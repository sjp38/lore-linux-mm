Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id D8A129003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:39 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so80960414wib.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:39 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id n18si11961176wij.109.2015.07.20.01.00.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:24 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 8E07C98B6D
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:23 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [PATCH 06/10] mm, page_alloc: Use jump label to check if page grouping by mobility is enabled
Date: Mon, 20 Jul 2015 09:00:15 +0100
Message-Id: <1437379219-9160-7-git-send-email-mgorman@suse.com>
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

The global variable page_group_by_mobility_disabled remembers if page grouping
by mobility was disabled at boot time. It's more efficient to do this by jump
label.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h    |  2 +-
 include/linux/mmzone.h |  7 ++++++-
 mm/page_alloc.c        | 15 ++++++---------
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6d3a2d430715..5a27bbba63ed 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -151,7 +151,7 @@ static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
 {
 	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
 
-	if (unlikely(page_group_by_mobility_disabled))
+	if (page_group_by_mobility_disabled())
 		return MIGRATE_UNMOVABLE;
 
 	/* Group based on mobility */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 672ac437c43c..c9497519340a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -73,7 +73,12 @@ enum {
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
 
-extern int page_group_by_mobility_disabled;
+extern struct static_key page_group_by_mobility_key;
+
+static inline bool page_group_by_mobility_disabled(void)
+{
+	return static_key_false(&page_group_by_mobility_key);
+}
 
 #define NR_MIGRATETYPE_BITS (PB_migrate_end - PB_migrate + 1)
 #define MIGRATETYPE_MASK ((1UL << NR_MIGRATETYPE_BITS) - 1)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 56432b59b797..403cf31f8cf9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -228,7 +228,7 @@ EXPORT_SYMBOL(nr_node_ids);
 EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
-int page_group_by_mobility_disabled __read_mostly;
+struct static_key page_group_by_mobility_key __read_mostly = STATIC_KEY_INIT_FALSE;
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static inline void reset_deferred_meminit(pg_data_t *pgdat)
@@ -303,8 +303,7 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 
 void set_pageblock_migratetype(struct page *page, int migratetype)
 {
-	if (unlikely(page_group_by_mobility_disabled &&
-		     migratetype < MIGRATE_PCPTYPES))
+	if (page_group_by_mobility_disabled() && migratetype < MIGRATE_PCPTYPES)
 		migratetype = MIGRATE_UNMOVABLE;
 
 	set_pageblock_flags_group(page, (unsigned long)migratetype,
@@ -1501,7 +1500,7 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
 	if (order >= pageblock_order / 2 ||
 		start_mt == MIGRATE_RECLAIMABLE ||
 		start_mt == MIGRATE_UNMOVABLE ||
-		page_group_by_mobility_disabled)
+		page_group_by_mobility_disabled())
 		return true;
 
 	return false;
@@ -1530,7 +1529,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 	/* Claim the whole block if over half of it is free */
 	if (pages >= (1 << (pageblock_order-1)) ||
-			page_group_by_mobility_disabled)
+			page_group_by_mobility_disabled())
 		set_pageblock_migratetype(page, start_type);
 }
 
@@ -4156,15 +4155,13 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 	 * disabled and enable it later
 	 */
 	if (vm_total_pages < (pageblock_nr_pages * MIGRATE_TYPES))
-		page_group_by_mobility_disabled = 1;
-	else
-		page_group_by_mobility_disabled = 0;
+		static_key_slow_inc(&page_group_by_mobility_key);
 
 	pr_info("Built %i zonelists in %s order, mobility grouping %s.  "
 		"Total pages: %ld\n",
 			nr_online_nodes,
 			zonelist_order_name[current_zonelist_order],
-			page_group_by_mobility_disabled ? "off" : "on",
+			page_group_by_mobility_disabled() ? "off" : "on",
 			vm_total_pages);
 #ifdef CONFIG_NUMA
 	pr_info("Policy zone: %s\n", zone_names[policy_zone]);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
