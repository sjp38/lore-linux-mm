Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9ODNmgR007667
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:23:48 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9ODNmTB138710
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:23:48 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9ODNlUo023476
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 09:23:48 -0400
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 1/3] [FIX] hugetlb: Fix broken fs quota management
Date: Wed, 24 Oct 2007 06:23:45 -0700
Message-Id: <20071024132345.13013.36192.stgit@kernel>
In-Reply-To: <20071024132335.13013.76227.stgit@kernel>
References: <20071024132335.13013.76227.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>
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

This patch teaches the unmap path how to release fs quota analogous to
truncate_hugepages().  If __unmap_hugepage_range() clears the last page
reference it will credit the corresponding fs quota before calling the page
dtor.  This will catch pages that were mapped MAP_PRIVATE only as the file
will always hold the last reference on a MAP_SHARED page.

hugetlb_cow() is also updated to charge against quota before allocating the
new page.

Signed-off-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---

 mm/hugetlb.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ae2959b..0d645ca 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -685,7 +685,17 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 	flush_tlb_range(vma, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
-		put_page(page);
+		if (put_page_testzero(page)) {
+			/*
+			 * When releasing the last reference to a page we must
+			 * credit the quota.  For MAP_PRIVATE pages this occurs
+			 * when the last PTE is cleared, for MAP_SHARED pages
+			 * this occurs when the file is truncated.
+			 */
+			VM_BUG_ON(PageMapping(page));
+			hugetlb_put_quota(vma->vm_file->f_mapping);
+			free_huge_page(page);
+		}
 	}
 }
 
@@ -722,6 +732,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		set_huge_ptep_writable(vma, address, ptep);
 		return 0;
 	}
+	if (hugetlb_get_quota(vma->vm_file->f_mapping))
+		return VM_FAULT_SIGBUS;
 
 	page_cache_get(old_page);
 	new_page = alloc_huge_page(vma, address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
