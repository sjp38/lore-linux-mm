Date: Fri, 21 Oct 2005 23:30:01 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
Message-ID: <20051022013001.GE27317@logos.cnet>
References: <20050930193754.GB16812@xeon.cnet> <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com> <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com> <43419686.60600@colorfullife.com> <20051003221743.GB29091@logos.cnet> <4342B623.3060007@colorfullife.com> <20051006160115.GA30677@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051006160115.GA30677@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, akpm@osdl.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, arjanv@redhat.com
List-ID: <linux-mm.kvack.org>

Took it a while more than "tomorrow" but I have something.

> I'm thinking over this, will be sending something soon. 

I'm testing the following which implements "slab_reclaim_ops"
and dcache methods as discussed (inode, dquot, etc should follow).

It also addresses some problems Al Viro pointed with reference to the   
dcache.                                                                 

Doing a battery of tests on it - need to come up with more detailed
statistics (hit ratio on the caches and "freed objects/freed pages"
ratios with different interesting workloads).

Comments?

diff -ur -p --exclude-from=linux-2.6.13.3.slab/Documentation/dontdiff linux-2.6.13.3.orig/fs/dcache.c linux-2.6.13.3.slab/fs/dcache.c
--- linux-2.6.13.3.orig/fs/dcache.c	2005-10-03 18:27:35.000000000 -0500
+++ linux-2.6.13.3.slab/fs/dcache.c	2005-10-21 17:47:38.000000000 -0500
@@ -44,7 +44,8 @@ static seqlock_t rename_lock __cacheline
 
 EXPORT_SYMBOL(dcache_lock);
 
-static kmem_cache_t *dentry_cache; 
+kmem_cache_t *dentry_cache; 
+
 
 #define DNAME_INLINE_LEN (sizeof(struct dentry)-offsetof(struct dentry,d_iname))
 
@@ -84,6 +85,7 @@ static void d_callback(struct rcu_head *
  */
 static void d_free(struct dentry *dentry)
 {
+	dentry->d_flags = 0;
 	if (dentry->d_op && dentry->d_op->d_release)
 		dentry->d_op->d_release(dentry);
  	call_rcu(&dentry->d_rcu, d_callback);
@@ -363,7 +365,7 @@ restart:
  * removed.
  * Called with dcache_lock, drops it and then regains.
  */
-static inline void prune_one_dentry(struct dentry * dentry)
+inline void prune_one_dentry(struct dentry * dentry)
 {
 	struct dentry * parent;
 
@@ -390,13 +392,17 @@ static inline void prune_one_dentry(stru
  * This function may fail to free any resources if
  * all the dentries are in use.
  */
+
+unsigned long long check_slab_page(void *);
+int free_slab_page(void *objp, unsigned long long bitmap);
  
-static void prune_dcache(int count)
+static void __prune_dcache(int count, int page_scan)
 {
 	spin_lock(&dcache_lock);
 	for (; count ; count--) {
 		struct dentry *dentry;
 		struct list_head *tmp;
+		unsigned long long bitmap;
 
 		cond_resched_lock(&dcache_lock);
 
@@ -426,11 +432,238 @@ static void prune_dcache(int count)
  			spin_unlock(&dentry->d_lock);
 			continue;
 		}
+
+		if (page_scan) {
+			/*XXX: dcache_lock guarantees dentry won't vanish?*/
+			spin_unlock(&dentry->d_lock);
+			if ((bitmap = check_slab_page(dentry))) {
+				if (free_slab_page(dentry, bitmap))
+					continue;
+			}
+			spin_lock(&dentry->d_lock);
+ 			if (atomic_read(&dentry->d_count)) {
+				/* keep it off the dentry_unused list. */
+				spin_unlock(&dentry->d_lock);
+				continue;
+			}
+			/* if the aggregate freeing fails we proceed 
+			 * to free the single dentry as usual.
+			 */
+		} 
+
 		prune_one_dentry(dentry);
 	}
 	spin_unlock(&dcache_lock);
 }
 
+static void prune_dcache(int count)
+{
+	__prune_dcache(count, 1);
+}
+
+static inline int dentry_negative(struct dentry *dentry)
+{
+	return (dentry->d_inode == NULL);
+}
+
+#define MAX_CHILD_REAP 32
+
+int dir_check_freeable(struct dentry *parent)
+{
+	struct dentry *this_parent = parent;
+	struct list_head *next;
+	unsigned int int_array[32];
+	unsigned int *int_array_ptr = (unsigned int *)&int_array;
+	unsigned int nr_children, ret;
+
+	ret = nr_children = 0;
+	memset(&int_array, 0, sizeof(int_array));
+
+	if (list_empty(&this_parent->d_subdirs))
+		BUG();
+repeat:
+	next = this_parent->d_subdirs.next;
+resume:
+	while (next != &this_parent->d_subdirs) {
+		struct list_head *tmp = next;
+		struct dentry *dentry = list_entry(tmp, struct dentry, d_child);
+
+		if (!(virt_addr_valid(next)))
+			BUG();
+
+		next = tmp->next;
+
+		if (!list_empty(&dentry->d_subdirs)) {
+			this_parent = dentry;
+			/* increase the counter */
+			*int_array_ptr = *int_array_ptr+1;
+			/* move to next array position */
+			int_array_ptr++;
+			if (int_array_ptr >= (unsigned int *)&int_array+(sizeof(int_array)/sizeof(int)))
+				BUG();
+			*int_array_ptr = 0;
+			nr_children++;
+			goto repeat;
+		}
+		/* Pinned or negative dentry? */
+		if (!atomic_read(&dentry->d_count) && !dentry_negative(dentry)) {
+			*int_array_ptr = *int_array_ptr+1;
+			nr_children++;
+		} else 
+			/* unfreeable dentry, bail out */
+			goto out;
+        }
+
+	/*
+         * All done at this level ... ascend and resume the search.
+         */
+        if (this_parent != parent) {
+		unsigned int val = *int_array_ptr;
+		/* does this directory have any additional ref? */
+		if (atomic_read(&this_parent->d_count) != val)
+			return 0;
+		int_array_ptr--;
+		if (int_array_ptr < (unsigned int*)&int_array)
+			BUG();
+
+		next = this_parent->d_child.next;
+		this_parent = this_parent->d_parent;
+		goto resume;
+        }
+
+	if (int_array_ptr != (unsigned int*)&int_array) {
+		printk("int array pointer differs: ptr:%p - &array:%p\n",
+			int_array_ptr, &int_array);
+		BUG();
+	}
+
+	if (nr_children < MAX_CHILD_REAP)
+		if (atomic_read(&parent->d_count) == *int_array_ptr)
+			ret = 1;
+out:
+	return ret;
+}
+
+/*
+ * XXX: what are the consequences of acquiring the lock of
+ * a free object? Can some other codepath race and try to 
+ * use the dentry assuming it is free while we "hold" the
+ * lock here? 
+ * 
+ * Since the reading of protected dentry->d_flags is performed 
+ * locklessly, we might be reading stale data.
+ *
+ * Does it need a memory barrier to synchronize with d_free()'s 
+ * DCACHE_INUSE assignment? 
+ * 
+ */
+int dcache_objp_lock(void *obj)
+{
+	struct dentry *dentry = (struct dentry *)obj;
+
+	if (((dentry->d_flags & DCACHE_INUSE) == DCACHE_INUSE)) {
+		spin_lock(&dentry->d_lock);
+		return 1;
+	}
+	return 0;
+}
+
+int dcache_objp_unlock(void *obj)
+{
+	struct dentry *dentry = (struct dentry *)obj;
+	spin_unlock(&dentry->d_lock);
+	return 1;
+}
+
+/* 
+ * dcache_lock guarantees that dentry and children will not 
+ * vanish under us.
+ */
+int dcache_objp_is_freeable(void *obj)
+{
+	int ret = 1;
+	struct dentry *dentry = (struct dentry*)obj;
+
+	if (dentry->d_flags & (DCACHE_UNHASHED|DCACHE_DISCONNECTED))
+		return 0;
+
+	if (!((dentry->d_flags & DCACHE_INUSE) == DCACHE_INUSE))
+		return 0;
+
+	if (dentry_negative(dentry))
+		return 0;
+	
+	if (atomic_read(&dentry->d_count)) {
+		ret = 0;
+		if (!list_empty(&dentry->d_subdirs))
+		       	ret = dir_check_freeable(dentry);
+	}
+	return ret;
+}
+
+/* 
+ * dentry_free_child - attempt to free children of a given dentry.
+ * Caller holds an additional reference to it which is released here.
+ */
+int dentry_free_child(struct dentry *dentry)
+{
+	int ret = 1;
+
+	if (dentry->d_inode == NULL)
+		BUG();
+
+	if (!list_empty(&dentry->d_subdirs)) {
+		spin_unlock(&dcache_lock);
+		shrink_dcache_parent(dentry);
+		spin_lock(&dcache_lock);
+	}
+
+        spin_lock(&dentry->d_lock);
+	atomic_dec(&dentry->d_count);
+	if (atomic_read(&dentry->d_count))
+		ret = 0;
+	return ret;
+}
+
+int dcache_objp_release(void *obj)
+{
+	struct dentry *dentry = (struct dentry*)obj;
+	int ret = 0;
+
+	/* no additional references? nuke it */
+	if (!atomic_read(&dentry->d_count) ) {
+		if (!list_empty(&dentry->d_lru)) {
+			dentry_stat.nr_unused--;
+			list_del_init(&dentry->d_lru);
+		}
+		ret = 1;
+		prune_one_dentry(dentry);
+	/* otherwise attempt to free children */
+	} else if (!list_empty(&dentry->d_subdirs)) {
+		/* grab a reference to guarantee dir won't vanish */
+		/* XXX: Confirm it is OK to grab an additional ref. here. */
+		atomic_inc(&dentry->d_count);
+		spin_unlock(&dentry->d_lock);
+		if (dentry_free_child(dentry)) {
+			if (!list_empty(&dentry->d_lru)) {
+				dentry_stat.nr_unused--;
+				list_del_init(&dentry->d_lru);
+			}
+			ret = 1;
+			prune_one_dentry(dentry);
+		} else 
+			spin_unlock(&dentry->d_lock);
+	}
+	return ret;
+}
+
+struct slab_reclaim_ops dcache_reclaim_ops = {
+	.objp_is_freeable = dcache_objp_is_freeable,
+	.objp_release = dcache_objp_release,
+	.objp_lock = dcache_objp_lock,
+	.objp_unlock = dcache_objp_unlock,
+};
+
 /*
  * Shrink the dcache for the specified super block.
  * This allows us to unmount a device without disturbing
@@ -642,7 +875,7 @@ void shrink_dcache_parent(struct dentry 
 	int found;
 
 	while ((found = select_parent(parent)) != 0)
-		prune_dcache(found);
+		__prune_dcache(found, 0);
 }
 
 /**
@@ -680,7 +913,7 @@ void shrink_dcache_anon(struct hlist_hea
 			}
 		}
 		spin_unlock(&dcache_lock);
-		prune_dcache(found);
+		__prune_dcache(found, 0);
 	} while(found);
 }
 
@@ -742,7 +975,7 @@ struct dentry *d_alloc(struct dentry * p
 	dname[name->len] = 0;
 
 	atomic_set(&dentry->d_count, 1);
-	dentry->d_flags = DCACHE_UNHASHED;
+	dentry->d_flags = DCACHE_UNHASHED|DCACHE_INUSE;
 	spin_lock_init(&dentry->d_lock);
 	dentry->d_inode = NULL;
 	dentry->d_parent = NULL;
@@ -1689,6 +1922,8 @@ static void __init dcache_init(unsigned 
 	
 	set_shrinker(DEFAULT_SEEKS, shrink_dcache_memory);
 
+	slab_set_reclaim_ops(dentry_cache, &dcache_reclaim_ops);
+
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
 		return;
diff -ur -p --exclude-from=linux-2.6.13.3.slab/Documentation/dontdiff linux-2.6.13.3.orig/fs/inode.c linux-2.6.13.3.slab/fs/inode.c
--- linux-2.6.13.3.orig/fs/inode.c	2005-10-03 18:27:35.000000000 -0500
+++ linux-2.6.13.3.slab/fs/inode.c	2005-10-20 17:17:56.000000000 -0500
@@ -97,7 +97,7 @@ DECLARE_MUTEX(iprune_sem);
  */
 struct inodes_stat_t inodes_stat;
 
-static kmem_cache_t * inode_cachep;
+kmem_cache_t * inode_cachep;
 
 static struct inode *alloc_inode(struct super_block *sb)
 {
diff -ur -p --exclude-from=linux-2.6.13.3.slab/Documentation/dontdiff linux-2.6.13.3.orig/include/linux/dcache.h linux-2.6.13.3.slab/include/linux/dcache.h
--- linux-2.6.13.3.orig/include/linux/dcache.h	2005-10-03 18:27:35.000000000 -0500
+++ linux-2.6.13.3.slab/include/linux/dcache.h	2005-10-20 17:18:24.000000000 -0500
@@ -155,6 +155,7 @@ d_iput:		no		no		no       yes
 
 #define DCACHE_REFERENCED	0x0008  /* Recently used, don't discard. */
 #define DCACHE_UNHASHED		0x0010	
+#define DCACHE_INUSE		0xdbca0000
 
 extern spinlock_t dcache_lock;
 
diff -ur -p --exclude-from=linux-2.6.13.3.slab/Documentation/dontdiff linux-2.6.13.3.orig/include/linux/slab.h linux-2.6.13.3.slab/include/linux/slab.h
--- linux-2.6.13.3.orig/include/linux/slab.h	2005-10-03 18:27:35.000000000 -0500
+++ linux-2.6.13.3.slab/include/linux/slab.h	2005-10-20 17:18:27.000000000 -0500
@@ -76,6 +76,14 @@ struct cache_sizes {
 extern struct cache_sizes malloc_sizes[];
 extern void *__kmalloc(size_t, unsigned int __nocast);
 
+struct slab_reclaim_ops {
+	int (*objp_is_freeable)(void *objp);
+	int (*objp_release)(void *objp);
+	int (*objp_lock)(void *objp);
+	int (*objp_unlock)(void *objp);
+};
+extern int slab_set_reclaim_ops(kmem_cache_t *, struct slab_reclaim_ops *);
+
 static inline void *kmalloc(size_t size, unsigned int __nocast flags)
 {
 	if (__builtin_constant_p(size)) {
diff -ur -p --exclude-from=linux-2.6.13.3.slab/Documentation/dontdiff linux-2.6.13.3.orig/mm/slab.c linux-2.6.13.3.slab/mm/slab.c
--- linux-2.6.13.3.orig/mm/slab.c	2005-10-03 18:27:35.000000000 -0500
+++ linux-2.6.13.3.slab/mm/slab.c	2005-10-21 17:03:44.000000000 -0500
@@ -1,4 +1,5 @@
 /*
+ *
  * linux/mm/slab.c
  * Written by Mark Hemment, 1996/97.
  * (markhe@nextd.demon.co.uk)
@@ -93,6 +94,8 @@
 #include	<linux/module.h>
 #include	<linux/rcupdate.h>
 #include	<linux/string.h>
+#include	<linux/proc_fs.h>
+#include	<linux/pagemap.h>
 
 #include	<asm/uaccess.h>
 #include	<asm/cacheflush.h>
@@ -190,7 +193,7 @@
  */
 
 #define BUFCTL_END	(((kmem_bufctl_t)(~0U))-0)
-#define BUFCTL_FREE	(((kmem_bufctl_t)(~0U))-1)
+#define BUFCTL_INUSE	(((kmem_bufctl_t)(~0U))-1)
 #define	SLAB_LIMIT	(((kmem_bufctl_t)(~0U))-2)
 
 /* Max number of objs-per-slab for caches which use off-slab slabs.
@@ -327,6 +330,7 @@ struct kmem_cache_s {
 	kmem_cache_t		*slabp_cache;
 	unsigned int		slab_size;
 	unsigned int		dflags;		/* dynamic flags */
+	struct slab_reclaim_ops *reclaim_ops;
 
 	/* constructor func */
 	void (*ctor)(void *, kmem_cache_t *, unsigned long);
@@ -574,6 +578,266 @@ static void free_block(kmem_cache_t* cac
 static void enable_cpucache (kmem_cache_t *cachep);
 static void cache_reap (void *unused);
 
+int slab_set_reclaim_ops(kmem_cache_t *cachep, struct slab_reclaim_ops *ops)
+{
+	cachep->reclaim_ops = ops;
+	return 1;
+}
+
+static inline kmem_bufctl_t *slab_bufctl(struct slab *slabp)
+{
+	return (kmem_bufctl_t *)(slabp+1);
+}
+
+/* 
+ * Cache the used/free status from the slabbufctl management structure
+ * in a bitmap to avoid further cachep->spinlock locking.
+ * 
+ * Using this cached information guarantees that the freeing routine
+ * won't attempt to interpret uninitialized objects. It however does 
+ * not guarantee that it won't interpret freed objects (since an used
+ * object might be freed by another CPU without notification). 
+ *
+ * Appropriate locking is required (either global or per-object, depending
+ * on cache internals) to verify liveness with accuracy. 
+ *
+ */
+unsigned long long slab_free_status(kmem_cache_t *cachep, struct slab *slabp)
+{
+	unsigned long long bitmap = 0;
+	int i;
+
+	if (cachep->num > sizeof(unsigned long long)*8)
+		BUG();
+
+	spin_lock_irq(&cachep->spinlock);
+	for(i=0; i < cachep->num ; i++) {
+		if (slab_bufctl(slabp)[i] == BUFCTL_INUSE)
+			set_bit(i, (unsigned long *)&bitmap);
+	}
+	spin_unlock_irq(&cachep->spinlock);
+
+	return bitmap;
+}
+
+inline int objp_inuse (kmem_cache_t *cachep, struct slab *slabp, unsigned long long *bitmap, void *objp)
+{
+	int objnr = (objp - slabp->s_mem) / cachep->objsize;
+	
+	return test_bit(objnr, (unsigned long *)bitmap);
+}
+
+int slab_free_attempt = 0;
+int slab_free_success = 0;
+
+/*
+ * check_slab_page - check if the SLAB container of a given object is freeable.
+ * @objp: object which resides in the SLAB.
+ */
+unsigned long long check_slab_page(void *objp)
+{
+        struct page *page;
+        struct slab *slabp;
+        kmem_cache_t *cachep;
+        struct slab_reclaim_ops *ops;
+        int i;
+        unsigned long long bitmap;
+
+        page = virt_to_page(objp);
+        slabp = GET_PAGE_SLAB(page);
+        cachep = GET_PAGE_CACHE(page);
+        ops = cachep->reclaim_ops;
+
+        if (!ops)
+                BUG();
+	if (!PageSlab(page))
+		BUG();
+	if (slabp->s_mem != (page_address(page) + slabp->colouroff))
+		BUG();
+
+        if (PageLocked(page))
+                return 0;
+
+	/*
+	 * XXX: acquires cachep->lock with cache specific lock held.
+	 * Is it guaranteed that no code holding cachep->lock will 
+	 * attempt to grab the cache specific locks? (AB-BA deadlock)
+	 */
+	bitmap = slab_free_status(cachep, slabp);
+	
+	for(i=0; i < cachep->num ; i++) {
+		void *objn = slabp->s_mem + cachep->objsize * i;
+
+		if (!objp_inuse(cachep, slabp, &bitmap, objn))
+			continue;
+
+		/* XXX: It might be OK to do lockless reading? 
+		 * After all the object is rechecked again 
+		 * holding appropriate locks during freeing pass. 
+		 * It depends on the underlying cache.
+		 */
+		if (ops->objp_lock && !ops->objp_lock(objn))
+			continue;
+
+		if (!ops->objp_is_freeable(objn)) {
+			if (ops->objp_unlock)
+				ops->objp_unlock(objn);
+			break;
+		}
+		if (ops->objp_unlock)
+			ops->objp_unlock(objn);
+	}	
+
+	slab_free_attempt++;
+
+	if (i == cachep->num) 
+		return 1;
+	return 0;
+}
+
+/*
+ * free_slab_page - attempt to free the SLAB container of a given object.
+ * @objp: object which resides in the SLAB.
+ */
+int free_slab_page(void *objp, unsigned long long bitmap)
+{
+        struct page *page;
+        struct slab *slabp;
+        kmem_cache_t *cachep;
+        int i, ret = 0;
+        struct slab_reclaim_ops *ops;
+
+        page = virt_to_page(objp);
+        slabp = GET_PAGE_SLAB(page);
+        cachep = GET_PAGE_CACHE(page);
+
+        ops = cachep->reclaim_ops;
+
+        if (!ops)
+                BUG();
+	if (!PageSlab(page))
+		BUG();
+	if (slabp->s_mem != (page_address(page) + slabp->colouroff))
+		BUG();
+
+        if (TestSetPageLocked(page))
+                return 0;
+
+	for(i=0; i < cachep->num ; i++) {
+		void *objp = slabp->s_mem + cachep->objsize * i;
+
+		if (!objp_inuse(cachep, slabp, &bitmap, objp))
+			continue;
+
+		if (ops->objp_lock && !ops->objp_lock(objp))
+			continue;
+
+		/* freeable object? */
+		if (!ops->objp_is_freeable(objp)) {
+			if (ops->objp_unlock)
+				ops->objp_unlock(objp);
+			break;
+		}
+		/* release takes care of unlocking the object */
+		ops->objp_release(objp);
+	}
+
+        if (i == cachep->num) {
+		slab_free_success++;
+		ret = 1;
+	}
+	unlock_page(page);
+	return ret;
+}
+
+extern kmem_cache_t *dentry_cache;
+extern kmem_cache_t *inode_cachep;
+
+struct cache_stat {
+	unsigned int free_pages;
+	unsigned int partial_pages;
+	unsigned int partial_freeable;
+	unsigned int full_pages;
+	unsigned int full_freeable;
+};
+
+void cache_retrieve_stats(kmem_cache_t *cachep, struct cache_stat *stat)
+{
+	struct list_head *entry;
+	struct slab *slabp;
+
+	memset(stat, 0, sizeof(struct cache_stat));
+
+	list_for_each(entry,&cachep->lists.slabs_free)
+		stat->free_pages++;
+
+	list_for_each(entry,&cachep->lists.slabs_partial) {
+		slabp = list_entry(entry, struct slab, list);
+		stat->partial_pages++;
+		stat->partial_freeable += check_slab_page(slabp);
+	}
+
+	list_for_each(entry,&cachep->lists.slabs_full) {
+		slabp = list_entry(entry, struct slab, list);
+		stat->full_pages++;
+		stat->full_freeable += check_slab_page(slabp);
+	}
+}
+
+struct proc_dir_entry *slab_stats;
+struct proc_dir_entry *slab_reclaim;
+
+static int print_slab_stats(char *page, char **start,
+			  off_t off, int count, int *eof, void *data)
+{
+
+	struct cache_stat stat;
+	int len;
+
+	cache_retrieve_stats(dentry_cache, &stat);
+
+	len = sprintf(page, "dentry_cache free:%u partial:%u partial_f:%u full:%u full_f:%u\n", stat.free_pages, stat.partial_pages, stat.partial_freeable, stat.full_pages, stat.full_freeable);
+
+	cache_retrieve_stats(inode_cachep, &stat);
+
+	len += sprintf(page+len, "inode_cache free:%u partial:%u partial_f:%u full:%u full_f:%u\n", stat.free_pages, stat.partial_pages, stat.partial_freeable, stat.full_pages, stat.full_freeable);
+
+	return len;
+}
+
+static int print_slab_reclaim(char *page, char **start,
+			  off_t off, int count, int *eof, void *data)
+{
+	int len;
+
+	len = sprintf(page, "slab_free_attempt:%d slab_free_success:%d\n",
+			slab_free_attempt, slab_free_success);
+	return len;
+}
+
+int __init init_slab_stats(void)
+{
+	slab_stats = create_proc_read_entry("slab_stats", 0644, NULL,
+					print_slab_stats, NULL);
+	if (slab_stats == NULL) 
+		printk(KERN_ERR "failure to create slab_stats!\n");
+	else
+		printk(KERN_ERR "success creating slab_stats!\n");
+
+	slab_stats = create_proc_read_entry("slab_reclaim", 0644, NULL,
+					print_slab_reclaim, NULL);
+	if (slab_reclaim == NULL) 
+		printk(KERN_ERR "failure to create slab_reclaim!\n");
+	else
+		printk(KERN_ERR "success creating slab_reclaim!\n");
+
+	slab_stats->owner = THIS_MODULE;
+
+	return 1;
+}
+
+late_initcall(init_slab_stats);
+
 static inline void **ac_entry(struct array_cache *ac)
 {
 	return (void**)(ac+1);
@@ -1710,11 +1974,6 @@ static struct slab* alloc_slabmgmt(kmem_
 	return slabp;
 }
 
-static inline kmem_bufctl_t *slab_bufctl(struct slab *slabp)
-{
-	return (kmem_bufctl_t *)(slabp+1);
-}
-
 static void cache_init_objs(kmem_cache_t *cachep,
 			struct slab *slabp, unsigned long ctor_flags)
 {
@@ -2054,9 +2313,9 @@ retry:
 
 			slabp->inuse++;
 			next = slab_bufctl(slabp)[slabp->free];
-#if DEBUG
-			slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-#endif
+
+			slab_bufctl(slabp)[slabp->free] = BUFCTL_INUSE;
+
 		       	slabp->free = next;
 		}
 		check_slabp(cachep, slabp);
@@ -2193,7 +2452,7 @@ static void free_block(kmem_cache_t *cac
 		objnr = (objp - slabp->s_mem) / cachep->objsize;
 		check_slabp(cachep, slabp);
 #if DEBUG
-		if (slab_bufctl(slabp)[objnr] != BUFCTL_FREE) {
+		if (slab_bufctl(slabp)[objnr] != BUFCTL_INUSE) {
 			printk(KERN_ERR "slab: double free detected in cache '%s', objp %p.\n",
 						cachep->name, objp);
 			BUG();
@@ -2422,9 +2681,7 @@ got_slabp:
 
 	slabp->inuse++;
 	next = slab_bufctl(slabp)[slabp->free];
-#if DEBUG
-	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-#endif
+	slab_bufctl(slabp)[slabp->free] = BUFCTL_INUSE;
 	slabp->free = next;
 	check_slabp(cachep, slabp);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
