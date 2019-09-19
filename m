Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F6AC3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 08:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 521E521848
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 08:22:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 521E521848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1D4A6B0346; Thu, 19 Sep 2019 04:22:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCE4F6B0348; Thu, 19 Sep 2019 04:22:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBEB76B0349; Thu, 19 Sep 2019 04:22:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0211.hostedemail.com [216.40.44.211])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF566B0346
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 04:22:12 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2384B82437C9
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 08:22:12 +0000 (UTC)
X-FDA: 75950977704.09.ray45_3045fbb3f284e
X-HE-Tag: ray45_3045fbb3f284e
X-Filterd-Recvd-Size: 4090
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 08:22:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A07A8AFBF;
	Thu, 19 Sep 2019 08:22:09 +0000 (UTC)
Date: Thu, 19 Sep 2019 10:22:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Lin Feng <linf@wangsu.com>
Cc: Matthew Wilcox <willy@infradead.org>, corbet@lwn.net, mcgrof@kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, keescook@chromium.org,
	mchehab+samsung@kernel.org, mgorman@techsingularity.net,
	vbabka@suse.cz, ktkhai@virtuozzo.com, hannes@cmpxchg.org,
	Jens Axboe <axboe@kernel.dk>, Omar Sandoval <osandov@fb.com>,
	Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH] [RFC] vmscan.c: add a sysctl entry for controlling
 memory reclaim IO congestion_wait length
Message-ID: <20190919082208.GB15782@dhcp22.suse.cz>
References: <20190917115824.16990-1-linf@wangsu.com>
 <20190917120646.GT29434@bombadil.infradead.org>
 <20190918123342.GF12770@dhcp22.suse.cz>
 <6ae57d3e-a3f4-a3db-5654-4ec6001941a9@wangsu.com>
 <20190919034949.GF9880@bombadil.infradead.org>
 <33090db5-c7d4-8d7d-0082-ee7643d15775@wangsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33090db5-c7d4-8d7d-0082-ee7643d15775@wangsu.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 19-09-19 15:46:11, Lin Feng wrote:
> 
> 
> On 9/19/19 11:49, Matthew Wilcox wrote:
> > On Thu, Sep 19, 2019 at 10:33:10AM +0800, Lin Feng wrote:
> > > On 9/18/19 20:33, Michal Hocko wrote:
> > > > I absolutely agree here. From you changelog it is also not clear what is
> > > > the underlying problem. Both congestion_wait and wait_iff_congested
> > > > should wake up early if the congestion is handled. Is this not the case?
> > > 
> > > For now I don't know why, codes seem should work as you said, maybe I need to
> > > trace more of the internals.
> > > But weird thing is that once I set the people-disliked-tunable iowait
> > > drop down instantly, this is contradictory to the code design.
> > 
> > Yes, this is quite strange.  If setting a smaller timeout makes a
> > difference, that indicates we're not waking up soon enough.  I see
> > two possibilities; one is that a wakeup is missing somewhere -- ie the
> > conditions under which we call clear_wb_congested() are wrong.  Or we
> > need to wake up sooner.
> > 
> > Umm.  We have clear_wb_congested() called from exactly one spot --
> > clear_bdi_congested().  That is only called from:
> > 
> > drivers/block/pktcdvd.c
> > fs/ceph/addr.c
> > fs/fuse/control.c
> > fs/fuse/dev.c
> > fs/nfs/write.c
> > 
> > Jens, is something supposed to be calling clear_bdi_congested() in the
> > block layer?  blk_clear_congested() used to exist until October 29th
> > last year.  Or is something else supposed to be waking up tasks that
> > are sleeping on congestion?
> > 
> 
> IIUC it looks like after commit a1ce35fa49852db60fc6e268038530be533c5b15,

This is something for Jens to comment on. Not waiting up on congestion
indeed sounds like a bug.

> besides those *.c places as you mentioned above, vmscan codes will always
> wait as long as 100ms and nobody wakes them up.

Yes this is true but you should realize that this path is triggered only
under heavy memory reclaim cases where there is nothing to reclaim
because there are too many pages already isolated and we are waiting for
reclaimers to make some progress on them. It is also possible that there
are simply no reclaimable pages at all and we are heading the OOM
situation. In both cases waiting a bit shouldn't be critical because
this is really a cold path. It would be much better to have a mechanism
to wake up earlier but this is likely to be non trivial and I am not
sure worth the effort considering how rare this should be.
-- 
Michal Hocko
SUSE Labs

