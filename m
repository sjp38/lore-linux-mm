Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id EC2096B0072
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 04:58:14 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 07/12] memory-hotplug: implement register_page_bootmem_info_section of sparse-vmemmap
Date: Tue, 27 Nov 2012 18:00:17 +0800
Message-Id: <1354010422-19648-8-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com>
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

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
 arch/ia64/mm/discontig.c       |  6 +++++
 arch/powerpc/mm/init_64.c      |  6 +++++
 arch/s390/mm/vmem.c            |  6 +++++
 arch/sparc/mm/init_64.c        |  6 +++++
 arch/x86/mm/init_64.c          | 52 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/memory_hotplug.h | 11 ++-------
 include/linux/mm.h             |  3 ++-
 mm/memory_hotplug.c            | 33 +++++++++++++++++++++++----
 8 files changed, 109 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index c641333..33943db 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -822,4 +822,10 @@ int __meminit vmemmap_populate(struct page *start_page,
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
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 95a4529..6466440 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -297,5 +297,11 @@ int __meminit vmemmap_populate(struct page *start_page,
 
 	return 0;
 }
+
+void register_page_bootmem_memmap(unsigned long section_nr,
+				  struct page *start_page, unsigned long size)
+{
+	/* TODO */
+}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 387c7c6..4f4803a 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -236,6 +236,12 @@ out:
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
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 9e28a11..75a984b 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2231,6 +2231,12 @@ void __meminit vmemmap_populate_print_last(void)
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
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 5675335..795dae3 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -998,6 +998,58 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
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
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 191b2d9..d4c4402 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -163,17 +163,10 @@ static inline void arch_refresh_nodedata(int nid, pg_data_t *pgdat)
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcaab4e..5657670 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1640,7 +1640,8 @@ int vmemmap_populate_basepages(struct page *start_page,
 						unsigned long pages, int node);
 int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
 void vmemmap_populate_print_last(void);
-
+void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
+				  unsigned long size);
 
 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 171610d..ccc11b6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -91,9 +91,8 @@ static void release_memory_resource(struct resource *res)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
-#ifndef CONFIG_SPARSEMEM_VMEMMAP
-static void get_page_bootmem(unsigned long info,  struct page *page,
-			     unsigned long type)
+void get_page_bootmem(unsigned long info,  struct page *page,
+		      unsigned long type)
 {
 	page->lru.next = (struct list_head *) type;
 	SetPagePrivate(page);
@@ -120,6 +119,7 @@ void __ref put_page_bootmem(struct page *page)
 
 }
 
+#ifndef CONFIG_SPARSEMEM_VMEMMAP
 static void register_page_bootmem_info_section(unsigned long start_pfn)
 {
 	unsigned long *usemap, mapsize, section_nr, i;
@@ -153,6 +153,32 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
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
@@ -195,7 +221,6 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 			register_page_bootmem_info_section(pfn);
 	}
 }
-#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
 static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 			   unsigned long end_pfn)
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
