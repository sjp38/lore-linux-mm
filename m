Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B30EC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 11:29:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E32F20854
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 11:29:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E32F20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FF696B0003; Fri,  6 Sep 2019 07:29:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AE086B0006; Fri,  6 Sep 2019 07:29:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59D746B0007; Fri,  6 Sep 2019 07:29:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0104.hostedemail.com [216.40.44.104])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD826B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 07:29:04 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CF9782DFB
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:29:03 +0000 (UTC)
X-FDA: 75904274166.15.drop63_31fc2bdaa1653
X-HE-Tag: drop63_31fc2bdaa1653
X-Filterd-Recvd-Size: 3947
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:29:03 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 076FDB8F2;
	Fri,  6 Sep 2019 11:29:02 +0000 (UTC)
Date: Fri, 6 Sep 2019 13:29:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Thomas Lindroth <thomas.lindroth@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-mm@kvack.org
Subject: Re: [BUG] kmemcg limit defeats __GFP_NOFAIL allocation
Message-ID: <20190906112901.GF14491@dhcp22.suse.cz>
References: <666dbcde-1b8a-9e2d-7d1f-48a117c78ae1@I-love.SAKURA.ne.jp>
 <ccf79dd9-b2e5-0d78-f520-164d198f9ca4@gmail.com>
 <4d0eda9a-319d-1a7d-1eed-71da90902367@i-love.sakura.ne.jp>
 <20190904112500.GO3838@dhcp22.suse.cz>
 <0056063b-46ff-0ebd-ff0d-c96a1f9ae6b1@i-love.sakura.ne.jp>
 <20190904142902.GZ3838@dhcp22.suse.cz>
 <405ce28b-c0b4-780c-c883-42d741ec60e0@i-love.sakura.ne.jp>
 <16fdbf78-3cf4-81cf-2a73-d38cb66afc17@gmail.com>
 <20190906072711.GD14491@dhcp22.suse.cz>
 <940ea5a4-b580-34f8-2e5f-0bd2534b7426@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <940ea5a4-b580-34f8-2e5f-0bd2534b7426@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 06-09-19 13:54:30, Andrey Ryabinin wrote:
> 
> 
> On 9/6/19 10:27 AM, Michal Hocko wrote:
> > On Fri 06-09-19 01:11:53, Thomas Lindroth wrote:
> >> On 9/4/19 6:39 PM, Tetsuo Handa wrote:
> >>> On 2019/09/04 23:29, Michal Hocko wrote:
> >>>> Ohh, right. We are trying to uncharge something that hasn't been charged
> >>>> because page_counter_try_charge has failed. So the fix needs to be more
> >>>> involved. Sorry, I should have realized that.
> >>>
> >>> OK. Survived the test. Thomas, please try.
> >>>
> >>>> ---
> >>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>>> index 9ec5e12486a7..e18108b2b786 100644
> >>>> --- a/mm/memcontrol.c
> >>>> +++ b/mm/memcontrol.c
> >>>> @@ -2821,6 +2821,16 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
> >>>>   	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
> >>>>   	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
> >>>> +
> >>>> +		/*
> >>>> +		 * Enforce __GFP_NOFAIL allocation because callers are not
> >>>> +		 * prepared to see failures and likely do not have any failure
> >>>> +		 * handling code.
> >>>> +		 */
> >>>> +		if (gfp & __GFP_NOFAIL) {
> >>>> +			page_counter_charge(&memcg->kmem, nr_pages);
> >>>> +			return 0;
> >>>> +		}
> >>>>   		cancel_charge(memcg, nr_pages);
> >>>>   		return -ENOMEM;
> >>>>   	}
> >>>>
> >>
> >> I tried the patch with 5.2.11 and wasn't able to trigger any null pointer
> >> deref crashes with it. Testing is tricky because the OOM killer will still
> >> run and eventually kill bash and whatever runs in the cgroup.
> > 
> > Yeah, this is unfortunate but also unfixable I am afraid. 
> 
> I think there are two possible ways to fix this. If we decide to keep kmem.limit_in_bytes broken,
> than we can just always bypass limit. Also we could add something like pr_warn_once("kmem limit doesn't work");
> when user changes kmem.limit_in_bytes 
> 
> 
> Or we can fix kmem.limit_in_bytes like this:

I would rather state the brokenness in the documentation. I do not want
to make the more complex. I have only glanced through your patch but
sheer size is really discouraging. Besides that the issue is really not
fixable because kmem charges are simply never going to be guaranteed to
be reclaimable and we simply cannot involve the memcg OOM killer to
resolve the problem. Having a separate counter was just a bad design
choice :/
-- 
Michal Hocko
SUSE Labs

