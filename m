Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE146B312F
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 15:25:55 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t9-v6so8649515qkl.2
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 12:25:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b24-v6si4098549qtk.113.2018.08.24.12.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 12:25:54 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 3/7] mm/hmm: fix race between hmm_mirror_unregister() and mmu_notifier callback
Date: Fri, 24 Aug 2018 15:25:45 -0400
Message-Id: <20180824192549.30844-4-jglisse@redhat.com>
In-Reply-To: <20180824192549.30844-1-jglisse@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org

From: Ralph Campbell <rcampbell@nvidia.com>

In hmm_mirror_unregister(), mm->hmm is set to NULL and then
mmu_notifier_unregister_no_release() is called. That creates a small
window where mmu_notifier can call mmu_notifier_ops with mm->hmm equal
to NULL. Fix this by first unregistering mmu notifier callbacks and
then setting mm->hmm to NULL.

Similarly in hmm_register(), set mm->hmm before registering mmu_notifier
callbacks so callback functions always see mm->hmm set.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org
---
 mm/hmm.c | 36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 9a068a1da487..a16678d08127 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -91,16 +91,6 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 	spin_lock_init(&hmm->lock);
 	hmm->mm = mm;
 
-	/*
-	 * We should only get here if hold the mmap_sem in write mode ie on
-	 * registration of first mirror through hmm_mirror_register()
-	 */
-	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
-	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
-		kfree(hmm);
-		return NULL;
-	}
-
 	spin_lock(&mm->page_table_lock);
 	if (!mm->hmm)
 		mm->hmm = hmm;
@@ -108,12 +98,27 @@ static struct hmm *hmm_register(struct mm_struct *mm)
 		cleanup = true;
 	spin_unlock(&mm->page_table_lock);
 
-	if (cleanup) {
-		mmu_notifier_unregister(&hmm->mmu_notifier, mm);
-		kfree(hmm);
-	}
+	if (cleanup)
+		goto error;
+
+	/*
+	 * We should only get here if hold the mmap_sem in write mode ie on
+	 * registration of first mirror through hmm_mirror_register()
+	 */
+	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
+	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
+		goto error_mm;
 
 	return mm->hmm;
+
+error_mm:
+	spin_lock(&mm->page_table_lock);
+	if (mm->hmm == hmm)
+		mm->hmm = NULL;
+	spin_unlock(&mm->page_table_lock);
+error:
+	kfree(hmm);
+	return NULL;
 }
 
 void hmm_mm_destroy(struct mm_struct *mm)
@@ -278,12 +283,13 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 	if (!should_unregister || mm == NULL)
 		return;
 
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
+
 	spin_lock(&mm->page_table_lock);
 	if (mm->hmm == hmm)
 		mm->hmm = NULL;
 	spin_unlock(&mm->page_table_lock);
 
-	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
 	kfree(hmm);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
-- 
2.17.1
