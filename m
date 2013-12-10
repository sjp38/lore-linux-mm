Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEDB6B0035
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 23:18:18 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id i8so3491142qcq.38
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 20:18:18 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id i2si10712446qaz.12.2013.12.09.20.18.16
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 20:18:17 -0800 (PST)
Date: Tue, 10 Dec 2013 15:17:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v13 12/16] fs: mark list_lru based shrinkers memcg aware
Message-ID: <20131210041747.GA31386@dastard>
References: <cover.1386571280.git.vdavydov@parallels.com>
 <9e1005848996c3df5ceca9e8262edcf8211a893d.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e1005848996c3df5ceca9e8262edcf8211a893d.1386571280.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>, Steven Whitehouse <swhiteho@redhat.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Al Viro <viro@zeniv.linux.org.uk>

On Mon, Dec 09, 2013 at 12:05:53PM +0400, Vladimir Davydov wrote:
> Since now list_lru automatically distributes objects among per-memcg
> lists and list_lru_{count,walk} employ information passed in the
> shrink_control argument to scan appropriate list, all shrinkers that
> keep objects in the list_lru structure can already work as memcg-aware.
> Let us mark them so.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Glauber Costa <glommer@openvz.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  fs/gfs2/quota.c  |    2 +-
>  fs/super.c       |    2 +-
>  fs/xfs/xfs_buf.c |    2 +-
>  fs/xfs/xfs_qm.c  |    2 +-
>  4 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
> index f0435da..6cf6114 100644
> --- a/fs/gfs2/quota.c
> +++ b/fs/gfs2/quota.c
> @@ -150,7 +150,7 @@ struct shrinker gfs2_qd_shrinker = {
>  	.count_objects = gfs2_qd_shrink_count,
>  	.scan_objects = gfs2_qd_shrink_scan,
>  	.seeks = DEFAULT_SEEKS,
> -	.flags = SHRINKER_NUMA_AWARE,
> +	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
>  };

I'll leave it for Steve to have the final say, but this cache tracks
objects that have contexts that span multiple memcgs (i.e. global
scope) and so is not a candidate for memcg based shrinking.

e.g. a single user can have processes running in multiple concurrent
memcgs, and so the user quota dquot needs to be accessed from all
those memcg contexts. Same for group quota objects - they can span
multiple memcgs that different users have instantiated, simply
because they all belong to the same group and hence are subject to
the group quota accounting.

And for XFS, there's also project quotas, which means you can have
files that are unique to both users and groups, but shared the same
project quota and hence span memcgs that way....

> diff --git a/fs/super.c b/fs/super.c
> index 8f9a81b..05bead8 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -219,7 +219,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
>  	s->s_shrink.scan_objects = super_cache_scan;
>  	s->s_shrink.count_objects = super_cache_count;
>  	s->s_shrink.batch = 1024;
> -	s->s_shrink.flags = SHRINKER_NUMA_AWARE;
> +	s->s_shrink.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
>  	return s;

OK.

> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index 5b2a49c..d8326b6 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1679,7 +1679,7 @@ xfs_alloc_buftarg(
>  	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
>  	btp->bt_shrinker.scan_objects = xfs_buftarg_shrink_scan;
>  	btp->bt_shrinker.seeks = DEFAULT_SEEKS;
> -	btp->bt_shrinker.flags = SHRINKER_NUMA_AWARE;
> +	btp->bt_shrinker.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
>  	register_shrinker(&btp->bt_shrinker);
>  	return btp;

This is a cache for XFS metadata buffers, and so is way below the
scope of memcg control. e.g. an inode buffer can hold 32 inodes,
each that belongs to a different memcg at the VFS inode cache level.
Even if a memcg removes an inode from the VFS cache level, that
buffer is still relevant to 31 other memcg contexts. A similar case
occurs for dquot buffers, and then there's filesystem internal
metadata like AG headers that no memcg has any right to claim
ownership of - they are owned and used solely by the filesystem, and
can be required by *any* memcg in the system to make progress.

i.e. these are low level filesystem metadata caches are owned by the
filesystem and are global resources - they will never come under
control of memcg, and none of the memory associated with this cache
should be accounted to a memcg context because of that....

> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index aaacf8f..1f9bbb5 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -903,7 +903,7 @@ xfs_qm_init_quotainfo(
>  	qinf->qi_shrinker.count_objects = xfs_qm_shrink_count;
>  	qinf->qi_shrinker.scan_objects = xfs_qm_shrink_scan;
>  	qinf->qi_shrinker.seeks = DEFAULT_SEEKS;
> -	qinf->qi_shrinker.flags = SHRINKER_NUMA_AWARE;
> +	qinf->qi_shrinker.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE;
>  	register_shrinker(&qinf->qi_shrinker);
>  	return 0;

That's the XFS dquot cache, analogous to the GFS2 dquot
cache I commented on above. Hence, not a candidate for memcg
shrinking.

Remember - caches use list_lru for scalability reasons right now,
but that doesn't automatically mean memcg based shrinking makes
sense for them.

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
