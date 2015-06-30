Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id A942C6B006E
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:08:49 -0400 (EDT)
Received: by wgck11 with SMTP id k11so3831013wgc.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 02:08:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk3si18252399wib.13.2015.06.30.02.08.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 02:08:47 -0700 (PDT)
Date: Tue, 30 Jun 2015 11:08:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 24/51] writeback, blkcg: associate each blkcg_gq with the
 corresponding bdi_writeback_congested
Message-ID: <20150630090842.GF7252@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-25-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-25-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri 22-05-15 17:13:38, Tejun Heo wrote:
> A blkg (blkcg_gq) can be congested and decongested independently from
> other blkgs on the same request_queue.  Accordingly, for cgroup
> writeback support, the congestion status at bdi (backing_dev_info)
> should be split and updated separately from matching blkg's.
> 
> This patch prepares by adding blkg->wb_congested and associating a
> blkg with its matching per-blkcg bdi_writeback_congested on creation.
> 
> v2: Updated to associate bdi_writeback_congested instead of
>     bdi_writeback.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Vivek Goyal <vgoyal@redhat.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

> ---
>  block/blk-cgroup.c         | 17 +++++++++++++++--
>  include/linux/blk-cgroup.h |  6 ++++++
>  2 files changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index 979cfdb..31610ae 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -182,6 +182,7 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
>  				    struct blkcg_gq *new_blkg)
>  {
>  	struct blkcg_gq *blkg;
> +	struct bdi_writeback_congested *wb_congested;
>  	int i, ret;
>  
>  	WARN_ON_ONCE(!rcu_read_lock_held());
> @@ -193,22 +194,30 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
>  		goto err_free_blkg;
>  	}
>  
> +	wb_congested = wb_congested_get_create(&q->backing_dev_info,
> +					       blkcg->css.id, GFP_ATOMIC);
> +	if (!wb_congested) {
> +		ret = -ENOMEM;
> +		goto err_put_css;
> +	}
> +
>  	/* allocate */
>  	if (!new_blkg) {
>  		new_blkg = blkg_alloc(blkcg, q, GFP_ATOMIC);
>  		if (unlikely(!new_blkg)) {
>  			ret = -ENOMEM;
> -			goto err_put_css;
> +			goto err_put_congested;
>  		}
>  	}
>  	blkg = new_blkg;
> +	blkg->wb_congested = wb_congested;
>  
>  	/* link parent */
>  	if (blkcg_parent(blkcg)) {
>  		blkg->parent = __blkg_lookup(blkcg_parent(blkcg), q, false);
>  		if (WARN_ON_ONCE(!blkg->parent)) {
>  			ret = -EINVAL;
> -			goto err_put_css;
> +			goto err_put_congested;
>  		}
>  		blkg_get(blkg->parent);
>  	}
> @@ -245,6 +254,8 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
>  	blkg_put(blkg);
>  	return ERR_PTR(ret);
>  
> +err_put_congested:
> +	wb_congested_put(wb_congested);
>  err_put_css:
>  	css_put(&blkcg->css);
>  err_free_blkg:
> @@ -391,6 +402,8 @@ void __blkg_release_rcu(struct rcu_head *rcu_head)
>  	if (blkg->parent)
>  		blkg_put(blkg->parent);
>  
> +	wb_congested_put(blkg->wb_congested);
> +
>  	blkg_free(blkg);
>  }
>  EXPORT_SYMBOL_GPL(__blkg_release_rcu);
> diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
> index 3033eb1..07a32b8 100644
> --- a/include/linux/blk-cgroup.h
> +++ b/include/linux/blk-cgroup.h
> @@ -99,6 +99,12 @@ struct blkcg_gq {
>  	struct hlist_node		blkcg_node;
>  	struct blkcg			*blkcg;
>  
> +	/*
> +	 * Each blkg gets congested separately and the congestion state is
> +	 * propagated to the matching bdi_writeback_congested.
> +	 */
> +	struct bdi_writeback_congested	*wb_congested;
> +
>  	/* all non-root blkcg_gq's are guaranteed to have access to parent */
>  	struct blkcg_gq			*parent;
>  
> -- 
> 2.4.0
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
