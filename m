Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8675DC41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 14:54:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 553E22067D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 14:54:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 553E22067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0E126B029B; Thu, 15 Aug 2019 10:54:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBFAF6B029C; Thu, 15 Aug 2019 10:54:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDD096B029D; Thu, 15 Aug 2019 10:54:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id B04706B029B
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:54:24 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 53958180AD801
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:54:24 +0000 (UTC)
X-FDA: 75824958048.10.tiger14_7db9120fea73f
X-HE-Tag: tiger14_7db9120fea73f
X-Filterd-Recvd-Size: 3735
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:54:23 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 704C7ABB1;
	Thu, 15 Aug 2019 14:54:22 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id E34F51E4200; Thu, 15 Aug 2019 16:54:21 +0200 (CEST)
Date: Thu, 15 Aug 2019 16:54:21 +0200
From: Jan Kara <jack@suse.cz>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 3/4] writeback, memcg: Implement cgroup_writeback_by_id()
Message-ID: <20190815145421.GN14313@quack2.suse.cz>
References: <20190803140155.181190-1-tj@kernel.org>
 <20190803140155.181190-4-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190803140155.181190-4-tj@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 03-08-19 07:01:54, Tejun Heo wrote:
> Implement cgroup_writeback_by_id() which initiates cgroup writeback
> from bdi and memcg IDs.  This will be used by memcg foreign inode
> flushing.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> ---
>  fs/fs-writeback.c         | 64 +++++++++++++++++++++++++++++++++++++++
>  include/linux/writeback.h |  4 +++
>  2 files changed, 68 insertions(+)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 6129debdc938..5c79d7acefdb 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -880,6 +880,70 @@ static void bdi_split_work_to_wbs(struct backing_dev_info *bdi,
>  		wb_put(last_wb);
>  }
>  
> +/**
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
> +	/* and find the associated wb */
> +	wb = wb_get_create(bdi, memcg_css, GFP_NOWAIT | __GFP_NOWARN);
> +	if (!wb) {
> +		ret = -ENOMEM;
> +		goto out_css_put;
> +	}

One more thought: You don't want the "_create" part here, do you? If
there's any point in writing back using this wb, it must be attached to
some inode and thus it must exist. In the normal case wb_get_create() will
just fetch the reference and be done with it but when you feed garbage into
this function due to id going stale or frn structures getting corrupted due
to concurrent access, you can be creating bogus wb structures in bdi...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

