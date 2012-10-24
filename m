Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 9B2996B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 05:42:10 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 1/2 V2] memory_hotplug: fix possible incorrect node_states[N_NORMAL_MEMORY]
Date: Wed, 24 Oct 2012 17:43:51 +0800
Message-Id: <1351071840-5060-2-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1351071840-5060-1-git-send-email-laijs@cn.fujitsu.com>
References: <1351071840-5060-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Kay Sievers <kay.sievers@vrfy.org>, Greg Kroah-Hartman <gregkh@suse.de>, Mel Gorman <mgorman@suse.de>, 'FNST-Wen Congyang' <wency@cn.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Jianguo Wu <wujianguo@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>

Currently memory_hotplug only manages the node_states[N_HIGH_MEMORY],
it forgets to manage node_states[N_NORMAL_MEMORY]. it may cause
node_states[N_NORMAL_MEMORY] becomes incorrect.

Example, if a node is empty before online, and we online a memory
which is in ZONE_NORMAL. And after online,  node_states[N_HIGH_MEMORY]
is correct, but node_states[N_NORMAL_MEMORY] is incorrect,
the online code don't set the new online node to
node_states[N_NORMAL_MEMORY].

The same things like it will happen when offline(the offline code
don't clear the node from node_states[N_NORMAL_MEMORY] when needed).
Some memory managment code depends node_states[N_NORMAL_MEMORY],
so we have to fix up the node_states[N_NORMAL_MEMORY].

We add node_states_check_changes_online() and node_states_check_changes_offline()
to detect whether node_states[N_HIGH_MEMORY] and node_states[N_NORMAL_MEMORY]
are changed while hotpluging.

Also add @status_change_nid_normal to struct memory_notify, thus
the memory hotplug callbacks know whether the node_states[N_NORMAL_MEMORY]
are changed. (We can add a @flags and reuse @status_change_nid instead of
introducing @status_change_nid_normal, but it will add much more complicated
in memory hotplug callback in every subsystem. So introdcing
@status_change_nid_normal is better and it don't change the sematic
of @status_change_nid)

Changed from V1:
	add more comments
	change the function name

CC: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Rob Landley <rob@landley.net>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Jiang Liu <jiang.liu@huawei.com>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Greg Kroah-Hartman <gregkh@suse.de>
CC: Mel Gorman <mgorman@suse.de>
CC: 'FNST-Wen Congyang' <wency@cn.fujitsu.com>
CC: linux-doc@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 Documentation/memory-hotplug.txt |    5 +-
 include/linux/memory.h           |    1 +
 mm/memory_hotplug.c              |  136 +++++++++++++++++++++++++++++++++-----
 3 files changed, 125 insertions(+), 17 deletions(-)

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
index ff9a9f8..a09216d 100644
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
index ec899a2..a1920fb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -467,6 +467,53 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	return 0;
 }
 
+/* check which state of node_states will be changed when online memory */
+static void node_states_check_changes_online(unsigned long nr_pages,
+	struct zone *zone, struct memory_notify *arg)
+{
+	int nid = zone_to_nid(zone);
+	enum zone_type zone_last = ZONE_NORMAL;
+
+	/*
+	 * If we have HIGHMEM, node_states[N_NORMAL_MEMORY] contains nodes
+	 * which have 0...ZONE_NORMAL, set zone_last to ZONE_NORMAL.
+	 *
+	 * If we don't have HIGHMEM, node_states[N_NORMAL_MEMORY] contains nodes
+	 * which have 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
+	 */
+	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+		zone_last = ZONE_MOVABLE;
+
+	/*
+	 * if the memory to be online is in a zone of 0...zone_last, and
+	 * the zones of 0...zone_last don't have memory before online, we will
+	 * need to set the node to node_states[N_NORMAL_MEMORY] after
+	 * the memory is online.
+	 */
+	if (zone_idx(zone) <= zone_last && !node_state(nid, N_NORMAL_MEMORY))
+		arg->status_change_nid_normal = nid;
+	else
+		arg->status_change_nid_normal = -1;
+
+	/*
+	 * if the node don't have memory befor online, we will need to
+	 * set the node to node_states[N_HIGH_MEMORY] after the memory
+	 * is online.
+	 */
+	if (!node_state(nid, N_HIGH_MEMORY))
+		arg->status_change_nid = nid;
+	else
+		arg->status_change_nid = -1;
+}
+
+static void node_states_set_node(int node, struct memory_notify *arg)
+{
+	if (arg->status_change_nid_normal >= 0)
+		node_set_state(node, N_NORMAL_MEMORY);
+
+	node_set_state(node, N_HIGH_MEMORY);
+}
+
 
 int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 {
@@ -478,13 +525,18 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
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
+	node_states_check_changes_online(nr_pages, zone, &arg);
 
 	nid = page_to_nid(pfn_to_page(pfn));
-	if (node_present_pages(nid) == 0)
-		arg.status_change_nid = nid;
 
 	ret = memory_notify(MEM_GOING_ONLINE, &arg);
 	ret = notifier_to_errno(ret);
@@ -494,12 +546,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
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
@@ -524,7 +570,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	zone->present_pages += onlined_pages;
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	if (onlined_pages) {
-		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
+		node_states_set_node(zone_to_nid(zone), &arg);
 		if (need_zonelists_rebuild)
 			build_all_zonelists(NULL, zone);
 		else
@@ -874,6 +920,67 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	return offlined;
 }
 
+/* check which state of node_states will be changed when offline memory */
+static void node_states_check_changes_offline(unsigned long nr_pages,
+		struct zone *zone, struct memory_notify *arg)
+{
+	struct pglist_data *pgdat = zone->zone_pgdat;
+	unsigned long present_pages = 0;
+	enum zone_type zt, zone_last = ZONE_NORMAL;
+
+	/*
+	 * If we have HIGHMEM, node_states[N_NORMAL_MEMORY] contains nodes
+	 * which have 0...ZONE_NORMAL, set zone_last to ZONE_NORMAL.
+	 *
+	 * If we don't have HIGHMEM, node_states[N_NORMAL_MEMORY] contains nodes
+	 * which have 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
+	 */
+	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+		zone_last = ZONE_MOVABLE;
+
+	/*
+	 * check whether node_states[N_NORMAL_MEMORY] will be changed.
+	 * If the memory to be offline is in a zone of 0...zone_last,
+	 * and it is the last present memory, 0...zone_last will
+	 * become empty after offline , thus we can determind we will
+	 * need to clear the node from node_states[N_NORMAL_MEMORY].
+	 */
+	for (zt = 0; zt <= zone_last; zt++)
+		present_pages += pgdat->node_zones[zt].present_pages;
+	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+		arg->status_change_nid_normal = zone_to_nid(zone);
+	else
+		arg->status_change_nid_normal = -1;
+
+	/*
+	 * node_states[N_HIGH_MEMORY] contains nodes which have 0...ZONE_MOVABLE
+	 */
+	zone_last = ZONE_MOVABLE;
+
+	/*
+	 * check whether node_states[N_HIGH_MEMORY] will be changed
+	 * If we try to offline the last present @nr_pages from the node,
+	 * we can determind we will need to clear the node from
+	 * node_states[N_HIGH_MEMORY].
+	 */
+	for (; zt <= zone_last; zt++)
+		present_pages += pgdat->node_zones[zt].present_pages;
+	if (nr_pages >= present_pages)
+		arg->status_change_nid = zone_to_nid(zone);
+	else
+		arg->status_change_nid = -1;
+}
+
+static void node_states_clear_node(int node, struct memory_notify *arg)
+{
+	if (arg->status_change_nid_normal >= 0)
+		node_clear_state(node, N_NORMAL_MEMORY);
+
+	if ((N_HIGH_MEMORY != N_NORMAL_MEMORY) &&
+	    (arg->status_change_nid >= 0))
+		node_clear_state(node, N_HIGH_MEMORY);
+}
+
 static int __ref __offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn, unsigned long timeout)
 {
@@ -907,9 +1014,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	arg.start_pfn = start_pfn;
 	arg.nr_pages = nr_pages;
-	arg.status_change_nid = -1;
-	if (nr_pages >= node_present_pages(node))
-		arg.status_change_nid = node;
+	node_states_check_changes_offline(nr_pages, zone, &arg);
 
 	ret = memory_notify(MEM_GOING_OFFLINE, &arg);
 	ret = notifier_to_errno(ret);
@@ -982,10 +1087,9 @@ repeat:
 	} else
 		zone_pcp_update(zone);
 
-	if (!node_present_pages(node)) {
-		node_clear_state(node, N_HIGH_MEMORY);
+	node_states_clear_node(node, &arg);
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
