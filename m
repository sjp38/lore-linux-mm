From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/8] vfs: fix too big f_pos handling
Date: Wed, 13 Jan 2010 21:53:06 +0800
Message-ID: <20100113135957.242612284@intel.com>
References: <20100113135305.013124116@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 35F586B0082
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:00:38 -0500 (EST)
Content-Disposition: inline; filename=f_pos-fix
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, rw_verify_area() checsk f_pos is negative or not. And if
negative, returns -EINVAL.

But, some special files as /dev/(k)mem and /proc/<pid>/mem etc..
has negative offsets. And we can't do any access via read/write
to the file(device).

This patch introduce a flag S_VERYBIG and allow negative file
offsets.

Changelog: v4->v5
 - clean up patches dor /dev/mem.
 - rebased onto 2.6.32-rc1

Changelog: v3->v4
 - make changes in mem.c aligned.
 - change __negative_fpos_check() to return int. 
 - fixed bug in "pos" check.
 - added comments.

Changelog: v2->v3
 - fixed bug in rw_verify_area (it cannot be compiled)

CC: Heiko Carstens <heiko.carstens@de.ibm.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 drivers/char/mem.c |    4 ++++
 fs/proc/base.c     |    2 ++
 fs/read_write.c    |   22 ++++++++++++++++++++--
 include/linux/fs.h |    2 ++
 4 files changed, 28 insertions(+), 2 deletions(-)

--- linux-mm.orig/fs/read_write.c	2010-01-13 21:23:04.000000000 +0800
+++ linux-mm/fs/read_write.c	2010-01-13 21:23:52.000000000 +0800
@@ -205,6 +205,21 @@ bad:
 }
 #endif
 
+static int
+__negative_fpos_check(struct inode *inode, loff_t pos, size_t count)
+{
+	/*
+	 * pos or pos+count is negative here, check overflow.
+	 * too big "count" will be caught in rw_verify_area().
+	 */
+	if ((pos < 0) && (pos + count < pos))
+		return -EOVERFLOW;
+	/* If !VERYBIG inode, negative pos(pos+count) is not allowed */
+	if (!IS_VERYBIG(inode))
+		return -EINVAL;
+	return 0;
+}
+
 /*
  * rw_verify_area doesn't like huge counts. We limit
  * them to something that fits in "int" so that others
@@ -222,8 +237,11 @@ int rw_verify_area(int read_write, struc
 	if (unlikely((ssize_t) count < 0))
 		return retval;
 	pos = *ppos;
-	if (unlikely((pos < 0) || (loff_t) (pos + count) < 0))
-		return retval;
+	if (unlikely((pos < 0) || (loff_t) (pos + count) < 0)) {
+		retval = __negative_fpos_check(inode, pos, count);
+		if (retval)
+			return retval;
+	}
 
 	if (unlikely(inode->i_flock && mandatory_lock(inode))) {
 		retval = locks_mandatory_area(
--- linux-mm.orig/include/linux/fs.h	2010-01-13 21:23:04.000000000 +0800
+++ linux-mm/include/linux/fs.h	2010-01-13 21:31:02.000000000 +0800
@@ -235,6 +235,7 @@ struct inodes_stat_t {
 #define S_NOCMTIME	128	/* Do not update file c/mtime */
 #define S_SWAPFILE	256	/* Do not truncate: swapon got its bmaps */
 #define S_PRIVATE	512	/* Inode is fs-internal */
+#define S_VERYBIG	1024	/* Inode is huge: treat loff_t as unsigned */
 
 /*
  * Note that nosuid etc flags are inode-specific: setting some file-system
@@ -269,6 +270,7 @@ struct inodes_stat_t {
 #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
 #define IS_SWAPFILE(inode)	((inode)->i_flags & S_SWAPFILE)
 #define IS_PRIVATE(inode)	((inode)->i_flags & S_PRIVATE)
+#define IS_VERYBIG(inode)	((inode)->i_flags & S_VERYBIG)
 
 /* the read-only stuff doesn't really belong here, but any other place is
    probably as bad and I don't want to create yet another include file. */
--- linux-mm.orig/drivers/char/mem.c	2010-01-13 21:23:11.000000000 +0800
+++ linux-mm/drivers/char/mem.c	2010-01-13 21:27:28.000000000 +0800
@@ -861,6 +861,10 @@ static int memory_open(struct inode *ino
 	if (dev->dev_info)
 		filp->f_mapping->backing_dev_info = dev->dev_info;
 
+	/* Is /dev/mem or /dev/kmem ? */
+	if (dev->dev_info == &directly_mappable_cdev_bdi)
+		inode->i_flags |= S_VERYBIG;
+
 	if (dev->fops->open)
 		return dev->fops->open(inode, filp);
 
--- linux-mm.orig/fs/proc/base.c	2010-01-13 21:23:04.000000000 +0800
+++ linux-mm/fs/proc/base.c	2010-01-13 21:27:51.000000000 +0800
@@ -861,6 +861,8 @@ static const struct file_operations proc
 static int mem_open(struct inode* inode, struct file* file)
 {
 	file->private_data = (void*)((long)current->self_exec_id);
+	/* this file is read only and we can catch out-of-range */
+	inode->i_flags |= S_VERYBIG;
 	return 0;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
