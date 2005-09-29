Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.12.10/8.12.10) with ESMTP id j8TDFETZ187508
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 13:15:14 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8TDFE9P162288
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:15:14 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j8TDFE93005349
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:15:14 +0200
Date: Thu, 29 Sep 2005 15:15:25 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 1/6] Page host virtual assist: base patch.
Message-ID: <20050929131525.GB5700@skybase.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Page host virtual assist: base patch.

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>

The basic idea for host virtual assist (hva) is to give a host system
which virtualizes the memory of its guest systems memory usage
information for guest pages. The host can then use this information
to optimize the management of guest pages, in particular the paging.
The main target for optimization are clean guest pages that do have a
backing on seconary storage (disk). The guest system can reload the
content, should it get lost.

In the base form of hva there are three guest page states: standard
uptodate and clean pages in the page or swap cache have state volatile,
free pages have guest page state unused and all other pages are stable.
The hva page state allows a paging hypervisor to rapidly remove pages
from a guest, without guest involvement (e.g. ballooning). Unused pages
can immediatly be reused at the time of the transition to unused state.
Volatile pages can be discarded by the host as part of the vmscan
operation instead of writing them to the paging device. This greatly
reduces the i/o needed by the host if it gets under memory pressure
and shifts the content reloading cost to the guest system. The guest
system doesn't notice that a discarded volatile the page is gone until
it tries to access the page or tries to make it stable. The Linux page
aging is not affected. Linux "thinks" that it still has the page in
page/swap cache and ages it according to current principles.

If the guest system tries to access an unused or discarded page it
gets a fault. For an unused page this can be some kind of bus error
since a page should never be accessed while it is free. This is
helpful for debugging purposes. For a volatile page that has been
discarded the host needs to deliver a special kind of fault to the
guest. This discard fault has to deliver the address of the page that
caused the fault. The guest system then removes the affected page from
the page or swap cache. The re-execution of the faulting instruction
now will result in a regular page fault that is processed in the
existing manner, i.e. the page is fetched by the guest from the
backing device again.

In the base form of hva introduced by this first patch the volatile
state makes sense only on a platform with physical, per-page dirty
bits because the host needs to be able to determine if a page has
become dirty without accessing the page table entries of its guest.
The host may only discard a volatile page if it is clean. With some
additional code that allows the platform to keep writable pages in
stable state it is possible to support platforms with per-pte dirty
bits as well. See patch #03.

That leaves the "simple" question: where to put the state transitions?
Some are easy: when a page is freed it is moved to unused state, when
it is allocated it moves to stable. An allocated page can change its
state between stable and volatile.

Allocated pages start out in stable state. What prevents a page from
being made volatile? There are 10 conditions:
1) The page is reserved. Some sort of special page, don't touch it.
2) The page is marked dirty in the struct page. The data in the page
   is more recent than the data on the backing device. This dirty
   indication is indepedent from the hardware dirty bit. We must not
   loose the page content.
3) The page is in writeback. The data in the page is needed until the
   i/o has finished.
4) The page is locked. Someone told us to leave the page in peace.
5) The page is anonymous. The page has no backing, can't recreate it.
6) The page has no mapping. Again no backing, can't recreate the page.
7) The page is not uptodate. The i/o to get the page uptodate has not
   finished yet. Doesn't make sense to discard a page before it has
   been uptodate once.
8) The page is private. There is additional information connected via
   the page->private pointer, e.g. journaling information. We don't
   know what hides behind page->private so better not loose the page
   content.
9) The page is already discarded. Making it volatile again would
   be wrong.
10) The page map count is not equal to page reference count - 1.
   There is a user besides the mappers of the page in the system. 
   Can't make the page volatile until the extra reference has been
   returned.

8 of the 10 conditions collapse into a single page->flags check. The
other two aren' too expensive either, a check against page->mapping
and a comparison of 2 counters.

If any of the conditions is true the page can't be made volatile.
The reverse is not necessarily true, a page doesn't have to be made
stable if one of the conditions changes. E.g. if a page is unmapped
from a page table the map count will decrease, shortly followed by a
decrease of the page reference counter. For some time condition #10
will be violated but the page doesn't have to be stable. Other
conditions are more stringent, if a page gets locked for i/o it has
to be stable. As a rule of thumb, transitions to stable state are
non-negotiable. Transitions to less stringent states (volatile or
unused) can be done at more convenient time and with the idea in
mind to keep the hot code paths lean.

Looking closely at the code almost all necessary state transitions to
stable can be done by find_get_page() and its variants. Whenever some
code finds a page it gets a stable page from the find function. There
are only three more places where a transition to stable is required:
get_user_pages if called with a non-NULL pages parameter, copy-on-write
in do_wp_page and the early copy-on-write break in do_no_page. The state
transition to stable can fail, in that case the page is removed from the
page/swap cache. find_get_page and variants returns NULL, get_user_pages
retries, do_wp_pages and do_no_page return with VM_FAULT_DISCARD.

The question when to try to get a page into volatile state isn't defined
as sharp as the question when a page needs to be stable. In principle
the function (page_hva_make_volatile) that tries to move a page into
volatile state can be called anytime. Whenever one of the conditions
#01 - #10 becomes false would be the 100% solution. We can be a bit
sloppy for the state changes to volatile, there is no harm done if we
don't get 100% of the pages that could be volatile. It is enough if the
majority of the suitable pages are volatile.

To get enough suitable pages to volatile state a try should be made
whenever a page is unlocked (unlock_page), finished writeback
(test_clear_page_dirty), the page reference counter is decreased
and when the page map counter is increased (page_add_anon_rmap and
page_add_file_rmap).

In addition to the usual memory management races there are two new
pitfalls: concurrent update of the page state and concurrent discard
faults for a single page.

For concurrent page state updates the PG_state_change page flag is
introduced. It prevents that a page_hva_make_stable can "overtake" a
page_hva_make_volatile. If the make volatile has already done all the
checks it will go ahead and change the page state to volatile. If in
the meantime one of the conditions has changed the user that requires
that a page is stable will have to wait until the make volatile has
finished. The check of the ten conditions and the state transitions to
volatile needs to be atomic in respect to the state transition to
stable. The other way round, the make volatile operation does not wait
for the PG_state_change bit because the make volatile might be invoked
in interrupt context. Waiting for the page flag would dead-lock the
system. This is another source for sloppyness. If the make volatile
operation hits an obstacle it just gives up, again no harm done. The
worst that can happen is that a page turns out stable although it
might be volatile.

For concurrent discard faults the page may only be removed from the
page/swap cache once. The new PG_discarded page flag is used for that
purpose. In addition the page is removed from page/swap cache in a
special way: the page->mapping is not cleared because later discard
faults still need the information. That is due to races in the memory
management, if a page is in the process of getting mapped while a
discard fault removes the page the system ends up with a mapping of a
discarded page that isn't in page/swap cache anymore. The first access
of such a page will end in another discard fault. To unmap that mapping
the page->mapping pointer is needed. The "real" __remove_from_page_cache
checks for the PG_discarded bit and only clears the page->mapping. The
other operations have already been done. 

The code that is introduced by this patch still has some issues.

1) The mlock system call needs to be handled in a special way.
2) Only works on a platform with per-page dirty bits. For platforms
   with per-pte dirty bits some care is needed for writable ptes.
3) For every minor fault two guest state changes are done and for
   each page unmap another state change is done. This is too expensive.

The patches #02, #03 and #04 deal with issues 1), 2) and 3).

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

diffstat:
 include/linux/mm.h         |   22 +++--
 include/linux/page-flags.h |   13 +++
 include/linux/page_hva.h   |   46 +++++++++++
 mm/Makefile                |    2 
 mm/filemap.c               |   71 ++++++++++++++++-
 mm/memory.c                |   78 +++++++++++++++++-
 mm/page-writeback.c        |    1 
 mm/page_alloc.c            |   14 ++-
 mm/page_hva.c              |  110 ++++++++++++++++++++++++++
 mm/readahead.c             |    6 +
 mm/rmap.c                  |  187 +++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |  104 +++++++++++++++++++++++++
 12 files changed, 637 insertions(+), 17 deletions(-)

diff -urpN linux-2.5/include/linux/mm.h linux-2.5-cmm2/include/linux/mm.h
--- linux-2.5/include/linux/mm.h	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/include/linux/mm.h	2005-09-29 14:49:51.000000000 +0200
@@ -287,16 +287,25 @@ struct page {
  * macros which retain the old rules: page_count(page) == 0 is a free page.
  */
 
+#include <linux/page_hva.h>
+
 /*
  * Drop a ref, return true if the logical refcount fell to zero (the page has
- * no users)
+ * no users).
+ *
+ * put_page_testzero checks if the page can be made volatile if the page
+ * still has users and the page host virtual assist is enabled.
  */
-#define put_page_testzero(p)				\
-	({						\
-		BUG_ON(page_count(p) == 0);		\
-		atomic_add_negative(-1, &(p)->_count);	\
-	})
 
+#define put_page_testzero(p)					\
+	({							\
+		int ret;					\
+		BUG_ON(page_count(p) == 0);			\
+		ret = atomic_add_negative(-1, &(p)->_count);	\
+		if (!ret)					\
+			page_hva_make_volatile(p, 1);		\
+		ret;						\
+	})
 /*
  * Grab a ref, return true if the page previously had a logical refcount of
  * zero.  ie: returns true if we just grabbed an already-deemed-to-be-free page
@@ -629,6 +638,7 @@ static inline int page_mapped(struct pag
 #define VM_FAULT_SIGBUS	0x01
 #define VM_FAULT_MINOR	0x02
 #define VM_FAULT_MAJOR	0x03
+#define VM_FAULT_DISCARD 0x04
 
 /* 
  * Special case for get_user_pages.
diff -urpN linux-2.5/include/linux/page-flags.h linux-2.5-cmm2/include/linux/page-flags.h
--- linux-2.5/include/linux/page-flags.h	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/include/linux/page-flags.h	2005-09-29 14:49:51.000000000 +0200
@@ -76,6 +76,9 @@
 #define PG_nosave_free		18	/* Free, should not be written */
 #define PG_uncached		19	/* Page has been mapped as uncached */
 
+#define PG_state_change	20		/* HV page state is changing. */
+#define PG_discarded		21	/* HV page has been discarded. */
+
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
  * allowed.
@@ -305,6 +308,16 @@ extern void __mod_page_state(unsigned lo
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageStateChange(page) test_bit(PG_state_change, &(page)->flags)
+#define ClearPageStateChange(page) clear_bit(PG_state_change, &(page)->flags)
+#define TestSetPageStateChange(page) \
+		test_and_set_bit(PG_state_change, &(page)->flags)
+
+#define PageDiscarded(page) test_bit(PG_discarded, &(page)->flags)
+#define ClearPageDiscarded(page) clear_bit(PG_discarded, &(page)->flags)
+#define TestSetPageDiscarded(page) \
+		test_and_set_bit(PG_discarded, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
diff -urpN linux-2.5/include/linux/page_hva.h linux-2.5-cmm2/include/linux/page_hva.h
--- linux-2.5/include/linux/page_hva.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.5-cmm2/include/linux/page_hva.h	2005-09-29 14:49:51.000000000 +0200
@@ -0,0 +1,46 @@
+#ifndef _LINUX_PAGE_HVA_H
+#define _LINUX_PAGE_HVA_H
+
+/*
+ * include/linux/page_hva.h
+ *
+ * (C) Copyright IBM Corp. 2005
+ *
+ * Host virtual assist functions.
+ *
+ * Authors: Himanshu Raj <rhim@cc.gatech.edu>
+ *          Hubertus Franke <frankeh@watson.ibm.com>
+ *          Martin Schwidefsky <schwidefsky@de.ibm.com>
+ */
+#ifdef CONFIG_PAGE_HVA
+
+#include <asm/page_hva.h>
+
+extern int page_hva_make_stable(struct page *page);
+extern void page_hva_discard_page(struct page *page);
+extern void __page_hva_discard_page(struct page *page);
+extern void __page_hva_make_volatile(struct page *page, unsigned int offset);
+
+static inline void page_hva_make_volatile(struct page *page,
+					  unsigned int offset)
+{
+	if (likely(!test_bit(PG_discarded, &page->flags)))
+		__page_hva_make_volatile(page, offset);
+}
+
+#else
+
+#define page_hva_set_unused(_page)		do { } while (0)
+#define page_hva_set_stable(_page)		do { } while (0)
+#define page_hva_set_volatile(_page)		do { } while (0)
+#define page_hva_set_stable_if_resident(_page)	(1)
+
+#define page_hva_make_stable(_page)		(1)
+#define page_hva_make_volatile(_page,_offset)	do { } while (0)
+
+#define page_hva_discard_page(_page)		do { } while (0)
+#define __page_hva_discard_page(_page)		do { } while (0)
+
+#endif
+
+#endif /* _LINUX_PAGE_HVA_H */
diff -urpN linux-2.5/mm/filemap.c linux-2.5-cmm2/mm/filemap.c
--- linux-2.5/mm/filemap.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/filemap.c	2005-09-29 14:49:51.000000000 +0200
@@ -109,6 +109,20 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
+#ifdef CONFIG_PAGE_HVA
+	/*
+	 * Check if the page has been discarded. If the PG_discarded
+	 * bit is set then __page_hva_discard_page already removed
+	 * the page from the radix tree due to a discard fault. It
+	 * did NOT clear the page->mapping because that is needed
+	 * in the discard fault for multiple discards of a single
+	 * page. Clear the mapping now.
+	 */
+	if (unlikely(PageDiscarded(page))) {
+		page->mapping = NULL;
+		return;
+	}
+#endif
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
@@ -459,6 +473,7 @@ void fastcall unlock_page(struct page *p
 	if (!TestClearPageLocked(page))
 		BUG();
 	smp_mb__after_clear_bit(); 
+	page_hva_make_volatile(page, 1);
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
@@ -507,6 +522,15 @@ struct page * find_get_page(struct addre
 	if (page)
 		page_cache_get(page);
 	read_unlock_irq(&mapping->tree_lock);
+	/*
+	 * If page is found, but was discarded we run the discard handler
+	 * and return NULL.
+	 */
+	if (page && unlikely(!page_hva_make_stable(page))) {
+		page_hva_discard_page(page);
+		page_cache_release(page);
+		page = NULL;
+	}
 	return page;
 }
 
@@ -523,6 +547,14 @@ struct page *find_trylock_page(struct ad
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page && TestSetPageLocked(page))
 		page = NULL;
+	if (page && unlikely(!page_hva_make_stable(page))) {
+		page_cache_get(page);
+		read_unlock_irq(&mapping->tree_lock);
+		__page_hva_discard_page(page);
+		unlock_page(page);
+		page_cache_release(page);
+		return NULL;
+	}
 	read_unlock_irq(&mapping->tree_lock);
 	return page;
 }
@@ -550,7 +582,12 @@ repeat:
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page) {
 		page_cache_get(page);
-		if (TestSetPageLocked(page)) {
+		if (unlikely(!page_hva_make_stable(page))) {
+			read_unlock_irq(&mapping->tree_lock);
+			page_hva_discard_page(page);
+			page_cache_release(page);
+			return NULL;
+		} else if (TestSetPageLocked(page)) {
 			read_unlock_irq(&mapping->tree_lock);
 			lock_page(page);
 			read_lock_irq(&mapping->tree_lock);
@@ -637,11 +674,25 @@ unsigned find_get_pages(struct address_s
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
+		 * Set stable failed, we discard the page and retry the
+		 * whole operation.
+		 */
+		read_unlock_irq(&mapping->tree_lock);
+		page_hva_discard_page(pages[i]);
+		do {
+			page_hva_discard_page(pages[i]);
+		} while (i--);
+		goto repeat;
+	}
 	read_unlock_irq(&mapping->tree_lock);
 	return ret;
 }
@@ -656,11 +707,25 @@ unsigned find_get_pages_tag(struct addre
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
+		 * Set stable failed, we discard the page and retry the
+		 * whole operation.
+		 */
+		read_unlock_irq(&mapping->tree_lock);
+		page_hva_discard_page(pages[i]);
+		do {
+			page_hva_discard_page(pages[i]);
+		} while (i--);
+		goto repeat;
+	}
 	if (ret)
 		*index = pages[ret - 1]->index + 1;
 	read_unlock_irq(&mapping->tree_lock);
diff -urpN linux-2.5/mm/Makefile linux-2.5-cmm2/mm/Makefile
--- linux-2.5/mm/Makefile	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/Makefile	2005-09-29 14:49:51.000000000 +0200
@@ -20,3 +20,5 @@ obj-$(CONFIG_SHMEM) += shmem.o
 obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
 
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
+
+obj-$(CONFIG_PAGE_HVA) 	+= page_hva.o
diff -urpN linux-2.5/mm/memory.c linux-2.5-cmm2/mm/memory.c
--- linux-2.5/mm/memory.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/memory.c	2005-09-29 14:49:51.000000000 +0200
@@ -947,6 +947,7 @@ int get_user_pages(struct task_struct *t
 			int write_access = write;
 			struct page *page;
 
+retry:
 			cond_resched_lock(&mm->page_table_lock);
 			while (!(page = follow_page(mm, start, write_access))) {
 				int ret;
@@ -979,6 +980,7 @@ int get_user_pages(struct task_struct *t
 					tsk->min_flt++;
 					break;
 				case VM_FAULT_MAJOR:
+				case VM_FAULT_DISCARD:
 					tsk->maj_flt++;
 					break;
 				case VM_FAULT_SIGBUS:
@@ -993,8 +995,30 @@ int get_user_pages(struct task_struct *t
 			if (pages) {
 				pages[i] = page;
 				flush_dcache_page(page);
-				if (!PageReserved(page))
+				if (!PageReserved(page)) {
 					page_cache_get(page);
+					/*
+					 * The pages are only locked in mem in
+					 * case the pages array is non-null,
+					 * implying that guest can deal with
+					 * page fault in case the page is
+					 * swapped out (although unlikely since
+					 * it was just swapped in if not
+					 * present). Hence, we assume that
+					 * guest can also tolerate the discard
+					 * fault if one arrives. However, in
+					 * case pages are locked in mem, we
+					 * should also make sure that there is
+					 * no discard  fault for these pages.
+					 * Hence, we make these pages stable.
+					 */
+					if (unlikely(!page_hva_make_stable(page))) {
+						spin_unlock(&mm->page_table_lock);
+						page_hva_discard_page(page);
+						page_cache_release(page);
+						goto retry;
+					}
+				}
 			}
 			if (vmas)
 				vmas[i] = vma;
@@ -1273,8 +1297,33 @@ static int do_wp_page(struct mm_struct *
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
-	if (!PageReserved(old_page))
+	if (!PageReserved(old_page)) {
 		page_cache_get(old_page);
+
+		/*
+		 * We need to put the old_page in stable state because it
+		 * will be copied to a new page (COW). page_cache_release
+		 * on old_page will make it volatile again.
+		 */
+		if (unlikely(!page_hva_make_stable(old_page))) {
+			spin_unlock(&mm->page_table_lock);
+			page_hva_discard_page(old_page);
+			page_cache_release(old_page);
+			/*
+			 * Here we do not try to make sure that the page
+			 * indeed is discarded. If we fail for some reason,
+			 * we let the instruction generate the fault again.
+			 * If it is a discard fault, it will be handled its
+			 * own way. The chance of getting a wp fault on a
+			 * discarded page is slim - will only happen when host
+			 * discards a page after a wp fault has been pushed
+			 * to guest already.
+			 */
+			return VM_FAULT_DISCARD;
+		}
+	}
+
+
 	spin_unlock(&mm->page_table_lock);
 
 	if (unlikely(anon_vma_prepare(vma)))
@@ -1720,9 +1769,15 @@ static int do_swap_page(struct mm_struct
 	unlock_page(page);
 
 	if (write_access) {
-		if (do_wp_page(mm, vma, address,
-				page_table, pmd, pte) == VM_FAULT_OOM)
-			ret = VM_FAULT_OOM;
+		/*
+		 * In case of a write access, we change the state of the
+		 * old_page inside do_wp_page. The return status is only
+		 * changed if do_wp_page returns OOM. Now since it can
+		 * also return DISCARD, we need to fit that too.
+		 */
+		int rc = do_wp_page(mm, vma, address, page_table, pmd, pte);
+		if ((rc == VM_FAULT_OOM) || (rc == VM_FAULT_DISCARD))
+			ret = rc;
 		goto out;
 	}
 
@@ -1862,6 +1917,12 @@ retry:
 		page = alloc_page_vma(GFP_HIGHUSER, vma, address);
 		if (!page)
 			goto oom;
+		if (unlikely(!page_hva_make_stable(new_page))) {
+			__free_pages(page, 0);
+			page_hva_discard_page(new_page);
+			page_cache_release(new_page);
+			return VM_FAULT_DISCARD;
+		}
 		copy_user_highpage(page, new_page, address);
 		page_cache_release(new_page);
 		new_page = page;
@@ -1902,6 +1963,13 @@ retry:
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
+		/*
+		 * The COW page is not part of swap cache yet. No need
+		 * to try to make it volatile. If the page returned
+		 * by the no_page handler is entered into the page table
+		 * try to make it volatile after the page map counter has
+		 * been increased.
+		 */
 		if (anon) {
 			lru_cache_add_active(new_page);
 			page_add_anon_rmap(new_page, vma, address);
diff -urpN linux-2.5/mm/page_alloc.c linux-2.5-cmm2/mm/page_alloc.c
--- linux-2.5/mm/page_alloc.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/page_alloc.c	2005-09-29 14:49:51.000000000 +0200
@@ -326,7 +326,8 @@ static inline void free_pages_check(cons
 			1 << PG_reclaim	|
 			1 << PG_slab	|
 			1 << PG_swapcache |
-			1 << PG_writeback )))
+			1 << PG_writeback |
+			1 << PG_discarded )))
 		bad_page(function, page);
 	if (PageDirty(page))
 		ClearPageDirty(page);
@@ -380,8 +381,10 @@ void __free_pages_ok(struct page *page, 
 			__put_page(page + i);
 #endif
 
-	for (i = 0 ; i < (1 << order) ; ++i)
+	for (i = 0 ; i < (1 << order) ; ++i) {
 		free_pages_check(__FUNCTION__, page + i);
+		page_hva_set_unused(page+i);
+	}
 	list_add(&page->lru, &list);
 	kernel_map_pages(page, 1<<order, 0);
 	free_pages_bulk(page_zone(page), 1, &list, order);
@@ -454,7 +457,8 @@ static void prep_new_page(struct page *p
 			1 << PG_reclaim	|
 			1 << PG_slab    |
 			1 << PG_swapcache |
-			1 << PG_writeback )))
+			1 << PG_writeback |
+		        1 << PG_discarded )))
 		bad_page(__FUNCTION__, page);
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
@@ -650,6 +654,7 @@ static void fastcall free_hot_cold_page(
 	if (PageAnon(page))
 		page->mapping = NULL;
 	free_pages_check(__FUNCTION__, page);
+	page_hva_set_unused(page);
 	pcp = &zone_pcp(zone, get_cpu())->pcp[cold];
 	local_irq_save(flags);
 	list_add(&page->lru, &pcp->list);
@@ -690,6 +695,7 @@ buffered_rmqueue(struct zone *zone, int 
 	unsigned long flags;
 	struct page *page = NULL;
 	int cold = !!(gfp_flags & __GFP_COLD);
+	int i;
 
 	if (order == 0) {
 		struct per_cpu_pages *pcp;
@@ -716,6 +722,8 @@ buffered_rmqueue(struct zone *zone, int 
 
 	if (page != NULL) {
 		BUG_ON(bad_range(zone, page));
+		for (i = 0 ; i < (1 << order) ; ++i)
+			page_hva_set_stable(page+i);
 		mod_page_state_zone(zone, pgalloc, 1 << order);
 		prep_new_page(page, order);
 
diff -urpN linux-2.5/mm/page_hva.c linux-2.5-cmm2/mm/page_hva.c
--- linux-2.5/mm/page_hva.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.5-cmm2/mm/page_hva.c	2005-09-29 14:49:51.000000000 +0200
@@ -0,0 +1,110 @@
+/*
+ * mm/page_hva.c
+ *
+ * (C) Copyright IBM Corp. 2005
+ *
+ * Host virtual assist functions.
+ *
+ * Authors: Himanshu Raj <rhim@cc.gatech.edu>
+ *          Hubertus Franke <frankeh@watson.ibm.com>
+ *          Martin Schwidefsky <schwidefsky@de.ibm.com>
+ */
+
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/module.h>
+#include <linux/spinlock.h>
+#include <linux/buffer_head.h>
+
+/*
+ * Check the state of a page if there is something that prevents
+ * the page from changing its state to volatile.
+ */
+static inline int
+__page_hva_discardable(struct page *page, unsigned int offset)
+{
+	/*
+	 * There are several conditions that prevent a page from becoming
+	 * volatile. The first check is for the page bits, if the page
+	 * is dirty, reserved, in writeback, locked, anonymous or
+	 * not up-to-date we can't allow the hypervisor to removed the
+	 * page.
+	 */
+
+	if (PageDirty(page) || PageReserved(page) || PageWriteback(page) ||
+	    PageLocked(page) || PageAnon(page) || !PageUptodate(page) ||
+	    PagePrivate(page) || PageDiscarded(page))
+		return 0;
+
+	/*
+	 * If the page has been truncated there is no point in makeing
+	 * it volatile. It will be freed soon.
+	 */
+	if (!page_mapping(page))
+		return 0;
+
+	/*
+	 * The last check is the critical one. We check the reference
+	 * count of the page against the number of mappings. The caller
+	 * of make_volatile passes an offset, that is the number extra
+	 * references. For most calls that is 1 extra reference for the
+	 * page-cache. In some cases the caller itself holds an additional
+	 * reference, then the offset is 2. If the page map count is equal
+	 * to the page count minus the offset then there is no other
+	 * (unknown) user of the page in the system and we can make the
+	 * page volatile.
+	 */
+
+	if (page_mapcount(page) != page_count(page) - offset)
+		return 0;
+
+	return 1;
+}
+
+/*
+ * Tries to change the state of a page from STABLE to VOLATILE. If there
+ * is something preventing the state change the page stays in STABLE.
+ */
+void __page_hva_make_volatile(struct page *page, unsigned int offset)
+{
+	/*
+	 * If we can't get the PG_state_change bit just give up. The
+	 * worst that can happen is that the page will stay in stable
+	 * state although if might be volatile.
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
+ * Change the state of a page from VOLATILE to STABLE
+ *
+ * returns "0" on success and "1" on failure
+ */
+int page_hva_make_stable(struct page *page)
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
+	return page_hva_set_stable_if_resident(page);
+}
+EXPORT_SYMBOL(page_hva_make_stable);
diff -urpN linux-2.5/mm/page-writeback.c linux-2.5-cmm2/mm/page-writeback.c
--- linux-2.5/mm/page-writeback.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/page-writeback.c	2005-09-29 14:49:51.000000000 +0200
@@ -712,6 +712,7 @@ int test_clear_page_dirty(struct page *p
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
+			page_hva_make_volatile(page, 1);
 			write_unlock_irqrestore(&mapping->tree_lock, flags);
 			if (mapping_cap_account_dirty(mapping))
 				dec_page_state(nr_dirty);
diff -urpN linux-2.5/mm/readahead.c linux-2.5-cmm2/mm/readahead.c
--- linux-2.5/mm/readahead.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/readahead.c	2005-09-29 14:49:51.000000000 +0200
@@ -281,6 +281,12 @@ __do_page_cache_readahead(struct address
 
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		if (page)
+			/*
+			 * If the page is found we simply continue and let the
+			 * discard_fault handler pick up a discarded fault.
+			 * Checking the page state in readahead is an expensive
+			 * operation.
+			 */
 			continue;
 
 		read_unlock_irq(&mapping->tree_lock);
diff -urpN linux-2.5/mm/rmap.c linux-2.5-cmm2/mm/rmap.c
--- linux-2.5/mm/rmap.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/rmap.c	2005-09-29 14:49:51.000000000 +0200
@@ -461,6 +461,7 @@ void page_add_anon_rmap(struct page *pag
 		inc_page_state(nr_mapped);
 	}
 	/* else checking page index and mapping is racy */
+	page_hva_make_volatile(page, 1);
 }
 
 /**
@@ -477,8 +478,194 @@ void page_add_file_rmap(struct page *pag
 
 	if (atomic_inc_and_test(&page->_mapcount))
 		inc_page_state(nr_mapped);
+	page_hva_make_volatile(page, 1);
 }
 
+#if defined(CONFIG_PAGE_HVA)
+
+/**
+ * page_hva_unmap - removes a mapping of a page from a pte
+ *
+ * @page:    the page which mapping in the vma should be struck down
+ * @vma:     virtual memory area that might hold a mapping to page
+ * @address: address in the page table entry that might contain the mapping
+ *
+ * the caller needs to hold page lock, the rmap lock on the page and
+ * the page table lock for the pte.
+ */
+static inline void
+page_hva_unmap(struct page *page, struct vm_area_struct *vma,
+	       unsigned long address)
+{
+	struct mm_struct * mm = vma->vm_mm;
+	pgd_t *pgd;
+	pgd_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	pte_t pteval;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		goto out;
+
+	pte = pte_offset_map(pmd, address);
+	if (!pte_present(*pte))
+		goto out_unmap;
+
+	if (page_to_pfn(page) != pte_pfn(*pte))
+		goto out_unmap;
+
+	/*
+	 * If the page is mlock()d, shouldn't have gotten a discard
+	 * fault for it.
+	 */
+	BUG_ON(vma->vm_flags & (VM_LOCKED|VM_RESERVED));
+
+	/* Nuke the page table entry. */
+	flush_cache_page(vma, address, page_to_pfn(page));
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	/* A discarded page with a dirty PTE! may not happen. */
+	BUG_ON(pte_dirty(pteval));
+
+	if (PageAnon(page)) {
+		swp_entry_t entry = { .val = page->private };
+		/*
+		 * Store the swap location in the pte.
+		 * See handle_pte_fault() ...
+		 */
+		BUG_ON(!PageSwapCache(page));
+		swap_duplicate(entry);
+		if (list_empty(&mm->mmlist)) {
+			spin_lock(&mmlist_lock);
+			list_add(&mm->mmlist, &init_mm.mmlist);
+			spin_unlock(&mmlist_lock);
+		}
+		set_pte(pte, swp_entry_to_pte(entry));
+		BUG_ON(pte_file(*pte));
+		dec_mm_counter(mm, anon_rss);
+	}
+
+	dec_mm_counter(mm, rss);
+
+	page_remove_rmap(page);
+
+	page_cache_release(page);
+
+out_unmap:
+	pte_unmap(pte);
+out:
+	return;
+}
+
+/**
+ * page_hva_unmap_linear - removes a mapping of a page from a linear vma
+ *
+ * @page: the page which mapping in the vma should be struck down
+ * @vma:  virtual memory area that might hold a mapping to page
+ *
+ * the caller needs to hold page lock and rmap lock on page.
+ */
+static void page_hva_unmap_linear(struct page *page, struct vm_area_struct *vma)
+{
+	struct mm_struct * mm = vma->vm_mm;
+	unsigned long address;
+
+	if (!mm)
+		BUG();
+	if (!get_mm_counter(mm, rss))
+		return;
+	address = vma_address(page, vma);
+	if (address == -EFAULT)
+		goto out;
+
+	/*
+	 * We need the page_table_lock to protect us from page faults,
+	 * munmap, fork, etc...
+	 */
+	spin_lock(&mm->page_table_lock);
+	page_hva_unmap(page, vma, address);
+	spin_unlock(&mm->page_table_lock);
+out:
+	return;
+}
+
+/**
+ * page_hva_unmap_nonlinear - removes a mapping of a page from a
+ *			      non-linear vma
+ *
+ * @page: the page which mapping in the vma should be struck down
+ * @vma:  virtual memory area that might hold a mapping to page
+ *
+ * the caller needs to hold page lock and rmap lock on page.
+ */
+static void
+page_hva_unmap_nonlinear(struct page *page, struct vm_area_struct *vma)
+{
+	struct mm_struct * mm = vma->vm_mm;
+	unsigned long address;
+
+	if (!mm)
+		BUG();
+	if (!get_mm_counter(mm, rss))
+		return;
+
+	/*
+	 * We need the page_table_lock to protect us from page faults,
+	 * munmap, fork, etc...
+	 */
+	spin_lock(&mm->page_table_lock);
+	address = vma->vm_start;
+	while (address < vma->vm_end) {
+		page_hva_unmap(page, vma, address);
+		address += PAGE_SIZE;
+	}
+	spin_unlock(&mm->page_table_lock);
+}
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
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+
+	BUG_ON(PageReserved(page) || PageAnon(page));
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		page_hva_unmap_linear(page, vma);
+		if (!page_mapped(page))
+			break;
+	}
+
+	if (list_empty(&mapping->i_mmap_nonlinear))
+		goto out;
+
+	list_for_each_entry(vma, &mapping->i_mmap_nonlinear,
+						shared.vm_set.list)
+		page_hva_unmap_nonlinear(page, vma);
+
+out:
+	spin_unlock(&mapping->i_mmap_lock);
+}
+#endif
+
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
diff -urpN linux-2.5/mm/vmscan.c linux-2.5-cmm2/mm/vmscan.c
--- linux-2.5/mm/vmscan.c	2005-08-29 01:41:01.000000000 +0200
+++ linux-2.5-cmm2/mm/vmscan.c	2005-09-29 14:49:51.000000000 +0200
@@ -555,6 +555,110 @@ keep:
 	return reclaimed;
 }
 
+#ifdef CONFIG_PAGE_HVA
+
+/*
+ * This is a direct discard reclaim path, taken by the discard fault
+ * handler and the proactive discard handling in mm
+ */
+extern void page_hva_unmap_all(struct page *page);
+
+/**
+ * __page_hva_discard_page() - remove a discarded page from the cache
+ *
+ * @page: the page
+ *
+ * The page passed to this function needs to be lcoked.
+ */
+void __page_hva_discard_page(struct page *page)
+{
+	struct address_space *mapping;
+	struct zone *zone;
+	int discarded;
+
+	/* Set the discarded bit early. */
+	discarded = TestSetPageDiscarded(page);
+
+	/* Remove page-table entries for this page. */
+	if (page_mapped(page))
+		page_hva_unmap_all(page);
+
+	/*
+	 * Remove the page from the lru and page/swap cache only once.
+	 * We can arrive in this function several times for a single page.
+	 */
+	if (discarded)
+		return;
+
+	zone = page_zone(page);
+
+	/*
+	 * Remove the page from LRU. The page is on the lru list because
+	 * pages not on the lru can't become volatile and therefore not
+	 * discarded. The reason is that lru_cache_add takes an extra
+	 * page reference while the page is on the per-cpu lru list.
+	 * That extra reference prevents page_hva_make_volatile from
+	 * changing the page state to volatile.
+	 */
+
+	spin_lock_irq(&zone->lru_lock);
+	if (TestClearPageLRU(page))
+		del_page_from_lru(zone, page);
+	spin_unlock_irq(&zone->lru_lock);
+
+	/* A page marked for writeback should not end up here. */
+	BUG_ON(PageWriteback(page));
+
+	/* A dirty page should not be venturing here. */
+	BUG_ON(PageDirty(page));
+
+	if (PagePrivate(page))
+		/*
+		 * Free the page from buffer cache. While i/o is
+		 * ongoing in the buffer cache the page is in stable.
+		 * If no i/o is ongoing the page can always be released.
+		 */
+		BUG_ON(!try_to_release_page(page, GFP_ATOMIC));
+
+	mapping = page_mapping(page);
+	/* Make sure that this page has a mapping. */
+	BUG_ON(!mapping);
+
+	write_lock_irq(&mapping->tree_lock);
+
+#ifdef CONFIG_SWAP
+	if (PageSwapCache(page)) {
+		swp_entry_t swap = { .val = page->private };
+		__delete_from_swap_cache(page);
+		write_unlock_irq(&mapping->tree_lock);
+		swap_free(swap);
+		goto free_it;
+	}
+#endif /* CONFIG_SWAP */
+
+	/* __remove_from_page_cache without page->mapping = NULL. */
+	radix_tree_delete(&mapping->page_tree, page->index);
+	mapping->nrpages--;
+	pagecache_acct(-1);
+
+	write_unlock_irq(&mapping->tree_lock);
+free_it:
+	__put_page(page); 	/* Pagecache ref */
+}
+EXPORT_SYMBOL(__page_hva_discard_page);
+
+void page_hva_discard_page(struct page *page)
+{
+	/* Get exclusive access to the page ... */
+	lock_page(page);
+
+	__page_hva_discard_page(page);
+
+	unlock_page(page);
+}
+EXPORT_SYMBOL(page_hva_discard_page);
+#endif
+
 /*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
