Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 3542B6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 14:02:11 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id r11so5008255lbv.27
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 11:02:09 -0700 (PDT)
Date: Tue, 9 Jul 2013 22:02:05 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: [PATCH] [MMOTM] xfs: fix dquot isolation hang
Message-ID: <20130709180203.GD9188@localhost.localdomain>
References: <1373265261-30314-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373265261-30314-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: akpm@linux-foundation.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, glommer@openvz.org, mhocko@suze.cz

Michal and Andrew, here is the patch

On Mon, Jul 08, 2013 at 04:34:21PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> The new LRU list isolation code in xfs_qm_dquot_isolate() isn't
> completely up to date.  Firstly, it needs conversion to return enum
> lru_status values, not raw numbers. Secondly - most importantly - it
> fails to unlock the dquot and relock the LRU in the LRU_RETRY path.
> This leads to deadlocks in xfstests generic/232. Fix them.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/xfs/xfs_qm.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index 46743cf..a10a720 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -659,7 +659,7 @@ xfs_qm_dquot_isolate(
>  		trace_xfs_dqreclaim_want(dqp);
>  		list_del_init(&dqp->q_lru);
>  		XFS_STATS_DEC(xs_qm_dquot_unused);
> -		return 0;
> +		return LRU_REMOVED;
>  	}
>  
>  	/*
> @@ -705,17 +705,19 @@ xfs_qm_dquot_isolate(
>  	XFS_STATS_DEC(xs_qm_dquot_unused);
>  	trace_xfs_dqreclaim_done(dqp);
>  	XFS_STATS_INC(xs_qm_dqreclaims);
> -	return 0;
> +	return LRU_REMOVED;
>  
>  out_miss_busy:
>  	trace_xfs_dqreclaim_busy(dqp);
>  	XFS_STATS_INC(xs_qm_dqreclaim_misses);
> -	return 2;
> +	return LRU_SKIP;
>  
>  out_unlock_dirty:
>  	trace_xfs_dqreclaim_busy(dqp);
>  	XFS_STATS_INC(xs_qm_dqreclaim_misses);
> -	return 3;
> +	xfs_dqunlock(dqp);
> +	spin_lock(lru_lock);
> +	return LRU_RETRY;
>  }
>  
>  static unsigned long
> -- 
> 1.8.3.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
