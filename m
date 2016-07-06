Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 494E8828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 05:33:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so106350614wmr.0
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 02:33:43 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id a8si3125800wmc.18.2016.07.06.02.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 02:33:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id EF7001C26FD
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 10:33:39 +0100 (IST)
Date: Wed, 6 Jul 2016 10:33:38 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 31/31] mm, vmstat: Remove zone and node double accounting
 by approximating retries
Message-ID: <20160706093338.GO11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-32-git-send-email-mgorman@techsingularity.net>
 <20160706000252.GA12570@bbox>
 <20160706085850.GN11498@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160706085850.GN11498@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 06, 2016 at 09:58:50AM +0100, Mel Gorman wrote:
> On Wed, Jul 06, 2016 at 09:02:52AM +0900, Minchan Kim wrote:
> > On Fri, Jul 01, 2016 at 09:01:39PM +0100, Mel Gorman wrote:
> > > The number of LRU pages, dirty pages and writeback pages must be accounted
> > > for on both zones and nodes because of the reclaim retry logic, compaction
> > > retry logic and highmem calculations all depending on per-zone stats.
> > > 
> > > The retry logic is only critical for allocations that can use any zones.
> > 
> > Sorry, I cannot follow this assertion.
> > Could you explain?
> > 
> 
> The patch has been reworked since and I tried clarifying the changelog.
> Does this help?
> 

It occurred to me at breakfast that this should be more consistent with
the OOM killer on both 32-bit and 64-bit so;

diff --git a/mm/compaction.c b/mm/compaction.c
index dfe7dafe8e8b..640532831b94 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1448,11 +1448,9 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	struct zoneref *z;
 	pg_data_t *last_pgdat = NULL;
 
-#ifdef CONFIG_HIGHMEM
 	/* Do not retry compaction for zone-constrained allocations */
-	if (!is_highmem_idx(ac->high_zoneidx))
+	if (ac->high_zoneidx < ZONE_NORMAL)
 		return false;
-#endif
 
 	/*
 	 * Make sure at least one zone would pass __compaction_suitable if we continue
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ded48e580abc..194a8162528b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3455,11 +3455,11 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		return false;
 
 	/*
-	 * Blindly retry allocation requests that cannot use all zones. We do
-	 * not have a reliable and fast means of calculating reclaimable, dirty
-	 * and writeback pages in eligible zones.
+	 * Blindly retry lowmem allocation requests that are often ignored by
+	 * the OOM killer as we not have a reliable and fast means of
+	 * calculating reclaimable, dirty and writeback pages in eligible zones.
 	 */
-	if (IS_ENABLED(CONFIG_HIGHMEM) && !is_highmem_idx(gfp_zone(gfp_mask)))
+	if (ac->high_zoneidx < ZONE_NORMAL)
 		goto out;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
