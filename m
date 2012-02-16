Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id BA6206B00F2
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:57 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 10/18] Support for huge page faulting
Date: Thu, 16 Feb 2012 15:31:37 +0100
Message-Id: <1329402705-25454-10-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Adds some basic vm routines and macros to operate on huge page
cache, designed to proper faulting of huge pages.

1. __do_fault - made it common for huge and small.
2. Simple wrappers for huge pages for rmapping.
3. Other changes.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/defrag-pagecache.h |   18 +--
 include/linux/fs.h               |   19 +-
 include/linux/mm.h               |   28 ++
 include/linux/mm_types.h         |    2 +-
 include/linux/rmap.h             |    9 +
 mm/huge_memory.c                 |   42 +++
 mm/memory.c                      |  528 +++++++++++++++++++++++++++++++-------
 mm/page-writeback.c              |   31 +++
 mm/rmap.c                        |   29 ++
 9 files changed, 582 insertions(+), 124 deletions(-)

diff --git a/include/linux/defrag-pagecache.h b/include/linux/defrag-pagecache.h
index 46793de..4ca3468 100644
--- a/include/linux/defrag-pagecache.h
+++ b/include/linux/defrag-pagecache.h
@@ -8,7 +8,7 @@
 
 #ifndef DEFRAG_PAGECACHE_H
 #define DEFRAG_PAGECACHE_H
-#include <linux/fs.h>
+#include <linux/defrag-pagecache.h>
 
 /* XXX Split this file into two public and protected - comments below
  * Protected will contain
@@ -24,22 +24,6 @@ typedef struct page *defrag_generic_get_page(
 	const struct defrag_pagecache_ctl *ctl, struct inode *inode,
 	pgoff_t pageIndex);
 
-/** Passes additional information and controls to page defragmentation. */
-struct defrag_pagecache_ctl {
-	/** If yes defragmentation will try to fill page caches. */
-	char fillPages:1;
-
-	/** If filling of page fails, defragmentation will fail too. Setting
-	 * this requires {@link #fillPages} will be setted.
-	 */
-	char requireFillPages:1;
-
-	/** If yes defragmentation will try to force in many aspects, this may
-	 * cause, operation to run longer, but with greater probability of
-	 * success. */
-	char force:1;
-};
-
 /** Defragments page cache of specified file and migrates it's to huge pages.
  *
  * @param f
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bfd9122..7288166 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -10,10 +10,7 @@
 #include <linux/ioctl.h>
 #include <linux/blk_types.h>
 #include <linux/types.h>
-
-#ifdef CONFIG_HUGEPAGECACHE
-#include <linux/defrag-pagecache.h>
-#endif
+#include <linux/defrag-pagecache-base.h>
 
 /*
  * It's silly to have NR_OPEN bigger than NR_FILE, but you can change
@@ -596,6 +593,9 @@ struct address_space_operations {
 	/* Set a page dirty.  Return true if this dirtied it */
 	int (*set_page_dirty)(struct page *page);
 
+	/** Same as \a set_page_dirty but for huge page */
+	int (*set_page_dirty_huge)(struct page *page);
+	
 	int (*readpages)(struct file *filp, struct address_space *mapping,
 			struct list_head *pages, unsigned nr_pages);
 
@@ -606,7 +606,6 @@ struct address_space_operations {
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 
-#ifdef CONFIG_HUGEPAGECACHE
 	/** Used to defrag (migrate) pages at position {@code pos}
 	 * to huge pages. Having this not {@code NULL} will indicate that
 	 * address space, generally, supports huge pages (transaprent
@@ -616,15 +615,19 @@ struct address_space_operations {
 	 *
 	 * @param pagep on success will be setted to established huge page
 	 *
-	 * @returns TODO What to return?
-	 *	    {@code 0} on success, value less then {@code 0} on error
+	 * @returns {@code 0} on success, value less then {@code 0} on error
 	 */
 	int (*defragpage) (struct file *, struct address_space *mapping,
 				loff_t pos,
 				struct page **pagep,
 				const struct defrag_pagecache_ctl *ctl);
-#endif
 
+	/** Used to split page, this method may be called under memory
+	 * preasure. Actaully, You should not split page.
+	 */
+	int (*split_page) (struct file *file, struct address_space *mapping,
+		loff_t pos, struct page *hueg_page);
+	
 	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
 	sector_t (*bmap)(struct address_space *, sector_t);
 	void (*invalidatepage) (struct page *, unsigned long);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 72f6a50..27a10c8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -206,10 +206,19 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
+	/** Same as \a fault but should return huge page, instead of single one.
+	 * If function fails, then caller may try again with fault.
+	 */
+	int (*fault_huge)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
+	/** Same as \a page_mkwrite, but for huge page. */
+	int (*page_mkwrite_huge)(struct vm_area_struct *vma,
+				 struct vm_fault *vmf);
+	
 	/* called by access_process_vm when get_user_pages() fails, typically
 	 * for use by special VMAs that can switch between memory and hardware
 	 */
@@ -534,6 +543,16 @@ static inline void get_page(struct page *page)
 	}
 }
 
+/** Bumps tail pages usage count. If there is at least one page that do not have
+ * valid mapping page count is left untoach.
+ */
+extern void get_page_tails_for_fmap(struct page *head);
+
+/** Decrease tail pages usage count.
+ * This function assumes you have getted compound or forozen compound.
+ */
+extern void put_page_tails_for_fmap(struct page *head);
+
 static inline void get_huge_page_tail(struct page *page)
 {
 	/*
@@ -996,6 +1015,7 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
+#define VM_FAULT_NOHUGE 0x0800  /* ->fault_huge, no huge page available .*/
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
@@ -1161,6 +1181,14 @@ int redirty_page_for_writepage(struct writeback_control *wbc,
 void account_page_dirtied(struct page *page, struct address_space *mapping);
 void account_page_writeback(struct page *page);
 int set_page_dirty(struct page *page);
+
+/** Sets huge page dirty, this will lock all tails, head should be locked.
+ * Compound should be getted or frozen. Skips all pages that have no mapping
+ *
+ * @param head
+ * @return number of sucessfull set_page_dirty
+ */
+int set_page_dirty_huge(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7649722..7d2c09d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -296,7 +296,7 @@ struct vm_area_struct {
 
 	/* Function pointers to deal with this struct. */
 	const struct vm_operations_struct *vm_ops;
-
+	
 	/* Information about our backing store: */
 	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE
 					   units, *not* PAGE_CACHE_SIZE */
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 1cdd62a..bc547cb 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -142,8 +142,17 @@ void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
 			   unsigned long, int);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
+
+/** Adds remap for huge page, compound page must be getted or frozen.
+ */
+extern void page_add_file_rmap_huge(struct page *head);
+
 void page_remove_rmap(struct page *);
 
+/** Removes rmap for huge page, compound page must be getted or frozen.
+ */
+void page_remove_rmap_huge(struct page *);
+
 void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
 			    unsigned long);
 void hugepage_add_new_anon_rmap(struct page *, struct vm_area_struct *,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e3b4c38..74d2e84 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2455,3 +2455,45 @@ void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 			split_huge_page_address(next->vm_mm, nstart);
 	}
 }
+
+/** Bumps tail pages usage count. This function assumes you have getted compound
+ * or forozen compound.
+ */
+void get_page_tails_for_fmap(struct page *head)
+{
+	struct page *page;
+
+	VM_BUG_ON(!PageHead(head));
+	VM_BUG_ON(atomic_read(&head[2]._compound_usage) == 1);
+	VM_BUG_ON(compound_order(head) < 2);
+
+	get_page(head + 1);
+	/* We may use __first_page, because we getts compound at whole. */
+	for (page = head + 2; page->__first_page == head; page++) {
+		VM_BUG_ON(!atomic_read(&page->_count));
+		VM_BUG_ON(!page->mapping);
+		VM_BUG_ON(!PageTail(page));
+		get_page(page);
+	}
+}
+
+/** Decrease tail pages usage count.
+ * This function assumes you have getted compound or forozen compound.
+ */
+void put_page_tails_for_fmap(struct page *head)
+{
+	struct page *page;
+
+	VM_BUG_ON(!PageHead(head));
+	VM_BUG_ON(atomic_read(&head[2]._compound_usage) == 1);
+	VM_BUG_ON(compound_order(head) < 2);
+
+	put_page(head + 1);
+	/* We may use __first_page, because we getts compound at whole. */
+	for (page = head + 2; page->__first_page == head; page++) {
+		VM_BUG_ON(!atomic_read(&page->_count));
+		VM_BUG_ON(!page->mapping);
+		VM_BUG_ON(!PageTail(page));
+		put_page(page);
+	}
+}
diff --git a/mm/memory.c b/mm/memory.c
index a0ab73c..7427c9b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3148,7 +3148,137 @@ oom:
 	return VM_FAULT_OOM;
 }
 
-/*
+/** Level 0 check if it's possible to establish huge pmd in process address
+ * space.
+ */
+static int check_if_hugemapping_is_possible0(
+		struct vm_area_struct *vma,
+		unsigned long address,
+		pgoff_t pgoff,
+		pmd_t pmdVal /* Keep pmd for THP for Pivate Mapping. */)
+{
+	if (vma->vm_ops) {
+		/* This is base chcek. */
+		if (!vma->vm_ops->fault_huge)
+			return 0;
+	} else {
+		return 0;
+	}
+
+	if (vma->vm_flags & VM_SHARED && !(vma->vm_flags & VM_NONLINEAR)) {
+		/* Check if VMA address is pmd aligned */
+		if ((address & ~PMD_MASK) != 0)
+			return 0;
+
+		/* Check if pgoff is huge page aligned */
+		/* XXX This should be exported as it's reused in defrag. */
+		if ((pgoff & ((1 << (PMD_SHIFT - PAGE_SHIFT)) - 1)) != 0)
+			return 0;
+
+		/* Check if huge pmd will fit inside VMA.
+		 * pmd_address_end returns first byte after end, not last byte!
+		 */
+		if (!(pmd_addr_end(address, (unsigned long) -1) <= vma->vm_end))
+			return 0;
+
+		/* WIP [Private THP], check if pmd is marked as do not make THP,
+		 * e.g. because it has COWs. (COWs gives milk).
+		 * We need add such flag because
+		 */
+
+		/* Check if file has enaugh length - not needed if there is
+		 * huge page in page cache, this implies file has enaugh lenght.
+		 * TODO Think on above. If true make requirement for THP support
+		 *      in page cache (put in documentation).
+		 * This may break some concepts that page cache may have not
+		 * up to date huge page, too.
+		 */
+	} else {
+		/* Anonymous VMA - not opcoded, yet. */
+		return 0;
+	}
+
+	/* All tests passed */
+	printk(KERN_INFO "Chk - All passed");
+	return 1;
+}
+
+
+/** Commons function for performing faulting with support for huge pages.
+ * This method is designed to be facade-ed, by others.
+ *
+ * TODO Still need to consider locking order, to prevent dead locks...
+ * it's looks like better will be compound_lock -> page_lock
+ *
+ * @param page loaded head page, locked iff compound_lock, getted
+ *
+ * @return {@code 0} on success
+ */
+static /*inline*/ int __huge_lock_check(
+					struct mm_struct *mm,
+					struct vm_area_struct *vma,
+					unsigned long address,
+					pud_t *pud,
+					pmd_t pmd,
+					pgoff_t pgoff,
+					unsigned int flags,
+					struct page *head)
+{
+	struct page *workPage;
+	unsigned long workAddress;
+	unsigned int processedPages;
+
+	int result = 0;
+
+	VM_BUG_ON(!check_if_hugemapping_is_possible0(vma, address, pgoff,
+		pmd));
+	VM_BUG_ON(atomic_read(&head->_count) <= 2);
+	VM_BUG_ON(!PageHead(head));
+
+	/* TODO [Documentation] expose below rules, from code.
+	 *
+	 * XXX Is it possible to with tests in loop to map not uptodate pages?
+	 *
+	 * It's looks like that with following designe we require that removing
+	 * page uptodate flag, for compound pages, may require compound lock
+	 * or something else.
+	 */
+
+	/* Check if tail pages are uptodate, this should not happen,
+	 * as we have compound_lock, but I can't guarantee and linear ordered.
+	 */
+	processedPages = 0;
+	workAddress = address;
+	/** XXX [Performance] compound_head is rather slow make new macro, when
+	 * we have compound page getted.
+	 */
+	for (workPage = head; compound_head(workPage) == head; workPage++) {
+		if (!PageUptodate(workPage)
+			|| !workPage->mapping
+			|| (workPage->index - processedPages != pgoff)) {
+			result = -EINVAL;
+			goto exit_processing;
+		}
+		/* We don't check ptes, because we have shared mapping
+		 * so all ptes should be (or could be in future) same, meaning
+		 * mainly protection flags. This check will be required for
+		 * private mapping.
+		 */
+		processedPages++;
+		workAddress += PAGE_SIZE;
+	}
+	if (processedPages != (1 << (PMD_SHIFT - PAGE_SHIFT))) {
+		/* Not enaugh processed pages, why? */
+		return processedPages + 1;
+	}
+
+exit_processing:
+	printk("Processed %d", processedPages);
+
+	return result;
+}
+
+/**
  * __do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
  * the FAULT_FLAG_WRITE is set in the flags parameter in order to avoid
@@ -3160,28 +3290,45 @@ oom:
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte neither mapped nor locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
+ *
+ * This method shares same concepts for single and huge pages.
+ *
+ * @param pud pud entry, if NULL method operates in single page mode, otherwise
+ *            operates in huge page mode.
  */
-static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+static inline int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pud_t *pud, pmd_t *pmd,
+		pgoff_t pgoff, unsigned int flags,
+		pmd_t orig_pmd, pte_t orig_pte)
 {
 	pte_t *page_table;
+	pmd_t *huge_table;
+
+	pte_t entry;
+	pmd_t hentry;
+
 	spinlock_t *ptl;
 	struct page *page;
 	struct page *cow_page;
-	pte_t entry;
+
 	int anon = 0;
 	struct page *dirty_page = NULL;
 	struct vm_fault vmf;
+	const struct vm_operations_struct *vm_ops = vma->vm_ops;
 	int ret;
 	int page_mkwrite = 0;
 
+	VM_BUG_ON((!!pmd) == (!!pud));
+
 	/*
 	 * If we do COW later, allocate page befor taking lock_page()
 	 * on the file cache page. This will reduce lock holding time.
 	 */
 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
-
+		if (pud) {
+			/* Privte mapping write not supported yet. */
+			BUG();
+		}
 		if (unlikely(anon_vma_prepare(vma)))
 			return VM_FAULT_OOM;
 
@@ -3196,14 +3343,20 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		cow_page = NULL;
 
-	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.virtual_address = (void __user *)
+		(address & (pud ? HPAGE_MASK : PAGE_MASK));
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
 	vmf.page = NULL;
 
-	ret = vma->vm_ops->fault(vma, &vmf);
+	/** XXX Tails should be getted to. */
+	if (pud)
+		ret = vm_ops->fault_huge(vma, &vmf);
+	else
+		ret = vm_ops->fault(vma, &vmf);
+
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
-			    VM_FAULT_RETRY)))
+			    VM_FAULT_RETRY | VM_FAULT_NOHUGE)))
 		goto uncharge_out;
 
 	if (unlikely(PageHWPoison(vmf.page))) {
@@ -3213,21 +3366,36 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto uncharge_out;
 	}
 
-	/*
-	 * For consistency in subsequent calls, make the faulted page always
-	 * locked.
+	/* For consistency in subsequent calls, make the faulted page
+	 * always locked.
 	 */
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
-		lock_page(vmf.page);
+			lock_page(vmf.page);
 	else
 		VM_BUG_ON(!PageLocked(vmf.page));
 
+	page = vmf.page;
+	if (pud) {
+		/* Check consystency of page, if it is applicable for huge
+		 * mapping.
+		 */
+		if (__huge_lock_check(mm, vma, address, pud, orig_pmd, pgoff,
+			flags, vmf.page)) {
+			unlock_page(page);
+			goto unwritable_page;
+		}
+	}
+
 	/*
 	 * Should we do an early C-O-W break?
 	 */
-	page = vmf.page;
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!(vma->vm_flags & VM_SHARED)) {
+			if (pud) {
+				/* Private cowing not supported yet for huge. */
+				BUG();
+			}
+
 			page = cow_page;
 			anon = 1;
 			copy_user_highpage(page, vmf.page, address, vma);
@@ -3238,89 +3406,156 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			 * address space wants to know that the page is about
 			 * to become writable
 			 */
-			if (vma->vm_ops->page_mkwrite) {
+			if ((!pud && vm_ops->page_mkwrite) ||
+			    (pud && vm_ops->page_mkwrite_huge)) {
 				int tmp;
-
 				unlock_page(page);
 				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
-				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
+				tmp = vm_ops->page_mkwrite(vma, &vmf);
 				if (unlikely(tmp &
 					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
 					ret = tmp;
 					goto unwritable_page;
 				}
 				if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
+					if (pud)
+						BUG();
 					lock_page(page);
 					if (!page->mapping) {
 						ret = 0; /* retry the fault */
-						unlock_page(page);
 						goto unwritable_page;
 					}
 				} else
 					VM_BUG_ON(!PageLocked(page));
-				page_mkwrite = 1;
+				page_mkwrite = 1 << (PMD_SHIFT - PAGE_SHIFT);
 			}
 		}
 
 	}
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-
-	/*
-	 * This silly early PAGE_DIRTY setting removes a race
-	 * due to the bad i386 page protection. But it's valid
-	 * for other architectures too.
-	 *
-	 * Note that if FAULT_FLAG_WRITE is set, we either now have
-	 * an exclusive copy of the page, or this is a shared mapping,
-	 * so we can make it writable and dirty to avoid having to
-	 * handle that later.
+	/* Following if is almost same for pud and not pud just, specified
+	 * methods changed. Keep it as far as possi	ble synchronized
 	 */
-	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte))) {
-		flush_icache_page(vma, page);
-		entry = mk_pte(page, vma->vm_page_prot);
-		if (flags & FAULT_FLAG_WRITE)
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		if (anon) {
-			inc_mm_counter_fast(mm, MM_ANONPAGES);
-			page_add_new_anon_rmap(page, vma, address);
-		} else {
-			inc_mm_counter_fast(mm, MM_FILEPAGES);
-			page_add_file_rmap(page);
+	if (pud) {
+		huge_table = pmd_offset(pud, address);
+		/* During allocation of pte pte_alloc uses, mm's page table lock
+		 * it is not best solution, but we reuse it here.
+		 */
+		ptl = &mm->page_table_lock;
+		spin_lock(ptl);
+		if (likely(pmd_same(*huge_table, orig_pmd))) {
+			flush_icache_page(vma, page);/* TODO Arch specific? */
+			hentry = mk_pmd(page, vma->vm_page_prot);
+			hentry = pmd_mkhuge(hentry);
+
 			if (flags & FAULT_FLAG_WRITE) {
-				dirty_page = page;
-				get_page(dirty_page);
+				hentry = pmd_mkdirty(hentry);
+				/* TODO make it pmd_maybe_mkwrite*/
+				if (likely(vma->vm_flags & VM_WRITE))
+					hentry = pmd_mkwrite(hentry);
 			}
-		}
-		set_pte_at(mm, address, page_table, entry);
+			if (anon) {
+				BUG();
+				inc_mm_counter_fast(mm, MM_ANONPAGES);
+				page_add_new_anon_rmap(page, vma, address);
+			} else {
+				/* TODO Inc of huge pages counter...*/
+				add_mm_counter_fast(mm, MM_FILEPAGES,
+					HPAGE_PMD_NR);
+				page_add_file_rmap_huge(page);
+				if (flags & FAULT_FLAG_WRITE) {
+					dirty_page = page;
+					get_page(dirty_page);
+					get_page_tails_for_fmap(dirty_page);
+				}
+			}
+			set_pmd_at(mm, address, huge_table, hentry);
 
-		/* no need to invalidate: a not-present page won't be cached */
-		update_mmu_cache(vma, address, page_table);
+			/* no need to invalidate: a not-present page won't be
+			 * cached */
+			update_mmu_cache(vma, address, page_table);
+		} else {
+			if (cow_page)
+				mem_cgroup_uncharge_page(cow_page);
+			if (anon)
+				page_cache_release(page);
+			else
+				anon = 1; /* no anon but release faulted_page */
+		}
+		spin_unlock(ptl);
 	} else {
-		if (cow_page)
-			mem_cgroup_uncharge_page(cow_page);
-		if (anon)
-			page_cache_release(page);
-		else
-			anon = 1; /* no anon but release faulted_page */
-	}
+		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		/*
+		* This silly early PAGE_DIRTY setting removes a race
+		* due to the bad i386 page protection. But it's valid
+		* for other architectures too.
+		*
+		* Note that if FAULT_FLAG_WRITE is set, we either now have
+		* an exclusive copy of the page, or this is a shared mapping,
+		* so we can make it writable and dirty to avoid having to
+		* handle that later.
+		*/
+		/* Only go through if we didn't race with anybody else... */
+		if (likely(pte_same(*page_table, orig_pte))) {
+			flush_icache_page(vma, page);
+			entry = mk_pte(page, vma->vm_page_prot);
+			if (flags & FAULT_FLAG_WRITE)
+				entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			if (anon) {
+				inc_mm_counter_fast(mm, MM_ANONPAGES);
+				page_add_new_anon_rmap(page, vma, address);
+			} else {
+				inc_mm_counter_fast(mm, MM_FILEPAGES);
+				page_add_file_rmap(page);
+				if (flags & FAULT_FLAG_WRITE) {
+					dirty_page = page;
+					get_page(dirty_page);
+				}
+			}
+			set_pte_at(mm, address, page_table, entry);
 
-	pte_unmap_unlock(page_table, ptl);
+			/* no need to invalidate: a not-present page won't be
+			 * cached */
+			update_mmu_cache(vma, address, page_table);
+		} else {
+			if (cow_page)
+				mem_cgroup_uncharge_page(cow_page);
+			if (anon)
+				page_cache_release(page);
+			else
+				anon = 1; /* no anon but release faulted_page */
+		}
+		pte_unmap_unlock(page_table, ptl);
+	}
 
 	if (dirty_page) {
 		struct address_space *mapping = page->mapping;
 
-		if (set_page_dirty(dirty_page))
-			page_mkwrite = 1;
-		unlock_page(dirty_page);
+		if (pud) {
+			int dirtied;
+			dirtied = set_page_dirty_huge(dirty_page);
+			unlock_page(dirty_page);
+			if (dirtied)
+				page_mkwrite = dirtied;
+		} else {
+			if (set_page_dirty(dirty_page))
+				page_mkwrite = 1;
+			unlock_page(dirty_page);
+		}
+
+		if (pud) {
+			put_page_tails_for_fmap(dirty_page);
+			compound_put(page);
+		}
+
 		put_page(dirty_page);
 		if (page_mkwrite && mapping) {
 			/*
 			 * Some device drivers do not set page.mapping but still
 			 * dirty their pages
 			 */
-			balance_dirty_pages_ratelimited(mapping);
+			balance_dirty_pages_ratelimited_nr(mapping,
+				page_mkwrite);
 		}
 
 		/* file_update_time outside page_lock */
@@ -3328,6 +3563,8 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			file_update_time(vma->vm_file);
 	} else {
 		unlock_page(vmf.page);
+		if (pud)
+			compound_put(page);
 		if (anon)
 			page_cache_release(vmf.page);
 	}
@@ -3335,6 +3572,10 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ret;
 
 unwritable_page:
+	if (pud) {
+		compound_put(page);
+		put_page_tails_for_fmap(page);
+	}
 	page_cache_release(page);
 	return ret;
 uncharge_out:
@@ -3346,6 +3587,33 @@ uncharge_out:
 	return ret;
 }
 
+/** Facade for {@link __do_fault} to fault "huge" pages.
+ * GCC will strip unneeded code basing on parameters passed.
+ */
+static int __do_fault_huge(struct mm_struct *mm,
+		struct vm_area_struct *vma,
+		unsigned long address, pud_t *pud,
+		pgoff_t pgoff, unsigned int flags,
+		pmd_t orig_pmd)
+{
+	pte_t pte_any;
+	return __do_fault(
+		mm, vma, address, pud, NULL, pgoff, flags, orig_pmd, pte_any);
+}
+
+/** Facade for {@link __do_fault} to fault "normal", pte level pages.
+ * GCC will strip unneeded code basing on parameters passed.
+ */
+static int __do_fault_normal(struct mm_struct *mm,
+		struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd,
+		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+{
+	pmd_t pmd_any;
+	return __do_fault(
+		mm, vma, address, NULL, pmd, pgoff, flags, pmd_any, orig_pte);
+}
+
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
@@ -3354,7 +3622,7 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 	pte_unmap(page_table);
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return __do_fault_normal(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
 /*
@@ -3386,7 +3654,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	pgoff = pte_to_pgoff(orig_pte);
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return __do_fault_normal(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
 /*
@@ -3455,6 +3723,105 @@ unlock:
 	return 0;
 }
 
+/** Handles fault on pde level.*/
+int handle_pmd_fault(struct mm_struct *mm,
+		     struct vm_area_struct *vma, unsigned long address,
+		     pud_t *pud, pmd_t *pmd, unsigned int flags)
+{
+	pte_t *pte;
+	pgoff_t pgoff;
+	pmd_t pmdVal;
+	int faultResult;
+
+	if (!vma->vm_file) {
+		/* Anonymous THP handling */
+		if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
+			if (!vma->vm_ops) {
+				return do_huge_pmd_anonymous_page(mm, vma,
+					address, pmd, flags);
+			}
+		} else {
+			pmd_t orig_pmd = *pmd;
+			barrier();
+			if (pmd_trans_huge(orig_pmd)) {
+				if (flags & FAULT_FLAG_WRITE &&
+				!pmd_write(orig_pmd) &&
+				!pmd_trans_splitting(orig_pmd))
+					return do_huge_pmd_wp_page(mm, vma,
+						address, pmd, orig_pmd);
+				return 0;
+			}
+			goto handle_pte_level;
+		}
+	}
+	/***************************
+	 * Page cache THP handling *
+	 ***************************/
+	pmdVal = *pmd;
+	if (pmd_present(pmdVal) && !pmd_trans_huge(pmdVal))
+		goto handle_pte_level;
+
+	if ((address & HPAGE_MASK) < vma->vm_start)
+		goto handle_pte_level;
+
+	/* Even if possible we currently support only for SHARED VMA.
+	 *
+	 * We support this only for shmem fs, but everyone is encorege
+	 * to add few simple methods and test it for other file systems.
+	 * Notes, warrnings etc are always welcome.
+	 */
+	if (!(vma->vm_flags & VM_SHARED))
+		goto handle_pte_level;
+
+	/* Handle fault of possible vma with huge page. */
+	pgoff = (((address & HPAGE_MASK) - vma->vm_start) >> PAGE_SHIFT)
+		+ vma->vm_pgoff;
+
+	if (!pmd_present(pmdVal)) {
+		/* No page at all. */
+		if (!check_if_hugemapping_is_possible0(vma, address, pgoff,
+			pmdVal))
+			goto handle_pte_level;
+	} else {
+		/* TODO Jump to make page writable. If not for regular
+		 *      filesystems, full fault path will be reused.
+		 */
+	}
+
+	faultResult = __do_fault_huge(mm, vma, address, pud, pgoff, flags,
+		pmdVal);
+	if (!(faultResult & (VM_FAULT_ERROR | VM_FAULT_NOHUGE))) {
+		printk(KERN_INFO "Setted huge pmd");
+		return faultResult;
+	}
+
+handle_pte_level:
+	/*
+	 * Use __pte_alloc instead of pte_alloc_map, because we can't
+	 * run pte_offset_map on the pmd, if an huge pmd could
+	 * materialize from under us from a different thread.
+	 */
+	if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))
+		return VM_FAULT_OOM;
+	/* Page cache THP uses mm->page_table_lock to check if pmd is still
+	 * none just before setting ne huge pmd, is __pte_alloc suceeded
+	 * then pmd may be huge or "normal" with ptes page.
+	 *
+	 * if an huge pmd materialized from under us just retry later */
+	if (unlikely(pmd_trans_huge(*pmd)))
+		return 0;
+
+	/*
+	 * A regular pmd is established and it can't morph into a huge pmd
+	 * from under us anymore at this point because we hold the mmap_sem
+	 * read mode and khugepaged takes it in write mode. So now it's
+	 * safe to run pte_offset_map().
+	 */
+	pte = pte_offset_map(pmd, address);
+
+	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+}
+
 /*
  * By the time we get here, we already hold the mm semaphore
  */
@@ -3464,7 +3831,6 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	pte_t *pte;
 
 	__set_current_state(TASK_RUNNING);
 
@@ -3484,42 +3850,8 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
-		if (!vma->vm_ops)
-			return do_huge_pmd_anonymous_page(mm, vma, address,
-							  pmd, flags);
-	} else {
-		pmd_t orig_pmd = *pmd;
-		barrier();
-		if (pmd_trans_huge(orig_pmd)) {
-			if (flags & FAULT_FLAG_WRITE &&
-			    !pmd_write(orig_pmd) &&
-			    !pmd_trans_splitting(orig_pmd))
-				return do_huge_pmd_wp_page(mm, vma, address,
-							   pmd, orig_pmd);
-			return 0;
-		}
-	}
 
-	/*
-	 * Use __pte_alloc instead of pte_alloc_map, because we can't
-	 * run pte_offset_map on the pmd, if an huge pmd could
-	 * materialize from under us from a different thread.
-	 */
-	if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))
-		return VM_FAULT_OOM;
-	/* if an huge pmd materialized from under us just retry later */
-	if (unlikely(pmd_trans_huge(*pmd)))
-		return 0;
-	/*
-	 * A regular pmd is established and it can't morph into a huge pmd
-	 * from under us anymore at this point because we hold the mmap_sem
-	 * read mode and khugepaged takes it in write mode. So now it's
-	 * safe to run pte_offset_map().
-	 */
-	pte = pte_offset_map(pmd, address);
-
-	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+	return handle_pmd_fault(mm, vma, address, pud, pmd, flags);
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 363ba70..ff32b5d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2072,6 +2072,37 @@ int set_page_dirty(struct page *page)
 }
 EXPORT_SYMBOL(set_page_dirty);
 
+int set_page_dirty_huge(struct page *head)
+{
+	struct page *work;
+	int result = 0;
+
+	VM_BUG_ON(!PageHead(head));
+	VM_BUG_ON(!PageLocked(head));
+	VM_BUG_ON(atomic_read(&head[2]._compound_usage) == 1);
+
+	if (head->mapping)
+		result += set_page_dirty(head);
+	else
+		BUG_ON(!PageSplitDeque(head));
+
+	for (work = head+1; compound_head(work) == head; work++) {
+		VM_BUG_ON(page_has_private(work));
+		VM_BUG_ON(page_has_buffers(work));
+
+		lock_page(work);
+		if (work->mapping) {
+			result += set_page_dirty(work);
+		} else {
+			/* Bug if there is no mapping and split is not
+			 * dequeued.
+			 */
+			BUG_ON(!PageSplitDeque(head));
+		}
+		unlock_page(work);
+	}
+	return result;
+}
 /*
  * set_page_dirty() is racy if the caller has no reference against
  * page->mapping->host, and if the page is unlocked.  This is because another
diff --git a/mm/rmap.c b/mm/rmap.c
index c8454e0..11f54e0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1157,6 +1157,21 @@ void page_add_file_rmap(struct page *page)
 	}
 }
 
+void page_add_file_rmap_huge(struct page *head)
+{
+	struct page *page;
+
+	VM_BUG_ON(!PageHead(head));
+	VM_BUG_ON(atomic_read(&head[2]._compound_usage) == 1);
+
+	page_add_file_rmap(head);
+	page_add_file_rmap(head + 1);
+	if (likely(compound_order(head) > 1)) {
+		for (page = head+2; page->__first_page == head; page++)
+			page_add_file_rmap(page);
+	}
+}
+
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
@@ -1207,6 +1222,20 @@ void page_remove_rmap(struct page *page)
 	 */
 }
 
+void page_remove_rmap_huge(struct page *head)
+{
+	struct page *page;
+
+	VM_BUG_ON(!PageHead(head));
+	VM_BUG_ON(atomic_read(&head[2]._compound_usage) == 1);
+
+	page_remove_rmap(head);
+	page_remove_rmap(head + 1);
+	if (likely(compound_order(head) > 1)) {
+		for (page = head+2; page->__first_page == head; page++)
+			page_remove_rmap(page);
+	}
+}
 /*
  * Subfunctions of try_to_unmap: try_to_unmap_one called
  * repeatedly from try_to_unmap_ksm, try_to_unmap_anon or try_to_unmap_file.
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
