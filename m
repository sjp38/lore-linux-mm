Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81A7FC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 17:00:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AF2E20684
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 17:00:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AF2E20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC4276B0003; Mon, 12 Aug 2019 13:00:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C74606B0005; Mon, 12 Aug 2019 13:00:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B89816B0006; Mon, 12 Aug 2019 13:00:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9131A6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:00:33 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EA0018248AA3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:00:32 +0000 (UTC)
X-FDA: 75814389504.12.story39_21b014b36c34f
X-HE-Tag: story39_21b014b36c34f
X-Filterd-Recvd-Size: 5061
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com [115.124.30.43])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:00:31 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TZKRUC-_1565629223;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TZKRUC-_1565629223)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 13 Aug 2019 01:00:26 +0800
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
To: Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, vbabka@suse.cz,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
 <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
 <20190809180238.GS18351@dhcp22.suse.cz>
 <79c90f6b-fcac-02e1-015a-0eaa4eafdf7d@linux.alibaba.com>
 <fb1f4958-5147-2fab-531f-d234806c2f37@linux.alibaba.com>
 <20190812093430.GD5117@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <297aefa2-ba64-cb91-d2c8-733054db01a3@linux.alibaba.com>
Date: Mon, 12 Aug 2019 10:00:17 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190812093430.GD5117@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/12/19 2:34 AM, Michal Hocko wrote:
> On Fri 09-08-19 16:54:43, Yang Shi wrote:
>>
>> On 8/9/19 11:26 AM, Yang Shi wrote:
>>>
>>> On 8/9/19 11:02 AM, Michal Hocko wrote:
> [...]
>>>> I have to study the code some more but is there any reason why those
>>>> pages are not accounted as proper THPs anymore? Sure they are partially
>>>> unmaped but they are still THPs so why cannot we keep them accounted
>>>> like that. Having a new counter to reflect that sounds like papering
>>>> over the problem to me. But as I've said I might be missing something
>>>> important here.
>>> I think we could keep those pages accounted for NR_ANON_THPS since they
>>> are still THP although they are unmapped as you mentioned if we just
>>> want to fix the improper accounting.
>> By double checking what NR_ANON_THPS really means,
>> Documentation/filesystems/proc.txt says "Non-file backed huge pages mapped
>> into userspace page tables". Then it makes some sense to dec NR_ANON_THPS
>> when removing rmap even though they are still THPs.
>>
>> I don't think we would like to change the definition, if so a new counter
>> may make more sense.
> Yes, changing NR_ANON_THPS semantic sounds like a bad idea. Let
> me try whether I understand the problem. So we have some THP in
> limbo waiting for them to be split and unmapped parts to be freed,
> right? I can see that page_remove_anon_compound_rmap does correctly
> decrement NR_ANON_MAPPED for sub pages that are no longer mapped by
> anybody. LRU pages seem to be accounted properly as well.  As you've
> said NR_ANON_THPS reflects the number of THPs mapped and that should be
> reflecting the reality already IIUC.
>
> So the only problem seems to be that deferred THP might aggregate a lot
> of immediately freeable memory (if none of the subpages are mapped) and
> that can confuse MemAvailable because it doesn't know about the fact.
> Has an skewed counter resulted in a user observable behavior/failures?

No. But the skewed counter may make big difference for a big scale 
cluster. The MemAvailable is an important factor for cluster scheduler 
to determine the capacity.

Even though the scheduler could place one more small container due to 
extra available memory, it would make big difference for a cluster with 
thousands of nodes.

> I can see that memcg rss size was the primary problem David was looking
> at. But MemAvailable will not help with that, right? Moreover is

Yes, but David actually would like to have memcg MemAvailable (the 
accounter like the global one), which should be counted like the global 
one and should account per memcg deferred split THP properly.

> accounting the full THP correct? What if subpages are still mapped?

"Deferred split" definitely doesn't mean they are free. When memory 
pressure is hit, they would be split, then the unmapped normal pages 
would be freed. So, when calculating MemAvailable, they are not 
accounted 100%, but like "available += lazyfree - min(lazyfree / 2, 
wmark_low)", just like how page cache is accounted.

We could get more accurate account, i.e. checking each sub page's 
mapcount when accounting, but it may change before shrinker start 
scanning. So, just use the ballpark estimation to trade off the 
complexity for accurate accounting.

>


