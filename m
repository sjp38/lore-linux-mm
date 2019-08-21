Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D634DC3A589
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 01:21:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FCD222DD6
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 01:21:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FCD222DD6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21B7B6B0277; Tue, 20 Aug 2019 21:21:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CCAF6B0278; Tue, 20 Aug 2019 21:21:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E2E86B0279; Tue, 20 Aug 2019 21:21:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id E4E036B0277
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 21:21:24 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8BF01812D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:21:24 +0000 (UTC)
X-FDA: 75844682088.22.screw19_465d51ce6ba43
X-HE-Tag: screw19_465d51ce6ba43
X-Filterd-Recvd-Size: 2828
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com [115.124.30.42])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:21:23 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0Ta0SZIU_1566350478;
Received: from IT-FVFX43SYHV2H.local(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0Ta0SZIU_1566350478)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 21 Aug 2019 09:21:19 +0800
Subject: Re: [PATCH 00/14] per memcg lru_lock
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
 Shakeel Butt <shakeelb@google.com>, Yu Zhao <yuzhao@google.com>,
 Daniel Jordan <daniel.m.jordan@oracle.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <20190820104532.GP3111@dhcp22.suse.cz>
 <CALvZod7-dL90jwd2pywpaD8NfUByVU9Y809+RfvJABGdRASYUg@mail.gmail.com>
 <alpine.LSU.2.11.1908201038260.1286@eggly.anvils>
From: Alex Shi <alex.shi@linux.alibaba.com>
Message-ID: <319c7a6c-6f1a-64c5-4920-e8279eb1e80b@linux.alibaba.com>
Date: Wed, 21 Aug 2019 09:21:18 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1908201038260.1286@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> 
> Thanks for the Cc Michal.  As Shakeel says, Google prodkernel has been
> using our per-memcg lru locks for 7 years or so.  Yes, we did not come
> up with supporting performance data at the time of posting, nor since:
> I see Alex has done much better on that (though I haven't even glanced
> to see if +s are persuasive).
> 
> https://lkml.org/lkml/2012/2/20/434
> was how ours was back then; some parts of that went in, then attached
> lrulock417.tar is how it was the last time I rebased, to v4.17.
> 
> I'll set aside what I'm doing, and switch to rebasing ours to v5.3-rc
> and/or mmotm.  Then compare with what Alex has, to see if there's any
> good reason to prefer one to the other: if no good reason to prefer ours,
> I doubt we shall bother to repost, but just use it as basis for helping
> to review or improve Alex's.
> 

Thanks for you all! Very glad to see we are trying on same point. :)
Not only on per memcg lru_lock, there are much room on lru and page replacement
tunings. Anyway Hope to see your update and more review comments soon.

Thanks
Alex

