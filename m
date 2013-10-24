Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 81D656B00E9
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:42 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so2347113pdj.28
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:42 -0700 (PDT)
Received: from psmtp.com ([74.125.245.135])
        by mx.google.com with SMTP id gj2si1738358pac.341.2013.10.24.05.05.40
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:41 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 11/15] super: make icache, dcache shrinkers memcg-aware
Date: Thu, 24 Oct 2013 16:05:02 +0400
Message-ID: <5bd0e963d78e3caf17e5b7861e09c3010b5d19fa.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
References: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Using the per-memcg LRU infrastructure introduced by previous patches,
this patch makes dcache and icache shrinkers memcg-aware. To achieve
that, it converts s_dentry_lru and s_inode_lru from list_lru to
memcg_list_lru and restricts the reclaim to per-memcg parts of the lists
in case of memcg pressure.

Other FS objects are currently ignored and only reclaimed on global
pressure, because their shrinkers are heavily FS-specific and can't be
converted to be memcg-aware so easily. However, we can pass on target
memcg to the FS layer and let it decide if per-memcg objects should be
reclaimed.

Note that with this patch applied we lose global LRU order, but it does
not appear to be a critical drawback, because global pressure should try
to balance the amount reclaimed from all memcgs. On the other hand,
preserving global LRU order would require an extra list_head added to
each dentry and inode, which seems to be too costly.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 fs/dcache.c        |   25 +++++++++++++++----------
 fs/inode.c         |   16 ++++++++++------
 fs/internal.h      |    9 +++++----
 fs/super.c         |   47 +++++++++++++++++++++++++++++------------------
 include/linux/fs.h |    4 ++--
 5 files changed, 61 insertions(+), 40 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 4100030..c128dee 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -373,18 +373,24 @@ static void dentry_unlink_inode(struct dentry * dentry)
 #define D_FLAG_VERIFY(dentry,x) WARN_ON_ONCE(((dentry)->d_flags & (DCACHE_LRU_LIST | DCACHE_SHRINK_LIST)) != (x))
 static void d_lru_add(struct dentry *dentry)
 {
+	struct list_lru *lru =
+		mem_cgroup_kmem_list_lru(&dentry->d_sb->s_dentry_lru, dentry);
+
 	D_FLAG_VERIFY(dentry, 0);
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
-	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
+	WARN_ON_ONCE(!list_lru_add(lru, &dentry->d_lru));
 }
 
 static void d_lru_del(struct dentry *dentry)
 {
+	struct list_lru *lru =
+		mem_cgroup_kmem_list_lru(&dentry->d_sb->s_dentry_lru, dentry);
+
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
-	WARN_ON_ONCE(!list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
+	WARN_ON_ONCE(!list_lru_del(lru, &dentry->d_lru));
 }
 
 static void d_shrink_del(struct dentry *dentry)
@@ -1006,9 +1012,9 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 }
 
 /**
- * prune_dcache_sb - shrink the dcache
- * @sb: superblock
- * @nr_to_scan : number of entries to try to free
+ * prune_dcache_lru - shrink the dcache
+ * @lru: dentry lru list
+ * @nr_to_scan: number of entries to try to free
  * @nid: which node to scan for freeable entities
  *
  * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
@@ -1018,14 +1024,13 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * This function may fail to free any resources if all the dentries are in
  * use.
  */
-long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-		     int nid)
+long prune_dcache_lru(struct list_lru *lru, unsigned long nr_to_scan, int nid)
 {
 	LIST_HEAD(dispose);
 	long freed;
 
-	freed = list_lru_walk_node(&sb->s_dentry_lru, nid, dentry_lru_isolate,
-				       &dispose, &nr_to_scan);
+	freed = list_lru_walk_node(lru, nid, dentry_lru_isolate,
+				   &dispose, &nr_to_scan);
 	shrink_dentry_list(&dispose);
 	return freed;
 }
@@ -1065,7 +1070,7 @@ void shrink_dcache_sb(struct super_block *sb)
 	do {
 		LIST_HEAD(dispose);
 
-		freed = list_lru_walk(&sb->s_dentry_lru,
+		freed = memcg_list_lru_walk_all(&sb->s_dentry_lru,
 			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
 
 		this_cpu_sub(nr_dentry_unused, freed);
diff --git a/fs/inode.c b/fs/inode.c
index b33ba8e..f2f29fa 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -402,7 +402,10 @@ EXPORT_SYMBOL(ihold);
 
 static void inode_lru_list_add(struct inode *inode)
 {
-	if (list_lru_add(&inode->i_sb->s_inode_lru, &inode->i_lru))
+	struct list_lru *lru =
+		mem_cgroup_kmem_list_lru(&inode->i_sb->s_inode_lru, inode);
+
+	if (list_lru_add(lru, &inode->i_lru))
 		this_cpu_inc(nr_unused);
 }
 
@@ -421,8 +424,10 @@ void inode_add_lru(struct inode *inode)
 
 static void inode_lru_list_del(struct inode *inode)
 {
+	struct list_lru *lru =
+		mem_cgroup_kmem_list_lru(&inode->i_sb->s_inode_lru, inode);
 
-	if (list_lru_del(&inode->i_sb->s_inode_lru, &inode->i_lru))
+	if (list_lru_del(lru, &inode->i_lru))
 		this_cpu_dec(nr_unused);
 }
 
@@ -748,14 +753,13 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * to trim from the LRU. Inodes to be freed are moved to a temporary list and
  * then are freed outside inode_lock by dispose_list().
  */
-long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-		     int nid)
+long prune_icache_lru(struct list_lru *lru, unsigned long nr_to_scan, int nid)
 {
 	LIST_HEAD(freeable);
 	long freed;
 
-	freed = list_lru_walk_node(&sb->s_inode_lru, nid, inode_lru_isolate,
-				       &freeable, &nr_to_scan);
+	freed = list_lru_walk_node(lru, nid, inode_lru_isolate,
+				   &freeable, &nr_to_scan);
 	dispose_list(&freeable);
 	return freed;
 }
diff --git a/fs/internal.h b/fs/internal.h
index 513e0d8..3c99eda 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -16,6 +16,7 @@ struct file_system_type;
 struct linux_binprm;
 struct path;
 struct mount;
+struct list_lru;
 
 /*
  * block_dev.c
@@ -114,8 +115,8 @@ extern int open_check_o_direct(struct file *f);
  * inode.c
  */
 extern spinlock_t inode_sb_list_lock;
-extern long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+extern long prune_icache_lru(struct list_lru *lru,
+			     unsigned long nr_to_scan, int nid);
 extern void inode_add_lru(struct inode *inode);
 
 /*
@@ -132,8 +133,8 @@ extern int invalidate_inodes(struct super_block *, bool);
  */
 extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
 extern int d_set_mounted(struct dentry *dentry);
-extern long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
-			    int nid);
+extern long prune_dcache_lru(struct list_lru *lru,
+			     unsigned long nr_to_scan, int nid);
 
 /*
  * read_write.c
diff --git a/fs/super.c b/fs/super.c
index 0225c20..c551684 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -57,6 +57,9 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 				      struct shrink_control *sc)
 {
 	struct super_block *sb;
+	struct mem_cgroup *memcg;
+	struct list_lru *inode_lru;
+	struct list_lru *dentry_lru;
 	long	fs_objects = 0;
 	long	total_objects;
 	long	freed = 0;
@@ -64,6 +67,7 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	long	inodes;
 
 	sb = container_of(shrink, struct super_block, s_shrink);
+	memcg = sc->target_mem_cgroup;
 
 	/*
 	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
@@ -75,11 +79,14 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	if (!grab_super_passive(sb))
 		return SHRINK_STOP;
 
-	if (sb->s_op->nr_cached_objects)
+	if (sb->s_op->nr_cached_objects && !memcg)
 		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
 
-	inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
-	dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
+	inode_lru = mem_cgroup_list_lru(&sb->s_inode_lru, memcg);
+	dentry_lru = mem_cgroup_list_lru(&sb->s_dentry_lru, memcg);
+
+	inodes = list_lru_count_node(inode_lru, sc->nid);
+	dentries = list_lru_count_node(dentry_lru, sc->nid);
 	total_objects = dentries + inodes + fs_objects + 1;
 
 	/* proportion the scan between the caches */
@@ -90,8 +97,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
 	 * prune the dcache first as the icache is pinned by it, then
 	 * prune the icache, followed by the filesystem specific caches
 	 */
-	freed = prune_dcache_sb(sb, dentries, sc->nid);
-	freed += prune_icache_sb(sb, inodes, sc->nid);
+	freed = prune_dcache_lru(dentry_lru, dentries, sc->nid);
+	freed += prune_icache_lru(inode_lru, inodes, sc->nid);
 
 	if (fs_objects) {
 		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
@@ -108,21 +115,25 @@ static unsigned long super_cache_count(struct shrinker *shrink,
 				       struct shrink_control *sc)
 {
 	struct super_block *sb;
+	struct mem_cgroup *memcg;
+	struct list_lru *inode_lru;
+	struct list_lru *dentry_lru;
 	long	total_objects = 0;
 
 	sb = container_of(shrink, struct super_block, s_shrink);
+	memcg = sc->target_mem_cgroup;
 
 	if (!grab_super_passive(sb))
 		return 0;
 
-	if (sb->s_op && sb->s_op->nr_cached_objects)
-		total_objects = sb->s_op->nr_cached_objects(sb,
-						 sc->nid);
+	if (sb->s_op && sb->s_op->nr_cached_objects && !memcg)
+		total_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
+
+	inode_lru = mem_cgroup_list_lru(&sb->s_inode_lru, memcg);
+	dentry_lru = mem_cgroup_list_lru(&sb->s_dentry_lru, memcg);
 
-	total_objects += list_lru_count_node(&sb->s_dentry_lru,
-						 sc->nid);
-	total_objects += list_lru_count_node(&sb->s_inode_lru,
-						 sc->nid);
+	total_objects += list_lru_count_node(dentry_lru, sc->nid);
+	total_objects += list_lru_count_node(inode_lru, sc->nid);
 
 	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
@@ -196,9 +207,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
 
-		if (list_lru_init(&s->s_dentry_lru))
+		if (memcg_list_lru_init(&s->s_dentry_lru))
 			goto err_out;
-		if (list_lru_init(&s->s_inode_lru))
+		if (memcg_list_lru_init(&s->s_inode_lru))
 			goto err_out_dentry_lru;
 
 		INIT_LIST_HEAD(&s->s_mounts);
@@ -236,13 +247,13 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		s->s_shrink.scan_objects = super_cache_scan;
 		s->s_shrink.count_objects = super_cache_count;
 		s->s_shrink.batch = 1024;
-		s->s_shrink.flags = SHRINKER_NUMA_AWARE;
+		s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
 	}
 out:
 	return s;
 
 err_out_dentry_lru:
-	list_lru_destroy(&s->s_dentry_lru);
+	memcg_list_lru_destroy(&s->s_dentry_lru);
 err_out:
 	security_sb_free(s);
 #ifdef CONFIG_SMP
@@ -264,8 +275,8 @@ out_free_sb:
  */
 static inline void destroy_super(struct super_block *s)
 {
-	list_lru_destroy(&s->s_dentry_lru);
-	list_lru_destroy(&s->s_inode_lru);
+	memcg_list_lru_destroy(&s->s_dentry_lru);
+	memcg_list_lru_destroy(&s->s_inode_lru);
 #ifdef CONFIG_SMP
 	free_percpu(s->s_files);
 #endif
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547..f007a37 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1328,8 +1328,8 @@ struct super_block {
 	 * Keep the lru lists last in the structure so they always sit on their
 	 * own individual cachelines.
 	 */
-	struct list_lru		s_dentry_lru ____cacheline_aligned_in_smp;
-	struct list_lru		s_inode_lru ____cacheline_aligned_in_smp;
+	struct memcg_list_lru s_dentry_lru ____cacheline_aligned_in_smp;
+	struct memcg_list_lru s_inode_lru ____cacheline_aligned_in_smp;
 };
 
 extern struct timespec current_fs_time(struct super_block *sb);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
