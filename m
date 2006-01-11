Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0BM2gIs009975
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 17:02:42 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0BM2f4f045392
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 17:02:42 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0BM2fSp022049
	for <linux-mm@kvack.org>; Wed, 11 Jan 2006 17:02:41 -0500
Subject: [PATCH 1/2] hugetlb: Delay page zeroing for faulted pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1136920951.23288.5.camel@localhost.localdomain>
References: <1136920951.23288.5.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 11 Jan 2006 16:02:40 -0600
Message-Id: <1137016960.9672.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've come up with a much better idea to resolve the issue I mention
below.  The attached patch changes hugetlb_no_page to allocate unzeroed
huge pages initially.  For shared mappings, we wait until after
inserting the page into the page_cache succeeds before we zero it.  This
has a side benefit of preventing the wasted zeroing that happened often
in the original code.  The page_lock should guard against someone else
using the page before it has been zeroed (but correct me if I am wrong
here).  The patch doesn't completely close the race (there is a much
smaller window without the zeroing though).  The next patch should close
the race window completely.

On Tue, 2006-01-10 at 13:22 -0600, Adam Litke wrote: 
> The race occurs when multiple threads shmat a hugetlb area and begin
> faulting in it's pages.  During a hugetlb fault, hugetlb_no_page checks
> for the page in the page cache.  If not found, it allocates (and zeroes)
> a new page and tries to add it to the page cache.  If this fails, the
> huge page is freed and we retry the page cache lookup (assuming someone
> else beat us to the add_to_page_cache call).
> 
> The above works fine, but due to the large window (while zeroing the
> huge page) it is possible that many threads could be "borrowing" pages
> only to return them later.  This causes free_hugetlb_pages to be lower
> than the logical number of free pages and some threads trying to shmat
> can falsely fail the accounting check.

Signed-off-by: Adam Litke <agl@us.ibm.com>

 hugetlb.c |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)
diff -upN reference/mm/hugetlb.c current/mm/hugetlb.c
--- reference/mm/hugetlb.c
+++ current/mm/hugetlb.c
@@ -92,10 +92,10 @@ void free_huge_page(struct page *page)
 	spin_unlock(&hugetlb_lock);
 }
 
-struct page *alloc_huge_page(struct vm_area_struct *vma, unsigned long addr)
+struct page *alloc_unzeroed_huge_page(struct vm_area_struct *vma,
+					unsigned long addr)
 {
 	struct page *page;
-	int i;
 
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page(vma, addr);
@@ -106,8 +106,26 @@ struct page *alloc_huge_page(struct vm_a
 	spin_unlock(&hugetlb_lock);
 	set_page_count(page, 1);
 	page[1].mapping = (void *)free_huge_page;
+
+	return page;
+}
+	
+void zero_huge_page(struct page *page)
+{
+	int i;
+	
 	for (i = 0; i < (HPAGE_SIZE/PAGE_SIZE); ++i)
 		clear_highpage(&page[i]);
+}
+
+struct page *alloc_huge_page(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct page *page;
+
+	page = alloc_unzeroed_huge_page(vma, addr);
+	if (page)
+		zero_huge_page(page);
+	
 	return page;
 }
 
@@ -441,7 +459,7 @@ retry:
 	if (!page) {
 		if (hugetlb_get_quota(mapping))
 			goto out;
-		page = alloc_huge_page(vma, address);
+		page = alloc_unzeroed_huge_page(vma, address);
 		if (!page) {
 			hugetlb_put_quota(mapping);
 			goto out;
@@ -460,6 +478,8 @@ retry:
 			}
 		} else
 			lock_page(page);
+
+		zero_huge_page(page);
 	}
 
 	spin_lock(&mm->page_table_lock);


-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
