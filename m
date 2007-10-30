From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 2/5] hugetlb: Fix quota management for private mappings
Date: Tue, 30 Oct 2007 13:46:15 -0700
Message-Id: <20071030204615.16585.60817.stgit@kernel>
In-Reply-To: <20071030204554.16585.80588.stgit@kernel>
References: <20071030204554.16585.80588.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The hugetlbfs quota management system was never taught to handle
MAP_PRIVATE mappings when that support was added.  Currently, quota is
debited at page instantiation and credited at file truncation.  This
approach works correctly for shared pages but is incomplete for private
pages.  In addition to hugetlb_no_page(), private pages can be instantiated
by hugetlb_cow(); but this function does not respect quotas.

Private huge pages are treated very much like normal, anonymous pages.
They are not "backed" by the hugetlbfs file and are not stored in the
mapping's radix tree.  This means that private pages are invisible to
truncate_hugepages() so that function will not credit the quota.

This patch (based on a prototype provided by Ken Chen) moves quota
crediting for all pages into free_huge_page().  page->private is used to
store a pointer to the mapping to which this page belongs.  This is used to
credit quota on the appropriate hugetlbfs instance.

Signed-off-by: Adam Litke <agl@us.ibm.com>
CC: Ken Chen <kenchen@google.com>
---

 fs/hugetlbfs/inode.c |    1 -
 mm/hugetlb.c         |   13 ++++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 04598e1..5f4e888 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -364,7 +364,6 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 			++next;
 			truncate_huge_page(page);
 			unlock_page(page);
-			hugetlb_put_quota(mapping);
 			freed++;
 		}
 		huge_pagevec_release(&pvec);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d319e8e..0b09ef2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -116,7 +116,9 @@ static void update_and_free_page(struct page *page)
 static void free_huge_page(struct page *page)
 {
 	int nid = page_to_nid(page);
+	struct address_space *mapping;
 
+	mapping = (struct address_space *) page_private(page);
 	BUG_ON(page_count(page));
 	INIT_LIST_HEAD(&page->lru);
 
@@ -129,6 +131,9 @@ static void free_huge_page(struct page *page)
 		enqueue_huge_page(page);
 	}
 	spin_unlock(&hugetlb_lock);
+	if (mapping)
+		hugetlb_put_quota(mapping);
+	set_page_private(page, 0);
 }
 
 /*
@@ -388,8 +393,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		page = alloc_huge_page_shared(vma, addr);
 	else
 		page = alloc_huge_page_private(vma, addr);
-	if (page)
+	if (page) {
 		set_page_refcounted(page);
+		set_page_private(page, (unsigned long) vma->vm_file->f_mapping);
+	}
 	return page;
 }
 
@@ -730,6 +737,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		set_huge_ptep_writable(vma, address, ptep);
 		return 0;
 	}
+	if (hugetlb_get_quota(vma->vm_file->f_mapping))
+		return VM_FAULT_SIGBUS;
 
 	page_cache_get(old_page);
 	new_page = alloc_huge_page(vma, address);
@@ -796,7 +805,6 @@ retry:
 			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
 			if (err) {
 				put_page(page);
-				hugetlb_put_quota(mapping);
 				if (err == -EEXIST)
 					goto retry;
 				goto out;
@@ -830,7 +838,6 @@ out:
 
 backout:
 	spin_unlock(&mm->page_table_lock);
-	hugetlb_put_quota(mapping);
 	unlock_page(page);
 	put_page(page);
 	goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
