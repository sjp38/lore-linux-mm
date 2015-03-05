Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id A62526B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 04:24:54 -0500 (EST)
Received: by wesw62 with SMTP id w62so51654369wes.9
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 01:24:54 -0800 (PST)
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id mz12si12860359wic.68.2015.03.05.01.24.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 01:24:53 -0800 (PST)
Received: by wghk14 with SMTP id k14so8247695wgh.7
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 01:24:52 -0800 (PST)
Message-ID: <54F820E2.9060109@plexistor.com>
Date: Thu, 05 Mar 2015 11:24:50 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 3/3 v2] dax: use pfn_mkwrite to update c/mtime + freeze protection
References: <54F733BD.7060807@plexistor.com> <54F73746.5020300@plexistor.com> <20150304171935.GA5443@quack.suse.cz>
In-Reply-To: <20150304171935.GA5443@quack.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

From: Yigal Korman <yigal@plexistor.com>

[v1]
Without this patch, c/mtime is not updated correctly when mmap'ed page is
first read from and then written to.

A new xfstest is submitted for testing this (generic/080)

[v2]
Jan Kara has pointed out that if we add the
sb_start/end_pagefault pair in the new pfn_mkwrite we
are then fixing another bug where: A user could start
writing to the page while filesystem is frozen.

CC: Jan Kara <jack@suse.cz>
Signed-off-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 fs/dax.c           | 17 +++++++++++++++++
 fs/ext2/file.c     |  1 +
 fs/ext4/file.c     |  1 +
 include/linux/fs.h |  1 +
 4 files changed, 20 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index ed1619e..d0bd1f4 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -464,6 +464,23 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
 EXPORT_SYMBOL_GPL(dax_fault);
 
 /**
+ * dax_pfn_mkwrite - handle first write to DAX page
+ * @vma: The virtual memory area where the fault occurred
+ * @vmf: The description of the fault
+ *
+ */
+int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
+
+	sb_start_pagefault(sb);
+	file_update_time(vma->vm_file);
+	sb_end_pagefault(sb);
+	return VM_FAULT_NOPAGE;
+}
+EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
+
+/**
  * dax_zero_page_range - zero a range within a page of a DAX file
  * @inode: The file being truncated
  * @from: The file offset that is being truncated to
diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index e317017..866a3ce 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -39,6 +39,7 @@ static int ext2_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 static const struct vm_operations_struct ext2_dax_vm_ops = {
 	.fault		= ext2_dax_fault,
 	.page_mkwrite	= ext2_dax_mkwrite,
+	.pfn_mkwrite	= dax_pfn_mkwrite,
 };
 
 static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 33a09da..b43a7a6 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -206,6 +206,7 @@ static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
 	.page_mkwrite	= ext4_dax_mkwrite,
+	.pfn_mkwrite	= dax_pfn_mkwrite,
 };
 #else
 #define ext4_dax_vm_ops	ext4_file_vm_ops
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b4d71b5..24af817 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2597,6 +2597,7 @@ int dax_clear_blocks(struct inode *, sector_t block, long size);
 int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
+int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
 #define dax_mkwrite(vma, vmf, gb)	dax_fault(vma, vmf, gb)
 
 #ifdef CONFIG_BLOCK
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
