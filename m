Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D351C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:55:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D070206C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 12:55:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D070206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09DE76B0008; Wed, 14 Aug 2019 08:55:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04EE06B000A; Wed, 14 Aug 2019 08:55:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECD546B000C; Wed, 14 Aug 2019 08:55:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0028.hostedemail.com [216.40.44.28])
	by kanga.kvack.org (Postfix) with ESMTP id CA4366B0008
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 08:55:57 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 765B53AA9
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:55:57 +0000 (UTC)
X-FDA: 75821030754.20.fifth72_33f8623917255
X-HE-Tag: fifth72_33f8623917255
X-Filterd-Recvd-Size: 3231
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:55:56 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 82919AC64;
	Wed, 14 Aug 2019 12:55:55 +0000 (UTC)
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
To: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, rientjes@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
 <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
 <20190809180238.GS18351@dhcp22.suse.cz>
 <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
 <fb1f4958-5147-2fab-531f-d234806c2f37@linux.alibaba.com>
 <20190812093430.GD5117@dhcp22.suse.cz>
 <297aefa2-ba64-cb91-d2c8-733054db01a3@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9d2e63c4-ebb6-1f14-b8fb-b39f2f67d916@suse.cz>
Date: Wed, 14 Aug 2019 14:55:54 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <297aefa2-ba64-cb91-d2c8-733054db01a3@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/12/19 7:00 PM, Yang Shi wrote:
>> I can see that memcg rss size was the primary problem David was looking
>> at. But MemAvailable will not help with that, right? Moreover is
> 
> Yes, but David actually would like to have memcg MemAvailable (the 
> accounter like the global one), which should be counted like the global 
> one and should account per memcg deferred split THP properly.
> 
>> accounting the full THP correct? What if subpages are still mapped?
> 
> "Deferred split" definitely doesn't mean they are free. When memory 
> pressure is hit, they would be split, then the unmapped normal pages 
> would be freed. So, when calculating MemAvailable, they are not 
> accounted 100%, but like "available += lazyfree - min(lazyfree / 2, 
> wmark_low)", just like how page cache is accounted.
> 
> We could get more accurate account, i.e. checking each sub page's 
> mapcount when accounting, but it may change before shrinker start 
> scanning. So, just use the ballpark estimation to trade off the 
> complexity for accurate accounting.

If we know the mapcounts in the moment the deferred split is initiated (I
suppose there has to be a iteration over all subpages already?), we could get
the exact number to adjust the counter with, and also store the number somewhere
(e.g. a unused field in first/second tail page, I think we already do that for
something). Then in the shrinker we just read that number to adjust the counter
back. Then we can ignore the subpage mapping changes before shrinking happens,
they shouldn't change the situation significantly, and importantly we we will be
safe from counter imbalance thanks to the stored number.

