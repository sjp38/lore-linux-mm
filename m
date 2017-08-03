Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA14D6B0693
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 07:00:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g28so1513892wrg.3
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 04:00:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si1330644wrf.473.2017.08.03.04.00.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 04:00:32 -0700 (PDT)
Date: Thu, 3 Aug 2017 13:00:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm, oom: do not rely on TIF_MEMDIE for memory
 reserves access
Message-ID: <20170803110030.GJ12521@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-2-mhocko@kernel.org>
 <20170802082914.GF2524@dhcp22.suse.cz>
 <20170803093701.icju4mxmto3ls3ch@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170803093701.icju4mxmto3ls3ch@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 03-08-17 10:37:01, Mel Gorman wrote:
> On Wed, Aug 02, 2017 at 10:29:14AM +0200, Michal Hocko wrote:
> >     For ages we have been relying on TIF_MEMDIE thread flag to mark OOM
> >     victims and then, among other things, to give these threads full
> >     access to memory reserves. There are few shortcomings of this
> >     implementation, though.
> >     
> 
> I believe the original intent was that allocations from the exit path
> would be small and relatively short-lived.

Yes.

> 
> >     First of all and the most serious one is that the full access to memory
> >     reserves is quite dangerous because we leave no safety room for the
> >     system to operate and potentially do last emergency steps to move on.
> >     
> >     Secondly this flag is per task_struct while the OOM killer operates
> >     on mm_struct granularity so all processes sharing the given mm are
> >     killed. Giving the full access to all these task_structs could lead to
> >     a quick memory reserves depletion.
> 
> This is a valid concern.
> 
> >     We have tried to reduce this risk by
> >     giving TIF_MEMDIE only to the main thread and the currently allocating
> >     task but that doesn't really solve this problem while it surely opens up
> >     a room for corner cases - e.g. GFP_NO{FS,IO} requests might loop inside
> >     the allocator without access to memory reserves because a particular
> >     thread was not the group leader.
> >     
> >     Now that we have the oom reaper and that all oom victims are reapable
> >     after 1b51e65eab64 ("oom, oom_reaper: allow to reap mm shared by the
> >     kthreads") we can be more conservative and grant only partial access to
> >     memory reserves because there are reasonable chances of the parallel
> >     memory freeing. We still want some access to reserves because we do not
> >     want other consumers to eat up the victim's freed memory. oom victims
> >     will still contend with __GFP_HIGH users but those shouldn't be so
> >     aggressive to starve oom victims completely.
> >     
> >     Introduce ALLOC_OOM flag and give all tsk_is_oom_victim tasks access to
> >     the half of the reserves. This makes the access to reserves independent
> >     on which task has passed through mark_oom_victim. Also drop any
> >     usage of TIF_MEMDIE from the page allocator proper and replace it by
> >     tsk_is_oom_victim as well which will make page_alloc.c completely
> >     TIF_MEMDIE free finally.
> >     
> >     CONFIG_MMU=n doesn't have oom reaper so let's stick to the original
> >     ALLOC_NO_WATERMARKS approach.
> >     
> >     There is a demand to make the oom killer memcg aware which will imply
> >     many tasks killed at once. This change will allow such a usecase without
> >     worrying about complete memory reserves depletion.
> >     
> >     Changes since v1
> >     - do not play tricks with nommu and grant access to memory reserves as
> >       long as TIF_MEMDIE is set
> >     - break out from allocation properly for oom victims as per Tetsuo
> >     - distinguish oom victims from other consumers of memory reserves in
> >       __gfp_pfmemalloc_flags - per Tetsuo
> >     
> >     Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > diff --git a/mm/internal.h b/mm/internal.h
> > index 24d88f084705..1ebcb1ed01b5 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -480,6 +480,17 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
> >  /* Mask to get the watermark bits */
> >  #define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
> >  
> > +/*
> > + * Only MMU archs have async oom victim reclaim - aka oom_reaper so we
> > + * cannot assume a reduced access to memory reserves is sufficient for
> > + * !MMU
> > + */
> > +#ifdef CONFIG_MMU
> > +#define ALLOC_OOM		0x08
> > +#else
> > +#define ALLOC_OOM		ALLOC_NO_WATERMARKS
> > +#endif
> > +
> >  #define ALLOC_HARDER		0x10 /* try to alloc harder */
> >  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> >  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> 
> Ok, no collision with the wmark indexes so that should be fine. While I
> didn't check, I suspect that !MMU users also have relatively few CPUs to
> allow major contention.

Well, I didn't try to improve the !MMU case because a) I do not know
whether there is a real problem with oom depletion there and b) I have
no way to test this. So I only focused on keeping the status quo for
nommu.

[...]

> > @@ -2943,10 +2943,19 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
> >  	 * the high-atomic reserves. This will over-estimate the size of the
> >  	 * atomic reserve but it avoids a search.
> >  	 */
> > -	if (likely(!alloc_harder))
> > +	if (likely(!alloc_harder)) {
> >  		free_pages -= z->nr_reserved_highatomic;
> > -	else
> > -		min -= min / 4;
> > +	} else {
> > +		/*
> > +		 * OOM victims can try even harder than normal ALLOC_HARDER
> > +		 * users
> > +		 */
> > +		if (alloc_flags & ALLOC_OOM)
> > +			min -= min / 2;
> > +		else
> > +			min -= min / 4;
> > +	}
> > +
> >  
> >  #ifdef CONFIG_CMA
> >  	/* If allocation can't use CMA areas don't use free CMA pages */
> 
> I see no problem here although the comment could be slightly better. It
> suggests at OOM victims can try harder but not why
> 
> /*
>  * OOM victims can try even harder than normal ALLOC_HARDER users on the
>  * grounds that it's definitely going to be in the exit path shortly and
>  * free memory. Any allocation it makes during the free path will be
>  * small and short-lived.
>  */

OK, I have replaced the coment.
 
> > @@ -3603,21 +3612,46 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  	return alloc_flags;
> >  }
> >  
> > -bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > +static bool oom_reserves_allowed(struct task_struct *tsk)
> >  {
> > -	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
> > +	if (!tsk_is_oom_victim(tsk))
> > +		return false;
> > +
> > +	/*
> > +	 * !MMU doesn't have oom reaper so give access to memory reserves
> > +	 * only to the thread with TIF_MEMDIE set
> > +	 */
> > +	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
> >  		return false;
> >  
> > +	return true;
> > +}
> > +
> 
> Ok, there is a chance that a task selected as an OOM kill victim may be
> in the middle of a __GFP_NOMEMALLOC allocation but I can't actually see a
> problem wiith that. __GFP_NOMEMALLOC users are not going to be in the exit
> path (which we care about for an OOM killed task) and the caller should
> always be able to handle a failure.

Not sure I understand. If the oom victim is doing __GFP_NOMEMALLOC then
we haven't been doing ALLOC_NO_WATERMARKS even before. So I preserve the
behavior here. Even though I am not sure this is a deliberate behavior
or something more of result of an evolution of the code.

> > +/*
> > + * Distinguish requests which really need access to full memory
> > + * reserves from oom victims which can live with a portion of it
> > + */
> > +static inline int __gfp_pfmemalloc_flags(gfp_t gfp_mask)
> > +{
> > +	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
> > +		return 0;
> >  	if (gfp_mask & __GFP_MEMALLOC)
> > -		return true;
> > +		return ALLOC_NO_WATERMARKS;
> >  	if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
> > -		return true;
> > -	if (!in_interrupt() &&
> > -			((current->flags & PF_MEMALLOC) ||
> > -			 unlikely(test_thread_flag(TIF_MEMDIE))))
> > -		return true;
> > +		return ALLOC_NO_WATERMARKS;
> > +	if (!in_interrupt()) {
> > +		if (current->flags & PF_MEMALLOC)
> > +			return ALLOC_NO_WATERMARKS;
> > +		else if (oom_reserves_allowed(current))
> > +			return ALLOC_OOM;
> > +	}
> >  
> > -	return false;
> > +	return 0;
> > +}
> > +
> > +bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
> > +{
> > +	return __gfp_pfmemalloc_flags(gfp_mask) > 0;
> >  }
> 
> Very subtle sign casing error here. If the flags ever use the high bit,
> this wraps and fails. It "shouldn't be possible" but you could just remove
> the "> 0" there to be on the safe side or have __gfp_pfmemalloc_flags
> return unsigned.

what about
	return !!__gfp_pfmemalloc_flags(gfp_mask);
 
> >  /*
> > @@ -3770,6 +3804,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	unsigned long alloc_start = jiffies;
> >  	unsigned int stall_timeout = 10 * HZ;
> >  	unsigned int cpuset_mems_cookie;
> > +	int reserves;
> >  
> 
> This should be explicitly named to indicate it's about flags and not the
> number of reserve pages or something else wacky.

s@reserves@reserve_flags@?

> >  	/*
> >  	 * In the slowpath, we sanity check order to avoid ever trying to
> > @@ -3875,15 +3910,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> >  		wake_all_kswapds(order, ac);
> >  
> > -	if (gfp_pfmemalloc_allowed(gfp_mask))
> > -		alloc_flags = ALLOC_NO_WATERMARKS;
> > +	reserves = __gfp_pfmemalloc_flags(gfp_mask);
> > +	if (reserves)
> > +		alloc_flags = reserves;
> >  
> 
> And if it's reserve_flags you can save a branch with
> 
> reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
> alloc_pags |= reserve_flags;
> 
> It won't make much difference considering how branch-intensive the allocator
> is anyway.

I was actually considering that but rather didn't want to do it because
I wanted to reset alloc_flags rather than create strange ALLOC_$FOO
combinations which would be harder to evaluate.
 
> >  	/*
> >  	 * Reset the zonelist iterators if memory policies can be ignored.
> >  	 * These allocations are high priority and system rather than user
> >  	 * orientated.
> >  	 */
> > -	if (!(alloc_flags & ALLOC_CPUSET) || (alloc_flags & ALLOC_NO_WATERMARKS)) {
> > +	if (!(alloc_flags & ALLOC_CPUSET) || reserves) {
> >  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> >  		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> >  					ac->high_zoneidx, ac->nodemask);
> > @@ -3960,8 +3996,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		goto got_pg;
> >  
> >  	/* Avoid allocations with no watermarks from looping endlessly */
> > -	if (test_thread_flag(TIF_MEMDIE) &&
> > -	    (alloc_flags == ALLOC_NO_WATERMARKS ||
> > +	if (tsk_is_oom_victim(current) &&
> > +	    (alloc_flags == ALLOC_OOM ||
> >  	     (gfp_mask & __GFP_NOMEMALLOC)))
> >  		goto nopage;
> >  
> 
> Mostly I only found nit-picks so whether you address them or not
> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks a lot for your review. Here is an incremental diff on top
---
commit 8483306e108a25441d796a8da3df5b85d633d859
Author: Michal Hocko <mhocko@suse.com>
Date:   Thu Aug 3 12:58:49 2017 +0200

    fold me "mm, oom: do not rely on TIF_MEMDIE for memory reserves access"
    
    - clarify access to memory reserves in __zone_watermark_ok - per Mel
    - make int->bool conversion in gfp_pfmemalloc_allowed more robust - per
      Mel
    - s@reserves@reserve_flags@ in __alloc_pages_slowpath - per Mel

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7ae0f6d45614..90e331e4c077 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2948,7 +2948,9 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 	} else {
 		/*
 		 * OOM victims can try even harder than normal ALLOC_HARDER
-		 * users
+		 * users on the grounds that it's definitely going to be in
+		 * the exit path shortly and free memory. Any allocation it
+		 * makes during the free path will be small and short-lived.
 		 */
 		if (alloc_flags & ALLOC_OOM)
 			min -= min / 2;
@@ -3651,7 +3653,7 @@ static inline int __gfp_pfmemalloc_flags(gfp_t gfp_mask)
 
 bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
-	return __gfp_pfmemalloc_flags(gfp_mask) > 0;
+	return !!__gfp_pfmemalloc_flags(gfp_mask);
 }
 
 /*
@@ -3804,7 +3806,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
 	unsigned int cpuset_mems_cookie;
-	int reserves;
+	int reserve_flags;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3910,16 +3912,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
-	reserves = __gfp_pfmemalloc_flags(gfp_mask);
-	if (reserves)
-		alloc_flags = reserves;
+	reserve_flags = __gfp_pfmemalloc_flags(gfp_mask);
+	if (reserve_flags)
+		alloc_flags = reserve_flags;
 
 	/*
 	 * Reset the zonelist iterators if memory policies can be ignored.
 	 * These allocations are high priority and system rather than user
 	 * orientated.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) || reserves) {
+	if (!(alloc_flags & ALLOC_CPUSET) || reserve_flags) {
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
 					ac->high_zoneidx, ac->nodemask);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
