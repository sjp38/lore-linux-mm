Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9F3FC3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 11:59:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A376523401
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 11:59:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A376523401
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BE276B0006; Wed,  4 Sep 2019 07:59:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36DA96B0007; Wed,  4 Sep 2019 07:59:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2858E6B0008; Wed,  4 Sep 2019 07:59:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id 094656B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:59:36 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A1CB0180AD804
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:59:35 +0000 (UTC)
X-FDA: 75897093510.26.crook82_369d34d9ee250
X-HE-Tag: crook82_369d34d9ee250
X-Filterd-Recvd-Size: 3669
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 11:59:35 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E3525AC31;
	Wed,  4 Sep 2019 11:59:33 +0000 (UTC)
Date: Wed, 4 Sep 2019 13:59:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Thomas Lindroth <thomas.lindroth@gmail.com>, linux-mm@kvack.org
Subject: Re: [BUG] kmemcg limit defeats __GFP_NOFAIL allocation
Message-ID: <20190904115933.GT3838@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <666dbcde-1b8a-9e2d-7d1f-48a117c78ae1@I-love.SAKURA.ne.jp>
 <ccf79dd9-b2e5-0d78-f520-164d198f9ca4@gmail.com>
 <4d0eda9a-319d-1a7d-1eed-71da90902367@i-love.sakura.ne.jp>
 <20190904112500.GO3838@dhcp22.suse.cz>
 <4d87d770-c110-224f-6c0c-d6fada90417d@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d87d770-c110-224f-6c0c-d6fada90417d@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 04-09-19 20:32:25, Tetsuo Handa wrote:
> On 2019/09/04 20:25, Michal Hocko wrote:
> > On Wed 04-09-19 18:36:06, Tetsuo Handa wrote:
> > [...]
> >> The first bug is that __memcg_kmem_charge_memcg() in mm/memcontrol.c is
> >> failing to return 0 when it is a __GFP_NOFAIL allocation request.
> >> We should ignore limits when it is a __GFP_NOFAIL allocation request.
> > 
> > OK, fixing that sounds like a reasonable thing to do.
> >  
> >> If we force __memcg_kmem_charge_memcg() to return 0, then
> >>
> >> ----------
> >>         struct page_counter *counter;
> >>         int ret;
> >>
> >> +       if (gfp & __GFP_NOFAIL)
> >> +               return 0;
> >> +
> >>         ret = try_charge(memcg, gfp, nr_pages);
> >>         if (ret)
> >>                 return ret;
> >> ----------
> > 
> > This should be more likely something like
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 9ec5e12486a7..05a4828edf9d 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2820,7 +2820,8 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
> >  		return ret;
> >  
> >  	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
> > -	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
> > +	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter) &&
> > +	    !(gfp_mask & __GFP_NOFAIL)) {
> >  		cancel_charge(memcg, nr_pages);
> >  		return -ENOMEM;
> >  	}
> 
> Is it guaranteed that try_charge(__GFP_NOFAIL) never fails?

it enforces charges.

> >> the second bug that alloc_slabmgmt() in mm/slab.c is returning NULL
> >> when it is a __GFP_NOFAIL allocation request will appear.
> >> I don't know how to handle this.
> > 
> > I am sorry, I do not follow, why would alloc_slabmgmt return NULL
> > with forcing gfp_nofail charges?
> > 
> 
> The reproducer is hitting
> 
> @@ -2300,18 +2302,21 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
>  	page->s_mem = addr + colour_off;
>  	page->active = 0;
>  
> -	if (OBJFREELIST_SLAB(cachep))
> +	if (OBJFREELIST_SLAB(cachep)) {
> +		BUG_ON(local_flags & __GFP_NOFAIL); // <= this condition

What does this bugon tries to say though. I am not an expert on slab bu
only OFF_SLAB(cachep) branch depends on an allocation. Others should
allocate object from the cache.
-- 
Michal Hocko
SUSE Labs

