Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 2ADAB900002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:02 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part1 PATCH v5 13/22] x86, mm, numa: Use numa_meminfo to check node_map_pfn alignment
Date: Thu, 13 Jun 2013 21:03:00 +0800
Message-Id: <1371128589-8953-14-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Yinghai Lu <yinghai@kernel.org>

We could use numa_meminfo directly instead of memblock nid in
node_map_pfn_alignment().

So we could do setting memblock nid later and only do it once
for successful path.

-v2: according to tj, separate moving to another patch.

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |   30 +++++++++++++++++++-----------
 1 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 10c6240..cff565a 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -493,14 +493,18 @@ static bool __init numa_meminfo_cover_memory(const struct numa_meminfo *mi)
  * Returns the determined alignment in pfn's.  0 if there is no alignment
  * requirement (single node).
  */
-unsigned long __init node_map_pfn_alignment(void)
+#ifdef NODE_NOT_IN_PAGE_FLAGS
+static unsigned long __init node_map_pfn_alignment(struct numa_meminfo *mi)
 {
 	unsigned long accl_mask = 0, last_end = 0;
 	unsigned long start, end, mask;
 	int last_nid = -1;
 	int i, nid;
 
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start, &end, &nid) {
+	for (i = 0; i < mi->nr_blks; i++) {
+		start = mi->blk[i].start >> PAGE_SHIFT;
+		end = mi->blk[i].end >> PAGE_SHIFT;
+		nid = mi->blk[i].nid;
 		if (!start || last_nid < 0 || last_nid == nid) {
 			last_nid = nid;
 			last_end = end;
@@ -523,10 +527,16 @@ unsigned long __init node_map_pfn_alignment(void)
 	/* convert mask to number of pages */
 	return ~accl_mask + 1;
 }
+#else
+static unsigned long __init node_map_pfn_alignment(struct numa_meminfo *mi)
+{
+	return 0;
+}
+#endif
 
 static int __init numa_register_memblks(struct numa_meminfo *mi)
 {
-	unsigned long uninitialized_var(pfn_align);
+	unsigned long pfn_align;
 	int i;
 
 	/* Account for nodes with cpus and no memory */
@@ -538,24 +548,22 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 	if (!numa_meminfo_cover_memory(mi))
 		return -EINVAL;
 
-	for (i = 0; i < mi->nr_blks; i++) {
-		struct numa_memblk *mb = &mi->blk[i];
-		memblock_set_node(mb->start, mb->end - mb->start, mb->nid);
-	}
-
 	/*
 	 * If sections array is gonna be used for pfn -> nid mapping, check
 	 * whether its granularity is fine enough.
 	 */
-#ifdef NODE_NOT_IN_PAGE_FLAGS
-	pfn_align = node_map_pfn_alignment();
+	pfn_align = node_map_pfn_alignment(mi);
 	if (pfn_align && pfn_align < PAGES_PER_SECTION) {
 		printk(KERN_WARNING "Node alignment %LuMB < min %LuMB, rejecting NUMA config\n",
 		       PFN_PHYS(pfn_align) >> 20,
 		       PFN_PHYS(PAGES_PER_SECTION) >> 20);
 		return -EINVAL;
 	}
-#endif
+
+	for (i = 0; i < mi->nr_blks; i++) {
+		struct numa_memblk *mb = &mi->blk[i];
+		memblock_set_node(mb->start, mb->end - mb->start, mb->nid);
+	}
 
 	return 0;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
