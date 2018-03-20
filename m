Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD2AC6B000D
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:44 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t24so39970qtn.21
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:44 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e29si733357qta.14.2018.03.19.19.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:44 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM client quit
Date: Mon, 19 Mar 2018 22:00:26 -0400
Message-Id: <20180320020038.3360-5-jglisse@redhat.com>
In-Reply-To: <20180320020038.3360-1-jglisse@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
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

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index 6088fa6ed137..667944630dc9 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -244,10 +244,29 @@ EXPORT_SYMBOL(hmm_mirror_register);
 void hmm_mirror_unregister(struct hmm_mirror *mirror)
 {
 	struct hmm *hmm = mirror->hmm;
+	struct mm_struct *mm = NULL;
+	bool unregister = false;
 
 	down_write(&hmm->mirrors_sem);
 	list_del_init(&mirror->list);
+	unregister = list_empty(&hmm->mirrors);
 	up_write(&hmm->mirrors_sem);
+
+	if (!unregister)
+		return;
+
+	spin_lock(&hmm->mm->page_table_lock);
+	if (hmm->mm->hmm == hmm) {
+		mm = hmm->mm;
+		mm->hmm = NULL;
+	}
+	spin_unlock(&hmm->mm->page_table_lock);
+
+	if (mm == NULL)
+		return;
+
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
+	kfree(hmm);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
 
-- 
2.14.3
