Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5D516B026A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 12:04:55 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s123-v6so35680361qkf.12
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 09:04:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w64-v6si840612qkb.193.2018.10.19.09.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 09:04:54 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 5/6] mm/hmm: use a structure for update callback parameters v2
Date: Fri, 19 Oct 2018 12:04:41 -0400
Message-Id: <20181019160442.18723-6-jglisse@redhat.com>
In-Reply-To: <20181019160442.18723-1-jglisse@redhat.com>
References: <20181019160442.18723-1-jglisse@redhat.com>
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

The hmm_update structure is always associated with a mmu_notifier
callbacks so we are not planing on grouping multiple updates together.
Nor do we care about page size for the range as range will over fully
cover the page being invalidated (this is a mmu_notifier property).

Changed since v1:
    - support for blockable mmu_notifier flags
    - improved commit log

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h | 31 ++++++++++++++++++++++---------
 mm/hmm.c            | 33 ++++++++++++++++++++++-----------
 2 files changed, 44 insertions(+), 20 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 1ff4bae7ada7..afc04dbbaf2f 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -274,13 +274,28 @@ static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
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
+ * @blockable: can the callback block/sleep ?
+ */
+struct hmm_update {
+	unsigned long start;
+	unsigned long end;
+	enum hmm_update_event event;
+	bool blockable;
+};
+
 /*
  * struct hmm_mirror_ops - HMM mirror device operations callback
  *
@@ -300,9 +315,9 @@ struct hmm_mirror_ops {
 	/* sync_cpu_device_pagetables() - synchronize page tables
 	 *
 	 * @mirror: pointer to struct hmm_mirror
-	 * @update_type: type of update that occurred to the CPU page table
-	 * @start: virtual start address of the range to update
-	 * @end: virtual end address of the range to update
+	 * @update: update informations (see struct hmm_update)
+	 * Returns: -EAGAIN if update.blockable false and callback need to
+	 *          block, 0 otherwise.
 	 *
 	 * This callback ultimately originates from mmu_notifiers when the CPU
 	 * page table is updated. The device driver must update its page table
@@ -313,10 +328,8 @@ struct hmm_mirror_ops {
 	 * page tables are completely updated (TLBs flushed, etc); this is a
 	 * synchronous call.
 	 */
-	void (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
-					   enum hmm_update_type update_type,
-					   unsigned long start,
-					   unsigned long end);
+	int (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
+					  const struct hmm_update *update);
 };
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index a7aff319bc5a..0eacf9627bc9 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -126,10 +126,8 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	kfree(mm->hmm);
 }
 
-static void hmm_invalidate_range(struct hmm *hmm,
-				 enum hmm_update_type action,
-				 unsigned long start,
-				 unsigned long end)
+static int hmm_invalidate_range(struct hmm *hmm,
+				const struct hmm_update *update)
 {
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
@@ -138,22 +136,30 @@ static void hmm_invalidate_range(struct hmm *hmm,
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
-	list_for_each_entry(mirror, &hmm->mirrors, list)
-		mirror->ops->sync_cpu_device_pagetables(mirror, action,
-							start, end);
+	list_for_each_entry(mirror, &hmm->mirrors, list) {
+		int ret;
+
+		ret = mirror->ops->sync_cpu_device_pagetables(mirror, update);
+		if (!update->blockable && ret == -EAGAIN) {
+			up_read(&hmm->mirrors_sem);
+			return -EAGAIN;
+		}
+	}
 	up_read(&hmm->mirrors_sem);
+
+	return 0;
 }
 
 static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
@@ -202,11 +208,16 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
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
+	update.blockable = true;
+	hmm_invalidate_range(hmm, &update);
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
-- 
2.17.2
