Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 544C7C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:08:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B59A2067B
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:08:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B59A2067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD9A06B0005; Mon,  9 Sep 2019 08:08:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A89CA6B0006; Mon,  9 Sep 2019 08:08:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99F0A6B0007; Mon,  9 Sep 2019 08:08:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0075.hostedemail.com [216.40.44.75])
	by kanga.kvack.org (Postfix) with ESMTP id 7330D6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:08:14 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 282408126
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:08:14 +0000 (UTC)
X-FDA: 75915259308.13.bikes54_821057026db48
X-HE-Tag: bikes54_821057026db48
X-Filterd-Recvd-Size: 2126
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:08:13 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 556D1B677;
	Mon,  9 Sep 2019 12:08:12 +0000 (UTC)
Date: Mon, 9 Sep 2019 14:08:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: lot of MemAvailable but falling cache and raising PSI
Message-ID: <20190909120811.GL27159@dhcp22.suse.cz>
References: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
 <20190905114022.GH3838@dhcp22.suse.cz>
 <7a3d23f2-b5fe-b4c0-41cd-e79070637bd9@profihost.ag>
 <e866c481-04f2-fdb4-4d99-e7be2414591e@profihost.ag>
 <20190909082732.GC27159@dhcp22.suse.cz>
 <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
 <20190909110136.GG27159@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190909110136.GG27159@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 09-09-19 13:01:36, Michal Hocko wrote:
> and that matches moments when we reclaimed memory. There seems to be a
> steady THP allocations flow so maybe this is a source of the direct
> reclaim?

I was thinking about this some more and THP being a source of reclaim
sounds quite unlikely. At least in a default configuration because we
shouldn't do anything expensinve in the #PF path. But there might be a
difference source of high order (!costly) allocations. Could you check
how many allocation requests like that you have on your system?

mount -t debugfs none /debug
echo "order > 0" > /debug/tracing/events/kmem/mm_page_alloc/filter
echo 1 > /debug/tracing/events/kmem/mm_page_alloc/enable
cat /debug/tracing/trace_pipe > $file
-- 
Michal Hocko
SUSE Labs

