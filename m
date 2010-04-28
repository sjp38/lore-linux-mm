Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 54C016B01EE
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 07:31:20 -0400 (EDT)
Date: Wed, 28 Apr 2010 07:31:11 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] xfs: add a shrinker to background inode reclaim
Message-ID: <20100428113111.GA27769@infradead.org>
References: <1272429248-5269-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1272429248-5269-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is quite ugly compared to the previous version but looks correct
enough to me.  One problem is that the first filesystem registered will
get an far over-proportional number of shrink requests, which the simple
patch to pass private data to the shrinker would get around easily.

Anyway, we need a fix, so:


Reviewed-by: Christoph Hellwig <hch@lst.de>

On Wed, Apr 28, 2010 at 02:34:08PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> On low memory boxes or those with highmem, kernel can OOM before the
> background reclaims inodes via xfssyncd. Add a shrinker to run inode
> reclaim so that it inode reclaim is expedited when memory is low.
> 
> This is more complex than it needs to be because the VM folk don't
> want a context added to the shrinker infrastructure. Hence we need
> to add a global list of XFS mount structures so the shrinker can
> traverse them.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/linux-2.6/xfs_super.c   |    5 ++
>  fs/xfs/linux-2.6/xfs_sync.c    |  112 +++++++++++++++++++++++++++++++++++++---
>  fs/xfs/linux-2.6/xfs_sync.h    |    7 ++-
>  fs/xfs/quota/xfs_qm_syscalls.c |    3 +-
>  fs/xfs/xfs_ag.h                |    1 +
>  fs/xfs/xfs_mount.h             |    1 +
>  6 files changed, 120 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/xfs/linux-2.6/xfs_super.c b/fs/xfs/linux-2.6/xfs_super.c
> index 1abcacc..a43d09e 100644
> --- a/fs/xfs/linux-2.6/xfs_super.c
> +++ b/fs/xfs/linux-2.6/xfs_super.c
> @@ -1210,6 +1210,7 @@ xfs_fs_put_super(
>  
>  	xfs_unmountfs(mp);
>  	xfs_freesb(mp);
> +	xfs_inode_shrinker_unregister(mp);
>  	xfs_icsb_destroy_counters(mp);
>  	xfs_close_devices(mp);
>  	xfs_dmops_put(mp);
> @@ -1623,6 +1624,8 @@ xfs_fs_fill_super(
>  	if (error)
>  		goto fail_vnrele;
>  
> +	xfs_inode_shrinker_register(mp);
> +
>  	kfree(mtpt);
>  	return 0;
>  
> @@ -1868,6 +1871,7 @@ init_xfs_fs(void)
>  		goto out_cleanup_procfs;
>  
>  	vfs_initquota();
> +	xfs_inode_shrinker_init();
>  
>  	error = register_filesystem(&xfs_fs_type);
>  	if (error)
> @@ -1895,6 +1899,7 @@ exit_xfs_fs(void)
>  {
>  	vfs_exitquota();
>  	unregister_filesystem(&xfs_fs_type);
> +	xfs_inode_shrinker_destroy();
>  	xfs_sysctl_unregister();
>  	xfs_cleanup_procfs();
>  	xfs_buf_terminate();
> diff --git a/fs/xfs/linux-2.6/xfs_sync.c b/fs/xfs/linux-2.6/xfs_sync.c
> index 3a64179..3884e20 100644
> --- a/fs/xfs/linux-2.6/xfs_sync.c
> +++ b/fs/xfs/linux-2.6/xfs_sync.c
> @@ -95,7 +95,8 @@ xfs_inode_ag_walk(
>  					   struct xfs_perag *pag, int flags),
>  	int			flags,
>  	int			tag,
> -	int			exclusive)
> +	int			exclusive,
> +	int			*nr_to_scan)
>  {
>  	uint32_t		first_index;
>  	int			last_error = 0;
> @@ -134,7 +135,7 @@ restart:
>  		if (error == EFSCORRUPTED)
>  			break;
>  
> -	} while (1);
> +	} while ((*nr_to_scan)--);
>  
>  	if (skipped) {
>  		delay(1);
> @@ -150,12 +151,15 @@ xfs_inode_ag_iterator(
>  					   struct xfs_perag *pag, int flags),
>  	int			flags,
>  	int			tag,
> -	int			exclusive)
> +	int			exclusive,
> +	int			*nr_to_scan)
>  {
>  	int			error = 0;
>  	int			last_error = 0;
>  	xfs_agnumber_t		ag;
> +	int			nr;
>  
> +	nr = nr_to_scan ? *nr_to_scan : INT_MAX;
>  	for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
>  		struct xfs_perag	*pag;
>  
> @@ -165,14 +169,18 @@ xfs_inode_ag_iterator(
>  			continue;
>  		}
>  		error = xfs_inode_ag_walk(mp, pag, execute, flags, tag,
> -						exclusive);
> +						exclusive, &nr);
>  		xfs_perag_put(pag);
>  		if (error) {
>  			last_error = error;
>  			if (error == EFSCORRUPTED)
>  				break;
>  		}
> +		if (nr <= 0)
> +			break;
>  	}
> +	if (nr_to_scan)
> +		*nr_to_scan = nr;
>  	return XFS_ERROR(last_error);
>  }
>  
> @@ -291,7 +299,7 @@ xfs_sync_data(
>  	ASSERT((flags & ~(SYNC_TRYLOCK|SYNC_WAIT)) == 0);
>  
>  	error = xfs_inode_ag_iterator(mp, xfs_sync_inode_data, flags,
> -				      XFS_ICI_NO_TAG, 0);
> +				      XFS_ICI_NO_TAG, 0, NULL);
>  	if (error)
>  		return XFS_ERROR(error);
>  
> @@ -310,7 +318,7 @@ xfs_sync_attr(
>  	ASSERT((flags & ~SYNC_WAIT) == 0);
>  
>  	return xfs_inode_ag_iterator(mp, xfs_sync_inode_attr, flags,
> -				     XFS_ICI_NO_TAG, 0);
> +				     XFS_ICI_NO_TAG, 0, NULL);
>  }
>  
>  STATIC int
> @@ -636,6 +644,7 @@ __xfs_inode_set_reclaim_tag(
>  	radix_tree_tag_set(&pag->pag_ici_root,
>  			   XFS_INO_TO_AGINO(ip->i_mount, ip->i_ino),
>  			   XFS_ICI_RECLAIM_TAG);
> +	pag->pag_ici_reclaimable++;
>  }
>  
>  /*
> @@ -668,6 +677,7 @@ __xfs_inode_clear_reclaim_tag(
>  {
>  	radix_tree_tag_clear(&pag->pag_ici_root,
>  			XFS_INO_TO_AGINO(mp, ip->i_ino), XFS_ICI_RECLAIM_TAG);
> +	pag->pag_ici_reclaimable--;
>  }
>  
>  /*
> @@ -817,5 +827,93 @@ xfs_reclaim_inodes(
>  	int		mode)
>  {
>  	return xfs_inode_ag_iterator(mp, xfs_reclaim_inode, mode,
> -					XFS_ICI_RECLAIM_TAG, 1);
> +					XFS_ICI_RECLAIM_TAG, 1, NULL);
> +}
> +
> +/*
> + * Shrinker infrastructure.
> + *
> + * This is all far more complex than it needs to be. It adds a global list of
> + * mounts because the shrinkers can only call a global context. We need to make
> + * the shrinkers pass a context to avoid the need for global state.
> + */
> +static LIST_HEAD(xfs_mount_list);
> +static struct rw_semaphore xfs_mount_list_lock;
> +
> +static int
> +xfs_reclaim_inode_shrink(
> +	int		nr_to_scan,
> +	gfp_t		gfp_mask)
> +{
> +	struct xfs_mount *mp;
> +	struct xfs_perag *pag;
> +	xfs_agnumber_t	ag;
> +	int		reclaimable = 0;
> +
> +	if (nr_to_scan) {
> +		if (!(gfp_mask & __GFP_FS))
> +			return -1;
> +
> +		down_read(&xfs_mount_list_lock);
> +		list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
> +			xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
> +					XFS_ICI_RECLAIM_TAG, 1, &nr_to_scan);
> +			if (nr_to_scan <= 0)
> +				break;
> +		}
> +		up_read(&xfs_mount_list_lock);
> +	}
> +
> +	down_read(&xfs_mount_list_lock);
> +	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
> +		for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
> +
> +			pag = xfs_perag_get(mp, ag);
> +			if (!pag->pag_ici_init) {
> +				xfs_perag_put(pag);
> +				continue;
> +			}
> +			reclaimable += pag->pag_ici_reclaimable;
> +			xfs_perag_put(pag);
> +		}
> +	}
> +	up_read(&xfs_mount_list_lock);
> +	return reclaimable;
> +}
> +
> +static struct shrinker xfs_inode_shrinker = {
> +	.shrink = xfs_reclaim_inode_shrink,
> +	.seeks = DEFAULT_SEEKS,
> +};
> +
> +void __init
> +xfs_inode_shrinker_init(void)
> +{
> +	init_rwsem(&xfs_mount_list_lock);
> +	register_shrinker(&xfs_inode_shrinker);
> +}
> +
> +void
> +xfs_inode_shrinker_destroy(void)
> +{
> +	ASSERT(list_empty(&xfs_mount_list));
> +	unregister_shrinker(&xfs_inode_shrinker);
> +}
> +
> +void
> +xfs_inode_shrinker_register(
> +	struct xfs_mount	*mp)
> +{
> +	down_write(&xfs_mount_list_lock);
> +	list_add_tail(&mp->m_mplist, &xfs_mount_list);
> +	up_write(&xfs_mount_list_lock);
> +}
> +
> +void
> +xfs_inode_shrinker_unregister(
> +	struct xfs_mount	*mp)
> +{
> +	down_write(&xfs_mount_list_lock);
> +	list_del(&mp->m_mplist);
> +	up_write(&xfs_mount_list_lock);
>  }
> diff --git a/fs/xfs/linux-2.6/xfs_sync.h b/fs/xfs/linux-2.6/xfs_sync.h
> index d480c34..cdcbaac 100644
> --- a/fs/xfs/linux-2.6/xfs_sync.h
> +++ b/fs/xfs/linux-2.6/xfs_sync.h
> @@ -53,6 +53,11 @@ void __xfs_inode_clear_reclaim_tag(struct xfs_mount *mp, struct xfs_perag *pag,
>  int xfs_sync_inode_valid(struct xfs_inode *ip, struct xfs_perag *pag);
>  int xfs_inode_ag_iterator(struct xfs_mount *mp,
>  	int (*execute)(struct xfs_inode *ip, struct xfs_perag *pag, int flags),
> -	int flags, int tag, int write_lock);
> +	int flags, int tag, int write_lock, int *nr_to_scan);
> +
> +void xfs_inode_shrinker_init(void);
> +void xfs_inode_shrinker_destroy(void);
> +void xfs_inode_shrinker_register(struct xfs_mount *mp);
> +void xfs_inode_shrinker_unregister(struct xfs_mount *mp);
>  
>  #endif
> diff --git a/fs/xfs/quota/xfs_qm_syscalls.c b/fs/xfs/quota/xfs_qm_syscalls.c
> index f14408e..26fa431 100644
> --- a/fs/xfs/quota/xfs_qm_syscalls.c
> +++ b/fs/xfs/quota/xfs_qm_syscalls.c
> @@ -889,7 +889,8 @@ xfs_qm_dqrele_all_inodes(
>  	uint		 flags)
>  {
>  	ASSERT(mp->m_quotainfo);
> -	xfs_inode_ag_iterator(mp, xfs_dqrele_inode, flags, XFS_ICI_NO_TAG, 0);
> +	xfs_inode_ag_iterator(mp, xfs_dqrele_inode, flags,
> +				XFS_ICI_NO_TAG, 0, NULL);
>  }
>  
>  /*------------------------------------------------------------------------*/
> diff --git a/fs/xfs/xfs_ag.h b/fs/xfs/xfs_ag.h
> index b1a5a1f..abb8222 100644
> --- a/fs/xfs/xfs_ag.h
> +++ b/fs/xfs/xfs_ag.h
> @@ -223,6 +223,7 @@ typedef struct xfs_perag {
>  	int		pag_ici_init;	/* incore inode cache initialised */
>  	rwlock_t	pag_ici_lock;	/* incore inode lock */
>  	struct radix_tree_root pag_ici_root;	/* incore inode cache root */
> +	int		pag_ici_reclaimable;	/* reclaimable inodes */
>  #endif
>  	int		pagb_count;	/* pagb slots in use */
>  	xfs_perag_busy_t pagb_list[XFS_PAGB_NUM_SLOTS];	/* unstable blocks */
> diff --git a/fs/xfs/xfs_mount.h b/fs/xfs/xfs_mount.h
> index 4fa0bc7..9ff48a1 100644
> --- a/fs/xfs/xfs_mount.h
> +++ b/fs/xfs/xfs_mount.h
> @@ -259,6 +259,7 @@ typedef struct xfs_mount {
>  	wait_queue_head_t	m_wait_single_sync_task;
>  	__int64_t		m_update_flags;	/* sb flags we need to update
>  						   on the next remount,rw */
> +	struct list_head	m_mplist;	/* inode shrinker mount list */
>  } xfs_mount_t;
>  
>  /*
> -- 
> 1.5.6.5
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
