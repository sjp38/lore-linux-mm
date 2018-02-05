Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB87B6B000A
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:04 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e12so18591899pgu.11
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g129si2015867pfc.338.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:03 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 05/64] mm,khugepaged: prepare passing of rangelock field to vm_fault
Date: Mon,  5 Feb 2018 02:26:55 +0100
Message-Id: <20180205012754.23615-6-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

When collapsing huge pages from swapin, a vm_fault structure is built
and passed to do_swap_page(). The new range field of the vm_fault
structure must be set correctly when dealing with range_lock.

We teach the main workhorse, khugepaged_scan_mm_slot(), to pass on
a full range lock.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/khugepaged.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index b7e2268dfc9a..0b91ce730160 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -873,7 +873,8 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address,
 static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd,
-					int referenced)
+					int referenced,
+					struct range_lock *mmrange)
 {
 	int swapped_in = 0, ret = 0;
 	struct vm_fault vmf = {
@@ -882,6 +883,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		.flags = FAULT_FLAG_ALLOW_RETRY,
 		.pmd = pmd,
 		.pgoff = linear_page_index(vma, address),
+		.lockrange = mmrange,
 	};
 
 	/* we only decide to swapin, if there is enough young ptes */
@@ -926,9 +928,10 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 }
 
 static void collapse_huge_page(struct mm_struct *mm,
-				   unsigned long address,
-				   struct page **hpage,
-				   int node, int referenced)
+			       unsigned long address,
+			       struct page **hpage,
+			       int node, int referenced,
+			       struct range_lock *mmrange)
 {
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
@@ -986,7 +989,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * If it fails, we release mmap_sem and jump out_nolock.
 	 * Continuing to collapse causes inconsistency.
 	 */
-	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced)) {
+	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced, mmrange)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
@@ -1093,7 +1096,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 static int khugepaged_scan_pmd(struct mm_struct *mm,
 			       struct vm_area_struct *vma,
 			       unsigned long address,
-			       struct page **hpage)
+			       struct page **hpage,
+			       struct range_lock *mmrange)
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
@@ -1207,7 +1211,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	if (ret) {
 		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
-		collapse_huge_page(mm, address, hpage, node, referenced);
+		collapse_huge_page(mm, address, hpage, node, referenced,
+				   mmrange);
 	}
 out:
 	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
@@ -1658,6 +1663,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int progress = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	VM_BUG_ON(!pages);
 	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
@@ -1731,7 +1737,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			} else {
 				ret = khugepaged_scan_pmd(mm, vma,
 						khugepaged_scan.address,
-						hpage);
+						hpage, &mmrange);
 			}
 			/* move to next address */
 			khugepaged_scan.address += HPAGE_PMD_SIZE;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
