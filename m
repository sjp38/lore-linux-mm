Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11F5EC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 06:31:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3E78214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 06:31:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3E78214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D01D6B0007; Tue, 20 Aug 2019 02:31:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 480E26B0008; Tue, 20 Aug 2019 02:31:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 395B06B000A; Tue, 20 Aug 2019 02:31:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0140.hostedemail.com [216.40.44.140])
	by kanga.kvack.org (Postfix) with ESMTP id 125906B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:31:24 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id A39348248ABC
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:31:23 +0000 (UTC)
X-FDA: 75841834446.05.shock17_637107e225b52
X-HE-Tag: shock17_637107e225b52
X-Filterd-Recvd-Size: 3536
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:31:23 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9795BADEC;
	Tue, 20 Aug 2019 06:31:21 +0000 (UTC)
Date: Tue, 20 Aug 2019 08:31:20 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, Roman Gushchin <guro@fb.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] mm, memcg: skip killing processes under memcg protection
 at first scan
Message-ID: <20190820063120.GD3111@dhcp22.suse.cz>
References: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com>
 <20190819073128.GB3111@dhcp22.suse.cz>
 <CALOAHbAo2MLkavFZz_5f5hvXE8BzYW8R-yjw5acnwT315TxoMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAo2MLkavFZz_5f5hvXE8BzYW8R-yjw5acnwT315TxoMQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[hmm the email got stuck on my send queue - sending again]

On Mon 19-08-19 16:15:08, Yafang Shao wrote:
> On Mon, Aug 19, 2019 at 3:31 PM Michal Hocko <mhocko@suse.com> wrote:
> >
> > On Sun 18-08-19 00:24:54, Yafang Shao wrote:
> > > In the current memory.min design, the system is going to do OOM instead
> > > of reclaiming the reclaimable pages protected by memory.min if the
> > > system is lack of free memory. While under this condition, the OOM
> > > killer may kill the processes in the memcg protected by memory.min.
> >
> > Could you be more specific about the configuration that leads to this
> > situation?
> 
> When I did memory pressure test to verify memory.min I found that issue.
> This issue can be produced as bellow,
>     memcg setting,
>         memory.max: 1G
>         memory.min: 512M
>         some processes are running is this memcg, with both serveral
> hundreds MB  file mapping and serveral hundreds MB anon mapping.
>     system setting,
>          swap: off.
>          some memory pressure test are running on the system.
> 
> When the memory usage of this memcg is bellow the memory.min, the
> global reclaimers stop reclaiming pages in this memcg, and when
> there's no available memory, the OOM killer will be invoked.
> Unfortunately the OOM killer can chose the process running in the
> protected memcg.

Well, the memcg protection was designed to prevent from regular
memory reclaim.  It was not aimed at acting as a group wide oom
protection. The global oom killer (but memcg as well) simply cares only
about oom_score_adj when selecting a victim.

Adding yet another oom protection is likely to complicate the oom
selection logic and make it more surprising. E.g. why should workload
fitting inside the min limit be so special? Do you have any real world
example?
 
> In order to produce it easy, you can incease the memroy.min and set
> -1000 to the oom_socre_adj of the processes outside of the protected
> memcg.

This sounds like a very dubious configuration to me. There is no other
option than chosing from the protected group.

> Is this setting proper ?
> 
> Thanks
> Yafang

-- 
Michal Hocko
SUSE Labs

