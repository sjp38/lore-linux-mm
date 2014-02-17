Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4EE6B0036
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 13:39:11 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so15231768pde.20
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 10:39:10 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id n8si15677428pax.15.2014.02.17.10.39.09
        for <linux-mm@kvack.org>;
        Mon, 17 Feb 2014 10:39:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: implement ->fault_nonblock() for page cache
Date: Mon, 17 Feb 2014 20:38:53 +0200
Message-Id: <1392662333-25470-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

filemap_fault_nonblock() is generic implementation of ->fault_nonblock()
for filesystems who uses page cache.

It should be safe to use filemap_fault_nonblock() for ->fault_nonblock()
if filesystem use filemap_fault() for ->fault().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/9p/vfs_file.c  |  2 ++
 fs/btrfs/file.c   |  1 +
 fs/cifs/file.c    |  1 +
 fs/ext4/file.c    |  1 +
 fs/f2fs/file.c    |  1 +
 fs/fuse/file.c    |  1 +
 fs/gfs2/file.c    |  1 +
 fs/nfs/file.c     |  1 +
 fs/nilfs2/file.c  |  1 +
 fs/ubifs/file.c   |  1 +
 fs/xfs/xfs_file.c |  1 +
 mm/filemap.c      | 35 +++++++++++++++++++++++++++++++++++
 12 files changed, 47 insertions(+)

diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index a16b0ff497ca..a7f7e41bec37 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -832,6 +832,7 @@ static void v9fs_mmap_vm_close(struct vm_area_struct *vma)
 
 static const struct vm_operations_struct v9fs_file_vm_ops = {
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
@@ -839,6 +840,7 @@ static const struct vm_operations_struct v9fs_file_vm_ops = {
 static const struct vm_operations_struct v9fs_mmap_file_vm_ops = {
 	.close = v9fs_mmap_vm_close,
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = v9fs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/btrfs/file.c b/fs/btrfs/file.c
index 0165b8672f09..13523a63e1f3 100644
--- a/fs/btrfs/file.c
+++ b/fs/btrfs/file.c
@@ -1993,6 +1993,7 @@ out:
 
 static const struct vm_operations_struct btrfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= btrfs_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 755584684f6c..71aff75e067c 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3094,6 +3094,7 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static struct vm_operations_struct cifs_file_vm_ops = {
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = cifs_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 1a5073959f32..182ae5543a1d 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -200,6 +200,7 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite   = ext4_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 0dfcef53a6ed..7c48fd2eb99c 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -84,6 +84,7 @@ out:
 
 static const struct vm_operations_struct f2fs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= f2fs_vm_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 77bcc303c3ae..e95e52ec7bc2 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1940,6 +1940,7 @@ static int fuse_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 static const struct vm_operations_struct fuse_file_vm_ops = {
 	.close		= fuse_vma_close,
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= fuse_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index efc078f0ee4e..7c4b2f096ac8 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -494,6 +494,7 @@ out:
 
 static const struct vm_operations_struct gfs2_vm_ops = {
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = gfs2_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5bb790a69c71..8fbe80168d1f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -617,6 +617,7 @@ out:
 
 static const struct vm_operations_struct nfs_file_vm_ops = {
 	.fault = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = nfs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 08fdb77852ac..adc4aa07d7d8 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -134,6 +134,7 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 static const struct vm_operations_struct nilfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= nilfs_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 123c79b7261e..f27c4c401a3f 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1538,6 +1538,7 @@ out_unlock:
 
 static const struct vm_operations_struct ubifs_file_vm_ops = {
 	.fault        = filemap_fault,
+	.fault_nonblock = filemap_fault_nonblock,
 	.page_mkwrite = ubifs_vm_page_mkwrite,
 	.remap_pages = generic_file_remap_pages,
 };
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 64b48eade91d..bc619150c960 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1465,6 +1465,7 @@ const struct file_operations xfs_dir_file_operations = {
 
 static const struct vm_operations_struct xfs_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= xfs_vm_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
diff --git a/mm/filemap.c b/mm/filemap.c
index 7a13f6ac5421..7b7c9c600544 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1726,6 +1726,40 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
+void filemap_fault_nonblock(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	pgoff_t size;
+	struct page *page;
+
+	page = find_get_page(mapping, vmf->pgoff);
+	if (!page)
+		return;
+	if (PageReadahead(page) || PageHWPoison(page))
+		goto put;
+	if (!trylock_page(page))
+		goto put;
+	/* Truncated? */
+	if (unlikely(page->mapping != mapping))
+		goto unlock;
+	if (unlikely(!PageUptodate(page)))
+		goto unlock;
+	size = (i_size_read(mapping->host) + PAGE_CACHE_SIZE - 1)
+		>> PAGE_CACHE_SHIFT;
+	if (unlikely(page->index >= size))
+		goto unlock;
+	if (file->f_ra.mmap_miss > 0)
+		file->f_ra.mmap_miss--;
+	vmf->page = page;
+	return;
+unlock:
+	unlock_page(page);
+put:
+	put_page(page);
+}
+EXPORT_SYMBOL(filemap_fault_nonblock);
+
 int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
@@ -1755,6 +1789,7 @@ EXPORT_SYMBOL(filemap_page_mkwrite);
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+	.fault_nonblock	= filemap_fault_nonblock,
 	.page_mkwrite	= filemap_page_mkwrite,
 	.remap_pages	= generic_file_remap_pages,
 };
-- 
1.9.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
