Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0118D0047
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 04:44:51 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p2P8iQrl016781
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:26 -0700
Received: from iwn2 (iwn2.prod.google.com [10.241.68.66])
	by wpaz1.hot.corp.google.com with ESMTP id p2P8iOwT012353
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:25 -0700
Received: by iwn2 with SMTP id 2so954312iwn.12
        for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:24 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 4/5] kstaled: skip non-RAM regions.
Date: Fri, 25 Mar 2011 01:43:54 -0700
Message-Id: <1301042635-11180-5-git-send-email-walken@google.com>
In-Reply-To: <1301042635-11180-1-git-send-email-walken@google.com>
References: <1301042635-11180-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/include/asm/page_types.h |    8 ++++++
 arch/x86/kernel/e820.c            |   45 +++++++++++++++++++++++++++++++++++++
 include/linux/mmzone.h            |    6 +++++
 mm/memcontrol.c                   |   21 +++++++++++-----
 4 files changed, 73 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index 1df6621..7ae791f 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -52,6 +52,14 @@ extern void initmem_init(unsigned long start_pfn, unsigned long end_pfn,
 				int acpi, int k8);
 extern void free_initmem(void);
 
+extern void e820_skip_hole(unsigned long *start_pfn, unsigned long *end_pfn);
+
+#define ARCH_HAVE_PFN_SKIP_HOLE 1
+static inline void pfn_skip_hole(unsigned long *start, unsigned long *end)
+{
+	e820_skip_hole(start, end);
+}
+
 #endif	/* !__ASSEMBLY__ */
 
 #endif	/* _ASM_X86_PAGE_DEFS_H */
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 294f26d..b816706 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1122,3 +1122,48 @@ void __init memblock_find_dma_reserve(void)
 	set_dma_reserve(mem_size_pfn - free_size_pfn);
 #endif
 }
+
+/*
+ * The caller wants to skip pfns that are guaranteed to not be valid
+ * memory. Find a stretch of ram between [start_pfn, end_pfn) and
+ * return its pfn range back through start_pfn and end_pfn.
+ */
+
+void e820_skip_hole(unsigned long *start_pfn, unsigned long *end_pfn)
+{
+	unsigned long start = *start_pfn << PAGE_SHIFT;
+	unsigned long end = *end_pfn << PAGE_SHIFT;
+	int i;
+
+	if (start >= end)
+		goto fail;		/* short-circuit e820 checks */
+
+	for (i = 0; i < e820.nr_map; i++) {
+		struct e820entry *ei = &e820.map[i];
+		unsigned long last, addr;
+
+		addr = round_up(ei->addr, PAGE_SIZE);
+		last = round_down(ei->addr + ei->size, PAGE_SIZE);
+
+		if (addr >= end)
+			goto fail;	/* We're done, not found */
+		if (last <= start)
+			continue;	/* Not at start yet, move on */
+		if (ei->type != E820_RAM)
+			continue;	/* Not RAM, move on */
+
+		/*
+		 * We've found RAM. If start is in this e820 range, return
+		 * it, otherwise return the start of this e820 range.
+		 */
+
+		if (addr > start)
+			*start_pfn = addr >> PAGE_SHIFT;
+		if (last < end)
+			*end_pfn = last >> PAGE_SHIFT;
+		return;
+	}
+fail:
+	*start_pfn = *end_pfn;
+	return;				/* No luck, return failure */
+}
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 02ecb01..955fd02 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -931,6 +931,12 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
 #define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
 
+#ifndef ARCH_HAVE_PFN_SKIP_HOLE
+static inline void pfn_skip_hole(unsigned long *start, unsigned long *end)
+{
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM
 
 /*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 042e266..5bdaa23 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5238,18 +5238,25 @@ static inline void kstaled_scan_page(struct page *page)
 static void kstaled_scan_node(pg_data_t *pgdat)
 {
 	unsigned long flags;
-	unsigned long start, end, pfn;
+	unsigned long pfn, end;
 
 	pgdat_resize_lock(pgdat, &flags);
 
-	start = pgdat->node_start_pfn;
-	end = start + pgdat->node_spanned_pages;
+	pfn = pgdat->node_start_pfn;
+	end = pfn + pgdat->node_spanned_pages;
 
-	for (pfn = start; pfn < end; pfn++) {
-		if (!pfn_valid(pfn))
-			continue;
+	while (pfn < end) {
+		unsigned long contiguous = end;
+
+		/* restrict pfn..contiguous to be a RAM backed range */
+		pfn_skip_hole(&pfn, &contiguous);
 
-		kstaled_scan_page(pfn_to_page(pfn));
+		for (; pfn < contiguous; pfn++) {
+			if (!pfn_valid(pfn))
+				continue;
+
+			kstaled_scan_page(pfn_to_page(pfn));
+		}
 	}
 
 	pgdat_resize_unlock(pgdat, &flags);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
