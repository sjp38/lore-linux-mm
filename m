Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4974D900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 15:36:47 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so13406135pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 12:36:46 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id s2si2279733pds.203.2015.06.03.12.36.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 12:36:46 -0700 (PDT)
Received: by pdbnf5 with SMTP id nf5so14069389pdb.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 12:36:45 -0700 (PDT)
Date: Thu, 4 Jun 2015 04:36:39 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] memcg: close the race window between OOM detection
 and killing
Message-ID: <20150603193639.GH20091@mtj.duckdns.org>
References: <20150603031544.GC7579@mtj.duckdns.org>
 <20150603144414.GG16201@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603144414.GG16201@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

Hey, Michal.

On Wed, Jun 03, 2015 at 04:44:14PM +0200, Michal Hocko wrote:
> The race does exist in the global case as well AFAICS.
> __alloc_pages_may_oom
>   mutex_trylock
>   get_page_from_freelist # fails
>   <preempted>				exit_mm # releases some memory
>   out_of_memory
>   					  exit_oom_victim
>     # No TIF_MEMDIE task so kill a new

Hmmm?  In -mm, if __alloc_page_may_oom() fails trylock, it never calls
out_of_memory().

> The race window might be smaller but it is possible in principle.
> Why does it make sense to treat those two in a different way?

The main difference here is that the alloc path does the whole thing
synchrnously and thus the OOM detection and killing can be put in the
same critical section which isn't the case for the memcg OOM handling.

> > The only reason memcg OOM killer behaves asynchronously (unwinding
> > stack and then handling) is memcg userland OOM handling, which may end
> > up blocking for userland actions while still holding whatever locks
> > that it was holding at the time it was invoking try_charge() leading
> > to a deadlock.
> 
> This is not the only reason. In-kernel memcg oom handling needs it
> as well. See 3812c8c8f395 ("mm: memcg: do not trap chargers with
> full callstack on OOM"). In fact it was the in-kernel case which has
> triggered this change. We simply cannot wait for oom with the stack and
> all the state the charge is called from.

Why should this be any different from OOM handling from page allocator
tho?  That can end up in the exact same situation and currently it
won't be able to get out of such situation - the OOM victim would be
stuck with OOM_SCAN_ABORT and all subsequent OOM invocations wouldn't
do anything due to OOM_SCAN_ABORT.

The solution here seems to be timing out on those waits.  ie. pick an
OOM victim, kill it, wait for it to exit for enough seconds.  If the
victim doesn't exit, ignore it and repeat the process, which is
guaranteed to make progress no matter what and appliable for both
allocator and memcg OOM handling.

> > IOW, it'd be cleaner to do everything synchronously while holding
> > oom_lock with timeout to get out of rare deadlocks.
> 
> Deadlocks are quite real and we really have to unwind and handle with a
> clean stack.

Yeah, they're real but we can deal with them in a more consistent way
using timeouts.

> > Memcg OOM killings are done at the end of page fault apart from OOM
> > detection.  This allows the following race condition.
> > 
> > 	Task A				Task B
> > 
> > 	OOM detection
> > 					OOM detection
> > 	OOM kill
> > 	victim exits
> > 					OOM kill
> > 
> > Task B has no way of knowing that another task has already killed an
> > OOM victim which proceeded to exit and release memory and will
> > unnecessarily pick another victim.  In highly contended cases, this
> > can lead to multiple unnecessary chained killings.
> 
> Yes I can see this might happen. I haven't seen this in the real life
> but I guess such a load can be constructed. The question is whether this
> is serious enough to make the code more complicated.

Yeah, I do have bug report and dmesg where multiple processes are
being killed (each one pretty large) when one should have been enough.

...
> > +void mem_cgroup_exit_oom_victim(void)
> > +{
> > +	struct mem_cgroup *memcg;
> > +
> > +	lockdep_assert_held(&oom_lock);
> > +
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_from_task(current);
> 
> The OOM might have happened in a parent memcg and the OOM victim might
> be a sibling or where ever in the hierarchy under oom memcg.
> So you have to use the OOM memcg to track the counter otherwise the
> tasks from other memcgs in the hierarchy racing with the oom victim
> would miss it anyway. You can store the target memcg into the victim
> when killing it.

In those cases there actually are more than one domains OOMing, but
yeah the count prolly should propagate all the way to the root.
Gees... I dislike this approach even more.  Grabbng the oom lock and
doing everything synchronously with timeout will be far simpler and
easier to follow.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
