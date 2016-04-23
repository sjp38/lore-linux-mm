Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FCF06B0253
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 20:30:10 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id js7so188845840obc.0
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 17:30:10 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id zb6si3752800obb.107.2016.04.22.17.30.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 17:30:09 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 1/2] thp, dax: add thp_get_unmapped_area for pmd mappings
Date: Fri, 22 Apr 2016 18:21:22 -0600
Message-Id: <1461370883-7664-2-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1461370883-7664-1-git-send-email-toshi.kani@hpe.com>
References: <1461370883-7664-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, viro@zeniv.linux.org.uk, willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, mike.kravetz@oracle.com, toshi.kani@hpe.com, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

Add thp_get_unmapped_area(), which can be called by filesystem's
get_unmapped_area to align an mmap address by the pmd size for
a DAX file.  It calls the default handler, mm->get_unmapped_area(),
to find a range and then aligns it for a DAX file.

thp_get_unmapped_area() can be extended for huge page cache support.

The patch is based on Matthew Wilcox's change that allows adding
support of the pud page size easily.

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
Cc: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/huge_mm.h |    7 +++++++
 mm/huge_memory.c        |   43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7008623..3769674 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -85,6 +85,10 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 extern unsigned long transparent_hugepage_flags;
 
+extern unsigned long thp_get_unmapped_area(struct file *filp,
+		unsigned long addr, unsigned long len, unsigned long pgoff,
+		unsigned long flags);
+
 extern void prep_transhuge_page(struct page *page);
 extern void free_transhuge_page(struct page *page);
 
@@ -163,6 +167,9 @@ struct page *get_huge_zero_page(void);
 #define transparent_hugepage_enabled(__vma) 0
 
 #define transparent_hugepage_flags 0UL
+
+#define thp_get_unmapped_area	NULL
+
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 86f9f8b..2181c7f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -790,6 +790,49 @@ void prep_transhuge_page(struct page *page)
 	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
 }
 
+unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
+		loff_t off, unsigned long flags, unsigned long size)
+{
+	unsigned long addr;
+	loff_t off_end = off + len;
+	loff_t off_align = round_up(off, size);
+	unsigned long len_pad;
+
+	if (off_end <= off_align || (off_end - off_align) < size)
+		return 0;
+
+	len_pad = len + size;
+	if (len_pad < len || (off + len_pad) < off)
+		return 0;
+
+	addr = current->mm->get_unmapped_area(filp, 0, len_pad,
+					      off >> PAGE_SHIFT, flags);
+	if (IS_ERR_VALUE(addr))
+		return 0;
+
+	addr += (off - addr) & (size - 1);
+	return addr;
+}
+
+unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags)
+{
+	loff_t off = (loff_t)pgoff << PAGE_SHIFT;
+
+	if (addr)
+		goto out;
+	if (!IS_DAX(filp->f_mapping->host) || !IS_ENABLED(CONFIG_FS_DAX_PMD))
+		goto out;
+
+	addr = __thp_get_unmapped_area(filp, len, off, flags, PMD_SIZE);
+	if (addr)
+		return addr;
+
+ out:
+	return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
+}
+EXPORT_SYMBOL_GPL(thp_get_unmapped_area);
+
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmd,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
