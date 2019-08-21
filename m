Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CED97C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 08:35:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90B5322DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 08:35:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90B5322DA7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1EB86B02A8; Wed, 21 Aug 2019 04:35:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCF926B02AB; Wed, 21 Aug 2019 04:35:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE4886B02AC; Wed, 21 Aug 2019 04:35:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0126.hostedemail.com [216.40.44.126])
	by kanga.kvack.org (Postfix) with ESMTP id ACCB96B02A8
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 04:35:01 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 516B96C09
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:35:01 +0000 (UTC)
X-FDA: 75845774802.25.bead19_48cf1f889bc32
X-HE-Tag: bead19_48cf1f889bc32
X-Filterd-Recvd-Size: 4434
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 08:35:00 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 28397ABD2;
	Wed, 21 Aug 2019 08:34:58 +0000 (UTC)
Date: Wed, 21 Aug 2019 10:34:57 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Roman Gushchin <guro@fb.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
Message-ID: <20190821083457.GC3111@dhcp22.suse.cz>
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190820213905.GB12897@tower.DHCP.thefacebook.com>
 <CALOAHbBSUPkw-XZBGooGZ9o7HcD5fbavG0bPDFCnYAFqqX8MGA@mail.gmail.com>
 <20190821064452.GV3111@dhcp22.suse.cz>
 <CALOAHbAt6nm+qSOLGTeo5s5XjQFcasQw9HJfKEEC24xVOoVxwg@mail.gmail.com>
 <20190821080516.GZ3111@dhcp22.suse.cz>
 <CALOAHbBJSi6R_mgh=hoPTcRXsHBb9g-_0tjEz5tWeC22cnaWRw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBJSi6R_mgh=hoPTcRXsHBb9g-_0tjEz5tWeC22cnaWRw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 21-08-19 16:15:54, Yafang Shao wrote:
> On Wed, Aug 21, 2019 at 4:05 PM Michal Hocko <mhocko@suse.com> wrote:
> >
> > On Wed 21-08-19 15:26:56, Yafang Shao wrote:
> > > On Wed, Aug 21, 2019 at 2:44 PM Michal Hocko <mhocko@suse.com> wrote:
> > > >
> > > > On Wed 21-08-19 09:00:39, Yafang Shao wrote:
> > > > [...]
> > > > > More possible OOMs is also a strong side effect (and it prevent us
> > > > > from using it).
> > > >
> > > > So why don't you use low limit if the guarantee side of min limit is too
> > > > strong for you?
> > >
> > > Well, I don't know what the best-practice of memory.min is.
> >
> > It is really a workload reclaim protection. Say you have a memory
> > consumer which performance characteristics would be noticeably disrupted
> > by any memory reclaim which then would lead to SLA disruption. This is a
> > strong requirement/QoS feature and as such comes with its demand on
> > configuration.
> >
> > > In our plan, we want to use it to protect the top priority containers
> > > (e.g. set the memory.min same with memory limit), which may latency
> > > sensive. Using memory.min may sometimes decrease the refault.
> > > If we set it too low, it may useless, becasue what memory.min is
> > > protecting is not specified. And if there're some busrt anon memory
> > > allocate in this memcg, the memory.min may can't protect any file
> > > memory.
> >
> > I am still not seeing why you are considering guarantee (memory.min)
> > rather than best practice (memory.low) here?
> 
> Let me show some examples for you.
> Suppose we have three containers with different priorities, which are
> high priority, medium priority and low priority.
> Then we set memory.low to these containers as bellow,
> high prioirty: memory.low same with memory.max
> medium priroity: memory.low is 50% of memory.max
> low priority: memory.low is 0
> 
> When all relcaimable pages withouth protection are reclaimed, the
> reclaimer begins to reclaim the protected pages, but unforuantely it
> desn't know which pages are belonging to high priority container and
> which pages are belonging to medium priority container. So the
> relcaimer may reclaim the high priority contianer first, and without
> reclaiming the medium priority container at all.

Hmm, it is hard to comment on this configuration without knowing what is
the overall consumption of all the three. In any case reclaiming all of
the reclaimable memory means that you have actually reclaimed full of
the low and half of the medium container to even start hitting on high
priority one. When there are only low priority protected containers then
they will get reclaimed proportionally to their size.
-- 
Michal Hocko
SUSE Labs

