Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 323A16B02A3
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:30:12 -0400 (EDT)
Subject: Re: [PATCH 2/3] xfs: convert inode shrinker to per-filesystem
 contexts
From: Alex Elder <aelder@sgi.com>
Reply-To: aelder@sgi.com
In-Reply-To: <1279194418-16119-3-git-send-email-david@fromorbit.com>
References: <1279194418-16119-1-git-send-email-david@fromorbit.com>
	 <1279194418-16119-3-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 20 Jul 2010 14:30:11 -0500
Message-ID: <1279654211.1859.235.camel@doink>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-15 at 21:46 +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now the shrinker passes us a context, wire up a shrinker context per
> filesystem. This allows us to remove the global mount list and the
> locking problems that introduced. It also means that a shrinker call
> does not need to traverse clean filesystems before finding a
> filesystem with reclaimable inodes.  This significantly reduces
> scanning overhead when lots of filesystems are present.
> 

I have a comment below about an optimization you made.
It's not necessarily a bug, but I thought I'd call
attention to it anyway.

Outside of that it looks good to me.

> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/linux-2.6/xfs_super.c |    2 -
>  fs/xfs/linux-2.6/xfs_sync.c  |   62 +++++++++--------------------------------
>  fs/xfs/linux-2.6/xfs_sync.h  |    2 -
>  fs/xfs/xfs_mount.h           |    2 +-
>  4 files changed, 15 insertions(+), 53 deletions(-)

. . .

> diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
> index be37582..f433819 100644
> --- a/fs/xfs/linux-2.6/xfs_sync.c
> +++ b/fs/xfs/linux-2.6/xfs_sync.c
> @@ -828,14 +828,7 @@ xfs_reclaim_inodes(
>  
>  /*
>   * Shrinker infrastructure.
> - *
> - * This is all far more complex than it needs to be. It adds a global list of
> - * mounts because the shrinkers can only call a global context. We need to make
> - * the shrinkers pass a context to avoid the need for global state.
>   */
> -static LIST_HEAD(xfs_mount_list);
> -static struct rw_semaphore xfs_mount_list_lock;
> -
>  static int
>  xfs_reclaim_inode_shrink(
>  	struct shrinker	*shrink,
> @@ -847,65 +840,38 @@ xfs_reclaim_inode_shrink(
>  	xfs_agnumber_t	ag;
>  	int		reclaimable = 0;
>  
> +	mp = container_of(shrink, struct xfs_mount, m_inode_shrink);
>  	if (nr_to_scan) {
>  		if (!(gfp_mask & __GFP_FS))
>  			return -1;
>  
> -		down_read(&xfs_mount_list_lock);
> -		list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
> -			xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
> +		xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
>  					XFS_ICI_RECLAIM_TAG, 1, &nr_to_scan);
> -			if (nr_to_scan <= 0)
> -				break;
> -		}
> -		up_read(&xfs_mount_list_lock);
> -	}
> +		/* if we don't exhaust the scan, don't bother coming back */
> +		if (nr_to_scan > 0)
> +			return -1;

This short-circuit return here sort of circumvents the
SLABS_SCANNED VM event counting.  On the other hand, it
seems to be counting nr_to_scan repeatedly, which isn't
necessarily that meaningful in this case either.  (I
don't know how important this is.)

It also means that shrink_slab() under-counts the number
of objects freed.  Again, this may not in practice be
an issue--especially since more will have actually been
freed than is claimed.

					-Alex

> +       }
>  
> -	down_read(&xfs_mount_list_lock);
> -	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
> -		for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
> -			pag = xfs_perag_get(mp, ag);
> -			reclaimable += pag->pag_ici_reclaimable;
> -			xfs_perag_put(pag);
> -		}
> +	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
> +		pag = xfs_perag_get(mp, ag);
> +		reclaimable += pag->pag_ici_reclaimable;
> +		xfs_perag_put(pag);
>  	}
> -	up_read(&xfs_mount_list_lock);
>  	return reclaimable;
>  }
>  
. . .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
