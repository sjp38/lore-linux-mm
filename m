Message-ID: <41078A3D.6040103@yahoo.com.au>
Date: Wed, 28 Jul 2004 21:13:01 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [RFC][PATCH 2/2] perzone slab LRUs
References: <410789EB.1060209@yahoo.com.au>
In-Reply-To: <410789EB.1060209@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------080307010200000606030902"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080307010200000606030902
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Oops, forgot to CC linux-mm.

Nick Piggin wrote:
> This patch is only intended for comments.
> 
> This implements (crappy?) infrastructure for per-zone slab LRUs for
> reclaimable slabs, and moves dcache.c over to use that.
> 
> The global unused list is retained to reduce intrusiveness, and another
> per-zone LRU list is added (which are still protected with the global 
> dcache
> lock). This is an attempt to make slab scanning more robust on highmem and
> NUMA systems.
> 
> One concern is that off-zone dentries might be pinning inodes in the zone
> we're trying to free memory for. I wonder if this can be solved?
> 

--------------080307010200000606030902
Content-Type: text/x-patch;
 name="perzone-slab.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="perzone-slab.patch"




---

 linux-2.6-npiggin/fs/dcache.c            |  120 ++++++++++++++++++++------
 linux-2.6-npiggin/include/linux/dcache.h |    1 
 linux-2.6-npiggin/include/linux/mm.h     |   19 ++++
 linux-2.6-npiggin/include/linux/mmzone.h |    4 
 linux-2.6-npiggin/mm/page_alloc.c        |    1 
 linux-2.6-npiggin/mm/vmscan.c            |  139 ++++++++++++++++++++++++-------
 6 files changed, 227 insertions(+), 57 deletions(-)

diff -puN fs/dcache.c~perzone-slab fs/dcache.c
--- linux-2.6/fs/dcache.c~perzone-slab	2004-07-28 20:54:53.000000000 +1000
+++ linux-2.6-npiggin/fs/dcache.c	2004-07-28 20:54:53.000000000 +1000
@@ -60,6 +60,7 @@ static unsigned int d_hash_mask;
 static unsigned int d_hash_shift;
 static struct hlist_head *dentry_hashtable;
 static LIST_HEAD(dentry_unused);
+static int zone_shrinker;
 
 /* Statistics gathering. */
 struct dentry_stat_t dentry_stat = {
@@ -86,6 +87,22 @@ static void d_free(struct dentry *dentry
  	call_rcu(&dentry->d_rcu, d_callback);
 }
 
+static void dentry_add_lru(struct dentry *dentry)
+{
+	struct zone_shrinker *zs;
+	zs = get_zone_shrinker(page_zone(virt_to_page(dentry)), zone_shrinker);
+	list_add(&dentry->d_lru, &zs->lru);
+	zs->nr++;
+}
+
+static void dentry_del_lru(struct dentry *dentry)
+{
+	struct zone_shrinker *zs;
+	zs = get_zone_shrinker(page_zone(virt_to_page(dentry)), zone_shrinker);
+	list_del(&dentry->d_lru);
+	zs->nr--;
+}
+
 /*
  * Release the dentry's inode, using the filesystem
  * d_iput() operation if defined.
@@ -153,7 +170,7 @@ repeat:
 		spin_unlock(&dcache_lock);
 		return;
 	}
-			
+
 	/*
 	 * AV: ->d_delete() is _NOT_ allowed to block now.
 	 */
@@ -164,9 +181,9 @@ repeat:
 	/* Unreachable? Get rid of it */
  	if (d_unhashed(dentry))
 		goto kill_it;
-  	if (list_empty(&dentry->d_lru)) {
-  		dentry->d_flags |= DCACHE_REFERENCED;
-  		list_add(&dentry->d_lru, &dentry_unused);
+	dentry->d_flags |= DCACHE_REFERENCED;
+  	if (list_empty(&dentry->d_unused)) {
+  		list_add(&dentry->d_unused, &dentry_unused);
   		dentry_stat.nr_unused++;
   	}
  	spin_unlock(&dentry->d_lock);
@@ -179,11 +196,12 @@ unhash_it:
 kill_it: {
 		struct dentry *parent;
 
-		/* If dentry was on d_lru list
+		/* If dentry was on d_unused list
 		 * delete it from there
 		 */
-  		if (!list_empty(&dentry->d_lru)) {
-  			list_del(&dentry->d_lru);
+		dentry_del_lru(dentry);
+  		if (!list_empty(&dentry->d_unused)) {
+  			list_del(&dentry->d_unused);
   			dentry_stat.nr_unused--;
   		}
   		list_del(&dentry->d_child);
@@ -261,9 +279,9 @@ int d_invalidate(struct dentry * dentry)
 static inline struct dentry * __dget_locked(struct dentry *dentry)
 {
 	atomic_inc(&dentry->d_count);
-	if (!list_empty(&dentry->d_lru)) {
+	if (!list_empty(&dentry->d_unused)) {
 		dentry_stat.nr_unused--;
-		list_del_init(&dentry->d_lru);
+		list_del_init(&dentry->d_unused);
 	}
 	return dentry;
 }
@@ -348,6 +366,7 @@ static inline void prune_one_dentry(stru
 {
 	struct dentry * parent;
 
+	dentry_del_lru(dentry);
 	__d_drop(dentry);
 	list_del(&dentry->d_child);
 	dentry_stat.nr_dentry--;	/* For d_free, below */
@@ -385,6 +404,37 @@ static void prune_dcache(int count)
 		list_del_init(tmp);
 		prefetch(dentry_unused.prev);
  		dentry_stat.nr_unused--;
+		dentry = list_entry(tmp, struct dentry, d_unused);
+
+ 		spin_lock(&dentry->d_lock);
+		/*
+		 * We found an inuse dentry which was not removed from
+		 * dentry_unused because of laziness during lookup.  Do not free
+		 * it - just keep it off the dentry_unused list.
+		 */
+ 		if (atomic_read(&dentry->d_count)) {
+ 			spin_unlock(&dentry->d_lock);
+			continue;
+		}
+		if (dentry->d_flags & DCACHE_REFERENCED)
+			dentry->d_flags &= ~DCACHE_REFERENCED;
+		prune_one_dentry(dentry);
+	}
+	spin_unlock(&dcache_lock);
+}
+
+static unsigned long prune_dcache_lru(struct list_head *list, unsigned long count)
+{
+	unsigned long pruned = 0;
+	spin_lock(&dcache_lock);
+	for (; count ; count--) {
+		struct dentry *dentry;
+		struct list_head *tmp;
+
+		tmp = list->prev;
+		if (tmp == list)
+			break;
+		prefetch(tmp->prev);
 		dentry = list_entry(tmp, struct dentry, d_lru);
 
  		spin_lock(&dentry->d_lock);
@@ -394,22 +444,32 @@ static void prune_dcache(int count)
 		 * it - just keep it off the dentry_unused list.
 		 */
  		if (atomic_read(&dentry->d_count)) {
+			if (!list_empty(&dentry->d_unused)) {
+				list_del_init(&dentry->d_unused);
+				dentry_stat.nr_unused--;
+			}
  			spin_unlock(&dentry->d_lock);
 			continue;
 		}
 		/* If the dentry was recently referenced, don't free it. */
 		if (dentry->d_flags & DCACHE_REFERENCED) {
 			dentry->d_flags &= ~DCACHE_REFERENCED;
- 			list_add(&dentry->d_lru, &dentry_unused);
- 			dentry_stat.nr_unused++;
+			list_del(&dentry->d_lru);
+ 			list_add(&dentry->d_lru, list);
  			spin_unlock(&dentry->d_lock);
 			continue;
 		}
+		list_del_init(&dentry->d_unused);
+		dentry_stat.nr_unused--;
 		prune_one_dentry(dentry);
+		pruned++;
 	}
 	spin_unlock(&dcache_lock);
+
+	return pruned;
 }
 
+
 /*
  * Shrink the dcache for the specified super block.
  * This allows us to unmount a device without disturbing
@@ -446,7 +506,7 @@ void shrink_dcache_sb(struct super_block
 	while (next != &dentry_unused) {
 		tmp = next;
 		next = tmp->next;
-		dentry = list_entry(tmp, struct dentry, d_lru);
+		dentry = list_entry(tmp, struct dentry, d_unused);
 		if (dentry->d_sb != sb)
 			continue;
 		list_del(tmp);
@@ -461,7 +521,7 @@ repeat:
 	while (next != &dentry_unused) {
 		tmp = next;
 		next = tmp->next;
-		dentry = list_entry(tmp, struct dentry, d_lru);
+		dentry = list_entry(tmp, struct dentry, d_unused);
 		if (dentry->d_sb != sb)
 			continue;
 		dentry_stat.nr_unused--;
@@ -551,16 +611,16 @@ resume:
 		struct dentry *dentry = list_entry(tmp, struct dentry, d_child);
 		next = tmp->next;
 
-		if (!list_empty(&dentry->d_lru)) {
+		if (!list_empty(&dentry->d_unused)) {
 			dentry_stat.nr_unused--;
-			list_del_init(&dentry->d_lru);
+			list_del_init(&dentry->d_unused);
 		}
 		/* 
 		 * move only zero ref count dentries to the end 
 		 * of the unused list for prune_dcache
 		 */
 		if (!atomic_read(&dentry->d_count)) {
-			list_add(&dentry->d_lru, dentry_unused.prev);
+			list_add(&dentry->d_unused, dentry_unused.prev);
 			dentry_stat.nr_unused++;
 			found++;
 		}
@@ -626,9 +686,9 @@ void shrink_dcache_anon(struct hlist_hea
 		spin_lock(&dcache_lock);
 		hlist_for_each(lp, head) {
 			struct dentry *this = hlist_entry(lp, struct dentry, d_hash);
-			if (!list_empty(&this->d_lru)) {
+			if (!list_empty(&this->d_unused)) {
 				dentry_stat.nr_unused--;
-				list_del(&this->d_lru);
+				list_del(&this->d_unused);
 			}
 
 			/* 
@@ -636,7 +696,7 @@ void shrink_dcache_anon(struct hlist_hea
 			 * of the unused list for prune_dcache
 			 */
 			if (!atomic_read(&this->d_count)) {
-				list_add_tail(&this->d_lru, &dentry_unused);
+				list_add_tail(&this->d_unused, &dentry_unused);
 				dentry_stat.nr_unused++;
 				found++;
 			}
@@ -658,14 +718,16 @@ void shrink_dcache_anon(struct hlist_hea
  *
  * In this case we return -1 to tell the caller that we baled.
  */
-static int shrink_dcache_memory(int nr, unsigned int gfp_mask)
+static unsigned long shrink_dcache_memory(struct zone_shrinker *zs,
+							unsigned long nr,
+							unsigned int gfp_mask)
 {
 	if (nr) {
 		if (!(gfp_mask & __GFP_FS))
 			return -1;
-		prune_dcache(nr);
+		zs->nr -= prune_dcache_lru(&zs->lru, nr);
 	}
-	return (dentry_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
+	return (zs->nr / 100) * sysctl_vfs_cache_pressure;
 }
 
 /**
@@ -695,7 +757,7 @@ struct dentry *d_alloc(struct dentry * p
 		}
 	} else  {
 		dname = dentry->d_iname;
-	}	
+	}
 	dentry->d_name.name = dname;
 
 	dentry->d_name.len = name->len;
@@ -716,6 +778,7 @@ struct dentry *d_alloc(struct dentry * p
 	dentry->d_bucket = NULL;
 	INIT_HLIST_NODE(&dentry->d_hash);
 	INIT_LIST_HEAD(&dentry->d_lru);
+	INIT_LIST_HEAD(&dentry->d_unused);
 	INIT_LIST_HEAD(&dentry->d_subdirs);
 	INIT_LIST_HEAD(&dentry->d_alias);
 
@@ -727,6 +790,7 @@ struct dentry *d_alloc(struct dentry * p
 	}
 
 	spin_lock(&dcache_lock);
+	dentry_add_lru(dentry);
 	if (parent)
 		list_add(&dentry->d_child, &parent->d_subdirs);
 	dentry_stat.nr_dentry++;
@@ -831,7 +895,7 @@ struct dentry * d_alloc_anon(struct inod
 		return NULL;
 
 	tmp->d_parent = tmp; /* make sure dput doesn't croak */
-	
+
 	spin_lock(&dcache_lock);
 	if (S_ISDIR(inode->i_mode) && !list_empty(&inode->i_dentry)) {
 		/* A directory can only have one dentry.
@@ -969,7 +1033,7 @@ struct dentry * __d_lookup(struct dentry
 	struct hlist_node *node;
 
 	rcu_read_lock();
-	
+
 	hlist_for_each (node, head) { 
 		struct dentry *dentry; 
 		struct qstr *qstr;
@@ -1592,8 +1656,10 @@ static void __init dcache_init(unsigned 
 					 0,
 					 SLAB_RECLAIM_ACCOUNT|SLAB_PANIC,
 					 NULL, NULL);
-	
-	set_shrinker(DEFAULT_SEEKS, shrink_dcache_memory);
+
+	zone_shrinker = set_zone_shrinker(shrink_dcache_memory, DEFAULT_SEEKS);
+	if (zone_shrinker < 0)
+		BUG();
 }
 
 /* SLAB cache for __getname() consumers */
diff -puN include/linux/mmzone.h~perzone-slab include/linux/mmzone.h
--- linux-2.6/include/linux/mmzone.h~perzone-slab	2004-07-28 20:54:53.000000000 +1000
+++ linux-2.6-npiggin/include/linux/mmzone.h	2004-07-28 20:54:53.000000000 +1000
@@ -142,7 +142,7 @@ struct zone {
 
 	ZONE_PADDING(_pad1_)
 
-	spinlock_t		lru_lock;	
+	spinlock_t		lru_lock;
 	struct list_head	active_list;
 	struct list_head	inactive_list;
 	unsigned long		nr_scan_active;
@@ -152,6 +152,8 @@ struct zone {
 	int			all_unreclaimable; /* All pages pinned */
 	unsigned long		pages_scanned;	   /* since last reclaim */
 
+	struct list_head	zone_shrinker_list;
+
 	ZONE_PADDING(_pad2_)
 
 	/*
diff -puN mm/page_alloc.c~perzone-slab mm/page_alloc.c
--- linux-2.6/mm/page_alloc.c~perzone-slab	2004-07-28 20:54:53.000000000 +1000
+++ linux-2.6-npiggin/mm/page_alloc.c	2004-07-28 20:54:53.000000000 +1000
@@ -1495,6 +1495,7 @@ static void __init free_area_init_core(s
 		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
+		INIT_LIST_HEAD(&zone->zone_shrinker_list);
 		if (!size)
 			continue;
 
diff -puN include/linux/mm.h~perzone-slab include/linux/mm.h
--- linux-2.6/include/linux/mm.h~perzone-slab	2004-07-28 20:54:53.000000000 +1000
+++ linux-2.6-npiggin/include/linux/mm.h	2004-07-28 20:54:53.000000000 +1000
@@ -575,6 +575,25 @@ struct shrinker;
 extern struct shrinker *set_shrinker(int, shrinker_t);
 extern void remove_shrinker(struct shrinker *shrinker);
 
+struct zone_shrinker;
+typedef unsigned long (*zone_shrinker_fn)(struct zone_shrinker *zs,
+						unsigned long nr_to_scan,
+						unsigned int gfp_mask);
+struct zone_shrinker {
+	struct list_head	lru;
+	unsigned long		nr;
+	zone_shrinker_fn	shrinker;
+	unsigned long		nr_scan;
+	int			seeks;
+
+	int			idx;
+	struct list_head	list;
+};
+
+int set_zone_shrinker(zone_shrinker_fn, int);
+struct zone_shrinker *get_zone_shrinker(struct zone *, int);
+void remove_zone_shrinker(int);
+
 /*
  * On a two-level page table, this ends up being trivial. Thus the
  * inlining and the symmetry break with pte_alloc_map() that does all
diff -puN mm/vmscan.c~perzone-slab mm/vmscan.c
--- linux-2.6/mm/vmscan.c~perzone-slab	2004-07-28 20:54:53.000000000 +1000
+++ linux-2.6-npiggin/mm/vmscan.c	2004-07-28 20:59:02.000000000 +1000
@@ -130,16 +130,16 @@ static DECLARE_RWSEM(shrinker_rwsem);
  */
 struct shrinker *set_shrinker(int seeks, shrinker_t theshrinker)
 {
-        struct shrinker *shrinker;
+	struct shrinker *shrinker;
 
-        shrinker = kmalloc(sizeof(*shrinker), GFP_KERNEL);
-        if (shrinker) {
-	        shrinker->shrinker = theshrinker;
-	        shrinker->seeks = seeks;
-	        shrinker->nr = 0;
-	        down_write(&shrinker_rwsem);
-	        list_add(&shrinker->list, &shrinker_list);
-	        up_write(&shrinker_rwsem);
+	shrinker = kmalloc(sizeof(*shrinker), GFP_KERNEL);
+	if (shrinker) {
+		shrinker->shrinker = theshrinker;
+		shrinker->seeks = seeks;
+		shrinker->nr = 0;
+		down_write(&shrinker_rwsem);
+		list_add(&shrinker->list, &shrinker_list);
+		up_write(&shrinker_rwsem);
 	}
 	return shrinker;
 }
@@ -157,6 +157,81 @@ void remove_shrinker(struct shrinker *sh
 }
 EXPORT_SYMBOL(remove_shrinker);
 
+static unsigned int zone_shrinker_idx;
+
+/*
+ * Add a shrinker callback to be called from the vm
+ */
+int set_zone_shrinker(zone_shrinker_fn fn, int seeks)
+{
+	int idx;
+	struct zone_shrinker *zs;
+	struct zone *zone;
+
+	down_write(&shrinker_rwsem);
+	idx = zone_shrinker_idx++;
+
+	for_each_zone(zone) {
+		zs = kmalloc(sizeof(*zs), GFP_KERNEL);
+		if (!zs) {
+			up_write(&shrinker_rwsem);
+			remove_zone_shrinker(idx);
+			return -ENOMEM;
+		}
+		INIT_LIST_HEAD(&zs->lru);
+		zs->shrinker = fn;
+		zs->seeks = seeks;
+		zs->nr = 0;
+		zs->idx = idx;
+		spin_lock_irq(&zone->lru_lock);
+		list_add(&zs->list, &zone->zone_shrinker_list);
+		spin_unlock_irq(&zone->lru_lock);
+	}
+	up_write(&shrinker_rwsem);
+	return idx;
+}
+EXPORT_SYMBOL(set_zone_shrinker);
+
+struct zone_shrinker *get_zone_shrinker(struct zone *zone, int idx)
+{
+	struct zone_shrinker *zs;
+	struct zone_shrinker *ret = NULL;
+
+	spin_lock_irq(&zone->lru_lock);
+	list_for_each_entry(zs, &zone->zone_shrinker_list, list) {
+		if (zs->idx == idx) {
+			ret = zs;
+			break;
+		}
+	}
+	spin_unlock_irq(&zone->lru_lock);
+	return ret;
+}
+EXPORT_SYMBOL(get_zone_shrinker);
+
+/*
+ * Remove one
+ */
+void remove_zone_shrinker(int idx)
+{
+	struct zone *zone;
+
+	down_write(&shrinker_rwsem);
+	for_each_zone(zone) {
+		struct zone_shrinker *zs;
+		list_for_each_entry(zs, &zone->zone_shrinker_list, list) {
+			if (zs->idx == idx) {
+				spin_lock_irq(&zone->lru_lock);
+				list_del(&zs->list);
+				spin_unlock_irq(&zone->lru_lock);
+				kfree(zs);
+			}
+		}
+	}
+	up_write(&shrinker_rwsem);
+}
+EXPORT_SYMBOL(remove_zone_shrinker);
+
 #define SHRINK_BATCH 128
 /*
  * Call the shrink functions to age shrinkable caches
@@ -171,8 +246,9 @@ EXPORT_SYMBOL(remove_shrinker);
  *
  * We do weird things to avoid (scanned*seeks*entries) overflowing 32 bits.
  */
-static int shrink_slab(unsigned long scanned, unsigned int gfp_mask)
+static int shrink_slab(struct zone *zone, unsigned long scanned, unsigned int gfp_mask)
 {
+	struct zone_shrinker *zs;
 	struct shrinker *shrinker;
 	long pages;
 
@@ -182,26 +258,25 @@ static int shrink_slab(unsigned long sca
 	if (!down_read_trylock(&shrinker_rwsem))
 		return 0;
 
-	pages = nr_used_zone_pages();
-	list_for_each_entry(shrinker, &shrinker_list, list) {
+	list_for_each_entry(zs, &zone->zone_shrinker_list, list) {
 		unsigned long long delta;
 		unsigned long total_scan;
 
-		delta = (4 * scanned) / shrinker->seeks;
-		delta *= (*shrinker->shrinker)(0, gfp_mask);
-		do_div(delta, pages + 1);
-		shrinker->nr += delta;
-		if (shrinker->nr < 0)
-			shrinker->nr = LONG_MAX;	/* It wrapped! */
+		delta = (4 * scanned) / zs->seeks;
+		delta *= (*zs->shrinker)(zs, 0, gfp_mask);
+		do_div(delta, zone->nr_inactive + zone->nr_active + 1);
+		zs->nr_scan += delta;
+		if (zs->nr_scan < 0)
+			zs->nr_scan = LONG_MAX;	/* It wrapped! */
 
-		total_scan = shrinker->nr;
-		shrinker->nr = 0;
+		total_scan = zs->nr_scan;
+		zs->nr_scan = 0;
 
 		while (total_scan >= SHRINK_BATCH) {
 			long this_scan = SHRINK_BATCH;
 			int shrink_ret;
 
-			shrink_ret = (*shrinker->shrinker)(this_scan, gfp_mask);
+			shrink_ret = (*zs->shrinker)(zs, this_scan, gfp_mask);
 			if (shrink_ret == -1)
 				break;
 			mod_page_state(slabs_scanned, this_scan);
@@ -210,8 +285,9 @@ static int shrink_slab(unsigned long sca
 			cond_resched();
 		}
 
-		shrinker->nr += total_scan;
+		zs->nr_scan += total_scan;
 	}
+
 	up_read(&shrinker_rwsem);
 	return 0;
 }
@@ -866,6 +942,8 @@ shrink_zone(struct zone *zone, struct sc
 static void
 shrink_caches(struct zone **zones, struct scan_control *sc)
 {
+	struct reclaim_state *reclaim_state = current->reclaim_state;
+	unsigned long total_scanned = 0;
 	int i;
 
 	for (i = 0; zones[i] != NULL; i++) {
@@ -878,8 +956,17 @@ shrink_caches(struct zone **zones, struc
 		if (zone->all_unreclaimable && sc->priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
+		sc->nr_scanned = 0;
 		shrink_zone(zone, sc);
+		total_scanned += sc->nr_scanned;
+		shrink_slab(zone, sc->nr_scanned, sc->gfp_mask);
+		if (reclaim_state) {
+			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+			reclaim_state->reclaimed_slab = 0;
+		}
 	}
+
+	sc->nr_scanned = total_scanned;
 }
  
 /*
@@ -901,7 +988,6 @@ int try_to_free_pages(struct zone **zone
 	int priority;
 	int ret = 0;
 	int total_scanned = 0, total_reclaimed = 0;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc;
 	int i;
 
@@ -919,11 +1005,6 @@ int try_to_free_pages(struct zone **zone
 		sc.nr_reclaimed = 0;
 		sc.priority = priority;
 		shrink_caches(zones, &sc);
-		shrink_slab(sc.nr_scanned, gfp_mask);
-		if (reclaim_state) {
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
-		}
 		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX) {
 			ret = 1;
 			goto out;
@@ -1055,7 +1136,7 @@ scan:
 			sc.priority = priority;
 			shrink_zone(zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
-			shrink_slab(sc.nr_scanned, GFP_KERNEL);
+			shrink_slab(zone, sc.nr_scanned, GFP_KERNEL);
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_reclaimed += sc.nr_reclaimed;
 			if (zone->all_unreclaimable)
diff -puN include/linux/dcache.h~perzone-slab include/linux/dcache.h
--- linux-2.6/include/linux/dcache.h~perzone-slab	2004-07-28 20:54:53.000000000 +1000
+++ linux-2.6-npiggin/include/linux/dcache.h	2004-07-28 20:54:53.000000000 +1000
@@ -95,6 +95,7 @@ struct dentry {
 	struct qstr d_name;
 
 	struct list_head d_lru;		/* LRU list */
+	struct list_head d_unused;	/* unused list */
 	struct list_head d_child;	/* child of parent list */
 	struct list_head d_subdirs;	/* our children */
 	struct list_head d_alias;	/* inode alias list */

_

--------------080307010200000606030902--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
