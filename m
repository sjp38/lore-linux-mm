Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 17D7D6B0038
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 22:06:12 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so6889249pdj.22
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 19:06:11 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pk8si17356359pab.184.2014.02.10.19.06.10
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 19:06:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: implement FAULT_FLAG_AROUND in filemap_fault()
Date: Tue, 11 Feb 2014 05:05:57 +0200
Message-Id: <1392087957-15730-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If FAULT_FLAG_AROUND is set filemap_fault() will use find_get_pages()
for batched pages lookup.

Pages returned by find_get_pages() will be handled differently: page
with index vmf->pgoff will take normal filemap_fault() code path.

For all other pages we will not attempt retry locking or wait page to be
up-to-date, just give up and go to the next page.

I'm not sure how we should deal with readahead() here. For now I just
call do_async_mmap_readahead(). It probably breaks readahead heuristics:
interleaving access looks as sequential.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 77 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 73 insertions(+), 4 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d56d3c145b9f..4d00fc0094f6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1593,6 +1593,64 @@ static void do_async_mmap_readahead(struct vm_area_struct *vma,
 					   page, offset, ra->ra_pages);
 }
 
+static struct page *lock_secondary_pages(struct vm_area_struct *vma,
+		struct vm_fault *vmf)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct page *primary_page = NULL, **pages = vmf->pages;
+	pgoff_t size;
+	int i;
+
+	for (i = 0; i < vmf->nr_pages; i++) {
+		if (!pages[i])
+			continue;
+		if (pages[i]->index == vmf->pgoff) {
+			primary_page = pages[i];
+			pages[i] = NULL;
+			continue;
+		}
+		if (pages[i]->index > vmf->max)
+			goto put;
+		do_async_mmap_readahead(vma, &file->f_ra, file,
+				pages[i], pages[i]->index);
+		if (!trylock_page(pages[i]))
+			goto put;
+		/* Truncated? */
+		if (unlikely(pages[i]->mapping != mapping))
+			goto unlock;
+		if (unlikely(!PageUptodate(pages[i])))
+			goto unlock;
+		size = (i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1)
+			>> PAGE_CACHE_SHIFT;
+		if (unlikely(pages[i]->index >= size))
+			goto unlock;
+		continue;
+unlock:
+		unlock_page(pages[i]);
+put:
+		put_page(pages[i]);
+		pages[i] = NULL;
+	}
+
+	return primary_page;
+}
+
+static void unlock_and_put_secondary_pages(struct vm_fault *vmf)
+{
+       int i;
+
+       if (!(vmf->flags & FAULT_FLAG_AROUND))
+	       return;
+       for (i = 0; i < vmf->nr_pages; i++) {
+               if (!vmf->pages[i])
+                       continue;
+               unlock_page(vmf->pages[i]);
+               page_cache_release(vmf->pages[i]);
+               vmf->pages[i] = NULL;
+       }
+}
+
 /**
  * filemap_fault - read in file data for page fault handling
  * @vma:	vma in which the fault was taken
@@ -1624,7 +1682,15 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	/*
 	 * Do we have something in the page cache already?
 	 */
-	page = find_get_page(mapping, offset);
+	if (vmf->flags & FAULT_FLAG_AROUND) {
+		ret = find_get_pages(mapping, vmf->min, vmf->nr_pages,
+				vmf->pages);
+		memset(vmf->pages + ret, 0,
+				sizeof(struct page *) * (vmf->nr_pages - ret));
+		page = lock_secondary_pages(vma, vmf);
+		ret = VM_FAULT_AROUND;
+	} else
+		page = find_get_page(mapping, offset);
 	if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
 		/*
 		 * We found the page, so try async readahead before
@@ -1636,7 +1702,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		do_sync_mmap_readahead(vma, ra, file, offset);
 		count_vm_event(PGMAJFAULT);
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
-		ret = VM_FAULT_MAJOR;
+		ret |= VM_FAULT_MAJOR;
 retry_find:
 		page = find_get_page(mapping, offset);
 		if (!page)
@@ -1644,12 +1710,14 @@ retry_find:
 	}
 
 	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
+		unlock_and_put_secondary_pages(vmf);
 		page_cache_release(page);
-		return ret | VM_FAULT_RETRY;
+		return (ret & ~VM_FAULT_AROUND) | VM_FAULT_RETRY;
 	}
 
 	/* Did it get truncated? */
 	if (unlikely(page->mapping != mapping)) {
+		unlock_and_put_secondary_pages(vmf);
 		unlock_page(page);
 		put_page(page);
 		goto retry_find;
@@ -1691,7 +1759,7 @@ no_cached_page:
 	 */
 	if (error >= 0)
 		goto retry_find;
-
+	unlock_and_put_secondary_pages(vmf);
 	/*
 	 * An error return from page_cache_read can result if the
 	 * system is low on memory, or a problem occurs while trying
@@ -1719,6 +1787,7 @@ page_not_uptodate:
 
 	if (!error || error == AOP_TRUNCATED_PAGE)
 		goto retry_find;
+	unlock_and_put_secondary_pages(vmf);
 
 	/* Things didn't work out. Return zero to tell the mm layer so. */
 	shrink_readahead_size_eio(file, ra);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
