Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8928A800E0
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 13:58:07 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id u2so5867084oif.11
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 10:58:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u6si1005162otb.45.2018.01.22.10.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 10:58:06 -0800 (PST)
From: jglisse@redhat.com
Subject: [PATCH] mm/hmm: fix uninitialized use of 'entry' in hmm_vma_walk_pmd()
Date: Mon, 22 Jan 2018 13:57:59 -0500
Message-Id: <20180122185759.26286-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Ralph Campbell <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Ralph Campbell <rcampbell@nvidia.com>

The variable 'entry' is used before being initialized in
hmm_vma_walk_pmd()

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/hmm.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index ea19742a5d60..979211c7ccc8 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -418,7 +418,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		}
 
 		if (!pte_present(pte)) {
-			swp_entry_t entry;
+			swp_entry_t entry = pte_to_swp_entry(pte);
 
 			if (!non_swap_entry(entry)) {
 				if (hmm_vma_walk->fault)
@@ -426,8 +426,6 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 				continue;
 			}
 
-			entry = pte_to_swp_entry(pte);
-
 			/*
 			 * This is a special swap entry, ignore migration, use
 			 * device and report anything else as error.
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
