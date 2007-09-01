From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 23/26] dentries: Extract common code to remove dentry from lru
Date: Fri, 31 Aug 2007 18:41:30 -0700
Message-ID: <20070901014224.596352219@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0023-slab_defrag_dentry_remove_lru.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Extract the common code to remove a dentry from the lru into a new function
dentry_lru_remove().

Two call sites used list_del() instead of list_del_init(). AFAIK the
performance of both is the same. dentry_lru_remove() does a list_del_init().

As a result dentry->d_lru is now always empty when a dentry is freed.
A consistent state is useful to establish dentry state from slab defrag.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/dcache.c |   42 ++++++++++++++----------------------------
 1 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 678d39d..71e4877 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -95,6 +95,14 @@ static void d_free(struct dentry *dentry)
 		call_rcu(&dentry->d_u.d_rcu, d_callback);
 }
 
+static void dentry_lru_remove(struct dentry *dentry)
+{
+	if (!list_empty(&dentry->d_lru)) {
+		list_del_init(&dentry->d_lru);
+		dentry_stat.nr_unused--;
+	}
+}
+
 /*
  * Release the dentry's inode, using the filesystem
  * d_iput() operation if defined.
@@ -211,13 +219,7 @@ repeat:
 unhash_it:
 	__d_drop(dentry);
 kill_it:
-	/* If dentry was on d_lru list
-	 * delete it from there
-	 */
-	if (!list_empty(&dentry->d_lru)) {
-		list_del(&dentry->d_lru);
-		dentry_stat.nr_unused--;
-	}
+	dentry_lru_remove(dentry);
 	dentry = d_kill(dentry);
 	if (dentry)
 		goto repeat;
@@ -285,10 +287,7 @@ int d_invalidate(struct dentry * dentry)
 static inline struct dentry * __dget_locked(struct dentry *dentry)
 {
 	atomic_inc(&dentry->d_count);
-	if (!list_empty(&dentry->d_lru)) {
-		dentry_stat.nr_unused--;
-		list_del_init(&dentry->d_lru);
-	}
+	dentry_lru_remove(dentry);
 	return dentry;
 }
 
@@ -407,10 +406,7 @@ static void prune_one_dentry(struct dentry * dentry, int prune_parents)
 
 		if (dentry->d_op && dentry->d_op->d_delete)
 			dentry->d_op->d_delete(dentry);
-		if (!list_empty(&dentry->d_lru)) {
-			list_del(&dentry->d_lru);
-			dentry_stat.nr_unused--;
-		}
+		dentry_lru_remove(dentry);
 		__d_drop(dentry);
 		dentry = d_kill(dentry);
 		spin_lock(&dcache_lock);
@@ -600,10 +596,7 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 
 	/* detach this root from the system */
 	spin_lock(&dcache_lock);
-	if (!list_empty(&dentry->d_lru)) {
-		dentry_stat.nr_unused--;
-		list_del_init(&dentry->d_lru);
-	}
+	dentry_lru_remove(dentry);
 	__d_drop(dentry);
 	spin_unlock(&dcache_lock);
 
@@ -617,11 +610,7 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 			spin_lock(&dcache_lock);
 			list_for_each_entry(loop, &dentry->d_subdirs,
 					    d_u.d_child) {
-				if (!list_empty(&loop->d_lru)) {
-					dentry_stat.nr_unused--;
-					list_del_init(&loop->d_lru);
-				}
-
+				dentry_lru_remove(dentry);
 				__d_drop(loop);
 				cond_resched_lock(&dcache_lock);
 			}
@@ -803,10 +792,7 @@ resume:
 		struct dentry *dentry = list_entry(tmp, struct dentry, d_u.d_child);
 		next = tmp->next;
 
-		if (!list_empty(&dentry->d_lru)) {
-			dentry_stat.nr_unused--;
-			list_del_init(&dentry->d_lru);
-		}
+		dentry_lru_remove(dentry);
 		/* 
 		 * move only zero ref count dentries to the end 
 		 * of the unused list for prune_dcache
-- 
1.5.2.4

-- 
