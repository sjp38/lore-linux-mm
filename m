Date: Wed, 10 Apr 2002 20:04:15 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] kmem_cache_shrink return value
Message-ID: <20020410200415.A25542@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently kmem_cache_shrink returns 1 normally and 0 in the case all slabs
were released.  This is almost useless for normal use and in fact only one
user actually checked it.  This user (drivers/s390/ccwcache.c) shouldn't
have used kmem_cache_shrink in the first place and does even cause an OOPS
due to kmem_cache_destroy on a NUL-pointer if kmem_cache_shrink returned
0...

This patch instead makes kmem_cache_shrink return the number of pages
released to help the VM doing balancing.  The -rmap VM already uses this
(it has this patch already included) and one of akpm's comments in the -aa
split patches addresses the same issue.


diff -uNr -Xdontdiff linux-2.4.19-pre6/drivers/s390/ccwcache.c linux/drivers/s390/ccwcache.c
--- linux-2.4.19-pre6/drivers/s390/ccwcache.c	Thu Aug 30 17:27:25 2001
+++ linux/drivers/s390/ccwcache.c	Wed Apr 10 15:46:12 2002
@@ -291,9 +291,11 @@
 	/* Shrink the caches, if available */
 	for ( cachind = 0; cachind < CCW_NUMBER_CACHES; cachind ++ ) {
 		if ( ccw_cache[cachind] ) {
+#if 0 /* this is useless and could cause an OOPS in the worst case */
 			if ( kmem_cache_shrink(ccw_cache[cachind]) == 0 ) {
 				ccw_cache[cachind] = NULL;
 			}
+#endif
 			kmem_cache_destroy(ccw_cache[cachind]);
 		}
 	}
diff -uNr -Xdontdiff linux-2.4.19-pre6/fs/dcache.c linux/fs/dcache.c
--- linux-2.4.19-pre6/fs/dcache.c	Sun Mar 10 14:03:05 2002
+++ linux/fs/dcache.c	Wed Apr 10 15:46:12 2002
@@ -568,8 +568,7 @@
 	count = dentry_stat.nr_unused / priority;
 
 	prune_dcache(count);
-	kmem_cache_shrink(dentry_cache);
-	return 0;
+	return kmem_cache_shrink(dentry_cache);
 }
 
 #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
diff -uNr -Xdontdiff linux-2.4.19-pre6/fs/dquot.c linux/fs/dquot.c
--- linux-2.4.19-pre6/fs/dquot.c	Sun Mar 10 14:03:05 2002
+++ linux/fs/dquot.c	Wed Apr 10 15:46:12 2002
@@ -413,8 +413,7 @@
 	lock_kernel();
 	prune_dqcache(nr_free_dquots / (priority + 1));
 	unlock_kernel();
-	kmem_cache_shrink(dquot_cachep);
-	return 0;
+	return kmem_cache_shrink(dquot_cachep);
 }
 
 /* NOTE: If you change this function please check whether dqput_blocks() works right... */
diff -uNr -Xdontdiff linux-2.4.19-pre6/fs/inode.c linux/fs/inode.c
--- linux-2.4.19-pre6/fs/inode.c	Sun Mar 10 14:03:05 2002
+++ linux/fs/inode.c	Wed Apr 10 15:46:12 2002
@@ -725,8 +725,7 @@
 	count = inodes_stat.nr_unused / priority;
 
 	prune_icache(count);
-	kmem_cache_shrink(inode_cachep);
-	return 0;
+	return kmem_cache_shrink(inode_cachep);
 }
 
 /*
diff -uNr -Xdontdiff linux-2.4.19-pre6/mm/slab.c linux/mm/slab.c
--- linux-2.4.19-pre6/mm/slab.c	Sun Apr  7 22:30:09 2002
+++ linux/mm/slab.c	Wed Apr 10 15:48:33 2002
@@ -909,14 +909,13 @@
 #define drain_cpu_caches(cachep)	do { } while (0)
 #endif
 
-static int __kmem_cache_shrink(kmem_cache_t *cachep)
+/*
+ * Called with the &cachep->spinlock held, returns number of slabs released
+ */
+static int __kmem_cache_shrink_locked(kmem_cache_t *cachep)
 {
 	slab_t *slabp;
-	int ret;
-
-	drain_cpu_caches(cachep);
-
-	spin_lock_irq(&cachep->spinlock);
+	int ret = 0;
 
 	/* If the cache is growing, stop shrinking. */
 	while (!cachep->growing) {
@@ -935,9 +934,22 @@
 
 		spin_unlock_irq(&cachep->spinlock);
 		kmem_slab_destroy(cachep, slabp);
+		ret++;
 		spin_lock_irq(&cachep->spinlock);
 	}
-	ret = !list_empty(&cachep->slabs_full) || !list_empty(&cachep->slabs_partial);
+	return ret;
+}
+
+static int __kmem_cache_shrink(kmem_cache_t *cachep)
+{
+	int ret;
+
+	drain_cpu_caches(cachep);
+
+	spin_lock_irq(&cachep->spinlock);
+	__kmem_cache_shrink_locked(cachep);
+	ret = !list_empty(&cachep->slabs_full) ||
+		!list_empty(&cachep->slabs_partial);
 	spin_unlock_irq(&cachep->spinlock);
 	return ret;
 }
@@ -947,14 +959,22 @@
  * @cachep: The cache to shrink.
  *
  * Releases as many slabs as possible for a cache.
- * To help debugging, a zero exit status indicates all slabs were released.
+ * Returns number of pages released.
  */
 int kmem_cache_shrink(kmem_cache_t *cachep)
 {
+	int ret;
+
 	if (!cachep || in_interrupt() || !is_chained_kmem_cache(cachep))
 		BUG();
 
-	return __kmem_cache_shrink(cachep);
+	drain_cpu_caches(cachep);
+  
+	spin_lock_irq(&cachep->spinlock);
+	ret = __kmem_cache_shrink_locked(cachep);
+	spin_unlock_irq(&cachep->spinlock);
+
+	return ret << cachep->gfporder;
 }
 
 /**
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
