Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 336756B0006
	for <linux-mm@kvack.org>; Sat, 20 Apr 2013 20:07:23 -0400 (EDT)
From: Theodore Ts'o <tytso@mit.edu>
Subject: [PATCH 1/3] ext4: mark all metadata I/O with REQ_META
Date: Sat, 20 Apr 2013 20:07:06 -0400
Message-Id: <1366502828-7793-1-git-send-email-tytso@mit.edu>
In-Reply-To: <20130421000522.GA5054@thunk.org>
References: <20130421000522.GA5054@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ext4 Developers List <linux-ext4@vger.kernel.org>
Cc: linux-mm@kvack.org, Linux Kernel Developers List <linux-kernel@vger.kernel.org>, mgorman@suse.de, Theodore Ts'o <tytso@mit.edu>

As Dave Chinner pointed out at the 2013 LSF/MM workshop, it's
important that metadata I/O requests are marked as such to avoid
priority inversions caused by I/O bandwidth throttling.

Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
---
 fs/ext4/balloc.c | 2 +-
 fs/ext4/ialloc.c | 2 +-
 fs/ext4/mmp.c    | 4 ++--
 fs/ext4/super.c  | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
index 8dcaea6..d0f13ea 100644
--- a/fs/ext4/balloc.c
+++ b/fs/ext4/balloc.c
@@ -441,7 +441,7 @@ ext4_read_block_bitmap_nowait(struct super_block *sb, ext4_group_t block_group)
 	trace_ext4_read_block_bitmap_load(sb, block_group);
 	bh->b_end_io = ext4_end_bitmap_read;
 	get_bh(bh);
-	submit_bh(READ, bh);
+	submit_bh(READ | REQ_META | REQ_PRIO, bh);
 	return bh;
 verify:
 	ext4_validate_block_bitmap(sb, desc, block_group, bh);
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 18d36d8..00a818d 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -166,7 +166,7 @@ ext4_read_inode_bitmap(struct super_block *sb, ext4_group_t block_group)
 	trace_ext4_load_inode_bitmap(sb, block_group);
 	bh->b_end_io = ext4_end_bitmap_read;
 	get_bh(bh);
-	submit_bh(READ, bh);
+	submit_bh(READ | REQ_META | REQ_PRIO, bh);
 	wait_on_buffer(bh);
 	if (!buffer_uptodate(bh)) {
 		put_bh(bh);
diff --git a/fs/ext4/mmp.c b/fs/ext4/mmp.c
index b3b1f7d..214461e 100644
--- a/fs/ext4/mmp.c
+++ b/fs/ext4/mmp.c
@@ -54,7 +54,7 @@ static int write_mmp_block(struct super_block *sb, struct buffer_head *bh)
 	lock_buffer(bh);
 	bh->b_end_io = end_buffer_write_sync;
 	get_bh(bh);
-	submit_bh(WRITE_SYNC, bh);
+	submit_bh(WRITE_SYNC | REQ_META | REQ_PRIO, bh);
 	wait_on_buffer(bh);
 	sb_end_write(sb);
 	if (unlikely(!buffer_uptodate(bh)))
@@ -86,7 +86,7 @@ static int read_mmp_block(struct super_block *sb, struct buffer_head **bh,
 		get_bh(*bh);
 		lock_buffer(*bh);
 		(*bh)->b_end_io = end_buffer_read_sync;
-		submit_bh(READ_SYNC, *bh);
+		submit_bh(READ_SYNC | REQ_META | REQ_PRIO, *bh);
 		wait_on_buffer(*bh);
 		if (!buffer_uptodate(*bh)) {
 			brelse(*bh);
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index bfa29ec..dbc7c09 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -4252,7 +4252,7 @@ static journal_t *ext4_get_dev_journal(struct super_block *sb,
 		goto out_bdev;
 	}
 	journal->j_private = sb;
-	ll_rw_block(READ, 1, &journal->j_sb_buffer);
+	ll_rw_block(READ | REQ_META | REQ_PRIO, 1, &journal->j_sb_buffer);
 	wait_on_buffer(journal->j_sb_buffer);
 	if (!buffer_uptodate(journal->j_sb_buffer)) {
 		ext4_msg(sb, KERN_ERR, "I/O error on journal device");
-- 
1.7.12.rc0.22.gcdd159b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
