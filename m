Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0638C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:40:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F358206DF
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:40:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F358206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DDA26B0007; Tue, 20 Aug 2019 06:40:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 297EC6B0008; Tue, 20 Aug 2019 06:40:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17DAF6B000A; Tue, 20 Aug 2019 06:40:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id EE3CD6B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:40:27 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9B787441C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:40:27 +0000 (UTC)
X-FDA: 75842462094.24.ship78_5b4662760de5d
X-HE-Tag: ship78_5b4662760de5d
X-Filterd-Recvd-Size: 3314
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:40:27 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 78D69AED0;
	Tue, 20 Aug 2019 10:40:24 +0000 (UTC)
Date: Tue, 20 Aug 2019 12:40:22 +0200
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
Message-ID: <20190820104022.GN3111@dhcp22.suse.cz>
References: <20190819211200.GA24956@tower.dhcp.thefacebook.com>
 <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
 <20190820064018.GE3111@dhcp22.suse.cz>
 <CALOAHbA_ouCeX2HacHHpNwTY59+3tc9rOHFsz7ZgCkjXF-U72A@mail.gmail.com>
 <20190820072703.GF3111@dhcp22.suse.cz>
 <CALOAHbC+ByFV6tPOnkmCM9FjxP3wWnQNCWUDO6e6RaeS=Mx8_Q@mail.gmail.com>
 <20190820083412.GK3111@dhcp22.suse.cz>
 <CALOAHbBfvnOtEVjoD7=GcSb4TF3eHTX7wXT-M9meZaj6b9QofA@mail.gmail.com>
 <20190820091735.GM3111@dhcp22.suse.cz>
 <CALOAHbB68w0miNE7FBASyMi=ou58AfsQTOkFY3fXgZi0w2aMrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbB68w0miNE7FBASyMi=ou58AfsQTOkFY3fXgZi0w2aMrQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 20-08-19 17:26:49, Yafang Shao wrote:
> On Tue, Aug 20, 2019 at 5:17 PM Michal Hocko <mhocko@suse.com> wrote:
[...]
> > > As there's a memory.oom.group option to select killing all processes
> > > in a memcg, why not introduce a memcg level memcg.oom.score_adj?
> >
> > Because the oom selection is process based as already mentioned. There
> > was a long discussion about memcg based oom victim selection last year
> > but no consensus has been achieved.
> >
> > > Then we can set different scores to different memcgs.
> > > Because we always deploy lots of containers on a single host, when OOM
> > > occurs it will better to prefer killing the low priority containers
> > > (with higher memcg.oom.score_adj) first.
> >
> > How would you define low priority container with score_adj?
> >
> 
> For example, Container-A is high priority and Container-B is low priority.
> When OOM killer happens we prefer to kill all processes in Container-B
> and prevent Container-A from being killed.
> So we set memroy.oom.score_adj  with -1000 to Container-A  and +1000
> to Container-B, both container with memory.oom.cgroup set.
> When we set memroy.oom.score_adj  to a container, all processes
> belonging to this container will be set this value to their own
> oom_score_adj.

I hope you can see that this on/off mechanism doesn't scale and thus it
is a dubious interface. Just think of mutlitple containers.

-- 
Michal Hocko
SUSE Labs

