Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 224106B00A9
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:05:32 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so28276388pab.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:05:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id xt6si14192368pbc.59.2015.04.23.14.05.08
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:05:09 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 28/28] thp: update documentation
Date: Fri, 24 Apr 2015 00:04:03 +0300
Message-Id: <1429823043-157133-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch updates Documentation/vm/transhuge.txt to reflect changes in
THP design.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt | 100 +++++++++++++++++++----------------------
 1 file changed, 45 insertions(+), 55 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 6b31cfbe2a9a..a12171e850d4 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -35,10 +35,10 @@ miss is going to run faster.
 
 == Design ==
 
-- "graceful fallback": mm components which don't have transparent
-  hugepage knowledge fall back to breaking a transparent hugepage and
-  working on the regular pages and their respective regular pmd/pte
-  mappings
+- "graceful fallback": mm components which don't have transparent hugepage
+  knowledge fall back to breaking huge pmd mapping into table of ptes and,
+  if nesessary, split a transparent hugepage. Therefore these components
+  can continue working on the regular pages or regular pte mappings.
 
 - if a hugepage allocation fails because of memory fragmentation,
   regular pages should be gracefully allocated instead and mixed in
@@ -200,9 +200,18 @@ thp_collapse_alloc_failed is incremented if khugepaged found a range
 	of pages that should be collapsed into one huge page but failed
 	the allocation.
 
-thp_split is incremented every time a huge page is split into base
+thp_split_page is incremented every time a huge page is split into base
 	pages. This can happen for a variety of reasons but a common
 	reason is that a huge page is old and is being reclaimed.
+	This action implies splitting all PMD the page mapped with.
+
+thp_split_page_failed is is incremented if kernel fails to split huge
+	page. This can happen if the page was pinned by somebody.
+
+thp_split_pmd is incremented every time a PMD split into table of PTEs.
+	This can happen, for instance, when application calls mprotect() or
+	munmap() on part of huge page. It doesn't split huge page, only
+	page table entry.
 
 thp_zero_page_alloc is incremented every time a huge zero page is
 	successfully allocated. It includes allocations which where
@@ -253,10 +262,8 @@ is complete, so they won't ever notice the fact the page is huge. But
 if any driver is going to mangle over the page structure of the tail
 page (like for checking page->mapping or other bits that are relevant
 for the head page and not the tail page), it should be updated to jump
-to check head page instead (while serializing properly against
-split_huge_page() to avoid the head and tail pages to disappear from
-under it, see the futex code to see an example of that, hugetlbfs also
-needed special handling in futex code for similar reasons).
+to check head page instead. Taking reference on any head/tail page would
+prevent page from being split by anyone.
 
 NOTE: these aren't new constraints to the GUP API, and they match the
 same constrains that applies to hugetlbfs too, so any driver capable
@@ -291,9 +298,9 @@ unaffected. libhugetlbfs will also work fine as usual.
 == Graceful fallback ==
 
 Code walking pagetables but unware about huge pmds can simply call
-split_huge_page_pmd(vma, addr, pmd) where the pmd is the one returned by
+split_huge_pmd(vma, pmd, addr) where the pmd is the one returned by
 pmd_offset. It's trivial to make the code transparent hugepage aware
-by just grepping for "pmd_offset" and adding split_huge_page_pmd where
+by just grepping for "pmd_offset" and adding split_huge_pmd where
 missing after pmd_offset returns the pmd. Thanks to the graceful
 fallback design, with a one liner change, you can avoid to write
 hundred if not thousand of lines of complex code to make your code
@@ -302,7 +309,8 @@ hugepage aware.
 If you're not walking pagetables but you run into a physical hugepage
 but you can't handle it natively in your code, you can split it by
 calling split_huge_page(page). This is what the Linux VM does before
-it tries to swapout the hugepage for example.
+it tries to swapout the hugepage for example. split_huge_page() can fail
+if the page is pinned and you must handle this correctly.
 
 Example to make mremap.c transparent hugepage aware with a one liner
 change:
@@ -314,14 +322,14 @@ diff --git a/mm/mremap.c b/mm/mremap.c
 		return NULL;
 
 	pmd = pmd_offset(pud, addr);
-+	split_huge_page_pmd(vma, addr, pmd);
++	split_huge_pmd(vma, pmd, addr);
 	if (pmd_none_or_clear_bad(pmd))
 		return NULL;
 
 == Locking in hugepage aware code ==
 
 We want as much code as possible hugepage aware, as calling
-split_huge_page() or split_huge_page_pmd() has a cost.
+split_huge_page() or split_huge_pmd() has a cost.
 
 To make pagetable walks huge pmd aware, all you need to do is to call
 pmd_trans_huge() on the pmd returned by pmd_offset. You must hold the
@@ -330,47 +338,29 @@ created from under you by khugepaged (khugepaged collapse_huge_page
 takes the mmap_sem in write mode in addition to the anon_vma lock). If
 pmd_trans_huge returns false, you just fallback in the old code
 paths. If instead pmd_trans_huge returns true, you have to take the
-mm->page_table_lock and re-run pmd_trans_huge. Taking the
-page_table_lock will prevent the huge pmd to be converted into a
-regular pmd from under you (split_huge_page can run in parallel to the
+page table lock (pmd_lock()) and re-run pmd_trans_huge. Taking the
+page table lock will prevent the huge pmd to be converted into a
+regular pmd from under you (split_huge_pmd can run in parallel to the
 pagetable walk). If the second pmd_trans_huge returns false, you
-should just drop the page_table_lock and fallback to the old code as
-before. Otherwise you should run pmd_trans_splitting on the pmd. In
-case pmd_trans_splitting returns true, it means split_huge_page is
-already in the middle of splitting the page. So if pmd_trans_splitting
-returns true it's enough to drop the page_table_lock and call
-wait_split_huge_page and then fallback the old code paths. You are
-guaranteed by the time wait_split_huge_page returns, the pmd isn't
-huge anymore. If pmd_trans_splitting returns false, you can proceed to
-process the huge pmd and the hugepage natively. Once finished you can
-drop the page_table_lock.
-
-== compound_lock, get_user_pages and put_page ==
+should just drop the page table lock and fallback to the old code as
+before. Otherwise you can proceed to process the huge pmd and the
+hugepage natively. Once finished you can drop the page table lock.
+
+== Refcounts and transparent huge pages ==
 
+As with other compound page types we do all refcounting for THP on head
+page, but unlike other compound pages THP support splitting.
 split_huge_page internally has to distribute the refcounts in the head
-page to the tail pages before clearing all PG_head/tail bits from the
-page structures. It can do that easily for refcounts taken by huge pmd
-mappings. But the GUI API as created by hugetlbfs (that returns head
-and tail pages if running get_user_pages on an address backed by any
-hugepage), requires the refcount to be accounted on the tail pages and
-not only in the head pages, if we want to be able to run
-split_huge_page while there are gup pins established on any tail
-page. Failure to be able to run split_huge_page if there's any gup pin
-on any tail page, would mean having to split all hugepages upfront in
-get_user_pages which is unacceptable as too many gup users are
-performance critical and they must work natively on hugepages like
-they work natively on hugetlbfs already (hugetlbfs is simpler because
-hugetlbfs pages cannot be split so there wouldn't be requirement of
-accounting the pins on the tail pages for hugetlbfs). If we wouldn't
-account the gup refcounts on the tail pages during gup, we won't know
-anymore which tail page is pinned by gup and which is not while we run
-split_huge_page. But we still have to add the gup pin to the head page
-too, to know when we can free the compound page in case it's never
-split during its lifetime. That requires changing not just
-get_page, but put_page as well so that when put_page runs on a tail
-page (and only on a tail page) it will find its respective head page,
-and then it will decrease the head page refcount in addition to the
-tail page refcount. To obtain a head page reliably and to decrease its
-refcount without race conditions, put_page has to serialize against
-__split_huge_page_refcount using a special per-page lock called
-compound_lock.
+page to the tail pages before clearing all PG_head/tail bits from the page
+structures. It can be done easily for refcounts taken by page table
+entries. But we don't have enough information on how to distribute any
+additional pins (i.e. from get_user_pages). split_huge_page fails any
+requests to split pinned huge page: it expects page count to be equal to
+sum of mapcount of all sub-pages plus one (split_huge_page caller must
+have reference for head page).
+
+split_huge_page uses migration entries to stabilize page->_count and
+page->_mapcount.
+
+Note that split_huge_pmd() doesn't have any limitation on refcounting:
+pmd can be split at any point and never fails.
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
