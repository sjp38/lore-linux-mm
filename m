Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 51B2982F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:52 -0400 (EDT)
Received: by ioll68 with SMTP id l68so59042014iol.3
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:52 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x8si4630009igg.87.2015.10.29.13.12.38
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:39 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 11/11] ext4: add ext4_dax_pfn_mkwrite()
Date: Thu, 29 Oct 2015 14:12:15 -0600
Message-Id: <1446149535-16200-12-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Add ext4_dax_pfn_mkwrite() that properly protects against freeze, sets
the file update time and calls into dax_pfn_mkwrite() to add the newly
dirtied page to the radix tree which tracks dirty DAX pages.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/ext4/file.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 54d7729..7f62cad 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -272,11 +272,31 @@ static int ext4_dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 				ext4_end_io_unwritten);
 }
 
+static int ext4_dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct inode *inode = file_inode(vma->vm_file);
+	loff_t size;
+	int ret;
+
+	sb_start_pagefault(inode->i_sb);
+	file_update_time(vma->vm_file);
+
+	/* check that the faulting page hasn't raced with truncate */
+	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (vmf->pgoff >= size)
+		ret = VM_FAULT_SIGBUS;
+	else
+		ret = dax_pfn_mkwrite(vma, vmf);
+
+	sb_end_pagefault(inode->i_sb);
+	return ret;
+}
+
 static const struct vm_operations_struct ext4_dax_vm_ops = {
 	.fault		= ext4_dax_fault,
 	.pmd_fault	= ext4_dax_pmd_fault,
 	.page_mkwrite	= ext4_dax_mkwrite,
-	.pfn_mkwrite	= dax_pfn_mkwrite,
+	.pfn_mkwrite	= ext4_dax_pfn_mkwrite,
 };
 #else
 #define ext4_dax_vm_ops	ext4_file_vm_ops
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
