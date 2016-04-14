Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 312946B0267
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:57:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c20so138829668pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 09:57:21 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id jj8si10506258pac.83.2016.04.14.09.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 09:57:17 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 1/2] dax: add dax_get_unmapped_area for pmd mappings
Date: Thu, 14 Apr 2016 10:48:30 -0600
Message-Id: <1460652511-19636-2-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, viro@zeniv.linux.org.uk
Cc: willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using pmd page
size.  This feature relies on both mmap virtual address and FS
block (i.e. physical address) to be aligned by the pmd page size.
Users can use mkfs options to specify FS to align block allocations.
However, aligning mmap address requires code changes to existing
applications for providing a pmd-aligned address to mmap().

For instance, fio with "ioengine=mmap" performs I/Os with mmap() [1].
It calls mmap() with a NULL address, which needs to be changed to
provide a pmd-aligned address for testing with DAX pmd mappings.
Changing all applications that call mmap() with NULL is undesirable.

Add dax_get_unmapped_area(), which can be called by filesystem's
get_unmapped_area to align an mmap address by the pmd size for
a DAX file.  It calls the default handler, mm->get_unmapped_area(),
to find a range and then aligns it for a DAX file.

[1]: https://github.com/axboe/fio/blob/master/engines/mmap.c
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
---
 fs/dax.c            |   43 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/dax.h |    3 +++
 2 files changed, 46 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index 75ba46d..f8ddd27 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1158,3 +1158,46 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
 	return dax_zero_page_range(inode, from, length, get_block);
 }
 EXPORT_SYMBOL_GPL(dax_truncate_page);
+
+/**
+ * dax_get_unmapped_area - handle get_unmapped_area for a DAX file
+ * @filp: The file being mmap'd, if not NULL
+ * @addr: The mmap address. If NULL, the kernel assigns the address
+ * @len: The mmap size in bytes
+ * @pgoff: The page offset in the file where the mapping starts from.
+ * @flags: The mmap flags
+ *
+ * This function can be called by a filesystem for get_unmapped_area().
+ * When a target file is a DAX file, it aligns the mmap address at the
+ * beginning of the file by the pmd size.
+ */
+unsigned long dax_get_unmapped_area(struct file *filp, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags)
+{
+	unsigned long off, off_end, off_pmd, len_pmd, addr_pmd;
+
+	if (!IS_ENABLED(CONFIG_FS_DAX_PMD) ||
+	    !filp || addr || !IS_DAX(filp->f_mapping->host))
+		goto out;
+
+	off = pgoff << PAGE_SHIFT;
+	off_end = off + len;
+	off_pmd = round_up(off, PMD_SIZE);  /* pmd-aligned offset */
+
+	if ((off_end <= off_pmd) || ((off_end - off_pmd) < PMD_SIZE))
+		goto out;
+
+	len_pmd = len + PMD_SIZE;
+	if ((off + len_pmd) < off)
+		goto out;
+
+	addr_pmd = current->mm->get_unmapped_area(filp, addr, len_pmd,
+						  pgoff, flags);
+	if (!IS_ERR_VALUE(addr_pmd)) {
+		addr_pmd += (off - addr_pmd) & (PMD_SIZE - 1);
+		return addr_pmd;
+	}
+out:
+	return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
+}
+EXPORT_SYMBOL_GPL(dax_get_unmapped_area);
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 636dd59..184b171 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -17,12 +17,15 @@ int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
 
 #ifdef CONFIG_FS_DAX
 struct page *read_dax_sector(struct block_device *bdev, sector_t n);
+unsigned long dax_get_unmapped_area(struct file *filp, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags);
 #else
 static inline struct page *read_dax_sector(struct block_device *bdev,
 		sector_t n)
 {
 	return ERR_PTR(-ENXIO);
 }
+#define dax_get_unmapped_area	NULL
 #endif
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
