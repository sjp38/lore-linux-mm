Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 4B4306B00A8
	for <linux-mm@kvack.org>; Fri, 24 May 2013 06:35:29 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v8 31/34] super: targeted memcg reclaim
Date: Fri, 24 May 2013 15:59:25 +0530
Message-Id: <1369391368-31562-32-git-send-email-glommer@openvz.org>
In-Reply-To: <1369391368-31562-1-git-send-email-glommer@openvz.org>
References: <1369391368-31562-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

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
 fs/super.c    | 39 ++++++++++++++++++++++++++-------------
 4 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index e07aa73..cace5cd 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -889,13 +889,14 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
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
index 00b804e..b9a8125 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -747,13 +747,14 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
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
index 8902d56..601bd15 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -16,6 +16,7 @@ struct file_system_type;
 struct linux_binprm;
 struct path;
 struct mount;
+struct mem_cgroup;
 
 /*
  * block_dev.c
@@ -111,7 +112,7 @@ extern int open_check_o_direct(struct file *f);
  */
 extern spinlock_t inode_sb_list_lock;
 extern long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+			    int nid, struct mem_cgroup *memcg);
 extern void inode_add_lru(struct inode *inode);
 
 /*
@@ -128,7 +129,7 @@ extern int invalidate_inodes(struct super_block *, bool);
  */
 extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
 extern long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+			    int nid, struct mem_cgroup *memcg);
 
 /*
  * read_write.c
diff --git a/fs/super.c b/fs/super.c
index adbbb1a..ff40e33 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -34,6 +34,7 @@
 #include <linux/cleancache.h>
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
+#include <linux/memcontrol.h>
 #include "internal.h"
 
 
@@ -56,6 +57,7 @@ static char *sb_writers_name[SB_FREEZE_LEVELS] = {
 static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct super_block *sb;
+	struct mem_cgroup *memcg = sc->target_mem_cgroup;
 	long	fs_objects = 0;
 	long	total_objects;
 	long	freed = 0;
@@ -74,11 +76,12 @@ static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 	if (!grab_super_passive(sb))
 		return -1;
 
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
@@ -89,8 +92,8 @@ static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 	 * prune the dcache first as the icache is pinned by it, then
 	 * prune the icache, followed by the filesystem specific caches
 	 */
-	freed = prune_dcache_sb(sb, dentries, sc->nid);
-	freed += prune_icache_sb(sb, inodes, sc->nid);
+	freed = prune_dcache_sb(sb, dentries, sc->nid, memcg);
+	freed += prune_icache_sb(sb, inodes, sc->nid, memcg);
 
 	if (fs_objects) {
 		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
@@ -107,20 +110,26 @@ static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc
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
@@ -199,8 +208,10 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		INIT_HLIST_NODE(&s->s_instances);
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
-		list_lru_init(&s->s_dentry_lru);
-		list_lru_init(&s->s_inode_lru);
+
+		list_lru_init_memcg(&s->s_dentry_lru);
+		list_lru_init_memcg(&s->s_inode_lru);
+
 		INIT_LIST_HEAD(&s->s_mounts);
 		init_rwsem(&s->s_umount);
 		lockdep_set_class(&s->s_umount, &type->s_umount_key);
@@ -236,7 +247,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		s->s_shrink.scan_objects = super_cache_scan;
 		s->s_shrink.count_objects = super_cache_count;
 		s->s_shrink.batch = 1024;
-		s->s_shrink.flags = SHRINKER_NUMA_AWARE;
+		s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	}
 out:
 	return s;
@@ -319,6 +330,8 @@ void deactivate_locked_super(struct super_block *s)
 
 		/* caches are now gone, we can safely kill the shrinker now */
 		unregister_shrinker(&s->s_shrink);
+		list_lru_destroy(&s->s_dentry_lru);
+		list_lru_destroy(&s->s_inode_lru);
 		put_filesystem(fs);
 		put_super(s);
 	} else {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
