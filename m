From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 3/5] hugetlb: Debit quota in alloc_huge_page
Date: Tue, 30 Oct 2007 13:46:27 -0700
Message-Id: <20071030204627.16585.26983.stgit@kernel>
In-Reply-To: <20071030204554.16585.80588.stgit@kernel>
References: <20071030204554.16585.80588.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Now that quota is credited by free_huge_page(), calls to
hugetlb_get_quota() seem out of place.  The alloc/free API is unbalanced
because we handle the hugetlb_put_quota() but expect the caller to
open-code hugetlb_get_quota().  Move the get inside alloc_huge_page to
clean up this disparity.

This patch has been kept apart from the previous patch because of the
somewhat dodgy ERR_PTR() use herein.  Moving the quota logic means that
alloc_huge_page() has two failure modes.  Quota failure must result in a
SIGBUS while a standard allocation failure is OOM.  Unfortunately,
ERR_PTR() doesn't like the small positive errnos we have in VM_FAULT_* so
they must be negated before they are used.

Does anyone take issue with the way I am using PTR_ERR.  If so, what are
your thoughts on how to clean this up (without needing an if,else if,else
block at each alloc_huge_page() callsite)?

Signed-off-by: Adam Litke <agl@us.ibm.com>

 STG: Please edit the
description for patch "get-quota-on-alloc-V2" above.  STG: Lines prefixed
with "STG:" will be automatically removed.  STG: Trailing empty lines will
be automatically removed.  STG: vi: set textwidth=75 filetype=diff
nobackup:
---

 mm/hugetlb.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0b09ef2..5eacee8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -388,6 +388,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr)
 {
 	struct page *page;
+	struct address_space *mapping = vma->vm_file->f_mapping;
+
+	if (hugetlb_get_quota(mapping))
+		return ERR_PTR(-VM_FAULT_SIGBUS);
 
 	if (vma->vm_flags & VM_MAYSHARE)
 		page = alloc_huge_page_shared(vma, addr);
@@ -395,9 +399,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		page = alloc_huge_page_private(vma, addr);
 	if (page) {
 		set_page_refcounted(page);
-		set_page_private(page, (unsigned long) vma->vm_file->f_mapping);
-	}
-	return page;
+		set_page_private(page, (unsigned long) mapping);
+		return page;
+	} else
+		return ERR_PTR(-VM_FAULT_OOM);
 }
 
 static int __init hugetlb_init(void)
@@ -737,15 +742,13 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		set_huge_ptep_writable(vma, address, ptep);
 		return 0;
 	}
-	if (hugetlb_get_quota(vma->vm_file->f_mapping))
-		return VM_FAULT_SIGBUS;
 
 	page_cache_get(old_page);
 	new_page = alloc_huge_page(vma, address);
 
-	if (!new_page) {
+	if (IS_ERR(new_page)) {
 		page_cache_release(old_page);
-		return VM_FAULT_OOM;
+		return -PTR_ERR(new_page);
 	}
 
 	spin_unlock(&mm->page_table_lock);
@@ -789,12 +792,9 @@ retry:
 		size = i_size_read(mapping->host) >> HPAGE_SHIFT;
 		if (idx >= size)
 			goto out;
-		if (hugetlb_get_quota(mapping))
-			goto out;
 		page = alloc_huge_page(vma, address);
-		if (!page) {
-			hugetlb_put_quota(mapping);
-			ret = VM_FAULT_OOM;
+		if (IS_ERR(page)) {
+			ret = -PTR_ERR(page);
 			goto out;
 		}
 		clear_huge_page(page, address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
