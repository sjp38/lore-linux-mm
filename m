Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OCZ9VP156572
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 12:35:09 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OCaDGv118998
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:36:13 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OCZ8XD006594
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:35:08 +0200
Date: Mon, 24 Apr 2006 14:35:13 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 5/8] Page host virtual assist: writable page table entries.
Message-ID: <20060424123513.GF15817@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

[patch 5/8] Page host virtual assist: writable page table entries.

The volatile state for page cache and swap cache pages requires that
the host system needs to be able to determine if a volatile page is
dirty before removing it. This excludes almost all platforms from using
hva. What is needed is a way to distinguish between pages that are purely
read-ony and pages that might get written to. This allows platforms with
per-pte dirty bits to use hva and platforms with per-page dirty bits a
small optimization.

Whenever a writable pte is created a check is added that allows to
move the page into the correct state. This needs to be done before
the writable pte is established. To avoid unnecessary state transitions
and the need for a counter, a new page flag PG_writable is added. Only
the creation of the first writable pte will do a page state change.
Even if all the writable ptes pointing to a page are removed again,
the page stays in the safe state until all users of the page have
unmapped it again. Only then is the PG_writable bit reset.

The state a page needs to have if a writable pte is present depends
on the platform. A platform with per-pte dirty bits wants to move the
page into stable state, a platform with per-page dirty bits like s390
can decide to move the page into a special state that requires the host
system to check the dirty bit before discarding a page.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 fs/exec.c                  |    6 +++--
 include/linux/page-flags.h |    5 ++++
 include/linux/page_hva.h   |   22 +++++++++++++++++++-
 mm/fremap.c                |    4 ++-
 mm/memory.c                |    5 ++++
 mm/mprotect.c              |    1 
 mm/page_alloc.c            |    3 +-
 mm/page_hva.c              |   49 ++++++++++++++++++++++++++++++++++++++++++++-
 mm/rmap.c                  |    1 
 9 files changed, 90 insertions(+), 6 deletions(-)

diff -urpN linux-2.6/fs/exec.c linux-2.6-patched/fs/exec.c
--- linux-2.6/fs/exec.c	2006-04-24 12:51:19.000000000 +0200
+++ linux-2.6-patched/fs/exec.c	2006-04-24 12:51:29.000000000 +0200
@@ -307,6 +307,7 @@ void install_arg_page(struct vm_area_str
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t * pte;
+	pte_t pte_val;
 	spinlock_t *ptl;
 
 	if (unlikely(anon_vma_prepare(vma)))
@@ -322,8 +323,9 @@ void install_arg_page(struct vm_area_str
 	}
 	inc_mm_counter(mm, anon_rss);
 	lru_cache_add_active(page);
-	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
-					page, vma->vm_page_prot))));
+	pte_val = pte_mkdirty(pte_mkwrite(mk_pte(page, vma->vm_page_prot)));
+	page_hva_check_write(page, pte_val);
+	set_pte_at(mm, address, pte, pte_val);
 	page_add_new_anon_rmap(page, vma, address);
 	pte_unmap_unlock(pte, ptl);
 
diff -urpN linux-2.6/include/linux/page-flags.h linux-2.6-patched/include/linux/page-flags.h
--- linux-2.6/include/linux/page-flags.h	2006-04-24 12:51:27.000000000 +0200
+++ linux-2.6-patched/include/linux/page-flags.h	2006-04-24 12:51:29.000000000 +0200
@@ -104,6 +104,7 @@
 
 #define PG_state_change		20	/* HV page state is changing. */
 #define PG_discarded		21	/* HV page has been discarded. */
+#define PG_writable		22	/* HV page is mapped writable. */
 
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -386,6 +387,10 @@ extern void __mod_page_state_offset(unsi
 #define TestSetPageDiscarded(page) \
 		test_and_set_bit(PG_discarded, &(page)->flags)
 
+#define PageWritable(page) test_bit(PG_writable, &(page)->flags)
+#define SetPageWritable(page) set_bit(PG_writable, &(page)->flags)
+#define ClearPageWritable(page) clear_bit(PG_writable, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
diff -urpN linux-2.6/include/linux/page_hva.h linux-2.6-patched/include/linux/page_hva.h
--- linux-2.6/include/linux/page_hva.h	2006-04-24 12:51:27.000000000 +0200
+++ linux-2.6-patched/include/linux/page_hva.h	2006-04-24 12:51:29.000000000 +0200
@@ -21,6 +21,8 @@ extern void page_hva_discard_page(struct
 
 extern int  __page_hva_make_stable(struct page *page);
 extern void __page_hva_make_volatile(struct page *page, unsigned int offset);
+extern void __page_hva_check_write(struct page *page, pte_t pte);
+extern void __page_hva_reset_write(struct page *page);
 
 static inline int page_hva_make_stable(struct page *page)
 {
@@ -38,18 +40,36 @@ static inline void page_hva_make_volatil
 		__page_hva_make_volatile(page, offset);
 }
 
+static inline void page_hva_check_write(struct page *page, pte_t pte)
+{
+	if (!page_hva_enabled() || !pte_write(pte) ||
+	    test_bit(PG_writable, &page->flags))
+		return;
+	__page_hva_check_write(page, pte);
+}
+
+static inline void page_hva_reset_write(struct page *page)
+{
+	if (!page_hva_enabled() || !test_bit(PG_writable, &page->flags))
+		return;
+	__page_hva_reset_write(page);
+}
+
 #else
 
 #define page_hva_enabled()			(0)
 
 #define page_hva_set_unused(_page)		do { } while (0)
 #define page_hva_set_stable(_page)		do { } while (0)
-#define page_hva_set_volatile(_page)		do { } while (0)
+#define page_hva_set_volatile(_page,_writable)	do { } while (0)
 #define page_hva_cond_set_stable(_page)		(1)
 
 #define page_hva_make_stable(_page)		(1)
 #define page_hva_make_volatile(_page,_offset)	do { } while (0)
 
+#define page_hva_check_write(_page, _pte)	do { } while (0)
+#define page_hva_reset_write(_page)		do { } while (0)
+
 #define page_hva_discard_page(_page)		do { } while (0)
 
 #endif
diff -urpN linux-2.6/mm/fremap.c linux-2.6-patched/mm/fremap.c
--- linux-2.6/mm/fremap.c	2006-03-20 06:53:29.000000000 +0100
+++ linux-2.6-patched/mm/fremap.c	2006-04-24 12:51:29.000000000 +0200
@@ -79,7 +79,9 @@ int install_page(struct mm_struct *mm, s
 		inc_mm_counter(mm, file_rss);
 
 	flush_icache_page(vma, page);
-	set_pte_at(mm, addr, pte, mk_pte(page, prot));
+	pte_val = mk_pte(page, prot);
+	page_hva_check_write(page, pte_val);
+	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
 	pte_val = *pte;
 	update_mmu_cache(vma, addr, pte_val);
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2006-04-24 12:51:29.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2006-04-24 12:51:29.000000000 +0200
@@ -1475,6 +1475,7 @@ static int do_wp_page(struct mm_struct *
 			flush_cache_page(vma, address, pte_pfn(orig_pte));
 			entry = pte_mkyoung(orig_pte);
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			page_hva_check_write(old_page, entry);
 			ptep_set_access_flags(vma, address, page_table, entry, 1);
 			update_mmu_cache(vma, address, entry);
 			lazy_mmu_prot_update(entry);
@@ -1525,6 +1526,7 @@ gotten:
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_hva_check_write(new_page, entry);
 		ptep_establish(vma, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lazy_mmu_prot_update(entry);
@@ -1958,6 +1960,7 @@ static int do_swap_page(struct mm_struct
 	}
 
 	flush_icache_page(vma, page);
+	page_hva_check_write(page, pte);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
 
@@ -2020,6 +2023,7 @@ static int do_anonymous_page(struct mm_s
 
 		entry = mk_pte(page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_hva_check_write(page, entry);
 
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
@@ -2157,6 +2161,7 @@ retry:
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		page_hva_check_write(new_page, entry);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
diff -urpN linux-2.6/mm/mprotect.c linux-2.6-patched/mm/mprotect.c
--- linux-2.6/mm/mprotect.c	2006-04-24 12:51:13.000000000 +0200
+++ linux-2.6-patched/mm/mprotect.c	2006-04-24 12:51:29.000000000 +0200
@@ -41,6 +41,7 @@ static void change_pte_range(struct mm_s
 			 * into place.
 			 */
 			ptent = pte_modify(ptep_get_and_clear(mm, addr, pte), newprot);
+			page_hva_check_write(pte_page(ptent), ptent);
 			set_pte_at(mm, addr, pte, ptent);
 			lazy_mmu_prot_update(ptent);
 		}
diff -urpN linux-2.6/mm/page_alloc.c linux-2.6-patched/mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c	2006-04-24 12:51:26.000000000 +0200
+++ linux-2.6-patched/mm/page_alloc.c	2006-04-24 12:51:29.000000000 +0200
@@ -564,7 +564,8 @@ static int prep_new_page(struct page *pa
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
 			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_checked | 1 << PG_mappedtodisk);
+			1 << PG_checked | 1 << PG_mappedtodisk |
+			1 << PG_writable );
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 	kernel_map_pages(page, 1 << order, 1);
diff -urpN linux-2.6/mm/page_hva.c linux-2.6-patched/mm/page_hva.c
--- linux-2.6/mm/page_hva.c	2006-04-24 12:51:29.000000000 +0200
+++ linux-2.6-patched/mm/page_hva.c	2006-04-24 12:51:29.000000000 +0200
@@ -79,7 +79,7 @@ void __page_hva_make_volatile(struct pag
 	preempt_disable();
 	if (!TestSetPageStateChange(page)) {
 		if (__page_hva_discardable(page, offset))
-			page_hva_set_volatile(page);
+			page_hva_set_volatile(page, PageWritable(page));
 		ClearPageStateChange(page);
 	}
 	preempt_enable();
@@ -115,6 +115,53 @@ int __page_hva_make_stable(struct page *
 EXPORT_SYMBOL(__page_hva_make_stable);
 
 /**
+ * __page_hva_check_write() - check page state for new writable pte
+ *
+ * @page: the page the new writable pte refers to
+ * @pte: the new writable pte
+ */
+void __page_hva_check_write(struct page *page, pte_t pte)
+{
+	preempt_disable();
+	while (TestSetPageStateChange(page))
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
+			page_hva_cond_set_stable(page);
+		SetPageWritable(page);
+	}
+	ClearPageStateChange(page);
+	preempt_enable();
+}
+EXPORT_SYMBOL(__page_hva_check_write);
+
+/**
+ * __page_hva_reset_write() - clear the PageWritable bit
+ *
+ * @page: the page
+ */
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
+
+/**
  * __page_hva_discard_page() - remove a discarded page from the cache
  *
  * @page: the page
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2006-04-24 12:51:29.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2006-04-24 12:51:29.000000000 +0200
@@ -534,6 +534,7 @@ void page_remove_rmap(struct page *page)
 		if (page_test_and_clear_dirty(page))
 			set_page_dirty(page);
 		__dec_page_state(nr_mapped);
+		page_hva_reset_write(page);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
