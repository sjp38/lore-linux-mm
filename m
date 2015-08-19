Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 61AD96B0255
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 10:44:45 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so10579550wib.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:44:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cv6si2448541wib.31.2015.08.19.07.44.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Aug 2015 07:44:43 -0700 (PDT)
Subject: Re: [PATCH 06/10] mm: page_alloc: Distinguish between being unable to
 sleep, unwilling to unwilling and avoiding waking kswapd
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-7-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D49658.50802@suse.cz>
Date: Wed, 19 Aug 2015 16:44:40 +0200
MIME-Version: 1.0
In-Reply-To: <1439376335-17895-7-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 08/12/2015 12:45 PM, Mel Gorman wrote:
> __GFP_WAIT has been used to identify atomic context in callers that hold
> spinlocks or are in interrupts. They are expected to be high priority and
> have access one of two watermarks lower than "min". __GFP_HIGH users get
> access to the first lower watermark and can be called the "high priority
> reserve". Atomic users and interrupts access yet another lower watermark
> that can be called the "atomic reserve".
> 
> Over time, callers had a requirement to not block when fallback options
> were available. Some have abused __GFP_WAIT leading to a situation where
> an optimisitic allocation with a fallback option can access atomic reserves.
> 
> This patch uses __GFP_ATOMIC to identify callers that are truely atomic,
> cannot sleep and have no alternative. High priority users continue to use
> __GFP_HIGH. __GFP_DIRECT_RECLAIM identifies callers that can sleep and are
> willing to enter direct reclaim. __GFP_KSWAPD_RECLAIM to identify callers
> that want to wake kswapd for background reclaim. __GFP_WAIT is redefined
> as a caller that is willing to enter direct reclaim and wake kswapd for
> background reclaim.
> 
> This patch then converts a number of sites
> 
> o __GFP_ATOMIC is used by callers that are high priority and have memory
>   pools for those requests. GFP_ATOMIC uses this flag. Callers with
>   interrupts disabled still automatically use the atomic reserves.
> 
> o Callers that have a limited mempool to guarantee forward progress use
>   __GFP_DIRECT_RECLAIM. bio allocations fall into this category where
>   kswapd will still be woken but atomic reserves are not used as there
>   is a one-entry mempool to guarantee progress.
> 
> o Callers that are checking if they are non-blocking should use the
>   helper gfpflags_allows_blocking() where possible. This is because
>   checking for __GFP_WAIT as was done historically now can trigger false
>   positives. Some exceptions like dm-crypt.c exist where the code intent
>   is clearer if __GFP_DIRECT_RECLAIM is used instead of the helper due to
>   flag manipulations.
> 
> The key hazard to watch out for is callers that removed __GFP_WAIT and
> was depending on access to atomic reserves for inconspicuous reasons.
> In some cases it may be appropriate for them to use __GFP_HIGH.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

I like the approach, it makes things much clearer. Note that this isn't full
review, just something that crossed my mind.

> @@ -117,9 +132,9 @@ struct vm_area_struct;
>  #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
>  #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
>  #define GFP_IOFS	(__GFP_IO | __GFP_FS)
> -#define GFP_TRANSHUGE	(GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> -			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
> -			 __GFP_NO_KSWAPD)
> +#define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> +			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
> +			 ~__GFP_KSWAPD_RECLAIM)

Unfortunately this is not as simple for all uses of GFP_TRANSHUGE.
Namely in __alloc_pages_slowpath() the checks could use __GFP_NO_KSWAPD as one
of the distinguishing flags, but to test for lack of __GFP_KSWAPD_RECLAIM, they
should be adjusted in order to be functionally equivalent.
Yes, it would be better if we could get rid of them, but that's out of scope
here. So, something like this?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index beda417..e019a89 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3073,7 +3073,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/* Checks for THP-specific high-order allocations */
-	if ((gfp_mask & GFP_TRANSHUGE) == GFP_TRANSHUGE) {
+	if ((gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM))
+							== GFP_TRANSHUGE) {
 		/*
 		 * If compaction is deferred for high-order allocations, it is
 		 * because sync compaction recently failed. If this is the case
@@ -3108,8 +3109,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * fault, so use asynchronous memory compaction for THP unless it is
 	 * khugepaged trying to collapse.
 	 */
-	if ((gfp_mask & GFP_TRANSHUGE) != GFP_TRANSHUGE ||
-						(current->flags & PF_KTHREAD))
+	if ((gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)
+			!= GFP_TRANSHUGE) || (current->flags & PF_KTHREAD))
 		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/* Try direct reclaim and then allocating */



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
