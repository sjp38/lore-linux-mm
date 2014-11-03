Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1C36B00F5
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 15:46:49 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id x3so9803636qcv.21
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 12:46:48 -0800 (PST)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id l64si31384466qgf.18.2014.11.03.12.46.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 12:46:45 -0800 (PST)
Received: by mail-qg0-f51.google.com with SMTP id j5so9218104qga.38
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 12:46:45 -0800 (PST)
From: j.glisse@gmail.com
Subject: [PATCH 3/5] lib: lockless generic and arch independent page table (gpt) v2.
Date: Mon,  3 Nov 2014 15:42:31 -0500
Message-Id: <1415047353-29160-4-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1415047353-29160-1-git-send-email-j.glisse@gmail.com>
References: <1415047353-29160-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Page table is a common structure format most notably use by cpu mmu. The
arch depend page table code has strong tie to the architecture which makes
it unsuitable to be use by other non arch specific code.

This patch implement a generic and arch independent page table. It is generic
in the sense that entry size can be u64 or unsigned long (or u32 too on 32bits
arch).

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
  // once all concurrent faulter on the address unlock.

Details on how the lockless concurrent updater and faulter works is provided
in the header file.

Changed since v1:
  - Switch to macro implementation instead of using arithmetic to accomodate
  the various size for table entry (uint64_t, unsigned long, ...).
  This is somewhat less flexbile but right now there is no use for the extra
  flexibility v1 was offering.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/gpt.h | 340 +++++++++++++++++++++++++++
 lib/Kconfig         |   3 +
 lib/Makefile        |   2 +
 lib/gpt.c           | 202 ++++++++++++++++
 lib/gpt_generic.h   | 663 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 1210 insertions(+)
 create mode 100644 include/linux/gpt.h
 create mode 100644 lib/gpt.c
 create mode 100644 lib/gpt_generic.h

diff --git a/include/linux/gpt.h b/include/linux/gpt.h
new file mode 100644
index 0000000..3c28634
--- /dev/null
+++ b/include/linux/gpt.h
@@ -0,0 +1,340 @@
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
+ * Walker callback can sleep but for now longer than it would take for other
+ * threads to wrap around internal gpt value through :
+ *   gpt_lock_fault(gpt, lock)
+ *   ... user faulting in new pte ...
+ *   gpt_unlock_fault(gpt, lock)
+ *
+ * The lockless design refer to gpt_lock() and gpt_unlock() taking a spinlock
+ * only for adding/removing the lock struct to active lock list ie no more than
+ * few instructions in both case leaving little room for lock contention.
+ *
+ * Moreover there is no memory allocation during gpt_lock() or gpt_unlock() or
+ * gpt_walk(). The only constraint is that the lock struct must be the same for
+ * gpt_lock(), gpt_unlock() and gpt_walk().
+ */
+#ifndef __LINUX_GPT_H
+#define __LINUX_GPT_H
+
+#include <linux/mm.h>
+#include <asm/types.h>
+
+struct gpt_walk;
+struct gpt_iter;
+
+/* struct gpt - generic page table structure.
+ *
+ * @pde_from_pdp: Return page directory entry that correspond to a page
+ * directory page. This allow user to use there own custom page directory
+ * entry format for all page directory level.
+ * @pgd: Page global directory if multi level (tree page table).
+ * @faulters: List of all concurrent fault locks.
+ * @updaters: List of all concurrent update locks.
+ * @pdp_young: List of all young page directory page, analogy would be that
+ * directory page on the young list are like inside a rcu read section and
+ * might be dereference by other threads that do not hold a reference on it.
+ * Logic is that an active updater might have taken reference before this
+ * page directory was added and because once an updater have a lock on a
+ * range it can start to walk or iterate over the range without holding rcu
+ * read critical section (allowing walker or iterator to sleep). Directory
+ * are move off the young list only once all updaters that never considered
+ * it are done (ie have call gpt_ ## SUFFIX ## _unlock_update()).
+ * @pdp_free: List of all page directory page to free (delayed free).
+ * @last_idx: Last valid index for this page table. Page table size is derived
+ * from that value.
+ * @pd_shift: Page directory shift value (1 << pd_shift) is the number of entry
+ * that each page directory hold.
+ * @pde_mask: Mask bit corresponding to pfn value of lower page directory from
+ * a pde.
+ * @pde_shift: Shift value use to extract pfn value of lower page directory
+ * from a pde.
+ * @pde_valid: If pde & pde_valid is not 0 then it means this is a valid pde
+ * entry that have a valid pfn value for a lower page directory level.
+ * @pgd_shift: Shift value to get the index inside the pgd from an address.
+ * @min_serial: Oldest serial number use by the oldest updater.
+ * @updater_serial: Current serial number use for updater.
+ * @faulter_serial: Current serial number use for faulter.
+ * @lock: Lock protecting serial number and updaters/faulters list.
+ * @pgd_lock: Lock protecting pgd level (and all level if arch do not have room
+ * for spinlock inside its page struct).
+ */
+struct gpt {
+	uint64_t (*pde_from_pdp)(struct gpt *gpt, struct page *pdp);
+	void			*pgd;
+	struct list_head	faulters;
+	struct list_head	updaters;
+	struct list_head	pdp_young;
+	struct list_head	pdp_free;
+	uint64_t		last_idx;
+	uint64_t		pd_shift;
+	uint64_t		pde_mask;
+	uint64_t		pde_shift;
+	uint64_t		pde_valid;
+	uint64_t		pgd_shift;
+	unsigned long		min_serial;
+	unsigned long		faulter_serial;
+	unsigned long		updater_serial;
+	spinlock_t		lock;
+	spinlock_t		pgd_lock;
+	unsigned		gfp_flags;
+};
+
+/* struct gpt_lock - generic page table range lock structure.
+ *
+ * @list: List struct for active lock holder lists.
+ * @first: Start address of the locked range (inclusive).
+ * @last: End address of the locked range (inclusive).
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
+	uint64_t		first;
+	uint64_t		last;
+	unsigned long		serial;
+	bool			faulter;
+};
+
+/* struct gpt_walk - generic page table range walker structure.
+ *
+ * @lock: The lock protecting this iterator.
+ * @first: First index of the walked range (inclusive).
+ * @last: Last index of the walked range (inclusive).
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
+		   void *ptep,
+		   uint64_t first,
+		   uint64_t last);
+	int (*pde)(struct gpt *gpt,
+		   struct gpt_walk *walk,
+		   struct page *pdp,
+		   void *pdep,
+		   uint64_t first,
+		   uint64_t last,
+		   uint64_t shift);
+	int (*pde_post)(struct gpt *gpt,
+			struct gpt_walk *walk,
+			struct page *pdp,
+			void *pdep,
+			uint64_t first,
+			uint64_t last,
+			uint64_t shift);
+	struct gpt_lock	*lock;
+	uint64_t	first;
+	uint64_t	last;
+	void		*data;
+};
+
+/* struct gpt_iter - generic page table range iterator structure.
+ *
+ * @gpt: The generic page table structure.
+ * @lock: The lock protecting this iterator.
+ * @pdp: Current page directory page.
+ * @pdep: Pointer to page directory entry for corresponding pdp.
+ * @idx: Current index
+ */
+struct gpt_iter {
+	struct gpt	*gpt;
+	struct gpt_lock	*lock;
+	struct page	*pdp;
+	void		*pdep;
+	uint64_t	idx;
+};
+
+
+/* Page directory page helpers */
+static inline uint64_t gpt_pdp_shift(struct gpt *gpt, struct page *pdp)
+{
+	if (!pdp)
+		return gpt->pgd_shift;
+	return pdp->flags & 0xff;
+}
+
+static inline uint64_t gpt_pdp_first(struct gpt *gpt, struct page *pdp)
+{
+	if (!pdp)
+		return 0UL;
+	return pdp->index;
+}
+
+static inline uint64_t gpt_pdp_last(struct gpt *gpt, struct page *pdp)
+{
+	if (!pdp)
+		return gpt->last_idx;
+	return min(gpt->last_idx,
+		   (uint64_t)(pdp->index +
+		   (1UL << (gpt_pdp_shift(gpt, pdp) + gpt->pd_shift)) - 1UL));
+}
+
+#if USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS
+static inline void gpt_pdp_lock(struct gpt *gpt, struct page  *pdp)
+{
+	if (pdp)
+		spin_lock(&pdp->ptl);
+	else
+		spin_lock(&gpt->pgd_lock);
+}
+
+static inline void gpt_pdp_unlock(struct gpt *gpt, struct page  *pdp)
+{
+	if (pdp)
+		spin_unlock(&pdp->ptl);
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
+static inline void gpt_pdp_ref(struct gpt *gpt, struct page  *pdp)
+{
+	if (pdp)
+		atomic_inc(&pdp->_mapcount);
+}
+
+static inline void gpt_pdp_unref(struct gpt *gpt, struct page  *pdp)
+{
+	if (pdp && atomic_dec_and_test(&pdp->_mapcount))
+		BUG();
+}
+
+
+/* Generic page table common functions. */
+void gpt_free(struct gpt *gpt);
+
+
+/* Generic page table type specific functions. */
+int gpt_ulong_init(struct gpt *gpt);
+void gpt_ulong_lock_update(struct gpt *gpt, struct gpt_lock *lock);
+void gpt_ulong_unlock_update(struct gpt *gpt, struct gpt_lock *lock);
+int gpt_ulong_lock_fault(struct gpt *gpt, struct gpt_lock *lock);
+void gpt_ulong_unlock_fault(struct gpt *gpt, struct gpt_lock *lock);
+int gpt_ulong_walk(struct gpt_walk *walk,
+		   struct gpt *gpt,
+		   struct gpt_lock *lock);
+bool gpt_ulong_iter_idx(struct gpt_iter *iter, uint64_t idx);
+bool gpt_ulong_iter_first(struct gpt_iter *iter,
+			  uint64_t first,
+			  uint64_t last);
+bool gpt_ulong_iter_next(struct gpt_iter *iter);
+
+int gpt_u64_init(struct gpt *gpt);
+void gpt_u64_lock_update(struct gpt *gpt, struct gpt_lock *lock);
+void gpt_u64_unlock_update(struct gpt *gpt, struct gpt_lock *lock);
+int gpt_u64_lock_fault(struct gpt *gpt, struct gpt_lock *lock);
+void gpt_u64_unlock_fault(struct gpt *gpt, struct gpt_lock *lock);
+int gpt_u64_walk(struct gpt_walk *walk,
+		 struct gpt *gpt,
+		 struct gpt_lock *lock);
+bool gpt_u64_iter_idx(struct gpt_iter *iter, uint64_t idx);
+bool gpt_u64_iter_first(struct gpt_iter *iter,
+			uint64_t first,
+			uint64_t last);
+bool gpt_u64_iter_next(struct gpt_iter *iter);
+
+#ifndef CONFIG_64BIT
+int gpt_u32_init(struct gpt *gpt);
+void gpt_u32_lock_update(struct gpt *gpt, struct gpt_lock *lock);
+void gpt_u32_unlock_update(struct gpt *gpt, struct gpt_lock *lock);
+int gpt_u32_lock_fault(struct gpt *gpt, struct gpt_lock *lock);
+void gpt_u32_unlock_fault(struct gpt *gpt, struct gpt_lock *lock);
+int gpt_u32_walk(struct gpt_walk *walk,
+		 struct gpt *gpt,
+		 struct gpt_lock *lock);
+bool gpt_u32_iter_idx(struct gpt_iter *iter, uint64_t idx);
+bool gpt_u32_iter_first(struct gpt_iter *iter,
+			uint64_t first,
+			uint64_t last);
+bool gpt_u32_iter_next(struct gpt_iter *iter);
+#endif
+
+
+/* Generic page table iterator helpers. */
+static inline void gpt_iter_init(struct gpt_iter *iter,
+				 struct gpt *gpt,
+				 struct gpt_lock *lock)
+{
+	iter->gpt = gpt;
+	iter->lock = lock;
+	iter->pdp = NULL;
+	iter->pdep = NULL;
+}
+
+#endif /* __LINUX_GPT_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 2faf7b2..c041b3c 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -525,4 +525,7 @@ source "lib/fonts/Kconfig"
 config ARCH_HAS_SG_CHAIN
 	def_bool n
 
+config GENERIC_PAGE_TABLE
+	bool
+
 endmenu
diff --git a/lib/Makefile b/lib/Makefile
index 84000ec..e5ad435 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -197,3 +197,5 @@ quiet_cmd_build_OID_registry = GEN     $@
 clean-files	+= oid_registry_data.c
 
 obj-$(CONFIG_UCS2_STRING) += ucs2_string.o
+
+obj-$(CONFIG_GENERIC_PAGE_TABLE) += gpt.o
diff --git a/lib/gpt.c b/lib/gpt.c
new file mode 100644
index 0000000..3a8e62c
--- /dev/null
+++ b/lib/gpt.c
@@ -0,0 +1,202 @@
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
+#include "gpt_generic.h"
+
+
+struct gpt_lock_walk {
+	struct list_head	pdp_to_free;
+	struct gpt_lock		*lock;
+	unsigned long		locked[(1 << (PAGE_SHIFT - 3)) / sizeof(long)];
+};
+
+/* gpt_pdp_before_serial() - is page directory older than given serial.
+ *
+ * @pdp: Pointer to struct page of the page directory.
+ * @serial: Serial number to check against.
+ *
+ * Page table walker and iterator use this to determine if the current pde
+ * needs to be walked down/iterated over or not. Use by updater to avoid
+ * walking down/iterating over new page directory.
+ */
+static inline bool gpt_pdp_before_serial(struct page *pdp,
+					 unsigned long serial)
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
+/* gpt_lock_hold_pdp() - does given lock hold a reference on given directory.
+ *
+ * @lock: Lock to check against.
+ * @pdp: Pointer to struct page of the page directory.
+ *
+ * When walking down page table or iterating over this function is call to know
+ * if the current pde entry needs to be walked down/iterated over.
+ */
+static bool gpt_lock_hold_pdp(struct gpt_lock *lock, struct page *pdp)
+{
+	if (lock->faulter)
+		return true;
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
+/* gpt_lock_fault_finish() - common lock fault cleanup.
+ *
+ * @gpt: The pointer to the generic page table structure.
+ * @wlock: Walk lock structure.
+ *
+ * This function first remove the lock from faulters list then update the
+ * serial number that will be use by next updater to either the oldest active
+ * faulter or to the next faulter serial number. In both case the next updater
+ * will ignore directory with serial equal or superior to this serial number.
+ * In other word it will only consider directory that are older that oldest
+ * active faulter.
+ *
+ * Note however that the young list is not drain here as we only want to drain
+ * it once updaters are done ie once no updaters might dereference such young
+ * page without holding a reference on it. Refer to gpt struct comments on
+ * young list.
+ */
+static void gpt_lock_fault_finish(struct gpt *gpt, struct gpt_lock_walk *wlock)
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
+
+/* Page directory page helpers */
+static inline bool gpt_pdp_cover_idx(struct gpt *gpt,
+				     struct page *pdp,
+				     unsigned long idx)
+{
+	return (idx >= gpt_pdp_first(gpt, pdp)) &&
+	       (idx <= gpt_pdp_last(gpt, pdp));
+}
+
+static inline struct page *gpt_pdp_upper_pdp(struct page *pdp)
+{
+	if (!pdp)
+		return NULL;
+	return pdp->s_mem;
+}
+
+static inline void gpt_pdp_init(struct page *page)
+{
+	atomic_set(&page->_mapcount, 1);
+#if USE_SPLIT_PTE_PTLOCKS && !ALLOC_SPLIT_PTLOCKS
+	spin_lock_init(&page->ptl);
+#endif
+}
+
+
+/* Generic page table common functions. */
+void gpt_free(struct gpt *gpt)
+{
+	BUG_ON(!list_empty(&gpt->faulters));
+	BUG_ON(!list_empty(&gpt->updaters));
+	kfree(gpt->pgd);
+	gpt->pgd = NULL;
+}
+EXPORT_SYMBOL(gpt_free);
+
+
+/* Generic page table type specific functions. */
+GPT_DEFINE(u64, uint64_t, 3);
+#ifdef CONFIG_64BIT
+GPT_DEFINE(ulong, unsigned long, 3);
+#else
+GPT_DEFINE(ulong, unsigned long, 2);
+GPT_DEFINE(u32, uint32_t, 2);
+#endif
diff --git a/lib/gpt_generic.h b/lib/gpt_generic.h
new file mode 100644
index 0000000..c996314
--- /dev/null
+++ b/lib/gpt_generic.h
@@ -0,0 +1,663 @@
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
+
+/*
+ * Template for implementing generic page table for various types.
+ *
+ * SUFFIX       suffix use for naming functions.
+ * TYPE         type (uint64_t, unsigned long, ...)
+ * TYPE_SHIFT   shift corresponding to GPT_TYPE (3 for u64, 2 for u32).
+ *
+ * Note that (1 << (1 << (TYPE_SHIFT + 3))) must be big enough to store any pfn
+ * and flags the user wants. For instance for a 32 bits arch with 36 bits PAE
+ * you need 24 bits to store a pfn thus if you use u32 as a type then you only
+ * have 8 bits left for flags in each entry.
+ */
+
+#define GPT_DEFINE(SUFFIX, TYPE, TYPE_SHIFT)				      \
+									      \
+int gpt_ ## SUFFIX ## _init(struct gpt *gpt)				      \
+{									      \
+	unsigned long pgd_size;						      \
+									      \
+	gpt->pgd = NULL;						      \
+	if (!gpt->last_idx)						      \
+		return -EINVAL;						      \
+	INIT_LIST_HEAD(&gpt->faulters);					      \
+	INIT_LIST_HEAD(&gpt->updaters);					      \
+	INIT_LIST_HEAD(&gpt->pdp_young);				      \
+	INIT_LIST_HEAD(&gpt->pdp_free);					      \
+	spin_lock_init(&gpt->pgd_lock);					      \
+	spin_lock_init(&gpt->lock);					      \
+	gpt->pd_shift = (PAGE_SHIFT - TYPE_SHIFT);			      \
+	gpt->pgd_shift = (__fls(gpt->last_idx) /			      \
+			  (PAGE_SHIFT - (TYPE_SHIFT))) *		      \
+			 (PAGE_SHIFT - (TYPE_SHIFT));			      \
+	pgd_size = (gpt->last_idx >> gpt->pgd_shift) << (TYPE_SHIFT);	      \
+	gpt->pgd = kzalloc(pgd_size, GFP_KERNEL);			      \
+	gpt->updater_serial = gpt->faulter_serial = gpt->min_serial = 0;      \
+	return !gpt->pgd ? -ENOMEM : 0;					      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _init);					      \
+									      \
+/* gpt_ ## SUFFIX ## _pde_pdp() - get page directory page from a pde.	      \
+ *									      \
+ * @gpt: The pointer to the generic page table structure.		      \
+ * @pde: Page directory entry to extract the lower directory page from.	      \
+ */									      \
+static inline struct page *gpt_ ## SUFFIX ## _pde_pdp(struct gpt *gpt,	      \
+						      TYPE pde)		      \
+{									      \
+	if (!(pde & gpt->pde_valid))					      \
+		return NULL;						      \
+	return pfn_to_page((pde & gpt->pde_mask) >> gpt->pde_shift);	      \
+}									      \
+									      \
+/* gpt_ ## SUFFIX ## _pte_from_idx() - pointer to a pte inside directory      \
+ *									      \
+ * @gpt: The pointer to the generic page table structure.		      \
+ * @pdp: Page directory page if any.					      \
+ * @idx: Index of the pte that is being lookup.				      \
+ */									      \
+static inline void *gpt_ ## SUFFIX ## _pte_from_idx(struct gpt *gpt,	      \
+						    struct page *pdp,	      \
+						    uint64_t idx)	      \
+{									      \
+	TYPE *ptep = pdp ? page_address(pdp) : gpt->pgd;		      \
+									      \
+	ptep += (idx & ((1UL << gpt->pd_shift) - 1UL));			      \
+	return ptep;							      \
+}									      \
+									      \
+/* gpt_ ## SUFFIX ## _pdep_from_idx() - pointer to directory entry	      \
+ *									      \
+ * @gpt: The pointer to the generic page table structure.		      \
+ * @pdp: Page directory page if any.					      \
+ * @idx: Index of the pde that is being lookup.				      \
+ */									      \
+static inline void *gpt_ ## SUFFIX ## _pdep_from_idx(struct gpt *gpt,	      \
+						     struct page *pdp,	      \
+						     uint64_t idx)	      \
+{									      \
+	TYPE *pdep = pdp ? page_address(pdp) : gpt->pgd;		      \
+	uint64_t shift = gpt_pdp_shift(gpt, pdp);			      \
+									      \
+	pdep += ((idx >> shift) & ((1UL << gpt->pd_shift) - 1UL));	      \
+	return pdep;							      \
+}									      \
+									      \
+static int gpt_ ## SUFFIX ## _walk_pde(struct gpt *gpt,			      \
+				       struct gpt_walk *walk,		      \
+				       struct page *pdp,		      \
+				       void *ptr,			      \
+				       uint64_t first,			      \
+				       uint64_t last,			      \
+				       uint64_t shift)			      \
+{									      \
+	unsigned long i, npde;						      \
+	TYPE *pdep = ptr;						      \
+	uint64_t cur, lshift, mask, next;				      \
+	int ret;							      \
+									      \
+	if (walk->pde) {						      \
+		ret = walk->pde(gpt, walk, pdp, ptr,			      \
+				first, last, shift);			      \
+		if (ret)						      \
+			return ret;					      \
+	}								      \
+									      \
+	lshift = shift ? shift - gpt->pd_shift : 0;			      \
+	mask = ~((1ULL << shift) - 1ULL);				      \
+	npde = ((last - first) >> shift) + 1;				      \
+	for (i = 0, cur = first; i < npde; ++i, cur = next) {		      \
+		struct page *lpdp;					      \
+		TYPE pde = ACCESS_ONCE(pdep[i]);			      \
+									      \
+		next = min((cur & mask) + (1UL << shift), last);	      \
+		lpdp = gpt_ ## SUFFIX ## _pde_pdp(gpt, pde);		      \
+		if (!lpdp || !gpt_lock_hold_pdp(walk->lock, lpdp))	      \
+			continue;					      \
+		if (lshift) {						      \
+			void *lpde;					      \
+									      \
+			lpde = gpt_ ## SUFFIX ## _pdep_from_idx(gpt,	      \
+							        lpdp,	      \
+							        cur);	      \
+			ret = gpt_ ## SUFFIX ## _walk_pde(gpt, walk,	      \
+							  lpdp, lpde,	      \
+							  cur, next,	      \
+							  lshift);	      \
+			if (ret)					      \
+				return ret;				      \
+		} else if (walk->pte) {					      \
+			void *lpte;					      \
+									      \
+			lpte = gpt_ ## SUFFIX ## _pte_from_idx(gpt,	      \
+							       lpdp,	      \
+							       cur);	      \
+			ret = walk->pte(gpt, walk, lpdp,		      \
+					lpte, cur, next);		      \
+			if (ret)					      \
+				return ret;				      \
+		}							      \
+	}								      \
+									      \
+	if (walk->pde_post) {						      \
+		ret = walk->pde_post(gpt, walk, pdp, ptr,		      \
+				     first, last, shift);		      \
+		if (ret)						      \
+			return ret;					      \
+	}								      \
+									      \
+	return 0;							      \
+}									      \
+									      \
+int gpt_ ## SUFFIX ## _walk(struct gpt_walk *walk,			      \
+			    struct gpt *gpt,				      \
+			    struct gpt_lock *lock)			      \
+{									      \
+	TYPE *pdep = gpt->pgd;						      \
+	uint64_t idx;							      \
+									      \
+	if (walk->first > gpt->last_idx || walk->last > gpt->last_idx)	      \
+		return -EINVAL;						      \
+									      \
+	idx = walk->first >> gpt->pgd_shift;				      \
+	return gpt_ ## SUFFIX ## _walk_pde(gpt, walk, NULL, &pdep[idx],	      \
+					   walk->first, walk->last,	      \
+					   gpt->pgd_shift);		      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _walk);					      \
+									      \
+static void gpt_ ## SUFFIX ## _pdp_unref(struct gpt *gpt,		      \
+					 struct page *pdp,		      \
+					 struct gpt_lock_walk *wlock,	      \
+					 struct page *updp,		      \
+					 TYPE *upde)			      \
+{									      \
+	/*								      \
+	 * The atomic decrement and test insure that only one thread	      \
+	 * will cleanup pde.						      \
+	 */								      \
+	if (!atomic_dec_and_test(&pdp->_mapcount))			      \
+		return;							      \
+									      \
+	/*								      \
+	 * Protection against race btw new pdes instancing and pdes	      \
+	 * clearing due to unref, rely on faulter taking a reference on	      \
+	 * all valid pdes and calling synchronize_rcu() after. After the      \
+	 * rcu synchronize no further unreference might clear a pde in	      \
+	 * the faulter(s) range(s).					      \
+	 */								      \
+	*upde = 0;							      \
+	if (!list_empty(&pdp->lru)) {					      \
+		/*							      \
+		 * It means this page directory was added recently but	      \
+		 * is about to be destroy before it could be remove from      \
+		 * the young list.					      \
+		 *							      \
+		 * Because it is in the young list and lock holder can	      \
+		 * access the page table without rcu protection it means      \
+		 * that we can not rely on synchronize_rcu to know when	      \
+		 * it is safe to free the page as some thread might be	      \
+		 * dereferencing it. We have to wait for all lock that	      \
+		 * are older than this page directory. At which point we      \
+		 * know for sure that no thread can derefence the page.	      \
+		 */							      \
+		spin_lock(&gpt->pgd_lock);				      \
+		list_add_tail(&pdp->lru, &gpt->pdp_free);		      \
+		spin_unlock(&gpt->pgd_lock);				      \
+	} else								      \
+		/*							      \
+		 * This means this is an old page directory and thus any      \
+		 * lock holder that might dereference a pointer to it	      \
+		 * would have a reference on it. Hence because refcount	      \
+		 * reached 0 we only need to wait for rcu grace period.	      \
+		 */							      \
+		list_add_tail(&pdp->lru, &wlock->pdp_to_free);		      \
+									      \
+	/* Un-account this entry caller must hold a ref on pdp. */	      \
+	if (updp && atomic_dec_and_test(&updp->_mapcount))		      \
+		BUG();							      \
+}									      \
+									      \
+static int gpt_ ## SUFFIX ## _pde_lock_update(struct gpt *gpt,		      \
+					      struct gpt_walk *walk,	      \
+					      struct page *pdp,		      \
+					      void *ptr,		      \
+					      uint64_t first,		      \
+					      uint64_t last,		      \
+					      uint64_t shift)		      \
+{									      \
+	unsigned long i, npde;						      \
+	struct gpt_lock_walk *wlock = walk->data;			      \
+	struct gpt_lock *lock = wlock->lock;				      \
+	TYPE *pdep = ptr;						      \
+									      \
+	npde = ((last - first) >> shift) + 1;				      \
+									      \
+	rcu_read_lock();						      \
+	for (i = 0; i < npde; ++i) {					      \
+		struct page *page;					      \
+		TYPE pde = ACCESS_ONCE(pdep[i]);			      \
+									      \
+		clear_bit(i, wlock->locked);				      \
+		page = gpt_ ## SUFFIX ## _pde_pdp(gpt, pde);		      \
+		if (!page)						      \
+			continue;					      \
+		if (!atomic_inc_not_zero(&page->_mapcount))		      \
+			continue;					      \
+									      \
+		if (!gpt_pdp_before_serial(page, lock->serial)) {	      \
+			/* This is a new entry ignore it. */		      \
+			gpt_ ## SUFFIX ## _pdp_unref(gpt, page, wlock,	      \
+						     pdp, &pdep[i]);	      \
+			continue;					      \
+		}							      \
+		set_bit(i, wlock->locked);				      \
+	}								      \
+	rcu_read_unlock();						      \
+									      \
+	for (i = 0; i < npde; i++) {					      \
+		struct page *page;					      \
+									      \
+		if (!test_bit(i, wlock->locked))			      \
+			continue;					      \
+		page = gpt_ ## SUFFIX ## _pde_pdp(gpt, pdep[i]);	      \
+		kmap(page);						      \
+	}								      \
+									      \
+	return 0;							      \
+}									      \
+									      \
+void gpt_ ## SUFFIX ## _lock_update(struct gpt *gpt,			      \
+				    struct gpt_lock *lock)		      \
+{									      \
+	struct gpt_lock_walk wlock;					      \
+	struct gpt_walk walk;						      \
+									      \
+	spin_lock(&gpt->lock);						      \
+	lock->faulter = false;						      \
+	lock->serial = gpt->updater_serial;				      \
+	list_add_tail(&lock->list, &gpt->updaters);			      \
+	spin_unlock(&gpt->lock);					      \
+									      \
+	INIT_LIST_HEAD(&wlock.pdp_to_free);				      \
+	wlock.lock = lock;						      \
+	walk.lock = lock;						      \
+	walk.data = &wlock;						      \
+	walk.pde = &gpt_ ## SUFFIX ## _pde_lock_update;			      \
+	walk.pde_post = NULL;						      \
+	walk.pte = NULL;						      \
+	walk.first = lock->first;					      \
+	walk.last = lock->last;						      \
+									      \
+	gpt_ ## SUFFIX ## _walk(&walk, gpt, lock);			      \
+	gpt_lock_walk_free_pdp(&wlock);					      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _lock_update);				      \
+									      \
+static int gpt_ ## SUFFIX ## _pde_unlock_update(struct gpt *gpt,	      \
+						struct gpt_walk *walk,	      \
+						struct page *pdp,	      \
+						void *ptr,		      \
+						uint64_t first,		      \
+						uint64_t last,		      \
+						uint64_t shift)		      \
+{									      \
+	unsigned long i, npde;						      \
+	struct gpt_lock_walk *wlock = walk->data;			      \
+	struct gpt_lock *lock = wlock->lock;				      \
+	TYPE *pdep = ptr;						      \
+									      \
+	npde = ((last - first) >> shift) + 1;				      \
+									      \
+	rcu_read_lock();						      \
+	for (i = 0; i < npde; ++i) {					      \
+		struct page *page;					      \
+		TYPE pde = ACCESS_ONCE(pdep[i]);			      \
+									      \
+		if (!(pde & gpt->pde_valid))				      \
+			continue;					      \
+		page = gpt_ ## SUFFIX ## _pde_pdp(gpt, pde);		      \
+		if (!page || !gpt_pdp_before_serial(page, lock->serial))      \
+			continue;					      \
+		kunmap(page);						      \
+		gpt_ ## SUFFIX ## _pdp_unref(gpt, page, wlock,		      \
+					     pdp, &pdep[i]);		      \
+	}								      \
+	rcu_read_unlock();						      \
+									      \
+	return 0;							      \
+}									      \
+									      \
+void gpt_ ## SUFFIX ## _unlock_update(struct gpt *gpt,			      \
+				      struct gpt_lock *lock)		      \
+{									      \
+	struct gpt_lock_walk wlock;					      \
+	struct gpt_walk walk;						      \
+									      \
+	INIT_LIST_HEAD(&wlock.pdp_to_free);				      \
+	wlock.lock = lock;						      \
+	walk.lock = lock;						      \
+	walk.data = &wlock;						      \
+	walk.pde = NULL;						      \
+	walk.pde_post = &gpt_ ## SUFFIX ## _pde_unlock_update;		      \
+	walk.pte = NULL;						      \
+	walk.first = lock->first;					      \
+	walk.last = lock->last;						      \
+									      \
+	gpt_ ## SUFFIX ## _walk(&walk, gpt, lock);			      \
+									      \
+	gpt_lock_walk_update_finish(gpt, &wlock);			      \
+	gpt_lock_walk_free_pdp(&wlock);					      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _unlock_update);			      \
+									      \
+static int gpt_ ## SUFFIX ## _pde_lock_fault(struct gpt *gpt,		      \
+					     struct gpt_walk *walk,	      \
+					     struct page *pdp,		      \
+					     void *ptr,			      \
+					     uint64_t first,		      \
+					     uint64_t last,		      \
+					     uint64_t shift)		      \
+{									      \
+	unsigned long cmissing, i, npde;				      \
+	struct gpt_lock_walk *wlock = walk->data;			      \
+	struct gpt_lock *lock = wlock->lock;				      \
+	struct list_head pdp_new, pdp_added;				      \
+	struct page *page, *tmp;					      \
+	TYPE mask, *pdep = ptr;						      \
+	int ret;							      \
+									      \
+	npde = ((last - first) >> shift) + 1;				      \
+	mask = ~((1ULL << shift) - 1ULL);				      \
+	INIT_LIST_HEAD(&pdp_added);					      \
+	INIT_LIST_HEAD(&pdp_new);					      \
+									      \
+	rcu_read_lock();						      \
+	for (i = 0, cmissing = 0; i < npde; ++i) {			      \
+		TYPE pde = ACCESS_ONCE(pdep[i]);			      \
+									      \
+		clear_bit(i, wlock->locked);				      \
+		if (!(pde & gpt->pde_valid)) {				      \
+			cmissing++;					      \
+			continue;					      \
+		}							      \
+		page = gpt_ ## SUFFIX ## _pde_pdp(gpt, pde);		      \
+		if (!atomic_inc_not_zero(&page->_mapcount)) {		      \
+			cmissing++;					      \
+			continue;					      \
+		}							      \
+		set_bit(i, wlock->locked);				      \
+	}								      \
+	rcu_read_unlock();						      \
+									      \
+	/* Allocate missing page directory page. */			      \
+	for (i = 0; i < cmissing; ++i) {				      \
+		page = alloc_page(gpt->gfp_flags | __GFP_ZERO);		      \
+		if (!page) {						      \
+			ret = -ENOMEM;					      \
+			goto error;					      \
+		}							      \
+		list_add_tail(&page->lru, &pdp_new);			      \
+	}								      \
+									      \
+	/*								      \
+	 * The synchronize_rcu() is for exclusion with concurrent update      \
+	 * thread that might try to clear the pde. Because a reference	      \
+	 * was taken just above on all valid pdes we know for sure that	      \
+	 * after the rcu synchronize all thread that were about to clear      \
+	 * pdes are done and that no new unreference will lead to pde	      \
+	 * clear.							      \
+	 */								      \
+	synchronize_rcu();						      \
+									      \
+	gpt_pdp_lock(gpt, pdp);						      \
+	for (i = 0; i < npde; ++i) {					      \
+		TYPE pde = ACCESS_ONCE(pdep[i]);			      \
+									      \
+		if (test_bit(i, wlock->locked))				      \
+			continue;					      \
+									      \
+		/* Anoter thread might already have populated entry. */	      \
+		page = gpt_ ## SUFFIX ## _pde_pdp(gpt, pde);		      \
+		if (page && atomic_inc_not_zero(&page->_mapcount))	      \
+			continue;					      \
+									      \
+		page = list_first_entry_or_null(&pdp_new,		      \
+						struct page,		      \
+						lru);			      \
+		BUG_ON(!page);						      \
+		list_del(&page->lru);					      \
+									      \
+		/* Initialize page directory page struct. */		      \
+		page->private = lock->serial;				      \
+		page->s_mem = pdp;					      \
+		page->index = (first & mask) + (i << shift);		      \
+		page->flags |= (shift - gpt->pd_shift) & 0xff;		      \
+		gpt_pdp_init(page);					      \
+		list_add_tail(&page->lru, &pdp_added);			      \
+									      \
+		pdep[i] = gpt->pde_from_pdp(gpt, page);			      \
+		/* Account this new entry inside upper directory. */	      \
+		if (pdp)						      \
+			atomic_inc(&pdp->_mapcount);			      \
+	}								      \
+	gpt_pdp_unlock(gpt, pdp);					      \
+									      \
+	spin_lock(&gpt->pgd_lock);					      \
+	list_splice_tail(&pdp_added, &gpt->pdp_young);			      \
+	spin_unlock(&gpt->pgd_lock);					      \
+									      \
+	for (i = 0; i < npde; ++i) {					      \
+		page = gpt_ ## SUFFIX ## _pde_pdp(gpt, pdep[i]);	      \
+		kmap(page);						      \
+	}								      \
+									      \
+	/* Free any left over pages. */					      \
+	list_for_each_entry_safe (page, tmp, &pdp_new, lru) {		      \
+		list_del(&page->lru);					      \
+		__free_page(page);					      \
+	}								      \
+	return 0;							      \
+									      \
+error:									      \
+	/*								      \
+	 * We know that no page is kmaped and no page were added to the	      \
+	 * directroy tree.						      \
+	 */								      \
+	list_for_each_entry_safe (page, tmp, &pdp_new, lru) {		      \
+		list_del(&page->lru);					      \
+		__free_page(page);					      \
+	}								      \
+									      \
+	rcu_read_lock();						      \
+	for (i = 0; i < npde; ++i) {					      \
+		if (test_bit(i, wlock->locked))				      \
+			continue;					      \
+									      \
+		page = gpt_ ## SUFFIX ## _pde_pdp(gpt, pdep[i]);	      \
+		gpt_ ## SUFFIX ## _pdp_unref(gpt, page, wlock,		      \
+					     pdp, &pdep[i]);		      \
+	}								      \
+	rcu_read_unlock();						      \
+									      \
+	walk->last = first;						      \
+	return ret;							      \
+}									      \
+									      \
+static int gpt_ ## SUFFIX ## _pde_unlock_fault(struct gpt *gpt,		      \
+					       struct gpt_walk *walk,	      \
+					       struct page *pdp,	      \
+					       void *ptr,		      \
+					       uint64_t first,		      \
+					       uint64_t last,		      \
+					       uint64_t shift)		      \
+{									      \
+	unsigned long i, npde;						      \
+	struct gpt_lock_walk *wlock = walk->data;			      \
+	struct gpt_lock *lock = wlock->lock;				      \
+	TYPE *pdep = ptr;						      \
+									      \
+	npde = ((last - first) >> shift) + 1;				      \
+									      \
+	rcu_read_lock();						      \
+	for (i = 0; i < npde; ++i) {					      \
+		struct page *page;					      \
+									      \
+		page = gpt_ ## SUFFIX ## _pde_pdp(gpt, pdep[i]);	      \
+		if (!page || !gpt_lock_hold_pdp(lock, page))		      \
+			continue;					      \
+		kunmap(page);						      \
+		gpt_ ## SUFFIX ## _pdp_unref(gpt, page, wlock,		      \
+					     pdp, &pdep[i]);		      \
+	}								      \
+	rcu_read_unlock();						      \
+									      \
+	return 0;							      \
+}									      \
+									      \
+int gpt_ ## SUFFIX ## _lock_fault(struct gpt *gpt,			      \
+				  struct gpt_lock *lock)		      \
+{									      \
+	struct gpt_lock_walk wlock;					      \
+	struct gpt_walk walk;						      \
+	int ret;							      \
+									      \
+	lock->faulter = true;						      \
+	spin_lock(&gpt->lock);						      \
+	lock->serial = gpt->faulter_serial++;				      \
+	list_add_tail(&lock->list, &gpt->faulters);			      \
+	spin_unlock(&gpt->lock);					      \
+									      \
+	INIT_LIST_HEAD(&wlock.pdp_to_free);				      \
+	wlock.lock = lock;						      \
+	walk.lock = lock;						      \
+	walk.data = &wlock;						      \
+	walk.pde = &gpt_ ## SUFFIX ## _pde_lock_fault;			      \
+	walk.pde_post = NULL;						      \
+	walk.pte = NULL;						      \
+	walk.first = lock->first;					      \
+	walk.last = lock->last;						      \
+									      \
+	ret = gpt_ ## SUFFIX ## _walk(&walk, gpt, lock);		      \
+	if (ret) {							      \
+		walk.pde = NULL;					      \
+		walk.pde_post = &gpt_ ## SUFFIX ## _pde_unlock_fault;	      \
+		gpt_ ## SUFFIX ## _walk(&walk, gpt, lock);		      \
+		gpt_lock_fault_finish(gpt, &wlock);			      \
+	}								      \
+	gpt_lock_walk_free_pdp(&wlock);					      \
+									      \
+	return ret;							      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _lock_fault);				      \
+									      \
+void gpt_ ## SUFFIX ## _unlock_fault(struct gpt *gpt,			      \
+				     struct gpt_lock *lock)		      \
+{									      \
+	struct gpt_lock_walk wlock;					      \
+	struct gpt_walk walk;						      \
+									      \
+	INIT_LIST_HEAD(&wlock.pdp_to_free);				      \
+	wlock.lock = lock;						      \
+	walk.lock = lock;						      \
+	walk.data = &wlock;						      \
+	walk.pde = NULL;						      \
+	walk.pde_post = &gpt_ ## SUFFIX ## _pde_unlock_fault;		      \
+	walk.pte = NULL;						      \
+	walk.first = lock->first;					      \
+	walk.last = lock->last;						      \
+									      \
+	gpt_ ## SUFFIX ## _walk(&walk, gpt, lock);			      \
+									      \
+	gpt_lock_fault_finish(gpt, &wlock);				      \
+	gpt_lock_walk_free_pdp(&wlock);					      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _unlock_fault);				      \
+									      \
+static bool gpt_ ## SUFFIX ## _iter_idx_pdp(struct gpt_iter *iter,	      \
+					    uint64_t idx)		      \
+{									      \
+	struct gpt *gpt = iter->gpt;					      \
+	TYPE pde, *pdep;						      \
+									      \
+	if (!gpt_pdp_cover_idx(gpt, iter->pdp, idx)) {			      \
+		iter->pdp = gpt_pdp_upper_pdp(iter->pdp);		      \
+		return gpt_ ## SUFFIX ## _iter_idx_pdp(iter, idx);	      \
+	}								      \
+	pdep = gpt_ ## SUFFIX ## _pdep_from_idx(gpt, iter->pdp, idx);	      \
+	if (!gpt_pdp_shift(gpt, iter->pdp)) {				      \
+		iter->pdep = pdep;					      \
+		iter->idx = idx;					      \
+		return true;						      \
+	}								      \
+	pde = ACCESS_ONCE(*pdep);					      \
+	if (!(pde & iter->gpt->pde_valid)) {				      \
+		iter->pdep = NULL;					      \
+		return false;						      \
+	}								      \
+	iter->pdp = gpt_ ## SUFFIX ## _pde_pdp(iter->gpt, pde);		      \
+	return gpt_ ## SUFFIX ## _iter_idx_pdp(iter, idx);		      \
+}									      \
+									      \
+bool gpt_ ## SUFFIX ## _iter_idx(struct gpt_iter *iter, uint64_t idx)	      \
+{									      \
+	iter->pdep = NULL;						      \
+	if ((idx < iter->lock->first) || (idx > iter->lock->last))	      \
+		return false;						      \
+									      \
+	return gpt_ ## SUFFIX ## _iter_idx_pdp(iter, idx);		      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _iter_idx);				      \
+									      \
+bool gpt_ ## SUFFIX ## _iter_first(struct gpt_iter *iter,		      \
+				   uint64_t first,			      \
+				   uint64_t last)			      \
+{									      \
+	iter->pdep = NULL;						      \
+	if (first > last)						      \
+		return false;						      \
+	if ((first < iter->lock->first) || (first > iter->lock->last))	      \
+		return false;						      \
+	if ((last < iter->lock->first) || (last > iter->lock->last))	      \
+		return false;						      \
+									      \
+	do {								      \
+		if (gpt_ ## SUFFIX ## _iter_idx_pdp(iter, first))	      \
+			return true;					      \
+		if (first < last)					      \
+			first++;					      \
+		else							      \
+			return false;					      \
+	} while (1);							      \
+	return false;							      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _iter_first);				      \
+									      \
+bool gpt_ ## SUFFIX ## _iter_next(struct gpt_iter *iter)		      \
+{									      \
+	if (!iter->pdep || iter->idx >= iter->lock->last)		      \
+		return false;						      \
+	return gpt_ ## SUFFIX ## _iter_first(iter,			      \
+					     iter->idx + 1,		      \
+					     iter->lock->last);		      \
+}									      \
+EXPORT_SYMBOL(gpt_ ## SUFFIX ## _iter_next)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
