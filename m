Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8FAC86B0080
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 06:00:07 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC v8 PATCH 16/20] memory-hotplug: free memmap of sparse-vmemmap
Date: Tue, 28 Aug 2012 18:00:23 +0800
Message-Id: <1346148027-24468-17-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

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

Note:  vmemmap_kfree() and vmemmap_free_bootmem() are not implemented for ia64,
ppc, s390, and sparc.

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
 arch/ia64/mm/discontig.c  |    8 +++
 arch/powerpc/mm/init_64.c |    8 +++
 arch/s390/mm/vmem.c       |    8 +++
 arch/sparc/mm/init_64.c   |    8 +++
 arch/x86/mm/init_64.c     |  119 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h        |    2 +
 mm/memory_hotplug.c       |   17 +------
 mm/sparse.c               |    5 +-
 8 files changed, 158 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 33943db..0d23b69 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -823,6 +823,14 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return vmemmap_populate_basepages(start_page, size, node);
 }
 
+void vmemmap_kfree(struct page *memmap, unsigned long nr_pages)
+{
+}
+
+void vmemmap_free_bootmem(struct page *memmap, unsigned long nr_pages)
+{
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 3690c44..835a2b3 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -299,6 +299,14 @@ int __meminit vmemmap_populate(struct page *start_page,
 	return 0;
 }
 
+void vmemmap_kfree(struct page *memmap, unsigned long nr_pages)
+{
+}
+
+void vmemmap_free_bootmem(struct page *memmap, unsigned long nr_pages)
+{
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index eda55cd..4b42b0b 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -227,6 +227,14 @@ out:
 	return ret;
 }
 
+void vmemmap_kfree(struct page *memmap, unsigned long nr_pages)
+{
+}
+
+void vmemmap_free_bootmem(struct page *memmap, unsigned long nr_pages)
+{
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index add1cc7..1384826 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2078,6 +2078,14 @@ void __meminit vmemmap_populate_print_last(void)
 	}
 }
 
+void vmemmap_kfree(struct page *memmap, unsigned long nr_pages)
+{
+}
+
+void vmemmap_free_bootmem(struct page *memmap, unsigned long nr_pages)
+{
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 0075592..4e8f8a4 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1138,6 +1138,125 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
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
+}
+
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c607913..fb0d1fc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1620,6 +1620,8 @@ int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
 void vmemmap_populate_print_last(void);
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long size);
+void vmemmap_kfree(struct page *memmpa, unsigned long nr_pages);
+void vmemmap_free_bootmem(struct page *memmpa, unsigned long nr_pages);
 
 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d8495ff..3aa0766 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -308,19 +308,6 @@ static int __meminit __add_section(int nid, struct zone *zone,
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
@@ -337,9 +324,9 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
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
index fac95f2..ab9d755 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -613,12 +613,13 @@ static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
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
