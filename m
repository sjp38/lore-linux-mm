Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id D7C466B00C6
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:27 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 29/34] thp, mm: basic huge_fault implementation for generic_file_vm_ops
Date: Fri,  5 Apr 2013 14:59:53 +0300
Message-Id: <1365163198-29726-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It provide enough functionality for simple cases like ramfs. Need to be
extended later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index 6f0e3be..a170a40 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1768,6 +1768,81 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static int filemap_huge_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	pgoff_t size, offset = vmf->pgoff;
+	unsigned long address = (unsigned long) vmf->virtual_address;
+	struct page *page;
+	int ret = 0;
+
+	BUG_ON(((address >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
+			(offset & HPAGE_CACHE_INDEX_MASK));
+
+retry:
+	page = find_get_page(mapping, offset);
+	if (!page) {
+		gfp_t gfp_mask = mapping_gfp_mask(mapping) | __GFP_COLD;
+		page = alloc_pages_vma(gfp_mask, HPAGE_PMD_ORDER,
+				vma, address, 0);
+		if (!page) {
+			count_vm_event(THP_FAULT_FALLBACK);
+			return VM_FAULT_OOM;
+		}
+		count_vm_event(THP_FAULT_ALLOC);
+		ret = add_to_page_cache_lru(page, mapping, offset, GFP_KERNEL);
+		if (ret == 0)
+			ret = mapping->a_ops->readpage(file, page);
+		else if (ret == -EEXIST)
+			ret = 0; /* losing race to add is OK */
+		page_cache_release(page);
+		if (!ret || ret == AOP_TRUNCATED_PAGE)
+			goto retry;
+		return ret;
+	}
+
+	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
+		page_cache_release(page);
+		return ret | VM_FAULT_RETRY;
+	}
+
+	/* Did it get truncated? */
+	if (unlikely(page->mapping != mapping)) {
+		unlock_page(page);
+		put_page(page);
+		goto retry;
+	}
+	VM_BUG_ON(page->index != offset);
+	VM_BUG_ON(!PageUptodate(page));
+
+	if (!PageTransHuge(page)) {
+		unlock_page(page);
+		put_page(page);
+		/* Ask fallback to small pages */
+		return VM_FAULT_OOM;
+	}
+
+	/*
+	 * Found the page and have a reference on it.
+	 * We must recheck i_size under page lock.
+	 */
+	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	if (unlikely(offset >= size)) {
+		unlock_page(page);
+		page_cache_release(page);
+		return VM_FAULT_SIGBUS;
+	}
+
+	vmf->page = page;
+	return ret | VM_FAULT_LOCKED;
+}
+#else
+#define filemap_huge_fault NULL
+#endif
+
 int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
@@ -1797,6 +1872,7 @@ EXPORT_SYMBOL(filemap_page_mkwrite);
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+	.huge_fault	= filemap_huge_fault,
 	.page_mkwrite	= filemap_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
