Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 51D8D6B0044
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:50:08 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 03:50:07 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 3C426C90041
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:50:04 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7o5Sv127370
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:50:05 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7o5ZN005083
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:50:05 -0400
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 10/10] x86, mm: Prevent gcc to re-read the pagetables
Date: Tue, 30 Jul 2013 13:18:25 +0530
Message-Id: <1375170505-5967-11-git-send-email-srikar@linux.vnet.ibm.com>
In-Reply-To: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

From: Andrea Arcangeli <aarcange@redhat.com>

GCC is very likely to read the pagetables just once and cache them in
the local stack or in a register, but it is can also decide to re-read
the pagetables. The problem is that the pagetable in those places can
change from under gcc.

In the page fault we only hold the ->mmap_sem for reading and both the
page fault and MADV_DONTNEED only take the ->mmap_sem for reading and we
don't hold any PT lock yet.

In get_user_pages_fast() the TLB shootdown code can clear the pagetables
before firing any TLB flush (the page can't be freed until the TLB
flushing IPI has been delivered but the pagetables will be cleared well
before sending any TLB flushing IPI).

With THP/hugetlbfs the pmd (and pud for hugetlbfs giga pages) can
change as well under gup_fast, it won't just be cleared for the same
reasons described above for the pte in the page fault case.

[ This patch was picked up from the AutoNUMA tree. Also stayed in Ingo
Molnar's Numa tree for a while.]

Originally-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

---
Ingo, Andrea, Please let me know if I can add your signed-off-by.
---
 arch/x86/mm/gup.c |   23 ++++++++++++++++++++---
 mm/memory.c       |    2 +-
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index dd74e46..6dc9921 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -150,7 +150,13 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 
 	pmdp = pmd_offset(&pud, addr);
 	do {
-		pmd_t pmd = *pmdp;
+		/*
+		 * With THP and hugetlbfs the pmd can change from
+		 * under us and it can be cleared as well by the TLB
+		 * shootdown, so read it with ACCESS_ONCE to do all
+		 * computations on the same sampling.
+		 */
+		pmd_t pmd = ACCESS_ONCE(*pmdp);
 
 		next = pmd_addr_end(addr, end);
 		/*
@@ -220,7 +226,13 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
 
 	pudp = pud_offset(&pgd, addr);
 	do {
-		pud_t pud = *pudp;
+		/*
+		 * With hugetlbfs giga pages the pud can change from
+		 * under us and it can be cleared as well by the TLB
+		 * shootdown, so read it with ACCESS_ONCE to do all
+		 * computations on the same sampling.
+		 */
+		pud_t pud = ACCESS_ONCE(*pudp);
 
 		next = pud_addr_end(addr, end);
 		if (pud_none(pud))
@@ -280,7 +292,12 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	local_irq_save(flags);
 	pgdp = pgd_offset(mm, addr);
 	do {
-		pgd_t pgd = *pgdp;
+		/*
+		 * The pgd could be cleared by the TLB shootdown from
+		 * under us so read it with ACCESS_ONCE to do all
+		 * computations on the same sampling.
+		 */
+		pgd_t pgd = ACCESS_ONCE(*pgdp);
 
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
diff --git a/mm/memory.c b/mm/memory.c
index ba94dec..6254dd2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3703,7 +3703,7 @@ int handle_pte_fault(struct mm_struct *mm,
 	pte_t entry;
 	spinlock_t *ptl;
 
-	entry = *pte;
+	entry = ACCESS_ONCE(*pte);
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
