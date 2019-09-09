Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFBABC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:10:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABDD421924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:10:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABDD421924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E4CC6B0005; Mon,  9 Sep 2019 08:10:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 495936B0007; Mon,  9 Sep 2019 08:10:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ABF26B0008; Mon,  9 Sep 2019 08:10:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA576B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:10:05 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C0209180AD801
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:10:04 +0000 (UTC)
X-FDA: 75915263928.24.page73_9abbbdbc80c
X-HE-Tag: page73_9abbbdbc80c
X-Filterd-Recvd-Size: 2609
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de [178.250.10.56])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:10:03 +0000 (UTC)
Received: (qmail 31500 invoked from network); 9 Sep 2019 14:10:02 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.182]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Mon, 09 Sep 2019 14:10:02 +0200
Subject: Re: lot of MemAvailable but falling cache and raising PSI
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
 cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
 Vlastimil Babka <vbabka@suse.cz>
References: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
 <20190905114022.GH3838@dhcp22.suse.cz>
 <7a3d23f2-b5fe-b4c0-41cd-e79070637bd9@profihost.ag>
 <e866c481-04f2-fdb4-4d99-e7be2414591e@profihost.ag>
 <20190909082732.GC27159@dhcp22.suse.cz>
 <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
 <20190909110136.GG27159@dhcp22.suse.cz>
 <20190909120811.GL27159@dhcp22.suse.cz>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <88ff0310-b9ab-36b6-d8ab-b6edd484d973@profihost.ag>
Date: Mon, 9 Sep 2019 14:10:02 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190909120811.GL27159@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Am 09.09.19 um 14:08 schrieb Michal Hocko:
> On Mon 09-09-19 13:01:36, Michal Hocko wrote:
>> and that matches moments when we reclaimed memory. There seems to be a
>> steady THP allocations flow so maybe this is a source of the direct
>> reclaim?
> 
> I was thinking about this some more and THP being a source of reclaim
> sounds quite unlikely. At least in a default configuration because we
> shouldn't do anything expensinve in the #PF path. But there might be a
> difference source of high order (!costly) allocations. Could you check
> how many allocation requests like that you have on your system?
> 
> mount -t debugfs none /debug
> echo "order > 0" > /debug/tracing/events/kmem/mm_page_alloc/filter
> echo 1 > /debug/tracing/events/kmem/mm_page_alloc/enable
> cat /debug/tracing/trace_pipe > $file

Just now or when PSI raises?

Greets,
Stefan

