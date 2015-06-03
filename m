Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1968C900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 10:44:18 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so94072628wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:44:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9si1639098wje.62.2015.06.03.07.44.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Jun 2015 07:44:16 -0700 (PDT)
Date: Wed, 3 Jun 2015 16:44:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] memcg: close the race window between OOM detection
 and killing
Message-ID: <20150603144414.GG16201@dhcp22.suse.cz>
References: <20150603031544.GC7579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603031544.GC7579@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed 03-06-15 12:15:44, Tejun Heo wrote:
> Hello,
> 
> This patch closes the race window by introducing OOM victim generation
> number to detect whether any exited between OOM detection and killing;
> however, this isn't the prettiest thing in the world and is nasty in
> that memcg OOM mechanism deviates from system-wide OOM killer.

The race does exist in the global case as well AFAICS.
__alloc_pages_may_oom
  mutex_trylock
  get_page_from_freelist # fails
  <preempted>				exit_mm # releases some memory
  out_of_memory
  					  exit_oom_victim
    # No TIF_MEMDIE task so kill a new

The race window might be smaller but it is possible in principle.
Why does it make sense to treat those two in a different way?

> The only reason memcg OOM killer behaves asynchronously (unwinding
> stack and then handling) is memcg userland OOM handling, which may end
> up blocking for userland actions while still holding whatever locks
> that it was holding at the time it was invoking try_charge() leading
> to a deadlock.

This is not the only reason. In-kernel memcg oom handling needs it
as well. See 3812c8c8f395 ("mm: memcg: do not trap chargers with
full callstack on OOM"). In fact it was the in-kernel case which has
triggered this change. We simply cannot wait for oom with the stack and
all the state the charge is called from.

> However, given that userland OOMs are retriable, this doesn't have to
> be this complicated.  Waiting with timeout in try_charge()
> synchronously should be enough - in the unlikely cases where forward
> progress can't be made, the OOM killing can simply abort waiting and
> continue on.  If it is an OOM deadlock which requires death of more
> victims, OOM condition will trigger again and kill more.
> 
> IOW, it'd be cleaner to do everything synchronously while holding
> oom_lock with timeout to get out of rare deadlocks.

Deadlocks are quite real and we really have to unwind and handle with a
clean stack.

> What do you think?
> 
> Thanks.
> ----- 8< -----
> Memcg OOM killings are done at the end of page fault apart from OOM
> detection.  This allows the following race condition.
> 
> 	Task A				Task B
> 
> 	OOM detection
> 					OOM detection
> 	OOM kill
> 	victim exits
> 					OOM kill
> 
> Task B has no way of knowing that another task has already killed an
> OOM victim which proceeded to exit and release memory and will
> unnecessarily pick another victim.  In highly contended cases, this
> can lead to multiple unnecessary chained killings.

Yes I can see this might happen. I haven't seen this in the real life
but I guess such a load can be constructed. The question is whether this
is serious enough to make the code more complicated.
 
> This patch closes this race window by adding per-memcg OOM victim exit
> generation number.  Each task snapshots it when trying to charge.  If
> OOM condition is triggered, the kill path compares the remembered
> generation against the current value.  If they differ, it indicates
> that some victims have exited between the charge attempt and OOM kill
> path and the task shouldn't pick another victim.

The idea is good. See comments to the implementation below.

> The condition can be reliably triggered with multiple allocating
> processes by modifying mem_cgroup_oom_trylock() to retry several times
> with a short delay.  With the patch applied, memcg OOM correctly
> detects the race condition and skips OOM killing to retry the
> allocation.

Were you able to trigger this even without adding delays?

> Signed-off-by: Tejun Heo <tj@kernel.org>
> ---
>  include/linux/memcontrol.h |    9 ++++++-
>  include/linux/sched.h      |    3 +-
>  mm/memcontrol.c            |   52 +++++++++++++++++++++++++++++++++++++++++++++
>  mm/oom_kill.c              |    5 ++++
>  4 files changed, 66 insertions(+), 3 deletions(-)
> 
[...]
> +/**
> + * mem_cgroup_exit_oom_victim - note the exit of an OOM victim
> + *
> + * Called from exit_oom_victm() with oom_lock held.  This is used to bump
> + * memcg->oom_exit_gen which is used to avoid unnecessary chained OOM
> + * killings.
> + */
> +void mem_cgroup_exit_oom_victim(void)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	lockdep_assert_held(&oom_lock);
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);

The OOM might have happened in a parent memcg and the OOM victim might
be a sibling or where ever in the hierarchy under oom memcg.
So you have to use the OOM memcg to track the counter otherwise the
tasks from other memcgs in the hierarchy racing with the oom victim
would miss it anyway. You can store the target memcg into the victim
when killing it.

[...]
> @@ -2245,6 +2289,14 @@ static int try_charge(struct mem_cgroup
>  	if (mem_cgroup_is_root(memcg))
>  		goto done;
>  retry:
> +	/*
> +	 * Snapshot the current OOM exit generation number.  The generation
> +	 * number has to be updated after memory is released and read
> +	 * before charging is attempted.  Use load_acquire paired with
> +	 * store_release in mem_cgroup_exit_oom_victim() for ordering.
> +	 */
> +	current->memcg_oom.oom_exit_gen = smp_load_acquire(&memcg->oom_exit_gen);

Same here. You should store the oom memcg gen count. Ideally hook it
into mem_cgroup_oom.

> +
>  	if (consume_stock(memcg, nr_pages))
>  		goto done;
>  
[...]

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
