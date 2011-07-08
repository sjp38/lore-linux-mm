Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C730890011D
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 00:15:12 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 09/14] superblock: move pin_sb_for_writeback() to fs/super.c
Date: Fri,  8 Jul 2011 14:14:41 +1000
Message-Id: <1310098486-6453-10-git-send-email-david@fromorbit.com>
In-Reply-To: <1310098486-6453-1-git-send-email-david@fromorbit.com>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

The per-sb shrinker has the same requirement as the writeback
threads of ensuring that the superblock is usable and pinned for the
time it takes to run the work. Both need to take a passive reference
to the sb, take a read lock on the s_umount lock and then only
continue if an unmount is not in progress.

pin_sb_for_writeback() does this exactly, so move it to fs/super.c
and rename it to grab_super_passive() and exporting it via
fs/internal.h for all the VFS code to be able to use.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/fs-writeback.c |   28 +---------------------------
 fs/internal.h     |    1 +
 fs/super.c        |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 0f015a0..b8c507c 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -461,32 +461,6 @@ writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 }
 
 /*
- * For background writeback the caller does not have the sb pinned
- * before calling writeback. So make sure that we do pin it, so it doesn't
- * go away while we are writing inodes from it.
- */
-static bool pin_sb_for_writeback(struct super_block *sb)
-{
-	spin_lock(&sb_lock);
-	if (list_empty(&sb->s_instances)) {
-		spin_unlock(&sb_lock);
-		return false;
-	}
-
-	sb->s_count++;
-	spin_unlock(&sb_lock);
-
-	if (down_read_trylock(&sb->s_umount)) {
-		if (sb->s_root)
-			return true;
-		up_read(&sb->s_umount);
-	}
-
-	put_super(sb);
-	return false;
-}
-
-/*
  * Write a portion of b_io inodes which belong to @sb.
  *
  * If @only_this_sb is true, then find and write all such
@@ -585,7 +559,7 @@ void writeback_inodes_wb(struct bdi_writeback *wb,
 		struct inode *inode = wb_inode(wb->b_io.prev);
 		struct super_block *sb = inode->i_sb;
 
-		if (!pin_sb_for_writeback(sb)) {
+		if (!grab_super_passive(sb)) {
 			requeue_io(inode);
 			continue;
 		}
diff --git a/fs/internal.h b/fs/internal.h
index ae47c48..fe327c2 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -97,6 +97,7 @@ extern struct file *get_empty_filp(void);
  * super.c
  */
 extern int do_remount_sb(struct super_block *, int, void *, int);
+extern bool grab_super_passive(struct super_block *sb);
 extern void __put_super(struct super_block *sb);
 extern void put_super(struct super_block *sb);
 extern struct dentry *mount_fs(struct file_system_type *,
diff --git a/fs/super.c b/fs/super.c
index 73ab9f9..e63c754 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -243,6 +243,39 @@ static int grab_super(struct super_block *s) __releases(sb_lock)
 }
 
 /*
+ *	grab_super_passive - acquire a passive reference
+ *	@s: reference we are trying to grab
+ *
+ *	Tries to acquire a passive reference. This is used in places where we
+ *	cannot take an active reference but we need to ensure that the
+ *	superblock does not go away while we are working on it. It returns
+ *	false if a reference was not gained, and returns true with the s_umount
+ *	lock held in read mode if a reference is gained. On successful return,
+ *	the caller must drop the s_umount lock and the passive reference when
+ *	done.
+ */
+bool grab_super_passive(struct super_block *sb)
+{
+	spin_lock(&sb_lock);
+	if (list_empty(&sb->s_instances)) {
+		spin_unlock(&sb_lock);
+		return false;
+	}
+
+	sb->s_count++;
+	spin_unlock(&sb_lock);
+
+	if (down_read_trylock(&sb->s_umount)) {
+		if (sb->s_root)
+			return true;
+		up_read(&sb->s_umount);
+	}
+
+	put_super(sb);
+	return false;
+}
+
+/*
  * Superblock locking.  We really ought to get rid of these two.
  */
 void lock_super(struct super_block * sb)
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
