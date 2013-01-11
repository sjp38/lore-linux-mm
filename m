Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2F6DA6B0072
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 04:57:01 -0500 (EST)
Date: Fri, 11 Jan 2013 10:56:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: mmots: memory-hotplug: implement register_page_bootmem_info_section
 of sparse-vmemmap fix
Message-ID: <20130111095658.GC7286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wu Jianguo <wujianguo@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Defconfig for x86_64 complains
arch/x86/mm/init_64.c: In function a??register_page_bootmem_memmapa??:
arch/x86/mm/init_64.c:1340: error: implicit declaration of function a??get_page_bootmema??
arch/x86/mm/init_64.c:1340: error: a??MIX_SECTION_INFOa?? undeclared (first
use in this function)
arch/x86/mm/init_64.c:1340: error: (Each undeclared identifier is
reported only once
arch/x86/mm/init_64.c:1340: error: for each function it appears in.)
arch/x86/mm/init_64.c:1361: error: a??SECTION_INFOa?? undeclared (first use in this function)

move register_page_bootmem_memmap to memory_hotplug where it is used and
where it has all required symbols

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 arch/x86/mm/init_64.c |   58 -----------------------------------------------
 include/linux/mm.h    |    2 --
 mm/memory_hotplug.c   |   60 ++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 59 insertions(+), 61 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index ddd3b58..a6a7494 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1317,64 +1317,6 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 	return 0;
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	unsigned long addr = (unsigned long)start_page;
-	unsigned long end = (unsigned long)(start_page + size);
-	unsigned long next;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	unsigned int nr_pages;
-	struct page *page;
-
-	for (; addr < end; addr = next) {
-		pte_t *pte = NULL;
-
-		pgd = pgd_offset_k(addr);
-		if (pgd_none(*pgd)) {
-			next = (addr + PAGE_SIZE) & PAGE_MASK;
-			continue;
-		}
-		get_page_bootmem(section_nr, pgd_page(*pgd), MIX_SECTION_INFO);
-
-		pud = pud_offset(pgd, addr);
-		if (pud_none(*pud)) {
-			next = (addr + PAGE_SIZE) & PAGE_MASK;
-			continue;
-		}
-		get_page_bootmem(section_nr, pud_page(*pud), MIX_SECTION_INFO);
-
-		if (!cpu_has_pse) {
-			next = (addr + PAGE_SIZE) & PAGE_MASK;
-			pmd = pmd_offset(pud, addr);
-			if (pmd_none(*pmd))
-				continue;
-			get_page_bootmem(section_nr, pmd_page(*pmd),
-					 MIX_SECTION_INFO);
-
-			pte = pte_offset_kernel(pmd, addr);
-			if (pte_none(*pte))
-				continue;
-			get_page_bootmem(section_nr, pte_page(*pte),
-					 SECTION_INFO);
-		} else {
-			next = pmd_addr_end(addr, end);
-
-			pmd = pmd_offset(pud, addr);
-			if (pmd_none(*pmd))
-				continue;
-
-			nr_pages = 1 << (get_order(PMD_SIZE));
-			page = pmd_page(*pmd);
-			while (nr_pages--)
-				get_page_bootmem(section_nr, page++,
-						 SECTION_INFO);
-		}
-	}
-}
-
 void __meminit vmemmap_populate_print_last(void)
 {
 	if (p_start) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7c57bd0..1fea1b23 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1724,8 +1724,6 @@ void vmemmap_populate_print_last(void);
 #ifdef CONFIG_MEMORY_HOTPLUG
 void vmemmap_free(struct page *memmap, unsigned long nr_pages);
 #endif
-void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
-				  unsigned long size);
 
 enum mf_flags {
 	MF_COUNT_INCREASED = 1 << 0,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index be2b90c..1501d25 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -91,7 +91,6 @@ static void release_memory_resource(struct resource *res)
 	return;
 }
 
-#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
 void get_page_bootmem(unsigned long info,  struct page *page,
 		      unsigned long type)
 {
@@ -101,6 +100,7 @@ void get_page_bootmem(unsigned long info,  struct page *page,
 	atomic_inc(&page->_count);
 }
 
+#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
 /* reference to __meminit __free_pages_bootmem is valid
  * so use __ref to tell modpost not to generate a warning */
 void __ref put_page_bootmem(struct page *page)
@@ -128,6 +128,64 @@ void __ref put_page_bootmem(struct page *page)
 
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
+	unsigned int nr_pages;
+	struct page *page;
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
+
+			nr_pages = 1 << (get_order(PMD_SIZE));
+			page = pmd_page(*pmd);
+			while (nr_pages--)
+				get_page_bootmem(section_nr, page++,
+						 SECTION_INFO);
+		}
+	}
+}
+
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
 static void register_page_bootmem_info_section(unsigned long start_pfn)
 {
-- 
1.7.10.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
