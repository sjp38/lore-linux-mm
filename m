Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 985B76B0006
	for <linux-mm@kvack.org>; Sat, 20 Apr 2013 20:07:27 -0400 (EDT)
From: Theodore Ts'o <tytso@mit.edu>
Subject: [PATCH 3/3] ext4: mark metadata blocks using bh flags
Date: Sat, 20 Apr 2013 20:07:08 -0400
Message-Id: <1366502828-7793-3-git-send-email-tytso@mit.edu>
In-Reply-To: <1366502828-7793-1-git-send-email-tytso@mit.edu>
References: <20130421000522.GA5054@thunk.org>
 <1366502828-7793-1-git-send-email-tytso@mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ext4 Developers List <linux-ext4@vger.kernel.org>
Cc: linux-mm@kvack.org, Linux Kernel Developers List <linux-kernel@vger.kernel.org>, mgorman@suse.de, Theodore Ts'o <tytso@mit.edu>

This allows metadata writebacks which are issued via block device
writeback to be sent with the current write request flags.

Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
---
 fs/ext4/ext4_jbd2.c | 2 ++
 fs/ext4/inode.c     | 6 +++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/ext4_jbd2.c b/fs/ext4/ext4_jbd2.c
index 0e1dc9e..fd97b81 100644
--- a/fs/ext4/ext4_jbd2.c
+++ b/fs/ext4/ext4_jbd2.c
@@ -215,6 +215,8 @@ int __ext4_handle_dirty_metadata(const char *where, unsigned int line,
 
 	might_sleep();
 
+	mark_buffer_meta(bh);
+	mark_buffer_prio(bh);
 	if (ext4_handle_valid(handle)) {
 		err = jbd2_journal_dirty_metadata(handle, bh);
 		if (err) {
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 62492e9..d7518e2 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1080,10 +1080,14 @@ retry_journal:
 /* For write_end() in data=journal mode */
 static int write_end_fn(handle_t *handle, struct buffer_head *bh)
 {
+	int ret;
 	if (!buffer_mapped(bh) || buffer_freed(bh))
 		return 0;
 	set_buffer_uptodate(bh);
-	return ext4_handle_dirty_metadata(handle, NULL, bh);
+	ret = ext4_handle_dirty_metadata(handle, NULL, bh);
+	clear_buffer_meta(bh);
+	clear_buffer_prio(bh);
+	return ret;
 }
 
 /*
-- 
1.7.12.rc0.22.gcdd159b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
