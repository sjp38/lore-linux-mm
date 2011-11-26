Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 73BE56B0073
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 09:43:18 -0500 (EST)
Received: by wwg38 with SMTP id 38so6711324wwg.26
        for <linux-mm@kvack.org>; Sat, 26 Nov 2011 06:43:15 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 26 Nov 2011 22:43:15 +0800
Message-ID: <CAJd=RBB2gSCaJSsFfJXBg2zmgzNjXPAn8OakAZACNG0mv2D7nQ@mail.gmail.com>
Subject: [PATCH 3/3] MIPS: changes in VM core for adding THP
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Daney <ddaney.cavm@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, linux-mm@kvack.org

In VM core, window is opened for MIPS to use THP.

And two simple helper functions are added to easy MIPS a bit.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/Kconfig	Thu Nov 24 21:12:00 2011
+++ b/mm/Kconfig	Sat Nov 26 22:12:56 2011
@@ -307,7 +307,7 @@ config NOMMU_INITIAL_TRIM_EXCESS

 config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage Support"
-	depends on X86 && MMU
+	depends on MMU
 	select COMPACTION
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and
--- a/mm/huge_memory.c	Thu Nov 24 21:12:48 2011
+++ b/mm/huge_memory.c	Sat Nov 26 22:30:24 2011
@@ -17,6 +17,7 @@
 #include <linux/khugepaged.h>
 #include <linux/freezer.h>
 #include <linux/mman.h>
+#include <linux/pagemap.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"
@@ -135,6 +136,30 @@ static int set_recommended_min_free_kbyt
 }
 late_initcall(set_recommended_min_free_kbytes);

+/* helper function for MIPS to call pmd_page() indirectly */
+static inline struct page *__pmd_page(pmd_t pmd)
+{
+	struct page *page;
+
+#ifdef __HAVE_ARCH_THP_PMD_PAGE
+	page = thp_pmd_page(pmd);
+#else
+	page = pmd_page(pmd);
+#endif
+	return page;
+}
+
+/* helper function for MIPS to call update_mmu_cache() indirectly */
+static inline void __update_mmu_cache(struct vm_area_struct *vma,
+					unsigned long addr, pmd_t *pmdp)
+{
+#ifdef __HAVE_ARCH_UPDATE_MMU_THP
+	update_mmu_thp(vma, addr, pmdp);
+#else
+	update_mmu_cache(vma, addr, pmdp);
+#endif
+}
+
 static int start_khugepaged(void)
 {
 	int err = 0;
@@ -750,7 +775,7 @@ int copy_huge_pmd(struct mm_struct *dst_
 		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
 		goto out;
 	}
-	src_page = pmd_page(pmd);
+	src_page = __pmd_page(pmd);
 	VM_BUG_ON(!PageHead(src_page));
 	get_page(src_page);
 	page_dup_rmap(src_page);
@@ -894,7 +919,7 @@ int do_huge_pmd_wp_page(struct mm_struct
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_unlock;

-	page = pmd_page(orig_pmd);
+	page = __pmd_page(orig_pmd);
 	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
 	haddr = address & HPAGE_PMD_MASK;
 	if (page_mapcount(page) == 1) {
@@ -902,7 +927,7 @@ int do_huge_pmd_wp_page(struct mm_struct
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
-			update_mmu_cache(vma, address, entry);
+			__update_mmu_cache(vma, address, pmd);
 		ret |= VM_FAULT_WRITE;
 		goto out_unlock;
 	}
@@ -949,7 +974,7 @@ int do_huge_pmd_wp_page(struct mm_struct
 		pmdp_clear_flush_notify(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
-		update_mmu_cache(vma, address, entry);
+		__update_mmu_cache(vma, address, pmd);
 		page_remove_rmap(page);
 		put_page(page);
 		ret |= VM_FAULT_WRITE;
@@ -972,7 +997,7 @@ struct page *follow_trans_huge_pmd(struc
 	if (flags & FOLL_WRITE && !pmd_write(*pmd))
 		goto out;

-	page = pmd_page(*pmd);
+	page = __pmd_page(*pmd);
 	VM_BUG_ON(!PageHead(page));
 	if (flags & FOLL_TOUCH) {
 		pmd_t _pmd;
@@ -1011,7 +1036,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 			struct page *page;
 			pgtable_t pgtable;
 			pgtable = get_pmd_huge_pte(tlb->mm);
-			page = pmd_page(*pmd);
+			page = __pmd_page(*pmd);
 			pmd_clear(pmd);
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
@@ -1148,7 +1173,7 @@ pmd_t *page_check_address_pmd(struct pag
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd))
 		goto out;
-	if (pmd_page(*pmd) != page)
+	if (__pmd_page(*pmd) != page)
 		goto out;
 	/*
 	 * split_vma() may create temporary aliased mappings. There is
@@ -1967,7 +1992,7 @@ static void collapse_huge_page(struct mm
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address);
 	set_pmd_at(mm, address, pmd, _pmd);
-	update_mmu_cache(vma, address, _pmd);
+	__update_mmu_cache(vma, address, pmd);
 	prepare_pmd_huge_pte(pgtable, mm);
 	mm->nr_ptes--;
 	spin_unlock(&mm->page_table_lock);
@@ -2364,7 +2389,7 @@ void __split_huge_page_pmd(struct mm_str
 		spin_unlock(&mm->page_table_lock);
 		return;
 	}
-	page = pmd_page(*pmd);
+	page = __pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
