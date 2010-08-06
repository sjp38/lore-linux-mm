Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B22A36B02A4
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:20:59 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FWjr013746
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FWcq1638560
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FVs8026915
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 15/43] memblock: Remove nid_range argument, arch provides memblock_nid_range() instead
Date: Fri,  6 Aug 2010 15:14:56 +1000
Message-Id: <1281071724-28740-16-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/sparc/mm/init_64.c  |   16 ++++++----------
 include/linux/memblock.h |    7 +++++--
 mm/memblock.c            |   13 ++++++++-----
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index dd68025..0883113 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -785,8 +785,7 @@ static int find_node(unsigned long addr)
 	return -1;
 }
 
-static unsigned long long nid_range(unsigned long long start,
-				    unsigned long long end, int *nid)
+u64 memblock_nid_range(u64 start, u64 end, int *nid)
 {
 	*nid = find_node(start);
 	start += PAGE_SIZE;
@@ -804,8 +803,7 @@ static unsigned long long nid_range(unsigned long long start,
 	return start;
 }
 #else
-static unsigned long long nid_range(unsigned long long start,
-				    unsigned long long end, int *nid)
+u64 memblock_nid_range(u64 start, u64 end, int *nid)
 {
 	*nid = 0;
 	return end;
@@ -822,8 +820,7 @@ static void __init allocate_node_data(int nid)
 	struct pglist_data *p;
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
-	paddr = memblock_alloc_nid(sizeof(struct pglist_data),
-			      SMP_CACHE_BYTES, nid, nid_range);
+	paddr = memblock_alloc_nid(sizeof(struct pglist_data), SMP_CACHE_BYTES, nid);
 	if (!paddr) {
 		prom_printf("Cannot allocate pglist_data for nid[%d]\n", nid);
 		prom_halt();
@@ -843,8 +840,7 @@ static void __init allocate_node_data(int nid)
 	if (p->node_spanned_pages) {
 		num_pages = bootmem_bootmap_pages(p->node_spanned_pages);
 
-		paddr = memblock_alloc_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid,
-				      nid_range);
+		paddr = memblock_alloc_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid);
 		if (!paddr) {
 			prom_printf("Cannot allocate bootmap for nid[%d]\n",
 				  nid);
@@ -984,7 +980,7 @@ static void __init add_node_ranges(void)
 			unsigned long this_end;
 			int nid;
 
-			this_end = nid_range(start, end, &nid);
+			this_end = memblock_nid_range(start, end, &nid);
 
 			numadbg("Adding active range nid[%d] "
 				"start[%lx] end[%lx]\n",
@@ -1317,7 +1313,7 @@ static void __init reserve_range_in_node(int nid, unsigned long start,
 		unsigned long this_end;
 		int n;
 
-		this_end = nid_range(start, end, &n);
+		this_end = memblock_nid_range(start, end, &n);
 		if (n == nid) {
 			numadbg("      MATCH reserving range [%lx:%lx]\n",
 				start, this_end);
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 776c7d9..367dea6 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -46,8 +46,7 @@ extern long memblock_add(u64 base, u64 size);
 extern long memblock_remove(u64 base, u64 size);
 extern long __init memblock_free(u64 base, u64 size);
 extern long __init memblock_reserve(u64 base, u64 size);
-extern u64 __init memblock_alloc_nid(u64 size, u64 align, int nid,
-				u64 (*nid_range)(u64, u64, int *));
+extern u64 __init memblock_alloc_nid(u64 size, u64 align, int nid);
 extern u64 __init memblock_alloc(u64 size, u64 align);
 extern u64 __init memblock_alloc_base(u64 size,
 		u64, u64 max_addr);
@@ -63,6 +62,10 @@ extern int memblock_is_region_reserved(u64 base, u64 size);
 
 extern void memblock_dump_all(void);
 
+/* Provided by the architecture */
+extern u64 memblock_nid_range(u64 start, u64 end, int *nid);
+
+
 /*
  * pfn conversion functions
  *
diff --git a/mm/memblock.c b/mm/memblock.c
index 8a118b7..13807f2 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -319,7 +319,6 @@ static u64 __init memblock_alloc_nid_unreserved(u64 start, u64 end,
 }
 
 static u64 __init memblock_alloc_nid_region(struct memblock_region *mp,
-				       u64 (*nid_range)(u64, u64, int *),
 				       u64 size, u64 align, int nid)
 {
 	u64 start, end;
@@ -332,7 +331,7 @@ static u64 __init memblock_alloc_nid_region(struct memblock_region *mp,
 		u64 this_end;
 		int this_nid;
 
-		this_end = nid_range(start, end, &this_nid);
+		this_end = memblock_nid_range(start, end, &this_nid);
 		if (this_nid == nid) {
 			u64 ret = memblock_alloc_nid_unreserved(start, this_end,
 							   size, align);
@@ -345,8 +344,7 @@ static u64 __init memblock_alloc_nid_region(struct memblock_region *mp,
 	return ~(u64)0;
 }
 
-u64 __init memblock_alloc_nid(u64 size, u64 align, int nid,
-			 u64 (*nid_range)(u64 start, u64 end, int *nid))
+u64 __init memblock_alloc_nid(u64 size, u64 align, int nid)
 {
 	struct memblock_type *mem = &memblock.memory;
 	int i;
@@ -357,7 +355,6 @@ u64 __init memblock_alloc_nid(u64 size, u64 align, int nid,
 
 	for (i = 0; i < mem->cnt; i++) {
 		u64 ret = memblock_alloc_nid_region(&mem->regions[i],
-					       nid_range,
 					       size, align, nid);
 		if (ret != ~(u64)0)
 			return ret;
@@ -531,3 +528,9 @@ int memblock_is_region_reserved(u64 base, u64 size)
 	return memblock_overlaps_region(&memblock.reserved, base, size) >= 0;
 }
 
+u64 __weak memblock_nid_range(u64 start, u64 end, int *nid)
+{
+	*nid = 0;
+
+	return end;
+}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
