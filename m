Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE438D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:03:22 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p3JI3Iuh027393
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 11:03:18 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by hpaq12.eem.corp.google.com with ESMTP id p3JI1DhP022540
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 11:03:17 -0700
Received: by qyk29 with SMTP id 29so1754304qyk.10
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 11:03:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303235496-3060-4-git-send-email-yinghan@google.com>
References: <1303235496-3060-1-git-send-email-yinghan@google.com>
	<1303235496-3060-4-git-send-email-yinghan@google.com>
Date: Tue, 19 Apr 2011 11:03:16 -0700
Message-ID: <BANLkTikYY+qT5Ofrieb0eRKyF0=f2S1DyQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] change shrinker API by passing scan_control struct
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee08c372a04a1495214
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

--000e0cd68ee08c372a04a1495214
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 19, 2011 at 10:51 AM, Ying Han <yinghan@google.com> wrote:

> The patch changes each shrinkers API by consolidating the existing
> parameters into scan_control struct. This will simplify any further
> features added w/o touching each file of shrinker.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  arch/x86/kvm/mmu.c                   |    3 ++-
>  drivers/gpu/drm/i915/i915_gem.c      |    5 ++---
>  drivers/gpu/drm/ttm/ttm_page_alloc.c |    1 +
>  drivers/staging/zcache/zcache.c      |    5 ++++-
>  fs/dcache.c                          |    8 ++++++--
>  fs/gfs2/glock.c                      |    5 ++++-
>  fs/inode.c                           |    6 +++++-
>  fs/mbcache.c                         |   11 ++++++-----
>  fs/nfs/dir.c                         |    5 ++++-
>  fs/nfs/internal.h                    |    2 +-
>  fs/quota/dquot.c                     |    6 +++++-
>  fs/xfs/linux-2.6/xfs_buf.c           |    4 ++--
>  fs/xfs/linux-2.6/xfs_sync.c          |    5 +++--
>  fs/xfs/quota/xfs_qm.c                |    5 +++--
>  include/linux/mm.h                   |   12 ++++++------
>  include/linux/swap.h                 |    3 +++
>  mm/vmscan.c                          |   11 +++++++----
>  net/sunrpc/auth.c                    |    5 ++++-
>  18 files changed, 68 insertions(+), 34 deletions(-)
>
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index b6a9963..c07f02a 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -3579,10 +3579,11 @@ static int
> kvm_mmu_remove_some_alloc_mmu_pages(struct kvm *kvm,
>        return kvm_mmu_prepare_zap_page(kvm, page, invalid_list);
>  }
>
> -static int mmu_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t
> gfp_mask)
> +static int mmu_shrink(struct shrinker *shrink, struct scan_control *sc)
>  {
>        struct kvm *kvm;
>        struct kvm *kvm_freed = NULL;
> +       int nr_to_scan = sc->nr_slab_to_reclaim;
>
>        if (nr_to_scan == 0)
>                goto out;
> diff --git a/drivers/gpu/drm/i915/i915_gem.c
> b/drivers/gpu/drm/i915/i915_gem.c
> index 4aaf6cd..4d82218 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -4105,9 +4105,7 @@ i915_gpu_is_active(struct drm_device *dev)
>  }
>
>  static int
> -i915_gem_inactive_shrink(struct shrinker *shrinker,
> -                        int nr_to_scan,
> -                        gfp_t gfp_mask)
> +i915_gem_inactive_shrink(struct shrinker *shrinker, struct scan_control
> *sc)
>  {
>        struct drm_i915_private *dev_priv =
>                container_of(shrinker,
> @@ -4115,6 +4113,7 @@ i915_gem_inactive_shrink(struct shrinker *shrinker,
>                             mm.inactive_shrinker);
>        struct drm_device *dev = dev_priv->dev;
>        struct drm_i915_gem_object *obj, *next;
> +       int nr_to_scan = sc->nr_slab_to_reclaim;
>        int cnt;
>
>        if (!mutex_trylock(&dev->struct_mutex))
> diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c
> b/drivers/gpu/drm/ttm/ttm_page_alloc.c
> index 737a2a2..c014ac2 100644
> --- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
> +++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
> @@ -401,6 +401,7 @@ static int ttm_pool_mm_shrink(struct shrinker *shrink,
> int shrink_pages, gfp_t g
>        unsigned i;
>        unsigned pool_offset = atomic_add_return(1, &start_pool);
>        struct ttm_page_pool *pool;
> +       int shrink_pages = sc->nr_slab_to_reclaim;
>
>        pool_offset = pool_offset % NUM_POOLS;
>        /* select start pool in round robin fashion */
> diff --git a/drivers/staging/zcache/zcache.c
> b/drivers/staging/zcache/zcache.c
> index b8a2b30..4b1674c 100644
> --- a/drivers/staging/zcache/zcache.c
> +++ b/drivers/staging/zcache/zcache.c
> @@ -1181,9 +1181,12 @@ static bool zcache_freeze;
>  /*
>  * zcache shrinker interface (only useful for ephemeral pages, so zbud
> only)
>  */
> -static int shrink_zcache_memory(struct shrinker *shrink, int nr, gfp_t
> gfp_mask)
> +static int shrink_zcache_memory(struct shrinker *shrink,
> +                               struct scan_control *sc)
>  {
>        int ret = -1;
> +       int nr = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
>
>        if (nr >= 0) {
>                if (!(gfp_mask & __GFP_FS))
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 2f65679..d9c364a 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1237,7 +1237,7 @@ void shrink_dcache_parent(struct dentry * parent)
>  EXPORT_SYMBOL(shrink_dcache_parent);
>
>  /*
> - * Scan `nr' dentries and return the number which remain.
> + * Scan `sc->nr_slab_to_reclaim' dentries and return the number which
> remain.
>  *
>  * We need to avoid reentering the filesystem if the caller is performing a
>  * GFP_NOFS allocation attempt.  One example deadlock is:
> @@ -1248,8 +1248,12 @@ EXPORT_SYMBOL(shrink_dcache_parent);
>  *
>  * In this case we return -1 to tell the caller that we baled.
>  */
> -static int shrink_dcache_memory(struct shrinker *shrink, int nr, gfp_t
> gfp_mask)
> +static int shrink_dcache_memory(struct shrinker *shrink,
> +                               struct scan_control *sc)
>  {
> +       int nr = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
> +
>        if (nr) {
>                if (!(gfp_mask & __GFP_FS))
>                        return -1;
> diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
> index bc36aef..eddbcdf 100644
> --- a/fs/gfs2/glock.c
> +++ b/fs/gfs2/glock.c
> @@ -1348,11 +1348,14 @@ void gfs2_glock_complete(struct gfs2_glock *gl, int
> ret)
>  }
>
>
> -static int gfs2_shrink_glock_memory(struct shrinker *shrink, int nr, gfp_t
> gfp_mask)
> +static int gfs2_shrink_glock_memory(struct shrinker *shrink,
> +                                   struct scan_control *sc)
>  {
>        struct gfs2_glock *gl;
>        int may_demote;
>        int nr_skipped = 0;
> +       int nr = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
>        LIST_HEAD(skipped);
>
>        if (nr == 0)
> diff --git a/fs/inode.c b/fs/inode.c
> index f4018ab..48de194 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -703,8 +703,12 @@ static void prune_icache(int nr_to_scan)
>  * This function is passed the number of inodes to scan, and it returns the
>  * total number of remaining possibly-reclaimable inodes.
>  */
> -static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t
> gfp_mask)
> +static int shrink_icache_memory(struct shrinker *shrink,
> +                               struct scan_control *sc)
>  {
> +       int nr = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
> +
>        if (nr) {
>                /*
>                 * Nasty deadlock avoidance.  We may hold various FS locks,
> diff --git a/fs/mbcache.c b/fs/mbcache.c
> index a25444ab..580f10d 100644
> --- a/fs/mbcache.c
> +++ b/fs/mbcache.c
> @@ -36,7 +36,7 @@
>  #include <linux/sched.h>
>  #include <linux/init.h>
>  #include <linux/mbcache.h>
> -
> +#include <linux/swap.h>
>
>  #ifdef MB_CACHE_DEBUG
>  # define mb_debug(f...) do { \
> @@ -90,7 +90,7 @@ static DEFINE_SPINLOCK(mb_cache_spinlock);
>  * What the mbcache registers as to get shrunk dynamically.
>  */
>
> -static int mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan,
> gfp_t gfp_mask);
> +static int mb_cache_shrink_fn(struct shrinker *shrink, struct scan_control
> *sc);
>
>  static struct shrinker mb_cache_shrinker = {
>        .shrink = mb_cache_shrink_fn,
> @@ -156,18 +156,19 @@ forget:
>  * gets low.
>  *
>  * @shrink: (ignored)
> - * @nr_to_scan: Number of objects to scan
> - * @gfp_mask: (ignored)
> + * @sc: scan_control passed from reclaim
>  *
>  * Returns the number of objects which are present in the cache.
>  */
>  static int
> -mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t
> gfp_mask)
> +mb_cache_shrink_fn(struct shrinker *shrink, struct scan_control *sc)
>  {
>        LIST_HEAD(free_list);
>        struct mb_cache *cache;
>        struct mb_cache_entry *entry, *tmp;
>        int count = 0;
> +       int nr_to_scan = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
>
>        mb_debug("trying to free %d entries", nr_to_scan);
>        spin_lock(&mb_cache_spinlock);
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 2c3eb33..d196a77 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -35,6 +35,7 @@
>  #include <linux/sched.h>
>  #include <linux/kmemleak.h>
>  #include <linux/xattr.h>
> +#include <linux/swap.h>
>
>  #include "delegation.h"
>  #include "iostat.h"
> @@ -1962,11 +1963,13 @@ static void nfs_access_free_list(struct list_head
> *head)
>        }
>  }
>
> -int nfs_access_cache_shrinker(struct shrinker *shrink, int nr_to_scan,
> gfp_t gfp_mask)
> +int nfs_access_cache_shrinker(struct shrinker *shrink, struct scan_control
> *sc)
>  {
>        LIST_HEAD(head);
>        struct nfs_inode *nfsi, *next;
>        struct nfs_access_entry *cache;
> +       int nr_to_scan = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
>
>        if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
>                return (nr_to_scan == 0) ? 0 : -1;
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index cf9fdbd..243c7a0 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -218,7 +218,7 @@ void nfs_close_context(struct nfs_open_context *ctx,
> int is_sync);
>
>  /* dir.c */
>  extern int nfs_access_cache_shrinker(struct shrinker *shrink,
> -                                       int nr_to_scan, gfp_t gfp_mask);
> +                                       struct scan_control *sc);
>
>  /* inode.c */
>  extern struct workqueue_struct *nfsiod_workqueue;
> diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
> index a2a622e..e85bf4b 100644
> --- a/fs/quota/dquot.c
> +++ b/fs/quota/dquot.c
> @@ -77,6 +77,7 @@
>  #include <linux/capability.h>
>  #include <linux/quotaops.h>
>  #include <linux/writeback.h> /* for inode_lock, oddly enough.. */
> +#include <linux/swap.h>
>
>  #include <asm/uaccess.h>
>
> @@ -696,8 +697,11 @@ static void prune_dqcache(int count)
>  * This is called from kswapd when we think we need some
>  * more memory
>  */
> -static int shrink_dqcache_memory(struct shrinker *shrink, int nr, gfp_t
> gfp_mask)
> +static int shrink_dqcache_memory(struct shrinker *shrink,
> +                                struct scan_control *sc)
>  {
> +       int nr = sc->nr_slab_to_reclaim;
> +
>        if (nr) {
>                spin_lock(&dq_list_lock);
>                prune_dqcache(nr);
> diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c
> index 5cb230f..5af106c 100644
> --- a/fs/xfs/linux-2.6/xfs_buf.c
> +++ b/fs/xfs/linux-2.6/xfs_buf.c
> @@ -1542,12 +1542,12 @@ restart:
>  int
>  xfs_buftarg_shrink(
>        struct shrinker         *shrink,
> -       int                     nr_to_scan,
> -       gfp_t                   mask)
> +       struct scan_control     *sc)
>  {
>        struct xfs_buftarg      *btp = container_of(shrink,
>                                        struct xfs_buftarg, bt_shrinker);
>        struct xfs_buf          *bp;
> +       int nr_to_scan = sc->nr_slab_to_reclaim;
>        LIST_HEAD(dispose);
>
>        if (!nr_to_scan)
> diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
> index 6c10f1d..208a522 100644
> --- a/fs/xfs/linux-2.6/xfs_sync.c
> +++ b/fs/xfs/linux-2.6/xfs_sync.c
> @@ -998,13 +998,14 @@ xfs_reclaim_inodes(
>  static int
>  xfs_reclaim_inode_shrink(
>        struct shrinker *shrink,
> -       int             nr_to_scan,
> -       gfp_t           gfp_mask)
> +       struct scan_control *sc)
>  {
>        struct xfs_mount *mp;
>        struct xfs_perag *pag;
>        xfs_agnumber_t  ag;
>        int             reclaimable;
> +       int nr_to_scan = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
>
>        mp = container_of(shrink, struct xfs_mount, m_inode_shrink);
>        if (nr_to_scan) {
> diff --git a/fs/xfs/quota/xfs_qm.c b/fs/xfs/quota/xfs_qm.c
> index 254ee06..6f7532a 100644
> --- a/fs/xfs/quota/xfs_qm.c
> +++ b/fs/xfs/quota/xfs_qm.c
> @@ -2016,10 +2016,11 @@ xfs_qm_shake_freelist(
>  STATIC int
>  xfs_qm_shake(
>        struct shrinker *shrink,
> -       int             nr_to_scan,
> -       gfp_t           gfp_mask)
> +       struct scan_control *sc)
>  {
>        int     ndqused, nfree, n;
> +       int nr_to_scan = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
>
>        if (!kmem_shake_allow(gfp_mask))
>                return 0;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 42c2bf4..fba7ed9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1134,11 +1134,11 @@ static inline void sync_mm_rss(struct task_struct
> *task, struct mm_struct *mm)
>  /*
>  * A callback you can register to apply pressure to ageable caches.
>  *
> - * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
> - * look through the least-recently-used 'nr_to_scan' entries and
> - * attempt to free them up.  It should return the number of objects
> - * which remain in the cache.  If it returns -1, it means it cannot do
> - * any scanning at this time (eg. there is a risk of deadlock).
> + * 'shrink' is passed scan_control which includes a count
> 'nr_slab_to_reclaim'
> + * and a 'gfpmask'.  It should look through the least-recently-used
> + * 'nr_slab_to_reclaim' entries and attempt to free them up.  It should
> return
> + * the number of objects which remain in the cache.  If it returns -1, it
> means
> + * it cannot do any scanning at this time (eg. there is a risk of
> deadlock).
>  *
>  * The 'gfpmask' refers to the allocation we are currently trying to
>  * fulfil.
> @@ -1147,7 +1147,7 @@ static inline void sync_mm_rss(struct task_struct
> *task, struct mm_struct *mm)
>  * querying the cache size, so a fastpath for that case is appropriate.
>  */
>  struct shrinker {
> -       int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_mask);
> +       int (*shrink)(struct shrinker *, struct scan_control *sc);
>        int seeks;      /* seeks to recreate an obj */
>
>        /* These are for internal use */
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index cb48fbd..9ba29f8 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -75,6 +75,9 @@ struct scan_control {
>         * are scanned.
>         */
>        nodemask_t      *nodemask;
> +
> +       /* How many slab objects shrinker() should reclaim */
> +       unsigned long nr_slab_to_reclaim;
>  };
>
>  #define SWAP_FLAG_PREFER       0x8000  /* set if swap priority specified
> */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9662166..81d89b2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -177,7 +177,8 @@ unsigned long shrink_slab(struct scan_control *sc,
> unsigned long lru_pages)
>                unsigned long total_scan;
>                unsigned long max_pass;
>
> -               max_pass = (*shrinker->shrink)(shrinker, 0, gfp_mask);
> +               sc->nr_slab_to_reclaim = 0;
> +               max_pass = (*shrinker->shrink)(shrinker, sc);
>                delta = (4 * scanned) / shrinker->seeks;
>                delta *= max_pass;
>                do_div(delta, lru_pages + 1);
> @@ -205,9 +206,11 @@ unsigned long shrink_slab(struct scan_control *sc,
> unsigned long lru_pages)
>                        int shrink_ret;
>                        int nr_before;
>
> -                       nr_before = (*shrinker->shrink)(shrinker, 0,
> gfp_mask);
> -                       shrink_ret = (*shrinker->shrink)(shrinker,
> this_scan,
> -                                                               gfp_mask);
> +                       sc->nr_slab_to_reclaim = 0;
> +                       nr_before = (*shrinker->shrink)(shrinker, sc);
> +                       sc->nr_slab_to_reclaim = this_scan;
> +                       shrink_ret = (*shrinker->shrink)(shrinker, sc);
> +
>                        if (shrink_ret == -1)
>                                break;
>                        if (shrink_ret < nr_before)
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 67e3127..23858c9 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -14,6 +14,7 @@
>  #include <linux/hash.h>
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/spinlock.h>
> +#include <linux/swap.h>
>
>  #ifdef RPC_DEBUG
>  # define RPCDBG_FACILITY       RPCDBG_AUTH
> @@ -326,10 +327,12 @@ rpcauth_prune_expired(struct list_head *free, int
> nr_to_scan)
>  * Run memory cache shrinker.
>  */
>  static int
> -rpcauth_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t
> gfp_mask)
> +rpcauth_cache_shrinker(struct shrinker *shrink, struct scan_control *sc)
>  {
>        LIST_HEAD(free);
>        int res;
> +       int nr_to_scan = sc->nr_slab_to_reclaim;
> +       gfp_t gfp_mask = sc->gfp_mask;
>
>        if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
>                return (nr_to_scan == 0) ? 0 : -1;
> --
> 1.7.3.1
>
>

--000e0cd68ee08c372a04a1495214
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 19, 2011 at 10:51 AM, Ying H=
an <span dir=3D"ltr">&lt;<a href=3D"mailto:yinghan@google.com">yinghan@goog=
le.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
The patch changes each shrinkers API by consolidating the existing<br>
parameters into scan_control struct. This will simplify any further<br>
features added w/o touching each file of shrinker.<br>
<br>
Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@g=
oogle.com</a>&gt;<br>
---<br>
=A0arch/x86/kvm/mmu.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 ++-<br=
>
=A0drivers/gpu/drm/i915/i915_gem.c =A0 =A0 =A0| =A0 =A05 ++---<br>
=A0drivers/gpu/drm/ttm/ttm_page_alloc.c | =A0 =A01 +<br>
=A0drivers/staging/zcache/zcache.c =A0 =A0 =A0| =A0 =A05 ++++-<br>
=A0fs/dcache.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
8 ++++++--<br>
=A0fs/gfs2/glock.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 ++=
++-<br>
=A0fs/inode.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
6 +++++-<br>
=A0fs/mbcache.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 ++=
++++-----<br>
=A0fs/nfs/dir.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 =
++++-<br>
=A0fs/nfs/internal.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-<b=
r>
=A0fs/quota/dquot.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 ++++=
+-<br>
=A0fs/xfs/linux-2.6/xfs_buf.c =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++--<br>
=A0fs/xfs/linux-2.6/xfs_sync.c =A0 =A0 =A0 =A0 =A0| =A0 =A05 +++--<br>
=A0fs/xfs/quota/xfs_qm.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 +++--<br=
>
=A0include/linux/mm.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 12 ++++++--=
----<br>
=A0include/linux/swap.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +++<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 =
+++++++----<br>
=A0net/sunrpc/auth.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A05 ++++=
-<br>
=A018 files changed, 68 insertions(+), 34 deletions(-)<br>
<br>
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c<br>
index b6a9963..c07f02a 100644<br>
--- a/arch/x86/kvm/mmu.c<br>
+++ b/arch/x86/kvm/mmu.c<br>
@@ -3579,10 +3579,11 @@ static int kvm_mmu_remove_some_alloc_mmu_pages(stru=
ct kvm *kvm,<br>
 =A0 =A0 =A0 =A0return kvm_mmu_prepare_zap_page(kvm, page, invalid_list);<b=
r>
=A0}<br>
<br>
-static int mmu_shrink(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_m=
ask)<br>
+static int mmu_shrink(struct shrinker *shrink, struct scan_control *sc)<br=
>
=A0{<br>
 =A0 =A0 =A0 =A0struct kvm *kvm;<br>
 =A0 =A0 =A0 =A0struct kvm *kvm_freed =3D NULL;<br>
+ =A0 =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
<br>
 =A0 =A0 =A0 =A0if (nr_to_scan =3D=3D 0)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_ge=
m.c<br>
index 4aaf6cd..4d82218 100644<br>
--- a/drivers/gpu/drm/i915/i915_gem.c<br>
+++ b/drivers/gpu/drm/i915/i915_gem.c<br>
@@ -4105,9 +4105,7 @@ i915_gpu_is_active(struct drm_device *dev)<br>
=A0}<br>
<br>
=A0static int<br>
-i915_gem_inactive_shrink(struct shrinker *shrinker,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nr_to_scan,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask)<br>
+i915_gem_inactive_shrink(struct shrinker *shrinker, struct scan_control *s=
c)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct drm_i915_private *dev_priv =3D<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0container_of(shrinker,<br>
@@ -4115,6 +4113,7 @@ i915_gem_inactive_shrink(struct shrinker *shrinker,<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mm.inactive_shrink=
er);<br>
 =A0 =A0 =A0 =A0struct drm_device *dev =3D dev_priv-&gt;dev;<br>
 =A0 =A0 =A0 =A0struct drm_i915_gem_object *obj, *next;<br>
+ =A0 =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
 =A0 =A0 =A0 =A0int cnt;<br>
<br>
 =A0 =A0 =A0 =A0if (!mutex_trylock(&amp;dev-&gt;struct_mutex))<br>
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm=
_page_alloc.c<br>
index 737a2a2..c014ac2 100644<br>
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c<br>
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c<br>
@@ -401,6 +401,7 @@ static int ttm_pool_mm_shrink(struct shrinker *shrink, =
int shrink_pages, gfp_t g<br>
 =A0 =A0 =A0 =A0unsigned i;<br>
 =A0 =A0 =A0 =A0unsigned pool_offset =3D atomic_add_return(1, &amp;start_po=
ol);<br>
 =A0 =A0 =A0 =A0struct ttm_page_pool *pool;<br>
+ =A0 =A0 =A0 int shrink_pages =3D sc-&gt;nr_slab_to_reclaim;<br>
<br>
 =A0 =A0 =A0 =A0pool_offset =3D pool_offset % NUM_POOLS;<br>
 =A0 =A0 =A0 =A0/* select start pool in round robin fashion */<br>
diff --git a/drivers/staging/zcache/zcache.c b/drivers/staging/zcache/zcach=
e.c<br>
index b8a2b30..4b1674c 100644<br>
--- a/drivers/staging/zcache/zcache.c<br>
+++ b/drivers/staging/zcache/zcache.c<br>
@@ -1181,9 +1181,12 @@ static bool zcache_freeze;<br>
=A0/*<br>
 =A0* zcache shrinker interface (only useful for ephemeral pages, so zbud o=
nly)<br>
 =A0*/<br>
-static int shrink_zcache_memory(struct shrinker *shrink, int nr, gfp_t gfp=
_mask)<br>
+static int shrink_zcache_memory(struct shrinker *shrink,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_c=
ontrol *sc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0int ret =3D -1;<br>
+ =A0 =A0 =A0 int nr =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
<br>
 =A0 =A0 =A0 =A0if (nr &gt;=3D 0) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(gfp_mask &amp; __GFP_FS))<br>
diff --git a/fs/dcache.c b/fs/dcache.c<br>
index 2f65679..d9c364a 100644<br>
--- a/fs/dcache.c<br>
+++ b/fs/dcache.c<br>
@@ -1237,7 +1237,7 @@ void shrink_dcache_parent(struct dentry * parent)<br>
=A0EXPORT_SYMBOL(shrink_dcache_parent);<br>
<br>
=A0/*<br>
- * Scan `nr&#39; dentries and return the number which remain.<br>
+ * Scan `sc-&gt;nr_slab_to_reclaim&#39; dentries and return the number whi=
ch remain.<br>
 =A0*<br>
 =A0* We need to avoid reentering the filesystem if the caller is performin=
g a<br>
 =A0* GFP_NOFS allocation attempt. =A0One example deadlock is:<br>
@@ -1248,8 +1248,12 @@ EXPORT_SYMBOL(shrink_dcache_parent);<br>
 =A0*<br>
 =A0* In this case we return -1 to tell the caller that we baled.<br>
 =A0*/<br>
-static int shrink_dcache_memory(struct shrinker *shrink, int nr, gfp_t gfp=
_mask)<br>
+static int shrink_dcache_memory(struct shrinker *shrink,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_c=
ontrol *sc)<br>
=A0{<br>
+ =A0 =A0 =A0 int nr =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
+<br>
 =A0 =A0 =A0 =A0if (nr) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(gfp_mask &amp; __GFP_FS))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;<br>
diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c<br>
index bc36aef..eddbcdf 100644<br>
--- a/fs/gfs2/glock.c<br>
+++ b/fs/gfs2/glock.c<br>
@@ -1348,11 +1348,14 @@ void gfs2_glock_complete(struct gfs2_glock *gl, int=
 ret)<br>
=A0}<br>
<br>
<br>
-static int gfs2_shrink_glock_memory(struct shrinker *shrink, int nr, gfp_t=
 gfp_mask)<br>
+static int gfs2_shrink_glock_memory(struct shrinker *shrink,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struc=
t scan_control *sc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct gfs2_glock *gl;<br>
 =A0 =A0 =A0 =A0int may_demote;<br>
 =A0 =A0 =A0 =A0int nr_skipped =3D 0;<br>
+ =A0 =A0 =A0 int nr =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
 =A0 =A0 =A0 =A0LIST_HEAD(skipped);<br>
<br>
 =A0 =A0 =A0 =A0if (nr =3D=3D 0)<br>
diff --git a/fs/inode.c b/fs/inode.c<br>
index f4018ab..48de194 100644<br>
--- a/fs/inode.c<br>
+++ b/fs/inode.c<br>
@@ -703,8 +703,12 @@ static void prune_icache(int nr_to_scan)<br>
 =A0* This function is passed the number of inodes to scan, and it returns =
the<br>
 =A0* total number of remaining possibly-reclaimable inodes.<br>
 =A0*/<br>
-static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t gfp=
_mask)<br>
+static int shrink_icache_memory(struct shrinker *shrink,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_c=
ontrol *sc)<br>
=A0{<br>
+ =A0 =A0 =A0 int nr =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
+<br>
 =A0 =A0 =A0 =A0if (nr) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Nasty deadlock avoidance. =A0We may hold=
 various FS locks,<br>
diff --git a/fs/mbcache.c b/fs/mbcache.c<br>
index a25444ab..580f10d 100644<br>
--- a/fs/mbcache.c<br>
+++ b/fs/mbcache.c<br>
@@ -36,7 +36,7 @@<br>
=A0#include &lt;linux/sched.h&gt;<br>
=A0#include &lt;linux/init.h&gt;<br>
=A0#include &lt;linux/mbcache.h&gt;<br>
-<br>
+#include &lt;linux/swap.h&gt;<br>
<br>
=A0#ifdef MB_CACHE_DEBUG<br>
=A0# define mb_debug(f...) do { \<br>
@@ -90,7 +90,7 @@ static DEFINE_SPINLOCK(mb_cache_spinlock);<br>
 =A0* What the mbcache registers as to get shrunk dynamically.<br>
 =A0*/<br>
<br>
-static int mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp=
_t gfp_mask);<br>
+static int mb_cache_shrink_fn(struct shrinker *shrink, struct scan_control=
 *sc);<br>
<br>
=A0static struct shrinker mb_cache_shrinker =3D {<br>
 =A0 =A0 =A0 =A0.shrink =3D mb_cache_shrink_fn,<br>
@@ -156,18 +156,19 @@ forget:<br>
 =A0* gets low.<br>
 =A0*<br>
 =A0* @shrink: (ignored)<br>
- * @nr_to_scan: Number of objects to scan<br>
- * @gfp_mask: (ignored)<br>
+ * @sc: scan_control passed from reclaim<br>
 =A0*<br>
 =A0* Returns the number of objects which are present in the cache.<br>
 =A0*/<br>
=A0static int<br>
-mb_cache_shrink_fn(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask=
)<br>
+mb_cache_shrink_fn(struct shrinker *shrink, struct scan_control *sc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0LIST_HEAD(free_list);<br>
 =A0 =A0 =A0 =A0struct mb_cache *cache;<br>
 =A0 =A0 =A0 =A0struct mb_cache_entry *entry, *tmp;<br>
 =A0 =A0 =A0 =A0int count =3D 0;<br>
+ =A0 =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
<br>
 =A0 =A0 =A0 =A0mb_debug(&quot;trying to free %d entries&quot;, nr_to_scan)=
;<br>
 =A0 =A0 =A0 =A0spin_lock(&amp;mb_cache_spinlock);<br>
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c<br>
index 2c3eb33..d196a77 100644<br>
--- a/fs/nfs/dir.c<br>
+++ b/fs/nfs/dir.c<br>
@@ -35,6 +35,7 @@<br>
=A0#include &lt;linux/sched.h&gt;<br>
=A0#include &lt;linux/kmemleak.h&gt;<br>
=A0#include &lt;linux/xattr.h&gt;<br>
+#include &lt;linux/swap.h&gt;<br>
<br>
=A0#include &quot;delegation.h&quot;<br>
=A0#include &quot;iostat.h&quot;<br>
@@ -1962,11 +1963,13 @@ static void nfs_access_free_list(struct list_head *=
head)<br>
 =A0 =A0 =A0 =A0}<br>
=A0}<br>
<br>
-int nfs_access_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp=
_t gfp_mask)<br>
+int nfs_access_cache_shrinker(struct shrinker *shrink, struct scan_control=
 *sc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0LIST_HEAD(head);<br>
 =A0 =A0 =A0 =A0struct nfs_inode *nfsi, *next;<br>
 =A0 =A0 =A0 =A0struct nfs_access_entry *cache;<br>
+ =A0 =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
<br>
 =A0 =A0 =A0 =A0if ((gfp_mask &amp; GFP_KERNEL) !=3D GFP_KERNEL)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return (nr_to_scan =3D=3D 0) ? 0 : -1;<br>
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h<br>
index cf9fdbd..243c7a0 100644<br>
--- a/fs/nfs/internal.h<br>
+++ b/fs/nfs/internal.h<br>
@@ -218,7 +218,7 @@ void nfs_close_context(struct nfs_open_context *ctx, in=
t is_sync);<br>
<br>
=A0/* dir.c */<br>
=A0extern int nfs_access_cache_shrinker(struct shrinker *shrink,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int nr_to_scan, gfp_t gfp_mask);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc);<br>
<br>
=A0/* inode.c */<br>
=A0extern struct workqueue_struct *nfsiod_workqueue;<br>
diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c<br>
index a2a622e..e85bf4b 100644<br>
--- a/fs/quota/dquot.c<br>
+++ b/fs/quota/dquot.c<br>
@@ -77,6 +77,7 @@<br>
=A0#include &lt;linux/capability.h&gt;<br>
=A0#include &lt;linux/quotaops.h&gt;<br>
=A0#include &lt;linux/writeback.h&gt; /* for inode_lock, oddly enough.. */<=
br>
+#include &lt;linux/swap.h&gt;<br>
<br>
=A0#include &lt;asm/uaccess.h&gt;<br>
<br>
@@ -696,8 +697,11 @@ static void prune_dqcache(int count)<br>
 =A0* This is called from kswapd when we think we need some<br>
 =A0* more memory<br>
 =A0*/<br>
-static int shrink_dqcache_memory(struct shrinker *shrink, int nr, gfp_t gf=
p_mask)<br>
+static int shrink_dqcache_memory(struct shrinker *shrink,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sca=
n_control *sc)<br>
=A0{<br>
+ =A0 =A0 =A0 int nr =3D sc-&gt;nr_slab_to_reclaim;<br>
+<br>
 =A0 =A0 =A0 =A0if (nr) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&amp;dq_list_lock);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prune_dqcache(nr);<br>
diff --git a/fs/xfs/linux-2.6/xfs_buf.c b/fs/xfs/linux-2.6/xfs_buf.c<br>
index 5cb230f..5af106c 100644<br>
--- a/fs/xfs/linux-2.6/xfs_buf.c<br>
+++ b/fs/xfs/linux-2.6/xfs_buf.c<br>
@@ -1542,12 +1542,12 @@ restart:<br>
=A0int<br>
=A0xfs_buftarg_shrink(<br>
 =A0 =A0 =A0 =A0struct shrinker =A0 =A0 =A0 =A0 *shrink,<br>
- =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_scan,<br>
- =A0 =A0 =A0 gfp_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask)<br>
+ =A0 =A0 =A0 struct scan_control =A0 =A0 *sc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct xfs_buftarg =A0 =A0 =A0*btp =3D container_of(shrink,=
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct xfs_buftarg, bt_shrinker);<br>
 =A0 =A0 =A0 =A0struct xfs_buf =A0 =A0 =A0 =A0 =A0*bp;<br>
+ =A0 =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
 =A0 =A0 =A0 =A0LIST_HEAD(dispose);<br>
<br>
 =A0 =A0 =A0 =A0if (!nr_to_scan)<br>
diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c<br>
index 6c10f1d..208a522 100644<br>
--- a/fs/xfs/linux-2.6/xfs_sync.c<br>
+++ b/fs/xfs/linux-2.6/xfs_sync.c<br>
@@ -998,13 +998,14 @@ xfs_reclaim_inodes(<br>
=A0static int<br>
=A0xfs_reclaim_inode_shrink(<br>
 =A0 =A0 =A0 =A0struct shrinker *shrink,<br>
- =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 nr_to_scan,<br>
- =A0 =A0 =A0 gfp_t =A0 =A0 =A0 =A0 =A0 gfp_mask)<br>
+ =A0 =A0 =A0 struct scan_control *sc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct xfs_mount *mp;<br>
 =A0 =A0 =A0 =A0struct xfs_perag *pag;<br>
 =A0 =A0 =A0 =A0xfs_agnumber_t =A0ag;<br>
 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 reclaimable;<br>
+ =A0 =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
<br>
 =A0 =A0 =A0 =A0mp =3D container_of(shrink, struct xfs_mount, m_inode_shrin=
k);<br>
 =A0 =A0 =A0 =A0if (nr_to_scan) {<br>
diff --git a/fs/xfs/quota/xfs_qm.c b/fs/xfs/quota/xfs_qm.c<br>
index 254ee06..6f7532a 100644<br>
--- a/fs/xfs/quota/xfs_qm.c<br>
+++ b/fs/xfs/quota/xfs_qm.c<br>
@@ -2016,10 +2016,11 @@ xfs_qm_shake_freelist(<br>
=A0STATIC int<br>
=A0xfs_qm_shake(<br>
 =A0 =A0 =A0 =A0struct shrinker *shrink,<br>
- =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 nr_to_scan,<br>
- =A0 =A0 =A0 gfp_t =A0 =A0 =A0 =A0 =A0 gfp_mask)<br>
+ =A0 =A0 =A0 struct scan_control *sc)<br>
=A0{<br>
 =A0 =A0 =A0 =A0int =A0 =A0 ndqused, nfree, n;<br>
+ =A0 =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
<br>
 =A0 =A0 =A0 =A0if (!kmem_shake_allow(gfp_mask))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;<br>
diff --git a/include/linux/mm.h b/include/linux/mm.h<br>
index 42c2bf4..fba7ed9 100644<br>
--- a/include/linux/mm.h<br>
+++ b/include/linux/mm.h<br>
@@ -1134,11 +1134,11 @@ static inline void sync_mm_rss(struct task_struct *=
task, struct mm_struct *mm)<br>
=A0/*<br>
 =A0* A callback you can register to apply pressure to ageable caches.<br>
 =A0*<br>
- * &#39;shrink&#39; is passed a count &#39;nr_to_scan&#39; and a &#39;gfpm=
ask&#39;. =A0It should<br>
- * look through the least-recently-used &#39;nr_to_scan&#39; entries and<b=
r>
- * attempt to free them up. =A0It should return the number of objects<br>
- * which remain in the cache. =A0If it returns -1, it means it cannot do<b=
r>
- * any scanning at this time (eg. there is a risk of deadlock).<br>
+ * &#39;shrink&#39; is passed scan_control which includes a count &#39;nr_=
slab_to_reclaim&#39;<br>
+ * and a &#39;gfpmask&#39;. =A0It should look through the least-recently-u=
sed<br>
+ * &#39;nr_slab_to_reclaim&#39; entries and attempt to free them up. =A0It=
 should return<br>
+ * the number of objects which remain in the cache. =A0If it returns -1, i=
t means<br>
+ * it cannot do any scanning at this time (eg. there is a risk of deadlock=
).<br>
 =A0*<br>
 =A0* The &#39;gfpmask&#39; refers to the allocation we are currently tryin=
g to<br>
 =A0* fulfil.<br>
@@ -1147,7 +1147,7 @@ static inline void sync_mm_rss(struct task_struct *ta=
sk, struct mm_struct *mm)<br>
 =A0* querying the cache size, so a fastpath for that case is appropriate.<=
br>
 =A0*/<br>
=A0struct shrinker {<br>
- =A0 =A0 =A0 int (*shrink)(struct shrinker *, int nr_to_scan, gfp_t gfp_ma=
sk);<br>
+ =A0 =A0 =A0 int (*shrink)(struct shrinker *, struct scan_control *sc);<br=
>
 =A0 =A0 =A0 =A0int seeks; =A0 =A0 =A0/* seeks to recreate an obj */<br>
<br>
 =A0 =A0 =A0 =A0/* These are for internal use */<br>
diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
index cb48fbd..9ba29f8 100644<br>
--- a/include/linux/swap.h<br>
+++ b/include/linux/swap.h<br>
@@ -75,6 +75,9 @@ struct scan_control {<br>
 =A0 =A0 =A0 =A0 * are scanned.<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0nodemask_t =A0 =A0 =A0*nodemask;<br>
+<br>
+ =A0 =A0 =A0 /* How many slab objects shrinker() should reclaim */<br>
+ =A0 =A0 =A0 unsigned long nr_slab_to_reclaim;<br>
=A0};<br>
<br>
=A0#define SWAP_FLAG_PREFER =A0 =A0 =A0 0x8000 =A0/* set if swap priority s=
pecified */<br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
index 9662166..81d89b2 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -177,7 +177,8 @@ unsigned long shrink_slab(struct scan_control *sc, unsi=
gned long lru_pages)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long total_scan;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long max_pass;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 max_pass =3D (*shrinker-&gt;shrink)(shrinker,=
 0, gfp_mask);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_slab_to_reclaim =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 max_pass =3D (*shrinker-&gt;shrink)(shrinker,=
 sc);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta =3D (4 * scanned) / shrinker-&gt;seek=
s;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delta *=3D max_pass;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_div(delta, lru_pages + 1);<br>
@@ -205,9 +206,11 @@ unsigned long shrink_slab(struct scan_control *sc, uns=
igned long lru_pages)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int shrink_ret;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nr_before;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_before =3D (*shrinker-&gt;=
shrink)(shrinker, 0, gfp_mask);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_ret =3D (*shrinker-&gt=
;shrink)(shrinker, this_scan,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_mask);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_slab_to_reclaim =3D=
 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_before =3D (*shrinker-&gt;=
shrink)(shrinker, sc);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_slab_to_reclaim =3D=
 this_scan;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_ret =3D (*shrinker-&gt=
;shrink)(shrinker, sc);<br>
+<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (shrink_ret =3D=3D -1)<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (shrink_ret &lt; nr_befo=
re)<br>
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c<br>
index 67e3127..23858c9 100644<br>
--- a/net/sunrpc/auth.c<br>
+++ b/net/sunrpc/auth.c<br>
@@ -14,6 +14,7 @@<br>
=A0#include &lt;linux/hash.h&gt;<br>
=A0#include &lt;linux/sunrpc/clnt.h&gt;<br>
=A0#include &lt;linux/spinlock.h&gt;<br>
+#include &lt;linux/swap.h&gt;<br>
<br>
=A0#ifdef RPC_DEBUG<br>
=A0# define RPCDBG_FACILITY =A0 =A0 =A0 RPCDBG_AUTH<br>
@@ -326,10 +327,12 @@ rpcauth_prune_expired(struct list_head *free, int nr_=
to_scan)<br>
 =A0* Run memory cache shrinker.<br>
 =A0*/<br>
=A0static int<br>
-rpcauth_cache_shrinker(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_=
mask)<br>
+rpcauth_cache_shrinker(struct shrinker *shrink, struct scan_control *sc)<b=
r>
=A0{<br>
 =A0 =A0 =A0 =A0LIST_HEAD(free);<br>
 =A0 =A0 =A0 =A0int res;<br>
+ =A0 =A0 =A0 int nr_to_scan =3D sc-&gt;nr_slab_to_reclaim;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
<br>
 =A0 =A0 =A0 =A0if ((gfp_mask &amp; GFP_KERNEL) !=3D GFP_KERNEL)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return (nr_to_scan =3D=3D 0) ? 0 : -1;<br>
<font color=3D"#888888">--<br>
1.7.3.1<br>
<br>
</font></blockquote></div><br>

--000e0cd68ee08c372a04a1495214--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
