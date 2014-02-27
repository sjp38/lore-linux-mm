Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0D16B0073
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:54:13 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so2949502pab.33
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 11:54:13 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id uc9si337496pac.123.2014.02.27.11.54.11
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 11:54:11 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 2/2] mm: implement ->map_pages for page cache
Date: Thu, 27 Feb 2014 21:53:47 +0200
Message-Id: <1393530827-25450-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

filemap_map_pages() is generic implementation of ->map_pages() for
filesystems who uses page cache.

It should be safe to use filemap_map_pages() for ->map_pages() if
filesystem use filemap_fault() for ->fault().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/9p/vfs_file.c   |  2 ++
 fs/btrfs/file.c    |  1 +
 fs/cifs/file.c     |  1 +
 fs/ext4/file.c     |  1 +
 fs/f2fs/file.c     |  1 +
 fs/fuse/file.c     |  1 +
 fs/gfs2/file.c     |  1 +
 fs/nfs/file.c      |  1 +
 fs/nilfs2/file.c   |  1 +
 fs/ubifs/file.c    |  1 +
 fs/xfs/xfs_file.c  |  1 +
 include/linux/mm.h |  1 +
 mm/filemap.c       | 72 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/nommu.c         |  6 +++++
 14 files changed, 91 insertions(+)

diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index a16b0ff497ca..d8223209d4b1 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -832,6 +832,7 @@ static void v9fs_mmap_vm_close(struct vm_area_struct *vma)
 
 static const struct vm_operations_struct v9fs_file_vm_ops = {
 	.fault = filemap_fault,
+	.map_pages = filemap_map_pages,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
@@ -839,6 +840,7 @@ static const struct vm_operations_struct v9fs_file_vm_ops = {
 static const struct vm_operations_struct v9fs_mmap_file_vm_ops = {
 	.close = v9fs_mmap_vm_close,
 	.fault = filemap_fault,
+	.map_pages = filemap_map_pages,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 0165b8672f09..d1f0415bbfb1 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1993,6 +1993,7 @@ out:
 
 static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= btrfs_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 755584684f6c..6d081de57fdb 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3094,6 +3094,7 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static struct vm_operations_struct cifs_file_vm_ops = {
 	.fault = filemap_fault,
+	.map_pages = filemap_map_pages,
 	.page_mkwrite = cifs_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 1a5073959f32..46e78f8a133f 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -200,6 +200,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
+	.map_pages	= filemap_map_pages,
 	.page_mkwrite   = ext4_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 0dfcef53a6ed..129a3bdb05ca 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -84,6 +84,7 @@ out:
 
 static const struct vm_operations_struct f2fs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= f2fs_vm_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 77bcc303c3ae..da99a76668f8 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1940,6 +1940,7 @@ static int fuse_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 static const struct vm_operations_struct fuse_file_vm_ops = {
 	.close		= fuse_vma_close,
 	.fault		= filemap_fault,
+	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= fuse_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index efc078f0ee4e..2739f3c3bb8f 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -494,6 +494,7 @@ out:
 
 static const struct vm_operations_struct gfs2_vm_ops = {
 	.fault = filemap_fault,
+	.map_pages = filemap_map_pages,
 	.page_mkwrite = gfs2_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5bb790a69c71..284ca901fe16 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -617,6 +617,7 @@ out:
 
 static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
+	.map_pages = filemap_map_pages,
 	.page_mkwrite = nfs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 08fdb77852ac..f3a82fbcae02 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -134,6 +134,7 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static const struct vm_operations_struct nilfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= nilfs_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 123c79b7261e..4f34dbae823d 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1538,6 +1538,7 @@ out_unlock:
 
 static const struct vm_operations_struct ubifs_file_vm_ops = {
 	.fault        = filemap_fault,
+	.map_pages = filemap_map_pages,
 	.page_mkwrite = ubifs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 64b48eade91d..b2be204e16ca 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1465,6 +1465,7 @@ const struct file_operations xfs_dir_file_operations = {
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/include/linux/mm.h b/include/linux/mm.h
index aed92cb17127..7c4bfb725e63 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1818,6 +1818,7 @@ extern void truncate_inode_pages_range(struct address_space *,
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
+extern void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf);
 extern int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 /* mm/page-writeback.c */
diff --git a/mm/filemap.c b/mm/filemap.c
index 7a13f6ac5421..1bc12a96060d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -33,6 +33,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
+#include <linux/rmap.h>
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -1726,6 +1727,76 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
+void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	loff_t size;
+	struct page *page;
+	unsigned long address = (unsigned long) vmf->virtual_address;
+	unsigned long addr;
+	pte_t *pte;
+
+	rcu_read_lock();
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, vmf->pgoff) {
+		if (iter.index > vmf->max_pgoff)
+			break;
+repeat:
+		page = radix_tree_deref_slot(slot);
+		if (radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page))
+				break;
+			else
+				goto next;
+		}
+
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *slot)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
+		if (!PageUptodate(page) ||
+				PageReadahead(page) ||
+				PageHWPoison(page))
+			goto skip;
+		if (!trylock_page(page))
+			goto skip;
+
+		if (page->mapping != mapping || !PageUptodate(page))
+			goto unlock;
+
+		size = i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1;
+		if (page->index >= size	>> PAGE_CACHE_SHIFT)
+			goto unlock;
+
+		pte = vmf->pte + page->index - vmf->pgoff;
+		if (!pte_none(*pte))
+			goto unlock;
+
+		if (file->f_ra.mmap_miss > 0)
+			file->f_ra.mmap_miss--;
+		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
+		do_set_pte(vma, addr, page, pte, false, false);
+		unlock_page(page);
+		goto next;
+unlock:
+		unlock_page(page);
+skip:
+		page_cache_release(page);
+next:
+		if (page->index == vmf->max_pgoff)
+			break;
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(filemap_map_pages);
+
 int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
@@ -1755,6 +1826,7 @@ EXPORT_SYMBOL(filemap_page_mkwrite);
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+	.map_pages	= filemap_map_pages,
 	.page_mkwrite	= filemap_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/mm/nommu.c b/mm/nommu.c
index 8740213b1647..ce401e37e29f 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1985,6 +1985,12 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 }
 EXPORT_SYMBOL(filemap_fault);
 
+void filemap_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	BUG();
+}
+EXPORT_SYMBOL(filemap_map_pages);
+
 int generic_file_remap_pages(struct vm_area_struct *vma, unsigned long addr,
 			     unsigned long size, pgoff_t pgoff)
 {
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
