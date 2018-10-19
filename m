Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 16C856B026C
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 12:04:56 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x7-v6so37121754qtb.6
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 09:04:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f4-v6si12636280qkg.151.2018.10.19.09.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 09:04:55 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 6/6] mm/hmm: invalidate device page table at start of invalidation
Date: Fri, 19 Oct 2018 12:04:42 -0400
Message-Id: <20181019160442.18723-7-jglisse@redhat.com>
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
 mm/hmm.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 0eacf9627bc9..1aecf7c08cff 100644
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
@@ -126,7 +123,7 @@ void hmm_mm_destroy(struct mm_struct *mm)
 	kfree(mm->hmm);
 }
 
-static int hmm_invalidate_range(struct hmm *hmm,
+static int hmm_invalidate_range(struct hmm *hmm, bool device,
 				const struct hmm_update *update)
 {
 	struct hmm_mirror *mirror;
@@ -147,6 +144,9 @@ static int hmm_invalidate_range(struct hmm *hmm,
 	}
 	spin_unlock(&hmm->lock);
 
+	if (!device)
+		return 0;
+
 	down_read(&hmm->mirrors_sem);
 	list_for_each_entry(mirror, &hmm->mirrors, list) {
 		int ret;
@@ -189,18 +189,21 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
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
+	struct hmm_update update;
 	struct hmm *hmm = mm->hmm;
 
 	VM_BUG_ON(!hmm);
 
-	atomic_inc(&hmm->sequence);
-
-	return 0;
+	update.start = start;
+	update.end = end;
+	update.event = HMM_UPDATE_INVALIDATE;
+	update.blockable = blockable;
+	return hmm_invalidate_range(hmm, true, &update);
 }
 
 static void hmm_invalidate_range_end(struct mmu_notifier *mn,
@@ -217,7 +220,7 @@ static void hmm_invalidate_range_end(struct mmu_notifier *mn,
 	update.end = end;
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = true;
-	hmm_invalidate_range(hmm, &update);
+	hmm_invalidate_range(hmm, false, &update);
 }
 
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
-- 
2.17.2
