Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id j8TDG1OI115914
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 13:16:01 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8TDG19P152358
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:16:01 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j8TDG1bc007086
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:16:01 +0200
Received: from localhost (dyn-9-152-216-95.boeblingen.de.ibm.com [9.152.216.95])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.12.11) with ESMTP id j8TDG0b3007077
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:16:00 +0200
Date: Thu, 29 Sep 2005 15:16:11 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 3/6] Page host virtual assist: writable ptes.
Message-ID: <20050929131611.GD5700@skybase.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Page host virtual assist: writable ptes.

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>

The base patch for hva requires that the host system needs to be able
to determine if a volatile page is dirty before removing it. This
excludes almost all platforms from using hva. What is needed is a way
to distinguish between pages that are purely read-ony and pages that
might get written to. This allows platforms with per-pte dirty bits
to use hva and platforms with per-page dirty bits a small optimization.

Whenever a writable pte is created a check is added that allows to
move the page into the correct state. This needs to be done before
the writable pte is established. To avoid unnecessary state transitions
and the need for a counter, a new page flag PG_writable is added. Only
the creation of the first writable pte will do a page state change.
Even if the all writable ptes pointing to a page are removed again,
the page stays in the safe state until all users of the page have
unmapped it again. Only then the PG_writable bit is reset.

The state a page needs to have if a writable pte is present depends
on the platform. A platform with per-pte dirty bits probably wants
to move the page into stable state. A platform with per-page dirty
bits like s390 can decide to move the page into a special state that
requires the host system to check the dirty bit before discarding a
page. The page_hva_set_volatile primitive gets an additional "write"
argument which lets the platform code decide what to do.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

diffstat:
 fs/exec.c                  |    6 ++++--
 include/linux/page-flags.h |    5 +++++
 include/linux/page_hva.h   |   19 +++++++++++++++++++
 mm/fremap.c                |    4 +++-
 mm/memory.c                |    5 +++++
 mm/mprotect.c              |    1 +
 mm/page_alloc.c            |    3 ++-
 mm/page_hva.c              |   42 ++++++++++++++++++++++++++++++++++++++++--
 mm/rmap.c                  |    1 +
 9 files changed, 80 insertions(+), 6 deletions(-)

diff -urpN linux-2.5/fs/exec.c linux-2.5-cmm2/fs/exec.c
--- linux-2.5/fs/exec.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/fs/exec.c	2005-09-29 14:49:53.000000000 +0200
@@ -309,6 +309,7 @@ void install_arg_page(struct vm_area_str
 	pud_t * pud;
 	pmd_t * pmd;
 	pte_t * pte;
+	pte_t pte_val;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto out_sig;
@@ -332,8 +333,9 @@ void install_arg_page(struct vm_area_str
 	}
 	inc_mm_counter(mm, rss);
 	lru_cache_add_active(page);
-	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
-					page, vma->vm_page_prot))));
+	pte_val = pte_mkdirty(pte_mkwrite(mk_pte(page, vma->vm_page_prot)));
+	page_hva_check_write(page, pte_val);
+	set_pte_at(mm, address, pte, pte_val);
 	page_add_anon_rmap(page, vma, address);
 	pte_unmap(pte);
 	spin_unlock(&mm->page_table_lock);
diff -urpN linux-2.5/include/linux/page-flags.h linux-2.5-cmm2/include/linux/page-flags.h
--- linux-2.5/include/linux/page-flags.h	2005-09-29 14:49:52.000000000 +0200
+++ linux-2.5-cmm2/include/linux/page-flags.h	2005-09-29 14:49:53.000000000 +0200
@@ -78,6 +78,7 @@
 
 #define PG_state_change	20		/* HV page state is changing. */
 #define PG_discarded		21	/* HV page has been discarded. */
+#define PG_writable		22	/* HV page is mapped writable. */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -318,6 +319,10 @@ extern void __mod_page_state(unsigned lo
 #define TestSetPageDiscarded(page) \
 		test_and_set_bit(PG_discarded, &(page)->flags)
 
+#define PageWritable(page) test_bit(PG_writable, &(page)->flags)
+#define SetPageWritable(page) set_bit(PG_writable, &(page)->flags)
+#define ClearPageWritable(page) clear_bit(PG_writable, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
diff -urpN linux-2.5/include/linux/page_hva.h linux-2.5-cmm2/include/linux/page_hva.h
--- linux-2.5/include/linux/page_hva.h	2005-09-29 14:49:53.000000000 +0200
+++ linux-2.5-cmm2/include/linux/page_hva.h	2005-09-29 14:49:53.000000000 +0200
@@ -20,6 +20,8 @@ extern int page_hva_make_stable(struct p
 extern void page_hva_discard_page(struct page *page);
 extern void __page_hva_discard_page(struct page *page);
 extern void __page_hva_make_volatile(struct page *page, unsigned int offset);
+extern void __page_hva_check_write(struct page *page, pte_t pte);
+extern void __page_hva_reset_write(struct page *page);
 
 static inline void page_hva_make_volatile(struct page *page,
 					  unsigned int offset)
@@ -28,6 +30,20 @@ static inline void page_hva_make_volatil
 		__page_hva_make_volatile(page, offset);
 }
 
+static inline void page_hva_check_write(struct page *page, pte_t pte)
+{
+	if (!pte_write(pte) || test_bit(PG_writable, &page->flags))
+		return;
+	__page_hva_check_write(page, pte);
+}
+
+static inline void page_hva_reset_write(struct page *page)
+{
+	if (!test_bit(PG_writable, &page->flags))
+		return;
+	__page_hva_reset_write(page);
+}
+
 #else
 
 #define page_hva_enabled()			(0)
@@ -40,6 +56,9 @@ static inline void page_hva_make_volatil
 #define page_hva_make_stable(_page)		(1)
 #define page_hva_make_volatile(_page,_offset)	do { } while (0)
 
+#define page_hva_check_write(_page, _pte)	do { } while (0)
+#define page_hva_reset_write(_page)		do { } while (0)
+
 #define page_hva_discard_page(_page)		do { } while (0)
 #define __page_hva_discard_page(_page)		do { } while (0)
 
diff -urpN linux-2.5/mm/fremap.c linux-2.5-cmm2/mm/fremap.c
--- linux-2.5/mm/fremap.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/fremap.c	2005-09-29 14:49:53.000000000 +0200
@@ -94,7 +94,9 @@ int install_page(struct mm_struct *mm, s
 
 	inc_mm_counter(mm,rss);
 	flush_icache_page(vma, page);
-	set_pte_at(mm, addr, pte, mk_pte(page, prot));
+	pte_val = mk_pte(page, prot);
+	page_hva_check_write(page, pte_val);
+	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
 	pte_val = *pte;
 	pte_unmap(pte);
diff -urpN linux-2.5/mm/memory.c linux-2.5-cmm2/mm/memory.c
--- linux-2.5/mm/memory.c	2005-09-29 14:49:53.000000000 +0200
+++ linux-2.5-cmm2/mm/memory.c	2005-09-29 14:49:53.000000000 +0200
@@ -1230,6 +1230,7 @@ static inline void break_cow(struct vm_a
 
 	entry = maybe_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot)),
 			      vma);
+	page_hva_check_write(new_page, entry);
 	ptep_establish(vma, address, page_table, entry);
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
@@ -1284,6 +1285,7 @@ static int do_wp_page(struct mm_struct *
 			flush_cache_page(vma, address, pfn);
 			entry = maybe_mkwrite(pte_mkyoung(pte_mkdirty(pte)),
 					      vma);
+			page_hva_check_write(old_page, entry);
 			ptep_set_access_flags(vma, address, page_table, entry, 1);
 			update_mmu_cache(vma, address, entry);
 			lazy_mmu_prot_update(entry);
@@ -1760,6 +1762,7 @@ static int do_swap_page(struct mm_struct
 	}
 
 	flush_icache_page(vma, page);
+	page_hva_check_write(page, pte);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
 
@@ -1837,6 +1840,7 @@ do_anonymous_page(struct mm_struct *mm, 
 		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
 							 vma->vm_page_prot)),
 				      vma);
+		page_hva_check_write(page, entry);
 		lru_cache_add_active(page);
 		SetPageReferenced(page);
 		page_add_anon_rmap(page, vma, addr);
@@ -1962,6 +1966,7 @@ retry:
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_hva_check_write(new_page, entry);
 		set_pte_at(mm, address, page_table, entry);
 		/*
 		 * The COW page is not part of swap cache yet. No need
diff -urpN linux-2.5/mm/mprotect.c linux-2.5-cmm2/mm/mprotect.c
--- linux-2.5/mm/mprotect.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/mprotect.c	2005-09-29 14:49:53.000000000 +0200
@@ -40,6 +40,7 @@ static void change_pte_range(struct mm_s
 			 * into place.
 			 */
 			ptent = pte_modify(ptep_get_and_clear(mm, addr, pte), newprot);
+			page_hva_check_write(pte_page(ptent), ptent);
 			set_pte_at(mm, addr, pte, ptent);
 			lazy_mmu_prot_update(ptent);
 		}
diff -urpN linux-2.5/mm/page_alloc.c linux-2.5-cmm2/mm/page_alloc.c
--- linux-2.5/mm/page_alloc.c	2005-09-29 14:49:52.000000000 +0200
+++ linux-2.5-cmm2/mm/page_alloc.c	2005-09-29 14:49:53.000000000 +0200
@@ -463,7 +463,8 @@ static void prep_new_page(struct page *p
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
 			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_checked | 1 << PG_mappedtodisk);
+			1 << PG_checked | 1 << PG_mappedtodisk |
+			1 << PG_writable);
 	page->private = 0;
 	set_page_refs(page, order);
 	kernel_map_pages(page, 1 << order, 1);
diff -urpN linux-2.5/mm/page_hva.c linux-2.5-cmm2/mm/page_hva.c
--- linux-2.5/mm/page_hva.c	2005-09-29 14:49:53.000000000 +0200
+++ linux-2.5-cmm2/mm/page_hva.c	2005-09-29 14:49:53.000000000 +0200
@@ -78,8 +78,10 @@ void __page_hva_make_volatile(struct pag
 	 */
 	preempt_disable();
 	if (!TestSetPageStateChange(page)) {
-		if (__page_hva_discardable(page, offset))
-			page_hva_set_volatile(page);
+		if (__page_hva_discardable(page, offset)) {
+			int write = PageWritable(page);
+			page_hva_set_volatile(page, write);
+		}
 		ClearPageStateChange(page);
 	}
 	preempt_enable();
@@ -111,3 +113,39 @@ int page_hva_make_stable(struct page *pa
 	return page_hva_set_stable_if_resident(page);
 }
 EXPORT_SYMBOL(page_hva_make_stable);
+
+void __page_hva_check_write(struct page *page, pte_t pte)
+{
+	preempt_disable();
+	while (!TestSetPageStateChange(page))
+		cpu_relax();
+
+	if (!PageWritable(page)) {
+		if (__page_hva_discardable(page, 2))
+			page_hva_set_volatile(page, 1);
+		else
+			/*
+			 * If two processes create a write mapping at the
+			 * same time __page_hva_discardable will return
+			 * false but the page IS in volatile state.
+			 * We have to take care about the dirty bit so the
+			 * only option left is to make the page stable.
+			 */
+			page_hva_set_stable_if_resident(page);
+		SetPageWritable(page);
+	}
+	ClearPageStateChange(page);
+	preempt_enable();
+}
+EXPORT_SYMBOL(__page_hva_check_write);
+
+void __page_hva_reset_write(struct page *page)
+{
+	preempt_disable();
+	if (!TestSetPageStateChange(page)) {
+		ClearPageWritable(page);
+		ClearPageStateChange(page);
+	}
+	preempt_enable();
+}
+EXPORT_SYMBOL(__page_hva_reset_write);
diff -urpN linux-2.5/mm/rmap.c linux-2.5-cmm2/mm/rmap.c
--- linux-2.5/mm/rmap.c	2005-09-29 14:49:52.000000000 +0200
+++ linux-2.5-cmm2/mm/rmap.c	2005-09-29 14:49:53.000000000 +0200
@@ -690,6 +690,7 @@ void page_remove_rmap(struct page *page)
 		if (page_test_and_clear_dirty(page))
 			set_page_dirty(page);
 		dec_page_state(nr_mapped);
+		page_hva_reset_write(page);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
