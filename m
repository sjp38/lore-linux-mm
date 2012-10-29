Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 0ED626B0083
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:48:20 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [V5 PATCH 18/26] hotplug: update nodemasks management
Date: Mon, 29 Oct 2012 23:21:08 +0800
Message-Id: <1351524078-20363-17-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
References: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, x86 maintainers <x86@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Rob Landley <rob@landley.net>, Jianguo Wu <wujianguo@huawei.com>, Kay Sievers <kay.sievers@vrfy.org>, Wen Congyang <wency@cn.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

update nodemasks management for N_MEMORY

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 Documentation/memory-hotplug.txt |    5 ++-
 include/linux/memory.h           |    1 +
 mm/memory_hotplug.c              |   87 +++++++++++++++++++++++++++++++-------
 3 files changed, 77 insertions(+), 16 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index c6f993d..8e5eacb 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -390,6 +390,7 @@ struct memory_notify {
        unsigned long start_pfn;
        unsigned long nr_pages;
        int status_change_nid_normal;
+       int status_change_nid_high;
        int status_change_nid;
 }
 
@@ -397,7 +398,9 @@ start_pfn is start_pfn of online/offline memory.
 nr_pages is # of pages of online/offline memory.
 status_change_nid_normal is set node id when N_NORMAL_MEMORY of nodemask
 is (will be) set/clear, if this is -1, then nodemask status is not changed.
-status_change_nid is set node id when N_HIGH_MEMORY of nodemask is (will be)
+status_change_nid_high is set node id when N_HIGH_MEMORY of nodemask
+is (will be) set/clear, if this is -1, then nodemask status is not changed.
+status_change_nid is set node id when N_MEMORY of nodemask is (will be)
 set/clear. It means a new(memoryless) node gets new memory by online and a
 node loses all memory. If this is -1, then nodemask status is not changed.
 If status_changed_nid* >= 0, callback should create/discard structures for the
diff --git a/include/linux/memory.h b/include/linux/memory.h
index a09216d..45e93b4 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -54,6 +54,7 @@ struct memory_notify {
 	unsigned long start_pfn;
 	unsigned long nr_pages;
 	int status_change_nid_normal;
+	int status_change_nid_high;
 	int status_change_nid;
 };
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9af9641..a55b547 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -603,13 +603,15 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 	enum zone_type zone_last = ZONE_NORMAL;
 
 	/*
-	 * If we have HIGHMEM, node_states[N_NORMAL_MEMORY] contains nodes
-	 * which have 0...ZONE_NORMAL, set zone_last to ZONE_NORMAL.
+	 * If we have HIGHMEM or movable node, node_states[N_NORMAL_MEMORY]
+	 * contains nodes which have zones of 0...ZONE_NORMAL,
+	 * set zone_last to ZONE_NORMAL.
 	 *
-	 * If we don't have HIGHMEM, node_states[N_NORMAL_MEMORY] contains nodes
-	 * which have 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
+	 * If we don't have HIGHMEM nor movable node,
+	 * node_states[N_NORMAL_MEMORY] contains nodes which have zones of
+	 * 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
 	 */
-	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+	if (N_MEMORY == N_NORMAL_MEMORY)
 		zone_last = ZONE_MOVABLE;
 
 	/*
@@ -623,12 +625,34 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 	else
 		arg->status_change_nid_normal = -1;
 
+#ifdef CONFIG_HIGHMEM
+	/*
+	 * If we have movable node, node_states[N_HIGH_MEMORY]
+	 * contains nodes which have zones of 0...ZONE_HIGH,
+	 * set zone_last to ZONE_HIGH.
+	 *
+	 * If we don't have movable node, node_states[N_NORMAL_MEMORY]
+	 * contains nodes which have zones of 0...ZONE_MOVABLE,
+	 * set zone_last to ZONE_MOVABLE.
+	 */
+	zone_last = ZONE_HIGH;
+	if (N_MEMORY == N_HIGH_MEMORY)
+		zone_last = ZONE_MOVABLE;
+
+	if (zone_idx(zone) <= zone_last && !node_state(nid, N_HIGH_MEMORY))
+		arg->status_change_nid_high = nid;
+	else
+		arg->status_change_nid_high = -1;
+#else
+	arg->status_change_nid_high = arg->status_change_nid_normal;
+#endif
+
 	/*
 	 * if the node don't have memory befor online, we will need to
-	 * set the node to node_states[N_HIGH_MEMORY] after the memory
+	 * set the node to node_states[N_MEMORY] after the memory
 	 * is online.
 	 */
-	if (!node_state(nid, N_HIGH_MEMORY))
+	if (!node_state(nid, N_MEMORY))
 		arg->status_change_nid = nid;
 	else
 		arg->status_change_nid = -1;
@@ -639,7 +663,10 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_normal >= 0)
 		node_set_state(node, N_NORMAL_MEMORY);
 
-	node_set_state(node, N_HIGH_MEMORY);
+	if (arg->status_change_nid_high >= 0)
+		node_set_state(node, N_HIGH_MEMORY);
+
+	node_set_state(node, N_MEMORY);
 }
 
 
@@ -1103,13 +1130,15 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 	enum zone_type zt, zone_last = ZONE_NORMAL;
 
 	/*
-	 * If we have HIGHMEM, node_states[N_NORMAL_MEMORY] contains nodes
-	 * which have 0...ZONE_NORMAL, set zone_last to ZONE_NORMAL.
+	 * If we have HIGHMEM or movable node, node_states[N_NORMAL_MEMORY]
+	 * contains nodes which have zones of 0...ZONE_NORMAL,
+	 * set zone_last to ZONE_NORMAL.
 	 *
-	 * If we don't have HIGHMEM, node_states[N_NORMAL_MEMORY] contains nodes
-	 * which have 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
+	 * If we don't have HIGHMEM nor movable node,
+	 * node_states[N_NORMAL_MEMORY] contains nodes which have zones of
+	 * 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
 	 */
-	if (N_HIGH_MEMORY == N_NORMAL_MEMORY)
+	if (N_MEMORY == N_NORMAL_MEMORY)
 		zone_last = ZONE_MOVABLE;
 
 	/*
@@ -1126,6 +1155,30 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 	else
 		arg->status_change_nid_normal = -1;
 
+#ifdef CONIG_HIGHMEM
+	/*
+	 * If we have movable node, node_states[N_HIGH_MEMORY]
+	 * contains nodes which have zones of 0...ZONE_HIGH,
+	 * set zone_last to ZONE_HIGH.
+	 *
+	 * If we don't have movable node, node_states[N_NORMAL_MEMORY]
+	 * contains nodes which have zones of 0...ZONE_MOVABLE,
+	 * set zone_last to ZONE_MOVABLE.
+	 */
+	zone_last = ZONE_HIGH;
+	if (N_MEMORY == N_HIGH_MEMORY)
+		zone_last = ZONE_MOVABLE;
+
+	for (; zt <= zone_last; zt++)
+		present_pages += pgdat->node_zones[zt].present_pages;
+	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+		arg->status_change_nid_high = zone_to_nid(zone);
+	else
+		arg->status_change_nid_high = -1;
+#else
+	arg->status_change_nid_high = arg->status_change_nid_normal;
+#endif
+
 	/*
 	 * node_states[N_HIGH_MEMORY] contains nodes which have 0...ZONE_MOVABLE
 	 */
@@ -1150,9 +1203,13 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_normal >= 0)
 		node_clear_state(node, N_NORMAL_MEMORY);
 
-	if ((N_HIGH_MEMORY != N_NORMAL_MEMORY) &&
-	    (arg->status_change_nid >= 0))
+	if ((N_MEMORY != N_NORMAL_MEMORY) &&
+	    (arg->status_change_nid_high >= 0))
 		node_clear_state(node, N_HIGH_MEMORY);
+
+	if ((N_MEMORY != N_HIGH_MEMORY) &&
+	    (arg->status_change_nid >= 0))
+		node_clear_state(node, N_MEMORY);
 }
 
 static int __ref __offline_pages(unsigned long start_pfn,
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
