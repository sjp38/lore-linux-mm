Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F74DC49ED7
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 03:50:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34BC1217D6
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 03:50:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Jy0Yk/Rd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34BC1217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86D156B0330; Wed, 18 Sep 2019 23:50:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81DF16B0331; Wed, 18 Sep 2019 23:50:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 733496B0332; Wed, 18 Sep 2019 23:50:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF8F6B0330
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 23:50:03 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id F15C0824376E
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 03:50:02 +0000 (UTC)
X-FDA: 75950291844.04.pies09_52fd9076c03
X-HE-Tag: pies09_52fd9076c03
X-Filterd-Recvd-Size: 3624
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 03:50:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dIaTx+Cw6W1z2kh8erm4sN6OIGIJmSGITOU+49mfvpU=; b=Jy0Yk/Rd26StseUe6OJL3CH6q
	2rTWzns+Br6nwBlrgwrUu0ms90xlJr2TUerpgXXrz3lK8w5KV+3tIeEg6+KFsKaOz/uUujXRzzOIi
	x9gskoDIrBNBg68RTQMrxd/SA9PnC9s/6+i3FJGwd8ncqXM94dw2rpD1YDWcvSkYpN7n72lWLtjCt
	DOcRPY0cMNpt4A0pi7oVgmfYS1EmgLXpDfCkQYIBt4B0W8vSTbLGNisKGpEgyREPE+EkknGfsmLBy
	h1zZaNLoTx33ojutcoknm9FlLeJxxSEGHJ1Byox5ClyJI7tcIfK2Zmi/SiDm2I069p0DauYfEJ36o
	KtGKJB0Gw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1iAnS1-0004CN-AJ; Thu, 19 Sep 2019 03:49:49 +0000
Date: Wed, 18 Sep 2019 20:49:49 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Lin Feng <linf@wangsu.com>
Cc: Michal Hocko <mhocko@kernel.org>, corbet@lwn.net, mcgrof@kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, keescook@chromium.org,
	mchehab+samsung@kernel.org, mgorman@techsingularity.net,
	vbabka@suse.cz, ktkhai@virtuozzo.com, hannes@cmpxchg.org,
	Jens Axboe <axboe@kernel.dk>, Omar Sandoval <osandov@fb.com>,
	Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH] [RFC] vmscan.c: add a sysctl entry for controlling
 memory reclaim IO congestion_wait length
Message-ID: <20190919034949.GF9880@bombadil.infradead.org>
References: <20190917115824.16990-1-linf@wangsu.com>
 <20190917120646.GT29434@bombadil.infradead.org>
 <20190918123342.GF12770@dhcp22.suse.cz>
 <6ae57d3e-a3f4-a3db-5654-4ec6001941a9@wangsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ae57d3e-a3f4-a3db-5654-4ec6001941a9@wangsu.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 19, 2019 at 10:33:10AM +0800, Lin Feng wrote:
> On 9/18/19 20:33, Michal Hocko wrote:
> > I absolutely agree here. From you changelog it is also not clear what is
> > the underlying problem. Both congestion_wait and wait_iff_congested
> > should wake up early if the congestion is handled. Is this not the case?
> 
> For now I don't know why, codes seem should work as you said, maybe I need to
> trace more of the internals.
> But weird thing is that once I set the people-disliked-tunable iowait
> drop down instantly, this is contradictory to the code design.

Yes, this is quite strange.  If setting a smaller timeout makes a
difference, that indicates we're not waking up soon enough.  I see
two possibilities; one is that a wakeup is missing somewhere -- ie the
conditions under which we call clear_wb_congested() are wrong.  Or we
need to wake up sooner.

Umm.  We have clear_wb_congested() called from exactly one spot --
clear_bdi_congested().  That is only called from:

drivers/block/pktcdvd.c
fs/ceph/addr.c
fs/fuse/control.c
fs/fuse/dev.c
fs/nfs/write.c

Jens, is something supposed to be calling clear_bdi_congested() in the
block layer?  blk_clear_congested() used to exist until October 29th
last year.  Or is something else supposed to be waking up tasks that
are sleeping on congestion?


