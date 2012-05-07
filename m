Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 878346B00F4
	for <linux-mm@kvack.org>; Mon,  7 May 2012 07:38:18 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 10/10] mm: remove sparsemem allocation details from the bootmem allocator
Date: Mon,  7 May 2012 13:37:52 +0200
Message-Id: <1336390672-14421-11-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

alloc_bootmem_section() derives allocation area constraints from the
specified sparsemem section.  This is a bit specific for a generic
memory allocator like bootmem, though, so move it over to sparsemem.

As __alloc_bootmem_node_nopanic() already retries failed allocations
with relaxed area constraints, the fallback code in sparsemem.c can be
removed and the code becomes a bit more compact overall.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/bootmem.h |    3 ---
 mm/bootmem.c            |   22 ----------------------
 mm/nobootmem.c          |   22 ----------------------
 mm/sparse.c             |   25 ++++++++++++-------------
 4 files changed, 12 insertions(+), 60 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 66d3e95..04e30dc 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -135,9 +135,6 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 extern int reserve_bootmem_generic(unsigned long addr, unsigned long size,
 				   int flags);
 
-extern void *alloc_bootmem_section(unsigned long size,
-				   unsigned long section_nr);
-
 #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
 extern void *alloc_remap(int nid, unsigned long size);
 #else
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 9d0f266..d1c7a79 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -803,28 +803,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 
 }
 
-#ifdef CONFIG_SPARSEMEM
-/**
- * alloc_bootmem_section - allocate boot memory from a specific section
- * @size: size of the request in bytes
- * @section_nr: sparse map section to allocate from
- *
- * Return NULL on failure.
- */
-void * __init alloc_bootmem_section(unsigned long size,
-				    unsigned long section_nr)
-{
-	bootmem_data_t *bdata;
-	unsigned long pfn, goal;
-
-	pfn = section_nr_to_pfn(section_nr);
-	goal = pfn << PAGE_SHIFT;
-	bdata = &bootmem_node_data[early_pfn_to_nid(pfn)];
-
-	return alloc_bootmem_bdata(bdata, size, SMP_CACHE_BYTES, goal, 0);
-}
-#endif
-
 #ifndef ARCH_LOW_ADDRESS_LIMIT
 #define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
 #endif
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 77069bb..58e8205 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -356,28 +356,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 	return __alloc_bootmem_node(pgdat, size, align, goal);
 }
 
-#ifdef CONFIG_SPARSEMEM
-/**
- * alloc_bootmem_section - allocate boot memory from a specific section
- * @size: size of the request in bytes
- * @section_nr: sparse map section to allocate from
- *
- * Return NULL on failure.
- */
-void * __init alloc_bootmem_section(unsigned long size,
-				    unsigned long section_nr)
-{
-	unsigned long pfn, goal, limit;
-
-	pfn = section_nr_to_pfn(section_nr);
-	goal = pfn << PAGE_SHIFT;
-	limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
-
-	return __alloc_memory_core_early(early_pfn_to_nid(pfn), size,
-					 SMP_CACHE_BYTES, goal, limit);
-}
-#endif
-
 #ifndef ARCH_LOW_ADDRESS_LIMIT
 #define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
 #endif
diff --git a/mm/sparse.c b/mm/sparse.c
index a8bc7d3..2612b59 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -273,10 +273,10 @@ static unsigned long *__kmalloc_section_usemap(void)
 #ifdef CONFIG_MEMORY_HOTREMOVE
 static unsigned long * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
-					 unsigned long count)
+					 unsigned long size)
 {
-	unsigned long section_nr;
-
+	pg_data_t *host_pgdat;
+	unsigned long goal;
 	/*
 	 * A page may contain usemaps for other sections preventing the
 	 * page being freed and making a section unremovable while
@@ -287,8 +287,10 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	 * from the same section as the pgdat where possible to avoid
 	 * this problem.
 	 */
-	section_nr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
-	return alloc_bootmem_section(usemap_size() * count, section_nr);
+	goal = __pa(pgdat) & PAGE_SECTION_MASK;
+	host_pgdat = NODE_DATA(early_pfn_to_nid(goal));
+	return __alloc_bootmem_node_nopanic(host_pgdat, size,
+					    SMP_CACHE_BYTES, goal);
 }
 
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
@@ -332,9 +334,9 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 #else
 static unsigned long * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
-					 unsigned long count)
+					 unsigned long size)
 {
-	return NULL;
+	return alloc_bootmem_node_nopanic(pgdat, size)
 }
 
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
@@ -352,13 +354,10 @@ static void __init sparse_early_usemaps_alloc_node(unsigned long**usemap_map,
 	int size = usemap_size();
 
 	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
-								 usemap_count);
+							  size * usemap_count);
 	if (!usemap) {
-		usemap = alloc_bootmem_node(NODE_DATA(nodeid), size * usemap_count);
-		if (!usemap) {
-			printk(KERN_WARNING "%s: allocation failed\n", __func__);
-			return;
-		}
+		printk(KERN_WARNING "%s: allocation failed\n", __func__);
+		return;
 	}
 
 	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
