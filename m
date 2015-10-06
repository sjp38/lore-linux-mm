Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C49E682F68
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:24:44 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so212484919pab.3
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:24:44 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id a7si9796975pat.63.2015.10.06.08.24.24
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 08:24:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv12 15/37] ksm: prepare to new THP semantics
Date: Tue,  6 Oct 2015 18:23:42 +0300
Message-Id: <1444145044-72349-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't need special code to stabilize THP. If you've got reference to
any subpage of THP it will not be split under you.

New split_huge_page() also accepts tail pages: no need in special code
to get reference to head page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/ksm.c | 57 ++++++++++-----------------------------------------------
 1 file changed, 10 insertions(+), 47 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index fe09f3ddc912..fb333d8188fc 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -441,20 +441,6 @@ static void break_cow(struct rmap_item *rmap_item)
 	up_read(&mm->mmap_sem);
 }
 
-static struct page *page_trans_compound_anon(struct page *page)
-{
-	if (PageTransCompound(page)) {
-		struct page *head = compound_head(page);
-		/*
-		 * head may actually be splitted and freed from under
-		 * us but it's ok here.
-		 */
-		if (PageAnon(head))
-			return head;
-	}
-	return NULL;
-}
-
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
@@ -470,7 +456,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	page = follow_page(vma, addr, FOLL_GET);
 	if (IS_ERR_OR_NULL(page))
 		goto out;
-	if (PageAnon(page) || page_trans_compound_anon(page)) {
+	if (PageAnon(page)) {
 		flush_anon_page(vma, page, addr);
 		flush_dcache_page(page);
 	} else {
@@ -976,33 +962,6 @@ out:
 	return err;
 }
 
-static int page_trans_compound_anon_split(struct page *page)
-{
-	int ret = 0;
-	struct page *transhuge_head = page_trans_compound_anon(page);
-	if (transhuge_head) {
-		/* Get the reference on the head to split it. */
-		if (get_page_unless_zero(transhuge_head)) {
-			/*
-			 * Recheck we got the reference while the head
-			 * was still anonymous.
-			 */
-			if (PageAnon(transhuge_head))
-				ret = split_huge_page(transhuge_head);
-			else
-				/*
-				 * Retry later if split_huge_page run
-				 * from under us.
-				 */
-				ret = 1;
-			put_page(transhuge_head);
-		} else
-			/* Retry later if split_huge_page run from under us. */
-			ret = 1;
-	}
-	return ret;
-}
-
 /*
  * try_to_merge_one_page - take two pages and merge them into one
  * @vma: the vma that holds the pte pointing to page
@@ -1023,9 +982,6 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 
 	if (!(vma->vm_flags & VM_MERGEABLE))
 		goto out;
-	if (PageTransCompound(page) && page_trans_compound_anon_split(page))
-		goto out;
-	BUG_ON(PageTransCompound(page));
 	if (!PageAnon(page))
 		goto out;
 
@@ -1038,6 +994,13 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 	 */
 	if (!trylock_page(page))
 		goto out;
+
+	if (PageTransCompound(page)) {
+		err = split_huge_page(page);
+		if (err)
+			goto out_unlock;
+	}
+
 	/*
 	 * If this anonymous page is mapped only here, its pte may need
 	 * to be write-protected.  If it's mapped elsewhere, all of its
@@ -1068,6 +1031,7 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 		}
 	}
 
+out_unlock:
 	unlock_page(page);
 out:
 	return err;
@@ -1620,8 +1584,7 @@ next_mm:
 				cond_resched();
 				continue;
 			}
-			if (PageAnon(*page) ||
-			    page_trans_compound_anon(*page)) {
+			if (PageAnon(*page)) {
 				flush_anon_page(vma, *page, ksm_scan.address);
 				flush_dcache_page(*page);
 				rmap_item = get_next_rmap_item(slot,
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
