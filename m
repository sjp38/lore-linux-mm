Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF176B0440
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:17:54 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w132so34230138ita.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:17:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 139si1019894itj.34.2016.11.18.09.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:17:53 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v13 11/18] mm/hmm/mirror: add range monitor helper, to monitor CPU page table update
Date: Fri, 18 Nov 2016 13:18:20 -0500
Message-Id: <1479493107-982-12-git-send-email-jglisse@redhat.com>
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

Complement the hmm_vma_range_lock/unlock() mechanism with a range monitor that do
not block CPU page table invalidation and thus do not garanty forward progress. It
is still usefull as in many situations concurrent CPU page table update and CPU
snapshot are taking place in different region of the virtual address space.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h | 18 ++++++++++
 mm/hmm.c            | 95 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 112 insertions(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index c0b1c07..6571647 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -254,6 +254,24 @@ int hmm_vma_range_lock(struct hmm_range *range,
 void hmm_vma_range_unlock(struct hmm_range *range);
 
 
+/*
+ * Monitoring a range allow to track any CPU page table modification that can
+ * affect the range. It complements the hmm_vma_range_lock/unlock() mechanism
+ * as a non blocking method for synchronizing device page table with the CPU
+ * page table. See functions description in mm/hmm.c for documentation.
+ *
+ * NOTE AFTER A CALL TO hmm_vma_range_monitor_start() THAT RETURNED TRUE YOU
+ * MUST MAKE A CALL TO hmm_vma_range_monitor_end() BEFORE FREEING THE RANGE
+ * STRUCT OR BAD THING WILL HAPPEN !
+ */
+bool hmm_vma_range_monitor_start(struct hmm_range *range,
+				 struct vm_area_struct *vma,
+				 unsigned long start,
+				 unsigned long end,
+				 bool wait);
+bool hmm_vma_range_monitor_end(struct hmm_range *range);
+
+
 /* Below are for HMM internal use only ! Not to be use by device driver ! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/hmm.c b/mm/hmm.c
index ee05419..746eb96 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -40,6 +40,7 @@ struct hmm {
 	spinlock_t		lock;
 	struct list_head	ranges;
 	struct list_head	mirrors;
+	struct list_head	monitors;
 	atomic_t		sequence;
 	wait_queue_head_t	wait_queue;
 	struct mmu_notifier	mmu_notifier;
@@ -65,6 +66,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 			return NULL;
 		init_waitqueue_head(&hmm->wait_queue);
 		atomic_set(&hmm->notifier_count, 0);
+		INIT_LIST_HEAD(&hmm->monitors);
 		INIT_LIST_HEAD(&hmm->mirrors);
 		atomic_set(&hmm->sequence, 0);
 		hmm->mmu_notifier.ops = NULL;
@@ -112,7 +114,7 @@ static void hmm_invalidate_range(struct hmm *hmm,
 				 unsigned long start,
 				 unsigned long end)
 {
-	struct hmm_range range, *tmp;
+	struct hmm_range range, *tmp, *next;
 	struct hmm_mirror *mirror;
 
 	/*
@@ -127,6 +129,13 @@ static void hmm_invalidate_range(struct hmm *hmm,
 	range.hmm = hmm;
 
 	spin_lock(&hmm->lock);
+	/* Remove any range monitors */
+	list_for_each_entry_safe (tmp, next, &hmm->monitors, list) {
+		if (range.start >= tmp->end || range.end <= tmp->start)
+			continue;
+		/* This range is no longer valid */
+		list_del_init(&tmp->list);
+	}
 	list_for_each_entry (tmp, &hmm->ranges, list) {
 		if (range.start >= tmp->end || range.end <= tmp->start)
 			continue;
@@ -361,3 +370,87 @@ void hmm_vma_range_unlock(struct hmm_range *range)
 		wake_up(&hmm->wait_queue);
 }
 EXPORT_SYMBOL(hmm_vma_range_unlock);
+
+
+/*
+ * hmm_vma_range_monitor_start() - start monitoring of a range
+ * @range: pointer to hmm_range struct use to monitor
+ * @vma: virtual memory area for the range
+ * @start: start address of the range to monitor (inclusive)
+ * @end: end address of the range to monitor (exclusive)
+ * @wait: wait for any pending CPU page table to finish
+ * Returns: false if there is pendding CPU page table update, true otherwise
+ *
+ * The use pattern of this function is :
+ *   retry:
+ *       hmm_vma_range_monitor_start(range, vma, start, end, true);
+ *       // Do something that rely on stable CPU page table content but do not
+ *       // Prepare device page table update transaction
+ *       ...
+ *       // Take device driver lock that serialize device page table update
+ *       driver_lock_device_page_table_update();
+ *       if (!hmm_vma_range_monitor_end(range)) {
+ *           driver_unlock_device_page_table_update();
+ *           // Abort transaction you just build and cleanup anything that need
+ *           // to be. Same comment as above, about avoiding busy loop.
+ *           goto retry;
+ *       }
+ *       // Commit device page table update
+ *       driver_unlock_device_page_table_update();
+ */
+bool hmm_vma_range_monitor_start(struct hmm_range *range,
+				 struct vm_area_struct *vma,
+				 unsigned long start,
+				 unsigned long end,
+				 bool wait)
+{
+	BUG_ON(!vma);
+	BUG_ON(!range);
+
+	INIT_LIST_HEAD(&range->list);
+	range->hmm = hmm_register(vma->vm_mm);
+	if (!range->hmm)
+		return false;
+
+again:
+	spin_lock(&range->hmm->lock);
+	if (atomic_read(&range->hmm->notifier_count)) {
+		spin_unlock(&range->hmm->lock);
+		if (!wait)
+			return false;
+		/*
+		 * FIXME: Wait for all active mmu_notifier this is because we
+		 * can no keep an hmm_range struct around while waiting for
+		 * range invalidation to finish. Need to update mmu_notifier
+		 * to make this doable.
+		 */
+		wait_event(range->hmm->wait_queue,
+			   !atomic_read(&range->hmm->notifier_count));
+		goto again;
+	}
+	list_add_tail(&range->list, &range->hmm->monitors);
+	spin_unlock(&range->hmm->lock);
+	return true;
+}
+EXPORT_SYMBOL(hmm_vma_range_monitor_start);
+
+/*
+ * hmm_vma_range_monitor_end() - end monitoring of a range
+ * @range: range that was being monitored
+ * Returns: true if no invalidation since hmm_vma_range_monitor_start()
+ */
+bool hmm_vma_range_monitor_end(struct hmm_range *range)
+{
+	bool valid;
+
+	if (!range->hmm || list_empty(&range->list))
+		return false;
+
+	spin_lock(&range->hmm->lock);
+	valid = !list_empty(&range->list);
+	list_del_init(&range->list);
+	spin_unlock(&range->hmm->lock);
+
+	return valid;
+}
+EXPORT_SYMBOL(hmm_vma_range_monitor_end);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
