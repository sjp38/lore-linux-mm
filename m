Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 125076B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 09:54:47 -0400 (EDT)
From: Cong Wang <amwang@redhat.com>
Subject: [RFC Patch] fs: implement per-file drop caches
Date: Wed, 30 May 2012 21:38:40 +0800
Message-Id: <1338385120-14519-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This is a draft patch of implementing per-file drop caches.

It introduces a new fcntl command  F_DROP_CACHES to drop
file caches of a specific file. The reason is that currently
we only have a system-wide drop caches interface, it could
cause system-wide performance down if we drop all page caches
when we actually want to drop the caches of some huge file.

Below is small test case for this patch:

	#include <unistd.h>
	#include <stdlib.h>
	#include <stdio.h>
	#define __USE_GNU
	#include <fcntl.h>

	int
	main(int argc, char *argv[])
	{
		int fd;
		fd = open(argv[1], O_RDONLY);
		if (fd == -1) {
			perror("open");
			return 1;
		}
		printf("Before readahead:\n");
		system("grep ^Cache /proc/meminfo");
		if (readahead(fd, 0, 1024*1024*100)) {
			perror("open");
			return 1;
		}
		printf("Before drop cache:\n");
		system("grep ^Cache /proc/meminfo");
		fcntl(fd, 1024+9, 3);
		printf("After drop cache:\n");
		system("grep ^Cache /proc/meminfo");
		close(fd);
		return 0;
	}

I used a file of 100M size for testing, and I can see
the cache size of the whole system drops 70000K after
dropping the caches of this big file.

Any comments?

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

---
 fs/dcache.c           |   56 ++++++++++++++++++++++++++++++------------------
 fs/drop_caches.c      |   30 ++++++++++++++++++++++++++
 fs/fcntl.c            |    4 +++
 fs/inode.c            |   37 ++++++++++++++++++++++++++++++++
 include/linux/fcntl.h |    1 +
 include/linux/fs.h    |    2 +
 include/linux/mm.h    |    1 +
 7 files changed, 110 insertions(+), 21 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 4435d8b..5262851 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -585,28 +585,14 @@ kill_it:
 }
 EXPORT_SYMBOL(dput);
 
-/**
- * d_invalidate - invalidate a dentry
- * @dentry: dentry to invalidate
- *
- * Try to invalidate the dentry if it turns out to be
- * possible. If there are other dentries that can be
- * reached through this one we can't delete it and we
- * return -EBUSY. On success we return 0.
- *
- * no dcache lock.
- */
- 
-int d_invalidate(struct dentry * dentry)
+int __d_invalidate(struct dentry * dentry)
 {
 	/*
 	 * If it's already been dropped, return OK.
 	 */
-	spin_lock(&dentry->d_lock);
-	if (d_unhashed(dentry)) {
-		spin_unlock(&dentry->d_lock);
+	if (d_unhashed(dentry))
 		return 0;
-	}
+
 	/*
 	 * Check whether to do a partial shrink_dcache
 	 * to get rid of unused child entries.
@@ -630,16 +616,33 @@ int d_invalidate(struct dentry * dentry)
 	 * directory or not.
 	 */
 	if (dentry->d_count > 1 && dentry->d_inode) {
-		if (S_ISDIR(dentry->d_inode->i_mode) || d_mountpoint(dentry)) {
-			spin_unlock(&dentry->d_lock);
+		if (S_ISDIR(dentry->d_inode->i_mode) || d_mountpoint(dentry))
 			return -EBUSY;
-		}
 	}
 
 	__d_drop(dentry);
-	spin_unlock(&dentry->d_lock);
 	return 0;
 }
+
+/**
+ * d_invalidate - invalidate a dentry
+ * @dentry: dentry to invalidate
+ *
+ * Try to invalidate the dentry if it turns out to be
+ * possible. If there are other dentries that can be
+ * reached through this one we can't delete it and we
+ * return -EBUSY. On success we return 0.
+ *
+ * no dcache lock.
+ */
+int d_invalidate(struct dentry * dentry)
+{
+	int ret;
+	spin_lock(&dentry->d_lock);
+	ret = __d_invalidate(dentry);
+	spin_unlock(&dentry->d_lock);
+	return ret;
+}
 EXPORT_SYMBOL(d_invalidate);
 
 /* This must be called with d_lock held */
@@ -898,6 +901,17 @@ relock:
 	shrink_dentry_list(&tmp);
 }
 
+void prune_dcache_one(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	if (dentry->d_flags & DCACHE_REFERENCED)
+		dentry->d_flags &= ~DCACHE_REFERENCED;
+	dentry_lru_del(dentry);
+	dentry->d_flags |= DCACHE_SHRINK_LIST;
+	__d_invalidate(dentry);
+	spin_unlock(&dentry->d_lock);
+}
+
 /**
  * shrink_dcache_sb - shrink dcache for a superblock
  * @sb: superblock
diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index c00e055..805f150 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -65,3 +65,33 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
 	}
 	return 0;
 }
+
+static void drop_pagecache_file(struct file *filp)
+{
+	struct inode *inode = filp->f_path.dentry->d_inode;
+
+	spin_lock(&inode->i_lock);
+	if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||
+	    (inode->i_mapping->nrpages == 0)) {
+		spin_unlock(&inode->i_lock);
+		return;
+	}
+	__iget(inode);
+	spin_unlock(&inode->i_lock);
+	invalidate_mapping_pages(inode->i_mapping, 0, -1);
+	iput(inode);
+}
+
+
+void file_drop_caches(struct file *filp, unsigned long which)
+{
+	if (which & 1)
+		drop_pagecache_file(filp);
+
+	if (which & 2) {
+		struct dentry *dentry = filp->f_path.dentry;
+
+		prune_dcache_one(dentry);
+		prune_icache_one(dentry->d_inode);
+	}
+}
diff --git a/fs/fcntl.c b/fs/fcntl.c
index d078b75..a97f10a 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -420,6 +420,10 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 	case F_GETPIPE_SZ:
 		err = pipe_fcntl(filp, cmd, arg);
 		break;
+	case F_DROP_CACHES:
+		err = 0;
+		file_drop_caches(filp, arg);
+		break;
 	default:
 		break;
 	}
diff --git a/fs/inode.c b/fs/inode.c
index 6bc8761..a9e92bb 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -776,6 +776,43 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 	dispose_list(&freeable);
 }
 
+void prune_icache_one(struct inode *inode)
+{
+	unsigned long reap = 0;
+
+	/* We are still holding this inode, and we are
+	 * expecting the last iput() will finally
+	 * evict it.
+	 */
+	spin_lock(&inode->i_lock);
+
+	if (inode->i_state & (I_NEW | I_FREEING | I_WILL_FREE)) {
+		spin_unlock(&inode->i_lock);
+		return;
+	}
+
+	if (inode->i_state & I_REFERENCED)
+		inode->i_state &= ~I_REFERENCED;
+
+	inode_lru_list_del(inode);
+
+	if (inode_has_buffers(inode) || inode->i_data.nrpages) {
+		__iget(inode);
+		spin_unlock(&inode->i_lock);
+		if (remove_inode_buffers(inode))
+			reap += invalidate_mapping_pages(&inode->i_data,
+							0, -1);
+		iput(inode);
+	} else
+		spin_unlock(&inode->i_lock);
+
+	if (reap) {
+		__count_vm_events(PGINODESTEAL, reap);
+		if (current->reclaim_state)
+			current->reclaim_state->reclaimed_slab += reap;
+	}
+}
+
 static void __wait_on_freeing_inode(struct inode *inode);
 /*
  * Called with the inode lock held.
diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
index f550f89..6f2b24b 100644
--- a/include/linux/fcntl.h
+++ b/include/linux/fcntl.h
@@ -27,6 +27,7 @@
 #define F_SETPIPE_SZ	(F_LINUX_SPECIFIC_BASE + 7)
 #define F_GETPIPE_SZ	(F_LINUX_SPECIFIC_BASE + 8)
 
+#define F_DROP_CACHES	(F_LINUX_SPECIFIC_BASE + 9)
 /*
  * Types of directory notifications that may be requested.
  */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 038076b..d39e4b9 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1538,6 +1538,8 @@ struct super_block {
 /* superblock cache pruning functions */
 extern void prune_icache_sb(struct super_block *sb, int nr_to_scan);
 extern void prune_dcache_sb(struct super_block *sb, int nr_to_scan);
+extern void prune_icache_one(struct inode *inode);
+extern void prune_dcache_one(struct dentry *dentry);
 
 extern struct timespec current_fs_time(struct super_block *sb);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ce26716..1ad3fc1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1555,6 +1555,7 @@ int in_gate_area_no_mm(unsigned long addr);
 
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+void file_drop_caches(struct file *filp, unsigned long which);
 unsigned long shrink_slab(struct shrink_control *shrink,
 			  unsigned long nr_pages_scanned,
 			  unsigned long lru_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
