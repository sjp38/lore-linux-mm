Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id ABCFC6B0039
	for <linux-mm@kvack.org>; Tue, 14 May 2013 01:46:43 -0400 (EDT)
Date: Tue, 14 May 2013 15:46:40 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH v7 04/31] dcache: remove dentries from LRU before putting on
 dispose list
Message-ID: <20130514054640.GE29466@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <1368382432-25462-5-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368382432-25462-5-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

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
- fix the scope of the sb locking inside shrink_dcache_sb()
- remove the readdition of dentry_lru_prune(). ]

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dcache.c |   91 ++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 69 insertions(+), 22 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 795c15d..df37740 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -315,7 +315,7 @@ static void dentry_unlink_inode(struct dentry * dentry)
 }
 
 /*
- * dentry_lru_(add|del|prune|move_tail) must be called with d_lock held.
+ * dentry_lru_(add|del|move_list) must be called with d_lock held.
  */
 static void dentry_lru_add(struct dentry *dentry)
 {
@@ -341,7 +341,8 @@ static void __dentry_lru_del(struct dentry *dentry)
  */
 static void dentry_lru_del(struct dentry *dentry)
 {
-	if (!list_empty(&dentry->d_lru)) {
+	if (!list_empty(&dentry->d_lru) &&
+	    !(dentry->d_flags & DCACHE_SHRINK_LIST)) {
 		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 		__dentry_lru_del(dentry);
 		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
@@ -350,13 +351,15 @@ static void dentry_lru_del(struct dentry *dentry)
 
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
@@ -454,7 +457,8 @@ EXPORT_SYMBOL(d_drop);
  * If ref is non-zero, then decrement the refcount too.
  * Returns dentry requiring refcount drop, or NULL if we're done.
  */
-static inline struct dentry *dentry_kill(struct dentry *dentry, int ref)
+static inline struct dentry *
+dentry_kill(struct dentry *dentry, int ref, int unlock_on_failure)
 	__releases(dentry->d_lock)
 {
 	struct inode *inode;
@@ -463,8 +467,10 @@ static inline struct dentry *dentry_kill(struct dentry *dentry, int ref)
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
@@ -551,7 +557,7 @@ repeat:
 	return;
 
 kill_it:
-	dentry = dentry_kill(dentry, 1);
+	dentry = dentry_kill(dentry, 1, 1);
 	if (dentry)
 		goto repeat;
 }
@@ -750,12 +756,12 @@ EXPORT_SYMBOL(d_prune_aliases);
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
@@ -767,9 +773,9 @@ static void try_prune_one_dentry(struct dentry *dentry)
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
@@ -778,10 +784,11 @@ static void try_prune_one_dentry(struct dentry *dentry)
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
@@ -800,21 +807,31 @@ static void shrink_dentry_list(struct list_head *list)
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
@@ -855,8 +872,10 @@ relock:
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
@@ -870,6 +889,27 @@ relock:
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
@@ -883,9 +923,16 @@ void shrink_dcache_sb(struct super_block *sb)
 
 	spin_lock(&sb->s_dentry_lru_lock);
 	while (!list_empty(&sb->s_dentry_lru)) {
-		list_splice_init(&sb->s_dentry_lru, &tmp);
+		/*
+		 * account for removal here so we don't need to handle it later
+		 * even though the dentry is no longer on the lru list.
+		 */
 		spin_unlock(&sb->s_dentry_lru_lock);
-		shrink_dentry_list(&tmp);
+		list_splice_init(&sb->s_dentry_lru, &tmp);
+		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
+		sb->s_nr_dentry_unused = 0;
+
+		shrink_dcache_list(&tmp);
 		spin_lock(&sb->s_dentry_lru_lock);
 	}
 	spin_unlock(&sb->s_dentry_lru_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
