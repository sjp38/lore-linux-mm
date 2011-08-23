Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A47990013D
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 05:33:36 -0400 (EDT)
Subject: Re: [PATCH 05/13] mm: convert shrinkers to use new API
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1314089786-20535-6-git-send-email-david@fromorbit.com>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
	 <1314089786-20535-6-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Aug 2011 10:35:31 +0100
Message-ID: <1314092131.2730.23.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

Hi,

On Tue, 2011-08-23 at 18:56 +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Modify shrink_slab() to use the new .count_objects/.scan_objects API
> and implement the callouts for all the existing shrinkers.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>

GFS2 bits:
Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Looks good to me,

Steve.

> ---
>  Documentation/filesystems/vfs.txt    |   11 +++--
>  arch/x86/kvm/mmu.c                   |   16 ++++---
>  drivers/gpu/drm/i915/i915_dma.c      |    4 +-
>  drivers/gpu/drm/i915/i915_gem.c      |   49 ++++++++++++++---------
>  drivers/gpu/drm/ttm/ttm_page_alloc.c |   14 ++++--
>  drivers/staging/zcache/zcache-main.c |   45 ++++++++++++---------
>  fs/cifs/cifsacl.c                    |   57 +++++++++++++++++----------
>  fs/dcache.c                          |   15 ++++---
>  fs/gfs2/glock.c                      |   24 +++++++-----
>  fs/gfs2/main.c                       |    3 +-
>  fs/gfs2/quota.c                      |   19 +++++----
>  fs/gfs2/quota.h                      |    4 +-
>  fs/inode.c                           |    7 ++-
>  fs/internal.h                        |    3 +
>  fs/mbcache.c                         |   37 +++++++++++------
>  fs/nfs/dir.c                         |   17 ++++++--
>  fs/nfs/internal.h                    |    6 ++-
>  fs/nfs/super.c                       |    3 +-
>  fs/quota/dquot.c                     |   39 +++++++++----------
>  fs/super.c                           |   71 ++++++++++++++++++++--------------
>  fs/ubifs/shrinker.c                  |   19 +++++----
>  fs/ubifs/super.c                     |    3 +-
>  fs/ubifs/ubifs.h                     |    3 +-
>  fs/xfs/xfs_buf.c                     |   19 ++++++++-
>  fs/xfs/xfs_qm.c                      |   22 +++++++---
>  fs/xfs/xfs_super.c                   |    8 ++--
>  fs/xfs/xfs_sync.c                    |   17 +++++---
>  fs/xfs/xfs_sync.h                    |    4 +-
>  include/linux/fs.h                   |    8 +---
>  include/trace/events/vmscan.h        |   12 +++---
>  mm/vmscan.c                          |   46 +++++++++-------------
>  net/sunrpc/auth.c                    |   21 +++++++---
>  32 files changed, 369 insertions(+), 257 deletions(-)
> 
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index 52d8fb8..4ca3c2d 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -229,8 +229,8 @@ struct super_operations {
>  
>          ssize_t (*quota_read)(struct super_block *, int, char *, size_t, loff_t);
>          ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
> -	int (*nr_cached_objects)(struct super_block *);
> -	void (*free_cached_objects)(struct super_block *, int);
> +	long (*nr_cached_objects)(struct super_block *);
> +	long (*free_cached_objects)(struct super_block *, long);
>  };
>  
>  All methods are called without any locks being held, unless otherwise
> @@ -313,9 +313,10 @@ or bottom half).
>  	implement ->nr_cached_objects for it to be called correctly.
>  
>  	We can't do anything with any errors that the filesystem might
> -	encountered, hence the void return type. This will never be called if
> -	the VM is trying to reclaim under GFP_NOFS conditions, hence this
> -	method does not need to handle that situation itself.
> +	encountered, so the return value is the number of objects freed. This
> +	will never be called if the VM is trying to reclaim under GFP_NOFS
> +	conditions, hence this method does not need to handle that situation
> +	itself.
>  
>  	Implementations must include conditional reschedule calls inside any
>  	scanning loop that is done. This allows the VFS to determine
> diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
> index 1c5b693..939e201 100644
> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -3858,14 +3858,12 @@ static int kvm_mmu_remove_some_alloc_mmu_pages(struct kvm *kvm,
>  	return kvm_mmu_prepare_zap_page(kvm, page, invalid_list);
>  }
>  
> -static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
> +static long mmu_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	struct kvm *kvm;
>  	struct kvm *kvm_freed = NULL;
>  	int nr_to_scan = sc->nr_to_scan;
> -
> -	if (nr_to_scan == 0)
> -		goto out;
> +	long freed_pages = 0;
>  
>  	raw_spin_lock(&kvm_lock);
>  
> @@ -3877,7 +3875,7 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  		spin_lock(&kvm->mmu_lock);
>  		if (!kvm_freed && nr_to_scan > 0 &&
>  		    kvm->arch.n_used_mmu_pages > 0) {
> -			freed_pages = kvm_mmu_remove_some_alloc_mmu_pages(kvm,
> +			freed_pages += kvm_mmu_remove_some_alloc_mmu_pages(kvm,
>  							  &invalid_list);
>  			kvm_freed = kvm;
>  		}
> @@ -3891,13 +3889,17 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  		list_move_tail(&kvm_freed->vm_list, &vm_list);
>  
>  	raw_spin_unlock(&kvm_lock);
> +	return freed_pages;
> +}
>  
> -out:
> +static long mmu_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
>  	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
>  }
>  
>  static struct shrinker mmu_shrinker = {
> -	.shrink = mmu_shrink,
> +	.scan_objects = mmu_shrink_scan,
> +	.count_objects = mmu_shrink_count,
>  	.seeks = DEFAULT_SEEKS * 10,
>  };
>  
> diff --git a/drivers/gpu/drm/i915/i915_dma.c b/drivers/gpu/drm/i915/i915_dma.c
> index 8a3942c..734ea5e 100644
> --- a/drivers/gpu/drm/i915/i915_dma.c
> +++ b/drivers/gpu/drm/i915/i915_dma.c
> @@ -2074,7 +2074,7 @@ int i915_driver_load(struct drm_device *dev, unsigned long flags)
>  	return 0;
>  
>  out_gem_unload:
> -	if (dev_priv->mm.inactive_shrinker.shrink)
> +	if (dev_priv->mm.inactive_shrinker.scan_objects)
>  		unregister_shrinker(&dev_priv->mm.inactive_shrinker);
>  
>  	if (dev->pdev->msi_enabled)
> @@ -2108,7 +2108,7 @@ int i915_driver_unload(struct drm_device *dev)
>  	i915_mch_dev = NULL;
>  	spin_unlock(&mchdev_lock);
>  
> -	if (dev_priv->mm.inactive_shrinker.shrink)
> +	if (dev_priv->mm.inactive_shrinker.scan_objects)
>  		unregister_shrinker(&dev_priv->mm.inactive_shrinker);
>  
>  	mutex_lock(&dev->struct_mutex);
> diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
> index a546a71..0647a33 100644
> --- a/drivers/gpu/drm/i915/i915_gem.c
> +++ b/drivers/gpu/drm/i915/i915_gem.c
> @@ -56,7 +56,9 @@ static int i915_gem_phys_pwrite(struct drm_device *dev,
>  				struct drm_file *file);
>  static void i915_gem_free_object_tail(struct drm_i915_gem_object *obj);
>  
> -static int i915_gem_inactive_shrink(struct shrinker *shrinker,
> +static long i915_gem_inactive_scan(struct shrinker *shrinker,
> +				   struct shrink_control *sc);
> +static long i915_gem_inactive_count(struct shrinker *shrinker,
>  				    struct shrink_control *sc);
>  
>  /* some bookkeeping */
> @@ -3999,7 +4001,8 @@ i915_gem_load(struct drm_device *dev)
>  
>  	dev_priv->mm.interruptible = true;
>  
> -	dev_priv->mm.inactive_shrinker.shrink = i915_gem_inactive_shrink;
> +	dev_priv->mm.inactive_shrinker.scan_objects = i915_gem_inactive_scan;
> +	dev_priv->mm.inactive_shrinker.count_objects = i915_gem_inactive_count;
>  	dev_priv->mm.inactive_shrinker.seeks = DEFAULT_SEEKS;
>  	register_shrinker(&dev_priv->mm.inactive_shrinker);
>  }
> @@ -4221,8 +4224,8 @@ i915_gpu_is_active(struct drm_device *dev)
>  	return !lists_empty;
>  }
>  
> -static int
> -i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
> +static long
> +i915_gem_inactive_scan(struct shrinker *shrinker, struct shrink_control *sc)
>  {
>  	struct drm_i915_private *dev_priv =
>  		container_of(shrinker,
> @@ -4231,22 +4234,10 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>  	struct drm_device *dev = dev_priv->dev;
>  	struct drm_i915_gem_object *obj, *next;
>  	int nr_to_scan = sc->nr_to_scan;
> -	int cnt;
>  
>  	if (!mutex_trylock(&dev->struct_mutex))
>  		return 0;
>  
> -	/* "fast-path" to count number of available objects */
> -	if (nr_to_scan == 0) {
> -		cnt = 0;
> -		list_for_each_entry(obj,
> -				    &dev_priv->mm.inactive_list,
> -				    mm_list)
> -			cnt++;
> -		mutex_unlock(&dev->struct_mutex);
> -		return cnt / 100 * sysctl_vfs_cache_pressure;
> -	}
> -
>  rescan:
>  	/* first scan for clean buffers */
>  	i915_gem_retire_requests(dev);
> @@ -4262,15 +4253,12 @@ rescan:
>  	}
>  
>  	/* second pass, evict/count anything still on the inactive list */
> -	cnt = 0;
>  	list_for_each_entry_safe(obj, next,
>  				 &dev_priv->mm.inactive_list,
>  				 mm_list) {
>  		if (nr_to_scan &&
>  		    i915_gem_object_unbind(obj) == 0)
>  			nr_to_scan--;
> -		else
> -			cnt++;
>  	}
>  
>  	if (nr_to_scan && i915_gpu_is_active(dev)) {
> @@ -4284,5 +4272,26 @@ rescan:
>  			goto rescan;
>  	}
>  	mutex_unlock(&dev->struct_mutex);
> -	return cnt / 100 * sysctl_vfs_cache_pressure;
> +	return sc->nr_to_scan - nr_to_scan;
> +}
> +
> +static long
> +i915_gem_inactive_count(struct shrinker *shrinker, struct shrink_control *sc)
> +{
> +	struct drm_i915_private *dev_priv =
> +		container_of(shrinker,
> +			     struct drm_i915_private,
> +			     mm.inactive_shrinker);
> +	struct drm_device *dev = dev_priv->dev;
> +	struct drm_i915_gem_object *obj;
> +	long count = 0;
> +
> +	if (!mutex_trylock(&dev->struct_mutex))
> +		return 0;
> +
> +	list_for_each_entry(obj, &dev_priv->mm.inactive_list, mm_list)
> +		count++;
> +
> +	mutex_unlock(&dev->struct_mutex);
> +	return count;
>  }
> diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
> index 727e93d..3e71c68 100644
> --- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
> +++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
> @@ -395,14 +395,13 @@ static int ttm_pool_get_num_unused_pages(void)
>  /**
>   * Callback for mm to request pool to reduce number of page held.
>   */
> -static int ttm_pool_mm_shrink(struct shrinker *shrink,
> -			      struct shrink_control *sc)
> +static long ttm_pool_mm_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	static atomic_t start_pool = ATOMIC_INIT(0);
>  	unsigned i;
>  	unsigned pool_offset = atomic_add_return(1, &start_pool);
>  	struct ttm_page_pool *pool;
> -	int shrink_pages = sc->nr_to_scan;
> +	long shrink_pages = sc->nr_to_scan;
>  
>  	pool_offset = pool_offset % NUM_POOLS;
>  	/* select start pool in round robin fashion */
> @@ -413,13 +412,18 @@ static int ttm_pool_mm_shrink(struct shrinker *shrink,
>  		pool = &_manager->pools[(i + pool_offset)%NUM_POOLS];
>  		shrink_pages = ttm_page_pool_free(pool, nr_free);
>  	}
> -	/* return estimated number of unused pages in pool */
> +	return sc->nr_to_scan;
> +}
> +
> +static long ttm_pool_mm_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
>  	return ttm_pool_get_num_unused_pages();
>  }
>  
>  static void ttm_pool_mm_shrink_init(struct ttm_pool_manager *manager)
>  {
> -	manager->mm_shrink.shrink = &ttm_pool_mm_shrink;
> +	manager->mm_shrink.scan_objects = ttm_pool_mm_scan;
> +	manager->mm_shrink.count_objects = ttm_pool_mm_count;
>  	manager->mm_shrink.seeks = 1;
>  	register_shrinker(&manager->mm_shrink);
>  }
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 855a5bb..3ccb723 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -493,9 +493,10 @@ static void zbud_evict_zbpg(struct zbud_page *zbpg)
>   * page in use by another cpu, but also to avoid potential deadlock due to
>   * lock inversion.
>   */
> -static void zbud_evict_pages(int nr)
> +static int zbud_evict_pages(int nr)
>  {
>  	struct zbud_page *zbpg;
> +	int freed = 0;
>  	int i;
>  
>  	/* first try freeing any pages on unused list */
> @@ -511,7 +512,7 @@ retry_unused_list:
>  		spin_unlock_bh(&zbpg_unused_list_spinlock);
>  		zcache_free_page(zbpg);
>  		zcache_evicted_raw_pages++;
> -		if (--nr <= 0)
> +		if (++freed >= nr)
>  			goto out;
>  		goto retry_unused_list;
>  	}
> @@ -535,7 +536,7 @@ retry_unbud_list_i:
>  			/* want budlists unlocked when doing zbpg eviction */
>  			zbud_evict_zbpg(zbpg);
>  			local_bh_enable();
> -			if (--nr <= 0)
> +			if (++freed >= nr)
>  				goto out;
>  			goto retry_unbud_list_i;
>  		}
> @@ -559,13 +560,13 @@ retry_bud_list:
>  		/* want budlists unlocked when doing zbpg eviction */
>  		zbud_evict_zbpg(zbpg);
>  		local_bh_enable();
> -		if (--nr <= 0)
> +		if (++freed >= nr)
>  			goto out;
>  		goto retry_bud_list;
>  	}
>  	spin_unlock_bh(&zbud_budlists_spinlock);
>  out:
> -	return;
> +	return freed;
>  }
>  
>  static void zbud_init(void)
> @@ -1496,30 +1497,34 @@ static bool zcache_freeze;
>  /*
>   * zcache shrinker interface (only useful for ephemeral pages, so zbud only)
>   */
> -static int shrink_zcache_memory(struct shrinker *shrink,
> -				struct shrink_control *sc)
> +static long shrink_zcache_scan(struct shrinker *shrink,
> +			       struct shrink_control *sc)
>  {
>  	int ret = -1;
>  	int nr = sc->nr_to_scan;
>  	gfp_t gfp_mask = sc->gfp_mask;
>  
> -	if (nr >= 0) {
> -		if (!(gfp_mask & __GFP_FS))
> -			/* does this case really need to be skipped? */
> -			goto out;
> -		if (spin_trylock(&zcache_direct_reclaim_lock)) {
> -			zbud_evict_pages(nr);
> -			spin_unlock(&zcache_direct_reclaim_lock);
> -		} else
> -			zcache_aborted_shrink++;
> -	}
> -	ret = (int)atomic_read(&zcache_zbud_curr_raw_pages);
> -out:
> +	if (!(gfp_mask & __GFP_FS))
> +		return -1;
> +
> +	if (spin_trylock(&zcache_direct_reclaim_lock)) {
> +		ret = zbud_evict_pages(nr);
> +		spin_unlock(&zcache_direct_reclaim_lock);
> +	} else
> +		zcache_aborted_shrink++;
> +
>  	return ret;
>  }
>  
> +static long shrink_zcache_count(struct shrinker *shrink,
> +				struct shrink_control *sc)
> +{
> +	return atomic_read(&zcache_zbud_curr_raw_pages);
> +}
> +
>  static struct shrinker zcache_shrinker = {
> -	.shrink = shrink_zcache_memory,
> +	.scan_objects = shrink_zcache_scan,
> +	.count_objects = shrink_zcache_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
> index d0f59fa..508a684 100644
> --- a/fs/cifs/cifsacl.c
> +++ b/fs/cifs/cifsacl.c
> @@ -44,58 +44,73 @@ static const struct cifs_sid sid_user = {1, 2 , {0, 0, 0, 0, 0, 5}, {} };
>  
>  const struct cred *root_cred;
>  
> -static void
> -shrink_idmap_tree(struct rb_root *root, int nr_to_scan, int *nr_rem,
> -			int *nr_del)
> +static long
> +shrink_idmap_tree(struct rb_root *root, int nr_to_scan)
>  {
>  	struct rb_node *node;
>  	struct rb_node *tmp;
>  	struct cifs_sid_id *psidid;
> +	long count = 0;
>  
>  	node = rb_first(root);
>  	while (node) {
>  		tmp = node;
>  		node = rb_next(tmp);
>  		psidid = rb_entry(tmp, struct cifs_sid_id, rbnode);
> -		if (nr_to_scan == 0 || *nr_del == nr_to_scan)
> -			++(*nr_rem);
> -		else {
> -			if (time_after(jiffies, psidid->time + SID_MAP_EXPIRE)
> -						&& psidid->refcount == 0) {
> -				rb_erase(tmp, root);
> -				++(*nr_del);
> -			} else
> -				++(*nr_rem);
> +		if (nr_to_scan == 0) {
> +			count++;
> +			continue:
> +		}
> +		if (time_after(jiffies, psidid->time + SID_MAP_EXPIRE)
> +					&& psidid->refcount == 0) {
> +			rb_erase(tmp, root);
> +			if (++count >= nr_to_scan)
> +				break;
>  		}
>  	}
> +	return count;
>  }
>  
>  /*
>   * Run idmap cache shrinker.
>   */
> -static int
> -cifs_idmap_shrinker(struct shrinker *shrink, struct shrink_control *sc)
> +static long
> +cifs_idmap_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
> -	int nr_to_scan = sc->nr_to_scan;
> -	int nr_del = 0;
> -	int nr_rem = 0;
>  	struct rb_root *root;
> +	long freed;
>  
>  	root = &uidtree;
>  	spin_lock(&siduidlock);
> -	shrink_idmap_tree(root, nr_to_scan, &nr_rem, &nr_del);
> +	freed = shrink_idmap_tree(root, sc->nr_to_scan);
>  	spin_unlock(&siduidlock);
>  
>  	root = &gidtree;
>  	spin_lock(&sidgidlock);
> -	shrink_idmap_tree(root, nr_to_scan, &nr_rem, &nr_del);
> +	freed += shrink_idmap_tree(root, sc->nr_to_scan);
>  	spin_unlock(&sidgidlock);
>  
> -	return nr_rem;
> +	return freed;
> +}
> +
> +/*
> + * This still abuses the nr_to_scan == 0 trick to get the common code just to
> + * count objects. There neds to be an external count of the objects in the
> + * caches to avoid this.
> + */
> +static long
> +cifs_idmap_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	struct shrinker_control sc = {
> +		.nr_to_scan = 0,
> +	}
> +
> +	return cifs_idmap_shrinker_scan(shrink, &sc);
>  }
>  
>  static struct shrinker cifs_shrinker = {
> -	.shrink = cifs_idmap_shrinker,
> +	.scan_objects = cifs_idmap_shrinker_scan,
> +	.count_objects = cifs_idmap_shrinker_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 5123d71..d19e453 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -759,11 +759,12 @@ static void shrink_dentry_list(struct list_head *list)
>   *
>   * If flags contains DCACHE_REFERENCED reference dentries will not be pruned.
>   */
> -static void __shrink_dcache_sb(struct super_block *sb, int count, int flags)
> +static long __shrink_dcache_sb(struct super_block *sb, long count, int flags)
>  {
>  	struct dentry *dentry;
>  	LIST_HEAD(referenced);
>  	LIST_HEAD(tmp);
> +	long freed = 0;
>  
>  relock:
>  	spin_lock(&sb->s_dentry_lru_lock);
> @@ -791,6 +792,7 @@ relock:
>  		} else {
>  			list_move_tail(&dentry->d_lru, &tmp);
>  			spin_unlock(&dentry->d_lock);
> +			freed++;
>  			if (!--count)
>  				break;
>  		}
> @@ -801,6 +803,7 @@ relock:
>  	spin_unlock(&sb->s_dentry_lru_lock);
>  
>  	shrink_dentry_list(&tmp);
> +	return freed;
>  }
>  
>  /**
> @@ -815,9 +818,9 @@ relock:
>   * This function may fail to free any resources if all the dentries are in
>   * use.
>   */
> -void prune_dcache_sb(struct super_block *sb, int nr_to_scan)
> +long prune_dcache_sb(struct super_block *sb, long nr_to_scan)
>  {
> -	__shrink_dcache_sb(sb, nr_to_scan, DCACHE_REFERENCED);
> +	return __shrink_dcache_sb(sb, nr_to_scan, DCACHE_REFERENCED);
>  }
>  
>  /**
> @@ -1070,12 +1073,12 @@ EXPORT_SYMBOL(have_submounts);
>   * drop the lock and return early due to latency
>   * constraints.
>   */
> -static int select_parent(struct dentry * parent)
> +static long select_parent(struct dentry * parent)
>  {
>  	struct dentry *this_parent;
>  	struct list_head *next;
>  	unsigned seq;
> -	int found = 0;
> +	long found = 0;
>  	int locked = 0;
>  
>  	seq = read_seqbegin(&rename_lock);
> @@ -1163,7 +1166,7 @@ rename_retry:
>  void shrink_dcache_parent(struct dentry * parent)
>  {
>  	struct super_block *sb = parent->d_sb;
> -	int found;
> +	long found;
>  
>  	while ((found = select_parent(parent)) != 0)
>  		__shrink_dcache_sb(sb, found, 0);
> diff --git a/fs/gfs2/glock.c b/fs/gfs2/glock.c
> index 88e8a23..f9bc88d 100644
> --- a/fs/gfs2/glock.c
> +++ b/fs/gfs2/glock.c
> @@ -1370,24 +1370,21 @@ void gfs2_glock_complete(struct gfs2_glock *gl, int ret)
>  }
>  
> 
> -static int gfs2_shrink_glock_memory(struct shrinker *shrink,
> -				    struct shrink_control *sc)
> +static long gfs2_shrink_glock_scan(struct shrinker *shrink,
> +				   struct shrink_control *sc)
>  {
>  	struct gfs2_glock *gl;
>  	int may_demote;
>  	int nr_skipped = 0;
> -	int nr = sc->nr_to_scan;
> +	int freed = 0;
>  	gfp_t gfp_mask = sc->gfp_mask;
>  	LIST_HEAD(skipped);
>  
> -	if (nr == 0)
> -		goto out;
> -
>  	if (!(gfp_mask & __GFP_FS))
>  		return -1;
>  
>  	spin_lock(&lru_lock);
> -	while(nr && !list_empty(&lru_list)) {
> +	while (freed < sc->nr_to_scan && !list_empty(&lru_list)) {
>  		gl = list_entry(lru_list.next, struct gfs2_glock, gl_lru);
>  		list_del_init(&gl->gl_lru);
>  		clear_bit(GLF_LRU, &gl->gl_flags);
> @@ -1401,7 +1398,7 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
>  			may_demote = demote_ok(gl);
>  			if (may_demote) {
>  				handle_callback(gl, LM_ST_UNLOCKED, 0);
> -				nr--;
> +				freed++;
>  			}
>  			clear_bit(GLF_LOCK, &gl->gl_flags);
>  			smp_mb__after_clear_bit();
> @@ -1418,12 +1415,19 @@ static int gfs2_shrink_glock_memory(struct shrinker *shrink,
>  	list_splice(&skipped, &lru_list);
>  	atomic_add(nr_skipped, &lru_count);
>  	spin_unlock(&lru_lock);
> -out:
> +
> +	return freed;
> +}
> +
> +static long gfs2_shrink_glock_count(struct shrinker *shrink,
> +				    struct shrink_control *sc)
> +{
>  	return (atomic_read(&lru_count) / 100) * sysctl_vfs_cache_pressure;
>  }
>  
>  static struct shrinker glock_shrinker = {
> -	.shrink = gfs2_shrink_glock_memory,
> +	.scan_objects = gfs2_shrink_glock_scan,
> +	.count_objects = gfs2_shrink_glock_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> diff --git a/fs/gfs2/main.c b/fs/gfs2/main.c
> index 8ea7747..2c21986 100644
> --- a/fs/gfs2/main.c
> +++ b/fs/gfs2/main.c
> @@ -29,7 +29,8 @@
>  #include "dir.h"
>  
>  static struct shrinker qd_shrinker = {
> -	.shrink = gfs2_shrink_qd_memory,
> +	.scan_objects = gfs2_shrink_qd_scan,
> +	.count_objects = gfs2_shrink_qd_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
> index 42e8d23..5a5f76c 100644
> --- a/fs/gfs2/quota.c
> +++ b/fs/gfs2/quota.c
> @@ -78,20 +78,17 @@ static LIST_HEAD(qd_lru_list);
>  static atomic_t qd_lru_count = ATOMIC_INIT(0);
>  static DEFINE_SPINLOCK(qd_lru_lock);
>  
> -int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
> +long gfs2_shrink_qd_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	struct gfs2_quota_data *qd;
>  	struct gfs2_sbd *sdp;
> -	int nr_to_scan = sc->nr_to_scan;
> -
> -	if (nr_to_scan == 0)
> -		goto out;
> +	int freed = 0;
>  
>  	if (!(sc->gfp_mask & __GFP_FS))
>  		return -1;
>  
>  	spin_lock(&qd_lru_lock);
> -	while (nr_to_scan && !list_empty(&qd_lru_list)) {
> +	while (freed <= sc->nr_to_scan && !list_empty(&qd_lru_list)) {
>  		qd = list_entry(qd_lru_list.next,
>  				struct gfs2_quota_data, qd_reclaim);
>  		sdp = qd->qd_gl->gl_sbd;
> @@ -112,12 +109,16 @@ int gfs2_shrink_qd_memory(struct shrinker *shrink, struct shrink_control *sc)
>  		spin_unlock(&qd_lru_lock);
>  		kmem_cache_free(gfs2_quotad_cachep, qd);
>  		spin_lock(&qd_lru_lock);
> -		nr_to_scan--;
> +		freed++;
>  	}
>  	spin_unlock(&qd_lru_lock);
>  
> -out:
> -	return (atomic_read(&qd_lru_count) * sysctl_vfs_cache_pressure) / 100;
> +	return freed;
> +}
> +
> +long gfs2_shrink_qd_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	return (atomic_read(&qd_lru_count) / 100) * sysctl_vfs_cache_pressure;
>  }
>  
>  static u64 qd2offset(struct gfs2_quota_data *qd)
> diff --git a/fs/gfs2/quota.h b/fs/gfs2/quota.h
> index 90bf1c3..c40fe6d 100644
> --- a/fs/gfs2/quota.h
> +++ b/fs/gfs2/quota.h
> @@ -52,7 +52,9 @@ static inline int gfs2_quota_lock_check(struct gfs2_inode *ip)
>  	return ret;
>  }
>  
> -extern int gfs2_shrink_qd_memory(struct shrinker *shrink,
> +extern long gfs2_shrink_qd_scan(struct shrinker *shrink,
> +				struct shrink_control *sc);
> +extern long gfs2_shrink_qd_count(struct shrinker *shrink,
>  				 struct shrink_control *sc);
>  extern const struct quotactl_ops gfs2_quotactl_ops;
>  
> diff --git a/fs/inode.c b/fs/inode.c
> index 848808f..fee5d9a 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -613,10 +613,11 @@ static int can_unuse(struct inode *inode)
>   * LRU does not have strict ordering. Hence we don't want to reclaim inodes
>   * with this flag set because they are the inodes that are out of order.
>   */
> -void prune_icache_sb(struct super_block *sb, int nr_to_scan)
> +long prune_icache_sb(struct super_block *sb, long nr_to_scan)
>  {
>  	LIST_HEAD(freeable);
> -	int nr_scanned;
> +	long nr_scanned;
> +	long freed = 0;
>  	unsigned long reap = 0;
>  
>  	spin_lock(&sb->s_inode_lru_lock);
> @@ -686,6 +687,7 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
>  		list_move(&inode->i_lru, &freeable);
>  		sb->s_nr_inodes_unused--;
>  		this_cpu_dec(nr_unused);
> +		freed++;
>  	}
>  	if (current_is_kswapd())
>  		__count_vm_events(KSWAPD_INODESTEAL, reap);
> @@ -694,6 +696,7 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
>  	spin_unlock(&sb->s_inode_lru_lock);
>  
>  	dispose_list(&freeable);
> +	return freed;
>  }
>  
>  static void __wait_on_freeing_inode(struct inode *inode);
> diff --git a/fs/internal.h b/fs/internal.h
> index fe327c2..2662ffa 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -127,6 +127,8 @@ extern long do_handle_open(int mountdirfd,
>   * inode.c
>   */
>  extern spinlock_t inode_sb_list_lock;
> +extern long prune_icache_sb(struct super_block *sb, long nr_to_scan);
> +
>  
>  /*
>   * fs-writeback.c
> @@ -141,3 +143,4 @@ extern int invalidate_inodes(struct super_block *, bool);
>   * dcache.c
>   */
>  extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
> +extern long prune_dcache_sb(struct super_block *sb, long nr_to_scan);
> diff --git a/fs/mbcache.c b/fs/mbcache.c
> index 8c32ef3..aa3a19a 100644
> --- a/fs/mbcache.c
> +++ b/fs/mbcache.c
> @@ -90,11 +90,14 @@ static DEFINE_SPINLOCK(mb_cache_spinlock);
>   * What the mbcache registers as to get shrunk dynamically.
>   */
>  
> -static int mb_cache_shrink_fn(struct shrinker *shrink,
> -			      struct shrink_control *sc);
> +static long mb_cache_shrink_scan(struct shrinker *shrink,
> +				 struct shrink_control *sc);
> +static long mb_cache_shrink_count(struct shrinker *shrink,
> +				  struct shrink_control *sc);
>  
>  static struct shrinker mb_cache_shrinker = {
> -	.shrink = mb_cache_shrink_fn,
> +	.scan_objects = mb_cache_shrink_scan,
> +	.count_objects = mb_cache_shrink_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> @@ -161,13 +164,12 @@ forget:
>   *
>   * Returns the number of objects which are present in the cache.
>   */
> -static int
> -mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
> +static long
> +mb_cache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	LIST_HEAD(free_list);
> -	struct mb_cache *cache;
>  	struct mb_cache_entry *entry, *tmp;
> -	int count = 0;
> +	int freed = 0;
>  	int nr_to_scan = sc->nr_to_scan;
>  	gfp_t gfp_mask = sc->gfp_mask;
>  
> @@ -180,18 +182,27 @@ mb_cache_shrink_fn(struct shrinker *shrink, struct shrink_control *sc)
>  		list_move_tail(&ce->e_lru_list, &free_list);
>  		__mb_cache_entry_unhash(ce);
>  	}
> -	list_for_each_entry(cache, &mb_cache_list, c_cache_list) {
> -		mb_debug("cache %s (%d)", cache->c_name,
> -			  atomic_read(&cache->c_entry_count));
> -		count += atomic_read(&cache->c_entry_count);
> -	}
>  	spin_unlock(&mb_cache_spinlock);
>  	list_for_each_entry_safe(entry, tmp, &free_list, e_lru_list) {
>  		__mb_cache_entry_forget(entry, gfp_mask);
> +		freed++;
>  	}
> -	return (count / 100) * sysctl_vfs_cache_pressure;
> +	return freed;
>  }
>  
> +static long
> +mb_cache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	struct mb_cache *cache;
> +	long count = 0;
> +
> +	spin_lock(&mb_cache_spinlock);
> +	list_for_each_entry(cache, &mb_cache_list, c_cache_list)
> +		count += atomic_read(&cache->c_entry_count);
> +
> +	spin_unlock(&mb_cache_spinlock);
> +	return (count / 100) * sysctl_vfs_cache_pressure;
> +}
>  
>  /*
>   * mb_cache_create()  create a new cache
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b238d95..a5aefb2 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2057,17 +2057,18 @@ static void nfs_access_free_list(struct list_head *head)
>  	}
>  }
>  
> -int nfs_access_cache_shrinker(struct shrinker *shrink,
> -			      struct shrink_control *sc)
> +long nfs_access_cache_scan(struct shrinker *shrink,
> +			   struct shrink_control *sc)
>  {
>  	LIST_HEAD(head);
>  	struct nfs_inode *nfsi, *next;
>  	struct nfs_access_entry *cache;
>  	int nr_to_scan = sc->nr_to_scan;
> +	int freed = 0;
>  	gfp_t gfp_mask = sc->gfp_mask;
>  
>  	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
> -		return (nr_to_scan == 0) ? 0 : -1;
> +		return -1;
>  
>  	spin_lock(&nfs_access_lru_lock);
>  	list_for_each_entry_safe(nfsi, next, &nfs_access_lru_list, access_cache_inode_lru) {
> @@ -2079,6 +2080,7 @@ int nfs_access_cache_shrinker(struct shrinker *shrink,
>  		spin_lock(&inode->i_lock);
>  		if (list_empty(&nfsi->access_cache_entry_lru))
>  			goto remove_lru_entry;
> +		freed++;
>  		cache = list_entry(nfsi->access_cache_entry_lru.next,
>  				struct nfs_access_entry, lru);
>  		list_move(&cache->lru, &head);
> @@ -2097,7 +2099,14 @@ remove_lru_entry:
>  	}
>  	spin_unlock(&nfs_access_lru_lock);
>  	nfs_access_free_list(&head);
> -	return (atomic_long_read(&nfs_access_nr_entries) / 100) * sysctl_vfs_cache_pressure;
> +	return freed;
> +}
> +
> +long nfs_access_cache_count(struct shrinker *shrink,
> +			    struct shrink_control *sc)
> +{
> +	return (atomic_long_read(&nfs_access_nr_entries) / 100) *
> +						sysctl_vfs_cache_pressure;
>  }
>  
>  static void __nfs_access_zap_cache(struct nfs_inode *nfsi, struct list_head *head)
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index ab12913..9c65e1f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -244,8 +244,10 @@ extern int nfs_init_client(struct nfs_client *clp,
>  			   int noresvport);
>  
>  /* dir.c */
> -extern int nfs_access_cache_shrinker(struct shrinker *shrink,
> -					struct shrink_control *sc);
> +extern long nfs_access_cache_scan(struct shrinker *shrink,
> +				  struct shrink_control *sc);
> +extern long nfs_access_cache_count(struct shrinker *shrink,
> +				   struct shrink_control *sc);
>  
>  /* inode.c */
>  extern struct workqueue_struct *nfsiod_workqueue;
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index b961cea..e088c03 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -380,7 +380,8 @@ static const struct super_operations nfs4_sops = {
>  #endif
>  
>  static struct shrinker acl_shrinker = {
> -	.shrink		= nfs_access_cache_shrinker,
> +	.scan_objects	= nfs_access_cache_scan,
> +	.count_objects	= nfs_access_cache_count,
>  	.seeks		= DEFAULT_SEEKS,
>  };
>  
> diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
> index 5b572c8..c8724d2 100644
> --- a/fs/quota/dquot.c
> +++ b/fs/quota/dquot.c
> @@ -669,45 +669,42 @@ int dquot_quota_sync(struct super_block *sb, int type, int wait)
>  }
>  EXPORT_SYMBOL(dquot_quota_sync);
>  
> -/* Free unused dquots from cache */
> -static void prune_dqcache(int count)
> +/*
> + * This is called from kswapd when we think we need some
> + * more memory
> + */
> +static long shrink_dqcache_scan(struct shrinker *shrink,
> +				 struct shrink_control *sc)
>  {
>  	struct list_head *head;
>  	struct dquot *dquot;
> +	int freed = 0;
>  
> +	spin_lock(&dq_list_lock);
>  	head = free_dquots.prev;
> -	while (head != &free_dquots && count) {
> +	while (head != &free_dquots && freed < sc->nr_to_scan) {
>  		dquot = list_entry(head, struct dquot, dq_free);
>  		remove_dquot_hash(dquot);
>  		remove_free_dquot(dquot);
>  		remove_inuse(dquot);
>  		do_destroy_dquot(dquot);
> -		count--;
> +		freed++;
>  		head = free_dquots.prev;
>  	}
> +	spin_unlock(&dq_list_lock);
> +
> +	return freed;
>  }
>  
> -/*
> - * This is called from kswapd when we think we need some
> - * more memory
> - */
> -static int shrink_dqcache_memory(struct shrinker *shrink,
> +static long shrink_dqcache_count(struct shrinker *shrink,
>  				 struct shrink_control *sc)
>  {
> -	int nr = sc->nr_to_scan;
> -
> -	if (nr) {
> -		spin_lock(&dq_list_lock);
> -		prune_dqcache(nr);
> -		spin_unlock(&dq_list_lock);
> -	}
> -	return ((unsigned)
> -		percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS])
> -		/100) * sysctl_vfs_cache_pressure;
> +	return (percpu_counter_read_positive(&dqstats.counter[DQST_FREE_DQUOTS])
> +		/ 100) * sysctl_vfs_cache_pressure;
>  }
> -
>  static struct shrinker dqcache_shrinker = {
> -	.shrink = shrink_dqcache_memory,
> +	.scan_objects = shrink_dqcache_scan,
> +	.count_objects = shrink_dqcache_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> diff --git a/fs/super.c b/fs/super.c
> index 6a72693..074abbe 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -45,11 +45,14 @@ DEFINE_SPINLOCK(sb_lock);
>   * shrinker path and that leads to deadlock on the shrinker_rwsem. Hence we
>   * take a passive reference to the superblock to avoid this from occurring.
>   */
> -static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
> +static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	struct super_block *sb;
> -	int	fs_objects = 0;
> -	int	total_objects;
> +	long	fs_objects = 0;
> +	long	total_objects;
> +	long	freed = 0;
> +	long	dentries;
> +	long	inodes;
>  
>  	sb = container_of(shrink, struct super_block, s_shrink);
>  
> @@ -57,7 +60,7 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
>  	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
>  	 * to recurse into the FS that called us in clear_inode() and friends..
>  	 */
> -	if (sc->nr_to_scan && !(sc->gfp_mask & __GFP_FS))
> +	if (!(sc->gfp_mask & __GFP_FS))
>  		return -1;
>  
>  	if (!grab_super_passive(sb))
> @@ -69,33 +72,42 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
>  	total_objects = sb->s_nr_dentry_unused +
>  			sb->s_nr_inodes_unused + fs_objects + 1;
>  
> -	if (sc->nr_to_scan) {
> -		int	dentries;
> -		int	inodes;
> -
> -		/* proportion the scan between the caches */
> -		dentries = (sc->nr_to_scan * sb->s_nr_dentry_unused) /
> -							total_objects;
> -		inodes = (sc->nr_to_scan * sb->s_nr_inodes_unused) /
> -							total_objects;
> -		if (fs_objects)
> -			fs_objects = (sc->nr_to_scan * fs_objects) /
> -							total_objects;
> -		/*
> -		 * prune the dcache first as the icache is pinned by it, then
> -		 * prune the icache, followed by the filesystem specific caches
> -		 */
> -		prune_dcache_sb(sb, dentries);
> -		prune_icache_sb(sb, inodes);
> +	/* proportion the scan between the caches */
> +	dentries = (sc->nr_to_scan * sb->s_nr_dentry_unused) / total_objects;
> +	inodes = (sc->nr_to_scan * sb->s_nr_inodes_unused) / total_objects;
>  
> -		if (fs_objects && sb->s_op->free_cached_objects) {
> -			sb->s_op->free_cached_objects(sb, fs_objects);
> -			fs_objects = sb->s_op->nr_cached_objects(sb);
> -		}
> -		total_objects = sb->s_nr_dentry_unused +
> -				sb->s_nr_inodes_unused + fs_objects;
> +	/*
> +	 * prune the dcache first as the icache is pinned by it, then
> +	 * prune the icache, followed by the filesystem specific caches
> +	 */
> +	freed = prune_dcache_sb(sb, dentries);
> +	freed += prune_icache_sb(sb, inodes);
> +
> +	if (fs_objects) {
> +		fs_objects = (sc->nr_to_scan * fs_objects) / total_objects;
> +		freed += sb->s_op->free_cached_objects(sb, fs_objects);
>  	}
>  
> +	drop_super(sb);
> +	return freed;
> +}
> +
> +static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	struct super_block *sb;
> +	long	total_objects = 0;
> +
> +	sb = container_of(shrink, struct super_block, s_shrink);
> +
> +	if (!grab_super_passive(sb))
> +		return -1;
> +
> +	if (sb->s_op && sb->s_op->nr_cached_objects)
> +		total_objects = sb->s_op->nr_cached_objects(sb);
> +
> +	total_objects += sb->s_nr_dentry_unused;
> +	total_objects += sb->s_nr_inodes_unused;
> +
>  	total_objects = (total_objects / 100) * sysctl_vfs_cache_pressure;
>  	drop_super(sb);
>  	return total_objects;
> @@ -182,7 +194,8 @@ static struct super_block *alloc_super(struct file_system_type *type)
>  		s->cleancache_poolid = -1;
>  
>  		s->s_shrink.seeks = DEFAULT_SEEKS;
> -		s->s_shrink.shrink = prune_super;
> +		s->s_shrink.scan_objects = super_cache_scan;
> +		s->s_shrink.count_objects = super_cache_count;
>  		s->s_shrink.batch = 1024;
>  	}
>  out:
> diff --git a/fs/ubifs/shrinker.c b/fs/ubifs/shrinker.c
> index 9e1d056..78ca7b7 100644
> --- a/fs/ubifs/shrinker.c
> +++ b/fs/ubifs/shrinker.c
> @@ -277,19 +277,12 @@ static int kick_a_thread(void)
>  	return 0;
>  }
>  
> -int ubifs_shrinker(struct shrinker *shrink, struct shrink_control *sc)
> +long ubifs_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	int nr = sc->nr_to_scan;
>  	int freed, contention = 0;
>  	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
>  
> -	if (nr == 0)
> -		/*
> -		 * Due to the way UBIFS updates the clean znode counter it may
> -		 * temporarily be negative.
> -		 */
> -		return clean_zn_cnt >= 0 ? clean_zn_cnt : 1;
> -
>  	if (!clean_zn_cnt) {
>  		/*
>  		 * No clean znodes, nothing to reap. All we can do in this case
> @@ -323,3 +316,13 @@ out:
>  	dbg_tnc("%d znodes were freed, requested %d", freed, nr);
>  	return freed;
>  }
> +
> +long ubifs_shrinker_count(struct shrinker *shrink, ubifs_shrinker_scan)
> +{
> +	long clean_zn_cnt = atomic_long_read(&ubifs_clean_zn_cnt);
> +	/*
> +	 * Due to the way UBIFS updates the clean znode counter it may
> +	 * temporarily be negative.
> +	 */
> +	return clean_zn_cnt >= 0 ? clean_zn_cnt : 1;
> +}
> diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
> index 91903f6..3d3f3e9 100644
> --- a/fs/ubifs/super.c
> +++ b/fs/ubifs/super.c
> @@ -49,7 +49,8 @@ struct kmem_cache *ubifs_inode_slab;
>  
>  /* UBIFS TNC shrinker description */
>  static struct shrinker ubifs_shrinker_info = {
> -	.shrink = ubifs_shrinker,
> +	.scan_objects = ubifs_shrinker_scan,
> +	.count_objects = ubifs_shrinker_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
> index 27f2255..2b8f48c 100644
> --- a/fs/ubifs/ubifs.h
> +++ b/fs/ubifs/ubifs.h
> @@ -1625,7 +1625,8 @@ int ubifs_tnc_start_commit(struct ubifs_info *c, struct ubifs_zbranch *zroot);
>  int ubifs_tnc_end_commit(struct ubifs_info *c);
>  
>  /* shrinker.c */
> -int ubifs_shrinker(struct shrinker *shrink, struct shrink_control *sc);
> +long ubifs_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc);
> +long ubifs_shrinker_count(struct shrinker *shrink, struct shrink_control *sc);
>  
>  /* commit.c */
>  int ubifs_bg_thread(void *info);
> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index 7a026cb..b2eea9e 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1456,8 +1456,8 @@ restart:
>  	spin_unlock(&btp->bt_lru_lock);
>  }
>  
> -int
> -xfs_buftarg_shrink(
> +static long
> +xfs_buftarg_shrink_scan(
>  	struct shrinker		*shrink,
>  	struct shrink_control	*sc)
>  {
> @@ -1465,6 +1465,7 @@ xfs_buftarg_shrink(
>  					struct xfs_buftarg, bt_shrinker);
>  	struct xfs_buf		*bp;
>  	int nr_to_scan = sc->nr_to_scan;
> +	int freed = 0;
>  	LIST_HEAD(dispose);
>  
>  	if (!nr_to_scan)
> @@ -1493,6 +1494,7 @@ xfs_buftarg_shrink(
>  		 */
>  		list_move(&bp->b_lru, &dispose);
>  		btp->bt_lru_nr--;
> +		freed++;
>  	}
>  	spin_unlock(&btp->bt_lru_lock);
>  
> @@ -1502,6 +1504,16 @@ xfs_buftarg_shrink(
>  		xfs_buf_rele(bp);
>  	}
>  
> +	return freed;
> +}
> +
> +static long
> +xfs_buftarg_shrink_count(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
> +{
> +	struct xfs_buftarg	*btp = container_of(shrink,
> +					struct xfs_buftarg, bt_shrinker);
>  	return btp->bt_lru_nr;
>  }
>  
> @@ -1602,7 +1614,8 @@ xfs_alloc_buftarg(
>  		goto error;
>  	if (xfs_alloc_delwrite_queue(btp, fsname))
>  		goto error;
> -	btp->bt_shrinker.shrink = xfs_buftarg_shrink;
> +	btp->bt_shrinker.scan_objects = xfs_buftarg_shrink_scan;
> +	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
>  	btp->bt_shrinker.seeks = DEFAULT_SEEKS;
>  	register_shrinker(&btp->bt_shrinker);
>  	return btp;
> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index 9a0aa76..19863a8 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -60,10 +60,12 @@ STATIC void	xfs_qm_list_destroy(xfs_dqlist_t *);
>  
>  STATIC int	xfs_qm_init_quotainos(xfs_mount_t *);
>  STATIC int	xfs_qm_init_quotainfo(xfs_mount_t *);
> -STATIC int	xfs_qm_shake(struct shrinker *, struct shrink_control *);
> +STATIC long	xfs_qm_shake_scan(struct shrinker *, struct shrink_control *);
> +STATIC long	xfs_qm_shake_count(struct shrinker *, struct shrink_control *);
>  
>  static struct shrinker xfs_qm_shaker = {
> -	.shrink = xfs_qm_shake,
> +	.scan_objects = xfs_qm_shake_scan,
> +	.count_objects = xfs_qm_shake_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  
> @@ -1963,9 +1965,8 @@ xfs_qm_shake_freelist(
>  /*
>   * The kmem_shake interface is invoked when memory is running low.
>   */
> -/* ARGSUSED */
> -STATIC int
> -xfs_qm_shake(
> +STATIC long
> +xfs_qm_shake_scan(
>  	struct shrinker	*shrink,
>  	struct shrink_control *sc)
>  {
> @@ -1973,9 +1974,9 @@ xfs_qm_shake(
>  	gfp_t gfp_mask = sc->gfp_mask;
>  
>  	if (!kmem_shake_allow(gfp_mask))
> -		return 0;
> +		return -1;
>  	if (!xfs_Gqm)
> -		return 0;
> +		return -1;
>  
>  	nfree = xfs_Gqm->qm_dqfrlist_cnt; /* free dquots */
>  	/* incore dquots in all f/s's */
> @@ -1992,6 +1993,13 @@ xfs_qm_shake(
>  	return xfs_qm_shake_freelist(MAX(nfree, n));
>  }
>  
> +STATIC long
> +xfs_qm_shake_count(
> +	struct shrinker	*shrink,
> +	struct shrink_control *sc)
> +{
> +	return xfs_Gqm ? xfs_Gqm->qm_dqfrlist_cnt : -1;
> +}
>  
>  /*------------------------------------------------------------------*/
>  
> diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> index c94ec22..dff4b67 100644
> --- a/fs/xfs/xfs_super.c
> +++ b/fs/xfs/xfs_super.c
> @@ -1473,19 +1473,19 @@ xfs_fs_mount(
>  	return mount_bdev(fs_type, flags, dev_name, data, xfs_fs_fill_super);
>  }
>  
> -static int
> +static long
>  xfs_fs_nr_cached_objects(
>  	struct super_block	*sb)
>  {
>  	return xfs_reclaim_inodes_count(XFS_M(sb));
>  }
>  
> -static void
> +static long
>  xfs_fs_free_cached_objects(
>  	struct super_block	*sb,
> -	int			nr_to_scan)
> +	long			nr_to_scan)
>  {
> -	xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
> +	return xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
>  }
>  
>  static const struct super_operations xfs_super_operations = {
> diff --git a/fs/xfs/xfs_sync.c b/fs/xfs/xfs_sync.c
> index 4604f90..5b60a3a 100644
> --- a/fs/xfs/xfs_sync.c
> +++ b/fs/xfs/xfs_sync.c
> @@ -896,7 +896,7 @@ int
>  xfs_reclaim_inodes_ag(
>  	struct xfs_mount	*mp,
>  	int			flags,
> -	int			*nr_to_scan)
> +	long			*nr_to_scan)
>  {
>  	struct xfs_perag	*pag;
>  	int			error = 0;
> @@ -1017,7 +1017,7 @@ xfs_reclaim_inodes(
>  	xfs_mount_t	*mp,
>  	int		mode)
>  {
> -	int		nr_to_scan = INT_MAX;
> +	long		nr_to_scan = LONG_MAX;
>  
>  	return xfs_reclaim_inodes_ag(mp, mode, &nr_to_scan);
>  }
> @@ -1031,29 +1031,32 @@ xfs_reclaim_inodes(
>   * them to be cleaned, which we hope will not be very long due to the
>   * background walker having already kicked the IO off on those dirty inodes.
>   */
> -void
> +long
>  xfs_reclaim_inodes_nr(
>  	struct xfs_mount	*mp,
> -	int			nr_to_scan)
> +	long			nr_to_scan)
>  {
> +	long nr = nr_to_scan;
> +
>  	/* kick background reclaimer and push the AIL */
>  	xfs_syncd_queue_reclaim(mp);
>  	xfs_ail_push_all(mp->m_ail);
>  
> -	xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
> +	xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr);
> +	return nr_to_scan - nr;
>  }
>  
>  /*
>   * Return the number of reclaimable inodes in the filesystem for
>   * the shrinker to determine how much to reclaim.
>   */
> -int
> +long
>  xfs_reclaim_inodes_count(
>  	struct xfs_mount	*mp)
>  {
>  	struct xfs_perag	*pag;
>  	xfs_agnumber_t		ag = 0;
> -	int			reclaimable = 0;
> +	long			reclaimable = 0;
>  
>  	while ((pag = xfs_perag_get_tag(mp, ag, XFS_ICI_RECLAIM_TAG))) {
>  		ag = pag->pag_agno + 1;
> diff --git a/fs/xfs/xfs_sync.h b/fs/xfs/xfs_sync.h
> index 941202e..82e1b1c 100644
> --- a/fs/xfs/xfs_sync.h
> +++ b/fs/xfs/xfs_sync.h
> @@ -35,8 +35,8 @@ void xfs_quiesce_attr(struct xfs_mount *mp);
>  void xfs_flush_inodes(struct xfs_inode *ip);
>  
>  int xfs_reclaim_inodes(struct xfs_mount *mp, int mode);
> -int xfs_reclaim_inodes_count(struct xfs_mount *mp);
> -void xfs_reclaim_inodes_nr(struct xfs_mount *mp, int nr_to_scan);
> +long xfs_reclaim_inodes_count(struct xfs_mount *mp);
> +long xfs_reclaim_inodes_nr(struct xfs_mount *mp, long nr_to_scan);
>  
>  void xfs_inode_set_reclaim_tag(struct xfs_inode *ip);
>  void __xfs_inode_set_reclaim_tag(struct xfs_perag *pag, struct xfs_inode *ip);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 14be4d8..958c025 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1465,10 +1465,6 @@ struct super_block {
>  	struct shrinker s_shrink;	/* per-sb shrinker handle */
>  };
>  
> -/* superblock cache pruning functions */
> -extern void prune_icache_sb(struct super_block *sb, int nr_to_scan);
> -extern void prune_dcache_sb(struct super_block *sb, int nr_to_scan);
> -
>  extern struct timespec current_fs_time(struct super_block *sb);
>  
>  /*
> @@ -1662,8 +1658,8 @@ struct super_operations {
>  	ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
>  #endif
>  	int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
> -	int (*nr_cached_objects)(struct super_block *);
> -	void (*free_cached_objects)(struct super_block *, int);
> +	long (*nr_cached_objects)(struct super_block *);
> +	long (*free_cached_objects)(struct super_block *, long);
>  };
>  
>  /*
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 36851f7..80308ea 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -190,7 +190,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>  
>  	TP_STRUCT__entry(
>  		__field(struct shrinker *, shr)
> -		__field(void *, shrink)
> +		__field(void *, scan)
>  		__field(long, nr_objects_to_shrink)
>  		__field(gfp_t, gfp_flags)
>  		__field(unsigned long, pgs_scanned)
> @@ -202,7 +202,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>  
>  	TP_fast_assign(
>  		__entry->shr = shr;
> -		__entry->shrink = shr->shrink;
> +		__entry->scan = shr->scan_objects;
>  		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
>  		__entry->gfp_flags = sc->gfp_mask;
>  		__entry->pgs_scanned = pgs_scanned;
> @@ -213,7 +213,7 @@ TRACE_EVENT(mm_shrink_slab_start,
>  	),
>  
>  	TP_printk("%pF %p: objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
> -		__entry->shrink,
> +		__entry->scan,
>  		__entry->shr,
>  		__entry->nr_objects_to_shrink,
>  		show_gfp_flags(__entry->gfp_flags),
> @@ -232,7 +232,7 @@ TRACE_EVENT(mm_shrink_slab_end,
>  
>  	TP_STRUCT__entry(
>  		__field(struct shrinker *, shr)
> -		__field(void *, shrink)
> +		__field(void *, scan)
>  		__field(long, unused_scan)
>  		__field(long, new_scan)
>  		__field(int, retval)
> @@ -241,7 +241,7 @@ TRACE_EVENT(mm_shrink_slab_end,
>  
>  	TP_fast_assign(
>  		__entry->shr = shr;
> -		__entry->shrink = shr->shrink;
> +		__entry->scan = shr->scan_objects;
>  		__entry->unused_scan = unused_scan_cnt;
>  		__entry->new_scan = new_scan_cnt;
>  		__entry->retval = shrinker_retval;
> @@ -249,7 +249,7 @@ TRACE_EVENT(mm_shrink_slab_end,
>  	),
>  
>  	TP_printk("%pF %p: unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
> -		__entry->shrink,
> +		__entry->scan,
>  		__entry->shr,
>  		__entry->unused_scan,
>  		__entry->new_scan,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7ef6912..e32ce2d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -202,14 +202,6 @@ void unregister_shrinker(struct shrinker *shrinker)
>  }
>  EXPORT_SYMBOL(unregister_shrinker);
>  
> -static inline int do_shrinker_shrink(struct shrinker *shrinker,
> -				     struct shrink_control *sc,
> -				     unsigned long nr_to_scan)
> -{
> -	sc->nr_to_scan = nr_to_scan;
> -	return (*shrinker->shrink)(shrinker, sc);
> -}
> -
>  #define SHRINK_BATCH 128
>  /*
>   * Call the shrink functions to age shrinkable caches
> @@ -230,27 +222,26 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
>   *
>   * Returns the number of slab objects which we shrunk.
>   */
> -unsigned long shrink_slab(struct shrink_control *shrink,
> +unsigned long shrink_slab(struct shrink_control *sc,
>  			  unsigned long nr_pages_scanned,
>  			  unsigned long lru_pages)
>  {
>  	struct shrinker *shrinker;
> -	unsigned long ret = 0;
> +	unsigned long freed = 0;
>  
>  	if (nr_pages_scanned == 0)
>  		nr_pages_scanned = SWAP_CLUSTER_MAX;
>  
>  	if (!down_read_trylock(&shrinker_rwsem)) {
>  		/* Assume we'll be able to shrink next time */
> -		ret = 1;
> +		freed = 1;
>  		goto out;
>  	}
>  
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
> -		unsigned long long delta;
> -		unsigned long total_scan;
> -		unsigned long max_pass;
> -		int shrink_ret = 0;
> +		long long delta;
> +		long total_scan;
> +		long max_pass;
>  		long nr;
>  		long new_nr;
>  		long batch_size = shrinker->batch ? shrinker->batch
> @@ -266,7 +257,9 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  		} while (cmpxchg(&shrinker->nr, nr, 0) != nr);
>  
>  		total_scan = nr;
> -		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
> +		max_pass = shrinker->count_objects(shrinker, sc);
> +		WARN_ON_ONCE(max_pass < 0);
> +
>  		delta = (4 * nr_pages_scanned) / shrinker->seeks;
>  		delta *= max_pass;
>  		do_div(delta, lru_pages + 1);
> @@ -274,7 +267,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  		if (total_scan < 0) {
>  			printk(KERN_ERR "shrink_slab: %pF negative objects to "
>  			       "delete nr=%ld\n",
> -			       shrinker->shrink, total_scan);
> +			       shrinker->scan_objects, total_scan);
>  			total_scan = max_pass;
>  		}
>  
> @@ -301,20 +294,19 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  		if (total_scan > max_pass * 2)
>  			total_scan = max_pass * 2;
>  
> -		trace_mm_shrink_slab_start(shrinker, shrink, nr,
> +		trace_mm_shrink_slab_start(shrinker, sc, nr,
>  					nr_pages_scanned, lru_pages,
>  					max_pass, delta, total_scan);
>  
>  		while (total_scan >= batch_size) {
> -			int nr_before;
> +			long ret;
> +
> +			sc->nr_to_scan = batch_size;
> +			ret = shrinker->scan_objects(shrinker, sc);
>  
> -			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
> -			shrink_ret = do_shrinker_shrink(shrinker, shrink,
> -							batch_size);
> -			if (shrink_ret == -1)
> +			if (ret == -1)
>  				break;
> -			if (shrink_ret < nr_before)
> -				ret += nr_before - shrink_ret;
> +			freed += ret;
>  			count_vm_events(SLABS_SCANNED, batch_size);
>  			total_scan -= batch_size;
>  
> @@ -333,12 +325,12 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  				break;
>  		} while (cmpxchg(&shrinker->nr, nr, new_nr) != nr);
>  
> -		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
> +		trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
>  	}
>  	up_read(&shrinker_rwsem);
>  out:
>  	cond_resched();
> -	return ret;
> +	return freed;
>  }
>  
>  static void set_reclaim_mode(int priority, struct scan_control *sc,
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 727e506..f5955c3 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -292,6 +292,7 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
>  	spinlock_t *cache_lock;
>  	struct rpc_cred *cred, *next;
>  	unsigned long expired = jiffies - RPC_AUTH_EXPIRY_MORATORIUM;
> +	int freed = 0;
>  
>  	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
>  
> @@ -303,10 +304,10 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
>  		 */
>  		if (time_in_range(cred->cr_expire, expired, jiffies) &&
>  		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
> -			return 0;
> +			break;
>  
> -		list_del_init(&cred->cr_lru);
>  		number_cred_unused--;
> +		list_del_init(&cred->cr_lru);
>  		if (atomic_read(&cred->cr_count) != 0)
>  			continue;
>  
> @@ -316,17 +317,18 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
>  			get_rpccred(cred);
>  			list_add_tail(&cred->cr_lru, free);
>  			rpcauth_unhash_cred_locked(cred);
> +			freed++;
>  		}
>  		spin_unlock(cache_lock);
>  	}
> -	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
> +	return freed;
>  }
>  
>  /*
>   * Run memory cache shrinker.
>   */
> -static int
> -rpcauth_cache_shrinker(struct shrinker *shrink, struct shrink_control *sc)
> +static long
> +rpcauth_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	LIST_HEAD(free);
>  	int res;
> @@ -344,6 +346,12 @@ rpcauth_cache_shrinker(struct shrinker *shrink, struct shrink_control *sc)
>  	return res;
>  }
>  
> +static long
> +rpcauth_cache_count(struct shrinker *shrink, struct shrink_control *sc)
> +{
> +	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
> +}
> +
>  /*
>   * Look up a process' credentials in the authentication cache
>   */
> @@ -658,7 +666,8 @@ rpcauth_uptodatecred(struct rpc_task *task)
>  }
>  
>  static struct shrinker rpc_cred_shrinker = {
> -	.shrink = rpcauth_cache_shrinker,
> +	.scan_objects = rpcauth_cache_scan,
> +	.count_objects = rpcauth_cache_count,
>  	.seeks = DEFAULT_SEEKS,
>  };
>  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
