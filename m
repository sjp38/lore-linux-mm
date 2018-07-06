Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27CEA6B026D
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:34:31 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c27-v6so12801404qkj.3
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:34:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e12-v6si9621433qtf.249.2018.07.06.12.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 12:34:29 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v6 3/7] fs/dcache: Enable automatic pruning of negative dentries
Date: Fri,  6 Jul 2018 15:32:48 -0400
Message-Id: <1530905572-817-4-git-send-email-longman@redhat.com>
In-Reply-To: <1530905572-817-1-git-send-email-longman@redhat.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Waiman Long <longman@redhat.com>

It is not good enough to have a soft limit for the number of
negative dentries in the system and print a warning if that limit is
exceeded. We need to do something about it when this happens.

This patch enables automatic pruning of negative dentries when
neg-dentry-pc sysctl parameter is non-zero and the soft limit is going
to be exceeded.  This is done by using the workqueue API to do the
pruning gradually when a threshold is reached to minimize performance
impact on other running tasks.

The current threshold is 1/4 of the initial value of the free pool
count. Once the threshold is reached, the automatic pruning process
will be kicked in to replenish the free pool. Each pruning run will
scan 64 dentries per LRU list and can remove up to 256 negative
dentries to minimize the LRU locks hold time. The pruning rate will
be 50 Hz if the free pool count is less than 1/8 of the original and
10 Hz otherwise.

The dentry pruning operation may also free some least recently used
positive dentries.

In the unlikely event that a superblock is being umount'ed while in
negative dentry pruning mode, the umount may face an additional delay
of up to 0.1s.

This negative dentry shrinker is supposed to be run in the background
with minimal performance impact. So it does not remove excess negative
dentries as fast as the regular memory shrinker when the system is
under high memory pressure.  This negative dentry removal rate should
be enough under normal circumstances. In the extreme case that the
negative dentry generation rate is too high, both this shrinker and
the regular memory shrinker may be running at the same time when the
amount of free memory is too low.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/dcache.c              | 155 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/list_lru.h |   1 +
 mm/list_lru.c            |   4 +-
 3 files changed, 159 insertions(+), 1 deletion(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 175012b..ac25029 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -137,6 +137,11 @@ struct dentry_stat_t dentry_stat = {
  * the extra ones will be returned back to the global pool.
  */
 #define NEG_DENTRY_BATCH	(1 << 8)
+#define NEG_PRUNING_SIZE	(1 << 6)
+#define NEG_PRUNING_SLOW_RATE	(HZ/10)
+#define NEG_PRUNING_FAST_RATE	(HZ/50)
+#define NEG_IS_SB_UMOUNTING(sb)	\
+	unlikely(!(sb)->s_root || !((sb)->s_flags & MS_ACTIVE))
 
 static struct static_key limit_neg_key = STATIC_KEY_INIT_FALSE;
 static int neg_dentry_pc_old;
@@ -147,10 +152,18 @@ struct dentry_stat_t dentry_stat = {
 static long neg_dentry_nfree_init __read_mostly; /* Free pool initial value */
 static struct {
 	raw_spinlock_t nfree_lock;
+	int niter;			/* Pruning iteration count */
+	int lru_count;			/* Per-LRU pruning count */
+	long n_neg;			/* # of negative dentries pruned */
+	long n_pos;			/* # of positive dentries pruned */
 	long nfree;			/* Negative dentry free pool */
+	struct super_block *prune_sb;	/* Super_block for pruning */
 } ndblk ____cacheline_aligned_in_smp;
 proc_handler proc_neg_dentry_pc;
 
+static void prune_negative_dentry(struct work_struct *work);
+static DECLARE_DELAYED_WORK(prune_neg_dentry_work, prune_negative_dentry);
+
 static DEFINE_PER_CPU(long, nr_dentry);
 static DEFINE_PER_CPU(long, nr_dentry_unused);
 static DEFINE_PER_CPU(long, nr_dentry_neg);
@@ -338,6 +351,25 @@ static void __neg_dentry_inc(struct dentry *dentry)
 	 */
 	if (!cnt)
 		pr_warn_once("Too many negative dentries.");
+
+	/*
+	 * Initiate negative dentry pruning if free pool has less than
+	 * 1/4 of its initial value.
+	 */
+	if ((READ_ONCE(ndblk.nfree) < READ_ONCE(neg_dentry_nfree_init)/4) &&
+	    !READ_ONCE(ndblk.prune_sb) &&
+	    !cmpxchg(&ndblk.prune_sb, NULL, dentry->d_sb)) {
+		/*
+		 * Abort if umounting is in progress, otherwise take a
+		 * reference and move on.
+		 */
+		if (NEG_IS_SB_UMOUNTING(ndblk.prune_sb)) {
+			WRITE_ONCE(ndblk.prune_sb, NULL);
+		} else {
+			atomic_inc(&ndblk.prune_sb->s_active);
+			schedule_delayed_work(&prune_neg_dentry_work, 1);
+		}
+	}
 }
 
 static inline void neg_dentry_inc(struct dentry *dentry)
@@ -1411,6 +1443,129 @@ void shrink_dcache_sb(struct super_block *sb)
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
+/*
+ * A modified version that attempts to remove a limited number of negative
+ * dentries as well as some other non-negative dentries at the front.
+ */
+static enum lru_status dentry_negative_lru_isolate(struct list_head *item,
+		struct list_lru_one *lru, spinlock_t *lru_lock, void *arg)
+{
+	struct list_head *freeable = arg;
+	struct dentry	*dentry = container_of(item, struct dentry, d_lru);
+	enum lru_status	status = LRU_SKIP;
+
+	/*
+	 * Limit amount of dentry walking in each LRU list.
+	 */
+	if (ndblk.lru_count >= NEG_PRUNING_SIZE) {
+		ndblk.lru_count = 0;
+		return LRU_STOP;
+	}
+	ndblk.lru_count++;
+
+	/*
+	 * we are inverting the lru lock/dentry->d_lock here,
+	 * so use a trylock. If we fail to get the lock, just skip
+	 * it
+	 */
+	if (!spin_trylock(&dentry->d_lock))
+		return LRU_SKIP;
+
+	/*
+	 * Referenced dentries are still in use. If they have active
+	 * counts, just remove them from the LRU. Otherwise give them
+	 * another pass through the LRU.
+	 */
+	if (dentry->d_lockref.count) {
+		d_lru_isolate(lru, dentry);
+		status = LRU_REMOVED;
+		goto out;
+	}
+
+	/*
+	 * Dentries with reference bit on are moved back to the tail.
+	 */
+	if (dentry->d_flags & DCACHE_REFERENCED) {
+		dentry->d_flags &= ~DCACHE_REFERENCED;
+		status = LRU_ROTATE;
+		goto out;
+	}
+
+	status = LRU_REMOVED;
+	d_lru_shrink_move(lru, dentry, freeable);
+	if (d_is_negative(dentry))
+		ndblk.n_neg++;
+out:
+	spin_unlock(&dentry->d_lock);
+	return status;
+}
+
+/*
+ * A workqueue function to prune negative dentry.
+ *
+ * The pruning is done gradually over time so as to have as little
+ * performance impact as possible.
+ */
+static void prune_negative_dentry(struct work_struct *work)
+{
+	int freed, last_n_neg;
+	long nfree;
+	struct super_block *sb = READ_ONCE(ndblk.prune_sb);
+	LIST_HEAD(dispose);
+
+	if (!sb)
+		return;
+	if (NEG_IS_SB_UMOUNTING(sb) || !READ_ONCE(neg_dentry_pc))
+		goto stop_pruning;
+
+	ndblk.niter++;
+	ndblk.lru_count = 0;
+	last_n_neg = ndblk.n_neg;
+	freed = list_lru_walk(&sb->s_dentry_lru, dentry_negative_lru_isolate,
+			      &dispose, NEG_DENTRY_BATCH);
+
+	if (freed)
+		shrink_dentry_list(&dispose);
+	ndblk.n_pos += freed - (ndblk.n_neg - last_n_neg);
+
+	/*
+	 * Continue delayed pruning until negative dentry free pool is at
+	 * least 1/2 of the initial value, the super_block has no more
+	 * negative dentries left at the front, or unmounting is in
+	 * progress.
+	 *
+	 * The pruning rate depends on the size of the free pool. The
+	 * faster rate is used when there is less than 1/8 left.
+	 * Otherwise, the slower rate will be used.
+	 */
+	nfree = READ_ONCE(ndblk.nfree);
+	if ((ndblk.n_neg == last_n_neg) ||
+	    (nfree >= neg_dentry_nfree_init/2) || NEG_IS_SB_UMOUNTING(sb))
+		goto stop_pruning;
+
+	schedule_delayed_work(&prune_neg_dentry_work,
+			     (nfree < neg_dentry_nfree_init/8)
+			     ? NEG_PRUNING_FAST_RATE : NEG_PRUNING_SLOW_RATE);
+	return;
+
+stop_pruning:
+#ifdef CONFIG_DEBUG_KERNEL
+	/*
+	 * Report large negative dentry pruning event.
+	 */
+	if (ndblk.n_neg > NEG_PRUNING_SIZE) {
+		pr_info("Negative dentry pruning (SB=%s):\n\t"
+			"%d iterations, %ld/%ld neg/pos dentries freed.\n",
+			ndblk.prune_sb->s_id, ndblk.niter, ndblk.n_neg,
+			ndblk.n_pos);
+	}
+#endif
+	ndblk.niter = 0;
+	ndblk.n_neg = ndblk.n_pos = 0;
+	deactivate_super(sb);
+	WRITE_ONCE(ndblk.prune_sb, NULL);
+}
+
 /**
  * enum d_walk_ret - action to talke during tree walk
  * @D_WALK_CONTINUE:	contrinue walk
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 96def9d..a9598a0 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -23,6 +23,7 @@ enum lru_status {
 	LRU_SKIP,		/* item cannot be locked, skip */
 	LRU_RETRY,		/* item not freeable. May drop the lock
 				   internally, but has to return locked. */
+	LRU_STOP,		/* stop walking the list */
 };
 
 struct list_lru_one {
diff --git a/mm/list_lru.c b/mm/list_lru.c
index fcfb6c8..2ee5d3a 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -246,11 +246,13 @@ unsigned long list_lru_count_node(struct list_lru *lru, int nid)
 			 */
 			assert_spin_locked(&nlru->lock);
 			goto restart;
+		case LRU_STOP:
+			goto out;
 		default:
 			BUG();
 		}
 	}
-
+out:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
-- 
1.8.3.1
