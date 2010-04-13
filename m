Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 29C106B01F2
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 21:20:44 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 1/2] mm: add context argument to shrinker callback
Date: Tue, 13 Apr 2010 10:24:14 +1000
Message-Id: <1271118255-21070-2-git-send-email-david@fromorbit.com>
In-Reply-To: <1271118255-21070-1-git-send-email-david@fromorbit.com>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

The current shrinker implementation requires the registered callback
to have global state to work from. This makes it difficult to shrink
caches that are not global (e.g. per-filesystem caches). Add a
context argument to the shrinker callback so that it can easily be
used in such situations.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 arch/x86/kvm/mmu.c              |    2 +-
 drivers/gpu/drm/i915/i915_gem.c |    2 +-
 fs/dcache.c                     |    2 +-
 fs/gfs2/glock.c                 |    2 +-
 fs/gfs2/quota.c                 |    2 +-
 fs/gfs2/quota.h                 |    2 +-
 fs/inode.c                      |    2 +-
 fs/mbcache.c                    |    5 +++--
 fs/nfs/dir.c                    |    2 +-
 fs/nfs/internal.h               |    2 +-
 fs/quota/dquot.c                |    2 +-
 fs/ubifs/shrinker.c             |    2 +-
 fs/ubifs/ubifs.h                |    2 +-
 fs/xfs/linux-2.6/xfs_buf.c      |    5 +++--
 fs/xfs/quota/xfs_qm.c           |    7 +++++--
 include/linux/mm.h              |   13 +++++++------
 mm/vmscan.c                     |    9 ++++++---
 17 files changed, 36 insertions(+), 27 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 48aeee8..d8ecb5b 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2915,7 +2915,7 @@ static void kvm_mmu_remove_one_alloc_mmu_page(struct kvm *kvm)
 	kvm_mmu_zap_page(kvm, page);
 }
 
-static int mmu_shrink(int nr_to_scan, gfp_t gfp_mask)
+static int mmu_shrink(void *ctx, int nr_to_scan, gfp_t gfp_mask)
 {
 	struct kvm *kvm;
 	struct kvm *kvm_freed = NULL;
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 368d726..ed94bd6 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -5058,7 +5058,7 @@ void i915_gem_release(struct drm_device * dev, struct drm_file *file_priv)
 }
 
 static int
-i915_gem_shrink(int nr_to_scan, gfp_t gfp_mask)
+i915_gem_shrink(void *ctx, int nr_to_scan, gfp_t gfp_mask)
 {
 	drm_i915_private_t *dev_priv, *next_dev;
 	struct drm_i915_gem_object *obj_priv, *next_obj;
diff --git a/fs/dcache.c b/fs/dcache.c
index f1358e5..fdfe379 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -897,7 +897,7 @@ EXPORT_SYMBOL(shrink_dcache_parent);
  *
  * In this case we return -1 to tell the caller that we baled.
  */
-static int shrink_dcache_memory(int nr, gfp_t gfp_mask)
+static int shrink_dcache_memory(void *ctx, int nr, gfp_t gfp_mask)
 {
 	if (nr) {
 		if (!(gfp_mask & __GFP_FS))
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 454d4b4..9969572 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1345,7 +1345,7 @@ void gfs2_glock_complete(struct gfs2_glock *gl, int ret)
 }
 
 
-static int gfs2_shrink_glock_memory(int nr, gfp_t gfp_mask)
+static int gfs2_shrink_glock_memory(void *ctx, int nr, gfp_t gfp_mask)
 {
 	struct gfs2_glock *gl;
 	int may_demote;
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 6dbcbad..3e3156a 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -77,7 +77,7 @@ static LIST_HEAD(qd_lru_list);
 static atomic_t qd_lru_count = ATOMIC_INIT(0);
 static DEFINE_SPINLOCK(qd_lru_lock);
 
-int gfs2_shrink_qd_memory(int nr, gfp_t gfp_mask)
+int gfs2_shrink_qd_memory(void *ctx, int nr, gfp_t gfp_mask)
 {
 	struct gfs2_quota_data *qd;
 	struct gfs2_sbd *sdp;
diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
index 195f60c..6218c00 100644
--- a/fs/gfs2/quota.h
+++ b/fs/gfs2/quota.h
@@ -51,7 +51,7 @@ static inline int gfs2_quota_lock_check(struct gfs2_inode *ip)
 	return ret;
 }
 
-extern int gfs2_shrink_qd_memory(int nr, gfp_t gfp_mask);
+extern int gfs2_shrink_qd_memory(void *ctx, int nr, gfp_t gfp_mask);
 extern const struct quotactl_ops gfs2_quotactl_ops;
 
 #endif /* __QUOTA_DOT_H__ */
diff --git a/fs/inode.c b/fs/inode.c
index 407bf39..b47e48a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -514,7 +514,7 @@ static void prune_icache(int nr_to_scan)
  * This function is passed the number of inodes to scan, and it returns the
  * total number of remaining possibly-reclaimable inodes.
  */
-static int shrink_icache_memory(int nr, gfp_t gfp_mask)
+static int shrink_icache_memory(void *ctx, int nr, gfp_t gfp_mask)
 {
 	if (nr) {
 		/*
diff --git a/fs/mbcache.c b/fs/mbcache.c
index ec88ff3..725ea66 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -115,7 +115,7 @@ mb_cache_indexes(struct mb_cache *cache)
  * What the mbcache registers as to get shrunk dynamically.
  */
 
-static int mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask);
+static int mb_cache_shrink_fn(void *ctx, int nr_to_scan, gfp_t gfp_mask);
 
 static struct shrinker mb_cache_shrinker = {
 	.shrink = mb_cache_shrink_fn,
@@ -192,12 +192,13 @@ forget:
  * gets low.
  *
  * @nr_to_scan: Number of objects to scan
+ * @ctx: (ignored)
  * @gfp_mask: (ignored)
  *
  * Returns the number of objects which are present in the cache.
  */
 static int
-mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
+mb_cache_shrink_fn(void *ctx, int nr_to_scan, gfp_t gfp_mask)
 {
 	LIST_HEAD(free_list);
 	struct list_head *l, *ltmp;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c6f2750..8869f61 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1667,7 +1667,7 @@ static void nfs_access_free_entry(struct nfs_access_entry *entry)
 	smp_mb__after_atomic_dec();
 }
 
-int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
+int nfs_access_cache_shrinker(void *ctx, int nr_to_scan, gfp_t gfp_mask)
 {
 	LIST_HEAD(head);
 	struct nfs_inode *nfsi;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 11f82f0..ea55452 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -205,7 +205,7 @@ extern struct rpc_procinfo nfs4_procedures[];
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 
 /* dir.c */
-extern int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask);
+extern int nfs_access_cache_shrinker(void *ctx, int nr_to_scan, gfp_t gfp_mask);
 
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index e0b870f..883bbfd 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -670,7 +670,7 @@ static void prune_dqcache(int count)
  * more memory
  */
 
-static int shrink_dqcache_memory(int nr, gfp_t gfp_mask)
+static int shrink_dqcache_memory(void *ctx, int nr, gfp_t gfp_mask)
 {
 	if (nr) {
 		spin_lock(&dq_list_lock);
diff --git a/fs/ubifs/shrinker.c b/fs/ubifs/shrinker.c
index 02feb59..8ba73bf 100644
--- a/fs/ubifs/shrinker.c
+++ b/fs/ubifs/shrinker.c
@@ -277,7 +277,7 @@ static int kick_a_thread(void)
 	return 0;
 }
 
-int ubifs_shrinker(int nr, gfp_t gfp_mask)
+int ubifs_shrinker(void *ctx, int nr, gfp_t gfp_mask)
 {
 	int freed, contention = 0;
 	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index bd2542d..7244260 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1575,7 +1575,7 @@ int ubifs_tnc_start_commit(struct ubifs_info *c, struct ubifs_zbranch *zroot);
 int ubifs_tnc_end_commit(struct ubifs_info *c);
 
 /* shrinker.c */
-int ubifs_shrinker(int nr_to_scan, gfp_t gfp_mask);
+int ubifs_shrinker(void *ctx, int nr_to_scan, gfp_t gfp_mask);
 
 /* commit.c */
 int ubifs_bg_thread(void *info);
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index 44c2b0e..0df4b2e 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -44,7 +44,7 @@
 
 static kmem_zone_t *xfs_buf_zone;
 STATIC int xfsbufd(void *);
-STATIC int xfsbufd_wakeup(int, gfp_t);
+STATIC int xfsbufd_wakeup(void *ctx, int, gfp_t);
 STATIC void xfs_buf_delwri_queue(xfs_buf_t *, int);
 static struct shrinker xfs_buf_shake = {
 	.shrink = xfsbufd_wakeup,
@@ -339,7 +339,7 @@ _xfs_buf_lookup_pages(
 					__func__, gfp_mask);
 
 			XFS_STATS_INC(xb_page_retries);
-			xfsbufd_wakeup(0, gfp_mask);
+			xfsbufd_wakeup(NULL, 0, gfp_mask);
 			congestion_wait(BLK_RW_ASYNC, HZ/50);
 			goto retry;
 		}
@@ -1756,6 +1756,7 @@ xfs_buf_runall_queues(
 
 STATIC int
 xfsbufd_wakeup(
+	void			*ctx,
 	int			priority,
 	gfp_t			mask)
 {
diff --git a/fs/xfs/quota/xfs_qm.c b/fs/xfs/quota/xfs_qm.c
index 417e61e..82ac964 100644
--- a/fs/xfs/quota/xfs_qm.c
+++ b/fs/xfs/quota/xfs_qm.c
@@ -72,7 +72,7 @@ STATIC void	xfs_qm_freelist_destroy(xfs_frlist_t *);
 
 STATIC int	xfs_qm_init_quotainos(xfs_mount_t *);
 STATIC int	xfs_qm_init_quotainfo(xfs_mount_t *);
-STATIC int	xfs_qm_shake(int, gfp_t);
+STATIC int	xfs_qm_shake(void *, int, gfp_t);
 
 static struct shrinker xfs_qm_shaker = {
 	.shrink = xfs_qm_shake,
@@ -2088,7 +2088,10 @@ xfs_qm_shake_freelist(
  */
 /* ARGSUSED */
 STATIC int
-xfs_qm_shake(int nr_to_scan, gfp_t gfp_mask)
+xfs_qm_shake(
+	void	*ctx,
+	int	nr_to_scan,
+	gfp_t	gfp_mask)
 {
 	int	ndqused, nfree, n;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e70f21b..7d48942 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -982,11 +982,11 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
 /*
  * A callback you can register to apply pressure to ageable caches.
  *
- * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
- * look through the least-recently-used 'nr_to_scan' entries and
- * attempt to free them up.  It should return the number of objects
- * which remain in the cache.  If it returns -1, it means it cannot do
- * any scanning at this time (eg. there is a risk of deadlock).
+ * 'shrink' is passed a context 'ctx', a count 'nr_to_scan' and a 'gfpmask'.
+ * It should look through the least-recently-used 'nr_to_scan' entries and
+ * attempt to free them up.  It should return the number of objects which
+ * remain in the cache.  If it returns -1, it means it cannot do any scanning
+ * at this time (eg. there is a risk of deadlock).
  *
  * The 'gfpmask' refers to the allocation we are currently trying to
  * fulfil.
@@ -995,7 +995,8 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
  * querying the cache size, so a fastpath for that case is appropriate.
  */
 struct shrinker {
-	int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
+	int (*shrink)(void *ctx, int nr_to_scan, gfp_t gfp_mask);
+	void *ctx;	/* user callback context */
 	int seeks;	/* seeks to recreate an obj */
 
 	/* These are for internal use */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5321ac4..40f27d2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -215,8 +215,9 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
 		unsigned long total_scan;
-		unsigned long max_pass = (*shrinker->shrink)(0, gfp_mask);
+		unsigned long max_pass;
 
+		max_pass = (*shrinker->shrink)(shrinker->ctx, 0, gfp_mask);
 		delta = (4 * scanned) / shrinker->seeks;
 		delta *= max_pass;
 		do_div(delta, lru_pages + 1);
@@ -244,8 +245,10 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 			int shrink_ret;
 			int nr_before;
 
-			nr_before = (*shrinker->shrink)(0, gfp_mask);
-			shrink_ret = (*shrinker->shrink)(this_scan, gfp_mask);
+			nr_before = (*shrinker->shrink)(shrinker->ctx,
+							0, gfp_mask);
+			shrink_ret = (*shrinker->shrink)(shrinker->ctx,
+							this_scan, gfp_mask);
 			if (shrink_ret == -1)
 				break;
 			if (shrink_ret < nr_before)
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
