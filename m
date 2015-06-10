Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4678A6B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:32:24 -0400 (EDT)
Received: by padev16 with SMTP id ev16so28493950pad.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:24 -0700 (PDT)
Received: from mail-pd0-x243.google.com (mail-pd0-x243.google.com. [2607:f8b0:400e:c02::243])
        by mx.google.com with ESMTPS id pf6si12299072pbb.67.2015.06.09.23.32.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 23:32:23 -0700 (PDT)
Received: by pdev10 with SMTP id v10so7455420pde.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:23 -0700 (PDT)
From: Wenwei Tao <wenweitaowenwei@gmail.com>
Subject: [RFC PATCH 1/6] mm: add defer mechanism to ksm to make it more suitable
Date: Wed, 10 Jun 2015 14:27:14 +0800
Message-Id: <1433917639-31699-2-git-send-email-wenweitaowenwei@gmail.com>
In-Reply-To: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
References: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, hughd@google.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, wenweitaowenwei@gmail.com

I observe that it is unlikely for KSM to merge new pages from an area
that has already been scanned twice on Android mobile devices, so it's
a waste of power to continue to scan these areas in high frequency.
In this patch a defer mechanism is introduced which is borrowed from
page compaction to KSM. This defer mechanism can automatic lower the scan
frequency in the above case.

Signed-off-by: Wenwei Tao <wenweitaowenwei@gmail.com>
---
 mm/ksm.c |  230 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 203 insertions(+), 27 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 4162dce..54ffcb2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -104,6 +104,7 @@ struct mm_slot {
 	struct list_head mm_list;
 	struct rmap_item *rmap_list;
 	struct mm_struct *mm;
+	unsigned long seqnr;
 };
 
 /**
@@ -117,9 +118,12 @@ struct mm_slot {
  */
 struct ksm_scan {
 	struct mm_slot *mm_slot;
+	struct mm_slot *active_slot;
 	unsigned long address;
 	struct rmap_item **rmap_list;
 	unsigned long seqnr;
+	unsigned long ksm_considered;
+	unsigned int ksm_defer_shift;
 };
 
 /**
@@ -182,6 +186,11 @@ struct rmap_item {
 #define UNSTABLE_FLAG	0x100	/* is a node of the unstable tree */
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
 
+#define ACTIVE_SLOT_FLAG	0x100
+#define ACTIVE_SLOT_SEQNR	0x200
+#define KSM_MAX_DEFER_SHIFT	6
+
+
 /* The stable and unstable tree heads */
 static struct rb_root one_stable_tree[1] = { RB_ROOT };
 static struct rb_root one_unstable_tree[1] = { RB_ROOT };
@@ -197,14 +206,22 @@ static DEFINE_HASHTABLE(mm_slots_hash, MM_SLOTS_HASH_BITS);
 static struct mm_slot ksm_mm_head = {
 	.mm_list = LIST_HEAD_INIT(ksm_mm_head.mm_list),
 };
+
+static struct mm_slot ksm_mm_active = {
+	.mm_list = LIST_HEAD_INIT(ksm_mm_active.mm_list),
+};
+
 static struct ksm_scan ksm_scan = {
 	.mm_slot = &ksm_mm_head,
+	.active_slot = &ksm_mm_active,
 };
 
 static struct kmem_cache *rmap_item_cache;
 static struct kmem_cache *stable_node_cache;
 static struct kmem_cache *mm_slot_cache;
 
+static bool ksm_merged_or_unstable;
+
 /* The number of nodes in the stable tree */
 static unsigned long ksm_pages_shared;
 
@@ -336,6 +353,23 @@ static void insert_to_mm_slots_hash(struct mm_struct *mm,
 	hash_add(mm_slots_hash, &mm_slot->link, (unsigned long)mm);
 }
 
+static void move_to_active_list(struct mm_slot *mm_slot)
+{
+	if (mm_slot && !(mm_slot->seqnr & ACTIVE_SLOT_FLAG)) {
+		if (ksm_run & KSM_RUN_UNMERGE && mm_slot->rmap_list)
+			return;
+		if (mm_slot == ksm_scan.mm_slot) {
+			if (ksm_scan.active_slot == &ksm_mm_active)
+				return;
+			ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
+						struct mm_slot, mm_list);
+		}
+		list_move_tail(&mm_slot->mm_list,
+			&ksm_scan.active_slot->mm_list);
+		mm_slot->seqnr |= (ACTIVE_SLOT_FLAG | ACTIVE_SLOT_SEQNR);
+	}
+}
+
 /*
  * ksmd, and unmerge_and_remove_all_rmap_items(), must not touch an mm's
  * page tables after it has passed through ksm_exit() - which, if necessary,
@@ -772,6 +806,15 @@ static int unmerge_and_remove_all_rmap_items(void)
 	int err = 0;
 
 	spin_lock(&ksm_mmlist_lock);
+	mm_slot = list_entry(ksm_mm_active.mm_list.next,
+			struct mm_slot, mm_list);
+	while (mm_slot != &ksm_mm_active) {
+		list_move_tail(&mm_slot->mm_list, &ksm_mm_head.mm_list);
+		mm_slot->seqnr &= ~(ACTIVE_SLOT_FLAG | ACTIVE_SLOT_SEQNR);
+		mm_slot = list_entry(ksm_mm_active.mm_list.next,
+				struct mm_slot, mm_list);
+	}
+	ksm_scan.active_slot = &ksm_mm_active;
 	ksm_scan.mm_slot = list_entry(ksm_mm_head.mm_list.next,
 						struct mm_slot, mm_list);
 	spin_unlock(&ksm_mmlist_lock);
@@ -790,8 +833,8 @@ static int unmerge_and_remove_all_rmap_items(void)
 			if (err)
 				goto error;
 		}
-
 		remove_trailing_rmap_items(mm_slot, &mm_slot->rmap_list);
+		mm_slot->seqnr = 0;
 
 		spin_lock(&ksm_mmlist_lock);
 		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
@@ -806,6 +849,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 			up_read(&mm->mmap_sem);
 			mmdrop(mm);
 		} else {
+			move_to_active_list(mm_slot);
 			spin_unlock(&ksm_mmlist_lock);
 			up_read(&mm->mmap_sem);
 		}
@@ -1401,6 +1445,9 @@ static void stable_tree_append(struct rmap_item *rmap_item,
 		ksm_pages_sharing++;
 	else
 		ksm_pages_shared++;
+
+	if (!ksm_merged_or_unstable)
+		ksm_merged_or_unstable = true;
 }
 
 /*
@@ -1468,6 +1515,9 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	checksum = calc_checksum(page);
 	if (rmap_item->oldchecksum != checksum) {
 		rmap_item->oldchecksum = checksum;
+		if ((rmap_item->address & UNSTABLE_FLAG) &&
+				!ksm_merged_or_unstable)
+			ksm_merged_or_unstable = true;
 		return;
 	}
 
@@ -1504,6 +1554,31 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	}
 }
 
+static bool skip_active_slot_vma(struct rmap_item ***rmap_list,
+		struct vm_area_struct *vma, struct mm_slot *mm_slot)
+{
+	unsigned char age;
+	struct rmap_item *rmap_item = **rmap_list;
+
+	age = (unsigned char)(ksm_scan.seqnr - mm_slot->seqnr);
+	if (age > 0)
+		return false;
+	if (!(vma->vm_flags & VM_HUGETLB)) {
+		while (rmap_item && rmap_item->address < vma->vm_end) {
+			if (rmap_item->address < vma->vm_start) {
+				**rmap_list = rmap_item->rmap_list;
+				remove_rmap_item_from_tree(rmap_item);
+				free_rmap_item(rmap_item);
+				rmap_item = **rmap_list;
+			} else {
+				*rmap_list = &rmap_item->rmap_list;
+				rmap_item = rmap_item->rmap_list;
+			}
+		}
+		return true;
+	} else
+		return false;
+}
 static struct rmap_item *get_next_rmap_item(struct mm_slot *mm_slot,
 					    struct rmap_item **rmap_list,
 					    unsigned long addr)
@@ -1535,15 +1610,18 @@ static struct rmap_item *get_next_rmap_item(struct mm_slot *mm_slot,
 static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 {
 	struct mm_struct *mm;
-	struct mm_slot *slot;
+	struct mm_slot *slot, *next_slot;
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
 	int nid;
 
-	if (list_empty(&ksm_mm_head.mm_list))
+	if (list_empty(&ksm_mm_head.mm_list) &&
+		list_empty(&ksm_mm_active.mm_list))
 		return NULL;
-
-	slot = ksm_scan.mm_slot;
+	if (ksm_scan.active_slot != &ksm_mm_active)
+		slot = ksm_scan.active_slot;
+	else
+		slot = ksm_scan.mm_slot;
 	if (slot == &ksm_mm_head) {
 		/*
 		 * A number of pages can hang around indefinitely on per-cpu
@@ -1582,8 +1660,16 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 			root_unstable_tree[nid] = RB_ROOT;
 
 		spin_lock(&ksm_mmlist_lock);
-		slot = list_entry(slot->mm_list.next, struct mm_slot, mm_list);
-		ksm_scan.mm_slot = slot;
+		if (unlikely(ksm_scan.seqnr == 0 &&
+			!list_empty(&ksm_mm_active.mm_list))) {
+			slot = list_entry(ksm_mm_active.mm_list.next,
+				struct mm_slot, mm_list);
+			ksm_scan.active_slot = slot;
+		} else {
+			slot = list_entry(slot->mm_list.next,
+				struct mm_slot, mm_list);
+			ksm_scan.mm_slot = slot;
+		}
 		spin_unlock(&ksm_mmlist_lock);
 		/*
 		 * Although we tested list_empty() above, a racing __ksm_exit
@@ -1608,7 +1694,8 @@ next_mm:
 			continue;
 		if (ksm_scan.address < vma->vm_start)
 			ksm_scan.address = vma->vm_start;
-		if (!vma->anon_vma)
+		if (!vma->anon_vma || (ksm_scan.active_slot == slot &&
+			skip_active_slot_vma(&ksm_scan.rmap_list, vma, slot)))
 			ksm_scan.address = vma->vm_end;
 
 		while (ksm_scan.address < vma->vm_end) {
@@ -1639,6 +1726,9 @@ next_mm:
 			ksm_scan.address += PAGE_SIZE;
 			cond_resched();
 		}
+		if ((slot->seqnr & (ACTIVE_SLOT_FLAG | ACTIVE_SLOT_SEQNR)) ==
+			ACTIVE_SLOT_FLAG && vma->vm_flags & VM_HUGETLB)
+			vma->vm_flags &= ~VM_HUGETLB;
 	}
 
 	if (ksm_test_exit(mm)) {
@@ -1652,8 +1742,25 @@ next_mm:
 	remove_trailing_rmap_items(slot, ksm_scan.rmap_list);
 
 	spin_lock(&ksm_mmlist_lock);
-	ksm_scan.mm_slot = list_entry(slot->mm_list.next,
-						struct mm_slot, mm_list);
+	slot->seqnr &= ~SEQNR_MASK;
+	slot->seqnr |= (ksm_scan.seqnr & SEQNR_MASK);
+	next_slot = list_entry(slot->mm_list.next,
+		struct mm_slot, mm_list);
+	if (slot == ksm_scan.active_slot) {
+		if (slot->seqnr & ACTIVE_SLOT_SEQNR)
+			slot->seqnr &= ~ACTIVE_SLOT_SEQNR;
+		else {
+			slot->seqnr &= ~ACTIVE_SLOT_FLAG;
+			list_move_tail(&slot->mm_list,
+				&ksm_scan.mm_slot->mm_list);
+		}
+		ksm_scan.active_slot = next_slot;
+	} else
+		ksm_scan.mm_slot = next_slot;
+
+	if (ksm_scan.active_slot == &ksm_mm_active)
+		ksm_scan.active_slot = list_entry(ksm_mm_active.mm_list.next,
+					struct mm_slot, mm_list);
 	if (ksm_scan.address == 0) {
 		/*
 		 * We've completed a full scan of all vmas, holding mmap_sem
@@ -1664,6 +1771,9 @@ next_mm:
 		 * or when all VM_MERGEABLE areas have been unmapped (and
 		 * mmap_sem then protects against race with MADV_MERGEABLE).
 		 */
+		if (ksm_scan.active_slot == slot)
+			ksm_scan.active_slot = list_entry(slot->mm_list.next,
+						struct mm_slot, mm_list);
 		hash_del(&slot->link);
 		list_del(&slot->mm_list);
 		spin_unlock(&ksm_mmlist_lock);
@@ -1678,10 +1788,13 @@ next_mm:
 	}
 
 	/* Repeat until we've completed scanning the whole list */
-	slot = ksm_scan.mm_slot;
-	if (slot != &ksm_mm_head)
+	if (ksm_scan.active_slot != &ksm_mm_active) {
+		slot = ksm_scan.active_slot;
 		goto next_mm;
-
+	} else if (ksm_scan.mm_slot != &ksm_mm_head) {
+		slot = ksm_scan.mm_slot;
+		goto next_mm;
+	}
 	ksm_scan.seqnr++;
 	return NULL;
 }
@@ -1705,9 +1818,40 @@ static void ksm_do_scan(unsigned int scan_npages)
 	}
 }
 
+/*This is copyed from page compaction*/
+
+static inline void defer_ksm(void)
+{
+	ksm_scan.ksm_considered = 0;
+	if (++ksm_scan.ksm_defer_shift > KSM_MAX_DEFER_SHIFT)
+		ksm_scan.ksm_defer_shift = KSM_MAX_DEFER_SHIFT;
+
+}
+
+static inline bool ksm_defered(void)
+{
+	unsigned long defer_limit = 1UL << ksm_scan.ksm_defer_shift;
+
+	if (++ksm_scan.ksm_considered > defer_limit)
+		ksm_scan.ksm_considered = defer_limit;
+	return ksm_scan.ksm_considered < defer_limit &&
+			list_empty(&ksm_mm_active.mm_list);
+}
+
+static inline void reset_ksm_defer(void)
+{
+	if (ksm_scan.ksm_defer_shift != 0) {
+		ksm_scan.ksm_considered = 0;
+		ksm_scan.ksm_defer_shift = 0;
+	}
+}
+
+
 static int ksmd_should_run(void)
 {
-	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
+	return (ksm_run & KSM_RUN_MERGE) &&
+		!(list_empty(&ksm_mm_head.mm_list) &&
+			list_empty(&ksm_mm_active.mm_list));
 }
 
 static int ksm_scan_thread(void *nothing)
@@ -1718,8 +1862,14 @@ static int ksm_scan_thread(void *nothing)
 	while (!kthread_should_stop()) {
 		mutex_lock(&ksm_thread_mutex);
 		wait_while_offlining();
-		if (ksmd_should_run())
+		if (ksmd_should_run() && !ksm_defered()) {
+			ksm_merged_or_unstable = false;
 			ksm_do_scan(ksm_thread_pages_to_scan);
+			if (ksm_merged_or_unstable)
+				reset_ksm_defer();
+			else
+				defer_ksm();
+		}
 		mutex_unlock(&ksm_thread_mutex);
 
 		try_to_freeze();
@@ -1739,6 +1889,8 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
+	unsigned long vma_length =
+			(vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
 	int err;
 
 	switch (advice) {
@@ -1761,8 +1913,19 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 			if (err)
 				return err;
 		}
-
-		*vm_flags |= VM_MERGEABLE;
+		/*
+		* Since hugetlb vma is not supported by ksm
+		* use VM_HUGETLB to indicate new mergeable vma
+		*/
+		*vm_flags |= VM_MERGEABLE | VM_HUGETLB;
+		if (vma_length > ksm_thread_pages_to_scan) {
+			struct mm_slot *mm_slot;
+
+			spin_lock(&ksm_mmlist_lock);
+			mm_slot = get_mm_slot(mm);
+			move_to_active_list(mm_slot);
+			spin_unlock(&ksm_mmlist_lock);
+		}
 		break;
 
 	case MADV_UNMERGEABLE:
@@ -1775,7 +1938,7 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 				return err;
 		}
 
-		*vm_flags &= ~VM_MERGEABLE;
+		*vm_flags &= ~(VM_MERGEABLE | VM_HUGETLB);
 		break;
 	}
 
@@ -1792,7 +1955,8 @@ int __ksm_enter(struct mm_struct *mm)
 		return -ENOMEM;
 
 	/* Check ksm_run too?  Would need tighter locking */
-	needs_wakeup = list_empty(&ksm_mm_head.mm_list);
+	needs_wakeup = list_empty(&ksm_mm_head.mm_list) &&
+			list_empty(&ksm_mm_active.mm_list);
 
 	spin_lock(&ksm_mmlist_lock);
 	insert_to_mm_slots_hash(mm, mm_slot);
@@ -1806,10 +1970,8 @@ int __ksm_enter(struct mm_struct *mm)
 	 * scanning cursor, otherwise KSM pages in newly forked mms will be
 	 * missed: then we might as well insert at the end of the list.
 	 */
-	if (ksm_run & KSM_RUN_UNMERGE)
-		list_add_tail(&mm_slot->mm_list, &ksm_mm_head.mm_list);
-	else
-		list_add_tail(&mm_slot->mm_list, &ksm_scan.mm_slot->mm_list);
+	list_add_tail(&mm_slot->mm_list, &ksm_scan.active_slot->mm_list);
+	mm_slot->seqnr |= (ACTIVE_SLOT_FLAG | ACTIVE_SLOT_SEQNR);
 	spin_unlock(&ksm_mmlist_lock);
 
 	set_bit(MMF_VM_MERGEABLE, &mm->flags);
@@ -1823,7 +1985,7 @@ int __ksm_enter(struct mm_struct *mm)
 
 void __ksm_exit(struct mm_struct *mm)
 {
-	struct mm_slot *mm_slot;
+	struct mm_slot *mm_slot, *current_slot;
 	int easy_to_free = 0;
 
 	/*
@@ -1837,14 +1999,28 @@ void __ksm_exit(struct mm_struct *mm)
 
 	spin_lock(&ksm_mmlist_lock);
 	mm_slot = get_mm_slot(mm);
-	if (mm_slot && ksm_scan.mm_slot != mm_slot) {
+	if (ksm_scan.active_slot != &ksm_mm_active)
+		current_slot = ksm_scan.active_slot;
+	else
+		current_slot = ksm_scan.mm_slot;
+	if (mm_slot && mm_slot != current_slot) {
 		if (!mm_slot->rmap_list) {
 			hash_del(&mm_slot->link);
 			list_del(&mm_slot->mm_list);
 			easy_to_free = 1;
 		} else {
-			list_move(&mm_slot->mm_list,
-				  &ksm_scan.mm_slot->mm_list);
+			if (mm_slot == ksm_scan.mm_slot)
+				ksm_scan.mm_slot =
+					list_entry(mm_slot->mm_list.next,
+						struct mm_slot, mm_list);
+			if (ksm_run & KSM_RUN_UNMERGE)
+				list_move(&mm_slot->mm_list,
+					&ksm_scan.mm_slot->mm_list);
+			else {
+				list_move(&mm_slot->mm_list,
+					&ksm_scan.active_slot->mm_list);
+				mm_slot->seqnr |= ACTIVE_SLOT_FLAG;
+			}
 		}
 	}
 	spin_unlock(&ksm_mmlist_lock);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
