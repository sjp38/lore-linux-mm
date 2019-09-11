Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F01CC49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 14:37:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E30F20CC7
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 14:37:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="nWlWY+dA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E30F20CC7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1C046B0008; Wed, 11 Sep 2019 10:37:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCD466B000A; Wed, 11 Sep 2019 10:37:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE39D6B000C; Wed, 11 Sep 2019 10:37:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0098.hostedemail.com [216.40.44.98])
	by kanga.kvack.org (Postfix) with ESMTP id 9D88D6B0008
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:37:46 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 364A619B3F
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:37:46 +0000 (UTC)
X-FDA: 75922893732.14.frogs93_60df48db7e326
X-HE-Tag: frogs93_60df48db7e326
X-Filterd-Recvd-Size: 3547
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:37:45 +0000 (UTC)
Received: from X1 (110.8.30.213.rev.vodafone.pt [213.30.8.110])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C90A32053B;
	Wed, 11 Sep 2019 14:37:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568212664;
	bh=1fczKAAqSGjDH9qf3eCyH0kGN2ggp27wOT47W+oQbtE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=nWlWY+dAVzcqLF6822O67BEu6DZSELxK0ypBc4Thosu+kucgLcO/tbHvMQv81D6dm
	 r/i7x3BEXb/FmQm3o2lQ8QiBxKF2to5xds4voBkuA268lJwuR0CzcoA/E2mWA2b1sO
	 RloOpE8n4Y45ROxaZKYW4XFD7YyrWCYo1cQG5Y7k=
Date: Wed, 11 Sep 2019 07:37:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Johannes Weiner
 <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML
 <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, Thomas Lindroth
 <thomas.lindroth@gmail.com>, Tetsuo Handa
 <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] memcg, kmem: do not fail __GFP_NOFAIL charges
Message-Id: <20190911073740.b5c40cd47ea845884e25e265@linux-foundation.org>
In-Reply-To: <20190911120002.GQ4023@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
	<20190906125608.32129-1-mhocko@kernel.org>
	<CALvZod5w72jH8fJSFRaw7wgQTnzF6nb=+St-sSXVGSiG6Bs3Lg@mail.gmail.com>
	<20190909112245.GH27159@dhcp22.suse.cz>
	<20190911120002.GQ4023@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Sep 2019 14:00:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 09-09-19 13:22:45, Michal Hocko wrote:
> > On Fri 06-09-19 11:24:55, Shakeel Butt wrote:
> [...]
> > > I wonder what has changed since
> > > <http://lkml.kernel.org/r/20180525185501.82098-1-shakeelb@google.com/>.
> > 
> > I have completely forgot about that one. It seems that we have just
> > repeated the same discussion again. This time we have a poor user who
> > actually enabled the kmem limit.
> > 
> > I guess there was no real objection to the change back then. The primary
> > discussion revolved around the fact that the accounting will stay broken
> > even when this particular part was fixed. Considering this leads to easy
> > to trigger crash (with the limit enabled) then I guess we should just
> > make it less broken and backport to stable trees and have a serious
> > discussion about discontinuing of the limit. Start by simply failing to
> > set any limit in the current upstream kernels.
> 
> Any more concerns/objections to the patch? I can add a reference to your
> earlier post Shakeel if you want or to credit you the way you prefer.
> 
> Also are there any objections to start deprecating process of kmem
> limit? I would see it in two stages
> - 1st warn in the kernel log
> 	pr_warn("kmem.limit_in_bytes is deprecated and will be removed.
> 	        "Please report your usecase to linux-mm@kvack.org if you "
> 		"depend on this functionality."

pr_warn_once() :)

> - 2nd fail any write to kmem.limit_in_bytes
> - 3rd remove the control file completely

Sounds good to me.

