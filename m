Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC61CC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:28:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B855F2084D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:28:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B855F2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4615B6B0007; Mon,  9 Sep 2019 08:28:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4121E6B0008; Mon,  9 Sep 2019 08:28:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34EDB6B000A; Mon,  9 Sep 2019 08:28:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id 1877A6B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:28:55 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B38E8909D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:28:54 +0000 (UTC)
X-FDA: 75915311388.28.fruit58_138e7748b0b07
X-HE-Tag: fruit58_138e7748b0b07
X-Filterd-Recvd-Size: 2868
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:28:54 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 35CC2B07D;
	Mon,  9 Sep 2019 12:28:53 +0000 (UTC)
Date: Mon, 9 Sep 2019 14:28:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: lot of MemAvailable but falling cache and raising PSI
Message-ID: <20190909122852.GM27159@dhcp22.suse.cz>
References: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
 <20190905114022.GH3838@dhcp22.suse.cz>
 <7a3d23f2-b5fe-b4c0-41cd-e79070637bd9@profihost.ag>
 <e866c481-04f2-fdb4-4d99-e7be2414591e@profihost.ag>
 <20190909082732.GC27159@dhcp22.suse.cz>
 <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
 <20190909110136.GG27159@dhcp22.suse.cz>
 <20190909120811.GL27159@dhcp22.suse.cz>
 <88ff0310-b9ab-36b6-d8ab-b6edd484d973@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <88ff0310-b9ab-36b6-d8ab-b6edd484d973@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 09-09-19 14:10:02, Stefan Priebe - Profihost AG wrote:
> 
> Am 09.09.19 um 14:08 schrieb Michal Hocko:
> > On Mon 09-09-19 13:01:36, Michal Hocko wrote:
> >> and that matches moments when we reclaimed memory. There seems to be a
> >> steady THP allocations flow so maybe this is a source of the direct
> >> reclaim?
> > 
> > I was thinking about this some more and THP being a source of reclaim
> > sounds quite unlikely. At least in a default configuration because we
> > shouldn't do anything expensinve in the #PF path. But there might be a
> > difference source of high order (!costly) allocations. Could you check
> > how many allocation requests like that you have on your system?
> > 
> > mount -t debugfs none /debug
> > echo "order > 0" > /debug/tracing/events/kmem/mm_page_alloc/filter
> > echo 1 > /debug/tracing/events/kmem/mm_page_alloc/enable
> > cat /debug/tracing/trace_pipe > $file

echo 1 > /debug/tracing/events/vmscan/mm_vmscan_direct_reclaim_begin/enable
echo 1 > /debug/tracing/events/vmscan/mm_vmscan_direct_reclaim_end/enable
 
might tell us something as well but it might turn out that it just still
doesn't give us the full picture and we might need
echo stacktrace > /debug/tracing/trace_options

It will generate much more output though.

> Just now or when PSI raises?

When the excessive reclaim is happening ideally.

-- 
Michal Hocko
SUSE Labs

