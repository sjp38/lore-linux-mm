Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id EACAD6B000D
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 00:22:39 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id o64so59312648pfb.3
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 21:22:39 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id f12si28847882pat.121.2015.12.18.21.22.39
        for <linux-mm@kvack.org>;
        Fri, 18 Dec 2015 21:22:39 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 7/7] xfs: call dax_pfn_mkwrite() for DAX fsync/msync
Date: Fri, 18 Dec 2015 22:22:20 -0700
Message-Id: <1450502540-8744-8-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

To properly support the new DAX fsync/msync infrastructure filesystems
need to call dax_pfn_mkwrite() so that DAX can track when user pages are
dirtied.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/xfs/xfs_file.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index f5392ab..40ffbb1 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1603,9 +1603,8 @@ xfs_filemap_pmd_fault(
 /*
  * pfn_mkwrite was originally inteneded to ensure we capture time stamp
  * updates on write faults. In reality, it's need to serialise against
- * truncate similar to page_mkwrite. Hence we open-code dax_pfn_mkwrite()
- * here and cycle the XFS_MMAPLOCK_SHARED to ensure we serialise the fault
- * barrier in place.
+ * truncate similar to page_mkwrite. Hence we cycle the XFS_MMAPLOCK_SHARED
+ * to ensure we serialise the fault barrier in place.
  */
 static int
 xfs_filemap_pfn_mkwrite(
@@ -1628,6 +1627,8 @@ xfs_filemap_pfn_mkwrite(
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (vmf->pgoff >= size)
 		ret = VM_FAULT_SIGBUS;
+	else if (IS_DAX(inode))
+		ret = dax_pfn_mkwrite(vma, vmf);
 	xfs_iunlock(ip, XFS_MMAPLOCK_SHARED);
 	sb_end_pagefault(inode->i_sb);
 	return ret;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
