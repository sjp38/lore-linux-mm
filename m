Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 481E26B0029
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 23:29:50 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z5so9548072pfe.16
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 20:29:50 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c14si2198994pgu.341.2018.02.26.20.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 20:29:49 -0800 (PST)
Subject: [PATCH v4 09/12] mm,
 dax: replace IS_DAX() with IS_DEVDAX() or IS_FSDAX()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 26 Feb 2018 20:20:42 -0800
Message-ID: <151970524289.26729.18096955322602992171.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151970519370.26729.1011551137381425076.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

In preparation for fixing the broken definition of S_DAX in the
CONFIG_FS_DAX=n + CONFIG_DEV_DAX=y case, convert all IS_DAX() usages to
use explicit tests for the DEVDAX and FSDAX sub-cases of DAX
functionality.

Cc: Jan Kara <jack@suse.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: <stable@vger.kernel.org>
Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/fs.h |   16 +++++++---------
 mm/fadvise.c       |    3 ++-
 mm/filemap.c       |    4 ++--
 mm/huge_memory.c   |    4 +++-
 mm/madvise.c       |    3 ++-
 5 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index bd0c46880572..4a5aa8761011 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3208,21 +3208,19 @@ static inline bool io_is_direct(struct file *filp)
 
 static inline bool vma_is_dax(struct vm_area_struct *vma)
 {
-	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
+	struct inode *inode;
+
+	if (!vma->vm_file)
+		return false;
+	inode = vma->vm_file->f_mapping->host;
+	return IS_FSDAX(inode) || IS_DEVDAX(inode);
 }
 
 static inline bool vma_is_fsdax(struct vm_area_struct *vma)
 {
-	struct inode *inode;
-
 	if (!vma->vm_file)
 		return false;
-	if (!vma_is_dax(vma))
-		return false;
-	inode = file_inode(vma->vm_file);
-	if (S_ISCHR(inode->i_mode))
-		return false; /* device-dax */
-	return true;
+	return IS_FSDAX(file_inode(vma->vm_file));
 }
 
 static inline int iocb_flags(struct file *file)
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 767887f5f3bf..00d9317636a2 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -55,7 +55,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 
 	bdi = inode_to_bdi(mapping->host);
 
-	if (IS_DAX(inode) || (bdi == &noop_backing_dev_info)) {
+	if (IS_FSDAX(inode) || IS_DEVDAX(inode)
+			|| (bdi == &noop_backing_dev_info)) {
 		switch (advice) {
 		case POSIX_FADV_NORMAL:
 		case POSIX_FADV_RANDOM:
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f62212a59..4bc4e067ebf2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2357,7 +2357,7 @@ generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
 		 * DAX files, so don't bother trying.
 		 */
 		if (retval < 0 || !count || iocb->ki_pos >= size ||
-		    IS_DAX(inode))
+		    IS_FSDAX(inode))
 			goto out;
 	}
 
@@ -3225,7 +3225,7 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 		 * not succeed (even if it did, DAX does not handle dirty
 		 * page-cache pages correctly).
 		 */
-		if (written < 0 || !iov_iter_count(from) || IS_DAX(inode))
+		if (written < 0 || !iov_iter_count(from) || IS_FSDAX(inode))
 			goto out;
 
 		status = generic_perform_write(file, from, pos = iocb->ki_pos);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87ab9b8f56b5..ed238936e29b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -529,10 +529,12 @@ unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags)
 {
 	loff_t off = (loff_t)pgoff << PAGE_SHIFT;
+	struct inode *inode;
 
 	if (addr)
 		goto out;
-	if (!IS_DAX(filp->f_mapping->host) || !IS_ENABLED(CONFIG_FS_DAX_PMD))
+	inode = filp->f_mapping->host;
+	if (!IS_FSDAX(inode) || !IS_ENABLED(CONFIG_FS_DAX_PMD))
 		goto out;
 
 	addr = __thp_get_unmapped_area(filp, len, off, flags, PMD_SIZE);
diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..bdb83cf018b1 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -275,6 +275,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
 	struct file *file = vma->vm_file;
+	struct inode *inode = file_inode(file);
 
 	*prev = vma;
 #ifdef CONFIG_SWAP
@@ -293,7 +294,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
 		return -EBADF;
 #endif
 
-	if (IS_DAX(file_inode(file))) {
+	if (IS_FSDAX(inode) || IS_DEVDAX(inode)) {
 		/* no bad return value, but ignore advice */
 		return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
