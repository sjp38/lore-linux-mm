Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA8E6B02A4
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 14:12:32 -0400 (EDT)
Date: Thu, 15 Jul 2010 14:12:28 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] xfs: track AGs with reclaimable inodes in per-ag
 radix tree
Message-ID: <20100715181228.GC14554@infradead.org>
References: <1279194418-16119-1-git-send-email-david@fromorbit.com>
 <1279194418-16119-4-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279194418-16119-4-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> + */
> +static struct xfs_perag *
> +xfs_inode_ag_iter_next_pag(
> +	struct xfs_mount	*mp,
> +	xfs_agnumber_t		*first,
> +	int			tag)
> +{
> +	struct xfs_perag	*pag = NULL;
> +
> +	if (tag == XFS_ICI_RECLAIM_TAG) {
> +		int found;
> +		int ref;
> +
> +		spin_lock(&mp->m_perag_lock);
> +		found = radix_tree_gang_lookup_tag(&mp->m_perag_tree,
> +				(void **)&pag, *first, 1, tag);
> +		if (found <= 0) {
> +			spin_unlock(&mp->m_perag_lock);
> +			return NULL;
> +		}
> +		*first = pag->pag_agno + 1;
> +		/* open coded pag reference increment */
> +		ref = atomic_inc_return(&pag->pag_ref);
> +		spin_unlock(&mp->m_perag_lock);
> +		trace_xfs_perag_get_reclaim(mp, pag->pag_agno, ref, _RET_IP_);
> +	} else {
> +		pag = xfs_perag_get(mp, *first);
> +		(*first)++;
> +	}

I wonder if we should just split the AG iterator for inode reclaim vs
the rest.  We now have this difference in addition to taking the per-AG
lock exclusive instead of shared.

Anyway, the patch looks good for now,


Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
