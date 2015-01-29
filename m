Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 12E566B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 09:59:28 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id fb4so25658783wid.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 06:59:27 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id p10si15210548wjx.72.2015.01.29.06.59.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 06:59:26 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id h11so11154336wiw.0
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 06:59:25 -0800 (PST)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v4] mm: incorporate read-only pages into transparent huge pages
Date: Thu, 29 Jan 2015 16:59:07 +0200
Message-Id: <1422543547-12591-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com, zhangyanfei.linux@aliyun.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

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
collapsed 60% of the program's memory back into THPs.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
Changes in v2:
 - Remove extra code indent (Vlastimil Babka)
 - Add comment line for check condition of page_count() (Vlastimil Babka)
 - Add fast path optimistic check to
   __collapse_huge_page_isolate() (Andrea Arcangeli)
 - Move check condition of page_count() below to trylock_page() (Andrea Arcangeli)

Changes in v3:
 - Add a at-least-one-writable-pte check (Zhang Yanfei)
 - Debug page count (Vlastimil Babka, Andrea Arcangeli)
 - Increase read-only pte counter if pte is none (Andrea Arcangeli)

Changes in v4:
 - Remove read-only counter (Andrea Arcangeli)
 - Remove debug page count  (Andrea Arcangeli)
 - Change type of writable as bool (Andrea Arcangeli)
 - Change type of referenced as bool (Vlastimil Babka)
 - Change comment line (Vlastimil Babka, Zhang Yanfei)

v3 of this patch was added in mm tree. I send v4,
if you accept to replace v3 with v4. If not, I can
send this changes with a new patch.

I've written down test results:
With the patch:
After swapped out:
cat /proc/pid/smaps:
Anonymous:	85064 kB
AnonHugePages:	83968 kB
Swap:		714940 kB
Fraction:	98,71

cat /proc/meminfo:
AnonPages:	1710332 kB
AnonHugePages:	1632256 kB
Fraction:	95,43

After swapped in:
In a few seconds:
cat /proc/pid/smaps:
Anonymous:	800004 kB
AnonHugePages:	116736 kB
Swap:		0 kB
Fraction:	14,59

cat /proc/meminfo:
AnonPages:	2426832 kB
AnonHugePages:	1681408 kB
Fraction:	69,28

In 5 minutes:
cat /proc/pid/smaps:
Anonymous:	800004 kB
AnonHugePages:	487424 kB
Swap:		0 kB
Fraction:	60,92

cat /proc/meminfo:
AnonPages:	2427852 kB
AnonHugePages:	2035712 kB
Fraction:	83,84

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

 mm/huge_memory.c | 55 ++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 42 insertions(+), 13 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 817a875..45b5c81 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2148,7 +2148,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 {
 	struct page *page;
 	pte_t *_pte;
-	int referenced = 0, none = 0;
+	int none = 0;
+	bool referenced = false, writable = false;
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
@@ -2158,7 +2159,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			else
 				goto out;
 		}
-		if (!pte_present(pteval) || !pte_write(pteval))
+		if (!pte_present(pteval))
 			goto out;
 		page = vm_normal_page(vma, address, pteval);
 		if (unlikely(!page))
@@ -2168,9 +2169,6 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		VM_BUG_ON_PAGE(!PageAnon(page), page);
 		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-		/* cannot use mapcount: can't collapse if there's a gup pin */
-		if (page_count(page) != 1)
-			goto out;
 		/*
 		 * We can do it before isolate_lru_page because the
 		 * page can't be freed from under us. NOTE: PG_lock
@@ -2179,6 +2177,29 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
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
+		if (pte_write(pteval)) {
+			writable = true;
+		} else {
+			if (PageSwapCache(page) && !reuse_swap_page(page)) {
+				unlock_page(page);
+				goto out;
+			}
+			/*
+			 * Page is not in the swap cache. It can be collapsed
+			 * into a THP.
+			 */
+		}
+
 		/*
 		 * Isolate the page to avoid collapsing an hugepage
 		 * currently in use by the VM.
@@ -2195,9 +2216,9 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		/* If there is no mapped pte young don't collapse the page */
 		if (pte_young(pteval) || PageReferenced(page) ||
 		    mmu_notifier_test_young(vma->vm_mm, address))
-			referenced = 1;
+			referenced = true;
 	}
-	if (likely(referenced))
+	if (likely(referenced && writable))
 		return 1;
 out:
 	release_pte_pages(pte, _pte);
@@ -2550,11 +2571,12 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
-	int ret = 0, referenced = 0, none = 0;
+	int ret = 0, none = 0;
 	struct page *page;
 	unsigned long _address;
 	spinlock_t *ptl;
 	int node = NUMA_NO_NODE;
+	bool writable = false, referenced = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
@@ -2573,8 +2595,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 			else
 				goto out_unmap;
 		}
-		if (!pte_present(pteval) || !pte_write(pteval))
+		if (!pte_present(pteval))
 			goto out_unmap;
+		if (pte_write(pteval))
+			writable = true;
+
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			goto out_unmap;
@@ -2591,14 +2616,18 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
-			referenced = 1;
+			referenced = true;
 	}
-	if (referenced)
+	if (referenced && writable)
 		ret = 1;
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
