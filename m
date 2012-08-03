Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 9E0BF6B0087
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 04:00:19 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [RFC PATCH V6 15/19] memory-hotplug: implement register_page_bootmem_info_section of sparse-vmemmap
Date: Fri, 3 Aug 2012 15:49:17 +0800
Message-Id: <1343980161-14254-16-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1343980161-14254-1-git-send-email-wency@cn.fujitsu.com>
References: <1343980161-14254-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

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
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 arch/ia64/mm/discontig.c       |    6 ++++
 arch/powerpc/mm/init_64.c      |    6 ++++
 arch/s390/mm/vmem.c            |    6 ++++
 arch/sparc/mm/init_64.c        |    6 ++++
 arch/x86/mm/init_64.c          |   52 ++++++++++++++++++++++++++++++++++++++++
 include/linux/memory_hotplug.h |    2 +
 include/linux/mm.h             |    3 +-
 mm/memory_hotplug.c            |   23 +++++++++++++++--
 8 files changed, 100 insertions(+), 4 deletions(-)

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
index 620b7ac..3690c44 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -298,5 +298,11 @@ int __meminit vmemmap_populate(struct page *start_page,
 
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
index 6f896e7..eda55cd 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
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
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 6026fdd..53f7604 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2059,6 +2059,12 @@ int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
 	}
 	return 0;
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
index e0d88ba..0075592 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1138,6 +1138,58 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
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
index 1133e63..2d18235 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -164,6 +164,8 @@ static inline void arch_refresh_nodedata(int nid, pg_data_t *pgdat)
 
 extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
 extern void put_page_bootmem(struct page *page);
+extern void get_page_bootmem(unsigned long ingo, struct page *page,
+			     unsigned long type);
 
 /*
  * Lock for memory hotplug guarantees 1) all callbacks for memory hotplug
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 311be90..c607913 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1618,7 +1618,8 @@ int vmemmap_populate_basepages(struct page *start_page,
 						unsigned long pages, int node);
 int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
 void vmemmap_populate_print_last(void);
-
+void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
+				  unsigned long size);
 
 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3a264a5..4589f5b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -91,8 +91,8 @@ static void release_memory_resource(struct resource *res)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
-static void get_page_bootmem(unsigned long info,  struct page *page,
-			     unsigned long type)
+void get_page_bootmem(unsigned long info,  struct page *page,
+		      unsigned long type)
 {
 	unsigned long page_type;
 
@@ -164,8 +164,25 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 
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
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
