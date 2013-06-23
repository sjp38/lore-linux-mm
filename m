Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 4933A6B0034
	for <linux-mm@kvack.org>; Sun, 23 Jun 2013 09:02:45 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id v20so224897lbc.3
        for <linux-mm@kvack.org>; Sun, 23 Jun 2013 06:02:43 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH] list_lru: remove special case function list_lru_dispose_all.
Date: Sun, 23 Jun 2013 09:02:24 -0400
Message-Id: <1371992544-17152-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: fs-devel <linux-fsdevel@vger.kernel.org>, Glauber Costa <glommer@openvz.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>

The list_lru implementation has one function, list_lru_dispose_all, with only
one user (the dentry code). At first, such function appears to make sense
because we are really not interested in the result of isolating each dentry
separately - all of them are going away anyway. However, it's implementation
is buggy in the following way:

When we call list_lru_dispose_all in fs/dcache.c, we scan all dentries marking
them with DCACHE_SHRINK_LIST. However, this is done without the nlru->lock
taken.  The imediate result of that is that someone else may add or remove the
dentry from the LRU at the same time. When list_lru_del happens in that
scenario we will see an element that is not yet marked with DCACHE_SHRINK_LIST
(even though it will be in the future) and obviously remove it from an lru
where the element no longer is. Since list_lru_dispose_all will in effect count
down nlru's  nr_items and list_lru_del will do the same, this will lead to an
imbalance.

The solution for this would not be so simple: we can obviously just keep the
lru_lock taken, but then we have no guarantees that we will be able to acquire
the dentry lock (dentry->d_lock). To properly solve this, we need a
communication mechanism between the lru and dentry code, so they can coordinate
this with each other.

Such mechanism already exists in the form of the list_lru_walk_cb callback. So
it is possible to construct a dcache-side prune function that does the right
thing only by calling list_lru_walk in a loop until no more dentries are
available.

With only one user, plus the fact that a sane solution for the problem would
involve boucing between dcache and list_lru anyway, I see little justification
to keep the special case list_lru_dispose_all in tree.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <dchinner@redhat.com>

---
Andrew and mhocko: I have noted this while searching for Michal's problem.
Because we are now more or less in agreement that he is seeing an inode and
not a dentry problem, I unfortunately don't believe this is a fix for what
he is seeing - specially given his bisect results. But it is a clear bug
nevertheless, and this one I can even trigger myself by constantly flushing
the dcache for a sb while randomly touching dentries.
---
 fs/dcache.c              | 49 ++++++++++++++++++++++++++++--------------------
 include/linux/list_lru.h | 17 -----------------
 mm/list_lru.c            | 42 -----------------------------------------
 3 files changed, 29 insertions(+), 79 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index d3feea1..341d633 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -912,27 +912,29 @@ long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
 	return freed;
 }
 
-/*
- * Mark all the dentries as on being the dispose list so we don't think they are
- * still on the LRU if we try to kill them from ascending the parent chain in
- * try_prune_one_dentry() rather than directly from the dispose list.
- */
-static void
-shrink_dcache_list(
-	struct list_head *dispose)
+static enum lru_status
+dentry_lru_isolate_shrink(struct list_head *item, spinlock_t *lru_lock, void *arg)
 {
-	struct dentry *dentry;
+	struct list_head *freeable = arg;
+	struct dentry	*dentry = container_of(item, struct dentry, d_lru);
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(dentry, dispose, d_lru) {
-		spin_lock(&dentry->d_lock);
-		dentry->d_flags |= DCACHE_SHRINK_LIST;
-		spin_unlock(&dentry->d_lock);
-	}
-	rcu_read_unlock();
-	shrink_dentry_list(dispose);
+	/*
+	 * we are inverting the lru lock/dentry->d_lock here,
+	 * so use a trylock. If we fail to get the lock, just skip
+	 * it
+	 */
+	if (!spin_trylock(&dentry->d_lock))
+		return LRU_SKIP;
+
+	dentry->d_flags |= DCACHE_SHRINK_LIST;
+	list_move_tail(&dentry->d_lru, freeable);
+	this_cpu_dec(nr_dentry_unused);
+	spin_unlock(&dentry->d_lock);
+
+	return LRU_REMOVED;
 }
 
+
 /**
  * shrink_dcache_sb - shrink dcache for a superblock
  * @sb: superblock
@@ -942,10 +944,17 @@ shrink_dcache_list(
  */
 void shrink_dcache_sb(struct super_block *sb)
 {
-	long disposed;
+	long freed;
 
-	disposed = list_lru_dispose_all(&sb->s_dentry_lru, shrink_dcache_list);
-	this_cpu_sub(nr_dentry_unused, disposed);
+	do {
+		LIST_HEAD(dispose);
+
+		freed = list_lru_walk(&sb->s_dentry_lru,
+			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
+
+		this_cpu_sub(nr_dentry_unused, freed);
+		shrink_dentry_list(&dispose);
+	} while (freed > 0);
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index ff57503..3ce5417 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -128,21 +128,4 @@ list_lru_walk(struct list_lru *lru, list_lru_walk_cb isolate,
 	}
 	return isolated;
 }
-
-typedef void (*list_lru_dispose_cb)(struct list_head *dispose_list);
-/**
- * list_lru_dispose_all: forceably flush all elements in an @lru
- * @lru: the lru pointer
- * @dispose: callback function to be called for each lru list.
- *
- * This function will forceably isolate all elements into the dispose list, and
- * call the @dispose callback to flush the list. Please note that the callback
- * should expect items in any state, clean or dirty, and be able to flush all of
- * them.
- *
- * Return value: how many objects were freed. It should be equal to all objects
- * in the list_lru.
- */
-unsigned long
-list_lru_dispose_all(struct list_lru *lru, list_lru_dispose_cb dispose);
 #endif /* _LRU_LIST_H */
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 700d322..8447a56 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -118,48 +118,6 @@ restart:
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-static unsigned long list_lru_dispose_all_node(struct list_lru *lru, int nid,
-					       list_lru_dispose_cb dispose)
-{
-	struct list_lru_node	*nlru = &lru->node[nid];
-	LIST_HEAD(dispose_list);
-	unsigned long disposed = 0;
-
-	spin_lock(&nlru->lock);
-	while (!list_empty(&nlru->list)) {
-		list_splice_init(&nlru->list, &dispose_list);
-		disposed += nlru->nr_items;
-		nlru->nr_items = 0;
-		node_clear(nid, lru->active_nodes);
-		spin_unlock(&nlru->lock);
-
-		dispose(&dispose_list);
-
-		spin_lock(&nlru->lock);
-	}
-	spin_unlock(&nlru->lock);
-	return disposed;
-}
-
-unsigned long list_lru_dispose_all(struct list_lru *lru,
-				   list_lru_dispose_cb dispose)
-{
-	unsigned long disposed;
-	unsigned long total = 0;
-	int nid;
-
-	do {
-		disposed = 0;
-		for_each_node_mask(nid, lru->active_nodes) {
-			disposed += list_lru_dispose_all_node(lru, nid,
-							      dispose);
-		}
-		total += disposed;
-	} while (disposed != 0);
-
-	return total;
-}
-
 int list_lru_init(struct list_lru *lru)
 {
 	int i;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
