Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 52B186B0038
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:31:54 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so9500523pde.23
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 02:31:53 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ef1si17180045pbc.151.2014.07.28.02.31.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 02:31:53 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/6] fs: consolidate {nr,free}_cached_objects args in shrink_control
Date: Mon, 28 Jul 2014 13:31:24 +0400
Message-ID: <a301e8ee3c5a58475517f0131f9e87e8be0db97e.1406536261.git.vdavydov@parallels.com>
In-Reply-To: <cover.1406536261.git.vdavydov@parallels.com>
References: <cover.1406536261.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, david@fromorbit.com, viro@zeniv.linux.org.uk, gthelen@google.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We are going to make FS shrinkers memcg-aware. To achieve that, we will
have to pass the memcg to scan to the nr_cached_objects and
free_cached_objects VFS methods, which currently take only the NUMA node
to scan. Since the shrink_control structure already holds the node, and
the memcg to scan will be added to it when we introduce memcg-aware
vmscan, let us consolidate the methods' arguments in this structure to
keep things clean.

Suggested-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/super.c         |   12 ++++++------
 fs/xfs/xfs_super.c |    7 +++----
 include/linux/fs.h |    6 ++++--
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index b4f5679d0d8c..1f34321e15b4 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -76,7 +76,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 		return SHRINK_STOP;
 
 	if (sb->s_op->nr_cached_objects)
-		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
+		fs_objects = sb->s_op->nr_cached_objects(sb, sc);
 
 	inodes = list_lru_shrink_count(&sb->s_inode_lru, sc);
 	dentries = list_lru_shrink_count(&sb->s_dentry_lru, sc);
@@ -96,9 +96,10 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
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
@@ -121,8 +122,7 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 	 * s_op->nr_cached_objects().
 	 */
 	if (sb->s_op && sb->s_op->nr_cached_objects)
-		total_objects = sb->s_op->nr_cached_objects(sb,
-						 sc->nid);
+		total_objects = sb->s_op->nr_cached_objects(sb, sc);
 
 	total_objects += list_lru_shrink_count(&sb->s_dentry_lru, sc);
 	total_objects += list_lru_shrink_count(&sb->s_inode_lru, sc);
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 986c5577c4e9..0df5f4d7150f 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1521,7 +1521,7 @@ xfs_fs_mount(
 static long
 xfs_fs_nr_cached_objects(
 	struct super_block	*sb,
-	int			nid)
+	struct shrink_control	*sc)
 {
 	return xfs_reclaim_inodes_count(XFS_M(sb));
 }
@@ -1529,10 +1529,9 @@ xfs_fs_nr_cached_objects(
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
index 26b4970e9fb8..6193236aca16 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1563,8 +1563,10 @@ struct super_operations {
 			       loff_t);
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
