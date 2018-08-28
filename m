Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD756B45EC
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:20:55 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i68-v6so762787pfb.9
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 04:20:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b69-v6sor240052plb.139.2018.08.28.04.20.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 04:20:53 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 2/3] mm/cow: optimise pte dirty/accessed bits handling in fork
Date: Tue, 28 Aug 2018 21:20:33 +1000
Message-Id: <20180828112034.30875-3-npiggin@gmail.com>
In-Reply-To: <20180828112034.30875-1-npiggin@gmail.com>
References: <20180828112034.30875-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

fork clears dirty/accessed bits from new ptes in the child. This logic
has existed since mapped page reclaim was done by scanning ptes when
it may have been quite important. Today with physical based pte
scanning, there is less reason to clear these bits. Dirty bits are all
tested and cleared together and any dirty bit is the same as many
dirty bits. Any young bit is treated similarly to many young bits, but
not quite the same. A comment has been added where there is some
difference.

This eliminates a major source of faults powerpc/radix requires to set
dirty/accessed bits in ptes, speeding up a fork/exit microbenchmark by
about 5% on POWER9 (16600 -> 17500 fork/execs per second).

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
 mm/huge_memory.c |  2 --
 mm/memory.c      | 10 +++++-----
 mm/vmscan.c      |  8 ++++++++
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d9bae12978ef..5fb1a43e12e0 100644
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
index b616a69ad770..3d8bf8220bd0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1038,12 +1038,12 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7e7d25504651..52fe64af3d80 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1021,6 +1021,14 @@ static enum page_references page_check_references(struct page *page,
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
