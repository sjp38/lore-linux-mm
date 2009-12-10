Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 03BEA6B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 03:03:36 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA83YVR003870
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 17:03:34 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E0B345DE55
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:03:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F59445DE51
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:03:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06E301DB803A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:03:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3A871DB8040
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:03:30 +0900 (JST)
Date: Thu, 10 Dec 2009 17:00:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC mm][PATCH 4/5] add a lowmem check function
Message-Id: <20091210170036.dde2c147.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Final purpose of this patch is for improving oom/memoy shortage detection
better. In general there are OOM cases that lowmem is exhausted. What
this lowmem means is determined by the situation, but in general, 
limited amount of memory for some special use is lowmem.

This patch adds an integer lowmem_zone, which is initialized to -1.
If zone_idx(zone) <= lowmem_zone, the zone is lowmem.

This patch uses simple definition that the zone for special use is the lowmem.
Not taking the amount of memory into account.

For example,
  - if HIGHMEM is used, NORMAL is lowmem.
  - If the system has both of NORMAL and DMA32, DMA32 is lowmem.
  - When the system consists of only one zone, there are no lowmem.

This will be used for lowmem accounting per mm_struct and its information
will be used for oom-killer.

Changelog: 2009/12/09
 - stop using policy_zone and use unified definition on each config.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm.h |    9 +++++++
 mm/page_alloc.c    |   62 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)

Index: mmotm-2.6.32-Dec8/include/linux/mm.h
===================================================================
--- mmotm-2.6.32-Dec8.orig/include/linux/mm.h
+++ mmotm-2.6.32-Dec8/include/linux/mm.h
@@ -583,6 +583,15 @@ static inline void set_page_links(struct
 }
 
 /*
+ * Check a page is in lower zone
+ */
+extern int lowmem_zone;
+static inline bool is_lowmem_page(struct page *page)
+{
+	return page_zonenum(page) <= lowmem_zone;
+}
+
+/*
  * Some inline functions in vmstat.h depend on page_zone()
  */
 #include <linux/vmstat.h>
Index: mmotm-2.6.32-Dec8/mm/page_alloc.c
===================================================================
--- mmotm-2.6.32-Dec8.orig/mm/page_alloc.c
+++ mmotm-2.6.32-Dec8/mm/page_alloc.c
@@ -2311,6 +2311,59 @@ static void zoneref_set_zone(struct zone
 	zoneref->zone_idx = zone_idx(zone);
 }
 
+/* the zone is lowmem if zone_idx(zone) <= lowmem_zone */
+int lowmem_zone __read_mostly;
+/*
+ * Find out LOWMEM zone on this host. LOWMEM means a zone for special use
+ * and its size seems small and precious than other zones. For example,
+ * NORMAL zone is considered to be LOWMEM on a host which has HIGHMEM.
+ *
+ * This lowmem zone is determined by zone ordering and equipped memory layout.
+ * The amount of memory is not taken into account now.
+ */
+static void find_lowmem_zone(void)
+{
+	unsigned long pages[MAX_NR_ZONES];
+	struct zone *zone;
+	int idx;
+
+	for (idx = 0; idx < MAX_NR_ZONES; idx++)
+		pages[idx] = 0;
+	/* count the number of pages */
+	for_each_populated_zone(zone) {
+		idx = zone_idx(zone);
+		pages[idx] += zone->present_pages;
+	}
+	/* If We have HIGHMEM...we ignore ZONE_MOVABLE in this case. */
+#ifdef CONFIG_HIGHMEM
+	if (pages[ZONE_HIGHMEM]) {
+		lowmem_zone = ZONE_NORMAL;
+		return;
+	}
+#endif
+	/* If We have MOVABLE zone...which works like HIGHMEM. */
+	if (pages[ZONE_MOVABLE]) {
+		lowmem_zone = ZONE_NORMAL;
+		return;
+	}
+#ifdef CONFIG_ZONE_DMA32
+	/* If we have DMA32 and there is ZONE_NORMAL...*/
+	if (pages[ZONE_DMA32] && pages[ZONE_NORMAL]) {
+		lowmem_zone = ZONE_DMA32;
+		return;
+	}
+#endif
+#ifdef CONFIG_ZONE_DMA
+	/* If we have DMA and there is ZONE_NORMAL...*/
+	if (pages[ZONE_DMA] && pages[ZONE_NORMAL]) {
+		lowmem_zone = ZONE_DMA;
+		return;
+	}
+#endif
+	lowmem_zone = -1;
+	return;
+}
+
 /*
  * Builds allocation fallback zone lists.
  *
@@ -2790,12 +2843,21 @@ void build_all_zonelists(void)
 	else
 		page_group_by_mobility_disabled = 0;
 
+	find_lowmem_zone();
+
 	printk("Built %i zonelists in %s order, mobility grouping %s.  "
 		"Total pages: %ld\n",
 			nr_online_nodes,
 			zonelist_order_name[current_zonelist_order],
 			page_group_by_mobility_disabled ? "off" : "on",
 			vm_total_pages);
+
+	if (lowmem_zone >= 0)
+		printk("LOWMEM zone is detected as %s\n",
+			zone_names[lowmem_zone]);
+	else
+		printk("There are no special LOWMEM. The system seems flat\n");
+
 #ifdef CONFIG_NUMA
 	printk("Policy zone: %s\n", zone_names[policy_zone]);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
