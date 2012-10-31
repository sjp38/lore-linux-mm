Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 67C8B6B006E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 04:50:07 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART4 Patch 2/2] memory_hotplug: allow online/offline memory to result movable node
Date: Wed, 31 Oct 2012 16:15:34 +0800
Message-Id: <1351671334-10243-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351671334-10243-1-git-send-email-wency@cn.fujitsu.com>
References: <1351671334-10243-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

Now, memory management can handle movable node or nodes which don't have
any normal memory, so we can dynamic configure and add movable node by:
	online a ZONE_MOVABLE memory from a previous offline node
	offline the last normal memory which result a non-normal-memory-node

movable-node is very important for power-saving,
hardware partitioning and high-available-system(hardware fault management).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/memory_hotplug.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d07c66f..4aceb03 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -589,11 +589,19 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	return 0;
 }
 
+#ifdef CONFIG_MOVABLE_NODE
+/* when CONFIG_MOVABLE_NODE, we allow online node don't have normal memory */
+static bool can_online_high_movable(struct zone *zone)
+{
+	return true;
+}
+#else /* #ifdef CONFIG_MOVABLE_NODE */
 /* ensure every online node has NORMAL memory */
 static bool can_online_high_movable(struct zone *zone)
 {
 	return node_state(zone_to_nid(zone), N_NORMAL_MEMORY);
 }
+#endif /* #ifdef CONFIG_MOVABLE_NODE */
 
 /* check which state of node_states will be changed when online memory */
 static void node_states_check_changes_online(unsigned long nr_pages,
@@ -1097,6 +1105,13 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	return offlined;
 }
 
+#ifdef CONFIG_MOVABLE_NODE
+/* when CONFIG_MOVABLE_NODE, we allow online node don't have normal memory */
+static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
+{
+	return true;
+}
+#else /* #ifdef CONFIG_MOVABLE_NODE */
 /* ensure the node has NORMAL memory if it is still online */
 static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
 {
@@ -1120,6 +1135,7 @@ static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
 	 */
 	return present_pages == 0;
 }
+#endif /* #ifdef CONFIG_MOVABLE_NODE */
 
 /* check which state of node_states will be changed when offline memory */
 static void node_states_check_changes_offline(unsigned long nr_pages,
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
