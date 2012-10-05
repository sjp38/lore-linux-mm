Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 849556B009B
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 22:33:59 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1CF5D3EE0C0
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:33:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E5B1B45DE58
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:33:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C86A645DE4D
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:33:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B9D991DB8041
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:33:57 +0900 (JST)
Received: from g01jpexchkw01.g01.fujitsu.local (g01jpexchkw01.g01.fujitsu.local [10.0.194.40])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 347E81DB803F
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 11:33:57 +0900 (JST)
Message-ID: <506E46F7.4080006@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 11:33:27 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 6/10] memory-hotplug : implement register_page_bootmem_info_section
 of sparse-vmemmap
References: <506E43E0.70507@jp.fujitsu.com>
In-Reply-To: <506E43E0.70507@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

For removing memmap region of sparse-vmemmap which is allocated bootmem,
memmap region of sparse-vmemmap needs to be registered by get_page_bootmem().
So the patch searches pages of virtual mapping and registers the pages by
get_page_bootmem().

Note: register_page_bootmem_memmap() is not implemented for ia64, ppc, s390,
and sparc.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 arch/ia64/mm/discontig.c       |    6 ++++
 arch/powerpc/mm/init_64.c      |    6 ++++
 arch/s390/mm/vmem.c            |    6 ++++
 arch/sparc/mm/init_64.c        |    6 ++++
 arch/x86/mm/init_64.c          |   52 +++++++++++++++++++++++++++++++++++++++++
 include/linux/memory_hotplug.h |   11 +-------
 include/linux/mm.h             |    3 +-
 mm/memory_hotplug.c            |   37 ++++++++++++++++++++++++++---
 8 files changed, 113 insertions(+), 14 deletions(-)

Index: linux-3.6/include/linux/memory_hotplug.h
===================================================================
--- linux-3.6.orig/include/linux/memory_hotplug.h	2012-10-04 17:15:03.029828127 +0900
+++ linux-3.6/include/linux/memory_hotplug.h	2012-10-04 17:15:59.010833688 +0900
@@ -163,17 +163,10 @@ static inline void arch_refresh_nodedata
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 
-#ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
-{
-}
-static inline void put_page_bootmem(struct page *page)
-{
-}
-#else
 extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
 extern void put_page_bootmem(struct page *page);
-#endif
+extern void get_page_bootmem(unsigned long ingo, struct page *page,
+			     unsigned long type);
 
 /*
  * Lock for memory hotplug guarantees 1) all callbacks for memory hotplug
Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-04 17:15:27.213831361 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-04 17:37:00.176401540 +0900
@@ -91,9 +91,8 @@ static void release_memory_resource(stru
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
-#ifndef CONFIG_SPARSEMEM_VMEMMAP
-static void get_page_bootmem(unsigned long info,  struct page *page,
-			     unsigned long type)
+void get_page_bootmem(unsigned long info,  struct page *page,
+		      unsigned long type)
 {
 	unsigned long page_type;
 
@@ -127,6 +126,7 @@ void __ref put_page_bootmem(struct page 
 
 }
 
+#ifndef CONFIG_SPARSEMEM_VMEMMAP
 static void register_page_bootmem_info_section(unsigned long start_pfn)
 {
 	unsigned long *usemap, mapsize, section_nr, i;
@@ -160,6 +160,36 @@ static void register_page_bootmem_info_s
 		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
 
 }
+#else
+static void register_page_bootmem_info_section(unsigned long start_pfn)
+{
+	unsigned long *usemap, mapsize, section_nr, i;
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
+
+	usemap = __nr_to_section(section_nr)->pageblock_flags;
+	page = virt_to_page(usemap);
+
+	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
+
+	for (i = 0; i < mapsize; i++, page++)
+		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
+}
+#endif
 
 void register_page_bootmem_info_node(struct pglist_data *pgdat)
 {
@@ -202,7 +232,6 @@ void register_page_bootmem_info_node(str
 			register_page_bootmem_info_section(pfn);
 	}
 }
-#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 			   unsigned long end_pfn)
Index: linux-3.6/arch/ia64/mm/discontig.c
===================================================================
--- linux-3.6.orig/arch/ia64/mm/discontig.c	2012-10-01 08:47:46.000000000 +0900
+++ linux-3.6/arch/ia64/mm/discontig.c	2012-10-04 17:15:59.209833459 +0900
@@ -822,4 +822,10 @@ int __meminit vmemmap_populate(struct pa
 {
 	return vmemmap_populate_basepages(start_page, size, node);
 }
+
+void register_page_bootmem_memmap(unsigned long section_nr,
+				  struct page *start_page, unsigned long size)
+{
+	/* TODO */
+}
 #endif
Index: linux-3.6/arch/powerpc/mm/init_64.c
===================================================================
--- linux-3.6.orig/arch/powerpc/mm/init_64.c	2012-10-01 08:47:46.000000000 +0900
+++ linux-3.6/arch/powerpc/mm/init_64.c	2012-10-04 17:15:59.217833663 +0900
@@ -298,5 +298,11 @@ int __meminit vmemmap_populate(struct pa
 
 	return 0;
 }
+
+void register_page_bootmem_memmap(unsigned long section_nr,
+				  struct page *start_page, unsigned long size)
+{
+	/* TODO */
+}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
Index: linux-3.6/arch/s390/mm/vmem.c
===================================================================
--- linux-3.6.orig/arch/s390/mm/vmem.c	2012-10-01 08:47:46.000000000 +0900
+++ linux-3.6/arch/s390/mm/vmem.c	2012-10-04 17:15:59.227833764 +0900
@@ -227,6 +227,12 @@ out:
 	return ret;
 }
 
+void register_page_bootmem_memmap(unsigned long section_nr,
+				  struct page *start_page, unsigned long size)
+{
+	/* TODO */
+}
+
 /*
  * Add memory segment to the segment list if it doesn't overlap with
  * an already present segment.
Index: linux-3.6/arch/sparc/mm/init_64.c
===================================================================
--- linux-3.6.orig/arch/sparc/mm/init_64.c	2012-10-01 08:47:46.000000000 +0900
+++ linux-3.6/arch/sparc/mm/init_64.c	2012-10-04 17:15:59.232833747 +0900
@@ -2077,6 +2077,12 @@ void __meminit vmemmap_populate_print_la
 		node_start = 0;
 	}
 }
+
+void register_page_bootmem_memmap(unsigned long section_nr,
+				  struct page *start_page, unsigned long size)
+{
+	/* TODO */
+}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
 static void prot_init_common(unsigned long page_none,
Index: linux-3.6/arch/x86/mm/init_64.c
===================================================================
--- linux-3.6.orig/arch/x86/mm/init_64.c	2012-10-04 17:15:03.021828121 +0900
+++ linux-3.6/arch/x86/mm/init_64.c	2012-10-04 17:15:59.240833769 +0900
@@ -993,6 +993,58 @@ vmemmap_populate(struct page *start_page
 	return 0;
 }
 
+void register_page_bootmem_memmap(unsigned long section_nr,
+				  struct page *start_page, unsigned long size)
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
Index: linux-3.6/include/linux/mm.h
===================================================================
--- linux-3.6.orig/include/linux/mm.h	2012-10-01 08:47:46.000000000 +0900
+++ linux-3.6/include/linux/mm.h	2012-10-04 17:15:59.246833767 +0900
@@ -1618,7 +1618,8 @@ int vmemmap_populate_basepages(struct pa
 						unsigned long pages, int node);
 int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
 void vmemmap_populate_print_last(void);
-
+void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
+				  unsigned long size);
 
 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
