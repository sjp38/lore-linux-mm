Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id B820A6B009D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 22:35:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4A95A3EE0B5
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:35:19 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B75345DE55
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:35:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 01DE045DE50
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:35:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E6337E08006
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:35:18 +0900 (JST)
Received: from g01jpexchkw11.g01.fujitsu.local (g01jpexchkw11.g01.fujitsu.local [10.0.194.50])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A16651DB803A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:35:18 +0900 (JST)
Message-ID: <506E4741.6080402@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 11:34:41 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 7/10] memory-hotplug : remove memmap of sparse-vmemmap
References: <506E43E0.70507@jp.fujitsu.com>
In-Reply-To: <506E43E0.70507@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

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
 arch/x86/mm/init_64.c     |  119 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h        |    2 
 mm/memory_hotplug.c       |   17 ------
 mm/sparse.c               |    5 +
 8 files changed, 158 insertions(+), 17 deletions(-)

Index: linux-3.6/arch/ia64/mm/discontig.c
===================================================================
--- linux-3.6.orig/arch/ia64/mm/discontig.c	2012-10-04 18:30:15.475692638 +0900
+++ linux-3.6/arch/ia64/mm/discontig.c	2012-10-04 18:30:21.145698389 +0900
@@ -823,6 +823,14 @@ int __meminit vmemmap_populate(struct pa
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
Index: linux-3.6/arch/powerpc/mm/init_64.c
===================================================================
--- linux-3.6.orig/arch/powerpc/mm/init_64.c	2012-10-04 18:30:15.494692657 +0900
+++ linux-3.6/arch/powerpc/mm/init_64.c	2012-10-04 18:30:21.150698394 +0900
@@ -299,6 +299,14 @@ int __meminit vmemmap_populate(struct pa
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
Index: linux-3.6/arch/s390/mm/vmem.c
===================================================================
--- linux-3.6.orig/arch/s390/mm/vmem.c	2012-10-04 18:30:15.506692670 +0900
+++ linux-3.6/arch/s390/mm/vmem.c	2012-10-04 18:30:21.157698401 +0900
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
Index: linux-3.6/arch/sparc/mm/init_64.c
===================================================================
--- linux-3.6.orig/arch/sparc/mm/init_64.c	2012-10-04 18:30:15.512692676 +0900
+++ linux-3.6/arch/sparc/mm/init_64.c	2012-10-04 18:30:21.163698408 +0900
@@ -2078,6 +2078,14 @@ void __meminit vmemmap_populate_print_la
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
Index: linux-3.6/arch/x86/mm/init_64.c
===================================================================
--- linux-3.6.orig/arch/x86/mm/init_64.c	2012-10-04 18:30:15.517692681 +0900
+++ linux-3.6/arch/x86/mm/init_64.c	2012-10-04 18:30:21.171698416 +0900
@@ -993,6 +993,125 @@ vmemmap_populate(struct page *start_page
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
Index: linux-3.6/include/linux/mm.h
===================================================================
--- linux-3.6.orig/include/linux/mm.h	2012-10-04 18:30:15.524692688 +0900
+++ linux-3.6/include/linux/mm.h	2012-10-04 18:30:21.177698422 +0900
@@ -1620,6 +1620,8 @@ int vmemmap_populate(struct page *start_
 void vmemmap_populate_print_last(void);
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long size);
+void vmemmap_kfree(struct page *memmpa, unsigned long nr_pages);
+void vmemmap_free_bootmem(struct page *memmpa, unsigned long nr_pages);
 
 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,
Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-04 18:30:15.464692627 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-04 18:30:21.182698427 +0900
@@ -312,19 +312,6 @@ static int __meminit __add_section(int n
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
@@ -341,9 +328,9 @@ static int __remove_section(struct zone 
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
Index: linux-3.6/mm/sparse.c
===================================================================
--- linux-3.6.orig/mm/sparse.c	2012-10-04 18:26:53.908488966 +0900
+++ linux-3.6/mm/sparse.c	2012-10-04 18:30:21.185698430 +0900
@@ -613,12 +613,13 @@ static inline struct page *kmalloc_secti
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
