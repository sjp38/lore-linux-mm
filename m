Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 12A2E6B03DE
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 07:48:04 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a199so79628405oib.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:48:04 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 22si2242299otj.313.2017.06.21.04.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 04:48:02 -0700 (PDT)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH] mm: avoid taking zone lock in pagetypeinfo_showmixed
Date: Wed, 21 Jun 2017 17:17:23 +0530
Message-Id: <1498045643-12257-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhongjiang@huawei.com, sergey.senozhatsky@gmail.com, sudipm.mukherjee@gmail.com, hannes@cmpxchg.org, mgorman@techsingularity.net, mhocko@suse.com, bigeasy@linutronix.de, rientjes@google.com, minchan@kernel.org
Cc: linux-mm@kvack.org, Vinayak Menon <vinmenon@codeaurora.org>

pagetypeinfo_showmixedcount_print is found to take a lot of
time to complete and it does this holding the zone lock and
disabling interrupts. In some cases it is found to take more
than a second (On a 2.4GHz,8Gb RAM,arm64 cpu). Avoid taking
the zone lock similar to what is done by read_page_owner,
which means possibility of inaccurate results.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/page_owner.c |  6 +++++-
 mm/vmstat.c     | 24 ++++++++++++++----------
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index c3cee24..401feb0 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -281,7 +281,11 @@ void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 				continue;
 
 			if (PageBuddy(page)) {
-				pfn += (1UL << page_order(page)) - 1;
+				unsigned long freepage_order;
+
+				freepage_order = page_order_unsafe(page);
+				if (freepage_order < MAX_ORDER)
+					pfn += (1UL << freepage_order) - 1;
 				continue;
 			}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f5fa1bd..8cefdad 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1129,7 +1129,7 @@ static void frag_stop(struct seq_file *m, void *arg)
  * If @assert_populated is true, only use callback for zones that are populated.
  */
 static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
-		bool assert_populated,
+		bool assert_populated, bool nolock,
 		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
 {
 	struct zone *zone;
@@ -1140,9 +1140,11 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 		if (assert_populated && !populated_zone(zone))
 			continue;
 
-		spin_lock_irqsave(&zone->lock, flags);
+		if (!nolock)
+			spin_lock_irqsave(&zone->lock, flags);
 		print(m, pgdat, zone);
-		spin_unlock_irqrestore(&zone->lock, flags);
+		if (!nolock)
+			spin_unlock_irqrestore(&zone->lock, flags);
 	}
 }
 #endif
@@ -1165,7 +1167,7 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 static int frag_show(struct seq_file *m, void *arg)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
-	walk_zones_in_node(m, pgdat, true, frag_show_print);
+	walk_zones_in_node(m, pgdat, true, false, frag_show_print);
 	return 0;
 }
 
@@ -1206,7 +1208,7 @@ static int pagetypeinfo_showfree(struct seq_file *m, void *arg)
 		seq_printf(m, "%6d ", order);
 	seq_putc(m, '\n');
 
-	walk_zones_in_node(m, pgdat, true, pagetypeinfo_showfree_print);
+	walk_zones_in_node(m, pgdat, true, false, pagetypeinfo_showfree_print);
 
 	return 0;
 }
@@ -1258,7 +1260,8 @@ static int pagetypeinfo_showblockcount(struct seq_file *m, void *arg)
 	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
 		seq_printf(m, "%12s ", migratetype_names[mtype]);
 	seq_putc(m, '\n');
-	walk_zones_in_node(m, pgdat, true, pagetypeinfo_showblockcount_print);
+	walk_zones_in_node(m, pgdat, true, false,
+		pagetypeinfo_showblockcount_print);
 
 	return 0;
 }
@@ -1284,7 +1287,8 @@ static void pagetypeinfo_showmixedcount(struct seq_file *m, pg_data_t *pgdat)
 		seq_printf(m, "%12s ", migratetype_names[mtype]);
 	seq_putc(m, '\n');
 
-	walk_zones_in_node(m, pgdat, true, pagetypeinfo_showmixedcount_print);
+	walk_zones_in_node(m, pgdat, true, true,
+		pagetypeinfo_showmixedcount_print);
 #endif /* CONFIG_PAGE_OWNER */
 }
 
@@ -1448,7 +1452,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 static int zoneinfo_show(struct seq_file *m, void *arg)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
-	walk_zones_in_node(m, pgdat, false, zoneinfo_show_print);
+	walk_zones_in_node(m, pgdat, false, false, zoneinfo_show_print);
 	return 0;
 }
 
@@ -1854,7 +1858,7 @@ static int unusable_show(struct seq_file *m, void *arg)
 	if (!node_state(pgdat->node_id, N_MEMORY))
 		return 0;
 
-	walk_zones_in_node(m, pgdat, true, unusable_show_print);
+	walk_zones_in_node(m, pgdat, true, false, unusable_show_print);
 
 	return 0;
 }
@@ -1906,7 +1910,7 @@ static int extfrag_show(struct seq_file *m, void *arg)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
 
-	walk_zones_in_node(m, pgdat, true, extfrag_show_print);
+	walk_zones_in_node(m, pgdat, true, false, extfrag_show_print);
 
 	return 0;
 }
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
