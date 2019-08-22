Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC4D0C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:59:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FDFB233A0
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:59:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FDFB233A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF8D96B0304; Thu, 22 Aug 2019 06:59:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E840A6B0306; Thu, 22 Aug 2019 06:59:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D71076B0307; Thu, 22 Aug 2019 06:59:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id AEE2D6B0304
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:59:21 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 53ACA87C7
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:59:21 +0000 (UTC)
X-FDA: 75849767322.22.cart54_51a40641b312e
X-HE-Tag: cart54_51a40641b312e
X-Filterd-Recvd-Size: 3924
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:59:20 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8405FAC50;
	Thu, 22 Aug 2019 10:59:19 +0000 (UTC)
Date: Thu, 22 Aug 2019 12:59:18 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm, memcg: introduce per memcg oom_score_adj
Message-ID: <20190822105918.GH12785@dhcp22.suse.cz>
References: <1566464189-1631-1-git-send-email-laoar.shao@gmail.com>
 <20190822091902.GG12785@dhcp22.suse.cz>
 <CALOAHbAOH+Y+sN3ynAiBDm=JWrm4XpyUm8s3r9G=Oz4b0iNvCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAOH+Y+sN3ynAiBDm=JWrm4XpyUm8s3r9G=Oz4b0iNvCA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 22-08-19 17:34:54, Yafang Shao wrote:
> On Thu, Aug 22, 2019 at 5:19 PM Michal Hocko <mhocko@suse.com> wrote:
> >
> > On Thu 22-08-19 04:56:29, Yafang Shao wrote:
> > > - Why we need a per memcg oom_score_adj setting ?
> > > This is easy to deploy and very convenient for container.
> > > When we use container, we always treat memcg as a whole, if we have a per
> > > memcg oom_score_adj setting we don't need to set it process by process.
> >
> > Why cannot an initial process in the cgroup set the oom_score_adj and
> > other processes just inherit it from there? This sounds trivial to do
> > with a startup script.
> >
> 
> That is what we used to do before.
> But it can't apply to the running containers.
> 
> 
> > > It will make the user exhausted to set it to all processes in a memcg.
> >
> > Then let's have scripts to set it as they are less prone to exhaustion
> > ;)
> 
> That is not easy to deploy it to the production environment.

What is hard about a simple loop over tasklist exported by cgroup and
apply a value to oom_score_adj?

[...]

> > Besides that. What is the hierarchical semantic? Say you have hierarchy
> >         A (oom_score_adj = 1000)
> >          \
> >           B (oom_score_adj = 500)
> >            \
> >             C (oom_score_adj = -1000)
> >
> > put the above summing up aside for now and just focus on the memcg
> > adjusting?
> 
> I think that there's no conflict between children's oom_score_adj,
> that is different with memory.max.
> So it is not neccessary to consider the parent's oom_sore_adj.

Each exported cgroup tuning _has_ to be hierarchical so that an admin
can override children setting in order to safely delegate the
configuration.

Last but not least, oom_score_adj has proven to be a terrible interface
that is essentially close to unusable to anything outside of extreme
values (-1000 and very arguably 1000). Making it cgroup aware without
changing oom victim selection to consider cgroup as a whole will also be
a pain so I am afraid that this is a dead end path.

We can discuss cgroup aware oom victim selection for sure and there are
certainly reasonable usecases to back that functionality. Please refer
to discussion from 2017/2018 (dubbed as "cgroup-aware OOM killer"). But
be warned this is a tricky area and there was a fundamental disagreement
on how things should be classified without a clear way to reach
consensus. What we have right now is the only agreement we could reach.
It is likely possible that the only more clever cgroup aware oom
selection has to be implemented in the userspace with an understanding
of the specific workload.
-- 
Michal Hocko
SUSE Labs

