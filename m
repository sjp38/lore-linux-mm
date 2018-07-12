Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3052D6B000D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:36:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f9-v6so16865436pfn.22
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 00:36:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8-v6sor6954857plp.49.2018.07.12.00.36.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 00:36:42 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH] mm: optimise pte dirty/accessed bits handling in fork
Date: Thu, 12 Jul 2018 17:36:33 +1000
Message-Id: <20180712073633.1702-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org

fork clears dirty/accessed bits from new ptes in the child, even
though the mapping allows such accesses. This logic has existed
for ~ever, and certainly well before physical page reclaim and
cleaning was not strongly tied to pte access state as it is today.
Now that is the case, this access bit clearing logic does not do
much.

Other than this case, Linux is "eager" to set dirty/accessed bits
when setting up mappings, which avoids micro-faults (and page
faults on CPUs that implement these bits in software). With this
patch, there are no cases I could instrument where dirty/accessed
bits do not match the access permissions without memory pressure
(and without more exotic things like migration).

This speeds up a fork/exit microbenchmark by about 5% on POWER9
(which uses a software fault fallback mechanism to set these bits).
I expect x86 CPUs will barely be noticable, but would be interesting
to see. Other archs might care more, and anyway it's always good if
we can remove code and make things a bit faster.

I don't *think* I'm missing anything fundamental, but would be good
to be sure. Comments?

Thanks,
Nick

---

 mm/huge_memory.c |  4 ++--
 mm/memory.c      | 10 +++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1cd7c1a57a14..c1d41cad9aad 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -974,7 +974,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
-	pmd = pmd_mkold(pmd_wrprotect(pmd));
+	pmd = pmd_wrprotect(pmd);
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 
 	ret = 0;
@@ -1065,7 +1065,7 @@ int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	}
 
 	pudp_set_wrprotect(src_mm, addr, src_pud);
-	pud = pud_mkold(pud_wrprotect(pud));
+	pud = pud_wrprotect(pud);
 	set_pud_at(dst_mm, addr, dst_pud, pud);
 
 	ret = 0;
diff --git a/mm/memory.c b/mm/memory.c
index 7206a634270b..3fea40da3a58 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1023,12 +1023,12 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	}
 
 	/*
-	 * If it's a shared mapping, mark it clean in
-	 * the child
+	 * Child inherits dirty and young bits from parent. There is no
+	 * point clearing them because any cleaning or aging has to walk
+	 * all ptes anyway, and it will notice the bits set in the parent.
+	 * Leaving them set avoids stalls and even page faults on CPUs that
+	 * handle these bits in software.
 	 */
-	if (vm_flags & VM_SHARED)
-		pte = pte_mkclean(pte);
-	pte = pte_mkold(pte);
 
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
-- 
2.17.0
