Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 529E96B0083
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 02:03:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C28AC3EE0C2
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:03:34 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA18445DE54
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:03:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9361A45DE56
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:03:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83A931DB8048
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:03:34 +0900 (JST)
Received: from g01jpexchyt05.g01.fujitsu.local (g01jpexchyt05.g01.fujitsu.local [10.128.194.44])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 342021DB803C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:03:34 +0900 (JST)
Message-ID: <4FF28B26.9030205@jp.fujitsu.com>
Date: Tue, 3 Jul 2012 15:03:18 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v2 10/13] memory-hotplug : implement register_page_bootmem_info_section
 of sparse-vmemmap
References: <4FF287C3.4030901@jp.fujitsu.com>
In-Reply-To: <4FF287C3.4030901@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

For removing memmap region of sparse-vmemmap which is allocated bootmem,
memmap region of sparse-vmemmap needs to be registered by get_page_bootmem().
So the patch searches pages of virtual mapping and registers the pages by
get_page_bootmem().

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/x86/mm/init_64.c          |   53 +++++++++++++++++++++++++++++++++++++++++
 include/linux/memory_hotplug.h |    2 +
 include/linux/mm.h             |    3 +-
 mm/memory_hotplug.c            |   23 +++++++++++++++--
 4 files changed, 77 insertions(+), 4 deletions(-)

Index: linux-3.5-rc4/mm/memory_hotplug.c
===================================================================
--- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:14.419062959 +0900
+++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:18.522011667 +0900
@@ -91,8 +91,8 @@ static void release_memory_resource(stru
 }

 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
-static void get_page_bootmem(unsigned long info,  struct page *page,
-			     unsigned long type)
+void get_page_bootmem(unsigned long info,  struct page *page,
+		      unsigned long type)
 {
 	unsigned long page_type;

@@ -164,8 +164,25 @@ static void register_page_bootmem_info_s

 }
 #else
-static inline void register_page_bootmem_info_section(unsigned long start_pfn)
+static void register_page_bootmem_info_section(unsigned long start_pfn)
 {
+	unsigned long mapsize, section_nr;
+	struct mem_section *ms;
+	struct page *page, *memmap;
+
+	if (!pfn_valid(start_pfn))
+		return;
+
+	section_nr = pfn_to_section_nr(start_pfn);
+	ms = __nr_to_section(section_nr);
+
+	memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
+
+	page = virt_to_page(memmap);
+	mapsize = sizeof(struct page) * PAGES_PER_SECTION;
+	mapsize = PAGE_ALIGN(mapsize) >> PAGE_SHIFT;
+
+	register_page_bootmem_memmap(section_nr, memmap, PAGES_PER_SECTION);
 }
 #endif

Index: linux-3.5-rc4/include/linux/mm.h
===================================================================
--- linux-3.5-rc4.orig/include/linux/mm.h	2012-07-03 14:21:45.223427904 +0900
+++ linux-3.5-rc4/include/linux/mm.h	2012-07-03 14:22:18.530011567 +0900
@@ -1586,7 +1586,8 @@ int vmemmap_populate_basepages(struct pa
 						unsigned long pages, int node);
 int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
 void vmemmap_populate_print_last(void);
-
+void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
+				  unsigned long size);

 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,
Index: linux-3.5-rc4/arch/x86/mm/init_64.c
===================================================================
--- linux-3.5-rc4.orig/arch/x86/mm/init_64.c	2012-07-03 14:21:45.228427843 +0900
+++ linux-3.5-rc4/arch/x86/mm/init_64.c	2012-07-03 14:22:18.538011465 +0900
@@ -978,6 +978,59 @@ vmemmap_populate(struct page *start_page
 	return 0;
 }

+void __meminit
+register_page_bootmem_memmap(unsigned long section_nr, struct page *start_page,
+			     unsigned long size)
+{
+	unsigned long addr = (unsigned long)start_page;
+	unsigned long end = (unsigned long)(start_page + size);
+	unsigned long next;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	for (; addr < end; addr = next) {
+		pte_t *pte = NULL;
+
+		pgd = pgd_offset_k(addr);
+		if (pgd_none(*pgd)) {
+			next = (addr + PAGE_SIZE) & PAGE_MASK;
+			continue;
+		}
+		get_page_bootmem(section_nr, pgd_page(*pgd), MIX_SECTION_INFO);
+
+		pud = pud_offset(pgd, addr);
+		if (pud_none(*pud)) {
+			next = (addr + PAGE_SIZE) & PAGE_MASK;
+			continue;
+		}
+		get_page_bootmem(section_nr, pud_page(*pud), MIX_SECTION_INFO);
+
+		if (!cpu_has_pse) {
+			next = (addr + PAGE_SIZE) & PAGE_MASK;
+			pmd = pmd_offset(pud, addr);
+			if (pmd_none(*pmd))
+				continue;
+			get_page_bootmem(section_nr, pmd_page(*pmd),
+					 MIX_SECTION_INFO);
+
+			pte = pte_offset_kernel(pmd, addr);
+			if (pte_none(*pte))
+				continue;
+			get_page_bootmem(section_nr, pte_page(*pte),
+					 SECTION_INFO);
+		} else {
+			next = pmd_addr_end(addr, end);
+
+			pmd = pmd_offset(pud, addr);
+			if (pmd_none(*pmd))
+				continue;
+			get_page_bootmem(section_nr, pmd_page(*pmd),
+					 SECTION_INFO);
+		}
+	}
+}
+
 void __meminit vmemmap_populate_print_last(void)
 {
 	if (p_start) {
Index: linux-3.5-rc4/include/linux/memory_hotplug.h
===================================================================
--- linux-3.5-rc4.orig/include/linux/memory_hotplug.h	2012-07-03 14:22:14.409063086 +0900
+++ linux-3.5-rc4/include/linux/memory_hotplug.h	2012-07-03 14:22:18.541011428 +0900
@@ -162,6 +162,8 @@ static inline void arch_refresh_nodedata

 extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
 extern void put_page_bootmem(struct page *page);
+extern void get_page_bootmem(unsigned long ingo, struct page *page,
+			     unsigned long type);

 /*
  * Lock for memory hotplug guarantees 1) all callbacks for memory hotplug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
