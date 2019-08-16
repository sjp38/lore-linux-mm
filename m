Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49D99C3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:47:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A33C20578
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:47:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A33C20578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A252C6B0007; Fri, 16 Aug 2019 11:47:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AF376B0008; Fri, 16 Aug 2019 11:47:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84FA66B000A; Fri, 16 Aug 2019 11:47:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0132.hostedemail.com [216.40.44.132])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC496B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:47:12 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 01EB0180AD80A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:47:12 +0000 (UTC)
X-FDA: 75828719904.26.yard86_3ecf264b35f4b
X-HE-Tag: yard86_3ecf264b35f4b
X-Filterd-Recvd-Size: 4458
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:47:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E9567AF55;
	Fri, 16 Aug 2019 15:47:09 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id AD9061E4009; Fri, 16 Aug 2019 17:47:09 +0200 (CEST)
Date: Fri, 16 Aug 2019 17:47:09 +0200
From: Jan Kara <jack@suse.cz>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 4/5] writeback, memcg: Implement cgroup_writeback_by_id()
Message-ID: <20190816154709.GH3041@quack2.suse.cz>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
 <20190815195902.GE2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815195902.GE2263813@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 12:59:02, Tejun Heo wrote:
> Implement cgroup_writeback_by_id() which initiates cgroup writeback
> from bdi and memcg IDs.  This will be used by memcg foreign inode
> flushing.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza


> ---
>  fs/fs-writeback.c         |   67 ++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/writeback.h |    2 +
>  2 files changed, 69 insertions(+)
> 
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -892,6 +892,73 @@ restart:
>  }
>  
>  /**
> + * cgroup_writeback_by_id - initiate cgroup writeback from bdi and memcg IDs
> + * @bdi_id: target bdi id
> + * @memcg_id: target memcg css id
> + * @nr_pages: number of pages to write
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
> +	/* issue the writeback work */
> +	work = kzalloc(sizeof(*work), GFP_NOWAIT | __GFP_NOWARN);
> +	if (work) {
> +		work->nr_pages = nr;
> +		work->sync_mode = WB_SYNC_NONE;
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

