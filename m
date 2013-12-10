Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id C817B6B0035
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 20:37:20 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f64so3423525yha.31
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 17:37:20 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id t39si6710231yhp.125.2013.12.09.17.37.17
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 17:37:19 -0800 (PST)
Date: Tue, 10 Dec 2013 12:36:48 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v13 08/16] mm: list_lru: require shrink_control in count,
 walk functions
Message-ID: <20131210013648.GX31386@dastard>
References: <cover.1386571280.git.vdavydov@parallels.com>
 <86a461d3615ab4b9a270e754024c7bff99b1f5f0.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86a461d3615ab4b9a270e754024c7bff99b1f5f0.1386571280.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Al Viro <viro@zeniv.linux.org.uk>

On Mon, Dec 09, 2013 at 12:05:49PM +0400, Vladimir Davydov wrote:
> To enable targeted reclaim, the list_lru structure distributes its
> elements among several LRU lists. Currently, there is one LRU per NUMA
> node, and the elements from different nodes are placed to different
> LRUs. As a result there are two versions of count and walk functions:
> 
>  - list_lru_count, list_lru_walk - count, walk items from all nodes;
>  - list_lru_count_node, list_lru_walk_node - count, walk items from a
>    particular node specified in an additional argument.
> 
> We are going to make the list_lru structure per-memcg in addition to
> being per-node. This would allow us to reclaim slab not only on global
> memory shortage, but also on memcg pressure. If we followed the current
> list_lru interface notation, we would have to add a bunch of new
> functions taking a memcg and a node in additional arguments, which would
> look cumbersome.
> 
> To avoid this, we remove the *_node functions and make list_lru_count
> and list_lru_walk require a shrink_control argument so that they will

I don't think that's a good idea. You've had to leave the nr_to_scan
parameter in the API because there are now callers of
list_lru_walk() that don't pass a shrink control structure. IOWs,
you've tried to handle two different caller contexts with the one
function API, when they really should remain separate and not
require internal branching base don what parameters were set in the
API.

i.e. list_lru_walk() is for callers that don't have a shrink control
structure and want to walk ever entry in the LRU, regardless of the
internal structure.

list_lru_walk_node() is for callers that don't have a shrink control
structure and just want to walk items on a single node. This is the
interface NUMA aware callers are using.

list_lru_shrink_walk() is for callers that pass all walk control
parameters via a struct shrink_control. It's not supposed to be used
for interfaces that don't have a shrink_control context....

Same goes for list_lru_count()....

IOWs, you should not be modifying a single user of list_lru_walk()
or list_lru_count() - only those that use the _node() variants and
are going to be marked as memcg aware that need to be changed at
this point. i.e. keep the number of subsystems you actually need to
modify down to a minimum to keep the test matrix reasonable.

> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -972,8 +972,8 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>  /**
>   * prune_dcache_sb - shrink the dcache
>   * @sb: superblock
> - * @nr_to_scan : number of entries to try to free
> - * @nid: which node to scan for freeable entities
> + * @sc: shrink control, passed to list_lru_walk()
> + * @nr_to_scan: number of entries to try to free
>   *
>   * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
>   * done when we need more memory an called from the superblock shrinker
> @@ -982,14 +982,14 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>   * This function may fail to free any resources if all the dentries are in
>   * use.
>   */
> -long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
> -		     int nid)
> +long prune_dcache_sb(struct super_block *sb, struct shrink_control *sc,
> +		     unsigned long nr_to_scan)
>  {
>  	LIST_HEAD(dispose);
>  	long freed;
>  
> -	freed = list_lru_walk_node(&sb->s_dentry_lru, nid, dentry_lru_isolate,
> -				       &dispose, &nr_to_scan);
> +	freed = list_lru_walk(&sb->s_dentry_lru, sc, dentry_lru_isolate,
> +			      &dispose, &nr_to_scan);

Two things here - nr_to_scan should be passed to prune_dcache_sb()
inside the shrink_control. i.e. as sc->nr_to_scan.

Secondly, why is &nr_to_scan being passed as a pointer to
list_lru_walk()? It's not a variable that has any value being
returned to the caller - how list_lru_walk() uses it is entirely
opaque to the caller, and the only return value that matters if the
number of objects freed. i.e. the number moved to the dispose
list.

list_lru_walk_node() is a different matter - a scan might involve
walking multiple nodes (e.g. the internal list_lru_walk()
implementation) and so the nr_to_scan context can span multiple
list_lru_walk_node() calls....

In any case, it should be a call like this here:

	freed = list_lru_shrink_walk(&sb->s_dentry_lru, sc, dentry_lru_isolate,
				     &dispose);

> diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
> index 98236d0..f0435da 100644
> --- a/fs/gfs2/quota.c
> +++ b/fs/gfs2/quota.c
> @@ -132,8 +132,8 @@ static unsigned long gfs2_qd_shrink_scan(struct shrinker *shrink,
>  	if (!(sc->gfp_mask & __GFP_FS))
>  		return SHRINK_STOP;
>  
> -	freed = list_lru_walk_node(&gfs2_qd_lru, sc->nid, gfs2_qd_isolate,
> -				   &dispose, &sc->nr_to_scan);
> +	freed = list_lru_walk(&gfs2_qd_lru, sc, gfs2_qd_isolate,
> +			      &dispose, &sc->nr_to_scan);

And this kind of points out the strangeness of this API. You're
passing the sc to the function, then passing the nr_to_scan out of
the sc structure....

As it is, this shrinker only needs to be node aware - it does not
ever need to be memcg aware because it is dealing with filesystem
internal structures that are of global scope....

i.e. these should all remain untouched as list_lru_*_node() calls.

> @@ -78,8 +78,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>  	if (sb->s_op->nr_cached_objects)
>  		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);

sc needs to be propagated down into .nr_cached_objects. That's not
an optional extra - it needs to have the same information as the
dentry and inode cache pruners.

> -	inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
> -	dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
> +	inodes = list_lru_count(&sb->s_inode_lru, sc);
> +	dentries = list_lru_count(&sb->s_dentry_lru, sc);
>  	total_objects = dentries + inodes + fs_objects + 1;

list_lru_shrink_count()

> @@ -90,8 +90,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>  	 * prune the dcache first as the icache is pinned by it, then
>  	 * prune the icache, followed by the filesystem specific caches
>  	 */
> -	freed = prune_dcache_sb(sb, dentries, sc->nid);
> -	freed += prune_icache_sb(sb, inodes, sc->nid);
> +	freed = prune_dcache_sb(sb, sc, dentries);
> +	freed += prune_icache_sb(sb, sc, inodes);

As I commented last time:

	sc->nr_to_scan = dentries;
	freed = prune_dcache_sb(sb, sc);
	sc->nr_to_scan = inodes;
	freed += prune_icache_sb(sb, sc);
	if (fs_objects) {
		sc->nr_to_scan = mult_frac(sc->nr_to_scan, fs_objects,
					   total_objects);
		freed += sb->s_op->free_cached_objects(sb, sc);
	}

> -	total_objects += list_lru_count_node(&sb->s_dentry_lru,
> -						 sc->nid);
> -	total_objects += list_lru_count_node(&sb->s_inode_lru,
> -						 sc->nid);
> +	total_objects += list_lru_count(&sb->s_dentry_lru, sc);
> +	total_objects += list_lru_count(&sb->s_inode_lru, sc);

list_lru_shrink_count()

> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index c7f0b77..5b2a49c 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1508,9 +1508,11 @@ xfs_wait_buftarg(
>  	int loop = 0;
>  
>  	/* loop until there is nothing left on the lru list. */
> -	while (list_lru_count(&btp->bt_lru)) {
> -		list_lru_walk(&btp->bt_lru, xfs_buftarg_wait_rele,
> -			      &dispose, LONG_MAX);
> +	while (list_lru_count(&btp->bt_lru, NULL)) {
> +		unsigned long nr_to_scan = ULONG_MAX;
> +
> +		list_lru_walk(&btp->bt_lru, NULL, xfs_buftarg_wait_rele,
> +			      &dispose, &nr_to_scan);
>  
>  		while (!list_empty(&dispose)) {
>  			struct xfs_buf *bp;
> @@ -1565,8 +1567,8 @@ xfs_buftarg_shrink_scan(
>  	unsigned long		freed;
>  	unsigned long		nr_to_scan = sc->nr_to_scan;
>  
> -	freed = list_lru_walk_node(&btp->bt_lru, sc->nid, xfs_buftarg_isolate,
> -				       &dispose, &nr_to_scan);
> +	freed = list_lru_walk(&btp->bt_lru, sc, xfs_buftarg_isolate,
> +			      &dispose, &nr_to_scan);

No, this will never be made memcg aware because it's a global
filesystem metadata cache, so it should remain using
list_lru_walk_node().

i.e. don't touch stuff you don't need to touch.

>  	while (!list_empty(&dispose)) {
>  		struct xfs_buf *bp;
> @@ -1585,7 +1587,7 @@ xfs_buftarg_shrink_count(
>  {
>  	struct xfs_buftarg	*btp = container_of(shrink,
>  					struct xfs_buftarg, bt_shrinker);
> -	return list_lru_count_node(&btp->bt_lru, sc->nid);
> +	return list_lru_count(&btp->bt_lru, sc);
>  }
>  
>  void
> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index 14a4996..aaacf8f 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -769,8 +769,8 @@ xfs_qm_shrink_scan(
>  	INIT_LIST_HEAD(&isol.buffers);
>  	INIT_LIST_HEAD(&isol.dispose);
>  
> -	freed = list_lru_walk_node(&qi->qi_lru, sc->nid, xfs_qm_dquot_isolate, &isol,
> -					&nr_to_scan);
> +	freed = list_lru_walk(&qi->qi_lru, sc, xfs_qm_dquot_isolate, &isol,
> +			      &nr_to_scan);

Same here.

>  
>  	error = xfs_buf_delwri_submit(&isol.buffers);
>  	if (error)
> @@ -795,7 +795,7 @@ xfs_qm_shrink_count(
>  	struct xfs_quotainfo	*qi = container_of(shrink,
>  					struct xfs_quotainfo, qi_shrinker);
>  
> -	return list_lru_count_node(&qi->qi_lru, sc->nid);
> +	return list_lru_count(&qi->qi_lru, sc);
>  }
>  
>  /*
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index 3ce5417..34e57af 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -10,6 +10,8 @@
....

None of this should change - there should just be new prototypes for
list_lru_shrink_walk() and list_lru_shrink_count().

>  
> -unsigned long
> +unsigned long list_lru_count(struct list_lru *lru, struct shrink_control *sc)
> +{
> +	long count = 0;
> +	int nid;
> +
> +	if (sc)
> +		return list_lru_count_node(lru, sc->nid);
> +
> +	for_each_node_mask(nid, lru->active_nodes)
> +		count += list_lru_count_node(lru, nid);
> +
> +	return count;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_count);

In fact:

long
list_lru_shrink_count(struct list_lru *lru, struct shrink_control *sc)
{
	return list_lru_count_node(lru, sc->nid);
}

> +
> +static unsigned long
>  list_lru_walk_node(struct list_lru *lru, int nid, list_lru_walk_cb isolate,
>  		   void *cb_arg, unsigned long *nr_to_walk)
>  {
> @@ -112,7 +127,27 @@ restart:
>  	spin_unlock(&nlru->lock);
>  	return isolated;
>  }
> -EXPORT_SYMBOL_GPL(list_lru_walk_node);
> +
> +unsigned long list_lru_walk(struct list_lru *lru, struct shrink_control *sc,
> +			    list_lru_walk_cb isolate, void *cb_arg,
> +			    unsigned long *nr_to_walk)
> +{
> +	long isolated = 0;
> +	int nid;
> +
> +	if (sc)
> +		return list_lru_walk_node(lru, sc->nid, isolate,
> +					  cb_arg, nr_to_walk);
> +
> +	for_each_node_mask(nid, lru->active_nodes) {
> +		isolated += list_lru_walk_node(lru, nid, isolate,
> +					       cb_arg, nr_to_walk);
> +		if (*nr_to_walk <= 0)
> +			break;
> +	}
> +	return isolated;
> +}
> +EXPORT_SYMBOL_GPL(list_lru_walk);

long
list_lru_shrink_walk(struct list_lru *lru, struct shrink_control *sc,
		     list_lru_walk_cb isolate, void *cb_arg)
{
	return list_lru_walk_node(lru, sc->nid, isolate, cb_arg,
				  &sc->nr_to_scan);
}

i.e. adding shrink_control interfaces to the list_lru code only
requires the addition of two simple functions, not a major
API and implementation rework....

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
