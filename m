Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8316B45EA
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:20:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a26-v6so968558pgw.7
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 04:20:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u189-v6sor179715pgd.416.2018.08.28.04.20.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 04:20:49 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 1/3] mm/cow: don't bother write protectig already write-protected huge pages
Date: Tue, 28 Aug 2018 21:20:32 +1000
Message-Id: <20180828112034.30875-2-npiggin@gmail.com>
In-Reply-To: <20180828112034.30875-1-npiggin@gmail.com>
References: <20180828112034.30875-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

This is the THP equivalent for 1b2de5d039c8 ("mm/cow: don't bother write
protecting already write-protected pages").

Explicit hugetlb pages don't get the same treatment because they don't
appear to have the right accessor functions.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/huge_memory.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9592cbd8530a..d9bae12978ef 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -973,8 +973,11 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	mm_inc_nr_ptes(dst_mm);
 	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 
-	pmdp_set_wrprotect(src_mm, addr, src_pmd);
-	pmd = pmd_mkold(pmd_wrprotect(pmd));
+	if (pmd_write(pmd)) {
+		pmdp_set_wrprotect(src_mm, addr, src_pmd);
+		pmd = pmd_wrprotect(pmd);
+	}
+	pmd = pmd_mkold(pmd);
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 
 	ret = 0;
@@ -1064,8 +1067,11 @@ int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		/* No huge zero pud yet */
 	}
 
-	pudp_set_wrprotect(src_mm, addr, src_pud);
-	pud = pud_mkold(pud_wrprotect(pud));
+	if (pud_write(pud)) {
+		pudp_set_wrprotect(src_mm, addr, src_pud);
+		pud = pud_wrprotect(pud);
+	}
+	pud = pud_mkold(pud);
 	set_pud_at(dst_mm, addr, dst_pud, pud);
 
 	ret = 0;
-- 
2.18.0
