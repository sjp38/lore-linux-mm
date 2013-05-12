Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id E0DBA6B006E
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:39 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 34/39] thp, mm: handle huge pages in filemap_fault()
Date: Sun, 12 May 2013 04:23:31 +0300
Message-Id: <1368321816-17719-35-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If caller asks for huge page (flags & FAULT_FLAG_TRANSHUGE),
filemap_fault() return it if there's a huge page already by the offset.

If the area of page cache required to create huge is empty, we create a
new huge page and return it.

Otherwise we return VM_FAULT_FALLBACK to indicate that fallback to small
pages is required.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   52 +++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 43 insertions(+), 9 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 9877347..1deedd6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1557,14 +1557,23 @@ EXPORT_SYMBOL(generic_file_aio_read);
  * This adds the requested page to the page cache if it isn't already there,
  * and schedules an I/O to read in its contents from disk.
  */
-static int page_cache_read(struct file *file, pgoff_t offset)
+static int page_cache_read(struct file *file, pgoff_t offset, bool thp)
 {
 	struct address_space *mapping = file->f_mapping;
-	struct page *page; 
+	struct page *page;
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		if (thp) {
+			gfp_t gfp_mask = mapping_gfp_mask(mapping) | __GFP_COLD;
+			BUG_ON(offset & HPAGE_CACHE_INDEX_MASK);
+			page = alloc_pages(gfp_mask, HPAGE_PMD_ORDER);
+			if (page)
+				count_vm_event(THP_FAULT_ALLOC);
+			else
+				count_vm_event(THP_FAULT_FALLBACK);
+		} else
+			page = page_cache_alloc_cold(mapping);
 		if (!page)
 			return -ENOMEM;
 
@@ -1573,11 +1582,18 @@ static int page_cache_read(struct file *file, pgoff_t offset)
 			ret = mapping->a_ops->readpage(file, page);
 		else if (ret == -EEXIST)
 			ret = 0; /* losing race to add is OK */
+		else if (ret == -ENOSPC)
+			/*
+			 * No space in page cache to add huge page.
+			 * For caller it's the same as -ENOMEM: fall back to
+			 * small pages is required.
+			 */
+			ret = -ENOMEM;
 
 		page_cache_release(page);
 
 	} while (ret == AOP_TRUNCATED_PAGE);
-		
+
 	return ret;
 }
 
@@ -1669,13 +1685,20 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct address_space *mapping = file->f_mapping;
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
+	bool thp = vmf->flags & FAULT_FLAG_TRANSHUGE;
 	pgoff_t offset = vmf->pgoff;
+	unsigned long address = (unsigned long)vmf->virtual_address;
 	struct page *page;
 	pgoff_t size;
 	int ret = 0;
 
+	if (thp) {
+		BUG_ON(ra->ra_pages);
+		offset = linear_page_index(vma, address & HPAGE_PMD_MASK);
+	}
+
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (offset >= size)
+	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -1700,7 +1723,8 @@ retry_find:
 			goto no_cached_page;
 	}
 
-	if (PageTransCompound(page))
+	/* Split huge page if we don't want huge page to be here */
+	if (!thp && PageTransCompound(page))
 		split_huge_page(compound_trans_head(page));
 	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
 		page_cache_release(page);
@@ -1722,12 +1746,22 @@ retry_find:
 	if (unlikely(!PageUptodate(page)))
 		goto page_not_uptodate;
 
+	if (thp && !PageTransHuge(page)) {
+		/*
+		 * Caller asked for huge page, but we have small page
+		 * by this offset. Fallback to small pages.
+		 */
+		unlock_page(page);
+		page_cache_release(page);
+		return VM_FAULT_FALLBACK;
+	}
+
 	/*
 	 * Found the page and have a reference on it.
 	 * We must recheck i_size under page lock.
 	 */
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (unlikely(offset >= size)) {
+	if (unlikely(vmf->pgoff >= size)) {
 		unlock_page(page);
 		page_cache_release(page);
 		return VM_FAULT_SIGBUS;
@@ -1741,7 +1775,7 @@ no_cached_page:
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
-	error = page_cache_read(file, offset);
+	error = page_cache_read(file, offset, thp);
 
 	/*
 	 * The page we want has now been added to the page cache.
@@ -1757,7 +1791,7 @@ no_cached_page:
 	 * to schedule I/O.
 	 */
 	if (error == -ENOMEM)
-		return VM_FAULT_OOM;
+		return VM_FAULT_OOM | VM_FAULT_FALLBACK;
 	return VM_FAULT_SIGBUS;
 
 page_not_uptodate:
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
