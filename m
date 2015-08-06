Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 31B196B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 07:50:45 -0400 (EDT)
Received: by pabxd6 with SMTP id xd6so43424509pab.2
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 04:50:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y3si10969008pdq.207.2015.08.06.04.50.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Aug 2015 04:50:43 -0700 (PDT)
Subject: Re: [RFC 3/8] mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
	<1438768284-30927-4-git-send-email-mhocko@kernel.org>
	<201508052128.FIJ56269.QHSFOVFLOJOMFt@I-love.SAKURA.ne.jp>
	<20150805140230.GF11176@dhcp22.suse.cz>
In-Reply-To: <20150805140230.GF11176@dhcp22.suse.cz>
Message-Id: <201508062050.CAF21340.FJSOQOHVOLMtFF@I-love.SAKURA.ne.jp>
Date: Thu, 6 Aug 2015 20:50:27 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org

Michal Hocko wrote:
> On Wed 05-08-15 21:28:39, Tetsuo Handa wrote:
> > Reduced to only linux-mm.
> > 
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > 
> > > GFP_NOFS allocations are not allowed to invoke the OOM killer since
> > > their reclaim abilities are severely diminished.  However, without the
> > > OOM killer available there is no hope of progress once the reclaimable
> > > pages have been exhausted.
> > 
> > Excuse me, but I still cannot understand. Why are !__GFP_FS allocations
> > considered as "their reclaim abilities are severely diminished"?
> > 
> > It seems to me that not only GFP_NOFS allocation requests but also
> > almost all types of memory allocation requests do not include
> > __GFP_NO_KSWAPD flag.
> 
> __GFP_NO_KSWAPD is not to be used outside of very specific cases.
> 
> > Therefore, while a thread which called __alloc_pages_slowpath(GFP_NOFS)
> > cannot reclaim FS memory, I assume that kswapd kernel threads which are
> > woken up by the thread via wakeup_kswapd() via wake_all_kswapds() can
> > reclaim FS memory by calling balance_pgdat(). Is this assumption correct?
> 
> yes.
> 
OK. Then, it sounds to me that

  GFP_NOFS allocations' reclaim abilities are severely diminished as of
  reaching __alloc_pages_may_oom() for the first time of their allocation.
  But as time goes by, kswapd which has full reclaim abilities will reclaim
  memory which GFP_NOFS cannot reclaim. Thus, GFP_NOFS allocations' reclaim
  abilities is nearly equals to GFP_KERNEL if they waited for enough time.
  Therefore, GFP_NOFS allocations are allowed to invoke the OOM killer
  if they waited for enough time.

and the problem is that we don't have a trigger to teach that "You have
waited for enough duration but memory is still tight. Therefore, you can
invoke the OOM killer."

> > If the assumption is correct, when kswapd kernel threads returned from
> > balance_pgdat() or got stuck inside reclaiming functions (e.g. blocked at
> > mutex_lock() inside slab's shrinker functions), I think that the thread
> > which called __alloc_pages_slowpath(GFP_NOFS) has reclaimed FS memory
> > as if the thread called __alloc_pages_slowpath(GFP_KERNEL), and therefore
> > the thread qualifies calling out_of_memory() as with __GFP_FS allocations.
> 
> You are missing an important point. We are talking about OOM situation
> here. Which means that the background reclaim is not able to make
> sufficient progress and neither is the direct reclaim.

My worry here is about nearly OOM situation.

Generally, __GFP_WAIT allocations are more likely to succeed than
!__GFP_WAIT allocations. Therefore, GFP_ATOMIC allocations include
__GFP_HIGH in order to pass __zone_watermark_ok() when !__GFP_HIGH
allocations fail.

GFP_NOFS allocations include __GFP_WAIT but does not include __GFP_HIGH.
GFP_NOFS allocations will fail __zone_watermark_ok() when GFP_ATOMIC
allocations will pass. Thus, GFP_NOFS allocations retrying forever unless
TIF_MEMDIE is set is the toehold of likeliness of succeeding memory
allocation (except for the deadlock problem).

This patch changes !__GFP_FS allocations not to retry unless __GFP_NOFAIL is
set. I worry that we are going to make !__GFP_FS allocations less reliable
than GFP_ATOMIC allocations because the former is "close to !__GFP_WAIT" and
!__GFP_HIGH whereas the latter is "indeed !__GFP_WAIT" and __GFP_HIGH.

Therefore, I worry that, under nearly OOM condition where waiting for kswapd
kernel threads for a few seconds will reclaim FS memory which will be enough
to succeed the !__GFP_FS allocations, GFP_NOFS allocations start failing
prematurely. The toehold (reliability by __GFP_WAIT) is almost gone.

Therefore, I'm tempted to add __GFP_NOFAIL to GFP_NOFS/GFP_NOIO allocations.
If __GFP_NOFAIL is added, they will start calling out_of_memory() even under
nearly OOM condition where waiting for kswapd kernel threads for a few seconds
will reclaim memory which will be enough to succeed the GFP_NOFS/GFP_NOIO
allocations. The bad end is that out_of_memory() is called needlessly/frequently
than now, and I worry that OOM deadlock problem or depletion of memory reserves
occurs more likely than now due to a lot of __GFP_NOFAIL allocations.

Maybe, I'm tempted to replace GFP_NOFS/GFP_NOIO allocations with GFP_ATOMIC
allocations ( http://marc.info/?l=linux-xfs&m=142520873721204&w=2 ).

>                                                        While the
> GFP_IOFS requests are allowed to make a (V)FS activity which _might_
> help GFP_NOFS is not by definition. And that is why this reclaim context
> is less capable. Well to be more precise we do not perform IO (other
> than the swapout) from the direct reclaim context because of the stack
> restrictions so even GPF_IOFS is not _that_ strong but shrinkers are
> still free to do metadata specific actions.
>  
> > > Don't risk hanging these allocations.  Leave it to the allocation site
> > > to implement the fallback policy for failing allocations.
> > 
> > Are there memory pages which kswapd kernel threads cannot reclaim
> > but __alloc_pages_slowpath(GFP_KERNEL) allocations can reclaim
> > when __alloc_pages_slowpath(GFP_NOFS) allocations are hanging?
> 
> See above and have a look at the particular shrinkers code (e.g.
> super_cache_scan).

super_cache_scan() checks for __GFP_FS upon entry. If kswapd kernel threads
can call super_cache_scan() with GFP_KERNEL context, kswapd kernel threads
can reclaim. Thus, the answer to this question is "no" because I assume that
kswapd kernel threads can call super_cache_scan() with GFP_KERNEL context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
