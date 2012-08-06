Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 1A4FB6B005D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 05:23:30 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC V3 PATCH 02/25] memory_hotplug: fix missing nodemask management
Date: Mon, 6 Aug 2012 17:22:56 +0800
Message-Id: <1344244999-5081-3-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1344244999-5081-1-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
 <1344244999-5081-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Rob Landley <rob@landley.net>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Bjorn Helgaas <bhelgaas@google.com>, David Rientjes <rientjes@google.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

Currently memory_hotplug only manages the node_states[N_HIGH_MEMORY],
it forgot to manage node_states[N_NORMAL_MEMORY]. fix it.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 Documentation/memory-hotplug.txt |    5 ++-
 include/linux/memory.h           |    1 +
 mm/memory_hotplug.c              |   94 +++++++++++++++++++++++++++++++------
 3 files changed, 83 insertions(+), 17 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 6d0c251..6e6cbc7 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -377,15 +377,18 @@ The third argument is passed by pointer of struct memory_notify.
 struct memory_notify {
        unsigned long start_pfn;
        unsigned long nr_pages;
+       int status_change_nid_normal;
        int status_change_nid;
 }
 
 start_pfn is start_pfn of online/offline memory.
 nr_pages is # of pages of online/offline memory.
+status_change_nid_normal is set node id when N_NORMAL_MEMORY of nodemask
+is (will be) set/clear, if this is -1, then nodemask status is not changed.
 status_change_nid is set node id when N_HIGH_MEMORY of nodemask is (will be)
 set/clear. It means a new(memoryless) node gets new memory by online and a
 node loses all memory. If this is -1, then nodemask status is not changed.
-If status_changed_nid >= 0, callback should create/discard structures for the
+If status_changed_nid* >= 0, callback should create/discard structures for the
 node if necessary.
 
 --------------
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 1ac7f6e..6b9202b 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -53,6 +53,7 @@ int arch_get_memory_phys_device(unsigned long start_pfn);
 struct memory_notify {
 	unsigned long start_pfn;
 	unsigned long nr_pages;
+	int status_change_nid_normal;
 	int status_change_nid;
 };
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 427bb29..3438c4a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -456,6 +456,34 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	return 0;
 }
 
+static void check_nodemasks_changes_online(unsigned long nr_pages,
+	struct zone *zone, struct memory_notify *arg)
+{
+	int nid = zone_to_nid(zone);
+	enum zone_type zone_last = ZONE_NORMAL;
+
+	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+		zone_last = ZONE_MOVABLE;
+
+	if (zone_idx(zone) <= zone_last && !node_state(nid, N_NORMAL_MEMORY))
+		arg->status_change_nid_normal = nid;
+	else
+		arg->status_change_nid_normal = -1;
+
+	if (!node_state(nid, N_HIGH_MEMORY))
+		arg->status_change_nid = nid;
+	else
+		arg->status_change_nid = -1;
+}
+
+static void set_nodemasks(int node, struct memory_notify *arg)
+{
+	if (arg->status_change_nid_normal >= 0)
+		node_set_state(node, N_NORMAL_MEMORY);
+
+	node_set_state(node, N_HIGH_MEMORY);
+}
+
 
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 {
@@ -467,13 +495,18 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	struct memory_notify arg;
 
 	lock_memory_hotplug();
+	/*
+	 * This doesn't need a lock to do pfn_to_page().
+	 * The section can't be removed here because of the
+	 * memory_block->state_mutex.
+	 */
+	zone = page_zone(pfn_to_page(pfn));
+
 	arg.start_pfn = pfn;
 	arg.nr_pages = nr_pages;
-	arg.status_change_nid = -1;
+	check_nodemasks_changes_online(nr_pages, zone, &arg);
 
 	nid = page_to_nid(pfn_to_page(pfn));
-	if (node_present_pages(nid) == 0)
-		arg.status_change_nid = nid;
 
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
@@ -483,12 +516,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 		return ret;
 	}
 	/*
-	 * This doesn't need a lock to do pfn_to_page().
-	 * The section can't be removed here because of the
-	 * memory_block->state_mutex.
-	 */
-	zone = page_zone(pfn_to_page(pfn));
-	/*
 	 * If this zone is not populated, then it is not in zonelist.
 	 * This means the page allocator ignores this zone.
 	 * So, zonelist must be updated after online.
@@ -523,7 +550,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 
 	if (onlined_pages) {
 		kswapd_run(zone_to_nid(zone));
-		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
+		set_nodemasks(zone_to_nid(zone), &arg);
 	}
 
 	vm_total_pages = nr_free_pagecache_pages();
@@ -865,6 +892,44 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	return offlined;
 }
 
+static void check_nodemasks_changes_offline(unsigned long nr_pages,
+		struct zone *zone, struct memory_notify *arg)
+{
+	struct pglist_data *pgdat = zone->zone_pgdat;
+	unsigned long present_pages = 0;
+	enum zone_type zt, zone_last = ZONE_NORMAL;
+
+	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+		zone_last = ZONE_MOVABLE;
+
+	for (zt = 0; zt <= zone_last; zt++)
+		present_pages += pgdat->node_zones[zt].present_pages;
+	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+		arg->status_change_nid_normal = zone_to_nid(zone);
+	else
+		arg->status_change_nid_normal = -1;
+
+	zone_last = ZONE_MOVABLE;
+	for (; zt <= zone_last; zt++)
+		present_pages += pgdat->node_zones[zt].present_pages;
+	if (nr_pages >= present_pages)
+		arg->status_change_nid = zone_to_nid(zone);
+	else
+		arg->status_change_nid = -1;
+}
+
+static void clear_nodemasks(int node, struct memory_notify *arg)
+{
+	if (arg->status_change_nid_normal >= 0)
+		node_clear_state(node, N_NORMAL_MEMORY);
+
+	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+		return;
+
+	if (arg->status_change_nid >= 0)
+		node_clear_state(node, N_HIGH_MEMORY);
+}
+
 static int __ref offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn, unsigned long timeout)
 {
@@ -898,9 +963,7 @@ static int __ref offline_pages(unsigned long start_pfn,
 
 	arg.start_pfn = start_pfn;
 	arg.nr_pages = nr_pages;
-	arg.status_change_nid = -1;
-	if (nr_pages >= node_present_pages(node))
-		arg.status_change_nid = node;
+	check_nodemasks_changes_offline(nr_pages, zone, &arg);
 
 	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
 	ret = notifier_to_errno(ret);
@@ -965,10 +1028,9 @@ repeat:
 
 	init_per_zone_wmark_min();
 
-	if (!node_present_pages(node)) {
-		node_clear_state(node, N_HIGH_MEMORY);
+	clear_nodemasks(node, &arg);
+	if (arg.status_change_nid >= 0)
 		kswapd_stop(node);
-	}
 
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
