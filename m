Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B03486B006E
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:53:41 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so11070891pab.6
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:53:41 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xb8si8074418pab.52.2015.01.08.02.53.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 02:53:38 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 2/9] fs: consolidate {nr,free}_cached_objects args in shrink_control
Date: Thu, 8 Jan 2015 13:53:12 +0300
Message-ID: <093a0800022449ebc7caf8f6125725174d126597.1420711973.git.vdavydov@parallels.com>
In-Reply-To: <cover.1420711973.git.vdavydov@parallels.com>
References: <cover.1420711973.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We are going to make FS shrinkers memcg-aware. To achieve that, we will
have to pass the memcg to scan to the nr_cached_objects and
free_cached_objects VFS methods, which currently take only the NUMA node
to scan. Since the shrink_control structure already holds the node, and
the memcg to scan will be added to it when we introduce memcg-aware
vmscan, let us consolidate the methods' arguments in this structure to
keep things clean.

Suggested-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/super.c         |   12 ++++++------
 fs/xfs/xfs_super.c |    7 +++----
 include/linux/fs.h |    6 ++++--
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index 4554ac257647..a2b735a42e74 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -75,7 +75,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 		return SHRINK_STOP;
 
 	if (sb->s_op->nr_cached_objects)
-		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
+		fs_objects = sb->s_op->nr_cached_objects(sb, sc);
 
 	inodes = list_lru_shrink_count(&sb->s_inode_lru, sc);
 	dentries = list_lru_shrink_count(&sb->s_dentry_lru, sc);
@@ -97,9 +97,10 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	sc->nr_to_scan = inodes;
 	freed += prune_icache_sb(sb, sc);
 
-	if (fs_objects)
-		freed += sb->s_op->free_cached_objects(sb, fs_objects,
-						       sc->nid);
+	if (fs_objects) {
+		sc->nr_to_scan = fs_objects;
+		freed += sb->s_op->free_cached_objects(sb, sc);
+	}
 
 	drop_super(sb);
 	return freed;
@@ -122,8 +123,7 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 	 * s_op->nr_cached_objects().
 	 */
 	if (sb->s_op && sb->s_op->nr_cached_objects)
-		total_objects = sb->s_op->nr_cached_objects(sb,
-						 sc->nid);
+		total_objects = sb->s_op->nr_cached_objects(sb, sc);
 
 	total_objects += list_lru_shrink_count(&sb->s_dentry_lru, sc);
 	total_objects += list_lru_shrink_count(&sb->s_inode_lru, sc);
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 22e6acaa0320..0008e756e289 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1531,7 +1531,7 @@ xfs_fs_mount(
 static long
 xfs_fs_nr_cached_objects(
 	struct super_block	*sb,
-	int			nid)
+	struct shrink_control	*sc)
 {
 	return xfs_reclaim_inodes_count(XFS_M(sb));
 }
@@ -1539,10 +1539,9 @@ xfs_fs_nr_cached_objects(
 static long
 xfs_fs_free_cached_objects(
 	struct super_block	*sb,
-	long			nr_to_scan,
-	int			nid)
+	struct shrink_control	*sc)
 {
-	return xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
+	return xfs_reclaim_inodes_nr(XFS_M(sb), sc->nr_to_scan);
 }
 
 static const struct super_operations xfs_super_operations = {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 60acab209701..4cd648f51f63 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1616,8 +1616,10 @@ struct super_operations {
 	struct dquot **(*get_dquots)(struct inode *);
 #endif
 	int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
-	long (*nr_cached_objects)(struct super_block *, int);
-	long (*free_cached_objects)(struct super_block *, long, int);
+	long (*nr_cached_objects)(struct super_block *,
+				  struct shrink_control *);
+	long (*free_cached_objects)(struct super_block *,
+				    struct shrink_control *);
 };
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
