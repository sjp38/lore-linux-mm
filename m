Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A35F26B0027
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:03:49 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] sparse-vmemmap: specify vmemmap population range in bytes
Date: Wed, 20 Mar 2013 14:03:29 -0400
Message-Id: <1363802612-32127-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
References: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ben Hutchings <ben@decadent.org.uk>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The sparse code, when asking the architecture to populate the vmemmap,
specifies the section range as a starting page and a number of pages.

This is an awkward interface, because none of the arch-specific code
actually thinks of the range in terms of 'struct page' units and
always translates it to bytes first.

In addition, later patches mix huge page and regular page backing for
the vmemmap.  For this, they need to call vmemmap_populate_basepages()
on sub-section ranges with PAGE_SIZE and PMD_SIZE in mind.  But these
are not necessarily multiples of the 'struct page' size and so this
unit is too coarse.

Just translate the section range into bytes once in the generic sparse
code, then pass byte ranges down the stack.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/arm64/mm/mmu.c       | 13 +++++--------
 arch/ia64/mm/discontig.c  |  7 +++----
 arch/powerpc/mm/init_64.c | 11 +++--------
 arch/s390/mm/vmem.c       | 13 +++++--------
 arch/sparc/mm/init_64.c   |  7 +++----
 arch/x86/mm/init_64.c     | 15 +++++----------
 include/linux/mm.h        |  8 ++++----
 mm/sparse-vmemmap.c       | 19 ++++++++++++-------
 mm/sparse.c               | 10 ++++++++--
 9 files changed, 48 insertions(+), 55 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 224b44a..369fbe1 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -391,17 +391,14 @@ int kern_addr_valid(unsigned long addr)
 }
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 #ifdef CONFIG_ARM64_64K_PAGES
-int __meminit vmemmap_populate(struct page *start_page,
-			       unsigned long size, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	return vmemmap_populate_basepages(start_page, size, node);
+	return vmemmap_populate_basepages(start, end, node);
 }
 #else	/* !CONFIG_ARM64_64K_PAGES */
-int __meminit vmemmap_populate(struct page *start_page,
-			       unsigned long size, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	unsigned long addr = (unsigned long)start_page;
-	unsigned long end = (unsigned long)(start_page + size);
+	unsigned long addr = start;
 	unsigned long next;
 	pgd_t *pgd;
 	pud_t *pud;
@@ -434,7 +431,7 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return 0;
 }
 #endif	/* CONFIG_ARM64_64K_PAGES */
-void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+void vmemmap_free(unsigned long start, unsigned long end)
 {
 }
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index c2e955e..1627c77 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -817,13 +817,12 @@ void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-int __meminit vmemmap_populate(struct page *start_page,
-						unsigned long size, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	return vmemmap_populate_basepages(start_page, size, node);
+	return vmemmap_populate_basepages(start, end, node);
 }
 
-void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+void vmemmap_free(unsigned long start, unsigned long end)
 {
 }
 #endif
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 7e2246f..5a535b7 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -263,19 +263,14 @@ static __meminit void vmemmap_list_populate(unsigned long phys,
 	vmemmap_list = vmem_back;
 }
 
-int __meminit vmemmap_populate(struct page *start_page,
-			       unsigned long nr_pages, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	unsigned long start = (unsigned long)start_page;
-	unsigned long end = (unsigned long)(start_page + nr_pages);
 	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
 
 	/* Align to the page size of the linear mapping. */
 	start = _ALIGN_DOWN(start, page_size);
 
-	pr_debug("vmemmap_populate page %p, %ld pages, node %d\n",
-		 start_page, nr_pages, node);
-	pr_debug(" -> map %lx..%lx\n", start, end);
+	pr_debug("vmemmap_populate %lx..%lx, node %d\n", start, end, node);
 
 	for (; start < end; start += page_size) {
 		void *p;
@@ -298,7 +293,7 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return 0;
 }
 
-void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+void vmemmap_free(unsigned long start, unsigned long end)
 {
 }
 
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index ffab84d..74609e4 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -191,19 +191,16 @@ static void vmem_remove_range(unsigned long start, unsigned long size)
 /*
  * Add a backed mem_map array to the virtual mem_map array.
  */
-int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	unsigned long address, start_addr, end_addr;
+	unsigned long address = start;
 	pgd_t *pg_dir;
 	pud_t *pu_dir;
 	pmd_t *pm_dir;
 	pte_t *pt_dir;
 	int ret = -ENOMEM;
 
-	start_addr = (unsigned long) start;
-	end_addr = (unsigned long) (start + nr);
-
-	for (address = start_addr; address < end_addr;) {
+	for (address = start; address < end;) {
 		pg_dir = pgd_offset_k(address);
 		if (pgd_none(*pg_dir)) {
 			pu_dir = vmem_pud_alloc();
@@ -265,11 +262,11 @@ int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
 	memset(start, 0, nr * sizeof(struct page));
 	ret = 0;
 out:
-	flush_tlb_kernel_range(start_addr, end_addr);
+	flush_tlb_kernel_range(start, end);
 	return ret;
 }
 
-void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+void vmemmap_free(unsigned long start, unsigned long end)
 {
 }
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 1588d33..6ac99d6 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2181,10 +2181,9 @@ unsigned long vmemmap_table[VMEMMAP_SIZE];
 static long __meminitdata addr_start, addr_end;
 static int __meminitdata node_start;
 
-int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
+int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
+			       int node)
 {
-	unsigned long vstart = (unsigned long) start;
-	unsigned long vend = (unsigned long) (start + nr);
 	unsigned long phys_start = (vstart - VMEMMAP_BASE);
 	unsigned long phys_end = (vend - VMEMMAP_BASE);
 	unsigned long addr = phys_start & VMEMMAP_CHUNK_MASK;
@@ -2236,7 +2235,7 @@ void __meminit vmemmap_populate_print_last(void)
 	}
 }
 
-void vmemmap_free(struct page *memmap, unsigned long nr_pages)
+void vmemmap_free(unsigned long start, unsigned long end)
 {
 }
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 474e28f..7dd132c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1011,11 +1011,8 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 	flush_tlb_all();
 }
 
-void __ref vmemmap_free(struct page *memmap, unsigned long nr_pages)
+void __ref vmemmap_free(unsigned long start, unsigned long end)
 {
-	unsigned long start = (unsigned long)memmap;
-	unsigned long end = (unsigned long)(memmap + nr_pages);
-
 	remove_pagetable(start, end, false);
 }
 
@@ -1285,17 +1282,15 @@ static long __meminitdata addr_start, addr_end;
 static void __meminitdata *p_start, *p_end;
 static int __meminitdata node_start;
 
-int __meminit
-vmemmap_populate(struct page *start_page, unsigned long size, int node)
+int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 {
-	unsigned long addr = (unsigned long)start_page;
-	unsigned long end = (unsigned long)(start_page + size);
+	unsigned long addr;
 	unsigned long next;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 
-	for (; addr < end; addr = next) {
+	for (addr = start; addr < end; addr = next) {
 		void *p = NULL;
 
 		pgd = vmemmap_pgd_populate(addr, node);
@@ -1352,7 +1347,7 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 		}
 
 	}
-	sync_global_pgds((unsigned long)start_page, end - 1);
+	sync_global_pgds(start, end - 1);
 	return 0;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7acc9dc..2c6fc30 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1703,12 +1703,12 @@ pte_t *vmemmap_pte_populate(pmd_t *pmd, unsigned long addr, int node);
 void *vmemmap_alloc_block(unsigned long size, int node);
 void *vmemmap_alloc_block_buf(unsigned long size, int node);
 void vmemmap_verify(pte_t *, int, unsigned long, unsigned long);
-int vmemmap_populate_basepages(struct page *start_page,
-						unsigned long pages, int node);
-int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
+int vmemmap_populate_basepages(unsigned long start, unsigned long end,
+			       int node);
+int vmemmap_populate(unsigned long start, unsigned long end, int node);
 void vmemmap_populate_print_last(void);
 #ifdef CONFIG_MEMORY_HOTPLUG
-void vmemmap_free(struct page *memmap, unsigned long nr_pages);
+void vmemmap_free(unsigned long start, unsigned long end);
 #endif
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long size);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 22b7e18..27eeab3 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -147,11 +147,10 @@ pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node)
 	return pgd;
 }
 
-int __meminit vmemmap_populate_basepages(struct page *start_page,
-						unsigned long size, int node)
+int __meminit vmemmap_populate_basepages(unsigned long start,
+					 unsigned long end, int node)
 {
-	unsigned long addr = (unsigned long)start_page;
-	unsigned long end = (unsigned long)(start_page + size);
+	unsigned long addr = start;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -178,9 +177,15 @@ int __meminit vmemmap_populate_basepages(struct page *start_page,
 
 struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)
 {
-	struct page *map = pfn_to_page(pnum * PAGES_PER_SECTION);
-	int error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
-	if (error)
+	unsigned long start;
+	unsigned long end;
+	struct page *map;
+
+	map = pfn_to_page(pnum * PAGES_PER_SECTION);
+	start = (unsigned long)map;
+	end = (unsigned long)(map + PAGES_PER_SECTION);
+
+	if (vmemmap_populate(start, end, nid))
 		return NULL;
 
 	return map;
diff --git a/mm/sparse.c b/mm/sparse.c
index 7ca6dc8..a37be5f 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -615,11 +615,17 @@ static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
 }
 static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 {
-	vmemmap_free(memmap, nr_pages);
+	unsigned long start = (unsigned long)memmap;
+	unsigned long end = (unsigned long)(memmap + nr_pages);
+
+	vmemmap_free(start, end);
 }
 static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
 {
-	vmemmap_free(memmap, nr_pages);
+	unsigned long start = (unsigned long)memmap;
+	unsigned long end = (unsigned long)(memmap + nr_pages);
+
+	vmemmap_free(start, end);
 }
 #else
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
