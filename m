Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA5D6B0266
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 02:54:54 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l20so9393289pgc.10
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 23:54:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m3si27483345pld.71.2017.12.28.23.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 23:54:52 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/17] mm: pass the vmem_altmap to vmemmap_free
Date: Fri, 29 Dec 2017 08:53:56 +0100
Message-Id: <20171229075406.1936-8-hch@lst.de>
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@kernel.org>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We can just pass this on instead of having to do a radix tree lookup
without proper locking a few levels into the callchain.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arm64/mm/mmu.c            |  3 +-
 arch/ia64/mm/discontig.c       |  3 +-
 arch/powerpc/mm/init_64.c      |  5 ++--
 arch/s390/mm/vmem.c            |  3 +-
 arch/sparc/mm/init_64.c        |  3 +-
 arch/x86/mm/init_64.c          | 67 ++++++++++++++++++++++++------------------
 include/linux/memory_hotplug.h |  2 +-
 include/linux/mm.h             |  3 +-
 mm/memory_hotplug.c            |  7 +++--
 mm/sparse.c                    | 23 ++++++++-------
 10 files changed, 68 insertions(+), 51 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index ec8952ff13be..0b1f13e0b4b3 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -696,7 +696,8 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 	return 0;
 }
 #endif	/* CONFIG_ARM64_64K_PAGES */
-void vmemmap_free(unsigned long start, unsigned long end)
+void vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap)
 {
 }
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 1555aecaaf85..5ea0d8d0968b 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -760,7 +760,8 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 	return vmemmap_populate_basepages(start, end, node);
 }
 
-void vmemmap_free(unsigned long start, unsigned long end)
+void vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap)
 {
 }
 #endif
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 779b74a96b8f..db7d4e092157 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -254,7 +254,8 @@ static unsigned long vmemmap_list_free(unsigned long start)
 	return vmem_back->phys;
 }
 
-void __ref vmemmap_free(unsigned long start, unsigned long end)
+void __ref vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap)
 {
 	unsigned long page_size = 1 << mmu_psize_defs[mmu_vmemmap_psize].shift;
 	unsigned long page_order = get_order(page_size);
@@ -265,7 +266,6 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 
 	for (; start < end; start += page_size) {
 		unsigned long nr_pages, addr;
-		struct vmem_altmap *altmap;
 		struct page *section_base;
 		struct page *page;
 
@@ -285,7 +285,6 @@ void __ref vmemmap_free(unsigned long start, unsigned long end)
 		section_base = pfn_to_page(vmemmap_section_start(start));
 		nr_pages = 1 << page_order;
 
-		altmap = to_vmem_altmap((unsigned long) section_base);
 		if (altmap) {
 			vmem_altmap_free(altmap, nr_pages);
 		} else if (PageReserved(page)) {
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index c44ef0e7c466..db55561c5981 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -297,7 +297,8 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 	return ret;
 }
 
-void vmemmap_free(unsigned long start, unsigned long end)
+void vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap)
 {
 }
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 42d27a1a042a..995f9490334d 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2671,7 +2671,8 @@ int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
 	return 0;
 }
 
-void vmemmap_free(unsigned long start, unsigned long end)
+void vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap)
 {
 }
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 3c046618cc7e..0cab4b5b59ba 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -800,11 +800,11 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 
 #define PAGE_INUSE 0xFD
 
-static void __meminit free_pagetable(struct page *page, int order)
+static void __meminit free_pagetable(struct page *page, int order,
+		struct vmem_altmap *altmap)
 {
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
-	struct vmem_altmap *altmap = to_vmem_altmap((unsigned long) page);
 
 	if (altmap) {
 		vmem_altmap_free(altmap, nr_pages);
@@ -826,7 +826,8 @@ static void __meminit free_pagetable(struct page *page, int order)
 		free_pages((unsigned long)page_address(page), order);
 }
 
-static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd)
+static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd,
+		struct vmem_altmap *altmap)
 {
 	pte_t *pte;
 	int i;
@@ -838,13 +839,14 @@ static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd)
 	}
 
 	/* free a pte talbe */
-	free_pagetable(pmd_page(*pmd), 0);
+	free_pagetable(pmd_page(*pmd), 0, altmap);
 	spin_lock(&init_mm.page_table_lock);
 	pmd_clear(pmd);
 	spin_unlock(&init_mm.page_table_lock);
 }
 
-static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
+static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud,
+		struct vmem_altmap *altmap)
 {
 	pmd_t *pmd;
 	int i;
@@ -856,13 +858,14 @@ static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
 	}
 
 	/* free a pmd talbe */
-	free_pagetable(pud_page(*pud), 0);
+	free_pagetable(pud_page(*pud), 0, altmap);
 	spin_lock(&init_mm.page_table_lock);
 	pud_clear(pud);
 	spin_unlock(&init_mm.page_table_lock);
 }
 
-static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
+static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d,
+		struct vmem_altmap *altmap)
 {
 	pud_t *pud;
 	int i;
@@ -874,7 +877,7 @@ static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
 	}
 
 	/* free a pud talbe */
-	free_pagetable(p4d_page(*p4d), 0);
+	free_pagetable(p4d_page(*p4d), 0, altmap);
 	spin_lock(&init_mm.page_table_lock);
 	p4d_clear(p4d);
 	spin_unlock(&init_mm.page_table_lock);
@@ -882,7 +885,7 @@ static void __meminit free_pud_table(pud_t *pud_start, p4d_t *p4d)
 
 static void __meminit
 remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
-		 bool direct)
+		 struct vmem_altmap *altmap, bool direct)
 {
 	unsigned long next, pages = 0;
 	pte_t *pte;
@@ -913,7 +916,7 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 			 * freed when offlining, or simplely not in use.
 			 */
 			if (!direct)
-				free_pagetable(pte_page(*pte), 0);
+				free_pagetable(pte_page(*pte), 0, altmap);
 
 			spin_lock(&init_mm.page_table_lock);
 			pte_clear(&init_mm, addr, pte);
@@ -936,7 +939,7 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 
 			page_addr = page_address(pte_page(*pte));
 			if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
-				free_pagetable(pte_page(*pte), 0);
+				free_pagetable(pte_page(*pte), 0, altmap);
 
 				spin_lock(&init_mm.page_table_lock);
 				pte_clear(&init_mm, addr, pte);
@@ -953,7 +956,7 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 
 static void __meminit
 remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
-		 bool direct)
+		 bool direct, struct vmem_altmap *altmap)
 {
 	unsigned long next, pages = 0;
 	pte_t *pte_base;
@@ -972,7 +975,8 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 			    IS_ALIGNED(next, PMD_SIZE)) {
 				if (!direct)
 					free_pagetable(pmd_page(*pmd),
-						       get_order(PMD_SIZE));
+						       get_order(PMD_SIZE),
+						       altmap);
 
 				spin_lock(&init_mm.page_table_lock);
 				pmd_clear(pmd);
@@ -986,7 +990,8 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 				if (!memchr_inv(page_addr, PAGE_INUSE,
 						PMD_SIZE)) {
 					free_pagetable(pmd_page(*pmd),
-						       get_order(PMD_SIZE));
+						       get_order(PMD_SIZE),
+						       altmap);
 
 					spin_lock(&init_mm.page_table_lock);
 					pmd_clear(pmd);
@@ -998,8 +1003,8 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 		}
 
 		pte_base = (pte_t *)pmd_page_vaddr(*pmd);
-		remove_pte_table(pte_base, addr, next, direct);
-		free_pte_table(pte_base, pmd);
+		remove_pte_table(pte_base, addr, next, altmap, direct);
+		free_pte_table(pte_base, pmd, altmap);
 	}
 
 	/* Call free_pmd_table() in remove_pud_table(). */
@@ -1009,7 +1014,7 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 
 static void __meminit
 remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
-		 bool direct)
+		 struct vmem_altmap *altmap, bool direct)
 {
 	unsigned long next, pages = 0;
 	pmd_t *pmd_base;
@@ -1028,7 +1033,8 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 			    IS_ALIGNED(next, PUD_SIZE)) {
 				if (!direct)
 					free_pagetable(pud_page(*pud),
-						       get_order(PUD_SIZE));
+						       get_order(PUD_SIZE),
+						       altmap);
 
 				spin_lock(&init_mm.page_table_lock);
 				pud_clear(pud);
@@ -1042,7 +1048,8 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 				if (!memchr_inv(page_addr, PAGE_INUSE,
 						PUD_SIZE)) {
 					free_pagetable(pud_page(*pud),
-						       get_order(PUD_SIZE));
+						       get_order(PUD_SIZE),
+						       altmap);
 
 					spin_lock(&init_mm.page_table_lock);
 					pud_clear(pud);
@@ -1054,8 +1061,8 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 		}
 
 		pmd_base = pmd_offset(pud, 0);
-		remove_pmd_table(pmd_base, addr, next, direct);
-		free_pmd_table(pmd_base, pud);
+		remove_pmd_table(pmd_base, addr, next, direct, altmap);
+		free_pmd_table(pmd_base, pud, altmap);
 	}
 
 	if (direct)
@@ -1064,7 +1071,7 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 
 static void __meminit
 remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
-		 bool direct)
+		 struct vmem_altmap *altmap, bool direct)
 {
 	unsigned long next, pages = 0;
 	pud_t *pud_base;
@@ -1080,14 +1087,14 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 		BUILD_BUG_ON(p4d_large(*p4d));
 
 		pud_base = pud_offset(p4d, 0);
-		remove_pud_table(pud_base, addr, next, direct);
+		remove_pud_table(pud_base, addr, next, altmap, direct);
 		/*
 		 * For 4-level page tables we do not want to free PUDs, but in the
 		 * 5-level case we should free them. This code will have to change
 		 * to adapt for boot-time switching between 4 and 5 level page tables.
 		 */
 		if (CONFIG_PGTABLE_LEVELS == 5)
-			free_pud_table(pud_base, p4d);
+			free_pud_table(pud_base, p4d, altmap);
 	}
 
 	if (direct)
@@ -1096,7 +1103,8 @@ remove_p4d_table(p4d_t *p4d_start, unsigned long addr, unsigned long end,
 
 /* start and end are both virtual address. */
 static void __meminit
-remove_pagetable(unsigned long start, unsigned long end, bool direct)
+remove_pagetable(unsigned long start, unsigned long end, bool direct,
+		struct vmem_altmap *altmap)
 {
 	unsigned long next;
 	unsigned long addr;
@@ -1111,15 +1119,16 @@ remove_pagetable(unsigned long start, unsigned long end, bool direct)
 			continue;
 
 		p4d = p4d_offset(pgd, 0);
-		remove_p4d_table(p4d, addr, next, direct);
+		remove_p4d_table(p4d, addr, next, altmap, direct);
 	}
 
 	flush_tlb_all();
 }
 
-void __ref vmemmap_free(unsigned long start, unsigned long end)
+void __ref vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap)
 {
-	remove_pagetable(start, end, false);
+	remove_pagetable(start, end, false, altmap);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
@@ -1129,7 +1138,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	start = (unsigned long)__va(start);
 	end = (unsigned long)__va(end);
 
-	remove_pagetable(start, end, true);
+	remove_pagetable(start, end, true, NULL);
 }
 
 int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index e71927d0d46b..20dd98ad44a0 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -331,7 +331,7 @@ extern void remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct pglist_data *pgdat,
 		unsigned long start_pfn, struct vmem_altmap *altmap);
 extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset);
+		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
 extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_pages,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2f3a7ebecbe2..9d4cd4c1dc6d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2561,7 +2561,8 @@ int vmemmap_populate(unsigned long start, unsigned long end, int node,
 		struct vmem_altmap *altmap);
 void vmemmap_populate_print_last(void);
 #ifdef CONFIG_MEMORY_HOTPLUG
-void vmemmap_free(unsigned long start, unsigned long end);
+void vmemmap_free(unsigned long start, unsigned long end,
+		struct vmem_altmap *altmap);
 #endif
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long nr_pages);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index eae6bf47caf7..a8dde9734120 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -536,7 +536,7 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
 }
 
 static int __remove_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset)
+		unsigned long map_offset, struct vmem_altmap *altmap)
 {
 	unsigned long start_pfn;
 	int scn_nr;
@@ -553,7 +553,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
 	__remove_zone(zone, start_pfn);
 
-	sparse_remove_one_section(zone, ms, map_offset);
+	sparse_remove_one_section(zone, ms, map_offset, altmap);
 	return 0;
 }
 
@@ -607,7 +607,8 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	for (i = 0; i < sections_to_remove; i++) {
 		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
 
-		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset);
+		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset,
+				altmap);
 		map_offset = 0;
 		if (ret)
 			break;
diff --git a/mm/sparse.c b/mm/sparse.c
index 5f4a0dac7836..06130c13dc99 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -685,12 +685,13 @@ static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
 	/* This will make the necessary allocations eventually. */
 	return sparse_mem_map_populate(pnum, nid, altmap);
 }
-static void __kfree_section_memmap(struct page *memmap)
+static void __kfree_section_memmap(struct page *memmap,
+		struct vmem_altmap *altmap)
 {
 	unsigned long start = (unsigned long)memmap;
 	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
-	vmemmap_free(start, end);
+	vmemmap_free(start, end, altmap);
 }
 #ifdef CONFIG_MEMORY_HOTREMOVE
 static void free_map_bootmem(struct page *memmap)
@@ -698,7 +699,7 @@ static void free_map_bootmem(struct page *memmap)
 	unsigned long start = (unsigned long)memmap;
 	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
-	vmemmap_free(start, end);
+	vmemmap_free(start, end, NULL);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #else
@@ -729,7 +730,8 @@ static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
 	return __kmalloc_section_memmap();
 }
 
-static void __kfree_section_memmap(struct page *memmap)
+static void __kfree_section_memmap(struct page *memmap,
+		struct vmem_altmap *altmap)
 {
 	if (is_vmalloc_addr(memmap))
 		vfree(memmap);
@@ -798,7 +800,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 		return -ENOMEM;
 	usemap = __kmalloc_section_usemap();
 	if (!usemap) {
-		__kfree_section_memmap(memmap);
+		__kfree_section_memmap(memmap, altmap);
 		return -ENOMEM;
 	}
 
@@ -820,7 +822,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
 	pgdat_resize_unlock(pgdat, &flags);
 	if (ret <= 0) {
 		kfree(usemap);
-		__kfree_section_memmap(memmap);
+		__kfree_section_memmap(memmap, altmap);
 	}
 	return ret;
 }
@@ -847,7 +849,8 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
-static void free_section_usemap(struct page *memmap, unsigned long *usemap)
+static void free_section_usemap(struct page *memmap, unsigned long *usemap,
+		struct vmem_altmap *altmap)
 {
 	struct page *usemap_page;
 
@@ -861,7 +864,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
 		kfree(usemap);
 		if (memmap)
-			__kfree_section_memmap(memmap);
+			__kfree_section_memmap(memmap, altmap);
 		return;
 	}
 
@@ -875,7 +878,7 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
 }
 
 void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
-		unsigned long map_offset)
+		unsigned long map_offset, struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;
 	unsigned long *usemap = NULL, flags;
@@ -893,7 +896,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 
 	clear_hwpoisoned_pages(memmap + map_offset,
 			PAGES_PER_SECTION - map_offset);
-	free_section_usemap(memmap, usemap);
+	free_section_usemap(memmap, usemap, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
