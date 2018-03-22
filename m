Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FBCC6B0022
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 21:30:29 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a207so4298790qkb.23
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 18:30:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y18si3820971qta.268.2018.03.21.18.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 18:30:28 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM client quit v3
Date: Wed, 21 Mar 2018 21:30:25 -0400
Message-Id: <20180322013025.7008-1-jglisse@redhat.com>
In-Reply-To: <20180321181614.9968-1-jglisse@redhat.com>
References: <20180321181614.9968-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This code was lost in translation at one point. This properly call
mmu_notifier_unregister_no_release() once last user is gone. This
fix the zombie mm_struct as without this patch we do not drop the
refcount we have on it.

Changed since v1:
  - close race window between a last mirror unregistering and a new
    mirror registering, which could have lead to use after free()
    kind of bug
Changed since v2:
  - Avoid issue if there is multiple call to hmm_mirror_register()
    (which lead to use after free).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 39 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 36 insertions(+), 3 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 34c16297f65e..5b21d458db60 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -233,13 +233,24 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
 	if (!mm || !mirror || !mirror->ops)
 		return -EINVAL;
 
+again:
 	mirror->hmm = hmm_register(mm);
 	if (!mirror->hmm)
 		return -ENOMEM;
 
 	down_write(&mirror->hmm->mirrors_sem);
-	list_add(&mirror->list, &mirror->hmm->mirrors);
-	up_write(&mirror->hmm->mirrors_sem);
+	if (mirror->hmm->mm == NULL) {
+		/*
+		 * A racing hmm_mirror_unregister() is about to destroy the hmm
+		 * struct. Try again to allocate a new one.
+		 */
+		up_write(&mirror->hmm->mirrors_sem);
+		mirror->hmm = NULL;
+		goto again;
+	} else {
+		list_add(&mirror->list, &mirror->hmm->mirrors);
+		up_write(&mirror->hmm->mirrors_sem);
+	}
 
 	return 0;
 }
@@ -254,11 +265,33 @@ EXPORT_SYMBOL(hmm_mirror_register);
  */
 void hmm_mirror_unregister(struct hmm_mirror *mirror)
 {
-	struct hmm *hmm = mirror->hmm;
+	bool should_unregister = false;
+	struct mm_struct *mm;
+	struct hmm *hmm;
+
+	if (mirror->hmm == NULL)
+		return;
 
+	hmm = mirror->hmm;
 	down_write(&hmm->mirrors_sem);
 	list_del_init(&mirror->list);
+	should_unregister = list_empty(&hmm->mirrors);
+	mirror->hmm = NULL;
+	mm = hmm->mm;
+	hmm->mm = NULL;
 	up_write(&hmm->mirrors_sem);
+
+	if (!should_unregister || mm == NULL)
+		return;
+
+	spin_lock(&mm->page_table_lock);
+	if (mm->hmm == hmm) {
+		mm->hmm = NULL;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
+	kfree(hmm);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
 
-- 
2.14.3
