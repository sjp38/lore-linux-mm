Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6AB6B3131
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 15:25:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id b5-v6so7855328qtk.4
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 12:25:56 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n57-v6si7926198qtk.212.2018.08.24.12.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 12:25:55 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 6/7] mm/hmm: invalidate device page table at start of invalidation
Date: Fri, 24 Aug 2018 15:25:48 -0400
Message-Id: <20180824192549.30844-7-jglisse@redhat.com>
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

Invalidate device page table at start of invalidation and invalidate
in progress CPU page table snapshooting at both start and end of any
invalidation.

This is helpful when device need to dirty page because the device page
table report the page as dirty. Dirtying page must happen in the start
mmu notifier callback and not in the end one.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h |  2 +-
 mm/hmm.c            | 21 ++++++++++++++-------
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index a7f7600b6bb0..064924bce75c 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -325,7 +325,7 @@ struct hmm_mirror_ops {
 	 * synchronous call.
 	 */
 	void (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
-					  const struct hmm_update *update);
+					   const struct hmm_update *update);
 };
 
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index debd2f734ab5..6fe31e2bfa1e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -43,7 +43,6 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
  *
  * @mm: mm struct this HMM struct is bound to
  * @lock: lock protecting ranges list
- * @sequence: we track updates to the CPU page table with a sequence number
  * @ranges: list of range being snapshotted
  * @mirrors: list of mirrors for this mm
  * @mmu_notifier: mmu notifier to track updates to CPU page table
@@ -52,7 +51,6 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 struct hmm {
 	struct mm_struct	*mm;
 	spinlock_t		lock;
-	atomic_t		sequence;
 	struct list_head	ranges;
 	struct list_head	mirrors;
 	struct mmu_notifier	mmu_notifier;
@@ -85,7 +83,6 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 		return NULL;
 	INIT_LIST_HEAD(&hmm->mirrors);
 	init_rwsem(&hmm->mirrors_sem);
-	atomic_set(&hmm->sequence, 0);
 	hmm->mmu_notifier.ops = NULL;
 	INIT_LIST_HEAD(&hmm->ranges);
 	spin_lock_init(&hmm->lock);
@@ -126,8 +123,8 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	kfree(mm->hmm);
 }
 
-static void hmm_invalidate_range(struct hmm *hmm,
-				const struct hmm_update *update)
+static void hmm_invalidate_range(struct hmm *hmm, bool device,
+				 const struct hmm_update *update)
 {
 	struct hmm_mirror *mirror;
 	struct hmm_range *range;
@@ -147,6 +144,9 @@ static void hmm_invalidate_range(struct hmm *hmm,
 	}
 	spin_unlock(&hmm->lock);
 
+	if (!device)
+		return;
+
 	down_read(&hmm->mirrors_sem);
 	list_for_each_entry(mirror, &hmm->mirrors, list)
 		mirror->ops->sync_cpu_device_pagetables(mirror, update);
@@ -185,11 +185,18 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 				      unsigned long end,
 				      bool blockable)
 {
+	struct hmm_update update;
 	struct hmm *hmm = mm->hmm;
 
+	if (!blockable)
+		return -EAGAIN;
+
 	VM_BUG_ON(!hmm);
 
-	atomic_inc(&hmm->sequence);
+	update.start = start;
+	update.end = end;
+	update.event = HMM_UPDATE_INVALIDATE;
+	hmm_invalidate_range(hmm, true, &update);
 
 	return 0;
 }
@@ -207,7 +214,7 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 	update.start = start;
 	update.end = end;
 	update.event = HMM_UPDATE_INVALIDATE;
-	hmm_invalidate_range(hmm, &update);
+	hmm_invalidate_range(hmm, false, &update);
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
-- 
2.17.1
