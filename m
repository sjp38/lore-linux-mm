Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0763A62007F
	for <linux-mm@kvack.org>; Mon, 17 May 2010 04:20:31 -0400 (EDT)
Message-ID: <4BF0FC4C.4060306@linux.intel.com>
Date: Mon, 17 May 2010 16:20:28 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] mem-hotplug: fix potential race while building zonelist
 for new populated zone
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

Make "zone->present_pages gets increased" and "building zonelist" an
atomic operation to prevent possible race.

It is merely a theoretical race: after new zone gets populated,
its pages might be allocated by others before itself building zonelist.

Besides, atomic operation ensures alloc_percpu() will never fail since
there is a new fresh memory block added.

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Andi Kleen <andi.kleen@intel.com>
---
  include/linux/memory_hotplug.h |    8 ++++++++
  mm/memory_hotplug.c            |   15 +++++++++------
  mm/page_alloc.c                |   20 ++++++++++++++++----
  3 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 35b07b7..42b1416 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -157,6 +157,14 @@ extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
  extern void put_page_bootmem(struct page *page);
  #endif

+/* online_pages() will pass such zone info to build_all_zonelists()
+ * when it needs to initialize a new zone.
+ */
+struct zone_online_info {
+	struct zone *zone;
+	unsigned long onlined_pages;
+};
+
  #else /* ! CONFIG_MEMORY_HOTPLUG */
  /*
   * Stub functions for when hotplug is off
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b564b6a..06738b2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -389,6 +389,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
  	int nid;
  	int ret;
  	struct memory_notify arg;
+	struct zone_online_info zone_online_info;
  	/*
  	 * mutex to protect zone->pageset when it's still shared
  	 * in onlined_pages()
@@ -434,13 +435,15 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
  		return ret;
  	}

-	zone->present_pages += onlined_pages;
-	zone->zone_pgdat->node_present_pages += onlined_pages;
-	if (need_zonelists_rebuild)
-		build_all_zonelists(zone);
-	else
+	if (need_zonelists_rebuild) {
+		zone_online_info.zone = zone;
+		zone_online_info.onlined_pages = onlined_pages;
+		build_all_zonelists(&zone_online_info);
+	} else {
+		zone->present_pages += onlined_pages;
+		zone->zone_pgdat->node_present_pages += onlined_pages;
  		zone_pcp_update(zone);
-
+	}
  	mutex_unlock(&zone_pageset_mutex);
  	setup_per_zone_wmarks();
  	calculate_zone_inactive_ratio(zone);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 72c1211..0729a82 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2783,6 +2783,20 @@ static __init_refok int __build_all_zonelists(void *data)
  {
  	int nid;
  	int cpu;
+#ifdef CONFIG_MEMORY_HOTPLUG
+	struct zone_online_info *new = (struct zone_online_info *)data;
+
+	/*
+	 * Populate the new zone before build zonelists, which could
+	 * happen only when onlining a new node after system is booted.
+	 */
+	if (new) {
+		/* We are expecting a new memory block here. */
+		WARN_ON(!new->onlined_pages);
+		new->zone->present_pages += new->onlined_pages;
+		new->zone->zone_pgdat->node_present_pages += new->onlined_pages;
+	}
+#endif

  #ifdef CONFIG_NUMA
  	memset(node_load, 0, sizeof(node_load));
@@ -2796,10 +2810,8 @@ static __init_refok int __build_all_zonelists(void *data)

  #ifdef CONFIG_MEMORY_HOTPLUG
  	/* Setup real pagesets for the new zone */
-	if (data) {
-		struct zone *zone = data;
-		setup_zone_pageset(zone);
-	}
+	if (new)
+		setup_zone_pageset(new->zone);
  #endif

  	/*
-- 
1.6.0.rc1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
