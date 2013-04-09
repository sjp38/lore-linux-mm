Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id B346F6B004D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 05:15:02 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH v3 12/18] Revert "ext4: fix fsx truncate failure"
Date: Tue,  9 Apr 2013 11:14:21 +0200
Message-Id: <1365498867-27782-13-git-send-email-lczerner@redhat.com>
In-Reply-To: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Lukas Czerner <lczerner@redhat.com>

This reverts commit 189e868fa8fdca702eb9db9d8afc46b5cb9144c9.

This commit reintroduces the use of ext4_block_truncate_page() in ext4
truncate operation instead of ext4_discard_partial_page_buffers().

The statement in the commit description that the truncate operation only
zero block unaligned portion of the last page is not exactly right,
since truncate_pagecache_range() also zeroes and invalidate the unaligned
portion of the page. Then there is no need to zero and unmap it once more
and ext4_block_truncate_page() was doing the right job, although we
still need to update the buffer head containing the last block, which is
exactly what ext4_block_truncate_page() is doing.

Moreover the problem described in the commit is fixed more properly with
commit

15291164b22a357cb211b618adfef4fa82fc0de3
	jbd2: clear BH_Delay & BH_Unwritten in journal_unmap_buffer

This was tested on ppc64 machine with block size of 1024 bytes without
any problems.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 fs/ext4/inode.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 5729d21..d58e13c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3920,7 +3920,6 @@ void ext4_truncate(struct inode *inode)
 	unsigned int credits;
 	handle_t *handle;
 	struct address_space *mapping = inode->i_mapping;
-	loff_t page_len;
 
 	/*
 	 * There is a possibility that we're either freeing the inode
@@ -3964,14 +3963,8 @@ void ext4_truncate(struct inode *inode)
 		return;
 	}
 
-	if (inode->i_size % PAGE_CACHE_SIZE != 0) {
-		page_len = PAGE_CACHE_SIZE -
-			(inode->i_size & (PAGE_CACHE_SIZE - 1));
-
-		if (ext4_discard_partial_page_buffers(handle,
-				mapping, inode->i_size, page_len, 0))
-			goto out_stop;
-	}
+	if (inode->i_size & (inode->i_sb->s_blocksize - 1))
+		ext4_block_truncate_page(handle, mapping, inode->i_size);
 
 	/*
 	 * We add the inode to the orphan list, so that if this
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
