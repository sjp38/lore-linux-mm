Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 069496B0037
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:34 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 05/25] dcache: remove dentries from LRU before putting on dispose list
Date: Fri,  7 Jun 2013 00:34:38 +0400
Message-Id: <1370550898-26711-6-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>

From: Dave Chinner <dchinner@redhat.com>

One of the big problems with modifying the way the dcache shrinker
and LRU implementation works is that the LRU is abused in several
ways. One of these is shrink_dentry_list().

Basically, we can move a dentry off the LRU onto a different list
without doing any accounting changes, and then use dentry_lru_prune()
to remove it from what-ever list it is now on to do the LRU
accounting at that point.

This makes it -really hard- to change the LRU implementation. The
use of the per-sb LRU lock serialises movement of the dentries
between the different lists and the removal of them, and this is the
only reason that it works. If we want to break up the dentry LRU
lock and lists into, say, per-node lists, we remove the only
serialisation that allows this lru list/dispose list abuse to work.

To make this work effectively, the dispose list has to be isolated
from the LRU list - dentries have to be removed from the LRU
*before* being placed on the dispose list. This means that the LRU
accounting and isolation is completed before disposal is started,
and that means we can change the LRU implementation freely in
future.

This means that dentries *must* be marked with DCACHE_SHRINK_LIST
when they are placed on the dispose list so that we don't think that
parent dentries found in try_prune_one_dentry() are on the LRU when
the are actually on the dispose list. This would result in
accounting the dentry to the LRU a second time. Hence
dentry_lru_del() has to handle the DCACHE_SHRINK_LIST case
differently because the dentry isn't on the LRU list.

[ v2: don't decrement nr unused twice, spotted by Sha Zhengju ]
[ v7: (dchinner)
- shrink list leaks dentries when inode/parent can't be locked in
  dentry_kill().
- remove the readdition of dentry_lru_prune(). ]

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
---
 fs/dcache.c | 98 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 77 insertions(+), 21 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 0a49669..16b599e 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -327,7 +327,7 @@ static void dentry_unlink_inode(struct dentry * dentry)
 }
 
 /*
- * dentry_lru_(add|del|prune|move_tail) must be called with d_lock held.
+ * dentry_lru_(add|del|move_list) must be called with d_lock held.
  */
 static void dentry_lru_add(struct dentry *dentry)
 {
@@ -343,16 +343,25 @@ static void dentry_lru_add(struct dentry *dentry)
 static void __dentry_lru_del(struct dentry *dentry)
 {
 	list_del_init(&dentry->d_lru);
-	dentry->d_flags &= ~DCACHE_SHRINK_LIST;
 	dentry->d_sb->s_nr_dentry_unused--;
 	this_cpu_dec(nr_dentry_unused);
 }
 
 /*
  * Remove a dentry with references from the LRU.
+ *
+ * If we are on the shrink list, then we can get to try_prune_one_dentry() and
+ * lose our last reference through the parent walk. In this case, we need to
+ * remove ourselves from the shrink list, not the LRU.
  */
 static void dentry_lru_del(struct dentry *dentry)
 {
+	if (dentry->d_flags & DCACHE_SHRINK_LIST) {
+		list_del_init(&dentry->d_lru);
+		dentry->d_flags &= ~DCACHE_SHRINK_LIST;
+		return;
+	}
+
 	if (!list_empty(&dentry->d_lru)) {
 		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 		__dentry_lru_del(dentry);
@@ -362,13 +371,15 @@ static void dentry_lru_del(struct dentry *dentry)
 
 static void dentry_lru_move_list(struct dentry *dentry, struct list_head *list)
 {
+	BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
+
 	spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 	if (list_empty(&dentry->d_lru)) {
 		list_add_tail(&dentry->d_lru, list);
-		dentry->d_sb->s_nr_dentry_unused++;
-		this_cpu_inc(nr_dentry_unused);
 	} else {
 		list_move_tail(&dentry->d_lru, list);
+		dentry->d_sb->s_nr_dentry_unused--;
+		this_cpu_dec(nr_dentry_unused);
 	}
 	spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
 }
@@ -466,7 +477,8 @@ EXPORT_SYMBOL(d_drop);
  * If ref is non-zero, then decrement the refcount too.
  * Returns dentry requiring refcount drop, or NULL if we're done.
  */
-static inline struct dentry *dentry_kill(struct dentry *dentry, int ref)
+static inline struct dentry *
+dentry_kill(struct dentry *dentry, int ref, int unlock_on_failure)
 	__releases(dentry->d_lock)
 {
 	struct inode *inode;
@@ -475,8 +487,10 @@ static inline struct dentry *dentry_kill(struct dentry *dentry, int ref)
 	inode = dentry->d_inode;
 	if (inode && !spin_trylock(&inode->i_lock)) {
 relock:
-		spin_unlock(&dentry->d_lock);
-		cpu_relax();
+		if (unlock_on_failure) {
+			spin_unlock(&dentry->d_lock);
+			cpu_relax();
+		}
 		return dentry; /* try again with same dentry */
 	}
 	if (IS_ROOT(dentry))
@@ -563,7 +577,7 @@ repeat:
 	return;
 
 kill_it:
-	dentry = dentry_kill(dentry, 1);
+	dentry = dentry_kill(dentry, 1, 1);
 	if (dentry)
 		goto repeat;
 }
@@ -762,12 +776,12 @@ EXPORT_SYMBOL(d_prune_aliases);
  *
  * This may fail if locks cannot be acquired no problem, just try again.
  */
-static void try_prune_one_dentry(struct dentry *dentry)
+static struct dentry * try_prune_one_dentry(struct dentry *dentry)
 	__releases(dentry->d_lock)
 {
 	struct dentry *parent;
 
-	parent = dentry_kill(dentry, 0);
+	parent = dentry_kill(dentry, 0, 0);
 	/*
 	 * If dentry_kill returns NULL, we have nothing more to do.
 	 * if it returns the same dentry, trylocks failed. In either
@@ -779,9 +793,9 @@ static void try_prune_one_dentry(struct dentry *dentry)
 	 * fragmentation.
 	 */
 	if (!parent)
-		return;
+		return NULL;
 	if (parent == dentry)
-		return;
+		return dentry;
 
 	/* Prune ancestors. */
 	dentry = parent;
@@ -790,10 +804,11 @@ static void try_prune_one_dentry(struct dentry *dentry)
 		if (dentry->d_count > 1) {
 			dentry->d_count--;
 			spin_unlock(&dentry->d_lock);
-			return;
+			return NULL;
 		}
-		dentry = dentry_kill(dentry, 1);
+		dentry = dentry_kill(dentry, 1, 1);
 	}
+	return NULL;
 }
 
 static void shrink_dentry_list(struct list_head *list)
@@ -812,21 +827,31 @@ static void shrink_dentry_list(struct list_head *list)
 		}
 
 		/*
+		 * The dispose list is isolated and dentries are not accounted
+		 * to the LRU here, so we can simply remove it from the list
+		 * here regardless of whether it is referenced or not.
+		 */
+		list_del_init(&dentry->d_lru);
+		dentry->d_flags &= ~DCACHE_SHRINK_LIST;
+
+		/*
 		 * We found an inuse dentry which was not removed from
-		 * the LRU because of laziness during lookup.  Do not free
-		 * it - just keep it off the LRU list.
+		 * the LRU because of laziness during lookup. Do not free it.
 		 */
 		if (dentry->d_count) {
-			dentry_lru_del(dentry);
 			spin_unlock(&dentry->d_lock);
 			continue;
 		}
-
 		rcu_read_unlock();
 
-		try_prune_one_dentry(dentry);
+		dentry = try_prune_one_dentry(dentry);
 
 		rcu_read_lock();
+		if (dentry) {
+			dentry->d_flags |= DCACHE_SHRINK_LIST;
+			list_add(&dentry->d_lru, list);
+			spin_unlock(&dentry->d_lock);
+		}
 	}
 	rcu_read_unlock();
 }
@@ -867,8 +892,10 @@ relock:
 			list_move(&dentry->d_lru, &referenced);
 			spin_unlock(&dentry->d_lock);
 		} else {
-			list_move_tail(&dentry->d_lru, &tmp);
+			list_move(&dentry->d_lru, &tmp);
 			dentry->d_flags |= DCACHE_SHRINK_LIST;
+			this_cpu_dec(nr_dentry_unused);
+			sb->s_nr_dentry_unused--;
 			spin_unlock(&dentry->d_lock);
 			if (!--count)
 				break;
@@ -882,6 +909,27 @@ relock:
 	shrink_dentry_list(&tmp);
 }
 
+/*
+ * Mark all the dentries as on being the dispose list so we don't think they are
+ * still on the LRU if we try to kill them from ascending the parent chain in
+ * try_prune_one_dentry() rather than directly from the dispose list.
+ */
+static void
+shrink_dcache_list(
+	struct list_head *dispose)
+{
+	struct dentry *dentry;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(dentry, dispose, d_lru) {
+		spin_lock(&dentry->d_lock);
+		dentry->d_flags |= DCACHE_SHRINK_LIST;
+		spin_unlock(&dentry->d_lock);
+	}
+	rcu_read_unlock();
+	shrink_dentry_list(dispose);
+}
+
 /**
  * shrink_dcache_sb - shrink dcache for a superblock
  * @sb: superblock
@@ -895,9 +943,17 @@ void shrink_dcache_sb(struct super_block *sb)
 
 	spin_lock(&sb->s_dentry_lru_lock);
 	while (!list_empty(&sb->s_dentry_lru)) {
+		/*
+		 * account for removal here so we don't need to handle it later
+		 * even though the dentry is no longer on the lru list.
+		 */
 		list_splice_init(&sb->s_dentry_lru, &tmp);
+		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
+		sb->s_nr_dentry_unused = 0;
 		spin_unlock(&sb->s_dentry_lru_lock);
-		shrink_dentry_list(&tmp);
+
+		shrink_dcache_list(&tmp);
+
 		spin_lock(&sb->s_dentry_lru_lock);
 	}
 	spin_unlock(&sb->s_dentry_lru_lock);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
