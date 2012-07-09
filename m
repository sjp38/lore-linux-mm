Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 0C33D6B0087
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 06:33:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A422B3EE0B6
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:33:55 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E13C45DE58
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:33:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 73F9245DE56
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:33:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6846C1DB804D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:33:55 +0900 (JST)
Received: from g01jpexchyt09.g01.fujitsu.local (g01jpexchyt09.g01.fujitsu.local [10.128.194.48])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 160ED1DB8043
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:33:55 +0900 (JST)
Message-ID: <4FFAB37F.1060105@jp.fujitsu.com>
Date: Mon, 9 Jul 2012 19:33:35 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v3 11/13] memory-hotplug : free memmap of sparse-vmemmap
References: <4FFAB0A2.8070304@jp.fujitsu.com>
In-Reply-To: <4FFAB0A2.8070304@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

I don't think that all pages of virtual mapping in removed memory can be
freed, since page which type is MIX_SECTION_INFO is difficult to free.
So, the patch only frees page which type is SECTION_INFO at first.

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
 arch/x86/mm/init_64.c |   91 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h    |    2 +
 mm/memory_hotplug.c   |    5 ++
 mm/sparse.c           |    5 +-
 4 files changed, 101 insertions(+), 2 deletions(-)

Index: linux-3.5-rc4/include/linux/mm.h
===================================================================
--- linux-3.5-rc4.orig/include/linux/mm.h	2012-07-03 14:22:18.530011567 +0900
+++ linux-3.5-rc4/include/linux/mm.h	2012-07-03 14:22:20.999983872 +0900
@@ -1588,6 +1588,8 @@ int vmemmap_populate(struct page *start_
 void vmemmap_populate_print_last(void);
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long size);
+void vmemmap_kfree(struct page *memmpa, unsigned long nr_pages);
+void vmemmap_free_bootmem(struct page *memmpa, unsigned long nr_pages);

 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,
Index: linux-3.5-rc4/mm/sparse.c
===================================================================
--- linux-3.5-rc4.orig/mm/sparse.c	2012-07-03 14:21:45.071429805 +0900
+++ linux-3.5-rc4/mm/sparse.c	2012-07-03 14:22:21.000983767 +0900
@@ -614,12 +614,13 @@ static inline struct page *kmalloc_secti
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
Index: linux-3.5-rc4/arch/x86/mm/init_64.c
===================================================================
--- linux-3.5-rc4.orig/arch/x86/mm/init_64.c	2012-07-03 14:22:18.538011465 +0900
+++ linux-3.5-rc4/arch/x86/mm/init_64.c	2012-07-03 14:22:21.007983103 +0900
@@ -978,6 +978,97 @@ vmemmap_populate(struct page *start_page
 	return 0;
 }

+unsigned long find_and_clear_pte_page(unsigned long addr, unsigned long end,
+				      struct page **pp)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	unsigned long next;
+
+	*pp = NULL;
+
+	pgd = pgd_offset_k(addr);
+	if (pgd_none(*pgd))
+		return (addr + PAGE_SIZE) & PAGE_MASK;
+
+	pud = pud_offset(pgd, addr);
+	if (pud_none(*pud))
+		return (addr + PAGE_SIZE) & PAGE_MASK;
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
+		*pp = pte_page(*pte);
+		pte_clear(&init_mm, addr, pte);
+	} else {
+		next = pmd_addr_end(addr, end);
+
+		pmd = pmd_offset(pud, addr);
+		if (pmd_none(*pmd))
+			return next;
+
+		*pp = pmd_page(*pmd);
+		pmd_clear(pmd);
+	}
+
+	return next;
+}
+
+void __meminit
+vmemmap_kfree(struct page *memmap, unsigned long nr_pages)
+{
+	unsigned long addr = (unsigned long)memmap;
+	unsigned long end = (unsigned long)(memmap + nr_pages);
+	unsigned long next;
+	unsigned int order;
+	struct page *page;
+
+	for (; addr < end; addr = next) {
+		page = NULL;
+		next = find_and_clear_pte_page(addr, end, &page);
+		if (!page)
+			continue;
+
+		if (is_vmalloc_addr(page_address(page)))
+			vfree(page_address(page));
+		else {
+			order = next - addr;
+			free_pages((unsigned long)page_address(page),
+				   get_order(order));
+		}
+	}
+}
+
+void __meminit
+vmemmap_free_bootmem(struct page *memmap, unsigned long nr_pages)
+{
+	unsigned long addr = (unsigned long)memmap;
+	unsigned long end = (unsigned long)(memmap + nr_pages);
+	unsigned long next;
+	struct page *page;
+	unsigned long magic;
+
+	for (; addr < end; addr = next) {
+		page = NULL;
+		next = find_and_clear_pte_page(addr, end, &page);
+		if (!page)
+			continue;
+
+		magic = (unsigned long) page->lru.next;
+		if (magic == SECTION_INFO)
+			put_page_bootmem(page);
+	}
+}
+
 void __meminit
 register_page_bootmem_memmap(unsigned long section_nr, struct page *start_page,
 			     unsigned long size)
Index: linux-3.5-rc4/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:18.522011667 +0900
+++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:21.012982694 +0900
@@ -303,6 +303,8 @@ static int __meminit __add_section(int n
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
+	unsigned long flags;
+	struct pglist_data *pgdat = zone->zone_pgdat;
 	int ret;

 	if (!valid_section(ms))
@@ -310,6 +312,9 @@ static int __remove_section(struct zone

 	ret = unregister_memory_section(ms);

+	pgdat_resize_lock(pgdat, &flags);
+	sparse_remove_one_section(zone, ms);
+	pgdat_resize_unlock(pgdat, &flags);
 	return ret;
 }
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
