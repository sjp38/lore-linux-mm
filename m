Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0F80D6B00A3
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 09:10:16 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id d49so880545eek.5
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 06:10:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si2012451eeo.32.2013.12.13.06.10.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 06:10:16 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/7] mm: page_alloc: Only account batch allocations requests that are eligible
Date: Fri, 13 Dec 2013 14:10:06 +0000
Message-Id: <1386943807-29601-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-1-git-send-email-mgorman@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Not signed off. Johannes, was the intent really to decrement the batch
counts regardless of whether the policy was being enforced or not?

---
 mm/page_alloc.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c2a2229..bf49918 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1547,7 +1547,6 @@ again:
 					  get_pageblock_migratetype(page));
 	}
 
-	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
@@ -1923,7 +1922,8 @@ int sysctl_zone_distribute_mode_handler(ctl_table *table, int write,
  * other zones.
  */
 static bool zone_distribute_age(gfp_t gfp_mask, struct zone *preferred_zone,
-				struct zone *zone, int alloc_flags)
+				struct zone *zone, int alloc_flags,
+				bool *distrib_eligible)
 {
 	bool zone_is_local;
 	bool is_file, is_slab, is_anon;
@@ -1977,6 +1977,8 @@ static bool zone_distribute_age(gfp_t gfp_mask, struct zone *preferred_zone,
 	return true;
 
 check_batch:
+	*distrib_eligible = true;
+
 	/* Distribute to the next zone if this zone has exhausted its batch */
 	if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 		return true;
@@ -2000,6 +2002,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	bool distrib_eligible = false;
 
 	classzone_idx = zone_idx(preferred_zone);
 zonelist_scan:
@@ -2023,7 +2026,7 @@ zonelist_scan:
 
 		/* Distribute pages to ensure fair page aging */
 		if (zone_distribute_age(gfp_mask, preferred_zone, zone,
-					alloc_flags))
+				alloc_flags, &distrib_eligible))
 			continue;
 
 		/*
@@ -2119,8 +2122,11 @@ zonelist_scan:
 try_this_zone:
 		page = buffered_rmqueue(preferred_zone, zone, order,
 						gfp_mask, migratetype);
-		if (page)
+		if (page) {
+			if (distrib_eligible)
+				__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
 			break;
+		}
 this_zone_full:
 		if (IS_ENABLED(CONFIG_NUMA))
 			zlc_mark_zone_full(zonelist, z);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
