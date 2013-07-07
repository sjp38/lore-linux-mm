Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 993216B0062
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:30 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ea20so3134673lab.36
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:28 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 12/16] super: targeted memcg reclaim
Date: Sun,  7 Jul 2013 11:56:52 -0400
Message-Id: <1373212616-11713-13-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>

We now have all our dentries and inodes placed in memcg-specific LRU
lists. All we have to do is restrict the reclaim to the said lists in
case of memcg pressure.

That can't be done so easily for the fs_objects part of the equation,
since this is heavily fs-specific. What we do is pass on the context,
and let the filesystems decide if they ever chose or want to. At this
time, we just don't shrink them in memcg pressure (none is supported),
leaving that for global pressure only.

Marking the superblock shrinker and its LRUs as memcg-aware will
guarantee that the shrinkers will get invoked during targetted reclaim.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 fs/dcache.c   |  7 ++++---
 fs/inode.c    |  7 ++++---
 fs/internal.h |  5 +++--
 fs/super.c    | 35 ++++++++++++++++++++++-------------
 4 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 7489b6f..023302e 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -901,13 +901,14 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * use.
  */
 long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-		     int nid)
+		     int nid, struct mem_cgroup *memcg)
 {
 	LIST_HEAD(dispose);
 	long freed;
 
-	freed = list_lru_walk_node(&sb->s_dentry_lru, nid, dentry_lru_isolate,
-				       &dispose, &nr_to_scan);
+	freed = list_lru_walk_node_memcg(&sb->s_dentry_lru, nid,
+					dentry_lru_isolate, &dispose,
+					&nr_to_scan, memcg);
 	shrink_dentry_list(&dispose);
 	return freed;
 }
diff --git a/fs/inode.c b/fs/inode.c
index e315c0a..44d4026 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -749,13 +749,14 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * then are freed outside inode_lock by dispose_list().
  */
 long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-		     int nid)
+		     int nid, struct mem_cgroup *memcg)
 {
 	LIST_HEAD(freeable);
 	long freed;
 
-	freed = list_lru_walk_node(&sb->s_inode_lru, nid, inode_lru_isolate,
-				       &freeable, &nr_to_scan);
+	freed = list_lru_walk_node_memcg(&sb->s_inode_lru, nid,
+					inode_lru_isolate, &freeable,
+					&nr_to_scan, memcg);
 	dispose_list(&freeable);
 	return freed;
 }
diff --git a/fs/internal.h b/fs/internal.h
index 0b0db70..1f3fd0e 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -16,6 +16,7 @@ struct file_system_type;
 struct linux_binprm;
 struct path;
 struct mount;
+struct mem_cgroup;
 
 /*
  * block_dev.c
@@ -112,7 +113,7 @@ extern int open_check_o_direct(struct file *f);
  */
 extern spinlock_t inode_sb_list_lock;
 extern long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+			    int nid, struct mem_cgroup *memcg);
 extern void inode_add_lru(struct inode *inode);
 
 /*
@@ -129,7 +130,7 @@ extern int invalidate_inodes(struct super_block *, bool);
  */
 extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
 extern long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+			    int nid, struct mem_cgroup *memcg);
 
 /*
  * read_write.c
diff --git a/fs/super.c b/fs/super.c
index 09da975..3460a3b 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -34,6 +34,7 @@
 #include <linux/cleancache.h>
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
+#include <linux/memcontrol.h>
 #include "internal.h"
 
 
@@ -57,6 +58,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 				      struct shrink_control *sc)
 {
 	struct super_block *sb;
+	struct mem_cgroup *memcg = sc->target_mem_cgroup;
 	long	fs_objects = 0;
 	long	total_objects;
 	long	freed = 0;
@@ -75,11 +77,12 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	if (!grab_super_passive(sb))
 		return SHRINK_STOP;
 
-	if (sb->s_op && sb->s_op->nr_cached_objects)
+	if (sb->s_op && sb->s_op->nr_cached_objects && !memcg)
 		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
 
-	inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
-	dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
+	inodes = list_lru_count_node_memcg(&sb->s_inode_lru, sc->nid, memcg);
+	dentries = list_lru_count_node_memcg(&sb->s_dentry_lru, sc->nid, memcg);
+
 	total_objects = dentries + inodes + fs_objects + 1;
 
 	/* proportion the scan between the caches */
@@ -90,8 +93,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	 * prune the dcache first as the icache is pinned by it, then
 	 * prune the icache, followed by the filesystem specific caches
 	 */
-	freed = prune_dcache_sb(sb, dentries, sc->nid);
-	freed += prune_icache_sb(sb, inodes, sc->nid);
+	freed = prune_dcache_sb(sb, dentries, sc->nid, memcg);
+	freed += prune_icache_sb(sb, inodes, sc->nid, memcg);
 
 	if (fs_objects) {
 		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
@@ -109,20 +112,26 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 {
 	struct super_block *sb;
 	long	total_objects = 0;
+	struct mem_cgroup *memcg = sc->target_mem_cgroup;
 
 	sb = container_of(shrink, struct super_block, s_shrink);
 
 	if (!grab_super_passive(sb))
 		return 0;
 
-	if (sb->s_op && sb->s_op->nr_cached_objects)
+	/*
+	 * Ideally we would pass memcg to nr_cached_objects, and
+	 * let the underlying filesystem decide. Most likely the
+	 * path will be if (!memcg) return;, but even then.
+	 */
+	if (sb->s_op && sb->s_op->nr_cached_objects && !memcg)
 		total_objects = sb->s_op->nr_cached_objects(sb,
 						 sc->nid);
 
-	total_objects += list_lru_count_node(&sb->s_dentry_lru,
-						 sc->nid);
-	total_objects += list_lru_count_node(&sb->s_inode_lru,
-						 sc->nid);
+	total_objects += list_lru_count_node_memcg(&sb->s_dentry_lru,
+						 sc->nid, memcg);
+	total_objects += list_lru_count_node_memcg(&sb->s_inode_lru,
+						 sc->nid, memcg);
 
 	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
@@ -202,9 +211,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
 
-		if (list_lru_init(&s->s_dentry_lru))
+		if (list_lru_init_memcg(&s->s_dentry_lru))
 			goto err_out;
-		if (list_lru_init(&s->s_inode_lru))
+		if (list_lru_init_memcg(&s->s_inode_lru))
 			goto err_out_dentry_lru;
 
 		INIT_LIST_HEAD(&s->s_mounts);
@@ -242,7 +251,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		s->s_shrink.scan_objects = super_cache_scan;
 		s->s_shrink.count_objects = super_cache_count;
 		s->s_shrink.batch = 1024;
-		s->s_shrink.flags = SHRINKER_NUMA_AWARE;
+		s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	}
 out:
 	return s;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
