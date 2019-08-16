Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DD16C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:45:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09A56206C2
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:45:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09A56206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B1496B0007; Fri, 16 Aug 2019 11:45:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93AF86B0008; Fri, 16 Aug 2019 11:45:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8521C6B000A; Fri, 16 Aug 2019 11:45:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id 649E06B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:45:42 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 17B428248AD7
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:45:42 +0000 (UTC)
X-FDA: 75828716124.27.plant96_31b7b6bc13d52
X-HE-Tag: plant96_31b7b6bc13d52
X-Filterd-Recvd-Size: 5283
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:45:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E8AACAE1C;
	Fri, 16 Aug 2019 15:45:37 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 3EB341E4009; Fri, 16 Aug 2019 17:45:37 +0200 (CEST)
Date: Fri, 16 Aug 2019 17:45:37 +0200
From: Jan Kara <jack@suse.cz>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 3/5] writeback: Separate out wb_get_lookup() from
 wb_get_create()
Message-ID: <20190816154537.GG3041@quack2.suse.cz>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
 <20190815195823.GD2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815195823.GD2263813@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 12:58:23, Tejun Heo wrote:
> Separate out wb_get_lookup() which doesn't try to create one if there
> isn't already one from wb_get_create().  This will be used by later
> patches.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/backing-dev.h |    2 +
>  mm/backing-dev.c            |   55 +++++++++++++++++++++++++++++---------------
>  2 files changed, 39 insertions(+), 18 deletions(-)
> 
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -230,6 +230,8 @@ static inline int bdi_sched_wait(void *w
>  struct bdi_writeback_congested *
>  wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp);
>  void wb_congested_put(struct bdi_writeback_congested *congested);
> +struct bdi_writeback *wb_get_lookup(struct backing_dev_info *bdi,
> +				    struct cgroup_subsys_state *memcg_css);
>  struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
>  				    struct cgroup_subsys_state *memcg_css,
>  				    gfp_t gfp);
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -618,13 +618,12 @@ out_put:
>  }
>  
>  /**
> - * wb_get_create - get wb for a given memcg, create if necessary
> + * wb_get_lookup - get wb for a given memcg
>   * @bdi: target bdi
>   * @memcg_css: cgroup_subsys_state of the target memcg (must have positive ref)
> - * @gfp: allocation mask to use
>   *
> - * Try to get the wb for @memcg_css on @bdi.  If it doesn't exist, try to
> - * create one.  The returned wb has its refcount incremented.
> + * Try to get the wb for @memcg_css on @bdi.  The returned wb has its
> + * refcount incremented.
>   *
>   * This function uses css_get() on @memcg_css and thus expects its refcnt
>   * to be positive on invocation.  IOW, rcu_read_lock() protection on
> @@ -641,6 +640,39 @@ out_put:
>   * each lookup.  On mismatch, the existing wb is discarded and a new one is
>   * created.
>   */
> +struct bdi_writeback *wb_get_lookup(struct backing_dev_info *bdi,
> +				    struct cgroup_subsys_state *memcg_css)
> +{
> +	struct bdi_writeback *wb;
> +
> +	if (!memcg_css->parent)
> +		return &bdi->wb;
> +
> +	rcu_read_lock();
> +	wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
> +	if (wb) {
> +		struct cgroup_subsys_state *blkcg_css;
> +
> +		/* see whether the blkcg association has changed */
> +		blkcg_css = cgroup_get_e_css(memcg_css->cgroup, &io_cgrp_subsys);
> +		if (unlikely(wb->blkcg_css != blkcg_css || !wb_tryget(wb)))
> +			wb = NULL;
> +		css_put(blkcg_css);
> +	}
> +	rcu_read_unlock();
> +
> +	return wb;
> +}
> +
> +/**
> + * wb_get_create - get wb for a given memcg, create if necessary
> + * @bdi: target bdi
> + * @memcg_css: cgroup_subsys_state of the target memcg (must have positive ref)
> + * @gfp: allocation mask to use
> + *
> + * Try to get the wb for @memcg_css on @bdi.  If it doesn't exist, try to
> + * create one.  See wb_get_lookup() for more details.
> + */
>  struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
>  				    struct cgroup_subsys_state *memcg_css,
>  				    gfp_t gfp)
> @@ -653,20 +685,7 @@ struct bdi_writeback *wb_get_create(stru
>  		return &bdi->wb;
>  
>  	do {
> -		rcu_read_lock();
> -		wb = radix_tree_lookup(&bdi->cgwb_tree, memcg_css->id);
> -		if (wb) {
> -			struct cgroup_subsys_state *blkcg_css;
> -
> -			/* see whether the blkcg association has changed */
> -			blkcg_css = cgroup_get_e_css(memcg_css->cgroup,
> -						     &io_cgrp_subsys);
> -			if (unlikely(wb->blkcg_css != blkcg_css ||
> -				     !wb_tryget(wb)))
> -				wb = NULL;
> -			css_put(blkcg_css);
> -		}
> -		rcu_read_unlock();
> +		wb = wb_get_lookup(bdi, memcg_css);
>  	} while (!wb && !cgwb_create(bdi, memcg_css, gfp));
>  
>  	return wb;
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

