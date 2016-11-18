Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83F016B043F
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:17:53 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b132so34861659iti.5
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:17:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 139si2739572itv.64.2016.11.18.09.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:17:52 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v13 10/18] mm/hmm/mirror: add range lock helper, prevent CPU page table update for the range
Date: Fri, 18 Nov 2016 13:18:19 -0500
Message-Id: <1479493107-982-11-git-send-email-jglisse@redhat.com>
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

There is two possible strategy when it comes to snapshoting the CPU page table
inside the device page table. First one snapshot the CPU page table and keep
track of active mmu_notifier callback. Once snapshot is done and before updating
the device page table (in an atomic fashion) it check the mmu_notifier sequence.
If sequence is same as the time the CPU page table was snapshot then it means
that no mmu_notifier run in the meantime and hence the snapshot is accurate. If
the sequence is different then one mmu_notifier callback did run and snapshot
might no longer be valid and the whole procedure must be restarted.

Issue with this approach is that it does not garanty forward progress for the
device driver trying to mirror a range of the address space.

The second solution, implemented by this patch, is to serialize CPU snapshot
with mmu_notifier callback and have each waiting on each other according to the
order they happen. This garanty forward progress for driver. The drawback is
that it can stall process waiting on the mmu_notifier callback to finish. So
thing like direct page reclaim (or even indirect one) might stall and this might
increase overall kernel latency.

For now just accept this potential issue and wait to have real world workload to
be affected by it before trying to fix it. Fix is probably to introduce a new
mmu_notifier_try_to_invalidate() that could return failure if it has to wait or
sleep and use it inside reclaim code to decide to skip to next candidate for
reclaimation.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h |  30 ++++++++++++
 mm/hmm.c            | 131 +++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 154 insertions(+), 7 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index f44e270..c0b1c07 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -224,6 +224,36 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
 
+/*
+ * struct hmm_range - track invalidation lock on virtual address range
+ *
+ * @hmm: core hmm struct this range is active against
+ * @list: all range lock are on a list
+ * @start: range virtual start address (inclusive)
+ * @end: range virtual end address (exclusive)
+ * @waiting: pointer to range waiting on this one
+ * @wakeup: use to wakeup the range when it was waiting
+ */
+struct hmm_range {
+	struct hmm		*hmm;
+	struct list_head	list;
+	unsigned long		start;
+	unsigned long		end;
+	struct hmm_range	*waiting;
+	bool			wakeup;
+};
+
+/*
+ * Range locking allow to garanty forward progress by blocking CPU page table
+ * invalidation. See functions description in mm/hmm.c for documentation.
+ */
+int hmm_vma_range_lock(struct hmm_range *range,
+		       struct vm_area_struct *vma,
+		       unsigned long start,
+		       unsigned long end);
+void hmm_vma_range_unlock(struct hmm_range *range);
+
+
 /* Below are for HMM internal use only ! Not to be use by device driver ! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 3594785..ee05419 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -27,7 +27,8 @@
  * struct hmm - HMM per mm struct
  *
  * @mm: mm struct this HMM struct is bound to
- * @lock: lock protecting mirrors list
+ * @lock: lock protecting mirrors and ranges list
+ * @ranges: list of range lock (for snapshot and invalidation serialization)
  * @mirrors: list of mirrors for this mm
  * @wait_queue: wait queue
  * @sequence: we track update to CPU page table with a sequence number
@@ -37,6 +38,7 @@
 struct hmm {
 	struct mm_struct	*mm;
 	spinlock_t		lock;
+	struct list_head	ranges;
 	struct list_head	mirrors;
 	atomic_t		sequence;
 	wait_queue_head_t	wait_queue;
@@ -66,6 +68,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 		INIT_LIST_HEAD(&hmm->mirrors);
 		atomic_set(&hmm->sequence, 0);
 		hmm->mmu_notifier.ops = NULL;
+		INIT_LIST_HEAD(&hmm->ranges);
 		spin_lock_init(&hmm->lock);
 		hmm->mm = mm;
 	}
@@ -104,16 +107,48 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	kfree(hmm);
 }
 
-
-
 static void hmm_invalidate_range(struct hmm *hmm,
 				 enum hmm_update action,
 				 unsigned long start,
 				 unsigned long end)
 {
+	struct hmm_range range, *tmp;
 	struct hmm_mirror *mirror;
 
 	/*
+	 * Serialize invalidation with CPU snapshot (see hmm_vma_range_lock()).
+	 * Need to make change to mmu_notifier so that we can get a struct that
+	 * stay alive accross call to mmu_notifier_invalidate_range_start() and
+	 * mmu_notifier_invalidate_range_end(). FIXME !
+	 */
+	range.waiting = NULL;
+	range.start = start;
+	range.end = end;
+	range.hmm = hmm;
+
+	spin_lock(&hmm->lock);
+	list_for_each_entry (tmp, &hmm->ranges, list) {
+		if (range.start >= tmp->end || range.end <= tmp->start)
+			continue;
+
+		while (tmp->waiting)
+			tmp = tmp->waiting;
+
+		list_add(&range.list, &hmm->ranges);
+		tmp->waiting = &range;
+		range.wakeup = false;
+		spin_unlock(&hmm->lock);
+
+		wait_event(hmm->wait_queue, range.wakeup);
+		return;
+	}
+	list_add(&range.list, &hmm->ranges);
+	spin_unlock(&hmm->lock);
+
+	atomic_inc(&hmm->notifier_count);
+	atomic_inc(&hmm->sequence);
+
+	/*
 	 * Mirror being added or remove is a rare event so list traversal isn't
 	 * protected by a lock, we rely on simple rules. All list modification
 	 * are done using list_add_rcu() and list_del_rcu() under a spinlock to
@@ -127,6 +162,9 @@ static void hmm_invalidate_range(struct hmm *hmm,
 	 */
 	list_for_each_entry (mirror, &hmm->mirrors, list)
 		mirror->ops->update(mirror, action, start, end);
+
+	/* See above FIXME */
+	hmm_vma_range_unlock(&range);
 }
 
 static void hmm_invalidate_page(struct mmu_notifier *mn,
@@ -139,8 +177,6 @@ static void hmm_invalidate_page(struct mmu_notifier *mn,
 
 	VM_BUG_ON(!hmm);
 
-	atomic_inc(&hmm->notifier_count);
-	atomic_inc(&hmm->sequence);
 	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
 	atomic_dec(&hmm->notifier_count);
 	wake_up(&hmm->wait_queue);
@@ -155,8 +191,6 @@ static void hmm_invalidate_range_start(struct mmu_notifier *mn,
 
 	VM_BUG_ON(!hmm);
 
-	atomic_inc(&hmm->notifier_count);
-	atomic_inc(&hmm->sequence);
 	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
 }
 
@@ -244,3 +278,86 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	wait_event(hmm->wait_queue, !atomic_read(&hmm->notifier_count));
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
+
+
+/*
+ * hmm_vma_range_lock() - lock invalidation of a virtual address range
+ * @range: range lock struct provided by caller to track lock while valid
+ * @vma: virtual memory area containing the virtual address range
+ * @start: range virtual start address (inclusive)
+ * @end: range virtual end address (exclusive)
+ * Returns: -EINVAL or -ENOMEM on error, 0 otherwise
+ *
+ * This will block any invalidation to CPU page table for the range of virtual
+ * address provided as argument. Design pattern is :
+ *      hmm_vma_range_lock(vma, start, end, lock);
+ *      hmm_vma_range_get_pfns(vma, start, end, pfns);
+ *      // Device driver goes over each pfn in the pfns array, snapshot of CPU
+ *      // page table and take appropriate actions (use it to populate GPU page
+ *      // table, identify address that need faulting, prepare migration, ...)
+ *      hmm_vma_range_unlock(&lock);
+ *
+ * DO NOT HOLD THE RANGE LOCK FOR LONGER THAN NECESSARY ! THIS DOES BLOCK CPU
+ * PAGE TABLE INVALIDATION !
+ */
+int hmm_vma_range_lock(struct hmm_range *range,
+		       struct vm_area_struct *vma,
+		       unsigned long start,
+		       unsigned long end)
+{
+	struct hmm *hmm;
+
+	VM_BUG_ON(!vma);
+	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+
+	range->hmm = hmm = hmm_register(vma->vm_mm);
+	if (!hmm)
+		return -ENOMEM;
+
+	if (start < vma->vm_start || start >= vma->vm_end)
+		return -EINVAL;
+	if (end < vma->vm_start || end > vma->vm_end)
+		return -EINVAL;
+
+	range->waiting = NULL;
+	range->start = start;
+	range->end = end;
+
+	spin_lock(&hmm->lock);
+	list_add(&range->list, &hmm->ranges);
+	spin_unlock(&hmm->lock);
+
+	/*
+	 * Wait for all active mmu_notifier this is because we can not keep an
+	 * hmm_range struct around while mmu_notifier is between a start and
+	 * end section. This need change to mmu_notifier FIXME !
+	 */
+	wait_event(hmm->wait_queue, !atomic_read(&hmm->notifier_count));
+
+	return 0;
+}
+EXPORT_SYMBOL(hmm_vma_range_lock);
+
+/*
+ * hmm_vma_range_unlock() - unlock invalidation of a virtual address range
+ * @lock: lock struct tracking the range lock
+ *
+ * See hmm_vma_range_lock() for usage.
+ */
+void hmm_vma_range_unlock(struct hmm_range *range)
+{
+	struct hmm *hmm = range->hmm;
+	bool wakeup = false;
+
+	spin_lock(&hmm->lock);
+	list_del(&range->list);
+	if (range->waiting) {
+		range->waiting->wakeup = true;
+		wakeup = true;
+	}
+	spin_unlock(&hmm->lock);
+
+	if (wakeup)
+		wake_up(&hmm->wait_queue);
+}
+EXPORT_SYMBOL(hmm_vma_range_unlock);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
