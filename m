Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 63B176B0082
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 18:22:16 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 09/15 v2] Revert "ext4: fix fsx truncate failure"
Date: Fri, 31 Aug 2012 18:21:45 -0400
Message-Id: <1346451711-1931-10-git-send-email-lczerner@redhat.com>
In-Reply-To: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org, Lukas Czerner <lczerner@redhat.com>

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
 fs/ext4/extents.c  |   13 ++-----------
 fs/ext4/indirect.c |   13 ++-----------
 2 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index f920383..8336e4e 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -4234,7 +4234,6 @@ void ext4_ext_truncate(struct inode *inode)
 	struct super_block *sb = inode->i_sb;
 	ext4_lblk_t last_block;
 	handle_t *handle;
-	loff_t page_len;
 	int err = 0;
 
 	/*
@@ -4251,16 +4250,8 @@ void ext4_ext_truncate(struct inode *inode)
 	if (IS_ERR(handle))
 		return;
 
-	if (inode->i_size % PAGE_CACHE_SIZE != 0) {
-		page_len = PAGE_CACHE_SIZE -
-			(inode->i_size & (PAGE_CACHE_SIZE - 1));
-
-		err = ext4_discard_partial_page_buffers(handle,
-			mapping, inode->i_size, page_len, 0);
-
-		if (err)
-			goto out_stop;
-	}
+	if (inode->i_size & (sb->s_blocksize - 1))
+		ext4_block_truncate_page(handle, mapping, inode->i_size);
 
 	if (ext4_orphan_add(handle, inode))
 		goto out_stop;
diff --git a/fs/ext4/indirect.c b/fs/ext4/indirect.c
index 830e1b2..a082b30 100644
--- a/fs/ext4/indirect.c
+++ b/fs/ext4/indirect.c
@@ -1349,9 +1349,7 @@ void ext4_ind_truncate(struct inode *inode)
 	__le32 nr = 0;
 	int n = 0;
 	ext4_lblk_t last_block, max_block;
-	loff_t page_len;
 	unsigned blocksize = inode->i_sb->s_blocksize;
-	int err;
 
 	handle = start_transaction(inode);
 	if (IS_ERR(handle))
@@ -1362,16 +1360,9 @@ void ext4_ind_truncate(struct inode *inode)
 	max_block = (EXT4_SB(inode->i_sb)->s_bitmap_maxbytes + blocksize-1)
 					>> EXT4_BLOCK_SIZE_BITS(inode->i_sb);
 
-	if (inode->i_size % PAGE_CACHE_SIZE != 0) {
-		page_len = PAGE_CACHE_SIZE -
-			(inode->i_size & (PAGE_CACHE_SIZE - 1));
-
-		err = ext4_discard_partial_page_buffers(handle,
-			mapping, inode->i_size, page_len, 0);
-
-		if (err)
+	if (inode->i_size & (blocksize - 1))
+		if (ext4_block_truncate_page(handle, mapping, inode->i_size))
 			goto out_stop;
-	}
 
 	if (last_block != max_block) {
 		n = ext4_block_to_path(inode, last_block, offsets, NULL);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
