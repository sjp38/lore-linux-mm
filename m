Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id CB92E6B003A
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:10:30 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id e89so2681506qgf.4
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:30 -0700 (PDT)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id w9si1440303qab.24.2014.08.29.12.10.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 12:10:29 -0700 (PDT)
Received: by mail-qa0-f44.google.com with SMTP id j7so2519603qaq.17
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:29 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [RFC PATCH 2/6] lib: lockless generic and arch independent page table (gpt).
Date: Fri, 29 Aug 2014 15:10:11 -0400
Message-Id: <1409339415-3626-3-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
References: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Haggai Eran <haggaie@mellanox.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Page table is a common structure format most notably use by cpu mmu. The
arch depend page table code has strong tie to the architecture which makes
it unsuitable to be use by other non arch specific code.

This patch implement a generic and arch independent page table. It is generic
in the sense that entry size can be any power of two smaller than PAGE_SIZE
and each entry page size can cover a different power of two then PAGE_SIZE.

It is lockless in the sense that at any point in time you can have concurrent
thread updating the page table (removing or changing entry) and faulting in
the page table (adding new entry). This is achieve by enforcing each updater
and each faulter to take a range lock. There is no exclusion on range lock,
ie several thread can fault or update the same range concurrently and it is
the responsability of the user to synchronize update to the page table entry
(pte), update to the page table directory (pdp) is under gpt responsability.

API usage pattern is :
  gpt_init()

  gpt_lock_update(lock_range)
  // User can update pte for instance by using atomic bit operation
  // allowing complete lockless update.
  gpt_unlock_update(lock_range)

  gpt_lock_fault(lock_range)
  // User can fault in pte but he is responsible for avoiding thread
  // to concurrently fault the same pte and for properly accounting
  // the number of pte faulted in the pdp structure.
  gpt_unlock_fault(lock_range)
  // The new faulted pte will only be visible to others updaters only
  // once all faulter unlock.

Details on how the lockless concurrent updater and faulter works is provided
in the header file.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/gpt.h | 625 ++++++++++++++++++++++++++++++++++++
 lib/Kconfig         |   3 +
 lib/Makefile        |   2 +
 lib/gpt.c           | 897 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 1527 insertions(+)
 create mode 100644 include/linux/gpt.h
 create mode 100644 lib/gpt.c

diff --git a/include/linux/gpt.h b/include/linux/gpt.h
new file mode 100644
index 0000000..192935a
--- /dev/null
+++ b/include/linux/gpt.h
@@ -0,0 +1,625 @@
+/*
+ * Copyright 2014 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/*
+ * High level overview
+ * -------------------
+ *
+ * This is a generic arch independant page table implementation with lockless
+ * (allmost lockless) access. The content of the page table ie the page table
+ * entry, are not protected by the gpt helper, it is up to the code using gpt
+ * to protect the page table entry from concurrent update with no restriction
+ * on the mechanism (can be atomic or can sleep).
+ *
+ * The gpt code only deals with protecting the page directory tree structure.
+ * Which is done in a lockless way. Concurrent threads can read and or write
+ * overlapping range of the gpt. There can also be concurrent insertion and
+ * removal of page directory (insertion or removal of page table level).
+ *
+ * While removal of page directory is completely lockless, insertion of new
+ * page directory still require a lock (to avoid double insertion). If the
+ * architecture have a spinlock in its page struct then several threads can
+ * concurrently insert new directory (level) as long as they are inserting into
+ * different page directory. Otherwise insertion will serialize using a common
+ * spinlock. Note that insertion in this context only refer to inserting page
+ * directory, it does not deal about page table entry insertion and again this
+ * is the responsability of gpt user to properly synchronize those.
+ *
+ *
+ * Each gpt access must be done under gpt lock protection by calling gpt_lock()
+ * with a lock structure. Once a range is "locked" with gpt_lock() all access
+ * can be done in lockless fashion, using either gpt_walk or gpt_iter helpers.
+ * Note however that only directory that are considered as established will be
+ * considered ie if a thread is concurently inserting a new directory in the
+ * locked range then this directory will be ignore by gpt_walk or gpt_iter.
+ *
+ * This restriction comes from the lockless design. Some thread can hold a gpt
+ * lock for long time but if it holds it for a period long enough some of the
+ * internal gpt counter (unsigned long) might wrap around breaking all further
+ * access (thought it is self healing after a period of time). So access
+ * pattern to gpt should be :
+ *   gpt_lock(gpt, lock)
+ *   gpt_walk(gpt, lock, walk)
+ *   gpt_unlock(gpt, lock)
+ *
+ * Walker callback can sleep but for for now longer than it would take for
+ * other thread to wrap around internal gpt value through :
+ *   gpt_lock_fault(gpt, lock)
+ *   // user faulting in new pte
+ *   gpt_unlock_fault(gpt, lock)
+ *
+ * The lockless design refer to gpt_lock() and gpt_unlock() taking a spinlock
+ * only for adding/removing the lock struct to active lock list ie no more than
+ * few instructions in both case leaving little room for lock contention.
+ *
+ * Moreover there is no memory allocation during gpt_lock() or gpt_unlock() or
+ * gpt_walk(). The only constraint is that the lock struct must be the same for
+ * gpt_lock(), gpt_unlock() and gpt_walk() so gpt_lock struct might need to be
+ * allocated. This is however a small struct.
+ *
+ *
+ * Internal of gpt synchronization :
+ * ---------------------------------
+ *
+ * For the curious here is how gpt page directory access are synchronize with
+ * each others.
+ *
+ * Each time a user want to access a range of the gpt it must take a lock on
+ * the range using gpt_lock(). Each lock is associated with a serial number
+ * that is the current serial number for insertion (ie all new page directory
+ * will be assigned this serial number). Each lock holder will take a reference
+ * on each page directory that is older than its serial number (ie each page
+ * directory that are now considered alive).
+ *
+ * So page directory and lock holder form a timeline with following a regular
+ * expression :
+ *   (o*)h((r)*(a)*)*s
+ * With :
+ *   o : old directory page
+ *   h : oldest active lock holder (ie lock holder with the smallest serial
+ *       number)
+ *   r : recent directory page added after oldest lock holder
+ *   a : recent lock holder (ie lock holder with a serial number greater than
+ *       the oldest active lock holder serial number)
+ *   s : current serial number ie the serial number that is use by any thread
+ *       actively adding new page directory.
+ *
+ * So few rules are in place, 's' will only increase once all thread using a
+ * serial number are done inserting new page directory. So new page directory
+ * go into the 'r' state once gpt_unlock_fault() is call.
+ *
+ * Now what is important is to keep the relationship between each lock holder
+ * ('h' and 'a' state) and each recent directory page ('r' state) intact so
+ * that when unlocking only page directory that were referenced by the lock
+ * holder at lock time are unreferenced. This is simple, if page directory
+ * serial number is older that lock serial number then we know that this page
+ * directory was know at lock time and thus was referenced. Otherwise this is
+ * a recent directory page that was unknown (or skip) during lock operation.
+ *
+ * Same rules apply when walking the directory, gpt will only consider page
+ * directory that have an older serial number than the lock serial number.
+ *
+ * There is two issue that needs to be solve. First issue is wrap around of
+ * serial number, it is solve by using unsigned long and the jiffies helpers
+ * for comparing time (simple sign trick).
+ *
+ * However this first issue imply a second one, some page directory might sit
+ * inside the gpt without being visited for a long period so long that the
+ * current serial number wrapped around and is now smaller to this very old
+ * serial number leading to invalid assumption about this page directory.
+ *
+ * Trying to update old serial number is cumberstone and tricky with the lock
+ * less design of gpt. Not to mention this would need to happen at regular
+ * interval.
+ *
+ * Instead the problem can be simplify by noticing that we only care about page
+ * directory that were added after the oldest active lock 'h' everything added
+ * before was know to all gpt lock holder and thus reference. So all is needed
+ * is to keep track of serial number for page directory recently added and move
+ * those page directory to the old status once the oldest active lock serial
+ * number is after there serial number.
+ *
+ * To do this, gpt place new page directory on list, it is naturally sorted as
+ * new page directory are added at the end. Each time gpt_unlock() is call the
+ * new oldest lock serial number is found and the new page directory list is
+ * traversed and entry that are now older than the oldest lock serial number
+ * are remove.
+ *
+ * So if a page directory is not on the recent list then lock holder knows for
+ * sure they have to unreference it during gpt_unlock() or traverse it during
+ * gpt_walk().
+ *
+ * So issue can only happen if a thread hold a lock long enough for the serial
+ * number to wrap around which would block page directory on the recent list
+ * from being properly remove and lead to wrong assumption about how old is a
+ * directory page.
+ *
+ * Page directory removal is easier, each page directory keeps a count of the
+ * number of valid entry they have and number of lock that took a reference
+ * on it. So when this count drop to 0 gpt code knows that no thread is trying
+ * to access this page directory nor this page directory have any valid entry
+ * left thus it can safely be remove. This use atomic counter and rcu read
+ * section for synchronization.
+ */
+#ifndef __LINUX_GPT_H
+#define __LINUX_GPT_H
+
+#include <linux/mm.h>
+#include <asm/types.h>
+
+#ifdef CONFIG_64BIT
+#define GPT_PDIR_NBITS		((unsigned long)PAGE_SHIFT - 3UL)
+#else
+#define GPT_PDIR_NBITS		((unsigned long)PAGE_SHIFT - 2UL)
+#endif
+#define GPT_PDIR_MASK		((1UL << GPT_PDIR_NBITS) - 1UL)
+
+struct gpt;
+struct gpt_lock;
+struct gpt_walk;
+struct gpt_iter;
+
+/* struct gpt_ops - generic page table operations.
+ *
+ * @lock_update: Lock address range for update.
+ * @unlock_update: Unlock address range after update.
+ * @lock_fault: Lock address range for fault.
+ * @unlock_fault: Unlock address range after fault.
+ *
+ * The generic page table use lock hold accross update or fault operation to
+ * synchronize concurrent updater and faulter thread with each other. Because
+ * generic page table is configurable it needs different function depending if
+ * the page table is flat one (ie just one level) or a tree one (ie several
+ * levels).
+ */
+struct gpt_ops {
+	void (*lock_update)(struct gpt *gpt, struct gpt_lock *lock);
+	void (*unlock_update)(struct gpt *gpt, struct gpt_lock *lock);
+	int (*lock_fault)(struct gpt *gpt, struct gpt_lock *lock);
+	void (*unlock_fault)(struct gpt *gpt, struct gpt_lock *lock);
+	int (*walk)(struct gpt_walk *walk,
+		    struct gpt *gpt,
+		    struct gpt_lock *lock);
+	bool (*iter_addr)(struct gpt_iter *iter, unsigned long addr);
+	bool (*iter_first)(struct gpt_iter *iter,
+			   unsigned long start,
+			   unsigned long end);
+};
+
+
+/* struct gpt_user_ops - generic page table user provided operations.
+ *
+ * @pde_from_pdp: Return page directory entry that correspond to a page
+ * directory page. This allow user to use there own custom page directory
+ * entry format for all page directory level.
+ */
+struct gpt_user_ops {
+	unsigned long (*pde_from_pdp)(struct gpt *gpt, struct page *pdp);
+};
+
+
+/* struct gpt - generic page table structure.
+ *
+ * @ops: Generic page table operations.
+ * @user_ops: User provided gpt operation (if null use default implementation).
+ * @pgd: Page global directory if multi level (tree page table).
+ * @pte: Page table entry if single level (flat page table).
+ * @faulters: List of all concurrent fault locks.
+ * @updaters: List of all concurrent update locks.
+ * @pdp_young: List of all young page directory page.
+ * @pdp_free: List of all page directory page to free (delayed free).
+ * @max_addr: Maximum address that can index this page table (inclusive).
+ * @min_serial: Oldest serial number use by the oldest updater.
+ * @updater_serial: Current serial number use for updater.
+ * @faulter_serial: Current serial number use for faulter.
+ * @page_shift: The size as power of two of each table entry.
+ * @pde_size: Size of page directory entry (sizeof(long) for instance).
+ * @pfn_mask: Mask bit significant for page frame number of directory entry.
+ * @pfn_shift: Shift value to get the pfn from a page directory entry.
+ * @pfn_valid: Mask to know if a page directory entry is valid.
+ * @pgd_shift: Shift value to get the index inside the pgd from an address.
+ * @pld_shift: Page lower directory shift. This is shift value for the lowest
+ * page directory ie the page directory containing pfn of page table entry
+ * array. For instance if page_shift is 12 (4096 bytes) and each entry require
+ * 1 bytes then :
+ *   pld_shift = 12 + (PAGE_SHIFT - 0) = 12 + PAGE_SHIFT.
+ * Now if each entry cover 4096 bytes and  each entry require 2 bytes then :
+ *   pld_shift = 12 + (PAGE_SHIFT - 1) = 11 + PAGE_SHIFT.
+ * @pte_mask: Mask bit significant for indexing page table entry (pte) array.
+ * @pte_shift: Size shift for each page table entry (0 if each entry is one
+ * byte, 1 if each entry is 2 bytes, ...).
+ * @lock: Lock protecting serial number and updaters/faulters list.
+ * @pgd_lock: Lock protecting pgd level (and all level if arch do not have room
+ * for spinlock inside its page struct).
+ */
+struct gpt {
+	const struct gpt_ops		*ops;
+	const struct gpt_user_ops	*user_ops;
+	union {
+		unsigned long		*pgd;
+		void			*pte;
+	};
+	struct list_head		faulters;
+	struct list_head		updaters;
+	struct list_head		pdp_young;
+	struct list_head		pdp_free;
+	unsigned long			max_addr;
+	unsigned long			min_serial;
+	unsigned long			faulter_serial;
+	unsigned long			updater_serial;
+	unsigned long			page_shift;
+	unsigned long			pde_size;
+	unsigned long			pfn_invalid;
+	unsigned long			pfn_mask;
+	unsigned long			pfn_shift;
+	unsigned long			pfn_valid;
+	unsigned long			pgd_shift;
+	unsigned long			pld_shift;
+	unsigned long			pte_mask;
+	unsigned long			pte_shift;
+	unsigned			gfp_flags;
+	spinlock_t			lock;
+	spinlock_t			pgd_lock;
+};
+
+void gpt_free(struct gpt *gpt);
+int gpt_init(struct gpt *gpt);
+
+static inline unsigned long gpt_align_start_addr(struct gpt *gpt,
+						 unsigned long addr)
+{
+	return addr & ~((1UL << gpt->page_shift) - 1UL);
+}
+
+static inline unsigned long gpt_align_end_addr(struct gpt *gpt,
+					       unsigned long addr)
+{
+	return addr | ((1UL << gpt->page_shift) - 1UL);
+}
+
+static inline unsigned long gpt_pdp_shift(struct gpt *gpt, struct page *pdp)
+{
+	if (!pdp)
+		return gpt->pgd_shift;
+	return pdp->flags & 0xff;
+}
+
+static inline unsigned long gpt_pdp_start(struct gpt *gpt, struct page *pdp)
+{
+	if (!pdp)
+		return 0UL;
+	return pdp->index;
+}
+
+static inline unsigned long gpt_pdp_end(struct gpt *gpt, struct page *pdp)
+{
+	if (!pdp)
+		return gpt->max_addr;
+	return pdp->index + (1UL << gpt_pdp_shift(gpt, pdp)) - 1UL;
+}
+
+static inline bool gpt_pdp_cover_addr(struct gpt *gpt,
+				      struct page *pdp,
+				      unsigned long addr)
+{
+	return (addr >= gpt_pdp_start(gpt, pdp)) &&
+	       (addr <= gpt_pdp_end(gpt, pdp));
+}
+
+static inline bool gpt_pde_valid(struct gpt *gpt, unsigned long pde)
+{
+	return (pde & gpt->pfn_valid) && !(pde & gpt->pfn_invalid);
+}
+
+static inline struct page *gpt_pde_pdp(struct gpt *gpt,
+				       volatile unsigned long *pde)
+{
+	unsigned long tmp = *pde;
+
+	if (!gpt_pde_valid(gpt, tmp))
+		return NULL;
+
+	return pfn_to_page((tmp & gpt->pfn_mask) >> gpt->pfn_shift);
+}
+
+#if USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS
+static inline void gpt_pdp_lock(struct gpt *gpt, struct page  *pdp)
+{
+	if (pdp)
+		spin_lock(&page->ptl);
+	else
+		spin_lock(&gpt->pgd_lock);
+}
+
+static inline void gpt_pdp_unlock(struct gpt *gpt, struct page  *pdp)
+{
+	if (pdp)
+		spin_unlock(&page->ptl);
+	else
+		spin_unlock(&gpt->pgd_lock);
+}
+#else /* USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS */
+static inline void gpt_pdp_lock(struct gpt *gpt, struct page  *pdp)
+{
+	spin_lock(&gpt->pgd_lock);
+}
+
+static inline void gpt_pdp_unlock(struct gpt *gpt, struct page  *pdp)
+{
+	spin_unlock(&gpt->pgd_lock);
+}
+#endif /* USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS */
+
+static inline void gpt_ptp_ref(struct gpt *gpt, struct page  *ptp)
+{
+	if (ptp)
+		atomic_inc(&ptp->_mapcount);
+}
+
+static inline void gpt_ptp_unref(struct gpt *gpt, struct page  *ptp)
+{
+	if (ptp && atomic_dec_and_test(&ptp->_mapcount))
+		BUG();
+}
+
+static inline void gpt_ptp_batch_ref(struct gpt *gpt, struct page  *ptp, int n)
+{
+	if (ptp)
+		atomic_add(n, &ptp->_mapcount);
+}
+
+static inline void gpt_ptp_batch_unref(struct gpt *gpt,
+				       struct page  *ptp,
+				       int n)
+{
+	if (ptp && atomic_sub_and_test(n, &ptp->_mapcount))
+		BUG();
+}
+
+static inline void *gpt_ptp_pte(struct gpt *gpt, struct page *ptp)
+{
+	if (!ptp)
+		return gpt->pte;
+	return page_address(ptp);
+}
+
+static inline void *gpt_pte_from_addr(struct gpt *gpt,
+				      struct page *ptp,
+				      void *pte,
+				      unsigned long addr)
+{
+	addr = ((addr & gpt->pte_mask) >> gpt->page_shift) << gpt->pte_shift;
+	if (!ptp)
+		return gpt->pte += addr;
+	return (void *)(((unsigned long)pte & PAGE_MASK) + addr);
+}
+
+
+/* struct gpt_lock - generic page table range lock structure.
+ *
+ * @list: List struct for active lock holder lists.
+ * @start: Start address of the locked range (inclusive).
+ * @end: End address of the locked range (inclusive).
+ * @serial: Serial number associated with that lock.
+ *
+ * Before any read/update access to a range of the generic page table, it must
+ * be locked to synchronize with conurrent read/update and insertion. In most
+ * case gpt_lock will complete with only taking one spinlock for protecting the
+ * struct insertion in the active lock holder list (either updaters or faulters
+ * list depending if calling gpt_lock() or gpt_fault_lock()).
+ */
+struct gpt_lock {
+	struct list_head	list;
+	unsigned long		start;
+	unsigned long		end;
+	unsigned long		serial;
+	bool (*hold)(struct gpt_lock *lock, struct page *pdp);
+};
+
+static inline int gpt_lock_update(struct gpt *gpt, struct gpt_lock *lock)
+{
+	lock->start = gpt_align_start_addr(gpt, lock->start);
+	lock->end = gpt_align_end_addr(gpt, lock->end);
+	if ((lock->start >= lock->end) || (lock->end > gpt->max_addr))
+		return -EINVAL;
+
+	if (gpt->ops->lock_update)
+		gpt->ops->lock_update(gpt, lock);
+	return 0;
+}
+
+static inline void gpt_unlock_update(struct gpt *gpt, struct gpt_lock *lock)
+{
+	if ((lock->start >= lock->end) || (lock->end > gpt->max_addr))
+		BUG();
+	if (list_empty(&lock->list))
+		BUG();
+
+	if (gpt->ops->unlock_update)
+		gpt->ops->unlock_update(gpt, lock);
+}
+
+static inline int gpt_lock_fault(struct gpt *gpt, struct gpt_lock *lock)
+{
+	lock->start = gpt_align_start_addr(gpt, lock->start);
+	lock->end = gpt_align_end_addr(gpt, lock->end);
+	if ((lock->start >= lock->end) || (lock->end > gpt->max_addr))
+		return -EINVAL;
+
+	if (gpt->ops->lock_fault)
+		return gpt->ops->lock_fault(gpt, lock);
+	return 0;
+}
+
+static inline void gpt_unlock_fault(struct gpt *gpt, struct gpt_lock *lock)
+{
+	if ((lock->start >= lock->end) || (lock->end > gpt->max_addr))
+		BUG();
+	if (list_empty(&lock->list))
+		BUG();
+
+	if (gpt->ops->unlock_fault)
+		gpt->ops->unlock_fault(gpt, lock);
+}
+
+
+/* struct gpt_walk - generic page table range walker structure.
+ *
+ * @lock: The lock protecting this iterator.
+ * @start: Start address of the walked range (inclusive).
+ * @end: End address of the walked range (inclusive).
+ *
+ * This is similar to the cpu page table walker. It allows to walk a range of
+ * the generic page table. Note that gpt walk does not imply protection hence
+ * you must call gpt_lock() prior to using gpt_walk() if you want to safely
+ * walk the range as otherwise you will be open to all kind of synchronization
+ * issue.
+ */
+struct gpt_walk {
+	int (*pte)(struct gpt *gpt,
+		   struct gpt_walk *walk,
+		   struct page *pdp,
+		   void *pte,
+		   unsigned long start,
+		   unsigned long end);
+	int (*pde)(struct gpt *gpt,
+		   struct gpt_walk *walk,
+		   struct page *pdp,
+		   volatile unsigned long *pde,
+		   unsigned long start,
+		   unsigned long end,
+		   unsigned long shift);
+	int (*pde_post)(struct gpt *gpt,
+			struct gpt_walk *walk,
+			struct page *pdp,
+			volatile unsigned long *pde,
+			unsigned long start,
+			unsigned long end,
+			unsigned long shift);
+	struct gpt_lock	*lock;
+	unsigned long	start;
+	unsigned long	end;
+	void		*data;
+};
+
+static inline int gpt_walk(struct gpt_walk *walk,
+			   struct gpt *gpt,
+			   struct gpt_lock *lock)
+{
+	if ((lock->start >= lock->end) || (lock->end > gpt->max_addr))
+		return -EINVAL;
+	if (list_empty(&lock->list))
+		return -EINVAL;
+	if (!((lock->start <= walk->start) && (lock->end >= walk->end)))
+		return -EINVAL;
+
+	walk->lock = lock;
+	return gpt->ops->walk(walk, gpt, lock);
+}
+
+
+/* struct gpt_iter - generic page table range iterator structure.
+ *
+ * @gpt: The generic page table structure.
+ * @lock: The lock protecting this iterator.
+ * @ptp: Current page directory page.
+ * @pte: Current page table entry array corresponding to pdp.
+ * @pte_addr: Page table entry address.
+ *
+ * This allow to iterate over a range of generic page table. The range you want
+ * to iterate over must be locked. First call gpt_iter_start() then to iterate
+ * simply call gpt_iter_next() which return false once you reached the end.
+ */
+struct gpt_iter {
+	struct gpt	*gpt;
+	struct gpt_lock	*lock;
+	struct page	*ptp;
+	void		*pte;
+	unsigned long	pte_addr;
+};
+
+static inline void gpt_iter_init(struct gpt_iter *iter,
+				 struct gpt *gpt,
+				 struct gpt_lock *lock)
+{
+	iter->gpt = gpt;
+	iter->lock = lock;
+	iter->ptp = NULL;
+	iter->pte = NULL;
+}
+
+static inline bool gpt_iter_addr(struct gpt_iter *iter, unsigned long addr)
+{
+	addr = gpt_align_start_addr(iter->gpt, addr);
+	if ((addr < iter->lock->start) || (addr > iter->lock->end)) {
+		iter->ptp = NULL;
+		iter->pte = NULL;
+		return false;
+	}
+	if (iter->pte && gpt_pdp_cover_addr(iter->gpt, iter->ptp, addr)) {
+		struct gpt *gpt = iter->gpt;
+
+		iter->pte = gpt_pte_from_addr(gpt, iter->ptp, iter->pte, addr);
+		iter->pte_addr = addr;
+		return true;
+	}
+
+	return iter->gpt->ops->iter_addr(iter, addr);
+}
+
+static inline bool gpt_iter_first(struct gpt_iter *iter,
+				  unsigned long start,
+				  unsigned long end)
+{
+	start = gpt_align_start_addr(iter->gpt, start);
+	end = gpt_align_end_addr(iter->gpt, start);
+	if (!((start >= iter->lock->start) && (end <= iter->lock->end))) {
+		iter->ptp = NULL;
+		iter->pte = NULL;
+		return false;
+	}
+	if (iter->pte && gpt_pdp_cover_addr(iter->gpt, iter->ptp, start)) {
+		struct gpt *gpt = iter->gpt;
+
+		iter->pte = gpt_pte_from_addr(gpt, iter->ptp, iter->pte, start);
+		iter->pte_addr = start;
+		return true;
+	}
+
+	return iter->gpt->ops->iter_first(iter, start, end);
+}
+
+static inline bool gpt_iter_next(struct gpt_iter *iter)
+{
+	unsigned long start;
+
+	if (!iter->pte) {
+		iter->ptp = NULL;
+		iter->pte = NULL;
+		return false;
+	}
+
+	start = iter->pte_addr + (1UL << iter->gpt->page_shift);
+	if (start > iter->lock->end) {
+		iter->ptp = NULL;
+		iter->pte = NULL;
+		return false;
+	}
+
+	return iter->gpt->ops->iter_first(iter, start, iter->lock->end);
+}
+
+
+#endif /* __LINUX_GPT_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index a5ce0c7..176be56 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -515,4 +515,7 @@ source "lib/fonts/Kconfig"
 config ARCH_HAS_SG_CHAIN
 	def_bool n
 
+config GENERIC_PAGE_TABLE
+	bool
+
 endmenu
diff --git a/lib/Makefile b/lib/Makefile
index d6b4bc4..eae4516 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -196,3 +196,5 @@ quiet_cmd_build_OID_registry = GEN     $@
 clean-files	+= oid_registry_data.c
 
 obj-$(CONFIG_UCS2_STRING) += ucs2_string.o
+
+obj-$(CONFIG_GENERIC_PAGE_TABLE) += gpt.o
diff --git a/lib/gpt.c b/lib/gpt.c
new file mode 100644
index 0000000..5d82777
--- /dev/null
+++ b/lib/gpt.c
@@ -0,0 +1,897 @@
+/*
+ * Copyright 2014 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: JA(C)rA'me Glisse <jglisse@redhat.com>
+ */
+/* Generic arch independant page table implementation. See include/linux/gpt.h
+ * for further informations on the design.
+ */
+#include <linux/gpt.h>
+#include <linux/highmem.h>
+#include <linux/slab.h>
+
+
+/*
+ * Generic page table operations for page table with multi directory level.
+ */
+static inline struct page *gpt_pdp_upper_pdp(struct gpt *gpt,
+					      struct page *pdp)
+{
+	if (!pdp)
+		return NULL;
+	return pdp->s_mem;
+}
+
+static inline unsigned long *gpt_pdp_upper_pde(struct gpt *gpt,
+						struct page *pdp)
+{
+	unsigned long idx;
+	struct page *updp;
+
+	if (!pdp)
+		return NULL;
+
+	updp = gpt_pdp_upper_pdp(gpt, pdp);
+	idx = gpt_pdp_start(gpt, pdp) - gpt_pdp_start(gpt, updp);
+	idx = (idx >> gpt_pdp_shift(gpt, pdp)) & GPT_PDIR_MASK;
+	if (!updp) {
+		return gpt->pgd + idx;
+	}
+	return ((unsigned long *)page_address(updp)) + idx;
+}
+
+static inline bool gpt_pdp_before_serial(struct page *pdp, unsigned long serial)
+{
+	/*
+	 * To know if a page directory is new or old we first check if it's not
+	 * on the recently added list. If it is and its serial number is newer
+	 * or equal to our lock serial number then it is a new page directory
+	 * entry and must be ignore.
+	 */
+	return list_empty(&pdp->lru) || time_after(serial, pdp->private);
+}
+
+static inline bool gpt_pdp_before_eq_serial(struct page *pdp, unsigned long serial)
+{
+	/*
+	 * To know if a page directory is new or old we first check if it's not
+	 * on the recently added list. If it is and its serial number is newer
+	 * or equal to our lock serial number then it is a new page directory
+	 * entry and must be ignore.
+	 */
+	return list_empty(&pdp->lru) || time_after_eq(serial, pdp->private);
+}
+
+static int gpt_walk_pde(struct gpt *gpt,
+			struct gpt_walk *walk,
+			struct page *pdp,
+			volatile unsigned long *pde,
+			unsigned long start,
+			unsigned long end,
+			unsigned long shift)
+{
+	unsigned long addr, idx, lshift, mask, next, npde;
+	int ret;
+
+	npde = ((end - start) >> shift) + 1;
+	mask = ~((1UL << shift) - 1UL);
+	lshift = shift - GPT_PDIR_NBITS;
+
+	if (walk->pde) {
+		ret = walk->pde(gpt, walk, pdp, pde, start, end, shift);
+		if (ret)
+			return ret;
+	}
+
+	for (addr = start, idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+		struct page *lpdp;
+		void *lpde;
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		lpdp = gpt_pde_pdp(gpt, &pde[idx]);
+		if (!lpdp || !walk->lock->hold(walk->lock, lpdp))
+			continue;
+		lpde = page_address(lpdp);
+		if (lshift >= gpt->pld_shift) {
+			lpde += ((addr >> lshift) & GPT_PDIR_MASK) *
+				gpt->pde_size;
+			ret = gpt_walk_pde(gpt, walk, lpdp, lpde,
+					   addr, next, lshift);
+			if (ret)
+				return ret;
+		} else if (walk->pte) {
+			lpde = gpt_pte_from_addr(gpt, lpdp, lpde, addr);
+			ret = walk->pte(gpt, walk, lpdp, lpde, addr, next);
+			if (ret)
+				return ret;
+		}
+	}
+
+	if (walk->pde_post) {
+		ret = walk->pde_post(gpt, walk, pdp, pde, start, end, shift);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int gpt_tree_walk(struct gpt_walk *walk,
+			 struct gpt *gpt,
+			 struct gpt_lock *lock)
+{
+	unsigned long idx;
+
+	walk->start = gpt_align_start_addr(gpt, walk->start);
+	walk->end = gpt_align_end_addr(gpt, walk->start);
+	if ((walk->start >= walk->end) || (walk->end > gpt->max_addr))
+		return -EINVAL;
+
+	idx = (walk->start >> gpt->pgd_shift);
+	return gpt_walk_pde(gpt, walk, NULL, &gpt->pgd[idx],
+			    walk->start, walk->end,
+			    gpt->pgd_shift);
+}
+
+struct gpt_lock_walk {
+	struct list_head	pdp_to_free;
+	struct gpt_lock		*lock;
+	unsigned long		locked[BITS_TO_LONGS(1UL << GPT_PDIR_NBITS)];
+};
+
+static inline void gpt_pdp_unref(struct gpt *gpt,
+				 struct page *pdp,
+				 struct gpt_lock_walk *wlock,
+				 struct page *updp,
+				 volatile unsigned long *upde)
+{
+	if (!atomic_dec_and_test(&pdp->_mapcount))
+		return;
+
+	*upde = 0;
+	if (!list_empty(&pdp->lru)) {
+		/*
+		 * This should be a rare event, it means this page directory
+		 * was added recently but is about to be destroy before it
+		 * could be remove from the young list.
+		 *
+		 * Because it is in the young list and lock holder can access
+		 * the page table without rcu protection it means that we can
+		 * not rely on synchronize_rcu to know when it is safe to free
+		 * the page. We have to wait for all lock that are older than
+		 * this page directory to be release. Only once we reach that
+		 * point we know for sure that no thread can have a live
+		 * reference on that page directory.
+		 */
+		spin_lock(&gpt->pgd_lock);
+		list_add_tail(&pdp->lru, &gpt->pdp_free);
+		spin_unlock(&gpt->pgd_lock);
+	} else
+		/*
+		 * This means this is an old page directory and thus any lock
+		 * holder that might dereference a pointer to it would have a
+		 * reference on it. Hence when refcount reach 0 we know for
+		 * sure no lock holder will dereference this page directory
+		 * and thus synchronize_rcu is an long enough delay before
+		 * free.
+		 */
+		list_add_tail(&pdp->lru, &wlock->pdp_to_free);
+
+	/* Un-account this entry caller must hold a ref on pdp. */
+	if (updp && atomic_dec_and_test(&updp->_mapcount))
+		BUG();
+}
+
+static void gpt_lock_walk_free_pdp(struct gpt_lock_walk *wlock)
+{
+	struct page *pdp, *tmp;
+
+	if (list_empty(&wlock->pdp_to_free))
+		return;
+
+	synchronize_rcu();
+
+	list_for_each_entry_safe(pdp, tmp, &wlock->pdp_to_free, lru) {
+		/* Restore page struct fields to their expect value. */
+		list_del(&pdp->lru);
+		atomic_dec(&pdp->_mapcount);
+		pdp->mapping = NULL;
+		pdp->index = 0;
+		pdp->flags &= (~0xffUL);
+		__free_page(pdp);
+	}
+}
+
+static bool gpt_lock_update_hold(struct gpt_lock *lock, struct page *pdp)
+{
+	if (!atomic_read(&pdp->_mapcount))
+		return false;
+	if (!gpt_pdp_before_serial(pdp, lock->serial))
+		return false;
+	return true;
+}
+
+static void gpt_lock_walk_update_finish(struct gpt *gpt,
+					struct gpt_lock_walk *wlock)
+{
+	struct gpt_lock *lock = wlock->lock;
+	unsigned long min_serial;
+
+	spin_lock(&gpt->lock);
+	min_serial = gpt->min_serial;
+	list_del_init(&lock->list);
+	lock = list_first_entry_or_null(&gpt->updaters, struct gpt_lock, list);
+	gpt->min_serial = lock ? lock->serial : gpt->updater_serial;
+	spin_unlock(&gpt->lock);
+
+	/*
+	 * Drain the young pdp list if the new smallest serial lock holder is
+	 * different from previous one.
+	 */
+	if (gpt->min_serial != min_serial) {
+		struct page *pdp, *next;
+
+		spin_lock(&gpt->pgd_lock);
+		list_for_each_entry_safe(pdp, next, &gpt->pdp_young, lru) {
+			if (!gpt_pdp_before_serial(pdp, gpt->min_serial))
+				break;
+			list_del_init(&pdp->lru);
+		}
+		list_for_each_entry_safe(pdp, next, &gpt->pdp_free, lru) {
+			if (!gpt_pdp_before_serial(pdp, gpt->min_serial))
+				break;
+			list_del(&pdp->lru);
+			list_add_tail(&pdp->lru, &wlock->pdp_to_free);
+		}
+		spin_unlock(&gpt->pgd_lock);
+	}
+}
+
+static int gpt_pde_lock_update(struct gpt *gpt,
+			       struct gpt_walk *walk,
+			       struct page *pdp,
+			       volatile unsigned long *pde,
+			       unsigned long start,
+			       unsigned long end,
+			       unsigned long shift)
+{
+	unsigned long addr, idx, mask, next, npde;
+	struct gpt_lock_walk *wlock = walk->data;
+	struct gpt_lock *lock = wlock->lock;
+
+	npde = ((end - start) >> shift) + 1;
+	mask = ~((1UL << shift) - 1UL);
+
+	rcu_read_lock();
+	for (addr = start, idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+		struct page *lpdp;
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		lpdp = gpt_pde_pdp(gpt, &pde[idx]);
+		if (!lpdp)
+			continue;
+		if (!atomic_inc_not_zero(&lpdp->_mapcount)) {
+			/*
+			 * Force page directory entry to zero we know for sure
+			 * that some other thread is deleting this entry. So it
+			 * is safe to double clear pde.
+			 */
+			pde[idx] = 0;
+			continue;
+		}
+
+		if (!gpt_pdp_before_serial(lpdp, lock->serial)) {
+			/* This is a new entry drop reference and ignore it. */
+			gpt_pdp_unref(gpt, lpdp, wlock, pdp, &pde[idx]);
+			continue;
+		}
+		set_bit(idx, wlock->locked);
+	}
+	rcu_read_unlock();
+
+	for (addr = start, idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+		struct page *lpdp;
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		if (!test_bit(idx, wlock->locked))
+			continue;
+		clear_bit(idx, wlock->locked);
+		lpdp = gpt_pde_pdp(gpt, &pde[idx]);
+		kmap(lpdp);
+	}
+
+	return 0;
+}
+
+static void gpt_tree_lock_update(struct gpt *gpt, struct gpt_lock *lock)
+{
+	struct gpt_lock_walk wlock;
+	struct gpt_walk walk;
+
+	lock->hold = &gpt_lock_update_hold;
+	spin_lock(&gpt->lock);
+	lock->serial = gpt->updater_serial;
+	list_add_tail(&lock->list, &gpt->updaters);
+	spin_unlock(&gpt->lock);
+
+	bitmap_zero(wlock.locked, BITS_TO_LONGS(1UL << GPT_PDIR_NBITS));
+	INIT_LIST_HEAD(&wlock.pdp_to_free);
+	wlock.lock = lock;
+	walk.lock = lock;
+	walk.data = &wlock;
+	walk.pde = &gpt_pde_lock_update;
+	walk.pde_post = NULL;
+	walk.pte = NULL;
+	walk.start = lock->start;
+	walk.end = lock->end;
+
+	gpt_tree_walk(&walk, gpt, lock);
+	gpt_lock_walk_free_pdp(&wlock);
+}
+
+static int gpt_pde_unlock_update(struct gpt *gpt,
+				 struct gpt_walk *walk,
+				 struct page *pdp,
+				 volatile unsigned long *pde,
+				 unsigned long start,
+				 unsigned long end,
+				 unsigned long shift)
+{
+	unsigned long addr, idx, mask, next, npde;
+	struct gpt_lock_walk *wlock = walk->data;
+	struct gpt_lock *lock = wlock->lock;
+
+	npde = ((end - start) >> shift) + 1;
+	mask = ~((1UL << shift) - 1UL);
+
+	for (addr = start, idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+		struct page *lpdp;
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		lpdp = gpt_pde_pdp(gpt, &pde[idx]);
+		if (!lpdp || !gpt_pdp_before_serial(lpdp, lock->serial))
+			continue;
+		kunmap(lpdp);
+		gpt_pdp_unref(gpt, lpdp, wlock, pdp, &pde[idx]);
+	}
+
+	return 0;
+}
+
+static void gpt_tree_unlock_update(struct gpt *gpt, struct gpt_lock *lock)
+{
+	struct gpt_lock_walk wlock;
+	struct gpt_walk walk;
+
+	bitmap_zero(wlock.locked, BITS_TO_LONGS(1UL << GPT_PDIR_NBITS));
+	INIT_LIST_HEAD(&wlock.pdp_to_free);
+	wlock.lock = lock;
+	walk.lock = lock;
+	walk.data = &wlock;
+	walk.pde = NULL;
+	walk.pde_post = &gpt_pde_unlock_update;
+	walk.pte = NULL;
+	walk.start = lock->start;
+	walk.end = lock->end;
+
+	gpt_tree_walk(&walk, gpt, lock);
+
+	gpt_lock_walk_update_finish(gpt, &wlock);
+	gpt_lock_walk_free_pdp(&wlock);
+}
+
+static bool gpt_lock_fault_hold(struct gpt_lock *lock, struct page *pdp)
+{
+	if (!atomic_read(&pdp->_mapcount))
+		return false;
+	if (!gpt_pdp_before_eq_serial(pdp, lock->serial))
+		return false;
+	return true;
+}
+
+static void gpt_lock_walk_fault_finish(struct gpt *gpt,
+				       struct gpt_lock_walk *wlock)
+{
+	struct gpt_lock *lock = wlock->lock;
+
+	spin_lock(&gpt->lock);
+	list_del_init(&lock->list);
+	lock = list_first_entry_or_null(&gpt->faulters, struct gpt_lock, list);
+	if (lock)
+		gpt->updater_serial = lock->serial;
+	else
+		gpt->updater_serial = gpt->faulter_serial;
+	spin_unlock(&gpt->lock);
+}
+
+static int gpt_pde_lock_fault(struct gpt *gpt,
+			      struct gpt_walk *walk,
+			      struct page *pdp,
+			      volatile unsigned long *pde,
+			      unsigned long start,
+			      unsigned long end,
+			      unsigned long shift)
+{
+	unsigned long addr, c, idx, mask, next, npde;
+	struct gpt_lock_walk *wlock = walk->data;
+	struct gpt_lock *lock = wlock->lock;
+	struct list_head lpdp_new, lpdp_added;
+	struct page *lpdp, *tmp;
+	int ret;
+
+	npde = ((end - start) >> shift) + 1;
+	mask = ~((1UL << shift) - 1UL);
+	INIT_LIST_HEAD(&lpdp_added);
+	INIT_LIST_HEAD(&lpdp_new);
+
+	rcu_read_lock();
+	for (addr = start, c = idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		lpdp = gpt_pde_pdp(gpt, &pde[idx]);
+		if (lpdp == NULL) {
+			c++;
+			continue;
+		}
+		if (!atomic_inc_not_zero(&lpdp->_mapcount)) {
+			/*
+			 * Force page directory entry to zero we know for sure
+			 * that some other thread is deleting this entry. So it
+			 * is safe to double clear pde.
+			 */
+			c++;
+			pde[idx] = 0;
+			continue;
+		}
+		set_bit(idx, wlock->locked);
+	}
+	rcu_read_unlock();
+
+	/* Allocate missing page directory page. */
+	for (idx = 0; idx < c; ++idx) {
+		lpdp = alloc_page(gpt->gfp_flags | __GFP_ZERO);
+		if (!lpdp) {
+			ret = -ENOMEM;
+			goto error;
+		}
+		list_add_tail(&lpdp->lru, &lpdp_new);
+		kmap(lpdp);
+	}
+
+	gpt_pdp_lock(gpt, pdp);
+	for (addr = start, idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+		struct page *lpdp;
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		/* Anoter thread might already have populated entry. */
+		if (test_bit(idx, wlock->locked) || gpt_pde_valid(gpt, pde[idx]))
+			continue;
+
+		lpdp = list_first_entry_or_null(&lpdp_new, struct page, lru);
+		BUG_ON(!lpdp);
+		list_del(&lpdp->lru);
+
+		/* Initialize page directory page struct. */
+		lpdp->private = lock->serial;
+		lpdp->s_mem = pdp;
+		lpdp->index = addr & ~((1UL << shift) - 1UL);
+		lpdp->flags |= shift & 0xff;
+		list_add_tail(&lpdp->lru, &lpdp_added);
+		atomic_set(&lpdp->_mapcount, 1);
+#if USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS
+		spin_lock_init(&page->ptl);
+#endif
+
+		pde[idx] = gpt->user_ops->pde_from_pdp(gpt, lpdp);
+		/* Account this new entry inside upper directory. */
+		if (pdp)
+			atomic_inc(&pdp->_mapcount);
+	}
+	gpt_pdp_unlock(gpt, pdp);
+
+	spin_lock(&gpt->pgd_lock);
+	list_splice_tail(&lpdp_added, &gpt->pdp_young);
+	spin_unlock(&gpt->pgd_lock);
+
+	for (addr = start, idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+		struct page *lpdp;
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		if (!test_bit(idx, wlock->locked));
+			continue;
+		clear_bit(idx, wlock->locked);
+		lpdp = gpt_pde_pdp(gpt, &pde[idx]);
+		kmap(lpdp);
+	}
+
+	/* Free any left over pages. */
+	list_for_each_entry_safe (lpdp, tmp, &lpdp_new, lru) {
+		list_del(&lpdp->lru);
+		kunmap(lpdp);
+		__free_page(lpdp);
+	}
+	return 0;
+
+error:
+	list_for_each_entry_safe (lpdp, tmp, &lpdp_new, lru) {
+		list_del(&lpdp->lru);
+		kunmap(lpdp);
+		__free_page(lpdp);
+	}
+	walk->end = start - 1UL;
+	return ret;
+}
+
+static int gpt_pde_unlock_fault(struct gpt *gpt,
+				struct gpt_walk *walk,
+				struct page *pdp,
+				volatile unsigned long *pde,
+				unsigned long start,
+				unsigned long end,
+				unsigned long shift)
+{
+	unsigned long addr, idx, mask, next, npde;
+	struct gpt_lock_walk *wlock = walk->data;
+	struct gpt_lock *lock = wlock->lock;
+
+	npde = ((end - start) >> shift) + 1;
+	mask = ~((1UL << shift) - 1UL);
+
+	for (addr = start, idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+		struct page *lpdp;
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		lpdp = gpt_pde_pdp(gpt, &pde[idx]);
+		if (!lpdp || !lock->hold(lock, lpdp))
+			continue;
+		kunmap(lpdp);
+		gpt_pdp_unref(gpt, lpdp, wlock, pdp, &pde[idx]);
+	}
+
+	return 0;
+}
+
+static int gpt_tree_lock_fault(struct gpt *gpt, struct gpt_lock *lock)
+{
+	struct gpt_lock_walk wlock;
+	struct gpt_walk walk;
+	int ret;
+
+	lock->hold = &gpt_lock_fault_hold;
+	spin_lock(&gpt->lock);
+	lock->serial = gpt->faulter_serial++;
+	list_add_tail(&lock->list, &gpt->faulters);
+	spin_unlock(&gpt->lock);
+
+	bitmap_zero(wlock.locked, BITS_TO_LONGS(1UL << GPT_PDIR_NBITS));
+	INIT_LIST_HEAD(&wlock.pdp_to_free);
+	wlock.lock = lock;
+	walk.lock = lock;
+	walk.data = &wlock;
+	walk.pde = &gpt_pde_lock_fault;
+	walk.pde_post = NULL;
+	walk.pte = NULL;
+	walk.start = lock->start;
+	walk.end = lock->end;
+
+	ret = gpt_tree_walk(&walk, gpt, lock);
+	if (ret) {
+		walk.pde = NULL;
+		walk.pde_post = &gpt_pde_unlock_fault;
+		gpt_tree_walk(&walk, gpt, lock);
+		gpt_lock_walk_fault_finish(gpt, &wlock);
+	}
+	gpt_lock_walk_free_pdp(&wlock);
+
+	return ret;
+}
+
+static void gpt_tree_unlock_fault(struct gpt *gpt, struct gpt_lock *lock)
+{
+	struct gpt_lock_walk wlock;
+	struct gpt_walk walk;
+
+	bitmap_zero(wlock.locked, BITS_TO_LONGS(1UL << GPT_PDIR_NBITS));
+	INIT_LIST_HEAD(&wlock.pdp_to_free);
+	wlock.lock = lock;
+	walk.lock = lock;
+	walk.data = &wlock;
+	walk.pde = NULL;
+	walk.pde_post = &gpt_pde_unlock_fault;
+	walk.pte = NULL;
+	walk.start = lock->start;
+	walk.end = lock->end;
+
+	gpt_tree_walk(&walk, gpt, lock);
+
+	gpt_lock_walk_fault_finish(gpt, &wlock);
+	gpt_lock_walk_free_pdp(&wlock);
+}
+
+static bool gpt_tree_iter_addr_ptp(struct gpt_iter *iter,
+				   unsigned long addr,
+				   struct page *pdp,
+				   volatile unsigned long *pde,
+				   unsigned long shift)
+{
+	struct gpt_lock *lock = iter->lock;
+	struct gpt *gpt = iter->gpt;
+	struct page *lpdp;
+	void *lpde;
+
+	lpdp = gpt_pde_pdp(gpt, pde);
+	if (!lpdp || !lock->hold(lock, lpdp)) {
+		iter->ptp = NULL;
+		iter->pte = NULL;
+		return false;
+	}
+
+	lpde = page_address(lpdp);
+	if (shift == gpt->pld_shift) {
+		iter->ptp = lpdp;
+		iter->pte = gpt_pte_from_addr(gpt, lpdp, lpde, addr);
+		iter->pte_addr = addr;
+		return true;
+	}
+
+	shift -= GPT_PDIR_NBITS;
+	lpde += ((addr >> shift) & GPT_PDIR_MASK) * gpt->pde_size;
+	return gpt_tree_iter_addr_ptp(iter, addr, lpdp, lpde, shift);
+}
+
+static bool gpt_tree_iter_next_pdp(struct gpt_iter *iter,
+				   struct page *pdp,
+				   unsigned long addr)
+{
+	struct gpt *gpt = iter->gpt;
+	unsigned long *upde;
+	struct page *updp;
+
+	updp = gpt_pdp_upper_pdp(gpt, pdp);
+	upde = gpt_pdp_upper_pde(gpt, pdp);
+	if (gpt_pdp_cover_addr(gpt, updp, addr)) {
+		unsigned long shift = gpt_pdp_shift(gpt, updp);
+
+		return gpt_tree_iter_addr_ptp(iter, addr, updp, upde, shift);
+	}
+
+	return gpt_tree_iter_next_pdp(iter, updp, addr);
+}
+
+static bool gpt_tree_iter_addr(struct gpt_iter *iter, unsigned long addr)
+{
+	volatile unsigned long *pde;
+	struct gpt *gpt = iter->gpt;
+
+	if (iter->ptp)
+		return gpt_tree_iter_next_pdp(iter, iter->ptp, addr);
+	pde = gpt->pgd + (addr >> gpt->pgd_shift);
+	return gpt_tree_iter_addr_ptp(iter, addr, NULL, pde, gpt->pgd_shift);
+}
+
+static bool gpt_tree_iter_first_ptp(struct gpt_iter *iter,
+				    unsigned long start,
+				    unsigned long end,
+				    struct page *pdp,
+				    volatile unsigned long *pde,
+				    unsigned long shift)
+{
+	unsigned long addr, idx, lshift, mask, next, npde;
+	struct gpt_lock *lock = iter->lock;
+	struct gpt *gpt = iter->gpt;
+
+	npde = ((end - start) >> shift) + 1;
+	mask = ~((1UL << shift) - 1UL);
+	lshift = shift - GPT_PDIR_NBITS;
+
+	for (addr = start, idx = 0; idx < npde; addr = next + 1UL, ++idx) {
+		struct page *lpdp;
+		void *lpde;
+
+		next = min((addr & mask) + (1UL << shift) - 1UL, end);
+		lpdp = gpt_pde_pdp(gpt, &pde[idx]);
+		if (!lpdp || !lock->hold(lock, lpdp))
+			continue;
+
+		lpde = page_address(lpdp);
+		if (gpt->pld_shift == shift) {
+			iter->ptp = lpdp;
+			iter->pte = gpt_pte_from_addr(gpt, lpdp, lpde, addr);
+			iter->pte_addr = addr;
+			return true;
+		}
+
+		lpde += ((addr >> lshift) & GPT_PDIR_MASK) * gpt->pde_size;
+		if (gpt_tree_iter_first_ptp(iter, addr, next,
+					    lpdp, lpde, lshift))
+			return true;
+	}
+	return false;
+}
+
+static bool gpt_tree_iter_first_pdp(struct gpt_iter *iter,
+				    struct page *pdp,
+				    unsigned long start,
+				    unsigned long end)
+{
+	struct gpt *gpt = iter->gpt;
+	unsigned long *upde;
+	struct page *updp;
+
+	updp = gpt_pdp_upper_pdp(gpt, pdp);
+	upde = gpt_pdp_upper_pde(gpt, pdp);
+	if (gpt_pdp_cover_addr(gpt, updp, start)) {
+		unsigned long shift = gpt_pdp_shift(gpt, updp);
+
+		if (gpt_tree_iter_first_ptp(iter, start, end,
+					    updp, upde, shift))
+			return true;
+		start = gpt_pdp_end(gpt, updp) + 1UL;
+		if (start > end) {
+			iter->ptp = NULL;
+			iter->pte = NULL;
+			return false;
+		}
+	}
+
+	return gpt_tree_iter_first_pdp(iter, updp, start, end);
+}
+
+static bool gpt_tree_iter_first(struct gpt_iter *iter,
+				unsigned long start,
+				unsigned long end)
+{
+	unsigned long *pde;
+	struct gpt *gpt = iter->gpt;
+
+	if (iter->ptp)
+		return gpt_tree_iter_first_pdp(iter, iter->ptp, start, end);
+
+	pde = gpt->pgd + (start >> gpt->pgd_shift);
+	return gpt_tree_iter_first_ptp(iter, start, end, NULL,
+				       pde, gpt->pgd_shift);
+}
+
+static const struct gpt_ops _gpt_ops_tree = {
+	.lock_update = gpt_tree_lock_update,
+	.unlock_update = gpt_tree_unlock_update,
+	.lock_fault = gpt_tree_lock_fault,
+	.unlock_fault = gpt_tree_unlock_fault,
+	.walk = gpt_tree_walk,
+	.iter_addr = gpt_tree_iter_addr,
+	.iter_first = gpt_tree_iter_first,
+};
+
+
+/*
+ * Generic page table operations for page table with single level (flat).
+ */
+static int gpt_flat_walk(struct gpt_walk *walk,
+			 struct gpt *gpt,
+			 struct gpt_lock *lock)
+{
+	void *pte;
+
+	if (!walk->pte)
+		return 0;
+
+	pte = gpt_pte_from_addr(gpt, NULL, gpt->pte, walk->start);
+	return walk->pte(gpt, walk, NULL, pte, walk->start, walk->end);
+}
+
+static bool gpt_flat_iter_addr(struct gpt_iter *iter, unsigned long addr)
+{
+	struct gpt *gpt = iter->gpt;
+
+	iter->ptp = NULL;
+	iter->pte = gpt_pte_from_addr(gpt, NULL, gpt->pte, addr);
+	iter->pte_addr = addr;
+	return true;
+}
+
+static bool gpt_flat_iter_first(struct gpt_iter *iter,
+				unsigned long start,
+				unsigned long end)
+{
+	struct gpt *gpt = iter->gpt;
+
+	iter->ptp = NULL;
+	iter->pte = gpt_pte_from_addr(gpt, NULL, gpt->pte, start);
+	iter->pte_addr = start;
+	return true;
+}
+
+static const struct gpt_ops _gpt_ops_flat = {
+	.lock_update = NULL,
+	.unlock_update = NULL,
+	.lock_fault = NULL,
+	.unlock_fault = NULL,
+	.walk = gpt_flat_walk,
+	.iter_addr = gpt_flat_iter_addr,
+	.iter_first = gpt_flat_iter_first,
+};
+
+
+/*
+ * Default user operations implementation.
+ */
+static unsigned long gpt_default_pde_from_pdp(struct gpt *gpt,
+					      struct page *pdp)
+{
+	unsigned long pde;
+
+	pde = (page_to_pfn(pdp) << gpt->pfn_shift) | gpt->pfn_valid;
+	return pde;
+}
+
+static const struct gpt_user_ops _gpt_user_ops_default = {
+	.pde_from_pdp = gpt_default_pde_from_pdp,
+};
+
+
+void gpt_free(struct gpt *gpt)
+{
+	BUG_ON(!list_empty(&gpt->faulters));
+	BUG_ON(!list_empty(&gpt->updaters));
+	gpt->max_addr = 0;
+	kfree(gpt->pgd);
+}
+EXPORT_SYMBOL(gpt_free);
+
+int gpt_init(struct gpt *gpt)
+{
+	unsigned long pgd_size;
+
+	gpt->user_ops = gpt->user_ops ? gpt->user_ops : &_gpt_user_ops_default;
+	gpt->max_addr = gpt_align_end_addr(gpt, gpt->max_addr);
+	INIT_LIST_HEAD(&gpt->pdp_young);
+	INIT_LIST_HEAD(&gpt->pdp_free);
+	INIT_LIST_HEAD(&gpt->faulters);
+	INIT_LIST_HEAD(&gpt->updaters);
+	spin_lock_init(&gpt->pgd_lock);
+	spin_lock_init(&gpt->lock);
+	gpt->updater_serial = gpt->faulter_serial = gpt->min_serial = 0;
+	gpt->pde_size = sizeof(long);
+
+	/* The page table entry size must smaller than page size. */
+	if (gpt->pte_shift >= PAGE_SHIFT)
+		return -EINVAL;
+	gpt->pte_mask = (1UL << (PAGE_SHIFT - gpt->pte_shift)) - 1UL;
+	gpt->pte_mask = gpt->pte_mask << gpt->page_shift;
+
+	gpt->pld_shift = PAGE_SHIFT - gpt->pte_shift + gpt->page_shift;
+	if (gpt_align_end_addr(gpt, 1UL << gpt->pld_shift) >= gpt->max_addr) {
+		/* Only need one level ie this is a flat page table. */
+		gpt->pgd_shift = gpt->page_shift;
+		pgd_size = (gpt->max_addr >> gpt->pgd_shift) + 1UL;
+		pgd_size = pgd_size << gpt->pte_shift;
+		gpt->ops = &_gpt_ops_flat;
+	} else {
+		unsigned long nbits, pgd_nbits;
+
+		nbits = __fls(gpt->max_addr);
+		pgd_nbits = (nbits - gpt->pld_shift) % GPT_PDIR_NBITS;
+		pgd_nbits = pgd_nbits ? pgd_nbits : GPT_PDIR_NBITS;
+		gpt->pgd_shift = nbits - pgd_nbits;
+		pgd_size = ((gpt->max_addr >> gpt->pgd_shift) + 1UL) *
+			   gpt->pde_size;
+		gpt->ops = &_gpt_ops_tree;
+	}
+
+	gpt->pgd = kzalloc(pgd_size, GFP_KERNEL);
+	if (!gpt->pgd)
+		return -ENOMEM;
+
+	return 0;
+}
+EXPORT_SYMBOL(gpt_init);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
