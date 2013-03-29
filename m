Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id AB4546B0039
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 05:14:13 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 04/28] dentry: move to per-sb LRU locks
Date: Fri, 29 Mar 2013 13:13:46 +0400
Message-Id: <1364548450-28254-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-1-git-send-email-glommer@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>

From: Dave Chinner <dchinner@redhat.com>

With the dentry LRUs being per-sb structures, there is no real need
for a global dentry_lru_lock. The locking can be made more
fine-grained by moving to a per-sb LRU lock, isolating the LRU
operations of different filesytsems completely from each other.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/dcache.c        | 37 ++++++++++++++++++-------------------
 fs/super.c         |  1 +
 include/linux/fs.h |  4 +++-
 3 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index f1196f2..0a1d7b3 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -48,7 +48,7 @@
  *   - the dcache hash table
  * s_anon bl list spinlock protects:
  *   - the s_anon list (see __d_drop)
- * dcache_lru_lock protects:
+ * dentry->d_sb->s_dentry_lru_lock protects:
  *   - the dcache lru lists and counters
  * d_lock protects:
  *   - d_flags
@@ -63,7 +63,7 @@
  * Ordering:
  * dentry->d_inode->i_lock
  *   dentry->d_lock
- *     dcache_lru_lock
+ *     dentry->d_sb->s_dentry_lru_lock
  *     dcache_hash_bucket lock
  *     s_anon lock
  *
@@ -81,7 +81,6 @@
 int sysctl_vfs_cache_pressure __read_mostly = 100;
 EXPORT_SYMBOL_GPL(sysctl_vfs_cache_pressure);
 
-static __cacheline_aligned_in_smp DEFINE_SPINLOCK(dcache_lru_lock);
 __cacheline_aligned_in_smp DEFINE_SEQLOCK(rename_lock);
 
 EXPORT_SYMBOL(rename_lock);
@@ -320,11 +319,11 @@ static void dentry_unlink_inode(struct dentry * dentry)
 static void dentry_lru_add(struct dentry *dentry)
 {
 	if (list_empty(&dentry->d_lru)) {
-		spin_lock(&dcache_lru_lock);
+		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 		list_add(&dentry->d_lru, &dentry->d_sb->s_dentry_lru);
 		dentry->d_sb->s_nr_dentry_unused++;
 		this_cpu_inc(nr_dentry_unused);
-		spin_unlock(&dcache_lru_lock);
+		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
 	}
 }
 
@@ -342,9 +341,9 @@ static void __dentry_lru_del(struct dentry *dentry)
 static void dentry_lru_del(struct dentry *dentry)
 {
 	if (!list_empty(&dentry->d_lru)) {
-		spin_lock(&dcache_lru_lock);
+		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 		__dentry_lru_del(dentry);
-		spin_unlock(&dcache_lru_lock);
+		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
 	}
 }
 
@@ -359,15 +358,15 @@ static void dentry_lru_prune(struct dentry *dentry)
 		if (dentry->d_flags & DCACHE_OP_PRUNE)
 			dentry->d_op->d_prune(dentry);
 
-		spin_lock(&dcache_lru_lock);
+		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 		__dentry_lru_del(dentry);
-		spin_unlock(&dcache_lru_lock);
+		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
 	}
 }
 
 static void dentry_lru_move_list(struct dentry *dentry, struct list_head *list)
 {
-	spin_lock(&dcache_lru_lock);
+	spin_lock(&dentry->d_sb->s_dentry_lru_lock);
 	if (list_empty(&dentry->d_lru)) {
 		list_add_tail(&dentry->d_lru, list);
 		dentry->d_sb->s_nr_dentry_unused++;
@@ -375,7 +374,7 @@ static void dentry_lru_move_list(struct dentry *dentry, struct list_head *list)
 	} else {
 		list_move_tail(&dentry->d_lru, list);
 	}
-	spin_unlock(&dcache_lru_lock);
+	spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
 }
 
 /**
@@ -853,14 +852,14 @@ void prune_dcache_sb(struct super_block *sb, int count)
 	LIST_HEAD(tmp);
 
 relock:
-	spin_lock(&dcache_lru_lock);
+	spin_lock(&sb->s_dentry_lru_lock);
 	while (!list_empty(&sb->s_dentry_lru)) {
 		dentry = list_entry(sb->s_dentry_lru.prev,
 				struct dentry, d_lru);
 		BUG_ON(dentry->d_sb != sb);
 
 		if (!spin_trylock(&dentry->d_lock)) {
-			spin_unlock(&dcache_lru_lock);
+			spin_unlock(&sb->s_dentry_lru_lock);
 			cpu_relax();
 			goto relock;
 		}
@@ -876,11 +875,11 @@ relock:
 			if (!--count)
 				break;
 		}
-		cond_resched_lock(&dcache_lru_lock);
+		cond_resched_lock(&sb->s_dentry_lru_lock);
 	}
 	if (!list_empty(&referenced))
 		list_splice(&referenced, &sb->s_dentry_lru);
-	spin_unlock(&dcache_lru_lock);
+	spin_unlock(&sb->s_dentry_lru_lock);
 
 	shrink_dentry_list(&tmp);
 }
@@ -896,14 +895,14 @@ void shrink_dcache_sb(struct super_block *sb)
 {
 	LIST_HEAD(tmp);
 
-	spin_lock(&dcache_lru_lock);
+	spin_lock(&sb->s_dentry_lru_lock);
 	while (!list_empty(&sb->s_dentry_lru)) {
 		list_splice_init(&sb->s_dentry_lru, &tmp);
-		spin_unlock(&dcache_lru_lock);
+		spin_unlock(&sb->s_dentry_lru_lock);
 		shrink_dentry_list(&tmp);
-		spin_lock(&dcache_lru_lock);
+		spin_lock(&sb->s_dentry_lru_lock);
 	}
-	spin_unlock(&dcache_lru_lock);
+	spin_unlock(&sb->s_dentry_lru_lock);
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
diff --git a/fs/super.c b/fs/super.c
index 2a37fd6..0be75fb 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -182,6 +182,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
 		INIT_LIST_HEAD(&s->s_dentry_lru);
+		spin_lock_init(&s->s_dentry_lru_lock);
 		INIT_LIST_HEAD(&s->s_inode_lru);
 		spin_lock_init(&s->s_inode_lru_lock);
 		INIT_LIST_HEAD(&s->s_mounts);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2c28271..02934f5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1261,7 +1261,9 @@ struct super_block {
 	struct list_head	s_files;
 #endif
 	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use */
-	/* s_dentry_lru, s_nr_dentry_unused protected by dcache.c lru locks */
+
+	/* s_dentry_lru_lock protects s_dentry_lru and s_nr_dentry_unused */
+	spinlock_t		s_dentry_lru_lock ____cacheline_aligned_in_smp;
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	int			s_nr_dentry_unused;	/* # of dentry on lru */
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
