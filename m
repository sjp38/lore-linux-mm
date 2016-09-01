Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30BCE6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 02:59:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id vd14so139898925pab.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 23:59:34 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id p27si4824213otd.148.2016.08.31.23.59.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 23:59:33 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v8 08/16] arm64: numa: Use pr_fmt()
Date: Thu, 1 Sep 2016 14:54:59 +0800
Message-ID: <1472712907-12700-9-git-send-email-thunder.leizhen@huawei.com>
In-Reply-To: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
References: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank
 Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong
 Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

From: Kefeng Wang <wangkefeng.wang@huawei.com>

Use pr_fmt to prefix kernel output, and remove duplicated msg
of NUMA turned off.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 arch/arm64/mm/numa.c | 37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index d97c6e2..0e75b53 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -17,6 +17,8 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */

+#define pr_fmt(fmt) "NUMA: " fmt
+
 #include <linux/acpi.h>
 #include <linux/bootmem.h>
 #include <linux/memblock.h>
@@ -38,10 +40,9 @@ static __init int numa_parse_early_param(char *opt)
 {
 	if (!opt)
 		return -EINVAL;
-	if (!strncmp(opt, "off", 3)) {
-		pr_info("%s\n", "NUMA turned off");
+	if (!strncmp(opt, "off", 3))
 		numa_off = true;
-	}
+
 	return 0;
 }
 early_param("numa", numa_parse_early_param);
@@ -110,7 +111,7 @@ static void __init setup_node_to_cpumask_map(void)
 		set_cpu_numa_node(cpu, NUMA_NO_NODE);

 	/* cpumask_of_node() will now work */
-	pr_debug("NUMA: Node to cpumask map for %d nodes\n", nr_node_ids);
+	pr_debug("Node to cpumask map for %d nodes\n", nr_node_ids);
 }

 /*
@@ -145,13 +146,13 @@ int __init numa_add_memblk(int nid, u64 start, u64 end)

 	ret = memblock_set_node(start, (end - start), &memblock.memory, nid);
 	if (ret < 0) {
-		pr_err("NUMA: memblock [0x%llx - 0x%llx] failed to add on node %d\n",
+		pr_err("memblock [0x%llx - 0x%llx] failed to add on node %d\n",
 			start, (end - 1), nid);
 		return ret;
 	}

 	node_set(nid, numa_nodes_parsed);
-	pr_info("NUMA: Adding memblock [0x%llx - 0x%llx] on node %d\n",
+	pr_info("Adding memblock [0x%llx - 0x%llx] on node %d\n",
 			start, (end - 1), nid);
 	return ret;
 }
@@ -166,19 +167,18 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
 	void *nd;
 	int tnid;

-	pr_info("NUMA: Initmem setup node %d [mem %#010Lx-%#010Lx]\n",
-			nid, start_pfn << PAGE_SHIFT,
-			(end_pfn << PAGE_SHIFT) - 1);
+	pr_info("Initmem setup node %d [mem %#010Lx-%#010Lx]\n",
+		nid, start_pfn << PAGE_SHIFT, (end_pfn << PAGE_SHIFT) - 1);

 	nd_pa = memblock_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
 	nd = __va(nd_pa);

 	/* report and initialize */
-	pr_info("NUMA: NODE_DATA [mem %#010Lx-%#010Lx]\n",
+	pr_info("NODE_DATA [mem %#010Lx-%#010Lx]\n",
 		nd_pa, nd_pa + nd_size - 1);
 	tnid = early_pfn_to_nid(nd_pa >> PAGE_SHIFT);
 	if (tnid != nid)
-		pr_info("NUMA: NODE_DATA(%d) on node %d\n", nid, tnid);
+		pr_info("NODE_DATA(%d) on node %d\n", nid, tnid);

 	node_data[nid] = nd;
 	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
@@ -235,8 +235,7 @@ static int __init numa_alloc_distance(void)
 			numa_distance[i * numa_distance_cnt + j] = i == j ?
 				LOCAL_DISTANCE : REMOTE_DISTANCE;

-	pr_debug("NUMA: Initialized distance table, cnt=%d\n",
-			numa_distance_cnt);
+	pr_debug("Initialized distance table, cnt=%d\n", numa_distance_cnt);

 	return 0;
 }
@@ -257,20 +256,20 @@ static int __init numa_alloc_distance(void)
 void __init numa_set_distance(int from, int to, int distance)
 {
 	if (!numa_distance) {
-		pr_warn_once("NUMA: Warning: distance table not allocated yet\n");
+		pr_warn_once("Warning: distance table not allocated yet\n");
 		return;
 	}

 	if (from >= numa_distance_cnt || to >= numa_distance_cnt ||
 			from < 0 || to < 0) {
-		pr_warn_once("NUMA: Warning: node ids are out of bound, from=%d to=%d distance=%d\n",
+		pr_warn_once("Warning: node ids are out of bound, from=%d to=%d distance=%d\n",
 			    from, to, distance);
 		return;
 	}

 	if ((u8)distance != distance ||
 	    (from == to && distance != LOCAL_DISTANCE)) {
-		pr_warn_once("NUMA: Warning: invalid distance parameter, from=%d to=%d distance=%d\n",
+		pr_warn_once("Warning: invalid distance parameter, from=%d to=%d distance=%d\n",
 			     from, to, distance);
 		return;
 	}
@@ -297,7 +296,7 @@ static int __init numa_register_nodes(void)
 	/* Check that valid nid is set to memblks */
 	for_each_memblock(memory, mblk)
 		if (mblk->nid == NUMA_NO_NODE || mblk->nid >= MAX_NUMNODES) {
-			pr_warn("NUMA: Warning: invalid memblk node %d [mem %#010Lx-%#010Lx]\n",
+			pr_warn("Warning: invalid memblk node %d [mem %#010Lx-%#010Lx]\n",
 				mblk->nid, mblk->base,
 				mblk->base + mblk->size - 1);
 			return -EINVAL;
@@ -369,8 +368,8 @@ static int __init dummy_numa_init(void)

 	if (numa_off)
 		pr_info("NUMA disabled\n"); /* Forced off on command line. */
-	pr_info("NUMA: Faking a node at [mem %#018Lx-%#018Lx]\n",
-	       0LLU, PFN_PHYS(max_pfn) - 1);
+	pr_info("Faking a node at [mem %#018Lx-%#018Lx]\n",
+		0LLU, PFN_PHYS(max_pfn) - 1);

 	for_each_memblock(memory, mblk) {
 		ret = numa_add_memblk(0, mblk->base, mblk->base + mblk->size);
--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
