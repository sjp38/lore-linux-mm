Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 243906B000C
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:14:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j9-v6so14358943plt.3
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:14:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s23-v6sor4222653plr.15.2018.10.16.06.14.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 06:14:11 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH v2 3/5] mm/cow: optimise pte accessed bit handling in fork
Date: Tue, 16 Oct 2018 23:13:41 +1000
Message-Id: <20181016131343.20556-4-npiggin@gmail.com>
In-Reply-To: <20181016131343.20556-1-npiggin@gmail.com>
References: <20181016131343.20556-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, Ley Foon Tan <ley.foon.tan@intel.com>

fork clears dirty/accessed bits from new ptes in the child. This logic
has existed since mapped page reclaim was done by scanning ptes when
it may have been quite important. Today with physical based pte
scanning, there is less reason to clear these bits, so this patch
avoids clearing the accessed bit in the child.

Any accessed bit is treated similarly to many, with the difference
today with > 1 referenced bit causing the page to be activated, while
1 bit causes it to be kept. This patch causes pages shared by fork(2)
to be more readily activated, but this heuristic is very fuzzy anyway
-- a page can be accessed by multiple threads via a single pte and be
just as important as one that is accessed via multiple ptes, for
example. In the end I don't believe fork(2) is a significant driver of
page reclaim behaviour that this should matter too much.

This and the following change eliminate a major source of faults that
powerpc/radix requires to set dirty/accessed bits in ptes, speeding
up a fork/exit microbenchmark by about 5% on POWER9 (16600 -> 17500
fork/execs per second).

Skylake appears to have a micro-fault overhead too -- a test which
allocates 4GB anonymous memory, reads each page, then forks, and times
the child reading a byte from each page. The first pass over the pages
takes about 1000 cycles per page, the second pass takes about 27
cycles (TLB miss). With no additional minor faults measured due to
either child pass, and the page array well exceeding TLB capacity, the
large cost must be caused by micro faults caused by setting accessed
bit.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/huge_memory.c | 2 --
 mm/memory.c      | 1 -
 mm/vmscan.c      | 8 ++++++++
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0fb0e3025f98..1f43265204d4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -977,7 +977,6 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pmdp_set_wrprotect(src_mm, addr, src_pmd);
 		pmd = pmd_wrprotect(pmd);
 	}
-	pmd = pmd_mkold(pmd);
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 
 	ret = 0;
@@ -1071,7 +1070,6 @@ int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pudp_set_wrprotect(src_mm, addr, src_pud);
 		pud = pud_wrprotect(pud);
 	}
-	pud = pud_mkold(pud);
 	set_pud_at(dst_mm, addr, dst_pud, pud);
 
 	ret = 0;
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..0387ee1e3582 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1033,7 +1033,6 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 */
 	if (vm_flags & VM_SHARED)
 		pte = pte_mkclean(pte);
-	pte = pte_mkold(pte);
 
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5ef7240cbcb..e72d5b3336a0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1031,6 +1031,14 @@ static enum page_references page_check_references(struct page *page,
 		 * to look twice if a mapped file page is used more
 		 * than once.
 		 *
+		 * fork() will set referenced bits in child ptes despite
+		 * not having been accessed, to avoid micro-faults of
+		 * setting accessed bits. This heuristic is not perfectly
+		 * accurate in other ways -- multiple map/unmap in the
+		 * same time window would be treated as multiple references
+		 * despite same number of actual memory accesses made by
+		 * the program.
+		 *
 		 * Mark it and spare it for another trip around the
 		 * inactive list.  Another page table reference will
 		 * lead to its activation.
-- 
2.18.0
