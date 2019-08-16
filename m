Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A69BC3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:03:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2694E21726
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:03:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2694E21726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8F266B0006; Fri, 16 Aug 2019 12:02:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3F6E6B0007; Fri, 16 Aug 2019 12:02:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 956256B0008; Fri, 16 Aug 2019 12:02:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id 764566B0006
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:02:59 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1D471180AD806
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:02:59 +0000 (UTC)
X-FDA: 75828759678.28.flame21_371e03d6cde00
X-HE-Tag: flame21_371e03d6cde00
X-Filterd-Recvd-Size: 3197
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:02:58 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3F51EAF97;
	Fri, 16 Aug 2019 16:02:57 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id A3BC71E4009; Fri, 16 Aug 2019 18:02:56 +0200 (CEST)
Date: Fri, 16 Aug 2019 18:02:56 +0200
From: Jan Kara <jack@suse.cz>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: Re: [PATCH 5/5] writeback, memcg: Implement foreign dirty flushing
Message-ID: <20190816160256.GI3041@quack2.suse.cz>
References: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
 <20190815195930.GF2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815195930.GF2263813@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 12:59:30, Tejun Heo wrote:
> +/* issue foreign writeback flushes for recorded foreign dirtying events */
> +void mem_cgroup_flush_foreign(struct bdi_writeback *wb)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
> +	unsigned long intv = msecs_to_jiffies(dirty_expire_interval * 10);
> +	u64 now = jiffies_64;
> +	int i;
> +
> +	for (i = 0; i < MEMCG_CGWB_FRN_CNT; i++) {
> +		struct memcg_cgwb_frn *frn = &memcg->cgwb_frn[i];
> +
> +		/*
> +		 * If the record is older than dirty_expire_interval,
> +		 * writeback on it has already started.  No need to kick it
> +		 * off again.  Also, don't start a new one if there's
> +		 * already one in flight.
> +		 */
> +		if (frn->at > now - intv && atomic_read(&frn->done.cnt) == 1) {
> +			frn->at = 0;
> +			cgroup_writeback_by_id(frn->bdi_id, frn->memcg_id,
> +					       LONG_MAX, WB_REASON_FOREIGN_FLUSH,
> +					       &frn->done);
> +		}

Hum, two concerns here still:

1) You ask to writeback LONG_MAX pages. That means that you give up any
livelock avoidance for the flusher work and you can writeback almost
forever if someone is busily dirtying pages in the wb. I think you need to
pick something like amount of dirty pages in the given wb (that would have
to be fetched after everything is looked up) or just some arbitrary
reasonably small constant like 1024 (but then I guess there's no guarantee
stuck memcg will make any progress and you've invalidated the frn entry
here).

2) When you invalidate frn entry here by writing 0 to 'at', it's likely to get
reused soon. Possibly while the writeback is still running. And then you
won't start any writeback for the new entry because of the
atomic_read(&frn->done.cnt) == 1 check. This seems like it could happen
pretty frequently?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

