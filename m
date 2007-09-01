From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 25/26] dentries: dentry defragmentation
Date: Fri, 31 Aug 2007 18:41:32 -0700
Message-ID: <20070901014225.046839422@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0025-slab_defrag_dentry_defrag.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

kick() is called after get() has been used and after the slab has dropped
all of its own locks. The dentry pruning for unused entries works in a
straightforward way.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/dcache.c |  100 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 99 insertions(+), 1 deletion(-)

Index: linux-2.6/fs/dcache.c
===================================================================
--- linux-2.6.orig/fs/dcache.c	2007-08-29 18:55:21.000000000 -0700
+++ linux-2.6/fs/dcache.c	2007-08-29 18:57:51.000000000 -0700
@@ -143,7 +143,10 @@ static struct dentry *d_kill(struct dent
 
 	list_del(&dentry->d_u.d_child);
 	dentry_stat.nr_dentry--;	/* For d_free, below */
-	/*drops the locks, at that point nobody can reach this dentry */
+	/*
+	 * drops the locks, at that point nobody (aside from defrag)
+	 * can reach this dentry
+	 */
 	dentry_iput(dentry);
 	parent = dentry->d_parent;
 	d_free(dentry);
@@ -2100,6 +2103,100 @@ static void __init dcache_init_early(voi
 		INIT_HLIST_HEAD(&dentry_hashtable[loop]);
 }
 
+/*
+ * The slab allocator is holding off frees. We can safely examine
+ * the object without the danger of it vanishing from under us.
+ */
+static void *get_dentries(struct kmem_cache *s, int nr, void **v)
+{
+	struct dentry *dentry;
+	int i;
+
+	spin_lock(&dcache_lock);
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+
+		/*
+		 * Three sorts of dentries cannot be reclaimed:
+		 *
+		 * 1. dentries that are in the process of being allocated
+		 *    or being freed. In that case the dentry is neither
+		 *    on the LRU nor hashed.
+		 *
+		 * 2. Fake hashed entries as used for anonymous dentries
+		 *    and pipe I/O. The fake hashed entries have d_flags
+		 *    set to indicate a hashed entry. However, the
+		 *    d_hash field indicates that the entry is not hashed.
+		 *
+		 * 3. dentries that have a backing store that is not
+		 *    writable. This is true for tmpsfs and other in
+		 *    memory filesystems. Removing dentries from them
+		 *    would loose dentries for good.
+		 */
+		if ((d_unhashed(dentry) && list_empty(&dentry->d_lru)) ||
+		   (!d_unhashed(dentry) && hlist_unhashed(&dentry->d_hash)) ||
+		   (dentry->d_inode &&
+		   !mapping_cap_writeback_dirty(dentry->d_inode->i_mapping)))
+		   	/* Ignore this dentry */
+			v[i] = NULL;
+		else
+			/* dget_locked will remove the dentry from the LRU */
+			dget_locked(dentry);
+	}
+	spin_unlock(&dcache_lock);
+	return NULL;
+}
+
+/*
+ * Slab has dropped all the locks. Get rid of the refcount obtained
+ * earlier and also free the object.
+ */
+static void kick_dentries(struct kmem_cache *s,
+				int nr, void **v, void *private)
+{
+	struct dentry *dentry;
+	int i;
+
+	/*
+	 * First invalidate the dentries without holding the dcache lock
+	 */
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+
+		if (dentry)
+			d_invalidate(dentry);
+	}
+
+	/*
+	 * If we are the last one holding a reference then the dentries can
+	 * be freed. We need the dcache_lock.
+	 */
+	spin_lock(&dcache_lock);
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		if (!dentry)
+			continue;
+
+		spin_lock(&dentry->d_lock);
+		if (atomic_read(&dentry->d_count) > 1) {
+			spin_unlock(&dentry->d_lock);
+			spin_unlock(&dcache_lock);
+			dput(dentry);
+			spin_lock(&dcache_lock);
+			continue;
+		}
+
+		prune_one_dentry(dentry, 1);
+	}
+	spin_unlock(&dcache_lock);
+
+	/*
+	 * dentries are freed using RCU so we need to wait until RCU
+	 * operations are complete
+	 */
+	synchronize_rcu();
+}
+
 static void __init dcache_init(unsigned long mempages)
 {
 	int loop;
@@ -2109,6 +2206,7 @@ static void __init dcache_init(unsigned 
 		dcache_ctor);
 
 	register_shrinker(&dcache_shrinker);
+	kmem_cache_setup_defrag(dentry_cache, get_dentries, kick_dentries);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)

-- 
