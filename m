Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8B42682F64
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 14:39:40 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 65so12418356pff.3
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 11:39:40 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id a1si11908285pas.56.2015.12.23.11.39.39
        for <linux-mm@kvack.org>;
        Wed, 23 Dec 2015 11:39:39 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v6 5/7] ext2: call dax_pfn_mkwrite() for DAX fsync/msync
Date: Wed, 23 Dec 2015 12:39:18 -0700
Message-Id: <1450899560-26708-6-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

To properly support the new DAX fsync/msync infrastructure filesystems
need to call dax_pfn_mkwrite() so that DAX can track when user pages are
dirtied.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/ext2/file.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/ext2/file.c b/fs/ext2/file.c
index 11a42c5..2c88d68 100644
--- a/fs/ext2/file.c
+++ b/fs/ext2/file.c
@@ -102,8 +102,8 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 {
 	struct inode *inode = file_inode(vma->vm_file);
 	struct ext2_inode_info *ei = EXT2_I(inode);
-	int ret = VM_FAULT_NOPAGE;
 	loff_t size;
+	int ret;
 
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
@@ -113,6 +113,8 @@ static int ext2_dax_pfn_mkwrite(struct vm_area_struct *vma,
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
+	else
+		ret = dax_pfn_mkwrite(vma, vmf);
 
 	up_read(&ei->dax_sem);
 	sb_end_pagefault(inode->i_sb);
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
