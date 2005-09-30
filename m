Date: Fri, 30 Sep 2005 16:37:54 -0300
From: Marcelo <marcelo.tosatti@cyclades.com>
Subject: [PATCH] per-page SLAB freeing (only dcache for now)
Message-ID: <20050930193754.GB16812@xeon.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

Hi,

The SLAB reclaiming process works on per-object basis, out of pseudo-LRU
ordering in the case of inode and dentry caches.

In a recent thread named "VM balancing issues on 2.6.13: dentry cache 
not getting shrunk enough" folks suggested that the SLAB reclaiming
process should be changed to aim at entire SLAB containers, not 
single objects. This has been suggested several times in the past.

The following patch is an experimental attempt to do it for the 
dentry cache. 

It works by checking all objects of a given SLAB once a single object is
pruned in prune_dcache(). Once it has been confirmed that all objects
on the target SLAB are freeable, proceeds to free them all.

Few issues with the patch:

a) Locking needs further verification to confirm correctness.
b) The addition of "i_am_alive" flag might not be necessary: I believe
its possible to use kmembufctl to known about usage of objects 
within SLAB containers.
c) Freeing functions needs to be moved out of mm/slab.c in a proper
place.
d) General beautification.

I don't see any fundamental problems with this approach, are there any?
I'll clean it up and proceed to write the inode cache equivalent 
if there aren't.

Andrew commented about the requirement of a global lock for this reverse 
reclaiming - it seems to me that all that is necessary is correct
synchronization between users and the reclaiming path (not necessarily
a global lock though).

Or maybe I just dont get what he's talking about.

Anyway, dbench testing with 18 threads on 256Mb UP machine shows 
noticeable improvement (results in Mb/s):

                        1st run    2nd run    avg
stock 2.6.13            15.11       14.9      15.00	
2.6.13+slabreclaim      16.22       15.5      15.86

Comments?


diff -p -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/fs/dcache.c linux-2.6.13/fs/dcache.c
--- linux-2.6.13.orig/fs/dcache.c	2005-09-23 16:26:02.000000000 -0300
+++ linux-2.6.13/fs/dcache.c	2005-09-30 16:01:08.000000000 -0300
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
+	dentry->i_am_alive = 0;
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
 
@@ -390,8 +392,11 @@ static inline void prune_one_dentry(stru
  * This function may fail to free any resources if
  * all the dentries are in use.
  */
+
+int check_slab_page(void *);
+int free_slab_page(void *);
  
-static void prune_dcache(int count)
+static void __prune_dcache(int count, int page_scan)
 
 	spin_lock(&dcache_lock);
 	for (; count ; count--) {
@@ -427,10 +432,17 @@ static void prune_dcache(int count)
 			continue;
 		}
 		prune_one_dentry(dentry);
+		if(page_scan && check_slab_page(dentry))
+			free_slab_page(dentry);
 	}
 	spin_unlock(&dcache_lock);
 }
 
+static void prune_dcache(int count)
+{
+	__prune_dcache(count, 1);
+}
+
 /*
  * Shrink the dcache for the specified super block.
  * This allows us to unmount a device without disturbing
@@ -642,7 +654,7 @@ void shrink_dcache_parent(struct dentry 
 	int found;
 
 	while ((found = select_parent(parent)) != 0)
-		prune_dcache(found);
+		__prune_dcache(found, 0);
 }
 
 /**
@@ -680,7 +692,7 @@ void shrink_dcache_anon(struct hlist_hea
 			}
 		}
 		spin_unlock(&dcache_lock);
-		prune_dcache(found);
+		__prune_dcache(found, 0);
 	} while(found);
 }
 
@@ -755,6 +767,7 @@ struct dentry *d_alloc(struct dentry * p
 	INIT_LIST_HEAD(&dentry->d_lru);
 	INIT_LIST_HEAD(&dentry->d_subdirs);
 	INIT_LIST_HEAD(&dentry->d_alias);
+	dentry->i_am_alive = 0xdeadbeef;
 
 	if (parent) {
 		dentry->d_parent = dget(parent);
diff -p -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/fs/inode.c linux-2.6.13/fs/inode.c
--- linux-2.6.13.orig/fs/inode.c	2005-09-23 16:26:02.000000000 -0300
+++ linux-2.6.13/fs/inode.c	2005-09-28 14:17:31.000000000 -0300
@@ -97,7 +97,7 @@ DECLARE_MUTEX(iprune_sem);
  */
 struct inodes_stat_t inodes_stat;
 
-static kmem_cache_t * inode_cachep;
+kmem_cache_t * inode_cachep;
 
 static struct inode *alloc_inode(struct super_block *sb)
 {
diff -p -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/include/linux/dcache.h linux-2.6.13/include/linux/dcache.h
--- linux-2.6.13.orig/include/linux/dcache.h	2005-06-17 16:48:29.000000000 -0300
+++ linux-2.6.13/include/linux/dcache.h	2005-09-27 16:17:59.000000000 -0300
@@ -106,6 +106,7 @@ struct dentry {
 	struct hlist_node d_hash;	/* lookup hash list */	
 	int d_mounted;
 	unsigned char d_iname[DNAME_INLINE_LEN_MIN];	/* small names */
+	int i_am_alive;
 };
 
 struct dentry_operations {
diff -p -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/mm/slab.c linux-2.6.13/mm/slab.c
--- linux-2.6.13.orig/mm/slab.c	2005-09-23 16:26:04.000000000 -0300
+++ linux-2.6.13/mm/slab.c	2005-09-30 16:08:06.000000000 -0300
@@ -93,6 +93,8 @@
 #include	<linux/module.h>
 #include	<linux/rcupdate.h>
 #include	<linux/string.h>
+#include	<linux/proc_fs.h>
+#include	<linux/dcache.h>
 
 #include	<asm/uaccess.h>
 #include	<asm/cacheflush.h>
@@ -574,6 +576,259 @@ static void free_block(kmem_cache_t* cac
 static void enable_cpucache (kmem_cache_t *cachep);
 static void cache_reap (void *unused);
 
+int dentry_check_freeable(struct dentry *parent)
+{
+	struct dentry *this_parent = parent;
+	struct list_head *next;
+	unsigned int int_array[32]; /* XXX: should match tree depth limit */
+	unsigned int *int_array_ptr = (unsigned int *)&int_array;
+
+	memset(int_array, 0, sizeof(int_array));
+
+	if (parent->i_am_alive != 0xdeadbeef)
+		return 1;
+repeat:
+        next = this_parent->d_subdirs.next;
+resume:
+        while (next != &this_parent->d_subdirs) {
+		struct list_head *tmp = next;
+		struct dentry *dentry = list_entry(tmp, struct dentry, d_child);
+		next = tmp->next;
+
+                if (!list_empty(&dentry->d_subdirs)) {
+                        this_parent = dentry;
+			/* increase the counter */
+			*int_array_ptr = *int_array_ptr+1;
+			/* move to next array position */
+			int_array_ptr++;
+			if (int_array_ptr >= (unsigned int*)(&int_array)+(sizeof(int_array)))
+				BUG();
+			*int_array_ptr = 0;
+
+                        goto repeat;
+                }
+                /* Pinned dentry? */
+		if (atomic_read(&dentry->d_count))
+			return 0;
+		else 
+			*int_array_ptr = *int_array_ptr+1;
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
+	if (atomic_read(&parent->d_count) == *int_array_ptr)
+		return 1;
+
+	return 0;
+}
+
+int check_slab_page(void *objp)
+{
+        struct slab *slabp = GET_PAGE_SLAB(virt_to_page(objp));
+        kmem_cache_t *cachep = GET_PAGE_CACHE(virt_to_page(objp));
+        int i;
+
+	for(i=0; i < cachep->num ; i++) {
+		struct dentry *target;
+		void *objp = slabp->s_mem + cachep->objsize * i;
+		target = (struct dentry *)objp;
+
+		if (atomic_read(&target->d_count)) {
+			if (!dentry_check_freeable(target))
+				break;
+			}
+		}
+
+	if (i == cachep->num)
+		return 1;
+
+	return 0;
+}
+
+int dentry_free_child(struct dentry *dentry)
+{
+	int ret = 1;
+        if (!list_empty(&dentry->d_subdirs)) {
+                spin_unlock(&dcache_lock);
+                shrink_dcache_parent(dentry);
+                spin_lock(&dcache_lock);
+        }
+
+	spin_lock(&dentry->d_lock);
+	if (atomic_read(&dentry->d_count))
+		ret = 0;
+
+	return ret;
+}
+
+int slab_free_attempt = 0;
+int slab_free_success = 0;
+
+extern inline void prune_one_dentry(struct dentry *);
+
+int free_slab_page(void *objp)
+{
+	struct slab *slabp = GET_PAGE_SLAB(virt_to_page(objp));
+	kmem_cache_t *cachep = GET_PAGE_CACHE(virt_to_page(objp));
+	int i;
+	int freed = 0;
+
+	for(i=0; i < cachep->num ; i++) {
+		struct dentry *target;
+		void *objp = slabp->s_mem + cachep->objsize * i;
+		target = (struct dentry *)objp;
+
+		/* XXX: race between i_am_alive check and lock acquision? */
+		if (target->i_am_alive != 0xdeadbeef)
+			continue;
+
+		spin_lock(&target->d_lock);
+
+		/* no additional references? nuke it */
+                if (!atomic_read(&target->d_count)) {
+			if (!list_empty(&target->d_lru)) {
+				dentry_stat.nr_unused--;
+				list_del_init(&target->d_lru);
+			}
+			prune_one_dentry(target);
+			freed++;
+		/* otherwise attempt to free children */
+                } else {
+			spin_unlock(&target->d_lock);
+			if (dentry_free_child(target)) {
+				if (!list_empty(&target->d_lru)) {
+					dentry_stat.nr_unused--;
+					list_del_init(&target->d_lru);
+				}
+				prune_one_dentry(target);
+				freed++;
+			} else
+				break;
+				
+		}
+        }
+
+	slab_free_attempt++;
+
+        if (i == cachep->num) {
+		slab_free_success++;
+		return 1;
+	}
+
+	return 0;
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
+
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
+
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
