Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 09C126B0036
	for <linux-mm@kvack.org>; Sun, 12 May 2013 14:13:28 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v6 04/31] dcache: remove dentries from LRU before putting on dispose list
Date: Sun, 12 May 2013 22:13:25 +0400
Message-Id: <1368382432-25462-5-git-send-email-glommer@openvz.org>
In-Reply-To: <1368382432-25462-1-git-send-email-glommer@openvz.org>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>

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
dentry_lru_prune() has to handle the DCACHE_SHRINK_LIST case
differently because the dentry isn't on the LRU list.

[ v2: don't decrement nr unused twice, spotted by Sha Zhengju ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 fs/dcache.c | 93 ++++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 71 insertions(+), 22 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 795c15d..868abf9 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -331,7 +331,6 @@ static void dentry_lru_add(struct dentry *dentry)
 static void __dentry_lru_del(struct dentry *dentry)
 {
 	list_del_init(&dentry->d_lru);
-	dentry->d_flags &= ~DCACHE_SHRINK_LIST;
 	dentry->d_sb->s_nr_dentry_unused--;
 	this_cpu_dec(nr_dentry_unused);
 }
@@ -341,6 +340,8 @@ static void __dentry_lru_del(struct dentry *dentry)
  */
 static void dentry_lru_del(struct dentry *dentry)
 {
+	BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
+
 	if (!list_empty(&dentry->d_lru)) {
 		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 		__dentry_lru_del(dentry);
@@ -348,15 +349,39 @@ static void dentry_lru_del(struct dentry *dentry)
 	}
 }
 
+static void dentry_lru_prune(struct dentry *dentry)
+{
+	/*
+	 * inform the fs via d_prune that this dentry is about to be
+	 * unhashed and destroyed.
+	 */
+	if (dentry->d_flags & DCACHE_OP_PRUNE)
+		dentry->d_op->d_prune(dentry);
+
+	if (list_empty(&dentry->d_lru))
+		return;
+
+	if ((dentry->d_flags & DCACHE_SHRINK_LIST)) {
+		list_del_init(&dentry->d_lru);
+		dentry->d_flags &= ~DCACHE_SHRINK_LIST;
+	} else {
+		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
+		__dentry_lru_del(dentry);
+		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
+	}
+}
+
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
@@ -479,14 +504,8 @@ relock:
 
 	if (ref)
 		dentry->d_count--;
-	/*
-	 * inform the fs via d_prune that this dentry is about to be
-	 * unhashed and destroyed.
-	 */
-	if (dentry->d_flags & DCACHE_OP_PRUNE)
-		dentry->d_op->d_prune(dentry);
 
-	dentry_lru_del(dentry);
+	dentry_lru_prune(dentry);
 	/* if it was on the hash then remove it */
 	__d_drop(dentry);
 	return d_kill(dentry, parent);
@@ -800,12 +819,18 @@ static void shrink_dentry_list(struct list_head *list)
 		}
 
 		/*
+		 * The dispose list is isolated and dentries are not accounted
+		 * to the LRU here, so we can simply remove it from the list
+		 * here regardless of whether it is referenced or not.
+		 */
+		list_del_init(&dentry->d_lru);
+
+		/*
 		 * We found an inuse dentry which was not removed from
-		 * the LRU because of laziness during lookup.  Do not free
-		 * it - just keep it off the LRU list.
+		 * the LRU because of laziness during lookup. Do not free it.
 		 */
 		if (dentry->d_count) {
-			dentry_lru_del(dentry);
+			dentry->d_flags &= ~DCACHE_SHRINK_LIST;
 			spin_unlock(&dentry->d_lock);
 			continue;
 		}
@@ -857,6 +882,8 @@ relock:
 		} else {
 			list_move_tail(&dentry->d_lru, &tmp);
 			dentry->d_flags |= DCACHE_SHRINK_LIST;
+			this_cpu_dec(nr_dentry_unused);
+			sb->s_nr_dentry_unused--;
 			spin_unlock(&dentry->d_lock);
 			if (!--count)
 				break;
@@ -870,6 +897,27 @@ relock:
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
@@ -884,8 +932,16 @@ void shrink_dcache_sb(struct super_block *sb)
 	spin_lock(&sb->s_dentry_lru_lock);
 	while (!list_empty(&sb->s_dentry_lru)) {
 		list_splice_init(&sb->s_dentry_lru, &tmp);
+
+		/*
+		 * account for removal here so we don't need to handle it later
+		 * even though the dentry is no longer on the lru list.
+		 */
+		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
+		sb->s_nr_dentry_unused = 0;
+
 		spin_unlock(&sb->s_dentry_lru_lock);
-		shrink_dentry_list(&tmp);
+		shrink_dcache_list(&tmp);
 		spin_lock(&sb->s_dentry_lru_lock);
 	}
 	spin_unlock(&sb->s_dentry_lru_lock);
@@ -914,14 +970,7 @@ static void shrink_dcache_for_umount_subtree(struct dentry *dentry)
 		do {
 			struct inode *inode;
 
-			/*
-			 * inform the fs that this dentry is about to be
-			 * unhashed and destroyed.
-			 */
-			if (dentry->d_flags & DCACHE_OP_PRUNE)
-				dentry->d_op->d_prune(dentry);
-
-			dentry_lru_del(dentry);
+			dentry_lru_prune(dentry);
 			__d_shrink(dentry);
 
 			if (dentry->d_count != 0) {
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
