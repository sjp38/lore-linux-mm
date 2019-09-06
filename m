Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D03F2C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 07:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A03C2208C3
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 07:27:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A03C2208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2346C6B0003; Fri,  6 Sep 2019 03:27:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E5266B0006; Fri,  6 Sep 2019 03:27:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FAAD6B0007; Fri,  6 Sep 2019 03:27:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC1B36B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 03:27:14 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6D9906123
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 07:27:14 +0000 (UTC)
X-FDA: 75903664788.16.use67_795fd8da12606
X-HE-Tag: use67_795fd8da12606
X-Filterd-Recvd-Size: 3062
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 07:27:13 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 99715AF1D;
	Fri,  6 Sep 2019 07:27:12 +0000 (UTC)
Date: Fri, 6 Sep 2019 09:27:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Thomas Lindroth <thomas.lindroth@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org
Subject: Re: [BUG] kmemcg limit defeats __GFP_NOFAIL allocation
Message-ID: <20190906072711.GD14491@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <666dbcde-1b8a-9e2d-7d1f-48a117c78ae1@I-love.SAKURA.ne.jp>
 <ccf79dd9-b2e5-0d78-f520-164d198f9ca4@gmail.com>
 <4d0eda9a-319d-1a7d-1eed-71da90902367@i-love.sakura.ne.jp>
 <20190904112500.GO3838@dhcp22.suse.cz>
 <0056063b-46ff-0ebd-ff0d-c96a1f9ae6b1@i-love.sakura.ne.jp>
 <20190904142902.GZ3838@dhcp22.suse.cz>
 <405ce28b-c0b4-780c-c883-42d741ec60e0@i-love.sakura.ne.jp>
 <16fdbf78-3cf4-81cf-2a73-d38cb66afc17@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16fdbf78-3cf4-81cf-2a73-d38cb66afc17@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 06-09-19 01:11:53, Thomas Lindroth wrote:
> On 9/4/19 6:39 PM, Tetsuo Handa wrote:
> > On 2019/09/04 23:29, Michal Hocko wrote:
> > > Ohh, right. We are trying to uncharge something that hasn't been charged
> > > because page_counter_try_charge has failed. So the fix needs to be more
> > > involved. Sorry, I should have realized that.
> > 
> > OK. Survived the test. Thomas, please try.
> > 
> > > ---
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 9ec5e12486a7..e18108b2b786 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -2821,6 +2821,16 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
> > >   	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
> > >   	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
> > > +
> > > +		/*
> > > +		 * Enforce __GFP_NOFAIL allocation because callers are not
> > > +		 * prepared to see failures and likely do not have any failure
> > > +		 * handling code.
> > > +		 */
> > > +		if (gfp & __GFP_NOFAIL) {
> > > +			page_counter_charge(&memcg->kmem, nr_pages);
> > > +			return 0;
> > > +		}
> > >   		cancel_charge(memcg, nr_pages);
> > >   		return -ENOMEM;
> > >   	}
> > > 
> 
> I tried the patch with 5.2.11 and wasn't able to trigger any null pointer
> deref crashes with it. Testing is tricky because the OOM killer will still
> run and eventually kill bash and whatever runs in the cgroup.

Yeah, this is unfortunate but also unfixable I am afraid. I will post an
official patch with a changelog later today.

Thanks for testing!
-- 
Michal Hocko
SUSE Labs

