Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFC6CC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:27:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B67FD22CF4
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 07:27:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B67FD22CF4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 013276B0007; Tue, 20 Aug 2019 03:27:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F06396B0008; Tue, 20 Aug 2019 03:27:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1B996B000A; Tue, 20 Aug 2019 03:27:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0100.hostedemail.com [216.40.44.100])
	by kanga.kvack.org (Postfix) with ESMTP id BFAC66B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:27:07 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7EEFF99BF
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:27:06 +0000 (UTC)
X-FDA: 75841974852.28.waste18_3c861b87fa0c
X-HE-Tag: waste18_3c861b87fa0c
X-Filterd-Recvd-Size: 5137
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:27:05 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0EC46AC26;
	Tue, 20 Aug 2019 07:27:04 +0000 (UTC)
Date: Tue, 20 Aug 2019 09:27:03 +0200
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
Message-ID: <20190820072703.GF3111@dhcp22.suse.cz>
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190819211200.GA24956@tower.dhcp.thefacebook.com>
 <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
 <20190820064018.GE3111@dhcp22.suse.cz>
 <CALOAHbA_ouCeX2HacHHpNwTY59+3tc9rOHFsz7ZgCkjXF-U72A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbA_ouCeX2HacHHpNwTY59+3tc9rOHFsz7ZgCkjXF-U72A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 20-08-19 15:15:54, Yafang Shao wrote:
> On Tue, Aug 20, 2019 at 2:40 PM Michal Hocko <mhocko@suse.com> wrote:
> >
> > On Tue 20-08-19 09:16:01, Yafang Shao wrote:
> > > On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
> > > >
> > > > On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > > > > In the current memory.min design, the system is going to do OOM instead
> > > > > of reclaiming the reclaimable pages protected by memory.min if the
> > > > > system is lack of free memory. While under this condition, the OOM
> > > > > killer may kill the processes in the memcg protected by memory.min.
> > > > > This behavior is very weird.
> > > > > In order to make it more reasonable, I make some changes in the OOM
> > > > > killer. In this patch, the OOM killer will do two-round scan. It will
> > > > > skip the processes under memcg protection at the first scan, and if it
> > > > > can't kill any processes it will rescan all the processes.
> > > > >
> > > > > Regarding the overhead this change may takes, I don't think it will be a
> > > > > problem because this only happens under system  memory pressure and
> > > > > the OOM killer can't find any proper victims which are not under memcg
> > > > > protection.
> > > >
> > > > Hi Yafang!
> > > >
> > > > The idea makes sense at the first glance, but actually I'm worried
> > > > about mixing per-memcg and per-process characteristics.
> > > > Actually, it raises many questions:
> > > > 1) if we do respect memory.min, why not memory.low too?
> > >
> > > memroy.low is different with memory.min, as the OOM killer will not be
> > > invoked when it is reached.
> >
> > Responded in other email thread (please do not post two versions of the
> > patch on the same day because it makes conversation too scattered and
> > confusing).
> >
> (This is an issue about time zone :-) )

Normally we wait few days until feedback on the particular patch is
settled before a new version is posted.

> > Think of min limit protection as some sort of a more inteligent mlock.
> 
> Per my perspective, it is a less inteligent mlock, because what it
> protected may be a garbage memory.
> As I said before, what it protected is the memroy usage, rather than a
> specified file memory or anon memory or somethin else.
> 
> The advantage of it is easy to use.
> 
> > It protects from the regular memory reclaim and it can lead to the OOM
> > situation (be it global or memcg) but by no means it doesn't prevent
> > from the system to kill the workload if there is a need. Those two
> > decisions are simply orthogonal IMHO. The later is a an emergency action
> > while the former is to help guanratee a runtime behavior of the workload.
> >
> 
> If it can handle OOM memory reclaim, it will be more inteligent.

Can we get back to an actual usecase please?
 
> > To be completely fair, the OOM killer is a sort of the memory reclaim as
> > well so strictly speaking both mlock and memcg min protection could be
> > considered but from any practical aspect I can think of I simply do not
> > see a strong usecase that would justify a more complex oom behavior.
> > People will be simply confused that the selection is less deterministic
> > and therefore more confusing.
> > --
> 
> So what about ajusting the oom_socore_adj automatically when we set
> memory.min or mlock ?

oom_score_adj is a _user_ tuning. The kernel has no business in
auto-tuning it. It should just consume the value.

-- 
Michal Hocko
SUSE Labs

