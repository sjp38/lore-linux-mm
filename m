Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89FE1C31E40
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 04:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59550208C2
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 04:53:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59550208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 262D26B0007; Thu, 15 Aug 2019 00:53:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EBE76B0008; Thu, 15 Aug 2019 00:53:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B3786B000A; Thu, 15 Aug 2019 00:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0142.hostedemail.com [216.40.44.142])
	by kanga.kvack.org (Postfix) with ESMTP id D7D9D6B0007
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:53:41 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 49243181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 04:53:41 +0000 (UTC)
X-FDA: 75823444242.19.magic77_776559f2cbf56
X-HE-Tag: magic77_776559f2cbf56
X-Filterd-Recvd-Size: 3204
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com [115.124.30.54])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 04:53:40 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R581e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TZWJOlV_1565844812;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TZWJOlV_1565844812)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 15 Aug 2019 12:53:36 +0800
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, rientjes@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Linux API <linux-api@vger.kernel.org>
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
 <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
 <20190809180238.GS18351@dhcp22.suse.cz>
 <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
 <564a0860-94f1-6301-5527-5c2272931d8b@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <96bd67c0-e53e-9802-a461-19ce47bba021@linux.alibaba.com>
Date: Wed, 14 Aug 2019 21:53:30 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <564a0860-94f1-6301-5527-5c2272931d8b@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/14/19 5:49 AM, Vlastimil Babka wrote:
> On 8/9/19 8:26 PM, Yang Shi wrote:
>> Here the new counter is introduced for patch 2/2 to account deferred
>> split THPs into available memory since NR_ANON_THPS may contain
>> non-deferred split THPs.
>>
>> I could use an internal counter for deferred split THPs, but if it is
>> accounted by mod_node_page_state, why not just show it in /proc/meminfo?
> The answer to "Why not" is that it becomes part of userspace API (btw this
> patchset should have CC'd linux-api@ - please do for further iterations) and
> even if the implementation detail of deferred splitting might change in the
> future, we'll basically have to keep the counter (even with 0 value) in
> /proc/meminfo forever.
>
> Also, quite recently we have added the following counter:
>
> KReclaimable: Kernel allocations that the kernel will attempt to reclaim
>                under memory pressure. Includes SReclaimable (below), and other
>                direct allocations with a shrinker.
>
> Although THP allocations are not exactly "kernel allocations", once they are
> unmapped, they are in fact kernel-only, so IMHO it wouldn't be a big stretch to
> add the lazy THP pages there?

Thanks a lot for the suggestion. I agree it may be a good fit. Hope 
"kernel allocations" not cause confusion. But, we can explain in the 
documentation.

>
>> Or we fix NR_ANON_THPS and show deferred split THPs in /proc/meminfo?
>>


