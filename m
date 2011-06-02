Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D656E900001
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:01:48 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: =?UTF-8?q?=5BPATCH=2010/12=5D=20superblock=3A=20add=20filesystem=20shrinker=20operations?=
Date: Thu,  2 Jun 2011 17:01:05 +1000
Message-Id: <1306998067-27659-11-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-1-git-send-email-david@fromorbit.com>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

Now we have a per-superblock shrinker implementation, we can add a
filesystem specific callout to it to allow filesystem internal
caches to be shrunk by the superblock shrinker.

Rather than perpetuate the multipurpose shrinker callback API (i.e.
nr_to_scan == 0 meaning "tell me how many objects freeable in the
cache), two operations will be added. The first will return the
number of objects that are freeable, the second is the actual
shrinker call.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 Documentation/filesystems/vfs.txt |   16 +++++++++++++
 fs/super.c                        |   43 +++++++++++++++++++++++++++---------
 include/linux/fs.h                |    2 +
 3 files changed, 50 insertions(+), 11 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 88b9f55..dc732d2 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -229,6 +229,8 @@ struct super_operations {
 
         ssize_t (*quota_read)(struct super_block *, int, char *, size_t, loff_t);
         ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
+	int (*nr_cached_objects)(struct super_block *);
+	void (*free_cached_objects)(struct super_block *, int);
 };
 
 All methods are called without any locks being held, unless otherwise
@@ -301,6 +303,20 @@ or bottom half).
 
   quota_write: called by the VFS to write to filesystem quota file.
 
+  nr_cached_objects: called by the sb cache shrinking function for the
+	filesystem to return the number of freeable cached objects it contains.
+	Optional.
+
+  free_cache_objects: called by the sb cache shrinking function for the
+	filesystem to scan the number of objects indicated to try to free them.
+	Optional, but any filesystem implementing this method needs to also
+	implement ->nr_cached_objects for it to be called correctly.
+
+	We can't do anything with any errors that the filesystem might
+	encountered, hence the void return type. This will never be called if
+	the VM is trying to reclaim under GFP_NOFS conditions, hence this
+	method does not need to handle that situation itself.
+
 Whoever sets up the inode is responsible for filling in the "i_op" field. This
 is a pointer to a "struct inode_operations" which describes the methods that
 can be performed on individual inodes.
diff --git a/fs/super.c b/fs/super.c
index f4630d9..b55f968 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -41,7 +41,8 @@ DEFINE_SPINLOCK(sb_lock);
 static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct super_block *sb;
-	int count;
+	int	fs_objects = 0;
+	int	total_objects;
 
 	sb = container_of(shrink, struct super_block, s_shrink);
 
@@ -64,22 +65,42 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 		return -1;
 	}
 
-	if (sc->nr_to_scan) {
-		/* proportion the scan between the two cacheN? */
-		int total;
+	if (sb->s_op && sb->s_op->nr_cached_objects)
+		fs_objects = sb->s_op->nr_cached_objects(sb);
+
+	total_objects = sb->s_nr_dentry_unused +
+			sb->s_nr_inodes_unused + fs_objects + 1;
 
-		total = sb->s_nr_dentry_unused + sb->s_nr_inodes_unused + 1;
-		count = (sc->nr_to_scan * sb->s_nr_dentry_unused) / total;
+	if (sc->nr_to_scan) {
+		int	dentries;
+		int	inodes;
+
+		/* proportion the scan between the cacheN? */
+		dentries = (sc->nr_to_scan * sb->s_nr_dentry_unused) /
+							total_objects;
+		inodes = (sc->nr_to_scan * sb->s_nr_inodes_unused) /
+							total_objects;
+		if (fs_objects)
+			fs_objects = (sc->nr_to_scan * fs_objects) /
+							total_objects;
+		/*
+		 * prune the dcache first as the icache is pinned by it, then
+		 * prune the icache, followed by the filesystem specific caches
+		 */
+		prune_dcache_sb(sb, dentries);
+		prune_icache_sb(sb, inodes);
 
-		/* prune dcache first as icache is pinned by it */
-		prune_dcache_sb(sb, count);
-		prune_icache_sb(sb, sc->nr_to_scan - count);
+		if (fs_objects && sb->s_op->free_cached_objects) {
+			sb->s_op->free_cached_objects(sb, fs_objects);
+			fs_objects = sb->s_op->nr_cached_objects(sb);
+		}
+		total_objects = sb->s_nr_dentry_unused +
+				sb->s_nr_inodes_unused + fs_objects;
 	}
 
-	count = ((sb->s_nr_dentry_unused + sb->s_nr_inodes_unused) / 100)
-						* sysctl_vfs_cache_pressure;
+	total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
 	up_read(&sb->s_umount);
-	return count;
+	return total_objects;
 }
 
 /**
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c3b3462..4f0ed0a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1654,6 +1654,8 @@ struct super_operations {
 	ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
 #endif
 	int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
+	int (*nr_cached_objects)(struct super_block *);
+	void (*free_cached_objects)(struct super_block *, int);
 };
 
 /*
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
