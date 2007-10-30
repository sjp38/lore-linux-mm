From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 1/5] hugetlb: Split alloc_huge_page into private and shared components
Date: Tue, 30 Oct 2007 13:46:04 -0700
Message-Id: <20071030204604.16585.92338.stgit@kernel>
In-Reply-To: <20071030204554.16585.80588.stgit@kernel>
References: <20071030204554.16585.80588.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The shared page reservation and dynamic pool resizing features have made
the allocation of private vs. shared huge pages quite different.  By
splitting out the private/shared-specific portions of the process into
their own functions, readability is greatly improved.  alloc_huge_page now
calls the proper helper and performs common operations.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---

 mm/hugetlb.c |   46 +++++++++++++++++++++++++++-------------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ae2959b..d319e8e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -353,35 +353,43 @@ void return_unused_surplus_pages(unsigned long unused_resv_pages)
 	}
 }
 
-static struct page *alloc_huge_page(struct vm_area_struct *vma,
-				    unsigned long addr)
+
+static struct page *alloc_huge_page_shared(struct vm_area_struct *vma,
+			 			unsigned long addr)
 {
-	struct page *page = NULL;
-	int use_reserved_page = vma->vm_flags & VM_MAYSHARE;
+	struct page *page;
 
 	spin_lock(&hugetlb_lock);
-	if (!use_reserved_page && (free_huge_pages <= resv_huge_pages))
-		goto fail;
-
 	page = dequeue_huge_page(vma, addr);
-	if (!page)
-		goto fail;
-
 	spin_unlock(&hugetlb_lock);
-	set_page_refcounted(page);
 	return page;
+}
 
-fail:
-	spin_unlock(&hugetlb_lock);
+static struct page *alloc_huge_page_private(struct vm_area_struct *vma,
+			 			unsigned long addr)
+{
+	struct page *page = NULL;
 
-	/*
-	 * Private mappings do not use reserved huge pages so the allocation
-	 * may have failed due to an undersized hugetlb pool.  Try to grab a
-	 * surplus huge page from the buddy allocator.
-	 */
-	if (!use_reserved_page)
+	spin_lock(&hugetlb_lock);
+	if (free_huge_pages > resv_huge_pages)
+		page = dequeue_huge_page(vma, addr);
+	spin_unlock(&hugetlb_lock);
+	if (!page)
 		page = alloc_buddy_huge_page(vma, addr);
+	return page;
+}
 
+static struct page *alloc_huge_page(struct vm_area_struct *vma,
+				    unsigned long addr)
+{
+	struct page *page;
+
+	if (vma->vm_flags & VM_MAYSHARE)
+		page = alloc_huge_page_shared(vma, addr);
+	else
+		page = alloc_huge_page_private(vma, addr);
+	if (page)
+		set_page_refcounted(page);
 	return page;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
