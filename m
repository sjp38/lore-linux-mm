Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E509C3A5A6
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 11:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6864E22CE3
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 11:09:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6864E22CE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE9346B0006; Fri, 30 Aug 2019 07:09:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E99FD6B0008; Fri, 30 Aug 2019 07:09:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB1CA6B000A; Fri, 30 Aug 2019 07:09:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id B58CE6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 07:09:11 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 576641F373
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:09:11 +0000 (UTC)
X-FDA: 75878822502.27.slave59_330f0705e6047
X-HE-Tag: slave59_330f0705e6047
X-Filterd-Recvd-Size: 2512
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:09:10 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3307FAF11;
	Fri, 30 Aug 2019 11:09:09 +0000 (UTC)
Date: Fri, 30 Aug 2019 13:09:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Sangwoo <sangwoo2.park@lge.com>
Cc: hannes@cmpxchg.org, arunks@codeaurora.org, guro@fb.com,
	richard.weiyang@gmail.com, glider@google.com, jannh@google.com,
	dan.j.williams@intel.com, akpm@linux-foundation.org,
	alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com,
	gregkh@linuxfoundation.org, janne.huttunen@nokia.com,
	pasha.tatashin@soleen.com, vbabka@suse.cz, osalvador@suse.de,
	mgorman@techsingularity.net, khlebnikov@yandex-team.ru,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Add nr_free_highatomimic to fix incorrect watermatk
 routine
Message-ID: <20190830110907.GC28313@dhcp22.suse.cz>
References: <1567157153-22024-1-git-send-email-sangwoo2.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567157153-22024-1-git-send-email-sangwoo2.park@lge.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 30-08-19 18:25:53, Sangwoo wrote:
> The highatomic migrate block can be increased to 1% of Total memory.
> And, this is for only highorder ( > 0 order). So, this block size is
> excepted during check watermark if allocation type isn't alloc_harder.
> 
> It has problem. The usage of highatomic is already calculated at NR_FREE_PAGES.
> So, if we except total block size of highatomic, it's twice minus size of allocated
> highatomic.
> It's cause allocation fail although free pages enough.
> 
> We checked this by random test on my target(8GB RAM).
> 
> 	Binder:6218_2: page allocation failure: order:0, mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
> 	Binder:6218_2 cpuset=background mems_allowed=0

How come this order-0 sleepable allocation fails? The upstream kernel
doesn't fail those allocations unless the process context is killed by
the oom killer.

Also please note that atomic reserves are released when the memory
pressure is high and we cannot reclaim any other memory. Have a look at
unreserve_highatomic_pageblock called from should_reclaim_retry.
-- 
Michal Hocko
SUSE Labs

