Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CA0CF6B007B
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 09:28:04 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so5801306pab.5
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 06:28:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id be7si4897158pdb.286.2014.08.01.06.28.02
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 06:28:02 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v9 20/22] ext4: Avoid lock inversion between i_mmap_mutex and transaction start
Date: Fri,  1 Aug 2014 09:27:36 -0400
Message-Id: <b153961fec89926502fbe24c571a5dc2172d9a5e.1406897885.git.willy@linux.intel.com>
In-Reply-To: <cover.1406897885.git.willy@linux.intel.com>
References: <cover.1406897885.git.willy@linux.intel.com>
In-Reply-To: <cover.1406897885.git.willy@linux.intel.com>
References: <cover.1406897885.git.willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Jan Kara <jack@suse.cz>, willy@linux.intel.com, Matthew Wilcox <matthew.r.wilcox@intel.com>

From: Jan Kara <jack@suse.cz>

When DAX is enabled, it uses i_mmap_mutex as a protection against
truncate during page fault. This inevitably forces i_mmap_mutex to rank
outside of a transaction start and thus we have to avoid calling
pagecache purging operations when transaction is started.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 fs/ext4/inode.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 8a06473..494a864 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3631,13 +3631,19 @@ int ext4_punch_hole(struct inode *inode, loff_t offset, loff_t length)
 	if (IS_SYNC(inode))
 		ext4_handle_sync(handle);
 
-	/* Now release the pages again to reduce race window */
+	inode->i_mtime = inode->i_ctime = ext4_current_time(inode);
+	ext4_mark_inode_dirty(handle, inode);
+	ext4_journal_stop(handle);
+
+	/*
+	 * Now release the pages again to reduce race window. This has to happen
+	 * outside of a transaction to avoid lock inversion on i_mmap_mutex
+	 * when DAX is enabled.
+	 */
 	if (last_block_offset > first_block_offset)
 		truncate_pagecache_range(inode, first_block_offset,
 					 last_block_offset);
-
-	inode->i_mtime = inode->i_ctime = ext4_current_time(inode);
-	ext4_mark_inode_dirty(handle, inode);
+	goto out_dio;
 out_stop:
 	ext4_journal_stop(handle);
 out_dio:
-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
