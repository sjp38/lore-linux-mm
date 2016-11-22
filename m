Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BECB6B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 10:48:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so11220613wme.5
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 07:48:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si3173000wmp.69.2016.11.22.07.48.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Nov 2016 07:48:07 -0800 (PST)
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort allocations
 in blkcg
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org> <20161121230332.GA3767@htj.duckdns.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
Date: Tue, 22 Nov 2016 16:47:49 +0100
MIME-Version: 1.0
In-Reply-To: <20161121230332.GA3767@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On 11/22/2016 12:03 AM, Tejun Heo wrote:
> blkcg allocates some per-cgroup data structures with GFP_NOWAIT and
> when that fails falls back to operations which aren't specific to the
> cgroup.  Occassional failures are expected under pressure and falling
> back to non-cgroup operation is the right thing to do.
> 
> Unfortunately, I forgot to add __GFP_NOWARN to these allocations and
> these expected failures end up creating a lot of noise.  Add
> __GFP_NOWARN.

Thanks. Makes me wonder whether we should e.g. add __GFP_NOWARN to
GFP_NOWAIT globally at some point.

> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Marc MERLIN <marc@merlins.org>
> Reported-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  block/blk-cgroup.c  |    9 +++++----
>  block/cfq-iosched.c |    3 ++-
>  2 files changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index b08ccbb..8ba0af7 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -185,7 +185,8 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
>  	}
>  
>  	wb_congested = wb_congested_get_create(&q->backing_dev_info,
> -					       blkcg->css.id, GFP_NOWAIT);
> +					       blkcg->css.id,
> +					       GFP_NOWAIT | __GFP_NOWARN);
>  	if (!wb_congested) {
>  		ret = -ENOMEM;
>  		goto err_put_css;
> @@ -193,7 +194,7 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
>  
>  	/* allocate */
>  	if (!new_blkg) {
> -		new_blkg = blkg_alloc(blkcg, q, GFP_NOWAIT);
> +		new_blkg = blkg_alloc(blkcg, q, GFP_NOWAIT | __GFP_NOWARN);
>  		if (unlikely(!new_blkg)) {
>  			ret = -ENOMEM;
>  			goto err_put_congested;
> @@ -1022,7 +1023,7 @@ blkcg_css_alloc(struct cgroup_subsys_state *parent_css)
>  	}
>  
>  	spin_lock_init(&blkcg->lock);
> -	INIT_RADIX_TREE(&blkcg->blkg_tree, GFP_NOWAIT);
> +	INIT_RADIX_TREE(&blkcg->blkg_tree, GFP_NOWAIT | __GFP_NOWARN);
>  	INIT_HLIST_HEAD(&blkcg->blkg_list);
>  #ifdef CONFIG_CGROUP_WRITEBACK
>  	INIT_LIST_HEAD(&blkcg->cgwb_list);
> @@ -1240,7 +1241,7 @@ int blkcg_activate_policy(struct request_queue *q,
>  		if (blkg->pd[pol->plid])
>  			continue;
>  
> -		pd = pol->pd_alloc_fn(GFP_NOWAIT, q->node);
> +		pd = pol->pd_alloc_fn(GFP_NOWAIT | __GFP_NOWARN, q->node);
>  		if (!pd)
>  			swap(pd, pd_prealloc);
>  		if (!pd) {
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index 5e24d88..b4c3b6c 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -3854,7 +3854,8 @@ cfq_get_queue(struct cfq_data *cfqd, bool is_sync, struct cfq_io_cq *cic,
>  			goto out;
>  	}
>  
> -	cfqq = kmem_cache_alloc_node(cfq_pool, GFP_NOWAIT | __GFP_ZERO,
> +	cfqq = kmem_cache_alloc_node(cfq_pool,
> +				     GFP_NOWAIT | __GFP_ZERO | __GFP_NOWARN,
>  				     cfqd->queue->node);
>  	if (!cfqq) {
>  		cfqq = &cfqd->oom_cfqq;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
