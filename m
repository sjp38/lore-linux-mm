Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 2B52E6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 22:37:24 -0400 (EDT)
Date: Thu, 20 Jun 2013 12:37:19 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v11 25/25] list_lru: dynamically adjust node arrays
Message-ID: <20130620023719.GO29338@dastard>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
 <1370550898-26711-26-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370550898-26711-26-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, mgorman@suse.de, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>

On Fri, Jun 07, 2013 at 12:34:58AM +0400, Glauber Costa wrote:
> We currently use a compile-time constant to size the node array for the
> list_lru structure. Due to this, we don't need to allocate any memory at
> initialization time. But as a consequence, the structures that contain
> embedded list_lru lists can become way too big (the superblock for
> instance contains two of them).
> 
> This patch aims at ameliorating this situation by dynamically allocating
> the node arrays with the firmware provided nr_node_ids.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>

Just a small bug:

> index c3f8ea9..9c2b656 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1591,6 +1591,7 @@ xfs_free_buftarg(
>  	struct xfs_mount	*mp,
>  	struct xfs_buftarg	*btp)
>  {
> +	list_lru_destroy(&btp->bt_lru);
>  	unregister_shrinker(&btp->bt_shrinker);

Unregister the shrinker before destroying the list the shrinker
walks. Same for all the other cases....

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
