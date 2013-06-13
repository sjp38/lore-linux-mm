Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 5E66790000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:04 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 10/22] x86, mm, numa: Move two functions calling on successful path later
Date: Thu, 13 Jun 2013 21:02:57 +0800
Message-Id: <1371128589-8953-11-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Yinghai Lu <yinghai@kernel.org>

We need to have numa info ready before init_mem_mappingi(), so that we
can call init_mem_mapping per node, and alse trim node memory ranges to
big alignment.

Currently, parsing numa info needs to allocate some buffer and need to be
called after init_mem_mapping. So try to split parsing numa info procedure
into two steps:
	- The first step will be called before init_mem_mapping, and it
	  should not need allocate buffers.
	- The second step will cantain all the buffer related code and be
	  executed later.

At last we will have early_initmem_init() and initmem_init().

This patch implements only the first step.

setup_node_data() and numa_init_array() are only called for successful
path, so we can move these two callings to x86_numa_init(). That will also
make numa_init() smaller and more readable.

-v2: remove online_node_map clear in numa_init(), as it is only
     set in setup_node_data() at last in successful path.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |   69 +++++++++++++++++++++++++++++----------------------
 1 files changed, 39 insertions(+), 30 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index a71c4e2..07ae800 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -477,7 +477,7 @@ static bool __init numa_meminfo_cover_memory(const struct numa_meminfo *mi)
 static int __init numa_register_memblks(struct numa_meminfo *mi)
 {
 	unsigned long uninitialized_var(pfn_align);
-	int i, nid;
+	int i;
 
 	/* Account for nodes with cpus and no memory */
 	node_possible_map = numa_nodes_parsed;
@@ -506,24 +506,6 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 	if (!numa_meminfo_cover_memory(mi))
 		return -EINVAL;
 
-	/* Finally register nodes. */
-	for_each_node_mask(nid, node_possible_map) {
-		u64 start = PFN_PHYS(max_pfn);
-		u64 end = 0;
-
-		for (i = 0; i < mi->nr_blks; i++) {
-			if (nid != mi->blk[i].nid)
-				continue;
-			start = min(mi->blk[i].start, start);
-			end = max(mi->blk[i].end, end);
-		}
-
-		if (start < end)
-			setup_node_data(nid, start, end);
-	}
-
-	/* Dump memblock with node info and return. */
-	memblock_dump_all();
 	return 0;
 }
 
@@ -559,7 +541,6 @@ static int __init numa_init(int (*init_func)(void))
 
 	nodes_clear(numa_nodes_parsed);
 	nodes_clear(node_possible_map);
-	nodes_clear(node_online_map);
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
 	WARN_ON(memblock_set_node(0, ULLONG_MAX, MAX_NUMNODES));
 	numa_reset_distance();
@@ -577,15 +558,6 @@ static int __init numa_init(int (*init_func)(void))
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < nr_cpu_ids; i++) {
-		int nid = early_cpu_to_node(i);
-
-		if (nid == NUMA_NO_NODE)
-			continue;
-		if (!node_online(nid))
-			numa_clear_node(i);
-	}
-	numa_init_array();
 	return 0;
 }
 
@@ -618,7 +590,7 @@ static int __init dummy_numa_init(void)
  * last fallback is dummy single node config encomapssing whole memory and
  * never fails.
  */
-void __init x86_numa_init(void)
+static void __init early_x86_numa_init(void)
 {
 	if (!numa_off) {
 #ifdef CONFIG_X86_NUMAQ
@@ -638,6 +610,43 @@ void __init x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
+void __init x86_numa_init(void)
+{
+	int i, nid;
+	struct numa_meminfo *mi = &numa_meminfo;
+
+	early_x86_numa_init();
+
+	/* Finally register nodes. */
+	for_each_node_mask(nid, node_possible_map) {
+		u64 start = PFN_PHYS(max_pfn);
+		u64 end = 0;
+
+		for (i = 0; i < mi->nr_blks; i++) {
+			if (nid != mi->blk[i].nid)
+				continue;
+			start = min(mi->blk[i].start, start);
+			end = max(mi->blk[i].end, end);
+		}
+
+		if (start < end)
+			setup_node_data(nid, start, end); /* online is set */
+	}
+
+	/* Dump memblock with node info */
+	memblock_dump_all();
+
+	for (i = 0; i < nr_cpu_ids; i++) {
+		int nid = early_cpu_to_node(i);
+
+		if (nid == NUMA_NO_NODE)
+			continue;
+		if (!node_online(nid))
+			numa_clear_node(i);
+	}
+	numa_init_array();
+}
+
 static __init int find_near_online_node(int node)
 {
 	int n, val;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
