Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE96A6B312F
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 15:25:55 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d194-v6so8459871qkb.12
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 12:25:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t28-v6si2188486qta.348.2018.08.24.12.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 12:25:55 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 5/7] mm/hmm: use a structure for update callback parameters
Date: Fri, 24 Aug 2018 15:25:47 -0400
Message-Id: <20180824192549.30844-6-jglisse@redhat.com>
In-Reply-To: <20180824192549.30844-1-jglisse@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Use a structure to gather all the parameters for the update callback.
This make it easier when adding new parameters by avoiding having to
update all callback function signature.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h | 25 +++++++++++++++++--------
 mm/hmm.c            | 27 ++++++++++++++-------------
 2 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1ff4bae7ada7..a7f7600b6bb0 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -274,13 +274,26 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
 struct hmm_mirror;
 
 /*
- * enum hmm_update_type - type of update
+ * enum hmm_update_event - type of update
  * @HMM_UPDATE_INVALIDATE: invalidate range (no indication as to why)
  */
-enum hmm_update_type {
+enum hmm_update_event {
 	HMM_UPDATE_INVALIDATE,
 };
 
+/*
+ * struct hmm_update - HMM update informations for callback
+ *
+ * @start: virtual start address of the range to update
+ * @end: virtual end address of the range to update
+ * @event: event triggering the update (what is happening)
+ */
+struct hmm_update {
+	unsigned long start;
+	unsigned long end;
+	enum hmm_update_event event;
+};
+
 /*
  * struct hmm_mirror_ops - HMM mirror device operations callback
  *
@@ -300,9 +313,7 @@ struct hmm_mirror_ops {
 	/* sync_cpu_device_pagetables() - synchronize page tables
 	 *
 	 * @mirror: pointer to struct hmm_mirror
-	 * @update_type: type of update that occurred to the CPU page table
-	 * @start: virtual start address of the range to update
-	 * @end: virtual end address of the range to update
+	 * @update: update informations (see struct hmm_update)
 	 *
 	 * This callback ultimately originates from mmu_notifiers when the CPU
 	 * page table is updated. The device driver must update its page table
@@ -314,9 +325,7 @@ struct hmm_mirror_ops {
 	 * synchronous call.
 	 */
 	void (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
-					   enum hmm_update_type update_type,
-					   unsigned long start,
-					   unsigned long end);
+					  const struct hmm_update *update);
 };
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 659efc9aada6..debd2f734ab5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -127,9 +127,7 @@ void hmm_mm_destroy(struct mm_struct *mm)
 }
 
 static void hmm_invalidate_range(struct hmm *hmm,
-				 enum hmm_update_type action,
-				 unsigned long start,
-				 unsigned long end)
+				const struct hmm_update *update)
 {
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
@@ -138,21 +136,20 @@ static void hmm_invalidate_range(struct hmm *hmm,
 	list_for_each_entry(range, &hmm->ranges, list) {
 		unsigned long addr, idx, npages;
 
-		if (end < range->start || start >= range->end)
+		if (update->end < range->start || update->start >= range->end)
 			continue;
 
 		range->valid = false;
-		addr = max(start, range->start);
+		addr = max(update->start, range->start);
 		idx = (addr - range->start) >> PAGE_SHIFT;
-		npages = (min(range->end, end) - addr) >> PAGE_SHIFT;
+		npages = (min(range->end, update->end) - addr) >> PAGE_SHIFT;
 		memset(&range->pfns[idx], 0, sizeof(*range->pfns) * npages);
 	}
 	spin_unlock(&hmm->lock);
 
 	down_read(&hmm->mirrors_sem);
 	list_for_each_entry(mirror, &hmm->mirrors, list)
-		mirror->ops->sync_cpu_device_pagetables(mirror, action,
-							start, end);
+		mirror->ops->sync_cpu_device_pagetables(mirror, update);
 	up_read(&hmm->mirrors_sem);
 }
 
@@ -183,10 +180,10 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 }
 
 static int hmm_invalidate_range_start(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start,
-				       unsigned long end,
-				       bool blockable)
+				      struct mm_struct *mm,
+				      unsigned long start,
+				      unsigned long end,
+				      bool blockable)
 {
 	struct hmm *hmm = mm->hmm;
 
@@ -202,11 +199,15 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 				     unsigned long start,
 				     unsigned long end)
 {
+	struct hmm_update update;
 	struct hmm *hmm = mm->hmm;
 
 	VM_BUG_ON(!hmm);
 
-	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
+	update.start = start;
+	update.end = end;
+	update.event = HMM_UPDATE_INVALIDATE;
+	hmm_invalidate_range(hmm, &update);
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
-- 
2.17.1
