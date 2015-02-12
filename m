Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CD29D900016
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:22 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lf10so12315986pab.12
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:22 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id wa6si5584250pab.88.2015.02.12.08.19.06
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:19:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 23/24] ksm: split huge pages on follow_page()
Date: Thu, 12 Feb 2015 18:18:37 +0200
Message-Id: <1423757918-197669-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's split THP with FOLL_SPLIT. Attempting to split them laterk would
always fail bacause we take references on tail pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/ksm.c | 58 ++++++++--------------------------------------------------
 1 file changed, 8 insertions(+), 50 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index a8a88b0f6f62..8d977f074a74 100644
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
@@ -467,10 +453,10 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	if (!vma)
 		goto out;
 
-	page = follow_page(vma, addr, FOLL_GET);
+	page = follow_page(vma, addr, FOLL_GET | FOLL_SPLIT);
 	if (IS_ERR_OR_NULL(page))
 		goto out;
-	if (PageAnon(page) || page_trans_compound_anon(page)) {
+	if (PageAnon(page)) {
 		flush_anon_page(vma, page, addr);
 		flush_dcache_page(page);
 	} else {
@@ -976,35 +962,6 @@ out:
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
-			if (PageAnon(transhuge_head)) {
-				lock_page(transhuge_head);
-				ret = split_huge_page(transhuge_head);
-				unlock_page(transhuge_head);
-			} else
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
@@ -1025,9 +982,10 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 
 	if (!(vma->vm_flags & VM_MERGEABLE))
 		goto out;
-	if (PageTransCompound(page) && page_trans_compound_anon_split(page))
-		goto out;
+
+	/* huge pages must be split by this time */
 	BUG_ON(PageTransCompound(page));
+
 	if (!PageAnon(page))
 		goto out;
 
@@ -1616,14 +1574,14 @@ next_mm:
 		while (ksm_scan.address < vma->vm_end) {
 			if (ksm_test_exit(mm))
 				break;
-			*page = follow_page(vma, ksm_scan.address, FOLL_GET);
+			*page = follow_page(vma, ksm_scan.address,
+					FOLL_GET | FOLL_SPLIT);
 			if (IS_ERR_OR_NULL(*page)) {
 				ksm_scan.address += PAGE_SIZE;
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
