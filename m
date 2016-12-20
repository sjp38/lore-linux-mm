Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 058486B0313
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:43:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so25080552wma.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:43:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l128si19038914wml.79.2016.12.20.05.43.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Dec 2016 05:43:29 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, page_alloc: convert page_group_by_mobility_disable to static key
Date: Tue, 20 Dec 2016 14:43:12 +0100
Message-Id: <20161220134312.17332-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>

The flag is rarely enabled or even changed, so it's an ideal static key
candidate. Since it's being checked in the page allocator fastpath via
gfpflags_to_migratetype(), it may actually save some valuable cycles.

Here's a diff excerpt from __alloc_pages_nodemask() assembly:

        -movl    page_group_by_mobility_disabled(%rip), %ecx
	+.byte 0x0f,0x1f,0x44,0x00,0
         movl    %r9d, %eax
         shrl    $3, %eax
         andl    $3, %eax
        -testl   %ecx, %ecx
        -movl    $0, %ecx
        -cmovne  %ecx, %eax

I.e. a NOP instead of test, conditional move and some assisting moves.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/gfp.h    |  2 +-
 include/linux/mmzone.h |  3 ++-
 mm/page_alloc.c        | 23 +++++++++++++----------
 3 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f8041f9de31e..097609342608 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -270,7 +270,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 	BUILD_BUG_ON((1UL << GFP_MOVABLE_SHIFT) != ___GFP_MOVABLE);
 	BUILD_BUG_ON((___GFP_MOVABLE >> GFP_MOVABLE_SHIFT) != MIGRATE_MOVABLE);
 
-	if (unlikely(page_group_by_mobility_disabled))
+	if (static_branch_unlikely(&page_group_by_mobility_disabled))
 		return MIGRATE_UNMOVABLE;
 
 	/* Group based on mobility */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0f088f3a2fed..d1d440cff60e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -17,6 +17,7 @@
 #include <linux/pageblock-flags.h>
 #include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
+#include <linux/jump_label.h>
 #include <asm/page.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -78,7 +79,7 @@ extern char * const migratetype_names[MIGRATE_TYPES];
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
 
-extern int page_group_by_mobility_disabled;
+extern struct static_key_false page_group_by_mobility_disabled;
 
 #define NR_MIGRATETYPE_BITS (PB_migrate_end - PB_migrate + 1)
 #define MIGRATETYPE_MASK ((1UL << NR_MIGRATETYPE_BITS) - 1)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..655153ef8f2c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -281,7 +281,7 @@ EXPORT_SYMBOL(nr_node_ids);
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
-int page_group_by_mobility_disabled __read_mostly;
+DEFINE_STATIC_KEY_FALSE(page_group_by_mobility_disabled);
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
@@ -450,9 +450,10 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
 {
-	if (unlikely(page_group_by_mobility_disabled &&
-		     migratetype < MIGRATE_PCPTYPES))
-		migratetype = MIGRATE_UNMOVABLE;
+	if (static_branch_unlikely(&page_group_by_mobility_disabled)) {
+		if (migratetype < MIGRATE_PCPTYPES)
+			migratetype = MIGRATE_UNMOVABLE;
+	}
 
 	set_pageblock_flags_group(page, (unsigned long)migratetype,
 					PB_migrate, PB_migrate_end);
@@ -1945,8 +1946,10 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
 
 	if (order >= pageblock_order / 2 ||
 		start_mt == MIGRATE_RECLAIMABLE ||
-		start_mt == MIGRATE_UNMOVABLE ||
-		page_group_by_mobility_disabled)
+		start_mt == MIGRATE_UNMOVABLE)
+		return true;
+
+	if (static_branch_unlikely(&page_group_by_mobility_disabled))
 		return true;
 
 	return false;
@@ -1975,7 +1978,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 	/* Claim the whole block if over half of it is free */
 	if (pages >= (1 << (pageblock_order-1)) ||
-			page_group_by_mobility_disabled)
+	    static_branch_unlikely(&page_group_by_mobility_disabled))
 		set_pageblock_migratetype(page, start_type);
 }
 
@@ -4964,14 +4967,14 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 	 * disabled and enable it later
 	 */
 	if (vm_total_pages < (pageblock_nr_pages * MIGRATE_TYPES))
-		page_group_by_mobility_disabled = 1;
+		static_branch_enable(&page_group_by_mobility_disabled);
 	else
-		page_group_by_mobility_disabled = 0;
+		static_branch_disable(&page_group_by_mobility_disabled);
 
 	pr_info("Built %i zonelists in %s order, mobility grouping %s.  Total pages: %ld\n",
 		nr_online_nodes,
 		zonelist_order_name[current_zonelist_order],
-		page_group_by_mobility_disabled ? "off" : "on",
+		static_key_enabled(&page_group_by_mobility_disabled) ? "off" : "on",
 		vm_total_pages);
 #ifdef CONFIG_NUMA
 	pr_info("Policy zone: %s\n", zone_names[policy_zone]);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
