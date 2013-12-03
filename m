Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id A2FBE6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 06:46:06 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so9820293yhl.6
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 03:46:06 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id k47si3096751yhc.49.2013.12.03.03.46.03
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 03:46:05 -0800 (PST)
Date: Tue, 3 Dec 2013 22:45:57 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v12 12/18] fs: make icache, dcache shrinkers memcg-aware
Message-ID: <20131203114557.GS10988@dastard>
References: <cover.1385974612.git.vdavydov@parallels.com>
 <8e7582ad42f35cd9a9ea274bd203e2423b944b62.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8e7582ad42f35cd9a9ea274bd203e2423b944b62.1385974612.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Dec 02, 2013 at 03:19:47PM +0400, Vladimir Davydov wrote:
> Using the per-memcg LRU infrastructure introduced by previous patches,
> this patch makes dcache and icache shrinkers memcg-aware. To achieve
> that, it converts s_dentry_lru and s_inode_lru from list_lru to
> memcg_list_lru and restricts the reclaim to per-memcg parts of the lists
> in case of memcg pressure.
> 
> Other FS objects are currently ignored and only reclaimed on global
> pressure, because their shrinkers are heavily FS-specific and can't be
> converted to be memcg-aware so easily. However, we can pass on target
> memcg to the FS layer and let it decide if per-memcg objects should be
> reclaimed.

And now you have a big problem, because that means filesystems like
XFS won't reclaim inodes during memcg reclaim.

That is, for XFS, prune_icache_lru() does not free any memory. All
it does is remove all the VFS references to the struct xfs_inode,
which is then reclaimed via the sb->s_op->free_cached_objects()
method.

IOWs, what you've done is broken.

> Note that with this patch applied we lose global LRU order, but it does

We don't have global LRU order today for the filesystem caches.
We have per superblock, per-node LRU reclaim order.

> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -343,18 +343,24 @@ static void dentry_unlink_inode(struct dentry * dentry)
>  #define D_FLAG_VERIFY(dentry,x) WARN_ON_ONCE(((dentry)->d_flags & (DCACHE_LRU_LIST | DCACHE_SHRINK_LIST)) != (x))
>  static void d_lru_add(struct dentry *dentry)
>  {
> +	struct list_lru *lru =
> +		mem_cgroup_kmem_list_lru(&dentry->d_sb->s_dentry_lru, dentry);
> +
>  	D_FLAG_VERIFY(dentry, 0);
>  	dentry->d_flags |= DCACHE_LRU_LIST;
>  	this_cpu_inc(nr_dentry_unused);
> -	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
> +	WARN_ON_ONCE(!list_lru_add(lru, &dentry->d_lru));
>  }

This is what I mean about pushing memcg cruft into places where it
is not necessary. This can be done entirely behind list_lru_add(),
without the caller having to care.

> @@ -970,9 +976,9 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>  }
>  
>  /**
> - * prune_dcache_sb - shrink the dcache
> - * @sb: superblock
> - * @nr_to_scan : number of entries to try to free
> + * prune_dcache_lru - shrink the dcache
> + * @lru: dentry lru list
> + * @nr_to_scan: number of entries to try to free
>   * @nid: which node to scan for freeable entities
>   *
>   * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
> @@ -982,14 +988,13 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>   * This function may fail to free any resources if all the dentries are in
>   * use.
>   */
> -long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
> -		     int nid)
> +long prune_dcache_lru(struct list_lru *lru, unsigned long nr_to_scan, int nid)
>  {
>  	LIST_HEAD(dispose);
>  	long freed;
>  
> -	freed = list_lru_walk_node(&sb->s_dentry_lru, nid, dentry_lru_isolate,
> -				       &dispose, &nr_to_scan);
> +	freed = list_lru_walk_node(lru, nid, dentry_lru_isolate,
> +				   &dispose, &nr_to_scan);
>  	shrink_dentry_list(&dispose);
>  	return freed;
>  }

And here, you pass an LRU when what we really need to pass is the
struct shrink_control that contains nr_to_scan, nid, and the memcg
that pruning is targetting.

Because of the tight integration of the LRUs and shrinkers, it makes
sense to pass the shrink control all the way into the list. i.e:

	freed = list_lru_scan(&sb->s_dentry_lru, sc, dentry_lru_isolate,
			      &dispose);

And again, that hides everything to do with memcg based LRUs and
reclaim from the callers. It's clean, simple and hard to get wrong.

> @@ -1029,7 +1034,7 @@ void shrink_dcache_sb(struct super_block *sb)
>  	do {
>  		LIST_HEAD(dispose);
>  
> -		freed = list_lru_walk(&sb->s_dentry_lru,
> +		freed = memcg_list_lru_walk_all(&sb->s_dentry_lru,
>  			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
>  

list_lru_walk() is, by definition, supposed to walk every single
object on the LRU. With memcg awareness, it should be walking all
the memcg lists, too.

> diff --git a/fs/super.c b/fs/super.c
> index cece164..b198da4 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -57,6 +57,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>  				      struct shrink_control *sc)
>  {
>  	struct super_block *sb;
> +	struct list_lru *inode_lru;
> +	struct list_lru *dentry_lru;
>  	long	fs_objects = 0;
>  	long	total_objects;
>  	long	freed = 0;
> @@ -75,11 +77,14 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>  	if (!grab_super_passive(sb))
>  		return SHRINK_STOP;
>  
> -	if (sb->s_op->nr_cached_objects)
> +	if (sb->s_op->nr_cached_objects && !sc->memcg)
>  		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
>  
> -	inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
> -	dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
> +	inode_lru = mem_cgroup_list_lru(&sb->s_inode_lru, sc->memcg);
> +	dentry_lru = mem_cgroup_list_lru(&sb->s_dentry_lru, sc->memcg);
> +
> +	inodes = list_lru_count_node(inode_lru, sc->nid);
> +	dentries = list_lru_count_node(dentry_lru, sc->nid);
>  	total_objects = dentries + inodes + fs_objects + 1;

Again: list_lru_count_sc(&sb->s_inode_lru, sc).

And push the scan control down into ->nr_cached_objects, too.

>  	/* proportion the scan between the caches */
> @@ -90,8 +95,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>  	 * prune the dcache first as the icache is pinned by it, then
>  	 * prune the icache, followed by the filesystem specific caches
>  	 */
> -	freed = prune_dcache_sb(sb, dentries, sc->nid);
> -	freed += prune_icache_sb(sb, inodes, sc->nid);
> +	freed = prune_dcache_lru(dentry_lru, dentries, sc->nid);
> +	freed += prune_icache_lru(inode_lru, inodes, sc->nid);

	sc->nr_to_scan = dentries;
	freed += prune_dcache_sb(sb, sc);
	sc->nr_to_scan = inodes;
	freed += prune_icache_sb(sb, sc);
	if (fs_objects) {
		sc->nr_to_scan = mult_frac(sc->nr_to_scan, fs_objects,
					   total_objects);
		freed += sb->s_op->free_cached_objects(sb, sc);
	}

So much simpler, so much nicer. And nothing memcg related in
sight....

> @@ -225,7 +232,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
>  	s->s_shrink.scan_objects = super_cache_scan;
>  	s->s_shrink.count_objects = super_cache_count;
>  	s->s_shrink.batch = 1024;
> -	s->s_shrink.flags = SHRINKER_NUMA_AWARE;
> +	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;

That's basically the only real logic change that should be
necessary to configure memcg LRUs and shrinkers for any user of the
list_lru infrastructure....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
