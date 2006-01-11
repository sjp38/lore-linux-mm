Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0BMOOF9006634
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 17:24:24 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0BMOO4f097742
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 17:24:24 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0BMOOBM001180
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 17:24:24 -0500
Subject: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1137016960.9672.5.camel@localhost.localdomain>
References: <1136920951.23288.5.camel@localhost.localdomain>
	 <1137016960.9672.5.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 11 Jan 2006 16:24:23 -0600
Message-Id: <1137018263.9672.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-01-11 at 16:02 -0600, Adam Litke wrote:
> here).  The patch doesn't completely close the race (there is a much
> smaller window without the zeroing though).  The next patch should close
> the race window completely.

My only concern is if I am using the correct lock for the job here.

 hugetlb.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)
diff -upN reference/mm/hugetlb.c current/mm/hugetlb.c
--- reference/mm/hugetlb.c
+++ current/mm/hugetlb.c
@@ -445,6 +445,7 @@ int hugetlb_no_page(struct mm_struct *mm
 	struct page *page;
 	struct address_space *mapping;
 	pte_t new_pte;
+	int shared = vma->vm_flags & VM_SHARED;
 
 	mapping = vma->vm_file->f_mapping;
 	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
@@ -454,26 +455,31 @@ int hugetlb_no_page(struct mm_struct *mm
 	 * Use page lock to guard against racing truncation
 	 * before we get page_table_lock.
 	 */
-retry:
 	page = find_lock_page(mapping, idx);
 	if (!page) {
 		if (hugetlb_get_quota(mapping))
 			goto out;
+
+		if (shared)
+			spin_lock(&mapping->host->i_lock);
+		
 		page = alloc_unzeroed_huge_page(vma, address);
 		if (!page) {
 			hugetlb_put_quota(mapping);
+			if (shared)
+				spin_unlock(&mapping->host->i_lock);
 			goto out;
 		}
 
-		if (vma->vm_flags & VM_SHARED) {
+		if (shared) {
 			int err;
 
 			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
+			spin_unlock(&mapping->host->i_lock);
 			if (err) {
 				put_page(page);
 				hugetlb_put_quota(mapping);
-				if (err == -EEXIST)
-					goto retry;
+				BUG_ON(-EEXIST);
 				goto out;
 			}
 		} else


-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
