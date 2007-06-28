Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5SGfCR1188544
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 16:41:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5SGfCIg2085070
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:12 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5SGfB7Z016538
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:12 +0200
Message-Id: <20070628164312.419848294@de.ibm.com>
References: <20070628164049.118610355@de.ibm.com>
Date: Thu, 28 Jun 2007 18:40:50 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 1/6] Guest page hinting: core + volatile page cache.
Content-Disposition: inline; filename=001-hva-core.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

The guest page hinting patchset introduces code that passes guest
page usage information to the host system that virtualizes the
memory of its guests. There are three different page states:
* Unused: The page content is of no interest to the guest. The
  host can forget the page content anr replace it with a page
  containing zeroes.
* Stable: The page content is needed by the guest and has to be
  preserved by the host.
* Volatile: The page content is useful to the guest but not
  essential. The host can discard the page but has to deliver a
  special kind of fault to the guest if the guest accesses a
  page discarded by the host.
   
The unused state is used for free pages, it allows the host to avoid
the paging of empty pages. The default state for non-free pages is
stable. The host can write stable pages to a swap device but has
to restore the page if the guest accesses it. The volatile page state
is used for clean uptodate page cache pages. The host can choose to
discard volatile pages as part of its vmscan operation instead of
writing them to the hosts paging device. The guest system doesn't
notice that a volatile page is gone until it tries to access the page
or if it tries to make the page stable again. For a guest access to a
discarded page the host generates a discard fault to notify the guest.
The guest has to remove the page from the cache and reload the page
from its backing device.

The volatile state is used for all page cache pages, even for pages
which are referenced by writable ptes. The host needs to be able to
check the dirty state of the pages. Since the host doesn't know where
the page table entries of the guest are located, the volatile state as
introduced by this patch is only usable on architectures with per-page
dirty bits (s390 only). For per-pte dirty bit architectures some
additional code is needed, see patch #4.

The main question is where to put the state transitions between
the volatile and the stable state. The simple solution is to make a
page stable whenever a lookup is done or a page reference is derived
from a page table entry. Attempts to make pages volatile are added at
strategic points. The conditions that prevent a page from being made
volatile:
1) The page is reserved. Some sort of special page.
2) The page is marked dirty in the struct page. The page content is
   more recent than the data on the backing device. The host cannot
   access the linux internal dirty bit so the page needs to be stable.
3) The page is in writeback. The page content is needed for i/o.
4) The page is locked. Someone has exclusive access to the page.
5) The page is anonymous. Swap cache support needs additional code.
   See patch #2.
6) The page has no mapping. Without a backing the page cannot be
   recreated.
7) The page is not uptodate.
8) The page has private information. try_to_release_page can fail,
   e.g. in case the private information is journaling data. The discard
   fault need to be able to remove the page.
9) The page is already discarded.
10) The page is not on the LRU list. The page has been isolated, some
   processing is done.
11) The page map count is not equal to the page reference count - 1.
   The discard fault handler can remove the page cache reference and
   all mappers of a page. It cannot remove the page reference for any
   other user of the page.

The transitions to stable are done by find_get_pages() and its variants,
in follow_page if the FOLL_GET flag is set, by copy-on-write in
do_wp_page, and by the early copy-on-write in do_no_page. For page cache
page this is always done with a call to page_make_stable().
To make enough pages discardable by the host an attempt to do the
transition to volatile state is done at several places:
1) When a page gets unlocked (unlock_page).
2) When writeback has finished (test_clear_page_writeback).
3) When the page reference counter is decreased (__free_pages,
   page_cache_release alias put_page_check and __pagevec_release_nonlru
   right before the put_page_testzero call).
4) When the map counter in increased (page_add_file_rmap).
5) When a page is moved from the active list to the inactive list.
6) In filemap_nopage after the wait for readpage has finished. This try
   is necessary because filemap_nopage held an additional reference to
   the page so that the page_make_volatile call in unlock_page could not
   do the state transition.
The function for the state transitions to volatile is page_make_volatile().

The major obstacles that need to get addressed:
* Concurrent page state changes:
  To guard against concurrent page state updates some kind of lock
  is needed. If page_make_volatile() has already done the 11 checks it
  will issue the state change primitive. If in the meantime one of
  the conditions has changed the user that requires that page in
  stable state will have to wait in the page_make_stable() function
  until the make volatile operation has finished. It is up to the
  architecture to define how this is done with the three primitives
  page_test_set_state_change, page_clear_state_change and
  page_state_change.
  There are some alternatives how this can be done, e.g. a global
  lock, or lock per segment in the kernel page table, or the per page
  bit PG_arch_1 if it is still free.

* Page references acquired from page tables:
  All page references acquired with find_get_page and friends can be
  used to access the page frame content. A page reference grabbed from
  a page table cannot be used to access the page content, the page has
  to be made stable first. If the make stable operation fails because
  the page has been discarded it has to be removed from page cache.
  That removes the page table entry as well.

* Page discard vs. __remove_from_page_cache race
  A new page flag PG_discarded is added. This bit is set for discarded
  pages. It prevents multiple removes of a page from the page cache due
  to concurrent discard faults and/or normal page removals. It also
  prevents the re-add of isolated pages to the lru list in vmscan if
  the page has been discarded while it was not on the lru list.

* Page discard vs. pte establish
  The discard fault handler does three things: 1) set the PG_discarded
  bit for the page, 2) remove the page from all page tables and 3) remove
  the page from the page cache. All page references of the discarded
  page that are still around after step 2 may not be used to establish
  new mappings because step 3 clears the page->mapping field that is
  required to find the mappers. Code that establishes new ptes to pages
  that might be discarded has to check the PG_discarded bit. Step 2 has
  to check all possible location for a pte of a particular page and check
  if the pte exists or another processor might be in the process of
  establishing one. To do that the page table lock for the pte is used.
  See page_unmap_all and the modified quick check in page_check_address
  for the details.

* copy_one_pte vs. discarded pages
  The code that copies the page tables may not copy ptes for discarded
  pages because this races with the discard fault handler. copy_one_pte
  cannot back out either since there is no automatic repeat of the
  fault that caused the pte modification. Ptes to discarded pages only
  show up in copy_one_pte if a fork races with a discard fault. In this
  case copy_one_pte has to create a pte in the new page table that looks
  like the one that the discard fault handler would have created in the
  original page table if copy_one_pte would not have grabed the page
  table lock first.

* get_user_pages with FOLL_GET
  If get_user_pages is called with a non-NULL pages argument the caller
  has to be able to access the page content using the references
  returned in the pages array. This is done with a check in follow_page
  for the FOLL_GET bit and a call to page_make_stable.
  If get_user_pages is called with NULL as the pages argument the
  pages are not made stable. The caller cannot expect that the pages 
  are available after the call because vmscan might have removed them.

* buffer heads / page_private
  A page that is modified with sys_write will get a buffer-head to
  keep track of the dirty state. The existence of a buffer-head makes
  PagePrivate(page) return true. Pages with private information cannot
  be made volatile. Until the buffer-head is removed the page will
  stay stable. The standard logic is to call try_to_release_page which
  frees the buffer-head only if more than 10% of GFP_USER memory are
  used for buffer heads. Without high memory every page can have a
  buffer-head without running over the limit. The result is that every
  page written to with sys_write will stay stable until it is removed.
  To get these pages volatile again max_buffer_heads is set to zero (!)
  to force a call to try_to_release_page whenever a page is moved from
  the active to the inactive list.

* page_free_discarded hook
  The architecture might want/need to do special things for discarded
  pages before they are freed. E.g. s390 has to delay the freeing of
  discarded pages. To allow this a hook in added to free_hot_cold_page.

Another noticable change is that the first few lines of code in
try_to_unmap_one that calculates the address from the page and the vma
is moved out of try_to_unmap_one to the callers. This is done to make
try_to_unmap_one usable for the removal of discarded pages in
page_unmap_all.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 fs/buffer.c                 |   12 ++
 include/linux/mm.h          |    1 
 include/linux/page-flags.h  |   13 ++
 include/linux/page-states.h |  120 ++++++++++++++++++++++++++
 include/linux/pagemap.h     |    6 +
 mm/Makefile                 |    1 
 mm/filemap.c                |   78 ++++++++++++++++-
 mm/memory.c                 |   55 ++++++++++++
 mm/page-states.c            |  197 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c         |    5 -
 mm/page_alloc.c             |   14 ++-
 mm/rmap.c                   |   93 ++++++++++++++++++--
 mm/swap.c                   |   14 +++
 mm/vmscan.c                 |   63 ++++++++++----
 14 files changed, 638 insertions(+), 34 deletions(-)

diff -urpN linux-2.6/fs/buffer.c linux-2.6-patched/fs/buffer.c
--- linux-2.6/fs/buffer.c	2007-05-22 09:49:49.000000000 +0200
+++ linux-2.6-patched/fs/buffer.c	2007-06-28 18:19:43.000000000 +0200
@@ -2949,11 +2949,23 @@ void __init buffer_init(void)
 	bh_cachep = KMEM_CACHE(buffer_head,
 			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
 
+#ifdef CONFIG_PAGE_STATES
+	/*
+	 * If volatile page cache is enabled we want to get as many
+	 * pages into volatile state as possible. Pages with private
+	 * information cannot be made stable. Set max_buffer_heads
+	 * to zero to make shrink_active_list to release the private
+	 * information when moving page from the active to the inactive
+	 * list.
+	 */
+	max_buffer_heads = 0;
+#else
 	/*
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL
 	 */
 	nrpages = (nr_free_buffer_pages() * 10) / 100;
 	max_buffer_heads = nrpages * (PAGE_SIZE / sizeof(struct buffer_head));
+#endif
 	hotcpu_notifier(buffer_cpu_notify, 0);
 }
 
diff -urpN linux-2.6/include/linux/mm.h linux-2.6-patched/include/linux/mm.h
--- linux-2.6/include/linux/mm.h	2007-06-22 14:11:55.000000000 +0200
+++ linux-2.6-patched/include/linux/mm.h	2007-06-28 18:19:43.000000000 +0200
@@ -302,6 +302,7 @@ static inline void init_page_count(struc
 }
 
 void put_page(struct page *page);
+void put_page_check(struct page *page);
 void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
diff -urpN linux-2.6/include/linux/page-flags.h linux-2.6-patched/include/linux/page-flags.h
--- linux-2.6/include/linux/page-flags.h	2007-05-08 09:23:16.000000000 +0200
+++ linux-2.6-patched/include/linux/page-flags.h	2007-06-28 18:19:43.000000000 +0200
@@ -104,6 +104,8 @@
 #define PG_uncached		31	/* Page has been mapped as uncached */
 #endif
 
+#define PG_discarded		20	/* Page discarded by the hypervisor. */
+
 /*
  * Manipulation of page state flags
  */
@@ -270,6 +272,17 @@ static inline void __ClearPageTail(struc
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#ifdef CONFIG_PAGE_STATES
+#define PageDiscarded(page)	test_bit(PG_discarded, &(page)->flags)
+#define ClearPageDiscarded(page) clear_bit(PG_discarded, &(page)->flags)
+#define TestSetPageDiscarded(page) \
+		test_and_set_bit(PG_discarded, &(page)->flags)
+#else
+#define PageDiscarded(page)		0
+#define ClearPageDiscarded(page)	do { } while (0)
+#define TestSetPageDiscarded(page)	0
+#endif
+
 struct page;	/* forward declaration */
 
 extern void cancel_dirty_page(struct page *page, unsigned int account_size);
diff -urpN linux-2.6/include/linux/pagemap.h linux-2.6-patched/include/linux/pagemap.h
--- linux-2.6/include/linux/pagemap.h	2007-05-09 09:58:16.000000000 +0200
+++ linux-2.6-patched/include/linux/pagemap.h	2007-06-28 18:19:43.000000000 +0200
@@ -12,6 +12,7 @@
 #include <asm/uaccess.h>
 #include <linux/gfp.h>
 #include <linux/bitops.h>
+#include <linux/page-states.h>
 
 /*
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
@@ -59,7 +60,11 @@ static inline void mapping_set_gfp_mask(
 #define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
 
 #define page_cache_get(page)		get_page(page)
+#ifdef CONFIG_PAGE_STATES
+#define page_cache_release(page)	put_page_check(page)
+#else
 #define page_cache_release(page)	put_page(page)
+#endif
 void release_pages(struct page **pages, int nr, int cold);
 
 #ifdef CONFIG_NUMA
@@ -136,6 +141,7 @@ int add_to_page_cache_lru(struct page *p
 				unsigned long index, gfp_t gfp_mask);
 extern void remove_from_page_cache(struct page *page);
 extern void __remove_from_page_cache(struct page *page);
+extern void __remove_from_page_cache_nocheck(struct page *page);
 
 /*
  * Return byte-offset into filesystem object for page.
diff -urpN linux-2.6/include/linux/page-states.h linux-2.6-patched/include/linux/page-states.h
--- linux-2.6/include/linux/page-states.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6-patched/include/linux/page-states.h	2007-06-28 18:19:43.000000000 +0200
@@ -0,0 +1,120 @@
+#ifndef _LINUX_PAGE_STATES_H
+#define _LINUX_PAGE_STATES_H
+
+/*
+ * include/linux/page-states.h
+ *
+ * Copyright IBM Corp. 2005, 2007
+ *
+ * Authors: Martin Schwidefsky <schwidefsky@de.ibm.com>
+ *          Hubertus Franke <frankeh@watson.ibm.com>
+ *          Himanshu Raj <rhim@cc.gatech.edu>
+ */
+
+#include <linux/pagevec.h>
+
+#ifdef CONFIG_PAGE_STATES
+/*
+ * Guest page hinting primitives that need to be defined in the
+ * architecture header file if PAGE_STATES=y:
+ * - page_host_discards:
+ *     Indicates whether the host system discards guest pages or not.
+ * - page_set_unused:
+ *     Indicates to the host that the page content is of no interest
+ *     to the guest. The host can "forget" the page content and replace
+ *     it with a page containing zeroes.
+ * - page_set_stable:
+ *     Indicate to the host that the page content is needed by the guest.
+ * - page_set_volatile:
+ *     Make the page discardable by the host. Instead of writing the
+ *     page to the hosts swap device, the host can remove the page.
+ *     A guest that accesses such a discarded page gets a special
+ *     discard fault.
+ * - page_set_stable_if_present:
+ *     The page state is set to stable if the page has not been discarded
+ *     by the host. The check and the state change have to be done
+ *     atomically.
+ * - page_discarded:
+ *     Returns true if the page has been discarded by the host.
+ * - page_test_set_state_change:
+ *     Tries to lock the page for state change. The primitive does not need
+ *     to have page granularity, it can lock a range of pages.
+ * - page_clear_state_change:
+ *     Unlocks a page for state changes.
+ * - page_state_change:
+ *     Returns true if the page is locked for state change.
+ * - page_free_discarded:
+ *     Free a discarded page. This might require to put the page on a
+ *     discard list and a synchronization over all cpus. Returns true
+ *     if the architecture backend wants to do special things on free.
+ */
+#include <asm/page-states.h>
+
+extern void page_unmap_all(struct page *page);
+extern void page_discard(struct page *page);
+extern int  __page_make_stable(struct page *page);
+extern void __page_make_volatile(struct page *page, int offset);
+extern void __pagevec_make_volatile(struct pagevec *pvec);
+
+/*
+ * Extended guest page hinting functions defined by using the
+ * architecture primitives:
+ * - page_make_stable:
+ *     Tries to make a page stable. This operation can fail if the
+ *     host has discarded a page. The function returns != 0 if the
+ *     page could not be made stable.
+ * - page_make_volatile:
+ *     Tries to make a page volatile. There are a number of conditions
+ *     that prevent a page from becoming volatile. If at least one
+ *     is true the function does nothing. See mm/page-states.c for
+ *     details.
+ * - pagevec_make_volatile:
+ *     Tries to make a vector of pages volatile. For each page in the
+ *     vector the same conditions apply as for page_make_volatile.
+ * - page_discard:
+ *     Removes a discarded page from the system. The page is removed
+ *     from the LRU list and the radix tree of its mapping.
+ *     page_discard uses page_unmap_all to remove all page table
+ *     entries for a page.
+ */
+
+static inline int page_make_stable(struct page *page)
+{
+	return page_host_discards() ? __page_make_stable(page) : 1;
+}
+
+static inline void page_make_volatile(struct page *page, int offset)
+{
+	if (page_host_discards())
+		__page_make_volatile(page, offset);
+}
+
+static inline void pagevec_make_volatile(struct pagevec *pvec)
+{
+	if (page_host_discards())
+		__pagevec_make_volatile(pvec);
+}
+
+#else
+
+#define page_host_discards()			(0)
+#define page_set_unused(_page,_order)		do { } while (0)
+#define page_set_stable(_page,_order)		do { } while (0)
+#define page_set_volatile(_page)		do { } while (0)
+#define page_set_stable_if_present(_page)	(1)
+#define page_discarded(_page)			(0)
+
+#define page_test_set_state_change(_page)	(0)
+#define page_clear_state_change(_page)		do { } while (0)
+#define page_state_change(_page)		(0)
+
+#define page_free_discarded(_page)		(0)
+
+#define page_make_stable(_page)			(1)
+#define page_make_volatile(_page, offset)	do { } while (0)
+#define pagevec_make_volatile(_pagevec)	do { } while (0)
+#define page_discard(_page)			do { } while (0)
+
+#endif
+
+#endif /* _LINUX_PAGE_STATES_H */
diff -urpN linux-2.6/mm/filemap.c linux-2.6-patched/mm/filemap.c
--- linux-2.6/mm/filemap.c	2007-05-17 16:24:56.000000000 +0200
+++ linux-2.6-patched/mm/filemap.c	2007-06-28 18:19:43.000000000 +0200
@@ -30,6 +30,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
+#include <linux/page-states.h>
 #include "filemap.h"
 #include "internal.h"
 
@@ -112,7 +113,7 @@ generic_file_direct_IO(int rw, struct ki
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.  The caller must hold a write_lock on the mapping's tree_lock.
  */
-void __remove_from_page_cache(struct page *page)
+void inline __remove_from_page_cache_nocheck(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 
@@ -122,6 +123,28 @@ void __remove_from_page_cache(struct pag
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 }
 
+void __remove_from_page_cache(struct page *page)
+{
+	/*
+	 * Check if the discard fault handler already removed
+	 * the page from the page cache. If not set the discard
+	 * bit in the page flags to prevent double page free if
+	 * a discard fault is racing with normal page free.
+	 */
+	if (TestSetPageDiscarded(page))
+		return;
+
+	__remove_from_page_cache_nocheck(page);
+
+	/*
+	 * Check the hardware page state and clear the discard
+	 * bit in the page flags only if the page is not
+	 * discarded.
+	 */
+	if (!page_discarded(page))
+		ClearPageDiscarded(page);
+}
+
 void remove_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
@@ -536,6 +559,7 @@ void fastcall unlock_page(struct page *p
 	if (!TestClearPageLocked(page))
 		BUG();
 	smp_mb__after_clear_bit(); 
+	page_make_volatile(page, 1);
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
@@ -601,6 +625,14 @@ struct page * find_get_page(struct addre
 	if (page)
 		page_cache_get(page);
 	read_unlock_irq(&mapping->tree_lock);
+	if (page && unlikely(!page_make_stable(page))) {
+		/*
+		 * The page has been discarded by the host. Run the
+		 * discard handler and return NULL.
+		 */
+		page_discard(page);
+		page = NULL;
+	}
 	return page;
 }
 EXPORT_SYMBOL(find_get_page);
@@ -625,7 +657,15 @@ repeat:
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page) {
 		page_cache_get(page);
-		if (TestSetPageLocked(page)) {
+		if (unlikely(!page_make_stable(page))) {
+			/*
+			 * The page has been discarded by the host. Run the
+			 * discard handler and return NULL.
+			 */
+			read_unlock_irq(&mapping->tree_lock);
+			page_discard(page);
+			return NULL;
+		} else if (TestSetPageLocked(page)) {
 			read_unlock_irq(&mapping->tree_lock);
 			__lock_page(page);
 			read_lock_irq(&mapping->tree_lock);
@@ -711,11 +751,24 @@ unsigned find_get_pages(struct address_s
 	unsigned int i;
 	unsigned int ret;
 
+repeat:
 	read_lock_irq(&mapping->tree_lock);
 	ret = radix_tree_gang_lookup(&mapping->page_tree,
 				(void **)pages, start, nr_pages);
-	for (i = 0; i < ret; i++)
+	for (i = 0; i < ret; i++) {
 		page_cache_get(pages[i]);
+		if (likely(page_make_stable(pages[i])))
+			continue;
+		/*
+		 * Make stable failed, we discard the page and retry the
+		 * whole operation.
+		 */
+		read_unlock_irq(&mapping->tree_lock);
+		page_discard(pages[i]);
+		while (i--)
+			page_cache_release(pages[i]);
+		goto repeat;
+	}
 	read_unlock_irq(&mapping->tree_lock);
 	return ret;
 }
@@ -770,11 +823,24 @@ unsigned find_get_pages_tag(struct addre
 	unsigned int i;
 	unsigned int ret;
 
+repeat:
 	read_lock_irq(&mapping->tree_lock);
 	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
 				(void **)pages, *index, nr_pages, tag);
-	for (i = 0; i < ret; i++)
+	for (i = 0; i < ret; i++) {
 		page_cache_get(pages[i]);
+		if (likely(page_make_stable(pages[i])))
+			continue;
+		/*
+		 * Make stable failed, we discard the page and retry the
+		 * whole operation.
+		 */
+		read_unlock_irq(&mapping->tree_lock);
+		page_discard(pages[i]);
+		while (i--)
+			page_cache_release(pages[i]);
+		goto repeat;
+	}
 	if (ret)
 		*index = pages[ret - 1]->index + 1;
 	read_unlock_irq(&mapping->tree_lock);
@@ -1502,8 +1568,10 @@ page_not_uptodate:
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate(page)) {
+			page_make_volatile(page, 2);
 			goto success;
+		}
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
 		goto retry_find;
diff -urpN linux-2.6/mm/Makefile linux-2.6-patched/mm/Makefile
--- linux-2.6/mm/Makefile	2007-05-08 09:23:16.000000000 +0200
+++ linux-2.6-patched/mm/Makefile	2007-06-28 18:19:43.000000000 +0200
@@ -31,4 +31,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_PAGE_STATES) += page-states.o
 
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2007-06-28 18:19:43.000000000 +0200
@@ -50,6 +50,7 @@
 #include <linux/delayacct.h>
 #include <linux/init.h>
 #include <linux/writeback.h>
+#include <linux/page-states.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -480,6 +481,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
 
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
+		if (unlikely(PageDiscarded(page)))
+			goto out_discard_pte;
 		get_page(page);
 		page_dup_rmap(page, vma, addr);
 		rss[!!PageAnon(page)]++;
@@ -487,6 +490,21 @@ copy_one_pte(struct mm_struct *dst_mm, s
 
 out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
+	return;
+
+out_discard_pte:
+	/*
+	 * If the page referred by the pte has the PG_discarded bit set,
+	 * copy_one_pte is racing with page_discard. The pte may not be
+	 * copied or we can end up with a pte pointing to a page not
+	 * in page cache anymore. Do what try_to_unmap_one would do
+	 * if the copy_one_pte had taken place before page_discard.
+	 */
+	if (page->index != linear_page_index(vma, addr))
+		/* If nonlinear, store the file page offset in the pte. */
+		set_pte_at(dst_mm, addr, dst_pte, pgoff_to_pte(page->index));
+	else
+		pte_clear(dst_mm, addr, dst_pte);
 }
 
 static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
@@ -951,6 +969,19 @@ struct page *follow_page(struct vm_area_
 
 	if (flags & FOLL_GET)
 		get_page(page);
+
+	if (flags & FOLL_GET) {
+		/*
+		 * The page is made stable if a reference is acquired.
+		 * If the caller does not get a reference it implies that
+		 * the caller can deal with page faults in case the page
+		 * is swapped out. In this case the caller can deal with
+		 * discard faults as well.
+		 */
+		if (unlikely(!page_make_stable(page)))
+			goto out_discard;
+	}
+
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
@@ -974,6 +1005,11 @@ no_page_table:
 		BUG_ON(flags & FOLL_WRITE);
 	}
 	return page;
+
+out_discard:
+	pte_unmap_unlock(ptep, ptl);
+	page_discard(page);
+	return NULL;
 }
 
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
@@ -1685,6 +1721,11 @@ static int do_wp_page(struct mm_struct *
 		dirty_page = old_page;
 		get_page(dirty_page);
 		reuse = 1;
+		/*
+		 * dirty_page will be set dirty, so it needs to be stable.
+		 */
+		if (unlikely(!page_make_stable(dirty_page)))
+			goto discard;
 	}
 
 	if (reuse) {
@@ -1703,6 +1744,12 @@ static int do_wp_page(struct mm_struct *
 	 * Ok, we need to copy. Oh, well..
 	 */
 	page_cache_get(old_page);
+	/*
+	 * To copy the content of old_page it needs to be stable.
+	 * page_cache_release on old_page will make it volatile again.
+	 */
+	if (unlikely(!page_make_stable(old_page)))
+		goto discard;
 gotten:
 	pte_unmap_unlock(page_table, ptl);
 
@@ -1771,6 +1818,10 @@ oom:
 unwritable_page:
 	page_cache_release(old_page);
 	return VM_FAULT_SIGBUS;
+discard:
+	pte_unmap_unlock(page_table, ptl);
+	page_discard(old_page);
+	return VM_FAULT_MINOR;
 }
 
 /*
@@ -2334,6 +2385,10 @@ retry:
 
 			if (unlikely(anon_vma_prepare(vma)))
 				goto oom;
+			if (unlikely(!page_make_stable(new_page))) {
+				page_discard(new_page);
+				goto retry;
+			}
 			page = alloc_page_vma(GFP_HIGHUSER, vma, address);
 			if (!page)
 				goto oom;
diff -urpN linux-2.6/mm/page_alloc.c linux-2.6-patched/mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c	2007-06-18 09:43:22.000000000 +0200
+++ linux-2.6-patched/mm/page_alloc.c	2007-06-28 18:19:43.000000000 +0200
@@ -41,6 +41,7 @@
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
+#include <linux/page-states.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -206,7 +207,8 @@ static void bad_page(struct page *page)
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_buddy );
+			1 << PG_buddy |
+			1 << PG_discarded );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -508,6 +510,7 @@ static void __free_pages_ok(struct page 
 		reserved += free_pages_check(page + i);
 	if (reserved)
 		return;
+	page_set_unused(page, order);
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page),PAGE_SIZE<<order);
@@ -781,10 +784,16 @@ static void fastcall free_hot_cold_page(
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
+	if (unlikely(PageDiscarded(page))) {
+		if (page_free_discarded(page))
+			return;
+	}
+
 	if (PageAnon(page))
 		page->mapping = NULL;
 	if (free_pages_check(page))
 		return;
+	page_set_unused(page, 0);
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
@@ -875,6 +884,7 @@ again:
 	put_cpu();
 
 	VM_BUG_ON(bad_range(zone, page));
+	page_set_stable(page, order);
 	if (prep_new_page(page, order, gfp_flags))
 		goto again;
 	return page;
@@ -1417,6 +1427,8 @@ void __pagevec_free(struct pagevec *pvec
 
 fastcall void __free_pages(struct page *page, unsigned int order)
 {
+	if (page_count(page) > 1)
+		page_make_volatile(page, 2);
 	if (put_page_testzero(page)) {
 		if (order == 0)
 			free_hot_page(page);
diff -urpN linux-2.6/mm/page-states.c linux-2.6-patched/mm/page-states.c
--- linux-2.6/mm/page-states.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6-patched/mm/page-states.c	2007-06-28 18:19:43.000000000 +0200
@@ -0,0 +1,197 @@
+/*
+ * mm/page-states.c
+ *
+ * (C) Copyright IBM Corp. 2005, 2007
+ *
+ * Guest page hinting functions.
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
+#include <linux/pagevec.h>
+#include <linux/page-states.h>
+
+#include "internal.h"
+
+/*
+ * Check if there is anything in the page flags or the mapping
+ * that prevents the page from changing its state to volatile.
+ */
+static inline int check_bits(struct page *page)
+{
+	/*
+	 * There are several conditions that prevent a page from becoming
+	 * volatile. The first check is for the page bits.
+	 */
+	if (PageDirty(page) || PageReserved(page) || PageWriteback(page) ||
+	    PageLocked(page) || PagePrivate(page) || PageDiscarded(page) ||
+	    !PageUptodate(page) || !PageLRU(page) || PageAnon(page))
+		return 0;
+
+	/*
+	 * If the page has been truncated there is no point in making
+	 * it volatile. It will be freed soon. And if the mapping ever
+	 * had locked pages all pages of the mapping will stay stable.
+	 */
+	return page_mapping(page) != NULL;
+}
+
+/*
+ * Check the reference counter of the page against the number of
+ * mappings. The caller passes an offset, that is the number of
+ * extra, known references. The page cache itself is one extra
+ * reference. If the caller acquired an additional reference then
+ * the offset would be 2. If the page map counter is equal to the
+ * page count minus the offset then there is no other, unknown
+ * user of the page in the system.
+ */
+static inline int check_counts(struct page *page, unsigned int offset)
+{
+	return page_mapcount(page) + offset == page_count(page);
+}
+
+/*
+ * Attempts to change the state of a page to volatile.
+ * If there is something preventing the state change the page stays
+ * int its current state.
+ */
+void __page_make_volatile(struct page *page, int offset)
+{
+	preempt_disable();
+	if (!page_test_set_state_change(page)) {
+		if (check_bits(page) && check_counts(page, offset))
+			page_set_volatile(page);
+		page_clear_state_change(page);
+	}
+	preempt_enable();
+}
+EXPORT_SYMBOL(__page_make_volatile);
+
+/*
+ * Attempts to change the state of a vector of pages to volatile.
+ * If there is something preventing the state change the page stays
+ * int its current state.
+ */
+void __pagevec_make_volatile(struct pagevec *pvec)
+{
+	struct page *page;
+	int i = pagevec_count(pvec);
+
+	while (--i >= 0) {
+		/*
+		 * If we can't get the state change bit just give up.
+		 * The worst that can happen is that the page will stay
+		 * in the stable state although it might be volatile.
+		 */
+		page = pvec->pages[i];
+		if (!page_test_set_state_change(page)) {
+			if (check_bits(page) && check_counts(page, 1))
+				page_set_volatile(page);
+			page_clear_state_change(page);
+		}
+	}
+}
+EXPORT_SYMBOL(__pagevec_make_volatile);
+
+/*
+ * Attempts to change the state of a page to stable. The host could
+ * have removed a volatile page, the page_set_stable_if_present call
+ * can fail.
+ *
+ * returns "0" on success and "1" on failure
+ */
+int __page_make_stable(struct page *page)
+{
+	/*
+	 * Postpone state change to stable until the state change bit is
+	 * cleared. As long as the state change bit is set another cpu
+	 * is in page_make_volatile for this page. That makes sure that
+	 * no caller of make_stable "overtakes" a make_volatile leaving
+	 * the page in volatile where stable is required.
+	 * The caller of make_stable need to make sure that no caller
+	 * of make_volatile can make the page volatile right after
+	 * make_stable has finished.
+	 */
+	while (page_state_change(page))
+		cpu_relax();
+	return page_set_stable_if_present(page);
+}
+EXPORT_SYMBOL(__page_make_stable);
+
+/**
+ * __page_discard() - remove a discarded page from the cache
+ *
+ * @page: the page
+ *
+ * The page passed to this function needs to be locked.
+ */
+static void __page_discard(struct page *page)
+{
+	struct address_space *mapping;
+	struct zone *zone;
+
+	/* Paranoia checks. */
+	VM_BUG_ON(PageWriteback(page));
+	VM_BUG_ON(PageDirty(page));
+	VM_BUG_ON(PagePrivate(page));
+
+	/* Set the discarded bit early. */
+	if (TestSetPageDiscarded(page))
+		return;
+
+	/* Unmap the page from all page tables. */
+	page_unmap_all(page);
+
+	/* Check if really all mappers of this page are gone. */
+	VM_BUG_ON(page_mapcount(page) != 0);
+
+	/*
+	 * Remove the page from LRU if it is currently added.
+	 * The users of isolate_lru_pages need to check the
+	 * discarded bit before readding the page to the LRU.
+	 */
+	zone = page_zone(page);
+	spin_lock_irq(&zone->lru_lock);
+	if (PageLRU(page)) {
+		/* Unlink page from lru. */
+		__ClearPageLRU(page);
+		del_page_from_lru(zone, page);
+	}
+	spin_unlock_irq(&zone->lru_lock);
+
+	/* We can't handle swap cache pages (yet). */
+	VM_BUG_ON(PageSwapCache(page));
+
+	/* Remove page from page cache. */
+ 	mapping = page->mapping;
+	write_lock_irq(&mapping->tree_lock);
+	__remove_from_page_cache_nocheck(page);
+	write_unlock_irq(&mapping->tree_lock);
+	__put_page(page);
+}
+
+/**
+ * page_discard() - remove a discarded page from the cache
+ *
+ * @page: the page
+ *
+ * Before calling this function an additional page reference needs to
+ * be acquired. This reference is released by the function.
+ */
+void page_discard(struct page *page)
+{
+	lock_page(page);
+	__page_discard(page);
+	unlock_page(page);
+	page_cache_release(page);
+}
+EXPORT_SYMBOL(page_discard);
diff -urpN linux-2.6/mm/page-writeback.c linux-2.6-patched/mm/page-writeback.c
--- linux-2.6/mm/page-writeback.c	2007-05-12 20:16:11.000000000 +0200
+++ linux-2.6-patched/mm/page-writeback.c	2007-06-28 18:19:43.000000000 +0200
@@ -33,6 +33,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
+#include <linux/page-states.h>
 
 /*
  * The maximum number of pages to writeout in a single bdflush/kupdate
@@ -972,10 +973,12 @@ int test_clear_page_writeback(struct pag
 
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestClearPageWriteback(page);
-		if (ret)
+		if (ret) {
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
+			page_make_volatile(page, 1);
+		}
 		write_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestClearPageWriteback(page);
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2007-05-17 16:24:56.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2007-06-28 18:19:43.000000000 +0200
@@ -48,6 +48,7 @@
 #include <linux/rcupdate.h>
 #include <linux/module.h>
 #include <linux/kallsyms.h>
+#include <linux/page-states.h>
 
 #include <asm/tlbflush.h>
 
@@ -268,13 +269,24 @@ pte_t *page_check_address(struct page *p
 		return NULL;
 
 	pte = pte_offset_map(pmd, address);
+	ptl = pte_lockptr(mm, pmd);
 	/* Make a quick check before getting the lock */
+#ifndef CONFIG_PAGE_STATES
+	/*
+	 * If the page table lock for this pte is taken we have to
+	 * assume that someone might be mapping the page. To solve
+	 * the race of a page discard vs. mapping the page we have
+	 * to serialize the two operations by taking the lock,
+	 * otherwise we end up with a pte for a page that has been
+	 * removed from page cache by the discard fault handler.
+	 */
+	if (!spin_is_locked(ptl))
+#endif
 	if (!pte_present(*pte)) {
 		pte_unmap(pte);
 		return NULL;
 	}
 
-	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
 	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
 		*ptlp = ptl;
@@ -605,6 +617,7 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount))
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
+	page_make_volatile(page, 1);
 }
 
 #ifdef CONFIG_DEBUG_VM
@@ -673,19 +686,14 @@ void page_remove_rmap(struct page *page,
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
@@ -750,8 +758,14 @@ static int try_to_unmap_one(struct page 
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
 #endif
+	{
+#ifdef CONFIG_PAGE_STATES
+		/* If nonlinear, store the file page offset in the pte. */
+		if (page->index != linear_page_index(vma, address))
+			set_pte_at(mm, address, pte, pgoff_to_pte(page->index));
+#endif
 		dec_mm_counter(mm, file_rss);
-
+	}
 
 	page_remove_rmap(page, vma);
 	page_cache_release(page);
@@ -855,6 +869,7 @@ static int try_to_unmap_anon(struct page
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
+	unsigned long address;
 	int ret = SWAP_AGAIN;
 
 	anon_vma = page_lock_anon_vma(page);
@@ -862,7 +877,10 @@ static int try_to_unmap_anon(struct page
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
@@ -887,6 +905,7 @@ static int try_to_unmap_file(struct page
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int ret = SWAP_AGAIN;
+	unsigned long address;
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
@@ -894,7 +913,10 @@ static int try_to_unmap_file(struct page
 
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
@@ -995,3 +1017,54 @@ int try_to_unmap(struct page *page, int 
 	return ret;
 }
 
+#ifdef CONFIG_PAGE_STATES
+
+/**
+ * page_unmap_all - removes all mappings of a page
+ *
+ * @page: the page which mapping in the vma should be struck down
+ *
+ * the caller needs to hold page lock
+ */
+void page_unmap_all(struct page* page)
+{
+	struct address_space *mapping = page_mapping(page);
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	unsigned long address;
+	int rc;
+
+	VM_BUG_ON(!PageLocked(page) || PageReserved(page) || PageAnon(page));
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		address = vma_address(page, vma);
+		if (address == -EFAULT)
+			continue;
+		rc = try_to_unmap_one(page, vma, address, 0);
+		VM_BUG_ON(rc == SWAP_FAIL);
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
+			rc = try_to_unmap_one(page, vma, address, 0);
+			VM_BUG_ON(rc == SWAP_FAIL);
+			address += PAGE_SIZE;
+		}
+	}
+
+out:
+	spin_unlock(&mapping->i_mmap_lock);
+}
+
+#endif
diff -urpN linux-2.6/mm/swap.c linux-2.6-patched/mm/swap.c
--- linux-2.6/mm/swap.c	2007-05-10 09:32:11.000000000 +0200
+++ linux-2.6-patched/mm/swap.c	2007-06-28 18:19:43.000000000 +0200
@@ -30,6 +30,7 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/init.h>
+#include <linux/page-states.h>
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
@@ -73,6 +74,16 @@ void put_page(struct page *page)
 }
 EXPORT_SYMBOL(put_page);
 
+#ifdef CONFIG_PAGE_STATES
+void put_page_check(struct page *page)
+{
+	if (page_count(page) > 1)
+		page_make_volatile(page, 2);
+	put_page(page);
+}
+EXPORT_SYMBOL(put_page_check);
+#endif
+
 /**
  * put_pages_list(): release a list of pages
  *
@@ -337,6 +348,8 @@ void __pagevec_release_nonlru(struct pag
 		struct page *page = pvec->pages[i];
 
 		VM_BUG_ON(PageLRU(page));
+		if (page_count(page) > 1)
+			page_make_volatile(page, 2);
 		if (put_page_testzero(page))
 			pagevec_add(&pages_to_free, page);
 	}
@@ -366,6 +379,7 @@ void __pagevec_lru_add(struct pagevec *p
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		add_page_to_inactive_list(zone, page);
+		page_make_volatile(page, 2);
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
diff -urpN linux-2.6/mm/vmscan.c linux-2.6-patched/mm/vmscan.c
--- linux-2.6/mm/vmscan.c	2007-05-10 09:32:11.000000000 +0200
+++ linux-2.6-patched/mm/vmscan.c	2007-06-28 18:19:43.000000000 +0200
@@ -37,6 +37,7 @@
 #include <linux/delay.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
+#include <linux/page-states.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -699,13 +700,20 @@ static unsigned long shrink_inactive_lis
 		 */
 		while (!list_empty(&page_list)) {
 			page = lru_to_page(&page_list);
-			VM_BUG_ON(PageLRU(page));
-			SetPageLRU(page);
 			list_del(&page->lru);
-			if (PageActive(page))
-				add_page_to_active_list(zone, page);
-			else
-				add_page_to_inactive_list(zone, page);
+			/*
+			 * Only readd the page to lru list if it has not
+			 * been discarded.
+			 */
+			if (likely(!PageDiscarded(page))) {
+				VM_BUG_ON(PageLRU(page));
+				SetPageLRU(page);
+				if (PageActive(page))
+					add_page_to_active_list(zone, page);
+				else
+					add_page_to_inactive_list(zone, page);
+			} else
+				ClearPageActive(page);
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -846,13 +854,22 @@ force_reclaim_mapped:
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		VM_BUG_ON(!PageActive(page));
-		ClearPageActive(page);
+		/*
+		 * Only readd the page to lru list if it has not
+		 * been discarded.
+		 */
+		if (likely(!PageDiscarded(page))) {
+			VM_BUG_ON(PageLRU(page));
+			SetPageLRU(page);
+			VM_BUG_ON(!PageActive(page));
+			ClearPageActive(page);
+			list_move(&page->lru, &zone->inactive_list);
+			pgmoved++;
+		} else {
+			ClearPageActive(page);
+			list_del(&page->lru);
+		}
 
-		list_move(&page->lru, &zone->inactive_list);
-		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
@@ -860,6 +877,7 @@ force_reclaim_mapped:
 			pgmoved = 0;
 			if (buffer_heads_over_limit)
 				pagevec_strip(&pvec);
+			pagevec_make_volatile(&pvec);
 			__pagevec_release(&pvec);
 			spin_lock_irq(&zone->lru_lock);
 		}
@@ -869,6 +887,7 @@ force_reclaim_mapped:
 	if (buffer_heads_over_limit) {
 		spin_unlock_irq(&zone->lru_lock);
 		pagevec_strip(&pvec);
+		pagevec_make_volatile(&pvec);
 		spin_lock_irq(&zone->lru_lock);
 	}
 
@@ -876,11 +895,21 @@ force_reclaim_mapped:
 	while (!list_empty(&l_active)) {
 		page = lru_to_page(&l_active);
 		prefetchw_prev_lru_page(page, &l_active, flags);
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		VM_BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->active_list);
-		pgmoved++;
+		/*
+		 * Only readd the page to lru list if it has not
+		 * been discarded.
+		 */
+		if (likely(!PageDiscarded(page))) {
+			VM_BUG_ON(PageLRU(page));
+			SetPageLRU(page);
+			VM_BUG_ON(!PageActive(page));
+			list_move(&page->lru, &zone->active_list);
+			pgmoved++;
+		} else {
+			ClearPageActive(page);
+			list_del(&page->lru);
+		}
+
 		if (!pagevec_add(&pvec, page)) {
 			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
 			pgmoved = 0;

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
