Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 959786B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 02:27:10 -0400 (EDT)
Date: Wed, 24 Aug 2011 02:27:06 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 10/13] xfs: convert buftarg LRU to generic code
Message-ID: <20110824062706.GD24077@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-11-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314089786-20535-11-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

> -STATIC void
> +static inline void
>  xfs_buf_lru_add(
>  	struct xfs_buf	*bp)
>  {
> -	struct xfs_buftarg *btp = bp->b_target;
> -
> -	spin_lock(&btp->bt_lru_lock);
> -	if (list_empty(&bp->b_lru)) {
> +	if (list_lru_add(&bp->b_target->bt_lru, &bp->b_lru))
>  		atomic_inc(&bp->b_hold);
> -		list_add_tail(&bp->b_lru, &btp->bt_lru);
> -		btp->bt_lru_nr++;
> -	}
> -	spin_unlock(&btp->bt_lru_lock);
>  }

Is there any point in keeping this wrapper?

> +static inline void
>  xfs_buf_lru_del(
>  	struct xfs_buf	*bp)
>  {
>  	if (list_empty(&bp->b_lru))
>  		return;
>  
> +	list_lru_del(&bp->b_target->bt_lru, &bp->b_lru);
>  }

It seems like all callers of list_lru_del really want the unlocked
check.  Out of your current set only two of the inode.c callers
are missing it, but given that those set I_FREEING first they should
be safe to do it as well.  What do you think about pulling
the unlocked check into list_lru_del?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
