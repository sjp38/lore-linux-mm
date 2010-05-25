Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CE9056002CC
	for <linux-mm@kvack.org>; Tue, 25 May 2010 04:53:25 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 2/5] mm: add context argument to shrinker callback
Date: Tue, 25 May 2010 18:53:05 +1000
Message-Id: <1274777588-21494-3-git-send-email-david@fromorbit.com>
In-Reply-To: <1274777588-21494-1-git-send-email-david@fromorbit.com>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

The current shrinker implementation requires the registered callback
to have global state to work from. This makes it difficult to shrink
caches that are not global (e.g. per-filesystem caches). Pass the shrinker
structure to the callback so that users can embed the shrinker structure
in the context the shrinker needs to operate on and get back to it in the
callback via container_of().

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
 fs/nfs/internal.h               |    3 ++-
 fs/quota/dquot.c                |    2 +-
 fs/ubifs/shrinker.c             |    2 +-
 fs/ubifs/ubifs.h                |    2 +-
 fs/xfs/linux-2.6/xfs_buf.c      |    5 +++--
 fs/xfs/linux-2.6/xfs_sync.c     |    1 +
 fs/xfs/quota/xfs_qm.c           |    7 +++++--
 include/linux/mm.h              |    2 +-
 mm/vmscan.c                     |    8 +++++---
 18 files changed, 31 insertions(+), 22 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 81563e7..ac3d107 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2919,7 +2919,7 @@ static int kvm_mmu_remove_some_alloc_mmu_pages(struct kvm *kvm)
 	return kvm_mmu_zap_page(kvm, page) + 1;
 }
 
-static int mmu_shrink(int nr_to_scan, gfp_t gfp_mask)
+static int mmu_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
 {
 	struct kvm *kvm;
 	struct kvm *kvm_freed = NULL;
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 112699f..6cd2e7a 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -5216,7 +5216,7 @@ i915_gpu_is_active(struct drm_device *dev)
 }
 
 static int
-i915_gem_shrink(int nr_to_scan, gfp_t gfp_mask)
+i915_gem_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
 {
 	drm_i915_private_t *dev_priv, *next_dev;
 	struct drm_i915_gem_object *obj_priv, *next_obj;
diff --git a/fs/dcache.c b/fs/dcache.c
index d96047b..dba6b6d 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -894,7 +894,7 @@ EXPORT_SYMBOL(shrink_dcache_parent);
  *
  * In this case we return -1 to tell the caller that we baled.
  */
-static int shrink_dcache_memory(int nr, gfp_t gfp_mask)
+static int shrink_dcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
 {
 	if (nr) {
 		if (!(gfp_mask & __GFP_FS))
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index ddcdbf4..04b540c 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1348,7 +1348,7 @@ void gfs2_glock_complete(struct gfs2_glock *gl, int ret)
 }
 
 
-static int gfs2_shrink_glock_memory(int nr, gfp_t gfp_mask)
+static int gfs2_shrink_glock_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
 {
 	struct gfs2_glock *gl;
 	int may_demote;
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 49667d6..4ea548f 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -77,7 +77,7 @@ static LIST_HEAD(qd_lru_list);
 static atomic_t qd_lru_count = ATOMIC_INIT(0);
 static DEFINE_SPINLOCK(qd_lru_lock);
 
-int gfs2_shrink_qd_memory(int nr, gfp_t gfp_mask)
+int gfs2_shrink_qd_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
 {
 	struct gfs2_quota_data *qd;
 	struct gfs2_sbd *sdp;
diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
index 195f60c..e7d236c 100644
--- a/fs/gfs2/quota.h
+++ b/fs/gfs2/quota.h
@@ -51,7 +51,7 @@ static inline int gfs2_quota_lock_check(struct gfs2_inode *ip)
 	return ret;
 }
 
-extern int gfs2_shrink_qd_memory(int nr, gfp_t gfp_mask);
+extern int gfs2_shrink_qd_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask);
 extern const struct quotactl_ops gfs2_quotactl_ops;
 
 #endif /* __QUOTA_DOT_H__ */
diff --git a/fs/inode.c b/fs/inode.c
index 3caa758..1e44ec5 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -577,7 +577,7 @@ static void prune_icache(int count)
  * This function is passed the number of inodes to scan, and it returns the
  * total number of remaining possibly-reclaimable inodes.
  */
-static int shrink_icache_memory(int nr, gfp_t gfp_mask)
+static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
 {
 	if (nr) {
 		/*
diff --git a/fs/mbcache.c b/fs/mbcache.c
index ec88ff3..e28f21b 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -115,7 +115,7 @@ mb_cache_indexes(struct mb_cache *cache)
  * What the mbcache registers as to get shrunk dynamically.
  */
 
-static int mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask);
+static int mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask);
 
 static struct shrinker mb_cache_shrinker = {
 	.shrink = mb_cache_shrink_fn,
@@ -191,13 +191,14 @@ forget:
  * This function is called by the kernel memory management when memory
  * gets low.
  *
+ * @shrink: (ignored)
  * @nr_to_scan: Number of objects to scan
  * @gfp_mask: (ignored)
  *
  * Returns the number of objects which are present in the cache.
  */
 static int
-mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
+mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
 {
 	LIST_HEAD(free_list);
 	struct list_head *l, *ltmp;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ee9a179..3f33bc0 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1708,7 +1708,7 @@ static void nfs_access_free_list(struct list_head *head)
 	}
 }
 
-int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
+int nfs_access_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
 {
 	LIST_HEAD(head);
 	struct nfs_inode *nfsi;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d8bd619..e70f44b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -205,7 +205,8 @@ extern struct rpc_procinfo nfs4_procedures[];
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 
 /* dir.c */
-extern int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask);
+extern int nfs_access_cache_shrinker(struct shrinker *shrink,
+					int nr_to_scan, gfp_t gfp_mask);
 
 /* inode.c */
 extern struct workqueue_struct *nfsiod_workqueue;
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 655a4c5..cfd5437 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -697,7 +697,7 @@ static int dqstats_read(unsigned int type)
  * more memory
  */
 
-static int shrink_dqcache_memory(int nr, gfp_t gfp_mask)
+static int shrink_dqcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
 {
 	if (nr) {
 		spin_lock(&dq_list_lock);
diff --git a/fs/ubifs/shrinker.c b/fs/ubifs/shrinker.c
index 02feb59..0b20111 100644
--- a/fs/ubifs/shrinker.c
+++ b/fs/ubifs/shrinker.c
@@ -277,7 +277,7 @@ static int kick_a_thread(void)
 	return 0;
 }
 
-int ubifs_shrinker(int nr, gfp_t gfp_mask)
+int ubifs_shrinker(struct shrinker *shrink, int nr, gfp_t gfp_mask)
 {
 	int freed, contention = 0;
 	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index bd2542d..5a92345 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1575,7 +1575,7 @@ int ubifs_tnc_start_commit(struct ubifs_info *c, struct ubifs_zbranch *zroot);
 int ubifs_tnc_end_commit(struct ubifs_info *c);
 
 /* shrinker.c */
-int ubifs_shrinker(int nr_to_scan, gfp_t gfp_mask);
+int ubifs_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask);
 
 /* commit.c */
 int ubifs_bg_thread(void *info);
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
index f01de3c..fe8bf82 100644
--- a/fs/xfs/linux-2.6/xfs_buf.c
+++ b/fs/xfs/linux-2.6/xfs_buf.c
@@ -44,7 +44,7 @@
 
 static kmem_zone_t *xfs_buf_zone;
 STATIC int xfsbufd(void *);
-STATIC int xfsbufd_wakeup(int, gfp_t);
+STATIC int xfsbufd_wakeup(struct shrinker *, int, gfp_t);
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
@@ -1753,6 +1753,7 @@ xfs_buf_runall_queues(
 
 STATIC int
 xfsbufd_wakeup(
+	struct shrinker		*shrink,
 	int			priority,
 	gfp_t			mask)
 {
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
index 3884e20..c881a0c 100644
--- a/fs/xfs/linux-2.6/xfs_sync.c
+++ b/fs/xfs/linux-2.6/xfs_sync.c
@@ -842,6 +842,7 @@ static struct rw_semaphore xfs_mount_list_lock;
 
 static int
 xfs_reclaim_inode_shrink(
+	struct shrinker	*shrink,
 	int		nr_to_scan,
 	gfp_t		gfp_mask)
 {
diff --git a/fs/xfs/quota/xfs_qm.c b/fs/xfs/quota/xfs_qm.c
index 38e7641..b8051aa 100644
--- a/fs/xfs/quota/xfs_qm.c
+++ b/fs/xfs/quota/xfs_qm.c
@@ -69,7 +69,7 @@ STATIC void	xfs_qm_list_destroy(xfs_dqlist_t *);
 
 STATIC int	xfs_qm_init_quotainos(xfs_mount_t *);
 STATIC int	xfs_qm_init_quotainfo(xfs_mount_t *);
-STATIC int	xfs_qm_shake(int, gfp_t);
+STATIC int	xfs_qm_shake(struct shrinker *, int, gfp_t);
 
 static struct shrinker xfs_qm_shaker = {
 	.shrink = xfs_qm_shake,
@@ -2117,7 +2117,10 @@ xfs_qm_shake_freelist(
  */
 /* ARGSUSED */
 STATIC int
-xfs_qm_shake(int nr_to_scan, gfp_t gfp_mask)
+xfs_qm_shake(
+	struct shrinker	*shrink,
+	int		nr_to_scan,
+	gfp_t		gfp_mask)
 {
 	int	ndqused, nfree, n;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fb19bb9..3d7eedc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -994,7 +994,7 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
  * querying the cache size, so a fastpath for that case is appropriate.
  */
 struct shrinker {
-	int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
+	int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);
 	int seeks;	/* seeks to recreate an obj */
 
 	/* These are for internal use */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3ff3311..9d56aaf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -215,8 +215,9 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
 		unsigned long total_scan;
-		unsigned long max_pass = (*shrinker->shrink)(0, gfp_mask);
+		unsigned long max_pass;
 
+		max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
 		delta = (4 * scanned) / shrinker->seeks;
 		delta *= max_pass;
 		do_div(delta, lru_pages + 1);
@@ -244,8 +245,9 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
 			int shrink_ret;
 			int nr_before;
 
-			nr_before = (*shrinker->shrink)(0, gfp_mask);
-			shrink_ret = (*shrinker->shrink)(this_scan, gfp_mask);
+			nr_before = (*shrinker->shrink)(shrinker, 0, gfp_mask);
+			shrink_ret = (*shrinker->shrink)(shrinker, this_scan,
+								gfp_mask);
 			if (shrink_ret == -1)
 				break;
 			if (shrink_ret < nr_before)
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
