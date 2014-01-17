Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 38BD16B0035
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 14:25:45 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id y6so3297060lbh.18
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 11:25:44 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id du1si738913lac.93.2014.01.17.11.25.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 11:25:43 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/3] mm: vmscan: get rid of DEFAULT_SEEKS and document shrink_slab logic
Date: Fri, 17 Jan 2014 23:25:30 +0400
Message-ID: <e204471853100447541ce36b198c0d45bf06379c.1389982079.git.vdavydov@parallels.com>
In-Reply-To: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com>
References: <4e2efebe688e06574f6495c634ac45d799e1518d.1389982079.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

Each shrinker must define the number of seeks it takes to recreate a
shrinkable cache object. It is used to balance slab reclaim vs page
reclaim: assuming it costs one seek to replace an LRU page, we age equal
percentages of the LRU and ageable caches. So far, everything sounds
clear, but the code implementing this behavior is rather confusing.

First, there is the DEFAULT_SEEKS constant, which equals 2 for some
reason:

  #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */

Most shrinkers define `seeks' to be equal to DEFAULT_SEEKS, some use
DEFAULT_SEEKS*N, and there are a few that totally ignore it. What is
peculiar, dcache and icache shrinkers have seeks=DEFAULT_SEEKS although
recreating an inode typically requires one seek. Does this mean that we
scan twice more inodes than we should?

Actually, no. The point is that vmscan handles DEFAULT_SEEKS as if it
were 1 (`delta' is the number of objects we are going to scan):

  shrink_slab_node():
    delta = (4 * nr_pages_scanned) / shrinker->seeks;
    delta *= freeable;
    do_div(delta, lru_pages + 1);

i.e.

            2 * nr_pages_scanned    DEFAULT_SEEKS
    delta = -------------------- * --------------- * freeable;
                 lru_pages         shrinker->seeks

Here we double the number of pages scanned in order to take into account
moves of on-LRU pages from the inactive list to the active list, which
we do not count in nr_pages_scanned.

That said, shrinker->seeks=DEFAULT_SEEKS*N is equivalent to N seeks, so
why on the hell do we need it?

IMO, the existence of the DEFAULT_SEEKS constant only causes confusion
for both users of the shrinker interface and those trying to understand
how slab shrinking works. The meaning of the `seeks' is perfectly
explained by the comment to it and there is no need in any obscure
constants for using it.

That's why I'm sending this patch which completely removes DEFAULT_SEEKS
and makes all shrinkers use N instead of N*DEFAULT_SEEKS, documenting
the idea lying behind shrink_slab() in the meanwhile.

Unfortunately, there are a few shrinkers that define seeks=1, which is
impossible to transfer to the new interface intact, namely:

  nfsd_reply_cache_shrinker
  ttm_pool_manager::mm_shrink
  ttm_pool_manager::mm_shrink
  dm_bufio_client::shrinker

It seems to me their authors were simply deceived by this mysterious
DEFAULT_SEEKS constant, because I've found no documentation why these
particular caches should be scanned more aggressively than the page and
other slab caches. For them, this patch leaves seeks=1. Thus, it DOES
introduce a functional change: the shrinkers enumerated above will be
scanned twice less intensively than they are now. I do not think that
this will cause any problems though.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Glauber Costa <glommer@gmail.com>
---
 arch/x86/kvm/mmu.c                                 |    2 +-
 drivers/gpu/drm/i915/i915_gem.c                    |    2 +-
 drivers/md/bcache/btree.c                          |    2 +-
 drivers/staging/android/ashmem.c                   |    2 +-
 drivers/staging/android/lowmemorykiller.c          |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |    4 +--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    2 +-
 fs/ext4/extents_status.c                           |    2 +-
 fs/gfs2/glock.c                                    |    2 +-
 fs/gfs2/quota.c                                    |    2 +-
 fs/mbcache.c                                       |    2 +-
 fs/nfs/super.c                                     |    2 +-
 fs/quota/dquot.c                                   |    2 +-
 fs/super.c                                         |    2 +-
 fs/ubifs/super.c                                   |    2 +-
 fs/xfs/xfs_buf.c                                   |    2 +-
 fs/xfs/xfs_qm.c                                    |    2 +-
 include/linux/shrinker.h                           |    1 -
 mm/huge_memory.c                                   |    2 +-
 mm/vmscan.c                                        |   31 ++++++++++----------
 net/sunrpc/auth.c                                  |    2 +-
 22 files changed, 36 insertions(+), 38 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 40772ef..b092ccc 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -4445,7 +4445,7 @@ mmu_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 static struct shrinker mmu_shrinker = {
 	.count_objects = mmu_shrink_count,
 	.scan_objects = mmu_shrink_scan,
-	.seeks = DEFAULT_SEEKS * 10,
+	.seeks = 10,
 };
 
 static void mmu_destroy_caches(void)
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 76d3d1a..c779221 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -4674,7 +4674,7 @@ i915_gem_load(struct drm_device *dev)
 
 	dev_priv->mm.inactive_shrinker.scan_objects = i915_gem_inactive_scan;
 	dev_priv->mm.inactive_shrinker.count_objects = i915_gem_inactive_count;
-	dev_priv->mm.inactive_shrinker.seeks = DEFAULT_SEEKS;
+	dev_priv->mm.inactive_shrinker.seeks = 1;
 	register_shrinker(&dev_priv->mm.inactive_shrinker);
 }
 
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 31bb53f..a359351 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -818,7 +818,7 @@ int bch_btree_cache_alloc(struct cache_set *c)
 
 	c->shrink.count_objects = bch_mca_count;
 	c->shrink.scan_objects = bch_mca_scan;
-	c->shrink.seeks = 4;
+	c->shrink.seeks = 2;
 	c->shrink.batch = c->btree_pages * 2;
 	register_shrinker(&c->shrink);
 
diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 23948f1..dbb6128 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -470,7 +470,7 @@ static struct shrinker ashmem_shrinker = {
 	 * XXX (dchinner): I wish people would comment on why they need on
 	 * significant changes to the default value here
 	 */
-	.seeks = DEFAULT_SEEKS * 4,
+	.seeks = 4,
 };
 
 static int set_prot_mask(struct ashmem_area *asma, unsigned long prot)
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 6f094b3..0cfd62c 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -173,7 +173,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 static struct shrinker lowmem_shrinker = {
 	.scan_objects = lowmem_scan,
 	.count_objects = lowmem_count,
-	.seeks = DEFAULT_SEEKS * 16
+	.seeks = 16
 };
 
 static int __init lowmem_init(void)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 0025ee6..29bf615 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -1394,13 +1394,13 @@ static void ldlm_pools_thread_stop(void)
 static struct shrinker ldlm_pools_srv_shrinker = {
 	.count_objects	= ldlm_pools_srv_count,
 	.scan_objects	= ldlm_pools_srv_scan,
-	.seeks		= DEFAULT_SEEKS,
+	.seeks		= 1,
 };
 
 static struct shrinker ldlm_pools_cli_shrinker = {
 	.count_objects	= ldlm_pools_cli_count,
 	.scan_objects	= ldlm_pools_cli_scan,
-	.seeks		= DEFAULT_SEEKS,
+	.seeks		= 1,
 };
 
 int ldlm_pools_init(void)
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 212823a..7799321 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1923,7 +1923,7 @@ int lu_printk_printer(const struct lu_env *env,
 static struct shrinker lu_site_shrinker = {
 	.count_objects	= lu_cache_shrink_count,
 	.scan_objects	= lu_cache_shrink_scan,
-	.seeks 		= DEFAULT_SEEKS,
+	.seeks 		= 1,
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 316103a..6019213 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -710,7 +710,7 @@ static inline void enc_pools_free(void)
 static struct shrinker pools_shrinker = {
 	.count_objects	= enc_pools_shrink_count,
 	.scan_objects	= enc_pools_shrink_scan,
-	.seeks		= DEFAULT_SEEKS,
+	.seeks		= 1,
 };
 
 int sptlrpc_enc_pool_init(void)
diff --git a/fs/ext4/extents_status.c b/fs/ext4/extents_status.c
index 3981ff7..2a49cca 100644
--- a/fs/ext4/extents_status.c
+++ b/fs/ext4/extents_status.c
@@ -1048,7 +1048,7 @@ void ext4_es_register_shrinker(struct ext4_sb_info *sbi)
 	sbi->s_es_last_sorted = 0;
 	sbi->s_es_shrinker.scan_objects = ext4_es_scan;
 	sbi->s_es_shrinker.count_objects = ext4_es_count;
-	sbi->s_es_shrinker.seeks = DEFAULT_SEEKS;
+	sbi->s_es_shrinker.seeks = 1;
 	register_shrinker(&sbi->s_es_shrinker);
 }
 
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
index 6f7a47c..dfd37c2 100644
--- a/fs/gfs2/glock.c
+++ b/fs/gfs2/glock.c
@@ -1468,7 +1468,7 @@ static unsigned long gfs2_glock_shrink_count(struct shrinker *shrink,
 }
 
 static struct shrinker glock_shrinker = {
-	.seeks = DEFAULT_SEEKS,
+	.seeks = 1,
 	.count_objects = gfs2_glock_shrink_count,
 	.scan_objects = gfs2_glock_shrink_scan,
 };
diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
index 98236d0..0e4ad87 100644
--- a/fs/gfs2/quota.c
+++ b/fs/gfs2/quota.c
@@ -149,7 +149,7 @@ static unsigned long gfs2_qd_shrink_count(struct shrinker *shrink,
 struct shrinker gfs2_qd_shrinker = {
 	.count_objects = gfs2_qd_shrink_count,
 	.scan_objects = gfs2_qd_shrink_scan,
-	.seeks = DEFAULT_SEEKS,
+	.seeks = 1,
 	.flags = SHRINKER_NUMA_AWARE,
 };
 
diff --git a/fs/mbcache.c b/fs/mbcache.c
index e519e45..a273ebd 100644
--- a/fs/mbcache.c
+++ b/fs/mbcache.c
@@ -195,7 +195,7 @@ mb_cache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 static struct shrinker mb_cache_shrinker = {
 	.count_objects = mb_cache_shrink_count,
 	.scan_objects = mb_cache_shrink_scan,
-	.seeks = DEFAULT_SEEKS,
+	.seeks = 1,
 };
 
 /*
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 910ed90..e96a512 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -362,7 +362,7 @@ static void unregister_nfs4_fs(void)
 static struct shrinker acl_shrinker = {
 	.count_objects	= nfs_access_cache_count,
 	.scan_objects	= nfs_access_cache_scan,
-	.seeks		= DEFAULT_SEEKS,
+	.seeks		= 1,
 };
 
 /*
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 831d49a..ff5e0e1 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -718,7 +718,7 @@ dqcache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 static struct shrinker dqcache_shrinker = {
 	.count_objects = dqcache_shrink_count,
 	.scan_objects = dqcache_shrink_scan,
-	.seeks = DEFAULT_SEEKS,
+	.seeks = 1,
 };
 
 /*
diff --git a/fs/super.c b/fs/super.c
index e5f6c2c..6010ac4 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -219,7 +219,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 	s->s_time_gran = 1000000000;
 	s->cleancache_poolid = -1;
 
-	s->s_shrink.seeks = DEFAULT_SEEKS;
+	s->s_shrink.seeks = 1;
 	s->s_shrink.scan_objects = super_cache_scan;
 	s->s_shrink.count_objects = super_cache_count;
 	s->s_shrink.batch = 1024;
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index f69daa5..62a4703 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -51,7 +51,7 @@ struct kmem_cache *ubifs_inode_slab;
 static struct shrinker ubifs_shrinker_info = {
 	.scan_objects = ubifs_shrink_scan,
 	.count_objects = ubifs_shrink_count,
-	.seeks = DEFAULT_SEEKS,
+	.seeks = 1,
 };
 
 /**
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index afe7645..bfd982f 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1667,7 +1667,7 @@ xfs_alloc_buftarg(
 
 	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
 	btp->bt_shrinker.scan_objects = xfs_buftarg_shrink_scan;
-	btp->bt_shrinker.seeks = DEFAULT_SEEKS;
+	btp->bt_shrinker.seeks = 1;
 	btp->bt_shrinker.flags = SHRINKER_NUMA_AWARE;
 	register_shrinker(&btp->bt_shrinker);
 	return btp;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index dd88f0e..4ff8536 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -931,7 +931,7 @@ xfs_qm_init_quotainfo(
 
 	qinf->qi_shrinker.count_objects = xfs_qm_shrink_count;
 	qinf->qi_shrinker.scan_objects = xfs_qm_shrink_scan;
-	qinf->qi_shrinker.seeks = DEFAULT_SEEKS;
+	qinf->qi_shrinker.seeks = 1;
 	qinf->qi_shrinker.flags = SHRINKER_NUMA_AWARE;
 	register_shrinker(&qinf->qi_shrinker);
 	return 0;
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 68c0970..0cd3257 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -60,7 +60,6 @@ struct shrinker {
 	/* objs pending delete, per node */
 	atomic_long_t *nr_deferred;
 };
-#define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
 /* Flags */
 #define SHRINKER_NUMA_AWARE (1 << 0)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 95d1acb..0c2379b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -235,7 +235,7 @@ static unsigned long shrink_huge_zero_page_scan(struct shrinker *shrink,
 static struct shrinker huge_zero_page_shrinker = {
 	.count_objects = shrink_huge_zero_page_count,
 	.scan_objects = shrink_huge_zero_page_scan,
-	.seeks = DEFAULT_SEEKS,
+	.seeks = 1,
 };
 
 #ifdef CONFIG_SYSFS
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 31aa997..f6d716d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -242,11 +242,19 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	 */
 	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
 
-	total_scan = nr;
-	delta = (4 * nr_pages_scanned) / shrinker->seeks;
+	/*
+	 * Assuming it costs one seek to replace an LRU page, we age
+	 * equal percentages of the LRU and ageable caches. This should
+	 * balance the seeks generated by these structures.
+	 *
+	 * To scan an LRU page, we have to move it to an inactive list
+	 * first. Take this into account by doubling nr_pages_scanned.
+	 */
+	delta = (2 * nr_pages_scanned) / shrinker->seeks;
 	delta *= freeable;
 	do_div(delta, lru_pages + 1);
-	total_scan += delta;
+
+	total_scan = nr + delta;
 	if (total_scan < 0) {
 		printk(KERN_ERR
 		"shrink_slab: %pF negative objects to delete nr=%ld\n",
@@ -314,19 +322,10 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 /*
  * Call the shrink functions to age shrinkable caches
  *
- * Here we assume it costs one seek to replace a lru page and that it also
- * takes a seek to recreate a cache object.  With this in mind we age equal
- * percentages of the lru and ageable caches.  This should balance the seeks
- * generated by these structures.
- *
- * If the vm encountered mapped pages on the LRU it increase the pressure on
- * slab to avoid swapping.
- *
- * We do weird things to avoid (scanned*seeks*entries) overflowing 32 bits.
- *
- * `lru_pages' represents the number of on-LRU pages in all the zones which
- * are eligible for the caller's allocation attempt.  It is used for balancing
- * slab reclaim versus page reclaim.
+ * `nr_pages_scanned' and `lru_pages' represent the number of scanned pages and
+ * the total number of on-LRU pages in all the zones which are eligible for the
+ * caller's allocation attempt respectively. They are used for balancing slab
+ * reclaim vs page reclaim.
  *
  * Returns the number of slab objects which we shrunk.
  */
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 5285ead..72a1665 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -819,7 +819,7 @@ rpcauth_uptodatecred(struct rpc_task *task)
 static struct shrinker rpc_cred_shrinker = {
 	.count_objects = rpcauth_cache_shrink_count,
 	.scan_objects = rpcauth_cache_shrink_scan,
-	.seeks = DEFAULT_SEEKS,
+	.seeks = 1,
 };
 
 int __init rpcauth_init_module(void)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
