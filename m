Message-Id: <20070504221708.828954952@sgi.com>
References: <20070504221555.642061626@sgi.com>
Date: Fri, 04 May 2007 15:15:58 -0700
From: clameter@sgi.com
Subject: [RFC 3/3] Support targeted reclaim and slab defrag for dentry cache
Content-Disposition: inline; filename=dcache_targetd_reclaim
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is an experimental patch for locking review only. I am not that
familiar with dentry cache locking.

We setup the dcache cache a bit differently using the new APIs and
define a get_reference and kick_object() function for the dentry cache.

get_dentry_reference simply works by incrementing the dentry refcount
if its not already zero. If it is zero then the slab called us while
another processor is in the process of freeing the object. The other
process will finish this free as soon as we return from this call. So
we have to fail.

kick_dentry_object() is called after get_dentry_reference() has
been used and after the slab has dropped all of its own locks.
Trying to use the dentry pruning here. Hope that is correct.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/dcache.c        |   48 +++++++++++++++++++++++++++++++++++++++---------
 include/linux/fs.h |    2 +-
 2 files changed, 40 insertions(+), 10 deletions(-)

Index: slub/fs/dcache.c
===================================================================
--- slub.orig/fs/dcache.c	2007-05-04 13:32:15.000000000 -0700
+++ slub/fs/dcache.c	2007-05-04 13:55:39.000000000 -0700
@@ -2133,17 +2133,48 @@ static void __init dcache_init_early(voi
 		INIT_HLIST_HEAD(&dentry_hashtable[loop]);
 }
 
+/*
+ * The slab is holding locks on the current slab. We can just
+ * get a reference
+ */
+int get_dentry_reference(void *private)
+{
+	struct dentry *dentry = private;
+
+	return atomic_inc_not_zero(&dentry->d_count);
+}
+
+/*
+ * Slab has dropped all the locks. Get rid of the
+ * refcount we obtained earlier and also rid of the
+ * object.
+ */
+void kick_dentry_object(void *private)
+{
+	struct dentry *dentry = private;
+
+	spin_lock(&dentry->d_lock);
+	if (atomic_read(&dentry->d_count) > 1) {
+		spin_unlock(&dentry->d_lock);
+		dput(dentry);
+	}
+	spin_lock(&dcache_lock);
+	prune_one_dentry(dentry, 1);
+	spin_unlock(&dcache_lock);
+}
+
+struct slab_ops dentry_slab_ops = {
+	.get_reference = get_dentry_reference,
+	.kick_object = kick_dentry_object
+};
+
 static void __init dcache_init(unsigned long mempages)
 {
 	int loop;
 
-	/* 
-	 * A constructor could be added for stable state like the lists,
-	 * but it is probably not worth it because of the cache nature
-	 * of the dcache. 
-	 */
-	dentry_cache = KMEM_CACHE(dentry,
-		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
+	dentry_cache = KMEM_CACHE_OPS(dentry,
+		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD,
+		&dentry_slab_ops);
 
 	register_shrinker(&dcache_shrinker);
 
@@ -2192,8 +2223,7 @@ void __init vfs_caches_init(unsigned lon
 	names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 
-	filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
+	filp_cachep = KMEM_CACHE(file, SLAB_PANIC);
 
 	dcache_init(mempages);
 	inode_init(mempages);
Index: slub/include/linux/fs.h
===================================================================
--- slub.orig/include/linux/fs.h	2007-05-04 13:32:15.000000000 -0700
+++ slub/include/linux/fs.h	2007-05-04 13:55:39.000000000 -0700
@@ -785,7 +785,7 @@ struct file {
 	spinlock_t		f_ep_lock;
 #endif /* #ifdef CONFIG_EPOLL */
 	struct address_space	*f_mapping;
-};
+} ____cacheline_aligned;
 extern spinlock_t files_lock;
 #define file_list_lock() spin_lock(&files_lock);
 #define file_list_unlock() spin_unlock(&files_lock);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
