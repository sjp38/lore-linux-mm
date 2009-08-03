Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 68CF16B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:59:01 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:18:16 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 9/12] ksm: fix oom deadlock
In-Reply-To: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
Message-ID: <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There's a now-obvious deadlock in KSM's out-of-memory handling:
imagine ksmd or KSM_RUN_UNMERGE handling, holding ksm_thread_mutex,
trying to allocate a page to break KSM in an mm which becomes the
OOM victim (quite likely in the unmerge case): it's killed and goes
to exit, and hangs there waiting to acquire ksm_thread_mutex.

Clearly we must not require ksm_thread_mutex in __ksm_exit, simple
though that made everything else: perhaps use mmap_sem somehow?
And part of the answer lies in the comments on unmerge_ksm_pages:
__ksm_exit should also leave all the rmap_item removal to ksmd.

But there's a fundamental problem, that KSM relies upon mmap_sem to
guarantee the consistency of the mm it's dealing with, yet exit_mmap
tears down an mm without taking mmap_sem.  And bumping mm_users won't
help at all, that just ensures that the pages the OOM killer assumes
are on their way to being freed will not be freed.

The best answer seems to be, to move the ksm_exit callout from just
before exit_mmap, to the middle of exit_mmap: after the mm's pages
have been freed (if the mmu_gather is flushed), but before its page
tables and vma structures have been freed; and down_write,up_write
mmap_sem there to serialize with KSM's own reliance on mmap_sem.

But KSM then needs to be careful, whenever it downs mmap_sem, to
check that the mm is not already exiting: there's a danger of using
find_vma on a layout that's being torn apart, or writing into page
tables which have been freed for reuse; and even do_anonymous_page
and __do_fault need to check they're not being called by break_ksm
to reinstate a pte after zap_pte_range has zapped that page table.

Though it might be clearer to add an exiting flag, set while holding
mmap_sem in __ksm_exit, that wouldn't cover the issue of reinstating
a zapped pte.  All we need is to check whether mm_users is 0 - but
must remember that ksmd may detect that before __ksm_exit is reached.
So, ksm_test_exit(mm) added to comment such checks on mm->mm_users.

__ksm_exit now has to leave clearing up the rmap_items to ksmd,
that needs ksm_thread_mutex; but shift the exiting mm just after the
ksm_scan cursor so that it will soon be dealt with.  __ksm_enter raise
mm_count to hold the mm_struct, ksmd's exit processing (exactly like
its processing when it finds all VM_MERGEABLEs unmapped) mmdrop it,
similar procedure for KSM_RUN_UNMERGE (which has stopped ksmd).

But also give __ksm_exit a fast path: when there's no complication
(no rmap_items attached to mm and it's not at the ksm_scan cursor),
it can safely do all the exiting work itself.  This is not just an
optimization: when ksmd is not running, the raised mm_count would
otherwise leak mm_structs.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/ksm.h |   31 +++++++--
 kernel/fork.c       |    1 
 mm/ksm.c            |  144 ++++++++++++++++++++++++++++--------------
 mm/memory.c         |    5 -
 mm/mmap.c           |    9 ++
 5 files changed, 137 insertions(+), 53 deletions(-)

--- ksm8/include/linux/ksm.h	2009-08-01 05:02:09.000000000 +0100
+++ ksm9/include/linux/ksm.h	2009-08-02 13:50:41.000000000 +0100
@@ -12,11 +12,14 @@
 #include <linux/sched.h>
 #include <linux/vmstat.h>
 
+struct mmu_gather;
+
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
-void __ksm_exit(struct mm_struct *mm);
+void __ksm_exit(struct mm_struct *mm,
+		struct mmu_gather **tlbp, unsigned long end);
 
 static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
@@ -25,10 +28,24 @@ static inline int ksm_fork(struct mm_str
 	return 0;
 }
 
-static inline void ksm_exit(struct mm_struct *mm)
+/*
+ * For KSM to handle OOM without deadlock when it's breaking COW in a
+ * likely victim of the OOM killer, exit_mmap() has to serialize with
+ * ksm_exit() after freeing mm's pages but before freeing its page tables.
+ * That leaves a window in which KSM might refault pages which have just
+ * been finally unmapped: guard against that with ksm_test_exit(), and
+ * use it after getting mmap_sem in ksm.c, to check if mm is exiting.
+ */
+static inline bool ksm_test_exit(struct mm_struct *mm)
+{
+	return atomic_read(&mm->mm_users) == 0;
+}
+
+static inline void ksm_exit(struct mm_struct *mm,
+			    struct mmu_gather **tlbp, unsigned long end)
 {
 	if (test_bit(MMF_VM_MERGEABLE, &mm->flags))
-		__ksm_exit(mm);
+		__ksm_exit(mm, tlbp, end);
 }
 
 /*
@@ -64,7 +81,13 @@ static inline int ksm_fork(struct mm_str
 	return 0;
 }
 
-static inline void ksm_exit(struct mm_struct *mm)
+static inline bool ksm_test_exit(struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline void ksm_exit(struct mm_struct *mm,
+			    struct mmu_gather **tlbp, unsigned long end)
 {
 }
 
--- ksm8/kernel/fork.c	2009-08-01 05:02:09.000000000 +0100
+++ ksm9/kernel/fork.c	2009-08-02 13:50:41.000000000 +0100
@@ -492,7 +492,6 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		exit_aio(mm);
-		ksm_exit(mm);
 		exit_mmap(mm);
 		set_mm_exe_file(mm, NULL);
 		if (!list_empty(&mm->mmlist)) {
--- ksm8/mm/ksm.c	2009-08-02 13:50:32.000000000 +0100
+++ ksm9/mm/ksm.c	2009-08-02 13:50:41.000000000 +0100
@@ -32,6 +32,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/ksm.h>
 
+#include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
 /*
@@ -347,6 +348,8 @@ static void break_cow(struct mm_struct *
 	struct vm_area_struct *vma;
 
 	down_read(&mm->mmap_sem);
+	if (ksm_test_exit(mm))
+		goto out;
 	vma = find_vma(mm, addr);
 	if (!vma || vma->vm_start > addr)
 		goto out;
@@ -365,6 +368,8 @@ static struct page *get_mergeable_page(s
 	struct page *page;
 
 	down_read(&mm->mmap_sem);
+	if (ksm_test_exit(mm))
+		goto out;
 	vma = find_vma(mm, addr);
 	if (!vma || vma->vm_start > addr)
 		goto out;
@@ -439,11 +444,11 @@ static void remove_rmap_item_from_tree(s
 	} else if (rmap_item->address & NODE_FLAG) {
 		unsigned char age;
 		/*
-		 * ksm_thread can and must skip the rb_erase, because
+		 * Usually ksmd can and must skip the rb_erase, because
 		 * root_unstable_tree was already reset to RB_ROOT.
-		 * But __ksm_exit has to be careful: do the rb_erase
-		 * if it's interrupting a scan, and this rmap_item was
-		 * inserted by this scan rather than left from before.
+		 * But be careful when an mm is exiting: do the rb_erase
+		 * if this rmap_item was inserted by this scan, rather
+		 * than left over from before.
 		 */
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
 		BUG_ON(age > 1);
@@ -491,6 +496,8 @@ static int unmerge_ksm_pages(struct vm_a
 	int err = 0;
 
 	for (addr = start; addr < end && !err; addr += PAGE_SIZE) {
+		if (ksm_test_exit(vma->vm_mm))
+			break;
 		if (signal_pending(current))
 			err = -ERESTARTSYS;
 		else
@@ -507,34 +514,50 @@ static int unmerge_and_remove_all_rmap_i
 	int err = 0;
 
 	spin_lock(&ksm_mmlist_lock);
-	mm_slot = list_entry(ksm_mm_head.mm_list.next,
+	ksm_scan.mm_slot = list_entry(ksm_mm_head.mm_list.next,
 						struct mm_slot, mm_list);
 	spin_unlock(&ksm_mmlist_lock);
 
-	while (mm_slot != &ksm_mm_head) {
+	for (mm_slot = ksm_scan.mm_slot;
+			mm_slot != &ksm_mm_head; mm_slot = ksm_scan.mm_slot) {
 		mm = mm_slot->mm;
 		down_read(&mm->mmap_sem);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (ksm_test_exit(mm))
+				break;
 			if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
 				continue;
 			err = unmerge_ksm_pages(vma,
 						vma->vm_start, vma->vm_end);
-			if (err) {
-				up_read(&mm->mmap_sem);
-				goto out;
-			}
+			if (err)
+				goto error;
 		}
+
 		remove_trailing_rmap_items(mm_slot, mm_slot->rmap_list.next);
-		up_read(&mm->mmap_sem);
 
 		spin_lock(&ksm_mmlist_lock);
-		mm_slot = list_entry(mm_slot->mm_list.next,
+		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
 						struct mm_slot, mm_list);
-		spin_unlock(&ksm_mmlist_lock);
+		if (ksm_test_exit(mm)) {
+			hlist_del(&mm_slot->link);
+			list_del(&mm_slot->mm_list);
+			spin_unlock(&ksm_mmlist_lock);
+
+			free_mm_slot(mm_slot);
+			clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+			up_read(&mm->mmap_sem);
+			mmdrop(mm);
+		} else {
+			spin_unlock(&ksm_mmlist_lock);
+			up_read(&mm->mmap_sem);
+		}
 	}
 
 	ksm_scan.seqnr = 0;
-out:
+	return 0;
+
+error:
+	up_read(&mm->mmap_sem);
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = &ksm_mm_head;
 	spin_unlock(&ksm_mmlist_lock);
@@ -755,6 +778,9 @@ static int try_to_merge_with_ksm_page(st
 	int err = -EFAULT;
 
 	down_read(&mm1->mmap_sem);
+	if (ksm_test_exit(mm1))
+		goto out;
+
 	vma = find_vma(mm1, addr1);
 	if (!vma || vma->vm_start > addr1)
 		goto out;
@@ -796,6 +822,10 @@ static int try_to_merge_two_pages(struct
 		return err;
 
 	down_read(&mm1->mmap_sem);
+	if (ksm_test_exit(mm1)) {
+		up_read(&mm1->mmap_sem);
+		goto out;
+	}
 	vma = find_vma(mm1, addr1);
 	if (!vma || vma->vm_start > addr1) {
 		up_read(&mm1->mmap_sem);
@@ -1181,7 +1211,12 @@ next_mm:
 
 	mm = slot->mm;
 	down_read(&mm->mmap_sem);
-	for (vma = find_vma(mm, ksm_scan.address); vma; vma = vma->vm_next) {
+	if (ksm_test_exit(mm))
+		vma = NULL;
+	else
+		vma = find_vma(mm, ksm_scan.address);
+
+	for (; vma; vma = vma->vm_next) {
 		if (!(vma->vm_flags & VM_MERGEABLE))
 			continue;
 		if (ksm_scan.address < vma->vm_start)
@@ -1190,6 +1225,8 @@ next_mm:
 			ksm_scan.address = vma->vm_end;
 
 		while (ksm_scan.address < vma->vm_end) {
+			if (ksm_test_exit(mm))
+				break;
 			*page = follow_page(vma, ksm_scan.address, FOLL_GET);
 			if (*page && PageAnon(*page)) {
 				flush_anon_page(vma, *page, ksm_scan.address);
@@ -1212,6 +1249,11 @@ next_mm:
 		}
 	}
 
+	if (ksm_test_exit(mm)) {
+		ksm_scan.address = 0;
+		ksm_scan.rmap_item = list_entry(&slot->rmap_list,
+						struct rmap_item, link);
+	}
 	/*
 	 * Nuke all the rmap_items that are above this current rmap:
 	 * because there were no VM_MERGEABLE vmas with such addresses.
@@ -1226,24 +1268,29 @@ next_mm:
 		 * We've completed a full scan of all vmas, holding mmap_sem
 		 * throughout, and found no VM_MERGEABLE: so do the same as
 		 * __ksm_exit does to remove this mm from all our lists now.
+		 * This applies either when cleaning up after __ksm_exit
+		 * (but beware: we can reach here even before __ksm_exit),
+		 * or when all VM_MERGEABLE areas have been unmapped (and
+		 * mmap_sem then protects against race with MADV_MERGEABLE).
 		 */
 		hlist_del(&slot->link);
 		list_del(&slot->mm_list);
+		spin_unlock(&ksm_mmlist_lock);
+
 		free_mm_slot(slot);
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+		up_read(&mm->mmap_sem);
+		mmdrop(mm);
+	} else {
+		spin_unlock(&ksm_mmlist_lock);
+		up_read(&mm->mmap_sem);
 	}
-	spin_unlock(&ksm_mmlist_lock);
-	up_read(&mm->mmap_sem);
 
 	/* Repeat until we've completed scanning the whole list */
 	slot = ksm_scan.mm_slot;
 	if (slot != &ksm_mm_head)
 		goto next_mm;
 
-	/*
-	 * Bump seqnr here rather than at top, so that __ksm_exit
-	 * can skip rb_erase on unstable tree until we run again.
-	 */
 	ksm_scan.seqnr++;
 	return NULL;
 }
@@ -1368,6 +1415,7 @@ int __ksm_enter(struct mm_struct *mm)
 	spin_unlock(&ksm_mmlist_lock);
 
 	set_bit(MMF_VM_MERGEABLE, &mm->flags);
+	atomic_inc(&mm->mm_count);
 
 	if (needs_wakeup)
 		wake_up_interruptible(&ksm_thread_wait);
@@ -1375,41 +1423,45 @@ int __ksm_enter(struct mm_struct *mm)
 	return 0;
 }
 
-void __ksm_exit(struct mm_struct *mm)
+void __ksm_exit(struct mm_struct *mm,
+		struct mmu_gather **tlbp, unsigned long end)
 {
 	struct mm_slot *mm_slot;
+	int easy_to_free = 0;
 
 	/*
-	 * This process is exiting: doesn't hold and doesn't need mmap_sem;
-	 * but we do need to exclude ksmd and other exiters while we modify
-	 * the various lists and trees.
+	 * This process is exiting: if it's straightforward (as is the
+	 * case when ksmd was never running), free mm_slot immediately.
+	 * But if it's at the cursor or has rmap_items linked to it, use
+	 * mmap_sem to synchronize with any break_cows before pagetables
+	 * are freed, and leave the mm_slot on the list for ksmd to free.
+	 * Beware: ksm may already have noticed it exiting and freed the slot.
 	 */
-	mutex_lock(&ksm_thread_mutex);
+
 	spin_lock(&ksm_mmlist_lock);
 	mm_slot = get_mm_slot(mm);
-	if (!list_empty(&mm_slot->rmap_list)) {
-		spin_unlock(&ksm_mmlist_lock);
-		remove_trailing_rmap_items(mm_slot, mm_slot->rmap_list.next);
-		spin_lock(&ksm_mmlist_lock);
-	}
-
-	if (ksm_scan.mm_slot == mm_slot) {
-		ksm_scan.mm_slot = list_entry(
-			mm_slot->mm_list.next, struct mm_slot, mm_list);
-		ksm_scan.address = 0;
-		ksm_scan.rmap_item = list_entry(
-			&ksm_scan.mm_slot->rmap_list, struct rmap_item, link);
-		if (ksm_scan.mm_slot == &ksm_mm_head)
-			ksm_scan.seqnr++;
+	if (mm_slot && ksm_scan.mm_slot != mm_slot) {
+		if (list_empty(&mm_slot->rmap_list)) {
+			hlist_del(&mm_slot->link);
+			list_del(&mm_slot->mm_list);
+			easy_to_free = 1;
+		} else {
+			list_move(&mm_slot->mm_list,
+				  &ksm_scan.mm_slot->mm_list);
+		}
 	}
-
-	hlist_del(&mm_slot->link);
-	list_del(&mm_slot->mm_list);
 	spin_unlock(&ksm_mmlist_lock);
 
-	free_mm_slot(mm_slot);
-	clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-	mutex_unlock(&ksm_thread_mutex);
+	if (easy_to_free) {
+		free_mm_slot(mm_slot);
+		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+		mmdrop(mm);
+	} else if (mm_slot) {
+		tlb_finish_mmu(*tlbp, 0, end);
+		down_write(&mm->mmap_sem);
+		up_write(&mm->mmap_sem);
+		*tlbp = tlb_gather_mmu(mm, 1);
+	}
 }
 
 #define KSM_ATTR_RO(_name) \
--- ksm8/mm/memory.c	2009-08-01 05:02:09.000000000 +0100
+++ ksm9/mm/memory.c	2009-08-02 13:50:41.000000000 +0100
@@ -2647,8 +2647,9 @@ static int do_anonymous_page(struct mm_s
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_none(*page_table))
+	if (!pte_none(*page_table) || ksm_test_exit(mm))
 		goto release;
+
 	inc_mm_counter(mm, anon_rss);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
@@ -2790,7 +2791,7 @@ static int __do_fault(struct mm_struct *
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte))) {
+	if (likely(pte_same(*page_table, orig_pte) && !ksm_test_exit(mm))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
--- ksm8/mm/mmap.c	2009-06-25 05:18:10.000000000 +0100
+++ ksm9/mm/mmap.c	2009-08-02 13:50:41.000000000 +0100
@@ -27,6 +27,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/ksm.h>
 #include <linux/mmu_notifier.h>
 #include <linux/perf_counter.h>
 
@@ -2114,6 +2115,14 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
+
+	/*
+	 * For KSM to handle OOM without deadlock when it's breaking COW in a
+	 * likely victim of the OOM killer, we must serialize with ksm_exit()
+	 * after freeing mm's pages but before freeing its page tables.
+	 */
+	ksm_exit(mm, &tlb, end);
+
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
