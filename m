Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0886B3133
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 15:25:57 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y130-v6so8635507qka.1
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 12:25:57 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j18-v6si4515277qtj.294.2018.08.24.12.25.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 12:25:56 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 7/7] mm/hmm: proper support for blockable mmu_notifier
Date: Fri, 24 Aug 2018 15:25:49 -0400
Message-Id: <20180824192549.30844-8-jglisse@redhat.com>
In-Reply-To: <20180824192549.30844-1-jglisse@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

When mmu_notifier calls invalidate_range_start callback with blockable
set to false we should not sleep. Properly propagate this to HMM users.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h | 12 +++++++++---
 mm/hmm.c            | 39 ++++++++++++++++++++++++++++-----------
 2 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 064924bce75c..c783916f8732 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -287,11 +287,13 @@ enum hmm_update_event {
  * @start: virtual start address of the range to update
  * @end: virtual end address of the range to update
  * @event: event triggering the update (what is happening)
+ * @blockable: can the callback block/sleep ?
  */
 struct hmm_update {
 	unsigned long start;
 	unsigned long end;
 	enum hmm_update_event event;
+	bool blockable;
 };
 
 /*
@@ -314,6 +316,8 @@ struct hmm_mirror_ops {
 	 *
 	 * @mirror: pointer to struct hmm_mirror
 	 * @update: update informations (see struct hmm_update)
+	 * Returns: -EAGAIN if update.blockable false and callback need to
+	 *          block, 0 otherwise.
 	 *
 	 * This callback ultimately originates from mmu_notifiers when the CPU
 	 * page table is updated. The device driver must update its page table
@@ -322,10 +326,12 @@ struct hmm_mirror_ops {
 	 *
 	 * The device driver must not return from this callback until the device
 	 * page tables are completely updated (TLBs flushed, etc); this is a
-	 * synchronous call.
+	 * synchronous call. If driver need to sleep and update->blockable is
+	 * false then you need to abort (do not do anything that would sleep or
+	 * block) and return -EAGAIN.
 	 */
-	void (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
-					   const struct hmm_update *update);
+	int (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
+					  const struct hmm_update *update);
 };
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 6fe31e2bfa1e..1d8fcaa0606f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -123,12 +123,18 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	kfree(mm->hmm);
 }
 
-static void hmm_invalidate_range(struct hmm *hmm, bool device,
-				 const struct hmm_update *update)
+static int hmm_invalidate_range(struct hmm *hmm, bool device,
+				const struct hmm_update *update)
 {
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
 
+	/*
+	 * It is fine to wait on lock here even if update->blockable is false
+	 * as the hmm->lock is only held for short period of time (when adding
+	 * or walking the ranges list). We could also convert the range list
+	 * into a lru list and avoid the spinlock all together.
+	 */
 	spin_lock(&hmm->lock);
 	list_for_each_entry(range, &hmm->ranges, list) {
 		unsigned long addr, idx, npages;
@@ -145,12 +151,26 @@ static void hmm_invalidate_range(struct hmm *hmm, bool device,
 	spin_unlock(&hmm->lock);
 
 	if (!device)
-		return;
+		return 0;
 
+	/*
+	 * It is fine to wait on mirrors_sem here even if update->blockable is
+	 * false as this semaphore is only taken in write mode for short period
+	 * when adding a new mirror to the list.
+	 */
 	down_read(&hmm->mirrors_sem);
-	list_for_each_entry(mirror, &hmm->mirrors, list)
-		mirror->ops->sync_cpu_device_pagetables(mirror, update);
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
@@ -188,17 +208,13 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	struct hmm_update update;
 	struct hmm *hmm = mm->hmm;
 
-	if (!blockable)
-		return -EAGAIN;
-
 	VM_BUG_ON(!hmm);
 
 	update.start = start;
 	update.end = end;
 	update.event = HMM_UPDATE_INVALIDATE;
-	hmm_invalidate_range(hmm, true, &update);
-
-	return 0;
+	update.blockable = blockable;
+	return hmm_invalidate_range(hmm, true, &update);
 }
 
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
@@ -214,6 +230,7 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 	update.start = start;
 	update.end = end;
 	update.event = HMM_UPDATE_INVALIDATE;
+	update.blockable = true;
 	hmm_invalidate_range(hmm, false, &update);
 }
 
-- 
2.17.1
