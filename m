Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BEFEC6B0082
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:47:34 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so7752084pdb.2
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:47:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id c11si34747513pat.225.2015.06.23.06.47.17
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 15/36] ksm: prepare to new THP semantics
Date: Tue, 23 Jun 2015 16:46:25 +0300
Message-Id: <1435067206-92901-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
