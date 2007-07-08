From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 06/12] Slab defragmentation: Support dentry defragmentation
Date: Sat, 07 Jul 2007 20:05:44 -0700
Message-ID: <20070708030844.800426889@sgi.com>
References: <20070708030538.729027694@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755991AbXGHDJ2@vger.kernel.org>
Content-Disposition: inline; filename=slub_defrag_dentry
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-Id: linux-mm.kvack.org

get() uses the dcache lock and then works with dget_locked to obtain a
reference to the dentry. An additional complication is that the dentry
may be in process of being freed or it may just have been allocated.
We add an additional flag to d_flags to be able to determined the
status of an object.

kick() is called after get() has been used and after the slab has dropped
all of its own locks. The dentry pruning for unused entries works in a
straighforward way.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/dcache.c            |  113 +++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/dcache.h |    5 ++
 2 files changed, 110 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc4-mm2/fs/dcache.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/fs/dcache.c	2007-06-26 12:00:37.000000000 -0700
+++ linux-2.6.22-rc4-mm2/fs/dcache.c	2007-06-26 12:08:49.000000000 -0700
@@ -135,6 +135,7 @@ static struct dentry *d_kill(struct dent
 
 	list_del(&dentry->d_u.d_child);
 	dentry_stat.nr_dentry--;	/* For d_free, below */
+	dentry->d_flags &= ~DCACHE_ENTRY_VALID;
 	/*drops the locks, at that point nobody can reach this dentry */
 	dentry_iput(dentry);
 	parent = dentry->d_parent;
@@ -951,6 +952,7 @@ struct dentry *d_alloc(struct dentry * p
 	if (parent)
 		list_add(&dentry->d_u.d_child, &parent->d_subdirs);
 	dentry_stat.nr_dentry++;
+	dentry->d_flags |= DCACHE_ENTRY_VALID;
 	spin_unlock(&dcache_lock);
 
 	return dentry;
@@ -2108,18 +2110,113 @@ static void __init dcache_init_early(voi
 		INIT_HLIST_HEAD(&dentry_hashtable[loop]);
 }
 
+/*
+ * The slab is holding off frees. Thus we can safely examine
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
+		/*
+		 * if DCACHE_ENTRY_VALID is not set then the dentry
+		 * may be already in the process of being freed.
+		 */
+		if (!(dentry->d_flags & DCACHE_ENTRY_VALID))
+			v[i] = NULL;
+		else
+			dget_locked(dentry);
+	}
+	spin_unlock(&dcache_lock);
+	return 0;
+}
+
+/*
+ * Slab has dropped all the locks. Get rid of the
+ * refcount we obtained earlier and also rid of the
+ * object.
+ */
+static void kick_dentries(struct kmem_cache *s, int nr, void **v, void *private)
+{
+	struct dentry *dentry;
+	int abort = 0;
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
+	 * be freed. We  need the dcache_lock.
+	 */
+	spin_lock(&dcache_lock);
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		if (!dentry)
+			continue;
+
+		if (abort)
+			goto put_dentry;
+
+		spin_lock(&dentry->d_lock);
+		if (atomic_read(&dentry->d_count) > 1) {
+			/*
+			 * Reference count was increased. This means that we
+			 * cannot free one object which makes it impossible
+			 * to reclaim this slab. So it is best to abandon the
+			 * freeing of further objects.
+			 */
+			abort = 1;
+			spin_unlock(&dentry->d_lock);
+put_dentry:
+			spin_unlock(&dcache_lock);
+			dput(dentry);
+			spin_lock(&dcache_lock);
+			continue;
+		}
+
+		/* Remove from LRU */
+		if (!list_empty(&dentry->d_lru)) {
+			dentry_stat.nr_unused--;
+			list_del_init(&dentry->d_lru);
+		}
+		/* Drop the entry */
+		prune_one_dentry(dentry, 1);
+	}
+	spin_unlock(&dcache_lock);
+
+	/*
+	 * dentries are freed using RCU so we need to wait until RCU
+	 * operations arei complete
+	 */
+	if (!abort)
+		synchronize_rcu();
+}
+
+static struct kmem_cache_ops dentry_kmem_cache_ops = {
+	.get = get_dentries,
+	.kick = kick_dentries,
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
-	
+	dentry_cache = KMEM_CACHE_OPS(dentry,
+		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD,
+		&dentry_kmem_cache_ops);
+
 	register_shrinker(&dcache_shrinker);
 
 	/* Hash may have been set up in dcache_init_early */
Index: linux-2.6.22-rc4-mm2/include/linux/dcache.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/dcache.h	2007-06-26 12:00:37.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/dcache.h	2007-06-26 12:07:36.000000000 -0700
@@ -177,6 +177,11 @@ d_iput:		no		no		no       yes
 
 #define DCACHE_INOTIFY_PARENT_WATCHED	0x0020 /* Parent inode is watched */
 
+#define DCACHE_ENTRY_VALID	0x0040	/*
+					 * Entry is valid and not in the
+					 * process of being created or
+					 * destroyed.
+					 */
 extern spinlock_t dcache_lock;
 
 /**

-- 
