Content-Type: text/plain;
  charset="us-ascii"
From: Ed Tomlinson <tomlins@cam.org>
Subject: [PATCH] ageable slab callbacks
Date: Sun, 15 Sep 2002 14:36:20 -0400
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209151436.20171.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

Hi,

This lets the vm use callbacks to shrink ageable caches.   With this we avoid
having to change vmscan if an ageable cache family is added.  It also batches
calls to the prune methods (SHRINK_BATCH).

patch is against 34-mm1, which is the latest I can test with here (ide problems). 

I have set the DEFAULT_SEEKS to 2.  Lets see if the extra pressure helps.

Comments
Ed Tomlinson

---------- slab_callbacks_A0
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.627   -> 1.628  
#	         fs/dcache.c	1.30    -> 1.31   
#	         mm/vmscan.c	1.102   -> 1.103  
#	include/linux/slab.h	1.12    -> 1.13   
#	          fs/dquot.c	1.45    -> 1.46   
#	           mm/slab.c	1.27    -> 1.28   
#	          fs/inode.c	1.68    -> 1.69   
#	include/linux/dcache.h	1.16    -> 1.17   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/15	ed@oscar.et.ca	1.628
# Introduce callbacks to shrink ageable caches.  With this we do not
# have to change vmscan when we add a new cache family with its own 
# ageing method.  Note that these are not necessarily per cache.  For
# example there is one aging method used for all inode caches.
# --------------------------------------------
#
diff -Nru a/fs/dcache.c b/fs/dcache.c
--- a/fs/dcache.c	Sun Sep 15 14:28:45 2002
+++ b/fs/dcache.c	Sun Sep 15 14:28:45 2002
@@ -570,9 +570,9 @@
  * This is called from kswapd when we think we need some
  * more memory. 
  */
-int shrink_dcache_memory(int ratio, unsigned int gfp_mask)
+int shrink_dcache_memory(int nr, int ratio, unsigned int gfp_mask)
 {
-	int entries = dentry_stat.nr_dentry / ratio + 1;
+	nr += dentry_stat.nr_dentry / ratio + 1;
 	/*
 	 * Nasty deadlock avoidance.
 	 *
@@ -584,11 +584,11 @@
 	 * We should make sure we don't hold the superblock lock over
 	 * block allocations, but for now:
 	 */
-	if (!(gfp_mask & __GFP_FS))
-		return 0;
+	if (!(gfp_mask & __GFP_FS) | (nr < SHRINK_BATCH))
+		return nr;
 
-	prune_dcache(entries);
-	return entries;
+	prune_dcache(nr);
+	return 0;
 }
 
 #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
@@ -1328,6 +1328,8 @@
 					 NULL, NULL);
 	if (!dentry_cache)
 		panic("Cannot create dentry cache");
+	
+	kmem_set_shrinker(DEFAULT_SEEKS, shrink_dcache_memory);
 
 #if PAGE_SHIFT < 13
 	mempages >>= (13 - PAGE_SHIFT);
@@ -1401,6 +1403,8 @@
 			SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!dquot_cachep)
 		panic("Cannot create dquot SLAB cache");
+
+	kmem_set_shrinker(DEFAULT_SEEKS, shrink_dquot_memory);
 #endif
 
 	dcache_init(mempages);
diff -Nru a/fs/dquot.c b/fs/dquot.c
--- a/fs/dquot.c	Sun Sep 15 14:28:45 2002
+++ b/fs/dquot.c	Sun Sep 15 14:28:45 2002
@@ -483,14 +483,17 @@
  * more memory
  */
 
-int shrink_dqcache_memory(int ratio, unsigned int gfp_mask)
+int shrink_dqcache_memory(int nr, int ratio, unsigned int gfp_mask)
 {
-	int entries = dqstats.allocated_dquots / ratio + 1;
+	nr += dqstats.allocated_dquots / ratio + 1;
+
+	if (nr < SHRINK_BATCH)
+		return nr; 
 
 	lock_kernel();
-	prune_dqcache(entries);
+	prune_dqcache(nr);
 	unlock_kernel();
-	return entries;
+	return 0;
 }
 
 /*
diff -Nru a/fs/inode.c b/fs/inode.c
--- a/fs/inode.c	Sun Sep 15 14:28:45 2002
+++ b/fs/inode.c	Sun Sep 15 14:28:45 2002
@@ -417,9 +417,9 @@
  * This is called from kswapd when we think we need some
  * more memory. 
  */
-int shrink_icache_memory(int ratio, unsigned int gfp_mask)
+int shrink_icache_memory(int nr, int ratio, unsigned int gfp_mask)
 {
-	int entries = inodes_stat.nr_inodes / ratio + 1;
+	nr += inodes_stat.nr_inodes / ratio + 1;
 	/*
 	 * Nasty deadlock avoidance..
 	 *
@@ -427,11 +427,11 @@
 	 * want to recurse into the FS that called us
 	 * in clear_inode() and friends..
 	 */
-	if (!(gfp_mask & __GFP_FS))
-		return 0;
+	if (!(gfp_mask & __GFP_FS) | (nr < SHRINK_BATCH) )
+		return nr;
 
-	prune_icache(entries);
-	return entries;
+	prune_icache(nr);
+	return 0;
 }
 EXPORT_SYMBOL(shrink_icache_memory);
 
@@ -1096,4 +1096,6 @@
 					 NULL);
 	if (!inode_cachep)
 		panic("cannot create inode slab cache");
+
+	kmem_set_shrinker(DEFAULT_SEEKS, shrink_icache_memory);
 }
diff -Nru a/include/linux/dcache.h b/include/linux/dcache.h
--- a/include/linux/dcache.h	Sun Sep 15 14:28:45 2002
+++ b/include/linux/dcache.h	Sun Sep 15 14:28:45 2002
@@ -182,15 +182,15 @@
 extern int d_invalidate(struct dentry *);
 
 /* dcache memory management */
-extern int shrink_dcache_memory(int, unsigned int);
+extern int shrink_dcache_memory(int, int, unsigned int);
 extern void prune_dcache(int);
 
 /* icache memory management (defined in linux/fs/inode.c) */
-extern int shrink_icache_memory(int, unsigned int);
+extern int shrink_icache_memory(int, int, unsigned int);
 extern void prune_icache(int);
 
 /* quota cache memory management (defined in linux/fs/dquot.c) */
-extern int shrink_dqcache_memory(int, unsigned int);
+extern int shrink_dqcache_memory(int, int, unsigned int);
 
 /* only used at mount-time */
 extern struct dentry * d_alloc_root(struct inode *);
diff -Nru a/include/linux/slab.h b/include/linux/slab.h
--- a/include/linux/slab.h	Sun Sep 15 14:28:45 2002
+++ b/include/linux/slab.h	Sun Sep 15 14:28:45 2002
@@ -45,6 +45,8 @@
 #define SLAB_CTOR_ATOMIC	0x002UL		/* tell constructor it can't sleep */
 #define	SLAB_CTOR_VERIFY	0x004UL		/* tell constructor it's a verify call */
 
+typedef int (*kmem_shrinker_t)(int, int, unsigned int);
+
 /* prototypes */
 extern void kmem_cache_init(void);
 extern void kmem_cache_sizes_init(void);
@@ -61,6 +63,12 @@
 
 extern void *kmalloc(size_t, int);
 extern void kfree(const void *);
+
+#define SHRINK_BATCH 32
+#define DEFAULT_SEEKS 2
+
+extern void kmem_set_shrinker(int, kmem_shrinker_t);
+extern int kmem_do_shrinks(int, int, unsigned int);
 
 extern int FASTCALL(kmem_cache_reap(int));
 
diff -Nru a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c	Sun Sep 15 14:28:45 2002
+++ b/mm/slab.c	Sun Sep 15 14:28:45 2002
@@ -147,6 +147,23 @@
  * Needed to avoid a possible looping condition in kmem_cache_grow().
  */
 static unsigned long offslab_limit;
+ 
+/*
+ * shrinker_t
+ *
+ * Manages list of shrinker callbacks used by the vm to apply pressure to 
+ * prunable caches.
+ */
+
+typedef struct shrinker_s {
+	kmem_shrinker_t		shrinker;
+	struct list_head	next;
+	int 			seeks;	/* seeks to recreate an obj */
+	int			nr;	/* objs pending delete */ 
+} shrinker_t;
+		
+static	spinlock_t		shrinker_lock = SPIN_LOCK_UNLOCKED;
+static	struct list_head	shrinker_list;
 
 /*
  * slab_t
@@ -413,6 +430,42 @@
 static void enable_all_cpucaches (void);
 #endif
 
+/*
+ * Add a shrinker to be called from the vm
+ */
+void kmem_set_shrinker(int seeks, kmem_shrinker_t theshrinker)
+{
+	shrinker_t *shrinkerp;	
+	shrinkerp = kmalloc(sizeof(shrinker_t),GFP_KERNEL);	
+	BUG_ON(!shrinkerp);
+	shrinkerp->shrinker = theshrinker;
+	shrinkerp->seeks = seeks;
+	shrinkerp->nr = 0;
+	spin_lock(&shrinker_lock);
+	list_add(&shrinkerp->next, &shrinker_list);
+	spin_lock(&shrinker_lock);
+}
+
+/* Call the shrink functions to age shrinkable caches */
+int kmem_do_shrinks(int pages, int scanned,  unsigned int gfp_mask)
+{
+struct list_head *p;
+	int ratio;
+
+	spin_lock(&shrinker_lock);
+
+	list_for_each(p,&shrinker_list) {
+		shrinker_t *shrinkerp = list_entry(p, shrinker_t, next);
+		ratio = pages / (shrinkerp->seeks * scanned + 1) + 1;
+		shrinkerp->nr = (*shrinkerp->shrinker)(shrinkerp->nr, 
+					ratio, gfp_mask);
+	}
+
+	spin_unlock(&shrinker_lock);
+	
+	return 0;
+}
+
 /* Cal the num objs, wastage, and bytes left over for a given slab size. */
 static void kmem_cache_estimate (unsigned long gfporder, size_t size,
 		 int flags, size_t *left_over, unsigned int *num)
@@ -456,6 +509,9 @@
 
 	cache_cache.colour = left_over/cache_cache.colour_off;
 	cache_cache.colour_next = 0;
+
+	INIT_LIST_HEAD(&shrinker_list);
+	spin_lock_init(&shrinker_lock);
 }
 
 
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Sun Sep 15 14:28:45 2002
+++ b/mm/vmscan.c	Sun Sep 15 14:28:45 2002
@@ -607,7 +607,6 @@
 {
 	struct zone *first_classzone;
 	struct zone *zone;
-	int ratio;
 	int nr_mapped = 0;
 	int pages = nr_used_zone_pages();
 
@@ -652,10 +651,8 @@
 	 * If we're encountering mapped pages on the LRU then increase the
 	 * pressure on slab to avoid swapping.
 	 */
-	ratio = (pages / (*total_scanned + nr_mapped + 1)) + 1;
-	shrink_dcache_memory(ratio, gfp_mask);
-	shrink_icache_memory(ratio, gfp_mask);
-	shrink_dqcache_memory(ratio, gfp_mask);
+	kmem_do_shrinks(pages, *total_scanned + nr_mapped, gfp_mask);
+
 	return nr_pages;
 }
 

----------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
