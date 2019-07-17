Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41EF0C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:09:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C90EF2173E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:09:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C90EF2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 675316B000D; Wed, 17 Jul 2019 13:09:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625BE8E0003; Wed, 17 Jul 2019 13:09:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 514308E0001; Wed, 17 Jul 2019 13:09:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19F276B000D
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:09:24 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 191so14821092pfy.20
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:09:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=COGTPqnLPC3BsHheLeeBLXogSA6zIOvNVBwc+3yIl3g=;
        b=Xo31pB2H8UOa5c1hAHy8HcFZb8qieYioFypdc5zwQerTGXzMeHhsFLK2t1t4kbgOYX
         LVRvDvY++V4ShdrBRMzZ1bDXWGQouXpSmJ/4COidlQ+Fro7vx18w8M/pUbi3X0EFYkeG
         +rn0OxUARE24DYQCoioeJxmelbyJBX6WWiRqKV8nj6htb/x6Srr3O4CAmFPM18BBwcG6
         DZuSy3i6NfNFCdd3jNaiyBmAAtI1RTeIWC8eShFk+7hHPjUeGjqAE0X1gsvGIR5WhWam
         8Hxp1UrUI36qcLv+miCnx7FVYWWGts39H92YXqHX9QRVu5fohrHIH4jEG52mr03xs64V
         osnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVToyb2VNr+Pp2HfW161Pmn+U3+bgh/7NxX7mq/PfmbAe1yYxsq
	Z8kseX8Bctz7mNyyNBtRAtbRpO+C+sE1oQlOlAABNqVJFhoFQN6kVjKHY9qYLBpqu8ahF8XWqCG
	iM2x+BZ6ZfHbhJCoiMU5FFhbD6ParPuK6LP/dXFMOnwz1BOD82yuVH6hzBPWjI9bMAQ==
X-Received: by 2002:a17:90a:b011:: with SMTP id x17mr45778219pjq.113.1563383363730;
        Wed, 17 Jul 2019 10:09:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOFQ3wjqd3FU/6qXsnXisv+Xtst0CnCm9Bjh6fiScsC5m4UySRpW2KTlOtPTyIpXvx99E0
X-Received: by 2002:a17:90a:b011:: with SMTP id x17mr45778147pjq.113.1563383362950;
        Wed, 17 Jul 2019 10:09:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563383362; cv=none;
        d=google.com; s=arc-20160816;
        b=PhhZzh5l5gkt7w2EuYy5DSQ57cavPSbf2Qb7sarmWYfJrmLRCgG/KWq+RSOwJTqdna
         P/KlGMPhrXtDK/H103gADSNujwfrw57uCIB4h1XnlbpKcQlNKLatFXvXM/Yt6Ltqmr6J
         jZGC/XPmNjEZfIU8rilcfqsFruVAxdp5jDR18BQzSc9ikw9nMtkNzUIBlGk5Q67+nvsx
         kOa4WufqH+q+rx/omxKTdez7s8STT8vdQwhEgkUpnA9WmeMxDjI8H+vky7BVrMPNldQq
         wt/KVhT2uShGZDNyEgvAOFdGR/eaFIMdgPmdGYiD23ZrWe44b1CoXFi5c86kCJCLqj1Z
         Y6hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=COGTPqnLPC3BsHheLeeBLXogSA6zIOvNVBwc+3yIl3g=;
        b=mmd5yMvDkRXj0nWkOBFcZFAharFR+YbBdyUWqRVu28VfdSTRaVB/WDRuikyqz2vuuv
         bCjhUyIEuJ3erg4E1gObhF4BfT3EERt8BARCueLNkOsvFqKRBdagrvlGmgiY2CACmXdf
         zlQayGTtXbrn710yNIyHttZt0Ng8ySHmW3SwSzoAxNx2sUyJg3jjXLxoSmb8U29jhEmO
         F/YwBLITSBvg3/ZBJ1cj3hrGvCTSUqoBHl99hGYG/evv5WsLoZCx8ajZbLP/5M7UtG2v
         WzJO/+ac/96JzT1X9z8NaJPiBcLg5f5Up0Oh9n1l8P90Pc55Vc9dB5ZNBmosOnpXYyTR
         AleQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id z197si24040439pgz.267.2019.07.17.10.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 10:09:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TX8rF-l_1563383355;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX8rF-l_1563383355)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 01:09:19 +0800
Subject: Re: list corruption in deferred_split_scan()
To: Shakeel Butt <shakeelb@google.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Hugh Dickins <hughd@google.com>,
 Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Roman Gushchin <guro@fb.com>, Qian Cai <cai@lca.pw>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>
References: <1562795006.8510.19.camel@lca.pw>
 <cd6e10bc-cb79-65c5-ff2b-4c244ae5eb1c@linux.alibaba.com>
 <1562879229.8510.24.camel@lca.pw>
 <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
 <1563225798.4610.5.camel@lca.pw>
 <5c853e6e-6367-d83c-bb97-97cd67320126@linux.alibaba.com>
 <8A64D551-FF5B-4068-853E-9E31AF323517@lca.pw>
 <e5aa1f5b-b955-5b8e-f502-7ac5deb141a7@linux.alibaba.com>
 <CALvZod7+ComCUROSBaj==r0VmCczs=npP4u6C9LuJWNWdfB0Pg@mail.gmail.com>
 <50f57bf8-a71a-c61f-74f7-31fb7bfe3253@linux.alibaba.com>
 <CALvZod7Je+gekSGR61LMeHdYoC_PJune_0qGNiDfNH2=oNeOgw@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <01007247-8252-248a-7d97-f739120c7595@linux.alibaba.com>
Date: Wed, 17 Jul 2019 10:09:15 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <CALvZod7Je+gekSGR61LMeHdYoC_PJune_0qGNiDfNH2=oNeOgw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/17/19 10:02 AM, Shakeel Butt wrote:
> On Tue, Jul 16, 2019 at 5:12 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>
>>
>> On 7/16/19 4:36 PM, Shakeel Butt wrote:
>>> Adding related people.
>>>
>>> The thread starts at:
>>> http://lkml.kernel.org/r/1562795006.8510.19.camel@lca.pw
>>>
>>> On Mon, Jul 15, 2019 at 8:01 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>>>
>>>> On 7/15/19 6:36 PM, Qian Cai wrote:
>>>>>> On Jul 15, 2019, at 8:22 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>>>>>
>>>>>>
>>>>>>
>>>>>> On 7/15/19 2:23 PM, Qian Cai wrote:
>>>>>>> On Fri, 2019-07-12 at 12:12 -0700, Yang Shi wrote:
>>>>>>>>> Another possible lead is that without reverting the those commits below,
>>>>>>>>> kdump
>>>>>>>>> kernel would always also crash in shrink_slab_memcg() at this line,
>>>>>>>>>
>>>>>>>>> map = rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_map, true);
>>>>>>>> This looks a little bit weird. It seems nodeinfo[nid] is NULL? I didn't
>>>>>>>> think of where nodeinfo was freed but memcg was still online. Maybe a
>>>>>>>> check is needed:
>>>>>>> Actually, "memcg" is NULL.
>>>>>> It sounds weird. shrink_slab() is called in mem_cgroup_iter which does pin the memcg. So, the memcg should not go away.
>>>>> Well, the commit “mm: shrinker: make shrinker not depend on memcg kmem” changed this line in shrink_slab_memcg(),
>>>>>
>>>>> -     if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
>>>>> +     if (!mem_cgroup_online(memcg))
>>>>>                 return 0;
>>>>>
>>>>> Since the kdump kernel has the parameter “cgroup_disable=memory”, shrink_slab_memcg() will no longer be able to handle NULL memcg from mem_cgroup_iter() as,
>>>>>
>>>>> if (mem_cgroup_disabled())
>>>>>         return NULL;
>>>> Aha, yes. memcg_kmem_enabled() implicitly checks !mem_cgroup_disabled().
>>>> Thanks for figuring this out. I think we need add mem_cgroup_dsiabled()
>>>> check before calling shrink_slab_memcg() as below:
>>>>
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index a0301ed..2f03c61 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -701,7 +701,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int
>>>> nid,
>>>>            unsigned long ret, freed = 0;
>>>>            struct shrinker *shrinker;
>>>>
>>>> -       if (!mem_cgroup_is_root(memcg))
>>>> +       if (!mem_cgroup_disabled() && !mem_cgroup_is_root(memcg))
>>>>                    return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>>>>
>>>>            if (!down_read_trylock(&shrinker_rwsem))
>>>>
>>> We were seeing unneeded oom-kills on kernels with
>>> "cgroup_disabled=memory" and Yang's patch series basically expose the
>>> bug to crash. I think the commit aeed1d325d42 ("mm/vmscan.c:
>>> generalize shrink_slab() calls in shrink_node()") missed the case for
>>> "cgroup_disabled=memory". However I am surprised that root_mem_cgroup
>>> is allocated even for "cgroup_disabled=memory" and it seems like
>>> css_alloc() is called even before checking if the corresponding
>>> controller is disabled.
>> I'm surprised too. A quick test with drgn shows root memcg is definitely
>> allocated:
>>
>>   >>> prog['root_mem_cgroup']
>> *(struct mem_cgroup *)0xffff8902cf058000 = {
>> [snip]
>>
>> But, isn't this a bug?
> It can be treated as a bug as this is not expected but we can discuss
> and take care of it later. I think we need your patch urgently as
> memory reclaim and /proc/sys/vm/drop_caches is broken for
> "cgroup_disabled=memory" kernel. So, please send your patch asap.

Sure. I'm going to post the patch soon.

>
> thanks,
> Shakeel

