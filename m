Date: Thu, 6 Oct 2005 16:27:39 +1000
From: David Chinner <dgc@sgi.com>
Subject: [PATCH] dcache: separate slab for directory dentries
Message-ID: <20051006062739.GP9519161@melbourne.sgi.com>
References: <20050911105709.GA16369@thunk.org> <20050911120045.GA4477@in.ibm.com> <20050912031636.GB16758@thunk.org> <20050913084752.GC4474@in.ibm.com> <20050913215932.GA1654338@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050913215932.GA1654338@melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
From: gnb@sgi.com
Return-Path: <owner-linux-mm@kvack.org>
To: Bharata B Rao <bharata@in.ibm.com>
Cc: Dipankar Sarma <dipankar@in.ibm.com>, linux-mm@kvack.org, gnb@sgi.com
List-ID: <linux-mm.kvack.org>

Separate out directory dentries into a separate slab so that
(potentially) longer lived dentries are clustered together rather
than sparsely distributed around the dentry slab cache.

Originally written for 2.6.5 by Greg Banks.

Signed-off-by: Greg Banks (gnb@sgi.com)
Signed-off-by: Dave Chinner (dgc@sgi.com)
---

Reference: http://marc.theaimsgroup.com/?l=linux-mm&m=112664896809759&w=2

 fs/dcache.c            |  100 ++++++++++++++++++++++++++++++++++++++++++++-----
 include/linux/dcache.h |    1 
 2 files changed, 91 insertions(+), 10 deletions(-)

--- 2.6.x-xfs.orig/include/linux/dcache.h	2005-10-06 12:41:12.000000000 +1000
+++ 2.6.x-xfs/include/linux/dcache.h	2005-10-06 10:51:31.825645594 +1000
@@ -155,6 +155,7 @@
 
 #define DCACHE_REFERENCED	0x0008  /* Recently used, don't discard. */
 #define DCACHE_UNHASHED		0x0010	
+#define DCACHE_DIRSLAB    	0x0040  /* allocated in the dir memcache */
 
 extern spinlock_t dcache_lock;
 
--- 2.6.x-xfs.orig/fs/dcache.c	2005-10-06 12:41:12.000000000 +1000
+++ 2.6.x-xfs/fs/dcache.c	2005-10-06 11:02:12.986649700 +1000
@@ -45,6 +45,7 @@
 EXPORT_SYMBOL(dcache_lock);
 
 static kmem_cache_t *dentry_cache; 
+static kmem_cache_t *dentry_dir_cache; 
 
 #define DNAME_INLINE_LEN (sizeof(struct dentry)-offsetof(struct dentry,d_iname))
 
@@ -75,7 +76,8 @@
 
 	if (dname_external(dentry))
 		kfree(dentry->d_name.name);
-	kmem_cache_free(dentry_cache, dentry); 
+	kmem_cache_free((dentry->d_flags & DCACHE_DIRSLAB) ? 
+	    	    	    dentry_dir_cache : dentry_cache, dentry);
 }
 
 /*
@@ -707,7 +709,7 @@
 }
 
 /**
- * d_alloc	-	allocate a dcache entry
+ * __d_alloc	-	allocate a dcache entry
  * @parent: parent of entry to allocate
  * @name: qstr of the name
  *
@@ -716,19 +718,22 @@
  * copied and the copy passed in may be reused after this call.
  */
  
-struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
+static struct dentry * __d_alloc(struct dentry * parent,
+				 const struct qstr *name, int flags)
 {
 	struct dentry *dentry;
 	char *dname;
+	kmem_cache_t *cache;
 
-	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL); 
+	cache = (flags & DCACHE_DIRSLAB) ? dentry_dir_cache : dentry_cache;
+	dentry = kmem_cache_alloc(cache, GFP_KERNEL); 
 	if (!dentry)
 		return NULL;
 
 	if (name->len > DNAME_INLINE_LEN-1) {
 		dname = kmalloc(name->len + 1, GFP_KERNEL);
 		if (!dname) {
-			kmem_cache_free(dentry_cache, dentry); 
+			kmem_cache_free(cache, dentry); 
 			return NULL;
 		}
 	} else  {
@@ -742,7 +747,7 @@
 	dname[name->len] = 0;
 
 	atomic_set(&dentry->d_count, 1);
-	dentry->d_flags = DCACHE_UNHASHED;
+	dentry->d_flags = (DCACHE_UNHASHED | flags);
 	spin_lock_init(&dentry->d_lock);
 	dentry->d_inode = NULL;
 	dentry->d_parent = NULL;
@@ -782,6 +787,69 @@
 	return d_alloc(parent, &q);
 }
 
+struct dentry * d_alloc(struct dentry * parent, const struct qstr *name)
+{
+	return __d_alloc(parent, name, 0);
+}
+
+/*
+ * Allocate a new dentry which will be suitable for the given inode
+ */
+static struct dentry * d_alloc_for_inode(struct dentry * parent,
+					 const struct qstr *name,
+					 struct inode *inode)
+{
+	int flags = 0;
+	
+	if (inode && S_ISDIR(inode->i_mode))
+		flags |= DCACHE_DIRSLAB;
+
+	return __d_alloc(parent, name, flags);
+}
+
+/*
+ * If the given dentry is not suitable for the inode, reallocate
+ * it, copy across the dentry's data and return the new one.  Only
+ * useful when the dentry has not yet been attached to inode or
+ * hashed, which is why it's a lot simpler than d_move().  Returns
+ * NULL if the dentry is suitable,  Called with dcache_lock, drops
+ * and regains.
+ */
+static struct dentry * d_realloc_for_inode(struct dentry * dentry,
+					   struct inode *inode)
+{
+	int flags = 0;
+	struct dentry *new;
+	struct dentry *parent;
+	
+	BUG_ON(dentry == NULL);
+	BUG_ON(dentry->d_inode != NULL);
+	BUG_ON(inode == NULL);
+	BUG_ON(dentry->d_parent == NULL || dentry->d_parent == dentry);
+
+	if (S_ISDIR(inode->i_mode))
+		flags |= DCACHE_DIRSLAB;
+	if ((flags & DCACHE_DIRSLAB) == (dentry->d_flags & DCACHE_DIRSLAB))
+		return NULL;	/* dentry is suitable */
+
+	parent = dentry->d_parent;
+	list_del_init(&dentry->d_child);
+
+	spin_unlock(&dcache_lock);
+	
+	new = __d_alloc(parent, &dentry->d_name, dentry->d_flags | flags);
+
+	spin_lock(&dcache_lock);
+
+	BUG_ON(new == NULL);	/* TODO */
+	if (new) {
+//		new->d_op = dentry->d_op;
+//		new->d_fsdata = dentry->d_fsdata;
+	}
+	
+	return new;
+}
+
 /**
  * d_instantiate - fill in inode information for a dentry
  * @entry: dentry to complete
@@ -872,7 +940,7 @@
 	if (root_inode) {
 		static const struct qstr name = { .name = "/", .len = 1 };
 
-		res = d_alloc(NULL, &name);
+		res = d_alloc_for_inode(NULL, &name, root_inode);
 		if (res) {
 			res->d_sb = root_inode->i_sb;
 			res->d_parent = res;
@@ -921,7 +989,7 @@
 		return res;
 	}
 
-	tmp = d_alloc(NULL, &anonstring);
+	tmp = d_alloc_for_inode(NULL, &anonstring, inode);
 	if (!tmp)
 		return NULL;
 
@@ -987,6 +1055,8 @@
 			iput(inode);
 		} else {
 			/* d_instantiate takes dcache_lock, so we do it by hand */
+			if ((new = d_realloc_for_inode(dentry, inode)))
+				dentry = new;
 			list_add(&dentry->d_alias, &inode->i_dentry);
 			dentry->d_inode = inode;
 			spin_unlock(&dcache_lock);
@@ -1014,7 +1084,7 @@
  * To avoid races with d_move while rename is happening, d_lock is used.
  *
  * Overflows in memcmp(), while d_move, are avoided by keeping the length
- * and name pointer in one structure pointed by d_qstr.
+ * and name pointer in one structure pointed by d_name.
  *
  * rcu_read_lock() and rcu_read_unlock() are used to disable preemption while
  * lookup is going on.
@@ -1121,7 +1191,8 @@
 	struct hlist_node *lhp;
 
 	/* Check whether the ptr might be valid at all.. */
-	if (!kmem_ptr_validate(dentry_cache, dentry))
+	if (!kmem_ptr_validate(dentry_cache, dentry) &&
+	    !kmem_ptr_validate(dentry_dir_cache, dentry))
 		goto out;
 
 	if (dentry->d_parent != dparent)
@@ -1687,6 +1758,15 @@
 					 SLAB_RECLAIM_ACCOUNT|SLAB_PANIC,
 					 NULL, NULL);
 	
+	dentry_dir_cache = kmem_cache_create("dentry_dir_cache",
+					 sizeof(struct dentry),
+					 0,
+					 SLAB_RECLAIM_ACCOUNT,
+					 NULL, NULL);
+	if (!dentry_dir_cache)
+		panic("Cannot create dentry dir cache");
+	
+
 	set_shrinker(DEFAULT_SEEKS, shrink_dcache_memory);
 
 	/* Hash may have been set up in dcache_init_early */

-- 
Dave Chinner
R&D Software Enginner
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
