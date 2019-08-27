Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5659CC3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 11:50:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24BAA217F5
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 11:50:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24BAA217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B93BD6B0007; Tue, 27 Aug 2019 07:50:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1BF86B0008; Tue, 27 Aug 2019 07:50:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E3C76B000A; Tue, 27 Aug 2019 07:50:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9096B0007
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 07:50:18 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D78DD824CA3F
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:50:17 +0000 (UTC)
X-FDA: 75868039674.24.toys07_59dcba62bd717
X-HE-Tag: toys07_59dcba62bd717
X-Filterd-Recvd-Size: 2304
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 11:50:17 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A9FC3B01E;
	Tue, 27 Aug 2019 11:50:15 +0000 (UTC)
Date: Tue, 27 Aug 2019 13:50:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	Adric Blake <promarbler14@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Subject: Re: WARNINGs in set_task_reclaim_state with memory cgroup and full
 memory usage
Message-ID: <20190827115014.GZ7538@dhcp22.suse.cz>
References: <CAE1jjeePxYPvw1mw2B3v803xHVR_BNnz0hQUY_JDMN8ny29M6w@mail.gmail.com>
 <b9cd7603-2441-d351-156a-57d6c13b2c79@linux.alibaba.com>
 <20190826105521.GF7538@dhcp22.suse.cz>
 <20190827104313.GW7538@dhcp22.suse.cz>
 <CALOAHbBMWyPBw+Ciup4+YupbLrxcTW76w+Mfc-mGEm9kcWb8YQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBMWyPBw+Ciup4+YupbLrxcTW76w+Mfc-mGEm9kcWb8YQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 19:43:49, Yafang Shao wrote:
> On Tue, Aug 27, 2019 at 6:43 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > If there are no objection to the patch I will post it as a standalong
> > one.
> 
> I have no objection to your patch. It could fix the issue.
> 
> I still think that it is not proper to use a new scan_control here as
> it breaks the global reclaim context.
>
> This context switch from global reclaim to memcg reclaim is very
> subtle change to the subsequent processing, that may cause some
> unexpected behavior.

Why would it break it? Could you be more specific please?

> Anyway, we can send this patch as a standalong one.
> Feel free to add:
> 
> Acked-by: Yafang Shao <laoar.shao@gmail.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

