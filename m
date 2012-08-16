Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 79E946B0070
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 16:54:11 -0400 (EDT)
Received: by weyx56 with SMTP id x56so145165wey.2
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 13:54:09 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [RFC PATCH 4/6] memcg: shrink dcache with memcg context
Date: Thu, 16 Aug 2012 13:54:08 -0700
Message-Id: <1345150448-31073-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org

After the kernel slab accounting, all the slab objects will be *charged* to
individual memcg including root. Today, there is no way to apply pressure to
those slabs besides scanning the global dcache lru list. The latter one
breaks the isolation badly where pressure from A could causes pages being
throwed out from B. After this patch, the per-memcg pressure will only be
applied to the slab objects being charged to it.

The patch handles vfs slab objects which is dentry cache to be more specific.
Given the nature of dcache pins inode, we think it is sufficient to only handle
dcache for now.

Each superblock now has a hashtable of LRUs which is indexed by the memcg
pointer. The hash_mem_cgroup() computes a hash code for per-superblock hash
table of dentries. Under target reclaim, the code walks the memcgs under the
hierarchy and looks through the hash table bucket indexed by the memcg only.
Under global reclaim, no hierarchy walk is performed and instead all the
hashtable buckets are scanned starting from idx=0.

Each dentry has a new field dentry->d_memcg which stores the hashtable key. The
field also records the memcg owner of the kmem_cache by the time the dentry is
added in the hashtable. The same key is used when the dcache is removed from
the hashtable. However, there is a race where the kmem_cache owner changes
while the dentry is off-lru in prune_dcache_sb(). The check is performed when
the dentry is re-inserted next time and the new owner field as well the
counters are readjusted (see dcache_put_back_ru()).

Use CONFIG_MEMCG_KMEM to enable the feature due to the dependency on kernel
slab accounting which shares the same config. If slab accounting is not enabled
(non-memcg kernel), all the unused dentries are linked on the idx=0 bucket in
the hashtable. That works as the global lru list as today. The function which
depending the slab accounting API is commented out for now.

Note:
1. I noticed the "generic hashtable implementation" patchset in lkml but not
reading into it. Maybe changes in the patch are needed after that, but should
be minor.

2. There is a known issue where the hashtable could introduce memcg collisions
in dentry LRUs. So the current implementation is a compromise between the
performance and the code complication. However we haven't noticed performance
hit in the production enviroment with this patch yet.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 fs/dcache.c              |  185 ++++++++++++++++++++++++++++++++++++++++++----
 fs/super.c               |   28 ++++++--
 include/linux/dcache.h   |    4 +
 include/linux/fs.h       |   31 +++++++-
 include/linux/slab_def.h |    5 +
 mm/slab.c                |    8 ++
 6 files changed, 237 insertions(+), 24 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 4046904..278b4e5 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -104,6 +104,21 @@ static unsigned int d_hash_shift __read_mostly;
 
 static struct hlist_bl_head *dentry_hashtable __read_mostly;
 
+#ifdef CONFIG_MEMCG_KMEM
+static int hash_mem_cgroup(struct mem_cgroup *mem)
+{
+	/*
+	 * In the event of global slab reclaim, scan all buckets starting from
+	 * the first index. Fix this in a future version by RR the starting
+	 * bucket to avoid biasing one cgroup over others.
+	 */
+	if (!mem)
+		return 0;
+
+	return hash_32((unsigned long)mem, DENTRY_LRU_HASH_BITS);
+}
+#endif
+
 static inline struct hlist_bl_head *d_hash(const struct dentry *parent,
 					unsigned int hash)
 {
@@ -218,6 +233,9 @@ static void __d_free(struct rcu_head *head)
 {
 	struct dentry *dentry = container_of(head, struct dentry, d_u.d_rcu);
 
+#ifdef CONFIG_MEMCG_KMEM
+	BUG_ON(dentry->d_memcg != NULL);
+#endif
 	WARN_ON(!list_empty(&dentry->d_alias));
 	if (dname_external(dentry))
 		kfree(dentry->d_name.name);
@@ -303,15 +321,34 @@ static void dentry_unlink_inode(struct dentry * dentry)
 		iput(inode);
 }
 
+static int dentry_lru_index(struct dentry *dentry)
+{
+#ifdef CONFIG_MEMCG_KMEM
+	return hash_mem_cgroup(dentry->d_memcg);
+#else
+	return 0;
+#endif
+}
+
 /*
  * dentry_lru_(add|del|prune|move_tail) must be called with d_lock held.
  */
 static void dentry_lru_add(struct dentry *dentry)
 {
+	int lru_index;
+
 	if (list_empty(&dentry->d_lru)) {
 		spin_lock(&dcache_lru_lock);
-		list_add(&dentry->d_lru, &dentry->d_sb->s_dentry_lru);
-		dentry->d_sb->s_nr_dentry_unused++;
+#ifdef CONFIG_MEMCG_KMEM
+		BUG_ON(dentry->d_memcg != NULL);
+		dentry->d_memcg = mem_cgroup_from_slab(dentry);
+#endif
+		lru_index = dentry_lru_index(dentry);
+
+		list_add(&dentry->d_lru,
+			&dentry->d_sb->s_dentry_lru[lru_index]);
+		dentry->d_sb->s_nr_dentry_unused[lru_index]++;
+		dentry->d_sb->s_total_nr_dentry_unused++;
 		dentry_stat.nr_unused++;
 		spin_unlock(&dcache_lru_lock);
 	}
@@ -319,10 +356,21 @@ static void dentry_lru_add(struct dentry *dentry)
 
 static void __dentry_lru_del(struct dentry *dentry)
 {
+	int lru_index;
+
 	list_del_init(&dentry->d_lru);
 	dentry->d_flags &= ~DCACHE_SHRINK_LIST;
-	dentry->d_sb->s_nr_dentry_unused--;
+
+	lru_index = dentry_lru_index(dentry);
+
+	BUG_ON(dentry->d_sb->s_nr_dentry_unused[lru_index] == 0);
+	dentry->d_sb->s_nr_dentry_unused[lru_index]--;
+	BUG_ON(dentry->d_sb->s_total_nr_dentry_unused == 0);
+	dentry->d_sb->s_total_nr_dentry_unused--;
 	dentry_stat.nr_unused--;
+#ifdef CONFIG_MEMCG_KMEM
+	dentry->d_memcg = NULL;
+#endif
 }
 
 /*
@@ -356,10 +404,16 @@ static void dentry_lru_prune(struct dentry *dentry)
 
 static void dentry_lru_move_list(struct dentry *dentry, struct list_head *list)
 {
+	int lru_index;
+
 	spin_lock(&dcache_lru_lock);
 	if (list_empty(&dentry->d_lru)) {
 		list_add_tail(&dentry->d_lru, list);
-		dentry->d_sb->s_nr_dentry_unused++;
+
+		lru_index = dentry_lru_index(dentry);
+
+		dentry->d_sb->s_nr_dentry_unused[lru_index]++;
+		dentry->d_sb->s_total_nr_dentry_unused++;
 		dentry_stat.nr_unused++;
 	} else {
 		list_move_tail(&dentry->d_lru, list);
@@ -847,6 +901,66 @@ static void shrink_dentry_list(struct list_head *list)
 	rcu_read_unlock();
 }
 
+/*
+ * dcache_put_back_lru - return LRU dentries to respective per-superblock
+ * per-hash bucket lists.  Caller must hold dcache_lock.
+ */
+static void dcache_put_back_lru(struct super_block *sb, struct list_head *lst)
+{
+	struct dentry *dentry;
+#ifdef CONFIG_MEMCG_KMEM
+	struct mem_cgroup *memcg;
+#endif
+
+	while (!list_empty(lst)) {
+		dentry = list_entry(lst->prev, struct dentry, d_lru);
+
+#ifdef CONFIG_MEMCG_KMEM
+		memcg = mem_cgroup_from_slab(dentry);
+
+		/*
+		 * dentry was previously removed from the the hash bucket list
+		 * without decrementing the bucket counter.  dentry is now being
+		 * re-inserted into a possibly different hash bucket list.  The
+		 * hash bucket list will be different if the the dentry's slab
+		 * page was reassigned to another memcg after the dentry was
+		 * removed from the bucket list.  If the memcg changed, then
+		 * shift the counters from the old bucket list and memcg to the
+		 * new ones.
+		 */
+		if (dentry->d_memcg != memcg) {
+			dentry->d_sb->s_nr_dentry_unused[
+				hash_mem_cgroup(dentry->d_memcg)]--;
+
+			dentry->d_memcg = memcg;
+
+			dentry->d_sb->s_nr_dentry_unused[
+				hash_mem_cgroup(dentry->d_memcg)]++;
+		}
+#endif
+
+		list_move(&dentry->d_lru,
+			  &sb->s_dentry_lru[dentry_lru_index(dentry)]);
+	}
+}
+
+#ifdef CONFIG_MEMCG_KMEM
+unsigned long mem_cgroup_dentry_unused_sb(struct mem_cgroup *memcg,
+					  struct super_block *sb)
+{
+	if (memcg) {
+		/*
+		 * Under hash collision, the return value could potentially be
+		 * bigger than the per-sb-per-memcg unused dentry lru_size.
+		 */
+		int index = hash_mem_cgroup(memcg);
+
+		return sb->s_nr_dentry_unused[index];
+	} else
+		return sb->s_total_nr_dentry_unused;
+}
+#endif
+
 /**
  * prune_dcache_sb - shrink the dcache
  * @sb: superblock
@@ -859,16 +973,38 @@ static void shrink_dentry_list(struct list_head *list)
  * This function may fail to free any resources if all the dentries are in
  * use.
  */
-void prune_dcache_sb(struct super_block *sb, int count)
+void prune_dcache_sb(struct super_block *sb, int count,
+		     struct mem_cgroup *memcg)
 {
 	struct dentry *dentry;
 	LIST_HEAD(referenced);
 	LIST_HEAD(tmp);
+	int idx = 0, unused;
+
+#ifdef CONFIG_MEMCG_KMEM
+	idx = hash_mem_cgroup(memcg);
+	if (memcg)
+		unused = sb->s_nr_dentry_unused[idx];
+	else
+		unused = sb->s_total_nr_dentry_unused;
+#else
+	unused = sb->s_total_nr_dentry_unused;
+#endif
+
+	if (unused == 0 || count == 0)
+		return;
 
 relock:
 	spin_lock(&dcache_lru_lock);
-	while (!list_empty(&sb->s_dentry_lru)) {
-		dentry = list_entry(sb->s_dentry_lru.prev,
+
+#ifdef CONFIG_MEMCG_KMEM
+again:
+#endif
+	while (!list_empty(&sb->s_dentry_lru[idx])) {
+#ifdef CONFIG_MEMCG_KMEM
+		struct mem_cgroup *d_memcg;
+#endif
+		dentry = list_entry(sb->s_dentry_lru[idx].prev,
 				struct dentry, d_lru);
 		BUG_ON(dentry->d_sb != sb);
 
@@ -877,11 +1013,19 @@ relock:
 			cpu_relax();
 			goto relock;
 		}
+#ifdef CONFIG_MEMCG_KMEM
+		d_memcg = mem_cgroup_from_slab(dentry);
+#endif
 
 		if (dentry->d_flags & DCACHE_REFERENCED) {
 			dentry->d_flags &= ~DCACHE_REFERENCED;
 			list_move(&dentry->d_lru, &referenced);
 			spin_unlock(&dentry->d_lock);
+#ifdef CONFIG_MEMCG_KMEM
+		} else if (d_memcg && memcg && d_memcg != memcg) {
+			list_move(&dentry->d_lru, &referenced);
+			spin_unlock(&dentry->d_lock);
+#endif
 		} else {
 			list_move_tail(&dentry->d_lru, &tmp);
 			dentry->d_flags |= DCACHE_SHRINK_LIST;
@@ -891,8 +1035,12 @@ relock:
 		}
 		cond_resched_lock(&dcache_lru_lock);
 	}
-	if (!list_empty(&referenced))
-		list_splice(&referenced, &sb->s_dentry_lru);
+
+#ifdef CONFIG_MEMCG_KMEM
+	if (!memcg && ++idx < DENTRY_LRU_HASH_SIZE)
+		goto again;
+#endif
+	dcache_put_back_lru(sb, &referenced);
 	spin_unlock(&dcache_lru_lock);
 
 	shrink_dentry_list(&tmp);
@@ -908,15 +1056,19 @@ relock:
 void shrink_dcache_sb(struct super_block *sb)
 {
 	LIST_HEAD(tmp);
+	int idx;
 
+restart:
 	spin_lock(&dcache_lru_lock);
-	while (!list_empty(&sb->s_dentry_lru)) {
-		list_splice_init(&sb->s_dentry_lru, &tmp);
-		spin_unlock(&dcache_lru_lock);
-		shrink_dentry_list(&tmp);
-		spin_lock(&dcache_lru_lock);
-	}
+	for (idx = 0; idx < DENTRY_LRU_HASH_SIZE; idx++)
+		list_splice_init(&sb->s_dentry_lru[idx], &tmp);
+
 	spin_unlock(&dcache_lru_lock);
+
+	shrink_dentry_list(&tmp);
+
+	if (sb->s_total_nr_dentry_unused != 0)
+		goto restart;
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
@@ -1309,6 +1461,9 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	dentry->d_sb = sb;
 	dentry->d_op = NULL;
 	dentry->d_fsdata = NULL;
+#ifdef CONFIG_MEMCG_KMEM
+	dentry->d_memcg = NULL;
+#endif
 	INIT_HLIST_BL_NODE(&dentry->d_hash);
 	INIT_LIST_HEAD(&dentry->d_lru);
 	INIT_LIST_HEAD(&dentry->d_subdirs);
diff --git a/fs/super.c b/fs/super.c
index 21817c0..3d72314 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -51,6 +51,8 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 	struct super_block *sb;
 	int	fs_objects = 0;
 	int	total_objects;
+	int	dentry_objects;
+	struct mem_cgroup *memcg = sc->mem_cgroup;
 
 	sb = container_of(shrink, struct super_block, s_shrink);
 
@@ -67,7 +69,12 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		fs_objects = sb->s_op->nr_cached_objects(sb);
 
-	total_objects = sb->s_nr_dentry_unused +
+#ifdef CONFIG_MEMCG_KMEM
+	dentry_objects = mem_cgroup_dentry_unused_sb(memcg, sb);
+#else
+	dentry_objects = sb->s_total_nr_dentry_unused;
+#endif
+	total_objects = dentry_objects +
 			sb->s_nr_inodes_unused + fs_objects + 1;
 
 	if (sc->nr_to_scan) {
@@ -75,25 +82,32 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 		int	inodes;
 
 		/* proportion the scan between the caches */
-		dentries = (sc->nr_to_scan * sb->s_nr_dentry_unused) /
-							total_objects;
+		dentries = (sc->nr_to_scan * dentry_objects) / total_objects;
+
 		inodes = (sc->nr_to_scan * sb->s_nr_inodes_unused) /
 							total_objects;
 		if (fs_objects)
 			fs_objects = (sc->nr_to_scan * fs_objects) /
 							total_objects;
+
 		/*
 		 * prune the dcache first as the icache is pinned by it, then
 		 * prune the icache, followed by the filesystem specific caches
 		 */
-		prune_dcache_sb(sb, dentries);
+		prune_dcache_sb(sb, dentries, memcg);
 		prune_icache_sb(sb, inodes, sc->priority);
 
 		if (fs_objects && sb->s_op->free_cached_objects) {
 			sb->s_op->free_cached_objects(sb, fs_objects);
 			fs_objects = sb->s_op->nr_cached_objects(sb);
 		}
-		total_objects = sb->s_nr_dentry_unused +
+
+#ifdef CONFIG_MEMCG_KMEM
+		dentry_objects = mem_cgroup_dentry_unused_sb(memcg, sb);
+#else
+		dentry_objects = sb->s_total_nr_dentry_unused;
+#endif
+		total_objects = dentry_objects +
 				sb->s_nr_inodes_unused + fs_objects;
 	}
 
@@ -113,6 +127,7 @@ static struct super_block *alloc_super(struct file_system_type *type)
 {
 	struct super_block *s = kzalloc(sizeof(struct super_block),  GFP_USER);
 	static const struct super_operations default_op;
+	int i;
 
 	if (s) {
 		if (security_sb_alloc(s)) {
@@ -140,7 +155,8 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		INIT_HLIST_NODE(&s->s_instances);
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
-		INIT_LIST_HEAD(&s->s_dentry_lru);
+		for (i = 0; i < MAX_DENTRY_LRU; i++)
+			INIT_LIST_HEAD(&s->s_dentry_lru[i]);
 		INIT_LIST_HEAD(&s->s_inode_lru);
 		spin_lock_init(&s->s_inode_lru_lock);
 		INIT_LIST_HEAD(&s->s_mounts);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 094789f..624c079 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -120,6 +120,10 @@ struct dentry {
 	void *d_fsdata;			/* fs-specific data */
 
 	struct list_head d_lru;		/* LRU list */
+#ifdef CONFIG_MEMCG_KMEM
+	struct mem_cgroup *d_memcg;	/* identify per memcg lru -
+					   NULL if not on lru */
+#endif
 	/*
 	 * d_child and d_rcu can share memory
 	 */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 667b4f8..8744a7c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1458,6 +1458,14 @@ extern int send_sigurg(struct fown_struct *fown);
 extern struct list_head super_blocks;
 extern spinlock_t sb_lock;
 
+/*
+ * Setup size of hash tables. Use the memcg pointer to hash into the
+ * superblock's dentry hash tables.
+ */
+#define DENTRY_LRU_HASH_BITS	9
+#define DENTRY_LRU_HASH_SIZE	(1 << DENTRY_LRU_HASH_BITS)
+#define MAX_DENTRY_LRU		DENTRY_LRU_HASH_SIZE
+
 struct super_block {
 	struct list_head	s_list;		/* Keep this first */
 	dev_t			s_dev;		/* search index; _not_ kdev_t */
@@ -1490,9 +1498,20 @@ struct super_block {
 	struct list_head	s_files;
 #endif
 	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use */
+
 	/* s_dentry_lru, s_nr_dentry_unused protected by dcache.c lru locks */
-	struct list_head	s_dentry_lru;	/* unused dentry lru */
-	int			s_nr_dentry_unused;	/* # of dentry on lru */
+	/*
+	 * unused dentry lru
+	 */
+	struct list_head	s_dentry_lru[MAX_DENTRY_LRU];
+	/*
+	 * # of dentry on lru
+	 */
+	int			s_nr_dentry_unused[MAX_DENTRY_LRU];
+	/*
+	 * total # of unused dentry
+	 */
+	int			s_total_nr_dentry_unused;
 
 	/* s_inode_lru_lock protects s_inode_lru and s_nr_inodes_unused */
 	spinlock_t		s_inode_lru_lock ____cacheline_aligned_in_smp;
@@ -1555,10 +1574,16 @@ struct super_block {
 /* superblock cache pruning functions */
 extern void prune_icache_sb(struct super_block *sb, int nr_to_scan,
 			    int priority);
-extern void prune_dcache_sb(struct super_block *sb, int nr_to_scan);
+extern void prune_dcache_sb(struct super_block *sb, int nr_to_scan,
+			    struct mem_cgroup *memcg);
 
 extern struct timespec current_fs_time(struct super_block *sb);
 
+#ifdef CONFIG_MEMCG_KMEM
+extern unsigned long mem_cgroup_dentry_unused_sb(struct mem_cgroup *mem,
+						  struct super_block *sb);
+#endif
+
 /*
  * Snapshotting support.
  */
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 0c634fa..dcaa542 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -214,4 +214,9 @@ found:
 
 #endif	/* CONFIG_NUMA */
 
+#ifdef CONFIG_MEMCG_KMEM
+
+struct mem_cgroup *mem_cgroup_from_slab(const void *obj);
+
+#endif /* CONFIG_MEMCG_KMEM */
 #endif	/* _LINUX_SLAB_DEF_H */
diff --git a/mm/slab.c b/mm/slab.c
index f8b0d53..b33ec78 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4564,6 +4564,14 @@ static const struct file_operations proc_slabinfo_operations = {
 	.release	= seq_release,
 };
 
+#ifdef CONFIG_MEMCG_KMEM
+struct mem_cgroup *mem_cgroup_from_slab(const void *obj)
+{
+	//TODO: this needs to be adjusted based on the slab accounting API
+//	return virt_to_cache(obj)->memcg;
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 
 static void *leaks_start(struct seq_file *m, loff_t *pos)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
