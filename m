Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9ODOBis005256
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:24:11 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9ODOB4J113576
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:24:11 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9ODOA3O017192
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:24:10 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/3] [PATCH] hugetlb: Enforce quotas during reservation for shared mappings
Date: Wed, 24 Oct 2007 06:24:08 -0700
Message-Id: <20071024132408.13013.81566.stgit@kernel>
In-Reply-To: <20071024132335.13013.76227.stgit@kernel>
References: <20071024132335.13013.76227.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

When a MAP_SHARED mmap of a hugetlbfs file succeeds, huge pages are
reserved to guarantee no problems will occur later when instantiating
pages.  If quotas are in force, page instantiation could fail due to a race
with another process or an oversized (but approved) shared mapping.

To prevent these scenarios, debit the quota for the full reservation amount
up front and credit the unused quota when the reservation is released.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index eaade8c..5fc075e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -769,6 +769,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	struct address_space *mapping;
 	pte_t new_pte;
+	int shared_page = vma->vm_flags & VM_SHARED;
 
 	mapping = vma->vm_file->f_mapping;
 	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
@@ -784,23 +785,24 @@ retry:
 		size = i_size_read(mapping->host) >> HPAGE_SHIFT;
 		if (idx >= size)
 			goto out;
-		if (hugetlb_get_quota(mapping, 1))
+		/* Shared pages are quota-accounted at reservation/mmap time */
+		if (!shared_page && hugetlb_get_quota(mapping, 1))
 			goto out;
 		page = alloc_huge_page(vma, address);
 		if (!page) {
-			hugetlb_put_quota(mapping, 1);
+			if (!shared_page)
+				hugetlb_put_quota(mapping, 1);
 			ret = VM_FAULT_OOM;
 			goto out;
 		}
 		clear_huge_page(page, address);
 
-		if (vma->vm_flags & VM_SHARED) {
+		if (shared_page) {
 			int err;
 
 			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
 			if (err) {
 				put_page(page);
-				hugetlb_put_quota(mapping, 1);
 				if (err == -EEXIST)
 					goto retry;
 				goto out;
@@ -834,7 +836,8 @@ out:
 
 backout:
 	spin_unlock(&mm->page_table_lock);
-	hugetlb_put_quota(mapping, 1);
+	if (!shared_page)
+		hugetlb_put_quota(mapping, 1);
 	unlock_page(page);
 	put_page(page);
 	goto out;
@@ -1144,6 +1147,8 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to)
 	if (chg < 0)
 		return chg;
 
+	if (hugetlb_get_quota(inode->i_mapping, chg))
+		return -ENOSPC;
 	ret = hugetlb_acct_memory(chg);
 	if (ret < 0)
 		return ret;
@@ -1154,5 +1159,6 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to)
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 {
 	long chg = region_truncate(&inode->i_mapping->private_list, offset);
-	hugetlb_acct_memory(freed - chg);
+	hugetlb_put_quota(inode->i_mapping, (chg - freed));
+	hugetlb_acct_memory(-(chg - freed));
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
