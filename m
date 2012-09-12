Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 6AFFC6B00E8
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 12:07:59 -0400 (EDT)
From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH] mm: bootmem: use phys_addr_t for physical addresses
Date: Wed, 12 Sep 2012 12:06:48 -0400
Message-ID: <1347466008-7231-1-git-send-email-cyril@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com, hannes@cmpxchg.org, shangw@linux.vnet.ibm.com, tj@kernel.org, vitalya@ti.com, Cyril Chemparathy <cyril@ti.com>

From: Vitaly Andrianov <vitalya@ti.com>

On a physical address extended (PAE) systems physical memory may be located
outside the first 4GB address range.  In particular, on TI Keystone devices,
all memory (including lowmem) is located outside the 4G address space. Many
functions in the bootmem.c use unsigned long as a type for physical addresses,
and this breaks badly on such PAE systems.

This patch intensively mangles the bootmem allocator to use phys_addr_t where
necessary.  We are aware that this is most certainly not the way to go
considering that the ARM architecture appears to be moving towards memblock.
Memblock may be a better solution, and fortunately it looks a lot more PAE
savvy than bootmem is.

However, we do not fully understand the motivations and restrictions behind
the mixed bootmem + memblock model in current ARM code. We hope for a
meaningful discussion and useful guidance towards a better solution to this
problem.

Signed-off-by: Vitaly Andrianov <vitalya@ti.com>
Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 include/linux/bootmem.h |   30 ++++++++++++------------
 mm/bootmem.c            |   59 ++++++++++++++++++++++++-----------------------
 2 files changed, 45 insertions(+), 44 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 6d6795d..e43c463 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -49,10 +49,10 @@ extern unsigned long free_all_bootmem_node(pg_data_t *pgdat);
 extern unsigned long free_all_bootmem(void);
 
 extern void free_bootmem_node(pg_data_t *pgdat,
-			      unsigned long addr,
+			      phys_addr_t addr,
 			      unsigned long size);
-extern void free_bootmem(unsigned long addr, unsigned long size);
-extern void free_bootmem_late(unsigned long addr, unsigned long size);
+extern void free_bootmem(phys_addr_t addr, unsigned long size);
+extern void free_bootmem_late(phys_addr_t addr, unsigned long size);
 
 /*
  * Flags for reserve_bootmem (also if CONFIG_HAVE_ARCH_BOOTMEM_NODE,
@@ -65,44 +65,44 @@ extern void free_bootmem_late(unsigned long addr, unsigned long size);
 #define BOOTMEM_DEFAULT		0
 #define BOOTMEM_EXCLUSIVE	(1<<0)
 
-extern int reserve_bootmem(unsigned long addr,
+extern int reserve_bootmem(phys_addr_t addr,
 			   unsigned long size,
 			   int flags);
 extern int reserve_bootmem_node(pg_data_t *pgdat,
-				unsigned long physaddr,
+				phys_addr_t physaddr,
 				unsigned long size,
 				int flags);
 
 extern void *__alloc_bootmem(unsigned long size,
 			     unsigned long align,
-			     unsigned long goal);
+			     phys_addr_t goal);
 extern void *__alloc_bootmem_nopanic(unsigned long size,
 				     unsigned long align,
-				     unsigned long goal);
+				     phys_addr_t goal);
 extern void *__alloc_bootmem_node(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
-				  unsigned long goal);
+				  phys_addr_t goal);
 void *__alloc_bootmem_node_high(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
-				  unsigned long goal);
+				  phys_addr_t goal);
 extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
-				  unsigned long goal);
+				  phys_addr_t goal);
 void *___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				  unsigned long size,
 				  unsigned long align,
-				  unsigned long goal,
-				  unsigned long limit);
+				  phys_addr_t goal,
+				  phys_addr_t limit);
 extern void *__alloc_bootmem_low(unsigned long size,
 				 unsigned long align,
-				 unsigned long goal);
+				 phys_addr_t goal);
 extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 				      unsigned long size,
 				      unsigned long align,
-				      unsigned long goal);
+				      phys_addr_t goal);
 
 #ifdef CONFIG_NO_BOOTMEM
 /* We are using top down, so it is safe to use 0 here */
@@ -137,7 +137,7 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 
-extern int reserve_bootmem_generic(unsigned long addr, unsigned long size,
+extern int reserve_bootmem_generic(phys_addr_t addr, unsigned long size,
 				   int flags);
 
 #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
diff --git a/mm/bootmem.c b/mm/bootmem.c
index f468185..3a4ee17 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -154,7 +154,7 @@ unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
  * down, but we are still initializing the system.  Pages are given directly
  * to the page allocator, no bootmem metadata is updated because it is gone.
  */
-void __init free_bootmem_late(unsigned long addr, unsigned long size)
+void __init free_bootmem_late(phys_addr_t addr, unsigned long size)
 {
 	unsigned long cursor, end;
 
@@ -362,7 +362,7 @@ static int __init mark_bootmem(unsigned long start, unsigned long end,
  *
  * The range must reside completely on the specified node.
  */
-void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
+void __init free_bootmem_node(pg_data_t *pgdat, phys_addr_t physaddr,
 			      unsigned long size)
 {
 	unsigned long start, end;
@@ -384,7 +384,7 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
  *
  * The range must be contiguous but may span node boundaries.
  */
-void __init free_bootmem(unsigned long addr, unsigned long size)
+void __init free_bootmem(phys_addr_t addr, unsigned long size)
 {
 	unsigned long start, end;
 
@@ -407,7 +407,7 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
  *
  * The range must reside completely on the specified node.
  */
-int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
+int __init reserve_bootmem_node(pg_data_t *pgdat, phys_addr_t physaddr,
 				 unsigned long size, int flags)
 {
 	unsigned long start, end;
@@ -428,7 +428,7 @@ int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
  *
  * The range must be contiguous but may span node boundaries.
  */
-int __init reserve_bootmem(unsigned long addr, unsigned long size,
+int __init reserve_bootmem(phys_addr_t addr, unsigned long size,
 			    int flags)
 {
 	unsigned long start, end;
@@ -439,7 +439,7 @@ int __init reserve_bootmem(unsigned long addr, unsigned long size,
 	return mark_bootmem(start, end, 1, flags);
 }
 
-int __weak __init reserve_bootmem_generic(unsigned long phys, unsigned long len,
+int __weak __init reserve_bootmem_generic(phys_addr_t phys, unsigned long len,
 				   int flags)
 {
 	return reserve_bootmem(phys, len, flags);
@@ -461,7 +461,7 @@ static unsigned long __init align_idx(struct bootmem_data *bdata,
 static unsigned long __init align_off(struct bootmem_data *bdata,
 				      unsigned long off, unsigned long align)
 {
-	unsigned long base = PFN_PHYS(bdata->node_min_pfn);
+	phys_addr_t base = PFN_PHYS(bdata->node_min_pfn);
 
 	/* Same as align_idx for byte offsets */
 
@@ -470,14 +470,14 @@ static unsigned long __init align_off(struct bootmem_data *bdata,
 
 static void * __init alloc_bootmem_bdata(struct bootmem_data *bdata,
 					unsigned long size, unsigned long align,
-					unsigned long goal, unsigned long limit)
+					phys_addr_t goal, phys_addr_t limit)
 {
 	unsigned long fallback = 0;
 	unsigned long min, max, start, sidx, midx, step;
 
-	bdebug("nid=%td size=%lx [%lu pages] align=%lx goal=%lx limit=%lx\n",
+	bdebug("nid=%td size=%lx [%lu pages] align=%lx goal=%llx limit=%llx\n",
 		bdata - bootmem_node_data, size, PAGE_ALIGN(size) >> PAGE_SHIFT,
-		align, goal, limit);
+		align, (u64)goal, (u64)limit);
 
 	BUG_ON(!size);
 	BUG_ON(align & (align - 1));
@@ -519,7 +519,8 @@ static void * __init alloc_bootmem_bdata(struct bootmem_data *bdata,
 	while (1) {
 		int merge;
 		void *region;
-		unsigned long eidx, i, start_off, end_off;
+		unsigned long eidx, i;
+		phys_addr_t   start_off, end_off;
 find_block:
 		sidx = find_next_zero_bit(bdata->node_bootmem_map, midx, sidx);
 		sidx = align_idx(bdata, sidx, step);
@@ -577,7 +578,7 @@ find_block:
 
 static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
 					unsigned long size, unsigned long align,
-					unsigned long goal, unsigned long limit)
+					phys_addr_t goal, phys_addr_t limit)
 {
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc(size, GFP_NOWAIT);
@@ -598,8 +599,8 @@ static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
 
 static void * __init alloc_bootmem_core(unsigned long size,
 					unsigned long align,
-					unsigned long goal,
-					unsigned long limit)
+					phys_addr_t goal,
+					phys_addr_t limit)
 {
 	bootmem_data_t *bdata;
 	void *region;
@@ -624,8 +625,8 @@ static void * __init alloc_bootmem_core(unsigned long size,
 
 static void * __init ___alloc_bootmem_nopanic(unsigned long size,
 					      unsigned long align,
-					      unsigned long goal,
-					      unsigned long limit)
+					      phys_addr_t goal,
+					      phys_addr_t limit)
 {
 	void *ptr;
 
@@ -655,15 +656,15 @@ restart:
  * Returns NULL on failure.
  */
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
-					unsigned long goal)
+					phys_addr_t goal)
 {
-	unsigned long limit = 0;
+	phys_addr_t limit = 0;
 
 	return ___alloc_bootmem_nopanic(size, align, goal, limit);
 }
 
 static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
-					unsigned long goal, unsigned long limit)
+					phys_addr_t goal, phys_addr_t limit)
 {
 	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit);
 
@@ -691,16 +692,16 @@ static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
  * The function panics if the request can not be satisfied.
  */
 void * __init __alloc_bootmem(unsigned long size, unsigned long align,
-			      unsigned long goal)
+			      phys_addr_t goal)
 {
-	unsigned long limit = 0;
+	phys_addr_t limit = 0;
 
 	return ___alloc_bootmem(size, align, goal, limit);
 }
 
 void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 				unsigned long size, unsigned long align,
-				unsigned long goal, unsigned long limit)
+				phys_addr_t goal, phys_addr_t limit)
 {
 	void *ptr;
 
@@ -731,7 +732,7 @@ again:
 }
 
 void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
-				   unsigned long align, unsigned long goal)
+				   unsigned long align, phys_addr_t goal)
 {
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
@@ -740,8 +741,8 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 }
 
 void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
-				    unsigned long align, unsigned long goal,
-				    unsigned long limit)
+				    unsigned long align, phys_addr_t goal,
+				    phys_addr_t limit)
 {
 	void *ptr;
 
@@ -770,7 +771,7 @@ void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
  * The function panics if the request can not be satisfied.
  */
 void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
-				   unsigned long align, unsigned long goal)
+				   unsigned long align, phys_addr_t goal)
 {
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
@@ -779,7 +780,7 @@ void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 }
 
 void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
-				   unsigned long align, unsigned long goal)
+				   unsigned long align, phys_addr_t goal)
 {
 #ifdef MAX_DMA32_PFN
 	unsigned long end_pfn;
@@ -825,7 +826,7 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
  * The function panics if the request can not be satisfied.
  */
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
-				  unsigned long goal)
+				  phys_addr_t goal)
 {
 	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
 }
@@ -846,7 +847,7 @@ void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
  * The function panics if the request can not be satisfied.
  */
 void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
-				       unsigned long align, unsigned long goal)
+				       unsigned long align, phys_addr_t goal)
 {
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
