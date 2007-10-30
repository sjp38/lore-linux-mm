From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 5/5] hugetlb: Enforce quotas during reservation for shared mappings
Date: Tue, 30 Oct 2007 13:46:50 -0700
Message-Id: <20071030204650.16585.6498.stgit@kernel>
In-Reply-To: <20071030204554.16585.80588.stgit@kernel>
References: <20071030204554.16585.80588.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

When a MAP_SHARED mmap of a hugetlbfs file succeeds, huge pages are
reserved to guarantee no problems will occur later when instantiating
pages.  If quotas are in force, page instantiation could fail due to a race
with another process or an oversized (but approved) shared mapping.

To prevent these scenarios, debit the quota for the full reservation amount
up front and credit the unused quota when the reservation is released.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index deba411..2fc3cd6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -367,7 +367,7 @@ static struct page *alloc_huge_page_shared(struct vm_area_struct *vma,
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page(vma, addr);
 	spin_unlock(&hugetlb_lock);
-	return page;
+	return page ? page : ERR_PTR(-VM_FAULT_OOM);
 }
 
 static struct page *alloc_huge_page_private(struct vm_area_struct *vma,
@@ -375,13 +375,16 @@ static struct page *alloc_huge_page_private(struct vm_area_struct *vma,
 {
 	struct page *page = NULL;
 
+	if (hugetlb_get_quota(vma->vm_file->f_mapping, 1))
+		return ERR_PTR(-VM_FAULT_SIGBUS);
+
 	spin_lock(&hugetlb_lock);
 	if (free_huge_pages > resv_huge_pages)
 		page = dequeue_huge_page(vma, addr);
 	spin_unlock(&hugetlb_lock);
 	if (!page)
 		page = alloc_buddy_huge_page(vma, addr);
-	return page;
+	return page ? page : ERR_PTR(-VM_FAULT_OOM);
 }
 
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
@@ -390,19 +393,16 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	struct page *page;
 	struct address_space *mapping = vma->vm_file->f_mapping;
 
-	if (hugetlb_get_quota(mapping, 1))
-		return ERR_PTR(-VM_FAULT_SIGBUS);
-
 	if (vma->vm_flags & VM_MAYSHARE)
 		page = alloc_huge_page_shared(vma, addr);
 	else
 		page = alloc_huge_page_private(vma, addr);
-	if (page) {
+
+	if (!IS_ERR(page)) {
 		set_page_refcounted(page);
 		set_page_private(page, (unsigned long) mapping);
-		return page;
-	} else
-		return ERR_PTR(-VM_FAULT_OOM);
+	}
+	return page;
 }
 
 static int __init hugetlb_init(void)
@@ -1147,6 +1147,8 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to)
 	if (chg < 0)
 		return chg;
 
+	if (hugetlb_get_quota(inode->i_mapping, chg))
+		return -ENOSPC;
 	ret = hugetlb_acct_memory(chg);
 	if (ret < 0)
 		return ret;
@@ -1157,5 +1159,6 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to)
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
