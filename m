Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id BE7536B009A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:29:39 -0400 (EDT)
Message-ID: <50126EBE.1020006@cn.fujitsu.com>
Date: Fri, 27 Jul 2012 18:34:38 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v5 16/19] memory-hotplug: free memmap of sparse-vmemmap
References: <50126B83.3050201@cn.fujitsu.com>
In-Reply-To: <50126B83.3050201@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

All pages of virtual mapping in removed memory cannot be freed, since some pages
used as PGD/PUD includes not only removed memory but also other memory. So the
patch checks whether page can be freed or not.

How to check whether page can be freed or not?
 1. When removing memory, the page structs of the revmoved memory are filled
    with 0FD.
 2. All page structs are filled with 0xFD on PT/PMD, PT/PMD can be cleared.
    In this case, the page used as PT/PMD can be freed.

Applying patch, __remove_section() of CONFIG_SPARSEMEM_VMEMMAP is integrated
into one. So __remove_section() of CONFIG_SPARSEMEM_VMEMMAP is deleted.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 arch/x86/mm/init_64.c |  121 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h    |    2 +
 mm/memory_hotplug.c   |   17 +------
 mm/sparse.c           |    5 +-
 4 files changed, 128 insertions(+), 17 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a151145..ef83955 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1138,6 +1138,127 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 	return 0;
 }
 
+#define PAGE_INUSE 0xFD
+
+unsigned long find_and_clear_pte_page(unsigned long addr, unsigned long end,
+			    struct page **pp, int *page_size)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	void *page_addr;
+	unsigned long next;
+
+	*pp = NULL;
+
+	pgd = pgd_offset_k(addr);
+	if (pgd_none(*pgd))
+		return pgd_addr_end(addr, end);
+
+	pud = pud_offset(pgd, addr);
+	if (pud_none(*pud))
+		return pud_addr_end(addr, end);
+
+	if (!cpu_has_pse) {
+		next = (addr + PAGE_SIZE) & PAGE_MASK;
+		pmd = pmd_offset(pud, addr);
+		if (pmd_none(*pmd))
+			return next;
+
+		pte = pte_offset_kernel(pmd, addr);
+		if (pte_none(*pte))
+			return next;
+
+		*page_size = PAGE_SIZE;
+		*pp = pte_page(*pte);
+	} else {
+		next = pmd_addr_end(addr, end);
+
+		pmd = pmd_offset(pud, addr);
+		if (pmd_none(*pmd))
+			return next;
+
+		*page_size = PMD_SIZE;
+		*pp = pmd_page(*pmd);
+	}
+
+	/*
+	 * Removed page structs are filled with 0xFD.
+	 */
+	memset((void *)addr, PAGE_INUSE, next - addr);
+
+	page_addr = page_address(*pp);
+
+	/*
+	 * Check the page is filled with 0xFD or not.
+	 * memchr_inv() returns the address. In this case, we cannot
+	 * clear PTE/PUD entry, since the page is used by other.
+	 * So we cannot also free the page.
+	 *
+	 * memchr_inv() returns NULL. In this case, we can clear
+	 * PTE/PUD entry, since the page is not used by other.
+	 * So we can also free the page.
+	 */
+	if (memchr_inv(page_addr, PAGE_INUSE, *page_size)) {
+		*pp = NULL;
+		return next;
+	}
+
+	if (!cpu_has_pse)
+		pte_clear(&init_mm, addr, pte);
+	else
+		pmd_clear(pmd);
+
+	return next;
+}
+
+void vmemmap_kfree(struct page *memmap, unsigned long nr_pages)
+{
+	unsigned long addr = (unsigned long)memmap;
+	unsigned long end = (unsigned long)(memmap + nr_pages);
+	unsigned long next;
+	struct page *page;
+	int page_size;
+
+	for (; addr < end; addr = next) {
+		page = NULL;
+		page_size = 0;
+		next = find_and_clear_pte_page(addr, end, &page, &page_size);
+		if (!page)
+			continue;
+
+		free_pages((unsigned long)page_address(page),
+			    get_order(page_size));
+		__flush_tlb_one(addr);
+	}
+
+}
+
+void vmemmap_free_bootmem(struct page *memmap, unsigned long nr_pages)
+{
+	unsigned long addr = (unsigned long)memmap;
+	unsigned long end = (unsigned long)(memmap + nr_pages);
+	unsigned long next;
+	struct page *page;
+	int page_size;
+	unsigned long magic;
+
+	for (; addr < end; addr = next) {
+		page = NULL;
+		page_size = 0;
+		next = find_and_clear_pte_page(addr, end, &page, &page_size);
+		if (!page)
+			continue;
+
+		magic = (unsigned long) page->lru.next;
+		if (magic == SECTION_INFO)
+			put_page_bootmem(page);
+		flush_tlb_kernel_range(addr, end);
+	}
+
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 716f38b..a5f23a9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1588,6 +1588,8 @@ int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
 void vmemmap_populate_print_last(void);
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long size);
+void vmemmap_kfree(struct page *memmpa, unsigned long nr_pages);
+void vmemmap_free_bootmem(struct page *memmpa, unsigned long nr_pages);
 
 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index adcc93d..859425c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -300,19 +300,6 @@ static int __meminit __add_section(int nid, struct zone *zone,
 	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
 }
 
-#ifdef CONFIG_SPARSEMEM_VMEMMAP
-static int __remove_section(struct zone *zone, struct mem_section *ms)
-{
-	int ret = -EINVAL;
-
-	if (!valid_section(ms))
-		return ret;
-
-	ret = unregister_memory_section(ms);
-
-	return ret;
-}
-#else
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
 	unsigned long flags;
@@ -329,9 +316,9 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	pgdat_resize_lock(pgdat, &flags);
 	sparse_remove_one_section(zone, ms);
 	pgdat_resize_unlock(pgdat, &flags);
-	return 0;
+
+	return ret;
 }
-#endif
 
 /*
  * Reasonably generic function for adding memory.  It is
diff --git a/mm/sparse.c b/mm/sparse.c
index c7bb952..3b212a1 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -622,12 +622,13 @@ static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
 	/* This will make the necessary allocations eventually. */
 	return sparse_mem_map_populate(pnum, nid);
 }
-static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
+static void __kfree_section_memmap(struct page *page, unsigned long nr_pages)
 {
-	return; /* XXX: Not implemented yet */
+	vmemmap_kfree(page, nr_pages);
 }
 static void free_map_bootmem(struct page *page, unsigned long nr_pages)
 {
+	vmemmap_free_bootmem(page, nr_pages);
 }
 #else
 static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
