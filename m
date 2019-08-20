Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CF2EC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:34:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6BC9239BA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:34:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6BC9239BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 670A96B0007; Tue, 20 Aug 2019 04:34:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 621B86B0008; Tue, 20 Aug 2019 04:34:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 537F56B000A; Tue, 20 Aug 2019 04:34:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0215.hostedemail.com [216.40.44.215])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8366B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:34:16 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D786D8248AB3
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:34:15 +0000 (UTC)
X-FDA: 75842144070.05.horn64_7ef5f8ee3213
X-HE-Tag: horn64_7ef5f8ee3213
X-Filterd-Recvd-Size: 5657
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:34:14 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1CFA1ABBE;
	Tue, 20 Aug 2019 08:34:13 +0000 (UTC)
Date: Tue, 20 Aug 2019 10:34:12 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Yafang Shao <shaoyafang@didiglobal.com>,
	Roman Gushchin <guro@fb.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Randy Dunlap <rdunlap@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
Message-ID: <20190820083412.GK3111@dhcp22.suse.cz>
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190819211200.GA24956@tower.dhcp.thefacebook.com>
 <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
 <20190820064018.GE3111@dhcp22.suse.cz>
 <CALOAHbA_ouCeX2HacHHpNwTY59+3tc9rOHFsz7ZgCkjXF-U72A@mail.gmail.com>
 <20190820072703.GF3111@dhcp22.suse.cz>
 <CALOAHbC+ByFV6tPOnkmCM9FjxP3wWnQNCWUDO6e6RaeS=Mx8_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbC+ByFV6tPOnkmCM9FjxP3wWnQNCWUDO6e6RaeS=Mx8_Q@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 20-08-19 15:49:20, Yafang Shao wrote:
> On Tue, Aug 20, 2019 at 3:27 PM Michal Hocko <mhocko@suse.com> wrote:
> >
> > On Tue 20-08-19 15:15:54, Yafang Shao wrote:
> > > On Tue, Aug 20, 2019 at 2:40 PM Michal Hocko <mhocko@suse.com> wrote:
> > > >
> > > > On Tue 20-08-19 09:16:01, Yafang Shao wrote:
> > > > > On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
> > > > > >
> > > > > > On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > > > > > > In the current memory.min design, the system is going to do OOM instead
> > > > > > > of reclaiming the reclaimable pages protected by memory.min if the
> > > > > > > system is lack of free memory. While under this condition, the OOM
> > > > > > > killer may kill the processes in the memcg protected by memory.min.
> > > > > > > This behavior is very weird.
> > > > > > > In order to make it more reasonable, I make some changes in the OOM
> > > > > > > killer. In this patch, the OOM killer will do two-round scan. It will
> > > > > > > skip the processes under memcg protection at the first scan, and if it
> > > > > > > can't kill any processes it will rescan all the processes.
> > > > > > >
> > > > > > > Regarding the overhead this change may takes, I don't think it will be a
> > > > > > > problem because this only happens under system  memory pressure and
> > > > > > > the OOM killer can't find any proper victims which are not under memcg
> > > > > > > protection.
> > > > > >
> > > > > > Hi Yafang!
> > > > > >
> > > > > > The idea makes sense at the first glance, but actually I'm worried
> > > > > > about mixing per-memcg and per-process characteristics.
> > > > > > Actually, it raises many questions:
> > > > > > 1) if we do respect memory.min, why not memory.low too?
> > > > >
> > > > > memroy.low is different with memory.min, as the OOM killer will not be
> > > > > invoked when it is reached.
> > > >
> > > > Responded in other email thread (please do not post two versions of the
> > > > patch on the same day because it makes conversation too scattered and
> > > > confusing).
> > > >
> > > (This is an issue about time zone :-) )
> >
> > Normally we wait few days until feedback on the particular patch is
> > settled before a new version is posted.
> >
> > > > Think of min limit protection as some sort of a more inteligent mlock.
> > >
> > > Per my perspective, it is a less inteligent mlock, because what it
> > > protected may be a garbage memory.
> > > As I said before, what it protected is the memroy usage, rather than a
> > > specified file memory or anon memory or somethin else.
> > >
> > > The advantage of it is easy to use.
> > >
> > > > It protects from the regular memory reclaim and it can lead to the OOM
> > > > situation (be it global or memcg) but by no means it doesn't prevent
> > > > from the system to kill the workload if there is a need. Those two
> > > > decisions are simply orthogonal IMHO. The later is a an emergency action
> > > > while the former is to help guanratee a runtime behavior of the workload.
> > > >
> > >
> > > If it can handle OOM memory reclaim, it will be more inteligent.
> >
> > Can we get back to an actual usecase please?
> >
> 
> No real usecase.
> What we concerned is if it can lead to more OOMs but can't protect
> itself in OOM then this behavior seems a little wierd.

This is a natural side effect of protecting memory from the reclaim.
Read mlock kind of protection. Weird? I dunno. Unexpected, no!

> Setting oom_score_adj is another choice,  but there's no memcg-level
> oom_score_adj.
> memory.min is memcg-level, while oom_score_adj is process-level, that
> is wierd as well.

OOM, is per process operation. Sure we have that group kill option but
then still the selection is per-process.

Without any clear usecase in sight I do not think it makes sense to
pursue this further.

Thanks!
-- 
Michal Hocko
SUSE Labs

