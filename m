Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 31B426B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 10:38:17 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id h11so1891296wiw.0
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 07:38:16 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id f4si9758803wjy.26.2015.01.24.07.38.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 Jan 2015 07:38:15 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id b13so2308469wgh.13
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 07:38:15 -0800 (PST)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v2] mm: incorporate read-only pages into transparent huge pages
Date: Sat, 24 Jan 2015 17:38:00 +0200
Message-Id: <1422113880-4712-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch aims to improve THP collapse rates, by allowing
THP collapse in the presence of read-only ptes, like those
left in place by do_swap_page after a read fault.

Currently THP can collapse 4kB pages into a THP when
there are up to khugepaged_max_ptes_none pte_none ptes
in a 2MB range. This patch applies the same limit for
read-only ptes.

The patch was tested with a test program that allocates
800MB of memory, writes to it, and then sleeps. I force
the system to swap out all but 190MB of the program by
touching other memory. Afterwards, the test program does
a mix of reads and writes to its memory, and the memory
gets swapped back in.

Without the patch, only the memory that did not get
swapped out remained in THPs, which corresponds to 24% of
the memory of the program. The percentage did not increase
over time.

With this patch, after 5 minutes of waiting khugepaged had
collapsed 48% of the program's memory back into THPs.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
Changes in v2:
 - Remove extra code indent
 - Add fast path optimistic check to
   __collapse_huge_page_isolate()
 - Add comment line for check condition of page_count()
 - Move check condition of page_count() below to trylock_page()

I've written down test results:
With the patch:
After swapped out:
cat /proc/pid/smaps:
Anonymous:	42804 kB
AnonHugePages:	38912 kB
Swap:		757200 kB
Fraction:	90,90

cat /proc/meminfo:
AnonPages:	1843956 kB
AnonHugePages:	1712128 kB
Fraction:	92,85

After swapped in:
In a few seconds:
cat /proc/pid/smaps:
Anonymous:	800004 kB
AnonHugePages:	104448 kB
Swap:		0 kB
Fraction:	13,05

cat /proc/meminfo:
AnonPages:	2605728 kB
AnonHugePages:	1777664 kB
Fraction:	68,22

In 5 minutes:
cat /proc/pid/smaps
Anonymous:	800004 kB
AnonHugePages:	389120 kB
Swap:		0 kB
Fraction:	48,63

cat /proc/meminfo:
AnonPages:	2607824 kB
AnonHugePages:	2041856 kB
Fraction:	78,29

Without the patch:
After swapped out:
cat /proc/pid/smaps:
Anonymous:      190660 kB
AnonHugePages:  190464 kB
Swap:           609344 kB
Fraction:       99,89

cat /proc/meminfo:
AnonPages:      1740456 kB
AnonHugePages:  1667072 kB
Fraction:       95,78

After swapped in:
cat /proc/pid/smaps:
Anonymous:      800004 kB
AnonHugePages:  190464 kB
Swap:           0 kB
Fraction:       23,80

cat /proc/meminfo:
AnonPages:      2350032 kB
AnonHugePages:  1667072 kB
Fraction:       70,93

I waited 10 minutes the fractions
did not change without the patch.

 mm/huge_memory.c | 48 +++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 39 insertions(+), 9 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 817a875..5e3e9b9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2148,7 +2148,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 {
 	struct page *page;
 	pte_t *_pte;
-	int referenced = 0, none = 0;
+	int referenced = 0, none = 0, ro = 0;
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
@@ -2158,7 +2158,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			else
 				goto out;
 		}
-		if (!pte_present(pteval) || !pte_write(pteval))
+		if (!pte_present(pteval))
 			goto out;
 		page = vm_normal_page(vma, address, pteval);
 		if (unlikely(!page))
@@ -2168,9 +2168,6 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		VM_BUG_ON_PAGE(!PageAnon(page), page);
 		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-		/* cannot use mapcount: can't collapse if there's a gup pin */
-		if (page_count(page) != 1)
-			goto out;
 		/*
 		 * We can do it before isolate_lru_page because the
 		 * page can't be freed from under us. NOTE: PG_lock
@@ -2179,6 +2176,31 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 */
 		if (!trylock_page(page))
 			goto out;
+
+		/*
+		 * cannot use mapcount: can't collapse if there's a gup pin.
+		 * The page must only be referenced by the scanned process
+		 * and page swap cache.
+		 */
+		if (page_count(page) != 1 + !!PageSwapCache(page)) {
+			unlock_page(page);
+			goto out;
+		}
+		if (!pte_write(pteval)) {
+			if (++ro > khugepaged_max_ptes_none) {
+				unlock_page(page);
+				goto out;
+			}
+			if (PageSwapCache(page) && !reuse_swap_page(page)) {
+				unlock_page(page);
+				goto out;
+			}
+			/*
+			 * Page is not in the swap cache, and page count is
+			 * one (see above). It can be collapsed into a THP.
+			 */
+		}
+
 		/*
 		 * Isolate the page to avoid collapsing an hugepage
 		 * currently in use by the VM.
@@ -2550,7 +2572,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
-	int ret = 0, referenced = 0, none = 0;
+	int ret = 0, referenced = 0, none = 0, ro = 0;
 	struct page *page;
 	unsigned long _address;
 	spinlock_t *ptl;
@@ -2573,8 +2595,12 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 			else
 				goto out_unmap;
 		}
-		if (!pte_present(pteval) || !pte_write(pteval))
+		if (!pte_present(pteval))
 			goto out_unmap;
+		if (!pte_write(pteval)) {
+			if (++ro > khugepaged_max_ptes_none)
+				goto out_unmap;
+		}
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			goto out_unmap;
@@ -2591,8 +2617,12 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
-		/* cannot use mapcount: can't collapse if there's a gup pin */
-		if (page_count(page) != 1)
+		/*
+		 * cannot use mapcount: can't collapse if there's a gup pin.
+		 * The page must only be referenced by the scanned process
+		 * and page swap cache.
+		 */
+		if (page_count(page) != 1 + !!PageSwapCache(page))
 			goto out_unmap;
 		if (pte_young(pteval) || PageReferenced(page) ||
 		    mmu_notifier_test_young(vma->vm_mm, address))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
