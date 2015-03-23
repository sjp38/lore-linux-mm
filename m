Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 71C6A6B006E
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 08:24:11 -0400 (EDT)
Received: by wgs2 with SMTP id 2so37564272wgs.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:24:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si11436603wix.93.2015.03.23.05.24.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Mar 2015 05:24:07 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/3] mm: numa: Preserve PTE write permissions across a NUMA hinting fault
Date: Mon, 23 Mar 2015 12:24:02 +0000
Message-Id: <1427113443-20973-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1427113443-20973-1-git-send-email-mgorman@suse.de>
References: <1427113443-20973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@suse.de>

Protecting a PTE to trap a NUMA hinting fault clears the writable bit
and further faults are needed after trapping a NUMA hinting fault to
set the writable bit again. This patch preserves the writable bit when
trapping NUMA hinting faults. The impact is obvious from the number
of minor faults trapped during the basis balancing benchmark and the
system CPU usage;

autonumabench
                                           4.0.0-rc4             4.0.0-rc4
                                            baseline              preserve
Time System-NUMA01                  107.13 (  0.00%)      103.13 (  3.73%)
Time System-NUMA01_THEADLOCAL       131.87 (  0.00%)       83.30 ( 36.83%)
Time System-NUMA02                    8.95 (  0.00%)       10.72 (-19.78%)
Time System-NUMA02_SMT                4.57 (  0.00%)        3.99 ( 12.69%)
Time Elapsed-NUMA01                 515.78 (  0.00%)      517.26 ( -0.29%)
Time Elapsed-NUMA01_THEADLOCAL      384.10 (  0.00%)      384.31 ( -0.05%)
Time Elapsed-NUMA02                  48.86 (  0.00%)       48.78 (  0.16%)
Time Elapsed-NUMA02_SMT              47.98 (  0.00%)       48.12 ( -0.29%)

             4.0.0-rc4   4.0.0-rc4
              baseline    preserve
User          44383.95    43971.89
System          252.61      201.24
Elapsed         998.68     1000.94

Minor Faults   2597249     1981230
Major Faults       365         364

There is a similar drop in system CPU usage using Dave Chinner's xfsrepair workload

                                    4.0.0-rc4             4.0.0-rc4
                                     baseline              preserve
Amean    real-xfsrepair      454.14 (  0.00%)      442.36 (  2.60%)
Amean    syst-xfsrepair      277.20 (  0.00%)      204.68 ( 26.16%)

The patch looks hacky but the alternatives looked worse. The tidest was
to rewalk the page tables after a hinting fault but it was more complex
than this approach and the performance was worse. It's not generally safe
to just mark the page writable during the fault if it's a write fault as
it may have been read-only for COW so that approach was discarded.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 9 ++++++++-
 mm/memory.c      | 8 +++-----
 mm/mprotect.c    | 3 +++
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2f12e9fcf1a2..0a42d1521aa4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1260,6 +1260,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int target_nid, last_cpupid = -1;
 	bool page_locked;
 	bool migrated = false;
+	bool was_writable;
 	int flags = 0;
 
 	/* A PROT_NONE fault should not end up here */
@@ -1354,7 +1355,10 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	goto out;
 clear_pmdnuma:
 	BUG_ON(!PageLocked(page));
+	was_writable = pmd_write(pmd);
 	pmd = pmd_modify(pmd, vma->vm_page_prot);
+	if (was_writable)
+		pmd = pmd_mkwrite(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
 	update_mmu_cache_pmd(vma, addr, pmdp);
 	unlock_page(page);
@@ -1478,6 +1482,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		pmd_t entry;
+		bool preserve_write = prot_numa && pmd_write(*pmd);
 		ret = 1;
 
 		/*
@@ -1493,9 +1498,11 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		if (!prot_numa || !pmd_protnone(*pmd)) {
 			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
+			if (preserve_write)
+				entry = pmd_mkwrite(entry);
 			ret = HPAGE_PMD_NR;
 			set_pmd_at(mm, addr, pmd, entry);
-			BUG_ON(pmd_write(entry));
+			BUG_ON(!preserve_write && pmd_write(entry));
 		}
 		spin_unlock(ptl);
 	}
diff --git a/mm/memory.c b/mm/memory.c
index 20beb6647dba..d20e12da3a3c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3035,6 +3035,7 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int last_cpupid;
 	int target_nid;
 	bool migrated = false;
+	bool was_writable = pte_write(pte);
 	int flags = 0;
 
 	/* A PROT_NONE fault should not end up here */
@@ -3059,6 +3060,8 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* Make it present again */
 	pte = pte_modify(pte, vma->vm_page_prot);
 	pte = pte_mkyoung(pte);
+	if (was_writable)
+		pte = pte_mkwrite(pte);
 	set_pte_at(mm, addr, ptep, pte);
 	update_mmu_cache(vma, addr, ptep);
 
@@ -3075,11 +3078,6 @@ static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * to it but pte_write gets cleared during protection updates and
 	 * pte_dirty has unpredictable behaviour between PTE scan updates,
 	 * background writeback, dirty balancing and application behaviour.
-	 *
-	 * TODO: Note that the ideal here would be to avoid a situation where a
-	 * NUMA fault is taken immediately followed by a write fault in
-	 * some cases which would have lower overhead overall but would be
-	 * invasive as the fault paths would need to be unified.
 	 */
 	if (!(vma->vm_flags & VM_WRITE))
 		flags |= TNF_NO_GROUP;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 44727811bf4c..88584838e704 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -75,6 +75,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
 			pte_t ptent;
+			bool preserve_write = prot_numa && pte_write(oldpte);
 
 			/*
 			 * Avoid trapping faults against the zero or KSM
@@ -94,6 +95,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 
 			ptent = ptep_modify_prot_start(mm, addr, pte);
 			ptent = pte_modify(ptent, newprot);
+			if (preserve_write)
+				ptent = pte_mkwrite(ptent);
 
 			/* Avoid taking write faults for known dirty pages */
 			if (dirty_accountable && pte_dirty(ptent) &&
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
