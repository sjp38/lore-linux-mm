Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 723296B0034
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:09:19 -0400 (EDT)
Date: Tue, 30 Jul 2013 16:09:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 6/6] mm: memcg: do not trap chargers with full callstack
 on OOM
Message-ID: <20130730140913.GC15847@dhcp22.suse.cz>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
 <1374791138-15665-7-git-send-email-hannes@cmpxchg.org>
 <20130726144310.GH17761@dhcp22.suse.cz>
 <20130726212808.GD17975@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130726212808.GD17975@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 26-07-13 17:28:09, Johannes Weiner wrote:
[...]
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: memcg: rework and document OOM serialization
> 
> 1. Remove the return value of mem_cgroup_oom_unlock().
> 
> 2. Rename mem_cgroup_oom_lock() to mem_cgroup_oom_trylock().
> 
> 3. Pull the prepare_to_wait() out of the memcg_oom_lock scope.  This
>    makes it more obvious that the task has to be on the waitqueue
>    before attempting to OOM-trylock the hierarchy, to not miss any
>    wakeups before going to sleep.  It just didn't matter until now
>    because it was all lumped together into the global memcg_oom_lock
>    spinlock section.
> 
> 4. Pull the mem_cgroup_oom_notify() out of the memcg_oom_lock scope.
>    It is proctected by the hierarchical OOM-lock.
> 
> 5. The memcg_oom_lock spinlock is only required to propagate the OOM
>    lock in any given hierarchy atomically.  Restrict its scope to
>    mem_cgroup_oom_(trylock|unlock).
> 
> 6. Do not wake up the waitqueue unconditionally at the end of the
>    function.  Only the lockholder has to wake up the next in line
>    after releasing the lock.
> 
>    Note that the lockholder kicks off the OOM-killer, which in turn
>    leads to wakeups from the uncharges of the exiting task.  But any
>    contender is not guaranteed to see them if it enters the OOM path
>    after the OOM kills but before the lockholder releases the lock.
>    Thus the wakeup has to be explicitely after releasing the lock.
> 
> 7. Put the OOM task on the waitqueue before marking the hierarchy as
>    under OOM as that is the point where we start to receive wakeups.
>    No point in listening before being on the waitqueue.
> 
> 8. Likewise, unmark the hierarchy before finishing the sleep, for
>    symmetry.
> 

OK, this looks better than what we have today, but still could be done
better IMO ;)

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 85 +++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 47 insertions(+), 38 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 30ae46a..0d923df 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2076,15 +2076,18 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
>  	return total;
>  }
>  

/* Protects oom_lock hierarchy consistent state and oom_notify chain */

> +static DEFINE_SPINLOCK(memcg_oom_lock);
> +
>  /*
>   * Check OOM-Killer is already running under our hierarchy.
>   * If someone is running, return false.
> - * Has to be called with memcg_oom_lock
>   */
[...]
> @@ -2195,45 +2197,52 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
>  				  int order)
>  {
>  	struct oom_wait_info owait;
> -	bool locked, need_to_kill;
> +	bool locked;
>  
>  	owait.memcg = memcg;
>  	owait.wait.flags = 0;
>  	owait.wait.func = memcg_oom_wake_function;
>  	owait.wait.private = current;
>  	INIT_LIST_HEAD(&owait.wait.task_list);
> -	need_to_kill = true;
> -	mem_cgroup_mark_under_oom(memcg);
>  
> -	/* At first, try to OOM lock hierarchy under memcg.*/
> -	spin_lock(&memcg_oom_lock);
> -	locked = mem_cgroup_oom_lock(memcg);
>  	/*
> +	 * As with any blocking lock, a contender needs to start
> +	 * listening for wakeups before attempting the trylock,
> +	 * otherwise it can miss the wakeup from the unlock and sleep
> +	 * indefinitely.  This is just open-coded because our locking
> +	 * is so particular to memcg hierarchies.
> +	 *
>  	 * Even if signal_pending(), we can't quit charge() loop without
>  	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
>  	 * under OOM is always welcomed, use TASK_KILLABLE here.

Could you take care of this paragraph as well, while you are at it,
please? I've always found it it confusing. I would remove it completely
I would remove it completely.

>  	 */
>  	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> -	if (!locked || memcg->oom_kill_disable)
> -		need_to_kill = false;
> +	mem_cgroup_mark_under_oom(memcg);
> +
> +	locked = mem_cgroup_oom_trylock(memcg);
> +
>  	if (locked)
>  		mem_cgroup_oom_notify(memcg);
> -	spin_unlock(&memcg_oom_lock);
>  
> -	if (need_to_kill) {
> +	if (locked && !memcg->oom_kill_disable) {
> +		mem_cgroup_unmark_under_oom(memcg);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  		mem_cgroup_out_of_memory(memcg, mask, order);

Killing under hierarchy which is not under_oom sounds strange to me.
Cannot we just move finish_wait & unmark down after unlock? It would
also take care about incorrect memcg_oom_recover you have in oom_unlock
path. The ordering would also be more natural
	prepare_wait
	mark_under_oom
	trylock
	unlock
	unmark_under_oom
	finish_wait

>  	} else {
>  		schedule();
> +		mem_cgroup_unmark_under_oom(memcg);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  	}
> -	spin_lock(&memcg_oom_lock);
> -	if (locked)
> -		mem_cgroup_oom_unlock(memcg);
> -	memcg_wakeup_oom(memcg);
> -	spin_unlock(&memcg_oom_lock);
>  
> -	mem_cgroup_unmark_under_oom(memcg);
> +	if (locked) {
> +		mem_cgroup_oom_unlock(memcg);
> +		/*
> +		 * There is no guarantee that a OOM-lock contender
> +		 * sees the wakeups triggered by the OOM kill
> +		 * uncharges.  Wake any sleepers explicitely.
> +		 */
> +		memcg_oom_recover(memcg);

This will be a noop because memcg is no longer under_oom (you wanted
memcg_wakeup_oom here I guess). Moreover, even the killed wouldn't wake
up anybody for the same reason.

> +	}
>  
>  	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
>  		return false;
> -- 
> 1.8.3.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
