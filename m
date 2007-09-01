From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 24/26] dentries: Add constructor
Date: Fri, 31 Aug 2007 18:41:31 -0700
Message-ID: <20070901014224.822197100@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0024-slab_defrag_dentry_state.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

In order to support defragmentation on the dentry cache we need to have
an determined object state at all times. Without a destructor the object
would have a random state after allocation.

So provide a constructor.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/dcache.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 71e4877..282a467 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -874,6 +874,16 @@ static struct shrinker dcache_shrinker = {
 	.seeks = DEFAULT_SEEKS,
 };
 
+void dcache_ctor(void *p, struct kmem_cache *s, unsigned long flags)
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
@@ -911,8 +921,6 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 
 	atomic_set(&dentry->d_count, 1);
 	dentry->d_flags = DCACHE_UNHASHED;
-	spin_lock_init(&dentry->d_lock);
-	dentry->d_inode = NULL;
 	dentry->d_parent = NULL;
 	dentry->d_sb = NULL;
 	dentry->d_op = NULL;
@@ -922,9 +930,7 @@ struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
 	dentry->d_cookie = NULL;
 #endif
 	INIT_HLIST_NODE(&dentry->d_hash);
-	INIT_LIST_HEAD(&dentry->d_lru);
 	INIT_LIST_HEAD(&dentry->d_subdirs);
-	INIT_LIST_HEAD(&dentry->d_alias);
 
 	if (parent) {
 		dentry->d_parent = dget(parent);
@@ -2098,14 +2104,10 @@ static void __init dcache_init(unsigned long mempages)
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
1.5.2.4

-- 
