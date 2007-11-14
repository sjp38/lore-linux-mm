Message-Id: <20071114221023.063979083@sgi.com>
References: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:21 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 15/17] dentries: Add constructor
Content-Disposition: inline; filename=0061-dentries-Add-constructor.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

In order to support defragmentation on the dentry cache we need to have
a determined object state at all times. Without a constructor the object
would have a random state after allocation.

So provide a constructor.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/dcache.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

Index: linux-2.6.24-rc2-mm1/fs/dcache.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/fs/dcache.c	2007-11-14 11:08:36.048011768 -0800
+++ linux-2.6.24-rc2-mm1/fs/dcache.c	2007-11-14 12:20:18.034093692 -0800
@@ -871,6 +871,16 @@ static struct shrinker dcache_shrinker =
 	.seeks = DEFAULT_SEEKS,
 };
 
+void dcache_ctor(struct kmem_cache *s, void *p)
+{
+	struct dentry *dentry = p;
+
+	spin_lock_init(&dentry->d_lock);
+	dentry->d_inode = NULL;
+	INIT_LIST_HEAD(&dentry->d_lru);
+	INIT_LIST_HEAD(&dentry->d_alias);
+}
+
 /**
  * d_alloc	-	allocate a dcache entry
  * @parent: parent of entry to allocate
@@ -908,8 +918,6 @@ struct dentry *d_alloc(struct dentry * p
 
 	atomic_set(&dentry->d_count, 1);
 	dentry->d_flags = DCACHE_UNHASHED;
-	spin_lock_init(&dentry->d_lock);
-	dentry->d_inode = NULL;
 	dentry->d_parent = NULL;
 	dentry->d_sb = NULL;
 	dentry->d_op = NULL;
@@ -919,9 +927,7 @@ struct dentry *d_alloc(struct dentry * p
 	dentry->d_cookie = NULL;
 #endif
 	INIT_HLIST_NODE(&dentry->d_hash);
-	INIT_LIST_HEAD(&dentry->d_lru);
 	INIT_LIST_HEAD(&dentry->d_subdirs);
-	INIT_LIST_HEAD(&dentry->d_alias);
 
 	if (parent) {
 		dentry->d_parent = dget(parent);
@@ -2102,14 +2108,10 @@ static void __init dcache_init(void)
 {
 	int loop;
 
-	/* 
-	 * A constructor could be added for stable state like the lists,
-	 * but it is probably not worth it because of the cache nature
-	 * of the dcache. 
-	 */
-	dentry_cache = KMEM_CACHE(dentry,
-		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
-	
+	dentry_cache = kmem_cache_create("dentry_cache", sizeof(struct dentry),
+		0, SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD,
+		dcache_ctor);
+
 	register_shrinker(&dcache_shrinker);
 
 	/* Hash may have been set up in dcache_init_early */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
