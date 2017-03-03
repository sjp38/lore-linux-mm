Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DBE26B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 17:53:10 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v190so1840920pfb.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 14:53:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y12sor7560532pfg.5.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Mar 2017 14:53:09 -0800 (PST)
Date: Fri, 3 Mar 2017 14:53:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, vmstat: print non-populated zones in zoneinfo
In-Reply-To: <alpine.DEB.2.10.1703031445340.92298@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1703031451310.98023@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com> <4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com> <alpine.DEB.2.10.1703031445340.92298@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Initscripts can use the information (protection levels) from
/proc/zoneinfo to configure vm.lowmem_reserve_ratio at boot.

vm.lowmem_reserve_ratio is an array of ratios for each configured zone on
the system.  If a zone is not populated on an arch, /proc/zoneinfo
suppresses its output.

This results in there not being a 1:1 mapping between the set of zones
emitted by /proc/zoneinfo and the zones configured by
vm.lowmem_reserve_ratio.

This patch shows statistics for non-populated zones in /proc/zoneinfo.
The zones exist and hold a spot in the vm.lowmem_reserve_ratio array.
Without this patch, it is not possible to determine which index in the
array controls which zone if one or more zones on the system are not
populated.

Remaining users of walk_zones_in_node() are unchanged.  Files such as
/proc/pagetypeinfo require certain zone data to be initialized properly
for display, which is not done for unpopulated zones.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: - s/bool populated/b assert_populated/ per Anshuman
     - add comment to zoneinfo_show() to describe why we care

 mm/vmstat.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1121,8 +1121,12 @@ static void frag_stop(struct seq_file *m, void *arg)
 {
 }
 
-/* Walk all the zones in a node and print using a callback */
+/*
+ * Walk zones in a node and print using a callback.
+ * If @assert_populated is true, only use callback for zones that are populated.
+ */
 static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
+		bool assert_populated,
 		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
 {
 	struct zone *zone;
@@ -1130,7 +1134,7 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 	unsigned long flags;
 
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
-		if (!populated_zone(zone))
+		if (assert_populated && !populated_zone(zone))
 			continue;
 
 		spin_lock_irqsave(&zone->lock, flags);
@@ -1158,7 +1162,7 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 static int frag_show(struct seq_file *m, void *arg)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
-	walk_zones_in_node(m, pgdat, frag_show_print);
+	walk_zones_in_node(m, pgdat, true, frag_show_print);
 	return 0;
 }
 
@@ -1199,7 +1203,7 @@ static int pagetypeinfo_showfree(struct seq_file *m, void *arg)
 		seq_printf(m, "%6d ", order);
 	seq_putc(m, '\n');
 
-	walk_zones_in_node(m, pgdat, pagetypeinfo_showfree_print);
+	walk_zones_in_node(m, pgdat, true, pagetypeinfo_showfree_print);
 
 	return 0;
 }
@@ -1251,7 +1255,7 @@ static int pagetypeinfo_showblockcount(struct seq_file *m, void *arg)
 	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++)
 		seq_printf(m, "%12s ", migratetype_names[mtype]);
 	seq_putc(m, '\n');
-	walk_zones_in_node(m, pgdat, pagetypeinfo_showblockcount_print);
+	walk_zones_in_node(m, pgdat, true, pagetypeinfo_showblockcount_print);
 
 	return 0;
 }
@@ -1277,7 +1281,7 @@ static void pagetypeinfo_showmixedcount(struct seq_file *m, pg_data_t *pgdat)
 		seq_printf(m, "%12s ", migratetype_names[mtype]);
 	seq_putc(m, '\n');
 
-	walk_zones_in_node(m, pgdat, pagetypeinfo_showmixedcount_print);
+	walk_zones_in_node(m, pgdat, true, pagetypeinfo_showmixedcount_print);
 #endif /* CONFIG_PAGE_OWNER */
 }
 
@@ -1429,12 +1433,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 }
 
 /*
- * Output information about zones in @pgdat.
+ * Output information about zones in @pgdat.  All zones are printed regardless
+ * of whether they are populated or not: lowmem_reserve_ratio operates on the
+ * set of all zones and userspace would not be aware of such zones if they are
+ * suppressed here (zoneinfo displays the effect of lowmem_reserve_ratio).
  */
 static int zoneinfo_show(struct seq_file *m, void *arg)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
-	walk_zones_in_node(m, pgdat, zoneinfo_show_print);
+	walk_zones_in_node(m, pgdat, false, zoneinfo_show_print);
 	return 0;
 }
 
@@ -1853,7 +1860,7 @@ static int unusable_show(struct seq_file *m, void *arg)
 	if (!node_state(pgdat->node_id, N_MEMORY))
 		return 0;
 
-	walk_zones_in_node(m, pgdat, unusable_show_print);
+	walk_zones_in_node(m, pgdat, true, unusable_show_print);
 
 	return 0;
 }
@@ -1905,7 +1912,7 @@ static int extfrag_show(struct seq_file *m, void *arg)
 {
 	pg_data_t *pgdat = (pg_data_t *)arg;
 
-	walk_zones_in_node(m, pgdat, extfrag_show_print);
+	walk_zones_in_node(m, pgdat, true, extfrag_show_print);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
