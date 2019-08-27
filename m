Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C53A5C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 17:12:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 938E92173E
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 17:12:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 938E92173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A1AD6B0008; Tue, 27 Aug 2019 13:12:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12B816B000A; Tue, 27 Aug 2019 13:12:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 019346B000C; Tue, 27 Aug 2019 13:12:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id CF5246B0008
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:12:48 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8385A8404
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:12:24 +0000 (UTC)
X-FDA: 75868851408.23.waves90_8953601643631
X-HE-Tag: waves90_8953601643631
X-Filterd-Recvd-Size: 4685
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com [115.124.30.54])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:12:23 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0Tacy7tn_1566925936;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0Tacy7tn_1566925936)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 28 Aug 2019 01:12:20 +0800
Subject: Re: WARNINGs in set_task_reclaim_state with memory cgroup and full
 memory usage
To: Michal Hocko <mhocko@kernel.org>
Cc: Adric Blake <promarbler14@gmail.com>, akpm@linux-foundation.org,
 ktkhai@virtuozzo.com, hannes@cmpxchg.org, daniel.m.jordan@oracle.com,
 laoar.shao@gmail.com, mgorman@techsingularity.net, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <CAE1jjeePxYPvw1mw2B3v803xHVR_BNnz0hQUY_JDMN8ny29M6w@mail.gmail.com>
 <b9cd7603-2441-d351-156a-57d6c13b2c79@linux.alibaba.com>
 <20190826105521.GF7538@dhcp22.suse.cz> <20190827104313.GW7538@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6bbdd982-8c33-0a07-b8ea-5bd1be594b6e@linux.alibaba.com>
Date: Tue, 27 Aug 2019 10:12:07 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190827104313.GW7538@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/27/19 3:43 AM, Michal Hocko wrote:
> If there are no objection to the patch I will post it as a standalong
> one.
>
> On Mon 26-08-19 12:55:21, Michal Hocko wrote:
>>  From 59d128214a62bf2d83c2a2a9cde887b4817275e7 Mon Sep 17 00:00:00 2001
>> From: Michal Hocko <mhocko@suse.com>
>> Date: Mon, 26 Aug 2019 12:43:15 +0200
>> Subject: [PATCH] mm, memcg: do not set reclaim_state on soft limit reclaim
>>
>> Adric Blake has noticed the following warning:
>> [38491.963105] WARNING: CPU: 7 PID: 175 at mm/vmscan.c:245 set_task_reclaim_state+0x1e/0x40
>> [...]
>> [38491.963239] Call Trace:
>> [38491.963246]  mem_cgroup_shrink_node+0x9b/0x1d0
>> [38491.963250]  mem_cgroup_soft_limit_reclaim+0x10c/0x3a0
>> [38491.963254]  balance_pgdat+0x276/0x540
>> [38491.963258]  kswapd+0x200/0x3f0
>> [38491.963261]  ? wait_woken+0x80/0x80
>> [38491.963265]  kthread+0xfd/0x130
>> [38491.963267]  ? balance_pgdat+0x540/0x540
>> [38491.963269]  ? kthread_park+0x80/0x80
>> [38491.963273]  ret_from_fork+0x35/0x40
>> [38491.963276] ---[ end trace 727343df67b2398a ]---
>>
>> which tells us that soft limit reclaim is about to overwrite the
>> reclaim_state configured up in the call chain (kswapd in this case but
>> the direct reclaim is equally possible). This means that reclaim stats
>> would get misleading once the soft reclaim returns and another reclaim
>> is done.
>>
>> Fix the warning by dropping set_task_reclaim_state from the soft reclaim
>> which is always called with reclaim_state set up.

This is exactly what I thought. Looks good to me. Acked-by: Yang Shi 
<yang.shi@linux.alibaba.com>

>>
>> Reported-by: Adric Blake <promarbler14@gmail.com>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> ---
>>   mm/vmscan.c | 5 +++--
>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index c77d1e3761a7..a6c5d0b28321 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3220,6 +3220,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>>   
>>   #ifdef CONFIG_MEMCG
>>   
>> +/* Only used by soft limit reclaim. Do not reuse for anything else. */
>>   unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
>>   						gfp_t gfp_mask, bool noswap,
>>   						pg_data_t *pgdat,
>> @@ -3235,7 +3236,8 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
>>   	};
>>   	unsigned long lru_pages;
>>   
>> -	set_task_reclaim_state(current, &sc.reclaim_state);
>> +	WARN_ON_ONCE(!current->reclaim_state);
>> +
>>   	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>>   			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>>   
>> @@ -3253,7 +3255,6 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
>>   
>>   	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
>>   
>> -	set_task_reclaim_state(current, NULL);
>>   	*nr_scanned = sc.nr_scanned;
>>   
>>   	return sc.nr_reclaimed;
>> -- 
>> 2.20.1
>>
>> -- 
>> Michal Hocko
>> SUSE Labs


