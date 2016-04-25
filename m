Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C88CD6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 10:50:21 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id os9so81180034lbb.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:50:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa10si24326535wjd.171.2016.04.25.07.50.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 07:50:20 -0700 (PDT)
Subject: Re: [PATCH 05/28] mm, page_alloc: Inline the fast path of the
 zonelist iterator
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-6-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571E2EAA.2050206@suse.cz>
Date: Mon, 25 Apr 2016 16:50:18 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-6-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:58 AM, Mel Gorman wrote:
> The page allocator iterates through a zonelist for zones that match
> the addressing limitations and nodemask of the caller but many allocations
> will not be restricted. Despite this, there is always functional call
> overhead which builds up.
> 
> This patch inlines the optimistic basic case and only calls the
> iterator function for the complex case. A hindrance was the fact that
> cpuset_current_mems_allowed is used in the fastpath as the allowed nodemask
> even though all nodes are allowed on most systems. The patch handles this
> by only considering cpuset_current_mems_allowed if a cpuset exists. As well
> as being faster in the fast-path, this removes some junk in the slowpath.

I don't think this part is entirely correct (or at least argued as being
correct above), see below.
 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3193,17 +3193,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>   	 */
>   	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>   
> -	/*
> -	 * Find the true preferred zone if the allocation is unconstrained by
> -	 * cpusets.
> -	 */
> -	if (!(alloc_flags & ALLOC_CPUSET) && !ac->nodemask) {
> -		struct zoneref *preferred_zoneref;
> -		preferred_zoneref = first_zones_zonelist(ac->zonelist,
> -				ac->high_zoneidx, NULL, &ac->preferred_zone);
> -		ac->classzone_idx = zonelist_zone_idx(preferred_zoneref);
> -	}
> -
>   	/* This is the last chance, in general, before the goto nopage. */
>   	page = get_page_from_freelist(gfp_mask, order,
>   				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
> @@ -3359,14 +3348,21 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   	struct zoneref *preferred_zoneref;
>   	struct page *page = NULL;
>   	unsigned int cpuset_mems_cookie;
> -	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
> +	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
>   	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>   	struct alloc_context ac = {
>   		.high_zoneidx = gfp_zone(gfp_mask),
> +		.zonelist = zonelist,
>   		.nodemask = nodemask,
>   		.migratetype = gfpflags_to_migratetype(gfp_mask),
>   	};
>   
> +	if (cpusets_enabled()) {
> +		alloc_flags |= ALLOC_CPUSET;
> +		if (!ac.nodemask)
> +			ac.nodemask = &cpuset_current_mems_allowed;
> +	}

My initial reaction is that this is setting ac.nodemask in stone outside
of cpuset_mems_cookie, but I guess it's ok since we're taking a pointer
into current's task_struct, not the contents of the current's nodemask.
It's however setting a non-NULL nodemask into stone, which means no
zonelist iterator fasthpaths... but only in the slowpath. I guess it's
not an issue then.

> +
>   	gfp_mask &= gfp_allowed_mask;
>   
>   	lockdep_trace_alloc(gfp_mask);
> @@ -3390,16 +3386,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>   retry_cpuset:
>   	cpuset_mems_cookie = read_mems_allowed_begin();
>   
> -	/* We set it here, as __alloc_pages_slowpath might have changed it */
> -	ac.zonelist = zonelist;

This doesn't seem relevant to the preferred_zoneref changes in
__alloc_pages_slowpath, so why it became ok? Maybe it is, but it's not
clear from the changelog.

Anyway, thinking about it made me realize that maybe we could move the
whole mems_cookie thing into slowpath? As soon as the optimistic
fastpath succeeds, we don't check the cookie anyway, so what about
something like this on top?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d18061535c8b..07bf1065e7c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3183,6 +3183,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
 	struct page *page = NULL;
 	int alloc_flags;
+	unsigned int cpuset_mems_cookie;
 	unsigned long pages_reclaimed = 0;
 	unsigned long did_some_progress;
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
@@ -3209,6 +3210,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		gfp_mask &= ~__GFP_ATOMIC;
 
 retry:
+	cpuset_mems_cookie = read_mems_allowed_begin();
+
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
@@ -3219,17 +3222,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
-	/*
-	 * Find the true preferred zone if the allocation is unconstrained by
-	 * cpusets.
-	 */
-	if (!(alloc_flags & ALLOC_CPUSET) && !ac->nodemask) {
-		struct zoneref *preferred_zoneref;
-		preferred_zoneref = first_zones_zonelist(ac->zonelist,
-				ac->high_zoneidx, NULL, &ac->preferred_zone);
-		ac->classzone_idx = zonelist_zone_idx(preferred_zoneref);
-	}
-
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
@@ -3370,7 +3362,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (page)
 		goto got_pg;
 nopage:
+	/*
+	 * When updating a task's mems_allowed, it is possible to race with
+	 * parallel threads in such a way that an allocation can fail while
+	 * the mask is being updated. If a page allocation is about to fail,
+	 * check if the cpuset changed during allocation and if so, retry.
+	 */
+	if (read_mems_allowed_retry(cpuset_mems_cookie))
+		goto retry;
+
 	warn_alloc_failed(gfp_mask, order, NULL);
+
 got_pg:
 	return page;
 }
@@ -3384,7 +3386,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 {
 	struct zoneref *preferred_zoneref;
 	struct page *page = NULL;
-	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
 	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
 	struct alloc_context ac = {
@@ -3420,9 +3421,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 
-retry_cpuset:
-	cpuset_mems_cookie = read_mems_allowed_begin();
-
 	/* Dirty zone balancing only done in the fast path */
 	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
 
@@ -3430,13 +3428,15 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	preferred_zoneref = first_zones_zonelist(ac.zonelist, ac.high_zoneidx,
 				ac.nodemask, &ac.preferred_zone);
 	if (!ac.preferred_zone)
-		goto out;
+		goto slowpath;
 	ac.classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
 	/* First allocation attempt */
 	alloc_mask = gfp_mask|__GFP_HARDWALL;
 	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
+
 	if (unlikely(!page)) {
+slowpath:
 		/*
 		 * Runtime PM, block IO and its error handling path
 		 * can deadlock because I/O on the device might not
@@ -3453,16 +3453,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	trace_mm_page_alloc(page, order, alloc_mask, ac.migratetype);
 
-out:
-	/*
-	 * When updating a task's mems_allowed, it is possible to race with
-	 * parallel threads in such a way that an allocation can fail while
-	 * the mask is being updated. If a page allocation is about to fail,
-	 * check if the cpuset changed during allocation and if so, retry.
-	 */
-	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
-		goto retry_cpuset;
-
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
