Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OCYUCO113840
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 12:34:30 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OCZZGv106732
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:35:35 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OCYUQu005535
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:34:30 +0200
Date: Mon, 24 Apr 2006 14:34:34 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 2/8] Page host virtual assist: volatile page cache.
Message-ID: <20060424123434.GC15817@skybase>
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

[patch 2/8] Page host virtual assist: volatile page cache.

A new page state "volatile" is introduced that is used for clean,
uptodate page cache pages. The host can choose to discard volatile
pages as part of its vmscan operation instead of writing them to the
hosts paging device. This greatly reduces the i/o needed by the host
if it gets under memory pressure. The guest system doesn't notice
that a volatile page is gone until it tries to access the page or
tries to make it stable again. Then the guest needs to remove the
page from the cache. A guest access to a discarded page causes the
host to deliver a new kind of fault to the guest - the discard fault.
After the guest has removed the page it is reloaded from the backing
device.

The code added by this patch uses the volatile state for all page cache
pages, even for pages which are referenced by writable ptes. The host
needs to be able to check the dirty state of the pages. Since the host
doesn't know where the page table entries of the guest are located,
the volatile state as introduced by this patch is only usable on
architectures with per-page dirty bits (s390 only). For per-pte dirty
bit architectures some additional code is needed.

The interesting question is where to put the state transitions between
the volatile and the stable state. The simple solution is the make a
page stable whenever a lookup is done or a page reference is derived
from a page table entry. Attempts to make pages volatile are added at
strategic points. Now what are the conditions that prevent a page from
being made volatile? There are 10 conditions:
1) The page is reserved. Some sort of special page.
2) The page is marked dirty in the struct page. The page content is
   more recent than the data on the backing device. The host cannot
   access the linux internal dirty bit so the page needs to be stable.
3) The page is in writeback. The page content is needed for i/o.
4) The page is locked. Someone has exclusive access to the page.
5) The page is anonymous. Swap cache support needs additional code.
6) The page has no mapping. No backing, the page cannot be recreated.
7) The page is not uptodate.
8) The page has private information. try_to_release_page can fail,
   e.g. in case the private information is journaling data. The discard
   fault need to be able to remove the page.
9) The page is already discarded.
10) The page map count is not equal to the page reference count - 1.
   The discard fault handler can remove the page cache reference and
   all mappers of a page. It cannot remove the page reference for any
   other user of the page.

The transitions to stable are done by find_get_pages() and its variants,
in get_user_pages if called with a pages parameter, by copy-on-write in
do_wp_page, and by the early copy-on-write in do_no_page. To make enough
pages discardable by the host an attempt to do the transition to volatile
state is done when a page gets unlocked (unlock_page), when writeback has
finished (test_clear_page_dirty), when the page reference counter is
decreased (put_page_testzero), and when the page map counter is increased
(page_add_file_rmap).

All page references acquired with find_get_page and friends can be used
to access the page frame content. A page reference grabbed from a page
table cannot be used to access the page content. A page_hva_make_stable
needs to be done first and if that fails the page needs to get discarded.
That removes the page table entry as well.

Two new page flags are added. To guard against concurrent page state
updates the PG_state_change flag is used. It prevents that a transition
to the stable state can "overtake" a transition to volatile state.
If page_hva_make_volatile has already done the 1e checks it will issue
the state change primitive. If in the meantime on of the conditions has
changed the user that requires the page in stable state will have to wait
until the make volatile operation has finished. The make volatile
operation does not wait for the PG_state_change if make stable has set
the bit. Instead the attempt to make the page volatile fails. The reason
is that test_clear_page_dirty is called from interrupt context and waiting
for the bit might dead-lock.

The second new page flag is the PG_discarded bit. This bit is set after
a discarded page has been recognized. It is used to call the unmap
function only for the first caller of the discard handler and it is
used to do the late removal of page cache pages that have been isolated
in vmscan. After an isolated page has been re-added to the lru list
PG_discarded is tested and if it is set the discard handler is called.

Another noticable change is that the first few lines of code in
try_to_unmap_one that calculates the address from the page and the vma
is moved out of try_to_unmap_one to the callers. This is done to make
try_to_unmap_one usable for the removal of discarded pages in
page_hva_unmap_all.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/mm.h         |   11 ++
 include/linux/page-flags.h |   14 +++
 include/linux/page_hva.h   |   29 +++++++
 mm/Makefile                |    1 
 mm/filemap.c               |   49 +++++++++++-
 mm/memory.c                |   45 ++++++++++-
 mm/page-writeback.c        |    1 
 mm/page_hva.c              |  174 +++++++++++++++++++++++++++++++++++++++++++++
 mm/rmap.c                  |   68 +++++++++++++++--
 mm/vmscan.c                |   18 +++-
 10 files changed, 391 insertions(+), 19 deletions(-)

diff -urpN linux-2.6/include/linux/mm.h linux-2.6-patched/include/linux/mm.h
--- linux-2.6/include/linux/mm.h	2006-04-24 12:51:26.000000000 +0200
+++ linux-2.6-patched/include/linux/mm.h	2006-04-24 12:51:26.000000000 +0200
@@ -302,12 +302,19 @@ struct page {
 
 /*
  * Drop a ref, return true if the logical refcount fell to zero (the page has
- * no users)
+ * no users).
+ *
+ * put_page_testzero checks if the page can be made volatile if the page
+ * still has users and the page host virtual assist is enabled.
  */
 static inline int put_page_testzero(struct page *page)
 {
+	int ret;
 	VM_BUG_ON(atomic_read(&page->_count) == 0);
-	return atomic_dec_and_test(&page->_count);
+	ret = atomic_dec_and_test(&page->_count);
+	if (!ret)
+		page_hva_make_volatile(page, 1);
+	return ret;
 }
 
 /*
diff -urpN linux-2.6/include/linux/page-flags.h linux-2.6-patched/include/linux/page-flags.h
--- linux-2.6/include/linux/page-flags.h	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/include/linux/page-flags.h	2006-04-24 12:51:26.000000000 +0200
@@ -102,6 +102,9 @@
 #define PG_uncached		31	/* Page has been mapped as uncached */
 #endif
 
+#define PG_state_change		20	/* HV page state is changing. */
+#define PG_discarded		21	/* HV page has been discarded. */
+
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
  * allowed.
@@ -372,6 +375,17 @@ extern void __mod_page_state_offset(unsi
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageStateChange(page) test_bit(PG_state_change, &(page)->flags)
+#define ClearPageStateChange(page) clear_bit(PG_state_change, &(page)->flags)
+#define TestSetPageStateChange(page) \
+		test_and_set_bit(PG_state_change, &(page)->flags)
+
+#define PageDiscarded(page)	test_bit(PG_discarded, &(page)->flags)
+#define SetPageDiscarded(page)	set_bit(PG_discarded, &(page)->flags)
+#define ClearPageDiscarded(page) clear_bit(PG_discarded, &(page)->flags)
+#define TestSetPageDiscarded(page) \
+		test_and_set_bit(PG_discarded, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
diff -urpN linux-2.6/include/linux/page_hva.h linux-2.6-patched/include/linux/page_hva.h
--- linux-2.6/include/linux/page_hva.h	2006-04-24 12:51:26.000000000 +0200
+++ linux-2.6-patched/include/linux/page_hva.h	2006-04-24 12:51:26.000000000 +0200
@@ -16,12 +16,41 @@
 
 #include <asm/page_hva.h>
 
+extern void page_hva_unmap_all(struct page *page);
+extern void page_hva_discard_page(struct page *page);
+
+extern int  __page_hva_make_stable(struct page *page);
+extern void __page_hva_make_volatile(struct page *page, unsigned int offset);
+
+static inline int page_hva_make_stable(struct page *page)
+{
+	if (!page_hva_enabled())
+		return 1;
+	return __page_hva_make_stable(page);
+}
+
+static inline void page_hva_make_volatile(struct page *page,
+					  unsigned int offset)
+{
+	if (!page_hva_enabled())
+		return;
+	if (likely(!test_bit(PG_discarded, &page->flags)))
+		__page_hva_make_volatile(page, offset);
+}
+
 #else
 
 #define page_hva_enabled()			(0)
 
 #define page_hva_set_unused(_page)		do { } while (0)
 #define page_hva_set_stable(_page)		do { } while (0)
+#define page_hva_set_volatile(_page)		do { } while (0)
+#define page_hva_cond_set_stable(_page)		(1)
+
+#define page_hva_make_stable(_page)		(1)
+#define page_hva_make_volatile(_page,_offset)	do { } while (0)
+
+#define page_hva_discard_page(_page)		do { } while (0)
 
 #endif
 
diff -urpN linux-2.6/mm/filemap.c linux-2.6-patched/mm/filemap.c
--- linux-2.6/mm/filemap.c	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/mm/filemap.c	2006-04-24 12:51:26.000000000 +0200
@@ -512,6 +512,7 @@ void fastcall unlock_page(struct page *p
 	if (!TestClearPageLocked(page))
 		BUG();
 	smp_mb__after_clear_bit(); 
+	page_hva_make_volatile(page, 1);
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
@@ -560,6 +561,14 @@ struct page * find_get_page(struct addre
 	if (page)
 		page_cache_get(page);
 	read_unlock_irq(&mapping->tree_lock);
+	if (page && unlikely(!page_hva_make_stable(page))) {
+		/*
+		 * The page has been discarded by the host. Run the
+		 * discard handler and return NULL.
+		 */
+		page_hva_discard_page(page);
+		page = NULL;
+	}
 	return page;
 }
 
@@ -603,7 +612,15 @@ repeat:
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page) {
 		page_cache_get(page);
-		if (TestSetPageLocked(page)) {
+		if (unlikely(!page_hva_make_stable(page))) {
+			/*
+			 * The page has been discarded by the host. Run the
+			 * discard handler and return NULL.
+			 */
+			read_unlock_irq(&mapping->tree_lock);
+			page_hva_discard_page(page);
+			return NULL;
+		} else if (TestSetPageLocked(page)) {
 			read_unlock_irq(&mapping->tree_lock);
 			__lock_page(page);
 			read_lock_irq(&mapping->tree_lock);
@@ -691,11 +708,24 @@ unsigned find_get_pages(struct address_s
 	unsigned int i;
 	unsigned int ret;
 
+repeat:
 	read_lock_irq(&mapping->tree_lock);
 	ret = radix_tree_gang_lookup(&mapping->page_tree,
 				(void **)pages, start, nr_pages);
-	for (i = 0; i < ret; i++)
+	for (i = 0; i < ret; i++) {
 		page_cache_get(pages[i]);
+		if (likely(page_hva_make_stable(pages[i])))
+			continue;
+		/*
+		 * Make stable failed, we discard the page and retry the
+		 * whole operation.
+		 */
+		read_unlock_irq(&mapping->tree_lock);
+		page_hva_discard_page(pages[i]);
+		while (i--)
+			page_cache_release(pages[i]);
+		goto repeat;
+	}
 	read_unlock_irq(&mapping->tree_lock);
 	return ret;
 }
@@ -711,11 +741,24 @@ unsigned find_get_pages_tag(struct addre
 	unsigned int i;
 	unsigned int ret;
 
+repeat:
 	read_lock_irq(&mapping->tree_lock);
 	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
 				(void **)pages, *index, nr_pages, tag);
-	for (i = 0; i < ret; i++)
+	for (i = 0; i < ret; i++) {
 		page_cache_get(pages[i]);
+		if (likely(page_hva_make_stable(pages[i])))
+			continue;
+		/*
+		 * Make stable failed, we discard the page and retry the
+		 * whole operation.
+		 */
+		read_unlock_irq(&mapping->tree_lock);
+		page_hva_discard_page(pages[i]);
+		while (i--)
+			page_cache_release(pages[i]);
+		goto repeat;
+	}
 	if (ret)
 		*index = pages[ret - 1]->index + 1;
 	read_unlock_irq(&mapping->tree_lock);
diff -urpN linux-2.6/mm/Makefile linux-2.6-patched/mm/Makefile
--- linux-2.6/mm/Makefile	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/mm/Makefile	2006-04-24 12:51:26.000000000 +0200
@@ -25,3 +25,4 @@ obj-$(CONFIG_MEMORY_HOTPLUG) += memory_h
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 
+obj-$(CONFIG_PAGE_HVA) 	+= page_hva.o
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2006-04-24 12:51:26.000000000 +0200
@@ -1040,6 +1040,7 @@ int get_user_pages(struct task_struct *t
 			if (write)
 				foll_flags |= FOLL_WRITE;
 
+retry:
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
@@ -1069,6 +1070,22 @@ int get_user_pages(struct task_struct *t
 					BUG();
 				}
 			}
+			if (foll_flags & FOLL_GET) {
+				/*
+				 * The pages are only made stable in case
+				 * an additional reference is acquired. This
+				 * includes the case of a non-null pages array.
+				 * If no additional reference is taken it
+				 * implies that the caller can deal with page
+				 * faults in case the page is swapped out.
+				 * In this case the caller can deal with
+				 * discard faults as well.
+				 */
+				if (unlikely(!page_hva_make_stable(page))) {
+					page_hva_discard_page(page);
+					goto retry;
+				}
+			}
 			if (pages) {
 				pages[i] = page;
 
@@ -1470,6 +1487,12 @@ static int do_wp_page(struct mm_struct *
 	 * Ok, we need to copy. Oh, well..
 	 */
 	page_cache_get(old_page);
+	/*
+	 * To copy the content of old_page it needs to be stable.
+	 * page_cache_release on old_page will make it volatile again.
+	 */
+	if (unlikely(!page_hva_make_stable(old_page)))
+		goto discard;
 gotten:
 	pte_unmap_unlock(page_table, ptl);
 
@@ -1523,6 +1546,10 @@ oom:
 	if (old_page)
 		page_cache_release(old_page);
 	return VM_FAULT_OOM;
+discard:
+	pte_unmap_unlock(page_table, ptl);
+	page_hva_discard_page(old_page);
+	return VM_FAULT_MAJOR;
 }
 
 /*
@@ -2078,6 +2105,10 @@ retry:
 
 		if (unlikely(anon_vma_prepare(vma)))
 			goto oom;
+		if (unlikely(!page_hva_make_stable(new_page))) {
+			page_hva_discard_page(new_page);
+			goto retry;
+		}
 		page = alloc_page_vma(GFP_HIGHUSER, vma, address);
 		if (!page)
 			goto oom;
@@ -2203,6 +2234,7 @@ static inline int handle_pte_fault(struc
 	pte_t old_entry;
 	spinlock_t *ptl;
 
+again:
 	old_entry = entry = *pte;
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
@@ -2224,9 +2256,16 @@ static inline int handle_pte_fault(struc
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (write_access) {
-		if (!pte_write(entry))
-			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, entry);
+		if (!pte_write(entry)) {
+			int rc = do_wp_page(mm, vma, address,
+					    pte, pmd, ptl, entry);
+			if (page_hva_enabled() &&
+			    unlikely(rc == VM_FAULT_MAJOR)) {
+				pte = pte_alloc_map(mm, pmd, address);
+				goto again;
+			}
+			return rc;
+		}
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
diff -urpN linux-2.6/mm/page_hva.c linux-2.6-patched/mm/page_hva.c
--- linux-2.6/mm/page_hva.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6-patched/mm/page_hva.c	2006-04-24 12:51:26.000000000 +0200
@@ -0,0 +1,174 @@
+/*
+ * mm/page_hva.c
+ *
+ * (C) Copyright IBM Corp. 2005, 2006
+ *
+ * Host virtual assist functions.
+ *
+ * Authors: Martin Schwidefsky <schwidefsky@de.ibm.com>
+ *          Hubertus Franke <frankeh@watson.ibm.com>
+ *          Himanshu Raj <rhim@cc.gatech.edu>
+ */
+
+#include <linux/mm.h>
+#include <linux/mm_inline.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <linux/buffer_head.h>
+
+#include "internal.h"
+
+/*
+ * Check the state of a page if there is something that prevents
+ * the page from changing its state to volatile.
+ */
+static inline int __page_hva_discardable(struct page *page,unsigned int offset)
+{
+	/*
+	 * There are several conditions that prevent a page from becoming
+	 * volatile. The first check is for the page bits.
+	 */
+	if (PageDirty(page) || PageReserved(page) || PageWriteback(page) ||
+	    PageLocked(page) || PagePrivate(page) || PageDiscarded(page) ||
+	    !PageUptodate(page) || PageAnon(page))
+		return 0;
+
+	/*
+	 * If the page has been truncated there is no point in making
+	 * it volatile. It will be freed soon. If the mapping ever had
+	 * locked pages all pages of the mapping will stay stable.
+	 */
+	if (!page_mapping(page))
+		return 0;
+
+	/*
+	 * The last check is the critical one. We check the reference
+	 * counter of the page against the number of mappings. The caller
+	 * of make_volatile passes an offset, that is the number of extra
+	 * references. For most calls that is 1 extra reference for the
+	 * page-cache. In some cases the caller itself holds an additional
+	 * reference, then the offset is 2. If the page map counter is equal
+	 * to the page count minus the offset then there is no other
+	 * (unknown) user of the page in the system and we can make the
+	 * page volatile.
+	 */
+	if (page_mapcount(page) != page_count(page) - offset)
+		return 0;
+
+	return 1;
+}
+
+/*
+ * Attempts to change the state of a page to volatile. If there is
+ * something preventing the state change the page stays in its current
+ * state.
+ */
+void __page_hva_make_volatile(struct page *page, unsigned int offset)
+{
+	/*
+	 * If we can't get the PG_state_change bit just give up. The
+	 * worst that can happen is that the page will stay in stable
+	 * state although it might be volatile.
+	 */
+	preempt_disable();
+	if (!TestSetPageStateChange(page)) {
+		if (__page_hva_discardable(page, offset))
+			page_hva_set_volatile(page);
+		ClearPageStateChange(page);
+	}
+	preempt_enable();
+}
+EXPORT_SYMBOL(__page_hva_make_volatile);
+
+/*
+ * Attempts to change the state of a page to stable. The host could
+ * have removed a volatile page, the page_hva_cond_set_stable call
+ * can fail.
+ *
+ * returns "0" on success and "1" on failure
+ */
+int __page_hva_make_stable(struct page *page)
+{
+	/*
+	 * Postpone state change to stable until PG_state_change bit is
+	 * cleared. As long as PG_state_change is set another cpu is in
+	 * page_hva_make_volatile for this page. That makes sure
+	 * that no caller of make_stable "overtakes" a make_volatile
+	 * leaving the page in volatile where stable is required.
+	 * The caller of make_stable need to make sure that no caller
+	 * of make_volatile can make the page volatile right after
+	 * make_stable has finished. That is done by requiring that
+	 * page has been locked or that the page_count has been
+	 * increased before make_stable is called. In both cases a
+	 * subsequent call page_hva_make_volatile will fail.
+	 */
+	while (PageStateChange(page))
+		cpu_relax();
+	return page_hva_cond_set_stable(page);
+}
+EXPORT_SYMBOL(__page_hva_make_stable);
+
+/**
+ * __page_hva_discard_page() - remove a discarded page from the cache
+ *
+ * @page: the page
+ *
+ * The page passed to this function needs to be locked.
+ */
+static void __page_hva_discard_page(struct page *page)
+{
+	struct zone *zone;
+	int discarded;
+
+	/* Paranoia checks. */
+	BUG_ON(PageWriteback(page));
+	BUG_ON(PageDirty(page));
+	BUG_ON(PagePrivate(page));
+
+	/* Set the discarded bit. */
+	if (!TestSetPageDiscarded(page))
+		/* The first discard fault unmaps the page. */
+		page_hva_unmap_all(page);
+
+	/*
+	 * Try to remove the page from LRU. If the page has been
+	 * isolated we have to postpone the discard until the page
+	 * is back on the LRU. Alternativly the page can be freed.
+	 */
+	zone = page_zone(page);
+	spin_lock_irq(&zone->lru_lock);
+	if (!PageLRU(page)) {
+		spin_unlock_irq(&zone->lru_lock);
+		return;
+	}
+
+	/* Unlink page from lru. */
+	__ClearPageLRU(page);
+	del_page_from_lru(zone, page);
+	spin_unlock_irq(&zone->lru_lock);
+
+	/* We can't handle swap cache pages (yet). */
+	BUG_ON(PageSwapCache(page));
+
+	/* Remove page from page cache. */
+	remove_from_page_cache(page);
+}
+
+/**
+ * page_hva_discard_page() - remove a discarded page from the cache
+ *
+ * @page: the page
+ *
+ * Before calling this function an additional page reference needs to
+ * be acquired. This reference is released by the function.
+ */
+void page_hva_discard_page(struct page *page)
+{
+	lock_page(page);
+	__page_hva_discard_page(page);
+	unlock_page(page);
+	page_cache_release(page);
+}
+EXPORT_SYMBOL(page_hva_discard_page);
diff -urpN linux-2.6/mm/page-writeback.c linux-2.6-patched/mm/page-writeback.c
--- linux-2.6/mm/page-writeback.c	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/mm/page-writeback.c	2006-04-24 12:51:26.000000000 +0200
@@ -727,6 +727,7 @@ int test_clear_page_dirty(struct page *p
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
+			page_hva_make_volatile(page, 1);
 			write_unlock_irqrestore(&mapping->tree_lock, flags);
 			if (mapping_cap_account_dirty(mapping))
 				dec_page_state(nr_dirty);
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2006-04-24 12:51:26.000000000 +0200
@@ -500,6 +500,7 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_page_state(nr_mapped);
+	page_hva_make_volatile(page, 1);
 }
 
 /**
@@ -540,19 +541,14 @@ void page_remove_rmap(struct page *page)
  * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
  */
 static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
-				int migration)
+				unsigned long address, int migration)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long address;
 	pte_t *pte;
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 
-	address = vma_address(page, vma);
-	if (address == -EFAULT)
-		goto out;
-
 	pte = page_check_address(page, mm, address, &ptl);
 	if (!pte)
 		goto out;
@@ -712,6 +708,7 @@ static int try_to_unmap_anon(struct page
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
+	unsigned long address;
 	int ret = SWAP_AGAIN;
 
 	anon_vma = page_lock_anon_vma(page);
@@ -719,7 +716,10 @@ static int try_to_unmap_anon(struct page
 		return ret;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		ret = try_to_unmap_one(page, vma, migration);
+		address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
+		ret = try_to_unmap_one(page, vma, address, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			break;
 	}
@@ -743,6 +743,7 @@ static int try_to_unmap_file(struct page
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;
+	unsigned long address;
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
@@ -750,7 +751,10 @@ static int try_to_unmap_file(struct page
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		ret = try_to_unmap_one(page, vma, migration);
+		address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
+		ret = try_to_unmap_one(page, vma, address, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			goto out;
 	}
@@ -851,3 +855,51 @@ int try_to_unmap(struct page *page, int 
 	return ret;
 }
 
+#if defined(CONFIG_PAGE_HVA)
+
+/**
+ * page_hva_unmap_all - removes all mappings of a page
+ *
+ * @page: the page which mapping in the vma should be struck down
+ *
+ * the caller needs to hold page lock
+ */
+void page_hva_unmap_all(struct page* page)
+{
+	struct address_space *mapping = page_mapping(page);
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	unsigned long address;
+
+	BUG_ON(!PageLocked(page) || PageReserved(page) || PageAnon(page));
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
+		BUG_ON(try_to_unmap_one(page, vma, address, 0) == SWAP_FAIL);
+	}
+
+	if (list_empty(&mapping->i_mmap_nonlinear))
+		goto out;
+
+	/*
+	 * Remove the non-linear mappings of the page. This is
+	 * awfully slow, but we have to find that discarded page..
+	 */
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
+			    shared.vm_set.list) {
+		address = vma->vm_start;
+		while (address < vma->vm_end) {
+			BUG_ON(try_to_unmap_one(page, vma, address, 0) == SWAP_FAIL);
+			address += PAGE_SIZE;
+		}
+	}
+
+out:
+	spin_unlock(&mapping->i_mmap_lock);
+}
+
+#endif
diff -urpN linux-2.6/mm/vmscan.c linux-2.6-patched/mm/vmscan.c
--- linux-2.6/mm/vmscan.c	2006-04-24 12:51:21.000000000 +0200
+++ linux-2.6-patched/mm/vmscan.c	2006-04-24 12:51:26.000000000 +0200
@@ -669,7 +669,11 @@ static unsigned long shrink_inactive_lis
 				add_page_to_active_list(zone, page);
 			else
 				add_page_to_inactive_list(zone, page);
-			if (!pagevec_add(&pvec, page)) {
+			if (page_hva_enabled() && unlikely(PageDiscarded(page))) {
+				spin_unlock_irq(&zone->lru_lock);
+				page_hva_discard_page(page);
+				spin_lock_irq(&zone->lru_lock);
+			} else if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
 				spin_lock_irq(&zone->lru_lock);
@@ -790,7 +794,11 @@ static void shrink_active_list(unsigned 
 
 		list_move(&page->lru, &zone->inactive_list);
 		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
+		if (page_hva_enabled() && unlikely(PageDiscarded(page))) {
+			spin_unlock_irq(&zone->lru_lock);
+			page_hva_discard_page(page);
+			spin_lock_irq(&zone->lru_lock);
+		} else if (!pagevec_add(&pvec, page)) {
 			zone->nr_inactive += pgmoved;
 			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
@@ -818,7 +826,11 @@ static void shrink_active_list(unsigned 
 		VM_BUG_ON(!PageActive(page));
 		list_move(&page->lru, &zone->active_list);
 		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
+		if (page_hva_enabled() && unlikely(PageDiscarded(page))) {
+			spin_unlock_irq(&zone->lru_lock);
+			page_hva_discard_page(page);
+			spin_lock_irq(&zone->lru_lock);
+		} else if (!pagevec_add(&pvec, page)) {
 			zone->nr_active += pgmoved;
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
