Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81B8AC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 06:40:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B8422082F
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 06:40:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B8422082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA2E76B0007; Tue, 20 Aug 2019 02:40:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D535D6B0008; Tue, 20 Aug 2019 02:40:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C68456B000A; Tue, 20 Aug 2019 02:40:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6DD6B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:40:21 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 516E4180AD803
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:40:21 +0000 (UTC)
X-FDA: 75841857042.04.book17_2022751c3921b
X-HE-Tag: book17_2022751c3921b
X-Filterd-Recvd-Size: 3922
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:40:20 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E1BDEADDC;
	Tue, 20 Aug 2019 06:40:18 +0000 (UTC)
Date: Tue, 20 Aug 2019 08:40:18 +0200
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
Message-ID: <20190820064018.GE3111@dhcp22.suse.cz>
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190819211200.GA24956@tower.dhcp.thefacebook.com>
 <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 20-08-19 09:16:01, Yafang Shao wrote:
> On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
> >
> > On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > > In the current memory.min design, the system is going to do OOM instead
> > > of reclaiming the reclaimable pages protected by memory.min if the
> > > system is lack of free memory. While under this condition, the OOM
> > > killer may kill the processes in the memcg protected by memory.min.
> > > This behavior is very weird.
> > > In order to make it more reasonable, I make some changes in the OOM
> > > killer. In this patch, the OOM killer will do two-round scan. It will
> > > skip the processes under memcg protection at the first scan, and if it
> > > can't kill any processes it will rescan all the processes.
> > >
> > > Regarding the overhead this change may takes, I don't think it will be a
> > > problem because this only happens under system  memory pressure and
> > > the OOM killer can't find any proper victims which are not under memcg
> > > protection.
> >
> > Hi Yafang!
> >
> > The idea makes sense at the first glance, but actually I'm worried
> > about mixing per-memcg and per-process characteristics.
> > Actually, it raises many questions:
> > 1) if we do respect memory.min, why not memory.low too?
> 
> memroy.low is different with memory.min, as the OOM killer will not be
> invoked when it is reached.

Responded in other email thread (please do not post two versions of the
patch on the same day because it makes conversation too scattered and
confusing).

Think of min limit protection as some sort of a more inteligent mlock.
It protects from the regular memory reclaim and it can lead to the OOM
situation (be it global or memcg) but by no means it doesn't prevent
from the system to kill the workload if there is a need. Those two
decisions are simply orthogonal IMHO. The later is a an emergency action
while the former is to help guanratee a runtime behavior of the workload.

To be completely fair, the OOM killer is a sort of the memory reclaim as
well so strictly speaking both mlock and memcg min protection could be
considered but from any practical aspect I can think of I simply do not
see a strong usecase that would justify a more complex oom behavior.
People will be simply confused that the selection is less deterministic
and therefore more confusing.
-- 
Michal Hocko
SUSE Labs

