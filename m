Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id E575C6B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 04:54:08 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ts6so129969228pac.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 01:54:08 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id s7si3301799pab.167.2016.07.09.01.54.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 01:54:06 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id c74so10045817pfb.0
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 01:54:06 -0700 (PDT)
Date: Sat, 9 Jul 2016 04:52:45 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH 2/3] Update name field for all shrinker instances
Message-ID: <68821d516aed9e248829d512eab88e381fd8ec60.1468051281.git.janani.rvchndrn@gmail.com>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1468051277.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

This patch makes changes to have all instances of struct shrinker update
the newly added name field. This name could then be passed to
tracepoints, which can help identify which shrinker was invoked.

---
 arch/x86/kvm/mmu.c                                 | 1 +
 drivers/gpu/drm/i915/i915_gem_shrinker.c           | 1 +
 drivers/gpu/drm/ttm/ttm_page_alloc.c               | 1 +
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c           | 1 +
 drivers/md/bcache/btree.c                          | 1 +
 drivers/md/dm-bufio.c                              | 1 +
 drivers/md/raid5.c                                 | 1 +
 drivers/staging/android/ashmem.c                   | 1 +
 drivers/staging/android/ion/ion_heap.c             | 1 +
 drivers/staging/android/lowmemorykiller.c          | 1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 1 +
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 1 +
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 1 +
 fs/ext4/extents_status.c                           | 1 +
 fs/f2fs/super.c                                    | 1 +
 fs/gfs2/glock.c                                    | 1 +
 fs/gfs2/quota.c                                    | 1 +
 fs/mbcache.c                                       | 1 +
 fs/nfs/super.c                                     | 1 +
 fs/nfsd/nfscache.c                                 | 1 +
 fs/quota/dquot.c                                   | 1 +
 fs/super.c                                         | 1 +
 fs/ubifs/super.c                                   | 1 +
 fs/xfs/xfs_buf.c                                   | 1 +
 fs/xfs/xfs_qm.c                                    | 1 +
 mm/huge_memory.c                                   | 2 ++
 mm/workingset.c                                    | 1 +
 mm/zsmalloc.c                                      | 1 +
 net/sunrpc/auth.c                                  | 1 +
 29 files changed, 30 insertions(+)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index def97b3..566b800 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -5025,6 +5025,7 @@ mmu_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 }
 
 static struct shrinker mmu_shrinker = {
+	.name = "mmu_shrinker",
 	.count_objects = mmu_shrink_count,
 	.scan_objects = mmu_shrink_scan,
 	.seeks = DEFAULT_SEEKS * 10,
diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
index 425e721..bb1953d 100644
--- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
+++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
@@ -411,6 +411,7 @@ i915_gem_shrinker_vmap(struct notifier_block *nb, unsigned long event, void *ptr
  */
 void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
 {
+	dev_priv->mm.shrinker.name = "i915_gem_shrinker";
 	dev_priv->mm.shrinker.scan_objects = i915_gem_shrinker_scan;
 	dev_priv->mm.shrinker.count_objects = i915_gem_shrinker_count;
 	dev_priv->mm.shrinker.seeks = DEFAULT_SEEKS;
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
index a37de5d..112a0c2 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -434,6 +434,7 @@ ttm_pool_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 
 static void ttm_pool_mm_shrink_init(struct ttm_pool_manager *manager)
 {
+	manager->mm_shrink.name = "ttm_pool_shrinker";
 	manager->mm_shrink.count_objects = ttm_pool_shrink_count;
 	manager->mm_shrink.scan_objects = ttm_pool_shrink_scan;
 	manager->mm_shrink.seeks = 1;
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
index bef9f6f..4abd37c 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
@@ -1066,6 +1066,7 @@ ttm_dma_pool_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 
 static void ttm_dma_pool_mm_shrink_init(struct ttm_pool_manager *manager)
 {
+	manager->mm_shrink.name = "ttm_dma_pool_shrinker";
 	manager->mm_shrink.count_objects = ttm_dma_pool_shrink_count;
 	manager->mm_shrink.scan_objects = &ttm_dma_pool_shrink_scan;
 	manager->mm_shrink.seeks = 1;
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index eab505e..3f89272 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -803,6 +803,7 @@ int bch_btree_cache_alloc(struct cache_set *c)
 		c->verify_data = NULL;
 #endif
 
+	c->shrink.name = "bch_btree_shrinker";
 	c->shrink.count_objects = bch_mca_count;
 	c->shrink.scan_objects = bch_mca_scan;
 	c->shrink.seeks = 4;
diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index cd77216..ff03854 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -1705,6 +1705,7 @@ struct dm_bufio_client *dm_bufio_client_create(struct block_device *bdev, unsign
 	__cache_size_refresh();
 	mutex_unlock(&dm_bufio_clients_lock);
 
+	c->shrinker.name = "dm_bufio_shrinker";
 	c->shrinker.count_objects = dm_bufio_shrink_count;
 	c->shrinker.scan_objects = dm_bufio_shrink_scan;
 	c->shrinker.seeks = 1;
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 8959e6d..f0e04c2 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -6632,6 +6632,7 @@ static struct r5conf *setup_conf(struct mddev *mddev)
 	 * it reduces the queue depth and so can hurt throughput.
 	 * So set it rather large, scaled by number of devices.
 	 */
+	conf->shrinker.name = "raid5_shrinker";
 	conf->shrinker.seeks = DEFAULT_SEEKS * conf->raid_disks * 4;
 	conf->shrinker.scan_objects = raid5_cache_scan;
 	conf->shrinker.count_objects = raid5_cache_count;
diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index ca9a53c..19dfeb9 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -487,6 +487,7 @@ ashmem_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 }
 
 static struct shrinker ashmem_shrinker = {
+	.name = "ashmem_shrinker",
 	.count_objects = ashmem_shrink_count,
 	.scan_objects = ashmem_shrink_scan,
 	/*
diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
index ca15a87..85f4110 100644
--- a/drivers/staging/android/ion/ion_heap.c
+++ b/drivers/staging/android/ion/ion_heap.c
@@ -308,6 +308,7 @@ static unsigned long ion_heap_shrink_scan(struct shrinker *shrinker,
 
 void ion_heap_init_shrinker(struct ion_heap *heap)
 {
+	heap->shrinker.name = "ion_heap_shrinker";
 	heap->shrinker.count_objects = ion_heap_shrink_count;
 	heap->shrinker.scan_objects = ion_heap_shrink_scan;
 	heap->shrinker.seeks = DEFAULT_SEEKS;
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 24d2745..9c58ed4 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -188,6 +188,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 }
 
 static struct shrinker lowmem_shrinker = {
+	.name = "lowmem_shrinker",
 	.scan_objects = lowmem_scan,
 	.count_objects = lowmem_count,
 	.seeks = DEFAULT_SEEKS * 16
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index b913ba9..89876c7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -1081,6 +1081,7 @@ static void ldlm_pools_thread_stop(void)
 }
 
 static struct shrinker ldlm_pools_cli_shrinker = {
+	.name		= "ldlm_pools_cli_shrinker",
 	.count_objects	= ldlm_pools_cli_count,
 	.scan_objects	= ldlm_pools_cli_scan,
 	.seeks		= DEFAULT_SEEKS,
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index e043857..8f998a5 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1803,6 +1803,7 @@ static unsigned long lu_cache_shrink_scan(struct shrinker *sk,
  * Debugging printer function using printk().
  */
 static struct shrinker lu_site_shrinker = {
+	.name		= "lu_site_shrinker",
 	.count_objects	= lu_cache_shrink_count,
 	.scan_objects	= lu_cache_shrink_scan,
 	.seeks 		= DEFAULT_SEEKS,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 02e6cda..c288b52 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -372,6 +372,7 @@ static inline void enc_pools_free(void)
 }
 
 static struct shrinker pools_shrinker = {
+	.name		= "ptlrpc_pools_shrinker",
 	.count_objects	= enc_pools_shrink_count,
 	.scan_objects	= enc_pools_shrink_scan,
 	.seeks		= DEFAULT_SEEKS,
diff --git a/fs/ext4/extents_status.c b/fs/ext4/extents_status.c
index 37e0592..a6534c6 100644
--- a/fs/ext4/extents_status.c
+++ b/fs/ext4/extents_status.c
@@ -1153,6 +1153,7 @@ int ext4_es_register_shrinker(struct ext4_sb_info *sbi)
 	if (err)
 		goto err1;
 
+	sbi->s_es_shrinker.name = "ext4_es_shrinker";
 	sbi->s_es_shrinker.scan_objects = ext4_es_scan;
 	sbi->s_es_shrinker.count_objects = ext4_es_count;
 	sbi->s_es_shrinker.seeks = DEFAULT_SEEKS;
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 74cc852..9d0aac3 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -65,6 +65,7 @@ static void f2fs_build_fault_attr(unsigned int rate)
 
 /* f2fs-wide shrinker description */
 static struct shrinker f2fs_shrinker_info = {
+	.name = "f2fs_shrinker",
 	.scan_objects = f2fs_shrink_scan,
 	.count_objects = f2fs_shrink_count,
 	.seeks = DEFAULT_SEEKS,
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 706fd93..5b3b7d6 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1416,6 +1416,7 @@ static unsigned long gfs2_glock_shrink_count(struct shrinker *shrink,
 }
 
 static struct shrinker glock_shrinker = {
+	.name = "glock_shrinker",
 	.seeks = DEFAULT_SEEKS,
 	.count_objects = gfs2_glock_shrink_count,
 	.scan_objects = gfs2_glock_shrink_scan,
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index ce7d69a..2d13873 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -187,6 +187,7 @@ static unsigned long gfs2_qd_shrink_count(struct shrinker *shrink,
 }
 
 struct shrinker gfs2_qd_shrinker = {
+	.name = "gfs2_qd_shrinker",
 	.count_objects = gfs2_qd_shrink_count,
 	.scan_objects = gfs2_qd_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
diff --git a/fs/mbcache.c b/fs/mbcache.c
index eccda3a..c58d727 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -363,6 +363,7 @@ struct mb_cache *mb_cache_create(int bucket_bits)
 	for (i = 0; i < bucket_count; i++)
 		INIT_HLIST_BL_HEAD(&cache->c_hash[i]);
 
+	cache->c_shrink.name = "mb_cache_shrinker";
 	cache->c_shrink.count_objects = mb_cache_count;
 	cache->c_shrink.scan_objects = mb_cache_scan;
 	cache->c_shrink.seeks = DEFAULT_SEEKS;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2137e02..041873f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -360,6 +360,7 @@ static void unregister_nfs4_fs(void)
 #endif
 
 static struct shrinker acl_shrinker = {
+	.name		= "nfs_shrinker",
 	.count_objects	= nfs_access_cache_count,
 	.scan_objects	= nfs_access_cache_scan,
 	.seeks		= DEFAULT_SEEKS,
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 54cde9a..40d331e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -69,6 +69,7 @@ static unsigned long nfsd_reply_cache_scan(struct shrinker *shrink,
 					   struct shrink_control *sc);
 
 static struct shrinker nfsd_reply_cache_shrinker = {
+	.name = "nfsd_reply_cache_shrinker",
 	.scan_objects = nfsd_reply_cache_scan,
 	.count_objects = nfsd_reply_cache_count,
 	.seeks	= 1,
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index ff21980..ca57560 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -730,6 +730,7 @@ dqcache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 }
 
 static struct shrinker dqcache_shrinker = {
+	.name = "dqcache_shrinker",
 	.count_objects = dqcache_shrink_count,
 	.scan_objects = dqcache_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
diff --git a/fs/super.c b/fs/super.c
index d78b984..051073c 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -241,6 +241,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	s->s_time_gran = 1000000000;
 	s->cleancache_poolid = CLEANCACHE_NO_POOL;
 
+	s->s_shrink.name = "super_cache_shrinker";
 	s->s_shrink.seeks = DEFAULT_SEEKS;
 	s->s_shrink.scan_objects = super_cache_scan;
 	s->s_shrink.count_objects = super_cache_count;
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 7034995..7fd4ac3 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -49,6 +49,7 @@ struct kmem_cache *ubifs_inode_slab;
 
 /* UBIFS TNC shrinker description */
 static struct shrinker ubifs_shrinker_info = {
+	.name = "ubifs_shrinker",
 	.scan_objects = ubifs_shrink_scan,
 	.count_objects = ubifs_shrink_count,
 	.seeks = DEFAULT_SEEKS,
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index e71cfbd..0fff60e 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1691,6 +1691,7 @@ xfs_alloc_buftarg(
 	if (list_lru_init(&btp->bt_lru))
 		goto error;
 
+	btp->bt_shrinker.name = "xfs_buftarg_shrinker";
 	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
 	btp->bt_shrinker.scan_objects = xfs_buftarg_shrink_scan;
 	btp->bt_shrinker.seeks = DEFAULT_SEEKS;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index a60d9e2..3c08c3b 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -687,6 +687,7 @@ xfs_qm_init_quotainfo(
 	if (XFS_IS_PQUOTA_RUNNING(mp))
 		xfs_qm_set_defquota(mp, XFS_DQ_PROJ, qinf);
 
+	qinf->qi_shrinker.name = "xfs_qm_shrinker";
 	qinf->qi_shrinker.count_objects = xfs_qm_shrink_count;
 	qinf->qi_shrinker.scan_objects = xfs_qm_shrink_scan;
 	qinf->qi_shrinker.seeks = DEFAULT_SEEKS;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9ed5853..2c84d06 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -263,6 +263,7 @@ static unsigned long shrink_huge_zero_page_scan(struct shrinker *shrink,
 }
 
 static struct shrinker huge_zero_page_shrinker = {
+	.name = "huge_zero_page_shrinker",
 	.count_objects = shrink_huge_zero_page_count,
 	.scan_objects = shrink_huge_zero_page_scan,
 	.seeks = DEFAULT_SEEKS,
@@ -3471,6 +3472,7 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 }
 
 static struct shrinker deferred_split_shrinker = {
+	.name = "deferred_split_shrinker",
 	.count_objects = deferred_split_count,
 	.scan_objects = deferred_split_scan,
 	.seeks = DEFAULT_SEEKS,
diff --git a/mm/workingset.c b/mm/workingset.c
index 8a75f8d..d180503 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -461,6 +461,7 @@ static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 }
 
 static struct shrinker workingset_shadow_shrinker = {
+	.name = "workingset_shadow_shrinker",
 	.count_objects = count_shadow_nodes,
 	.scan_objects = scan_shadow_nodes,
 	.seeks = DEFAULT_SEEKS,
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b6d4f25..bba84e1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1864,6 +1864,7 @@ static void zs_unregister_shrinker(struct zs_pool *pool)
 
 static int zs_register_shrinker(struct zs_pool *pool)
 {
+	pool->shrinker.name = "zs_shrinker";
 	pool->shrinker.scan_objects = zs_shrinker_scan;
 	pool->shrinker.count_objects = zs_shrinker_count;
 	pool->shrinker.batch = 0;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 040ff62..3411778 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -861,6 +861,7 @@ rpcauth_uptodatecred(struct rpc_task *task)
 }
 
 static struct shrinker rpc_cred_shrinker = {
+	.name = "rpc_cred_shrinker",
 	.count_objects = rpcauth_cache_shrink_count,
 	.scan_objects = rpcauth_cache_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
