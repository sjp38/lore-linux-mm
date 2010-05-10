Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 395126200C5
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:40:06 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 04/25] lmb: Remove nid_range argument, arch provides lmb_nid_range() instead
Date: Mon, 10 May 2010 19:38:38 +1000
Message-Id: <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/sparc/mm/init_64.c |   16 ++++++----------
 include/linux/lmb.h     |    7 +++++--
 lib/lmb.c               |   13 ++++++++-----
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 04590c9..88443c8 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -785,8 +785,7 @@ static int find_node(unsigned long addr)
 	return -1;
 }
 
-static unsigned long long nid_range(unsigned long long start,
-				    unsigned long long end, int *nid)
+u64 lmb_nid_range(u64 start, u64 end, int *nid)
 {
 	*nid = find_node(start);
 	start += PAGE_SIZE;
@@ -804,8 +803,7 @@ static unsigned long long nid_range(unsigned long long start,
 	return start;
 }
 #else
-static unsigned long long nid_range(unsigned long long start,
-				    unsigned long long end, int *nid)
+u64 lmb_nid_range(u64 start, u64 end, int *nid)
 {
 	*nid = 0;
 	return end;
@@ -822,8 +820,7 @@ static void __init allocate_node_data(int nid)
 	struct pglist_data *p;
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
-	paddr = lmb_alloc_nid(sizeof(struct pglist_data),
-			      SMP_CACHE_BYTES, nid, nid_range);
+	paddr = lmb_alloc_nid(sizeof(struct pglist_data), SMP_CACHE_BYTES, nid);
 	if (!paddr) {
 		prom_printf("Cannot allocate pglist_data for nid[%d]\n", nid);
 		prom_halt();
@@ -843,8 +840,7 @@ static void __init allocate_node_data(int nid)
 	if (p->node_spanned_pages) {
 		num_pages = bootmem_bootmap_pages(p->node_spanned_pages);
 
-		paddr = lmb_alloc_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid,
-				      nid_range);
+		paddr = lmb_alloc_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid);
 		if (!paddr) {
 			prom_printf("Cannot allocate bootmap for nid[%d]\n",
 				  nid);
@@ -984,7 +980,7 @@ static void __init add_node_ranges(void)
 			unsigned long this_end;
 			int nid;
 
-			this_end = nid_range(start, end, &nid);
+			this_end = lmb_nid_range(start, end, &nid);
 
 			numadbg("Adding active range nid[%d] "
 				"start[%lx] end[%lx]\n",
@@ -1317,7 +1313,7 @@ static void __init reserve_range_in_node(int nid, unsigned long start,
 		unsigned long this_end;
 		int n;
 
-		this_end = nid_range(start, end, &n);
+		this_end = lmb_nid_range(start, end, &n);
 		if (n == nid) {
 			numadbg("      MATCH reserving range [%lx:%lx]\n",
 				start, this_end);
diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index c2410fe..9caa67a 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -46,8 +46,7 @@ extern long lmb_add(u64 base, u64 size);
 extern long lmb_remove(u64 base, u64 size);
 extern long __init lmb_free(u64 base, u64 size);
 extern long __init lmb_reserve(u64 base, u64 size);
-extern u64 __init lmb_alloc_nid(u64 size, u64 align, int nid,
-				u64 (*nid_range)(u64, u64, int *));
+extern u64 __init lmb_alloc_nid(u64 size, u64 align, int nid);
 extern u64 __init lmb_alloc(u64 size, u64 align);
 extern u64 __init lmb_alloc_base(u64 size,
 		u64, u64 max_addr);
@@ -61,6 +60,10 @@ extern int lmb_is_region_reserved(u64 base, u64 size);
 
 extern void lmb_dump_all(void);
 
+/* Provided by the architecture */
+extern u64 lmb_nid_range(u64 start, u64 end, int *nid);
+
+
 /*
  * pfn conversion functions
  *
diff --git a/lib/lmb.c b/lib/lmb.c
index 5f21033..be3d7d9 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -319,7 +319,6 @@ static u64 __init lmb_alloc_nid_unreserved(u64 start, u64 end,
 }
 
 static u64 __init lmb_alloc_nid_region(struct lmb_region *mp,
-				       u64 (*nid_range)(u64, u64, int *),
 				       u64 size, u64 align, int nid)
 {
 	u64 start, end;
@@ -332,7 +331,7 @@ static u64 __init lmb_alloc_nid_region(struct lmb_region *mp,
 		u64 this_end;
 		int this_nid;
 
-		this_end = nid_range(start, end, &this_nid);
+		this_end = lmb_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
 			u64 ret = lmb_alloc_nid_unreserved(start, this_end,
 							   size, align);
@@ -345,8 +344,7 @@ static u64 __init lmb_alloc_nid_region(struct lmb_region *mp,
 	return ~(u64)0;
 }
 
-u64 __init lmb_alloc_nid(u64 size, u64 align, int nid,
-			 u64 (*nid_range)(u64 start, u64 end, int *nid))
+u64 __init lmb_alloc_nid(u64 size, u64 align, int nid)
 {
 	struct lmb_type *mem = &lmb.memory;
 	int i;
@@ -357,7 +355,6 @@ u64 __init lmb_alloc_nid(u64 size, u64 align, int nid,
 
 	for (i = 0; i < mem->cnt; i++) {
 		u64 ret = lmb_alloc_nid_region(&mem->regions[i],
-					       nid_range,
 					       size, align, nid);
 		if (ret != ~(u64)0)
 			return ret;
@@ -505,3 +502,9 @@ int lmb_is_region_reserved(u64 base, u64 size)
 	return lmb_overlaps_region(&lmb.reserved, base, size);
 }
 
+u64 __weak lmb_nid_range(u64 start, u64 end, int *nid)
+{
+	*nid = 0;
+
+	return end;
+}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
