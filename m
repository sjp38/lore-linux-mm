Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83376C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 13:49:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F3A9217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 13:49:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F3A9217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E12536B0587; Mon, 26 Aug 2019 09:49:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC2886B0589; Mon, 26 Aug 2019 09:49:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD8416B058A; Mon, 26 Aug 2019 09:49:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0115.hostedemail.com [216.40.44.115])
	by kanga.kvack.org (Postfix) with ESMTP id AFB306B0587
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 09:49:43 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 5F4A3824CA3F
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:49:43 +0000 (UTC)
X-FDA: 75864711846.13.veil52_37bbf81653308
X-HE-Tag: veil52_37bbf81653308
X-Filterd-Recvd-Size: 5344
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:49:42 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 66B20ABF4;
	Mon, 26 Aug 2019 13:49:41 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 170331E3DA1; Mon, 26 Aug 2019 15:49:40 +0200 (CEST)
Date: Mon, 26 Aug 2019 15:49:40 +0200
From: Jan Kara <jack@suse.cz>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH v3 4/5] writeback, memcg: Implement
 cgroup_writeback_by_id()
Message-ID: <20190826134940.GE10614@quack2.suse.cz>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
 <20190815195902.GE2263813@devbig004.ftw2.facebook.com>
 <20190821210210.GM2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821210210.GM2263813@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 21-08-19 14:02:10, Tejun Heo wrote:
> Implement cgroup_writeback_by_id() which initiates cgroup writeback
> from bdi and memcg IDs.  This will be used by memcg foreign inode
> flushing.
> 
> v2: Use wb_get_lookup() instead of wb_get_create() to avoid creating
>     spurious wbs.
> 
> v3: Interpret 0 @nr as 1.25 * nr_dirty to implement best-effort
>     flushing while avoding possible livelocks.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/fs-writeback.c         |   83 ++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/writeback.h |    2 +
>  2 files changed, 85 insertions(+)
> 
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -892,6 +892,89 @@ restart:
>  }
>  
>  /**
> + * cgroup_writeback_by_id - initiate cgroup writeback from bdi and memcg IDs
> + * @bdi_id: target bdi id
> + * @memcg_id: target memcg css id
> + * @nr_pages: number of pages to write, 0 for best-effort dirty flushing
> + * @reason: reason why some writeback work initiated
> + * @done: target wb_completion
> + *
> + * Initiate flush of the bdi_writeback identified by @bdi_id and @memcg_id
> + * with the specified parameters.
> + */
> +int cgroup_writeback_by_id(u64 bdi_id, int memcg_id, unsigned long nr,
> +			   enum wb_reason reason, struct wb_completion *done)
> +{
> +	struct backing_dev_info *bdi;
> +	struct cgroup_subsys_state *memcg_css;
> +	struct bdi_writeback *wb;
> +	struct wb_writeback_work *work;
> +	int ret;
> +
> +	/* lookup bdi and memcg */
> +	bdi = bdi_get_by_id(bdi_id);
> +	if (!bdi)
> +		return -ENOENT;
> +
> +	rcu_read_lock();
> +	memcg_css = css_from_id(memcg_id, &memory_cgrp_subsys);
> +	if (memcg_css && !css_tryget(memcg_css))
> +		memcg_css = NULL;
> +	rcu_read_unlock();
> +	if (!memcg_css) {
> +		ret = -ENOENT;
> +		goto out_bdi_put;
> +	}
> +
> +	/*
> +	 * And find the associated wb.  If the wb isn't there already
> +	 * there's nothing to flush, don't create one.
> +	 */
> +	wb = wb_get_lookup(bdi, memcg_css);
> +	if (!wb) {
> +		ret = -ENOENT;
> +		goto out_css_put;
> +	}
> +
> +	/*
> +	 * If @nr is zero, the caller is attempting to write out most of
> +	 * the currently dirty pages.  Let's take the current dirty page
> +	 * count and inflate it by 25% which should be large enough to
> +	 * flush out most dirty pages while avoiding getting livelocked by
> +	 * concurrent dirtiers.
> +	 */
> +	if (!nr) {
> +		unsigned long filepages, headroom, dirty, writeback;
> +
> +		mem_cgroup_wb_stats(wb, &filepages, &headroom, &dirty,
> +				      &writeback);
> +		nr = dirty * 10 / 8;
> +	}
> +
> +	/* issue the writeback work */
> +	work = kzalloc(sizeof(*work), GFP_NOWAIT | __GFP_NOWARN);
> +	if (work) {
> +		work->nr_pages = nr;
> +		work->sync_mode = WB_SYNC_NONE;
> +		work->range_cyclic = 1;
> +		work->reason = reason;
> +		work->done = done;
> +		work->auto_free = 1;
> +		wb_queue_work(wb, work);
> +		ret = 0;
> +	} else {
> +		ret = -ENOMEM;
> +	}
> +
> +	wb_put(wb);
> +out_css_put:
> +	css_put(memcg_css);
> +out_bdi_put:
> +	bdi_put(bdi);
> +	return ret;
> +}
> +
> +/**
>   * cgroup_writeback_umount - flush inode wb switches for umount
>   *
>   * This function is called when a super_block is about to be destroyed and
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -217,6 +217,8 @@ void wbc_attach_and_unlock_inode(struct
>  void wbc_detach_inode(struct writeback_control *wbc);
>  void wbc_account_cgroup_owner(struct writeback_control *wbc, struct page *page,
>  			      size_t bytes);
> +int cgroup_writeback_by_id(u64 bdi_id, int memcg_id, unsigned long nr_pages,
> +			   enum wb_reason reason, struct wb_completion *done);
>  void cgroup_writeback_umount(void);
>  
>  /**
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

