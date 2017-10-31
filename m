Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A47A46B026C
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:40:31 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id j17so41804575iod.18
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:40:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a184si1636897ith.10.2017.10.31.03.40.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 03:40:30 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Try last second allocation before and after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1509178029-10156-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171030141815.lk76bfetmspf7f4x@dhcp22.suse.cz>
In-Reply-To: <20171030141815.lk76bfetmspf7f4x@dhcp22.suse.cz>
Message-Id: <201710311940.FDJ52199.OHMtSFVFOJLOQF@I-love.SAKURA.ne.jp>
Date: Tue, 31 Oct 2017 19:40:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, aarcange@redhat.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, hannes@cmpxchg.org, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> > +struct page *alloc_pages_before_oomkill(struct oom_control *oc)
> > +{
> > +	/*
> > +	 * Make sure that this allocation attempt shall not depend on
> > +	 * __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation, for the caller is
> > +	 * already holding oom_lock.
> > +	 */
> > +	const gfp_t gfp_mask = oc->gfp_mask & ~__GFP_DIRECT_RECLAIM;
> > +	struct alloc_context *ac = oc->ac;
> > +	unsigned int alloc_flags = gfp_to_alloc_flags(gfp_mask);
> > +	const int reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
> > +
> > +	/* Need to update zonelist if selected as OOM victim. */
> > +	if (reserve_flags) {
> > +		alloc_flags = reserve_flags;
> > +		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> > +		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > +					ac->high_zoneidx, ac->nodemask);
> > +	}
> 
> Why do we need this zone list rebuilding?

Why we do _not_ need this zone list rebuilding?

The reason I used __alloc_pages_slowpath() in alloc_pages_before_oomkill() is
to avoid duplicating code (such as checking for ALLOC_OOM and rebuilding zone
list) which needs to be maintained in sync with __alloc_pages_slowpath().
If you don't like calling __alloc_pages_slowpath() from
alloc_pages_before_oomkill(), I'm OK with calling __alloc_pages_nodemask()
(with __GFP_DIRECT_RECLAIM/__GFP_NOFAIL cleared and __GFP_NOWARN set), for
direct reclaim functions can call __alloc_pages_nodemask() (with PF_MEMALLOC
set in order to avoid recursion of direct reclaim).

We are rebuilding zone list if selected as an OOM victim, for
__gfp_pfmemalloc_flags() returns ALLOC_OOM if oom_reserves_allowed(current)
is true.

----------
static inline struct page *
__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
                       struct alloc_context *ac)
{
(...snipped...)
retry:
(...snipped...)
	reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
	if (reserve_flags)
		alloc_flags = reserve_flags;

	/*
	 * Reset the zonelist iterators if memory policies can be ignored.
	 * These allocations are high priority and system rather than user
	 * orientated.
	 */
	if (!(alloc_flags & ALLOC_CPUSET) || reserve_flags) {
		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
							     ac->high_zoneidx, ac->nodemask);
	}

	/* Attempt with potentially adjusted zonelist and alloc_flags */
	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
	if (page)
		goto got_pg;

	/* Caller is not willing to reclaim, we can't balance anything */
	if (!can_direct_reclaim)
		goto nopage;
(...snipped...)
	/* Reclaim has failed us, start killing things */
	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
	if (page)
		goto got_pg;

	/* Avoid allocations with no watermarks from looping endlessly */
	if (tsk_is_oom_victim(current) &&
	    (alloc_flags == ALLOC_OOM ||
	     (gfp_mask & __GFP_NOMEMALLOC)))
		goto nopage;

	/* Retry as long as the OOM killer is making progress */
	if (did_some_progress) {
		no_progress_loops = 0;
		goto retry;
	}
(...snipped...)
}
----------

The reason I'm proposing this "mm,oom: Try last second allocation before and
after selecting an OOM victim." is that since oom_reserves_allowed(current) can
become true when current is between post __gfp_pfmemalloc_flags(gfp_mask) and
pre mutex_trylock(&oom_lock), an OOM victim can fail to try ALLOC_OOM attempt
before selecting next OOM victim when MMF_OOM_SKIP was set quickly.

I tried to handle such race window by "mm, oom: task_will_free_mem(current)
should ignore MMF_OOM_SKIP for once." [1], and your response [2] was

  Find a _robust_ solution rather than
  fiddling with try-once-more kind of hacks. E.g. do an allocation attempt
  _before_ we do any disruptive action (aka kill a victim). This would
  help other cases when we race with an exiting tasks or somebody managed
  to free memory while we were selecting an oom victim which can take
  quite some time.

. Therefore, I tried to handle such race window by "mm,oom: Try last second
allocation after selecting an OOM victim." [3], and your response [4] was

  My primary question was

  : that the above link contains an explanation from Andrea that the reason
  : for the high wmark is to reduce the likelihood of livelocks and be sure
  : to invoke the OOM killer,

  I am not sure how much that reason applies to the current code but if it
  still applies then we should do the same for later
  last-minute-allocation as well. Having both and disagreeing is just a
  mess.

. Therefore, I proposed this "mm,oom: Try last second allocation before and
after selecting an OOM victim." which uses the same watermark, and this time
you are still worrying about stop using ALLOC_WMARK_HIGH. You are giving
inconsistent messages here. If stop using ALLOC_WMARK_HIGH has some risk (which
Andrea needs to clarify it), we can't stop using ALLOC_WMARK_HIGH here. But we
have to allow using ALLOC_OOM (either before and/or after selecting an OOM
victim) which will result in disagreement you don't like, for we cannot stop
using ALLOC_WMARK_HIGH when we need to use ALLOC_OOM in order to solve the race
window which [1] tries to handle.

[1] http://lkml.kernel.org/r/201708191523.BJH90621.MHOOFFQSOLJFtV@I-love.SAKURA.ne.jp
[2] http://lkml.kernel.org/r/20170821121022.GF25956@dhcp22.suse.cz
[3] http://lkml.kernel.org/r/1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
[4] http://lkml.kernel.org/r/20170825080020.GE25498@dhcp22.suse.cz

> 
> > +	return get_page_from_freelist(gfp_mask, oc->order, alloc_flags, ac);
> > +}
> > +
> >  static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
> >  		int preferred_nid, nodemask_t *nodemask,
> >  		struct alloc_context *ac, gfp_t *alloc_mask,



> On Sat 28-10-17 17:07:09, Tetsuo Handa wrote:
> > This patch splits last second allocation attempt into two locations, once
> > before selecting an OOM victim and again after selecting an OOM victim,
> > and uses normal watermark for last second allocation attempts.
> 
> Why do we need both?

For two reasons.

(1) You said

      E.g. do an allocation attempt
      _before_ we do any disruptive action (aka kill a victim). This would
      help other cases when we race with an exiting tasks or somebody managed
      to free memory while we were selecting an oom victim which can take
      quite some time.

    at [2]. By doing really last second allocation attempt after we select
    an OOM victim, we can remove oom_lock serialization from the OOM reaper
    which is currently there in order to avoid racing with MMF_OOM_SKIP.

(2) I said

      Since we call panic() before calling oom_kill_process() when there is
      no killable process, panic() will be prematurely called which could
      have been avoided if [2] is used. For example, if a multithreaded
      application running with a dedicated CPUs/memory was OOM-killed, we
      can wait until ALLOC_OOM allocation fails to solve OOM situation.

   at [3]. By doing almost last second allocation attempt before we select
   an OOM victim, we can avoid needlessly calling panic() when there is no
   other eligible threads other than existing OOM victim threads, as well as
   avoid needlessly calling out_of_memory() which you think that selecting
   an OOM victim can take quite some time.

> 
> > As of linux-2.6.11, nothing prevented from concurrently calling
> > out_of_memory(). TIF_MEMDIE test in select_bad_process() tried to avoid
> > needless OOM killing. Thus, it was safe to do __GFP_DIRECT_RECLAIM
> > allocation (apart from which watermark should be used) just before
> > calling out_of_memory().
> > 
> > As of linux-2.6.24, try_set_zone_oom() was added to
> > __alloc_pages_may_oom() by commit ff0ceb9deb6eb017 ("oom: serialize out
> > of memory calls") which effectively started acting as a kind of today's
> > mutex_trylock(&oom_lock).
> > 
> > As of linux-4.2, try_set_zone_oom() was replaced with oom_lock by
> > commit dc56401fc9f25e8f ("mm: oom_kill: simplify OOM killer locking").
> > At least by this time, it became no longer safe to do
> > __GFP_DIRECT_RECLAIM allocation with oom_lock held.
> > 
> > And as of linux-4.13, last second allocation attempt stopped using
> > __GFP_DIRECT_RECLAIM by commit e746bf730a76fe53 ("mm,page_alloc: don't
> > call __node_reclaim() with oom_lock held.").
> > 
> > Therefore, there is no longer valid reason to use ALLOC_WMARK_HIGH for
> > last second allocation attempt [1].
> 
> Another reason to use the high watermark as explained by Andrea was
> "
> : Elaborating the comment: the reason for the high wmark is to reduce
> : the likelihood of livelocks and be sure to invoke the OOM killer, if
> : we're still under pressure and reclaim just failed. The high wmark is
> : used to be sure the failure of reclaim isn't going to be ignored. If
> : using the min wmark like you propose there's risk of livelock or
> : anyway of delayed OOM killer invocation.
> "
> 
> How is that affected by changes in locking you discribe above?

Andrea, please come out and explain why using ALLOC_WMARK_HIGH helped
avoiding OOM livelock and delayed OOM killer invocation in linux-2.6.11.

Since we use !__GFP_DIRECT_RECLAIM for almost/really last second allocation
attempts (due to oom_lock already held), there is no possibility of OOM
livelock nor delayed OOM killer invocation. We stopped using
__GFP_DIRECT_RECLAIM for last second allocation attempt after Andrea
explained the reason to use ALLOC_WMARK_HIGH. The preconditions have
changed after Andrea explained it. If there is still possibility of OOM
livelock or delayed OOM killer invocation caused by stopped using
ALLOC_WMARK_HIGH, please explain why (and we will fall back to [1]).

> 
> > And this patch changes to do normal
> > allocation attempt, with handling of ALLOC_OOM added in order to mitigate
> > extra OOM victim selection problem reported by Manish Jaggi [2].
> > 
> > Doing really last second allocation attempt after selecting an OOM victim
> > will also help the OOM reaper to start reclaiming memory without waiting
> > for oom_lock to be released.
> 
> The changelog is much more obscure than it really needs to be. You fail
> to explain _why_ we need this and and _what_ the actual problem is. You
> are simply drowning in details here (btw. this is not the first time
> your changelog has this issues). Try to focus on _what_ is the problem
> _why_ do we care and _how_ are you addressing it.
>  

The actual problem is [1], and your response [2] was

  Find a _robust_ solution rather than
  fiddling with try-once-more kind of hacks. E.g. do an allocation attempt
  _before_ we do any disruptive action (aka kill a victim). This would
  help other cases when we race with an exiting tasks or somebody managed
  to free memory while we were selecting an oom victim which can take
  quite some time.

. I tried to follow your response as [3] and your response [4] was

  This a lot of text which can be more confusing than helpful. Could you
  state the problem clearly without detours?

. You are suggesting me to obscure it by trying to find a _robust_
solution which would help other cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
