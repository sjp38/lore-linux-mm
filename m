Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47117C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 18:33:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05AC2206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 18:33:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05AC2206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9540C6B0007; Tue, 26 Mar 2019 14:33:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9029F6B0008; Tue, 26 Mar 2019 14:33:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81BA06B000A; Tue, 26 Mar 2019 14:33:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2CD6B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 14:33:29 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a3so8291238pfi.17
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 11:33:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=TD/b2/hM4h5fo7jz1LqyJuL1ejYtU2fMFb4c85iZhWw=;
        b=TR0bSHLYAHOYZQVBIOf2ga2y3/eTjTeCb+DfqwkjT9DEyg5jAU+rJAcR+Q5cxux7ck
         +EHb3HVwQypCI5JOfzJ/TXuz6KQlWbdr/a1PgWq1QNexRKMvL3EZ0p8PTIn2wS/q9Tp2
         1Jd+rU8Onq8aIWOGpPIXu0lkxnOjT6gXrF9kGTh3WkntQQ/0yFgRFVZghY8iCN5noAfA
         xmITnr+z9pU29YOpdGzMSK2itJzZVG+JCkmGd4CTpYoAsbblHhtc4LNr+RYl/8I8b/SU
         mxofzGHuwPwLOcsM+5PgdjhHLjbqNss1pzpTBMOo/w5dX9dd6nsKh0+JX6OyiD3GgmYa
         XR5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUE6BjjAbPAucT+7qN7phGVgyK5S5987AkCX+hrMAni6PUzcyya
	mQua8Dgx/fQFob54tzLdkn/+5maBbMo55yREu6IYMUNWRps45KVprRAdp9Avd9xvM96Hof0jctc
	uTjjya0mFvcZhMmagrbblBmbQ7xlpvED05hFOfW4lXzovOWuv147719D7N/pqjVOehw==
X-Received: by 2002:a17:902:9f83:: with SMTP id g3mr33356109plq.296.1553625208871;
        Tue, 26 Mar 2019 11:33:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFyKEFOzSXykpitpyoPqnMNE0oGr+KXovSLhV2scA8YZ05SBJI3l+w7lKAXGr3WUg9mq/K
X-Received: by 2002:a17:902:9f83:: with SMTP id g3mr33356021plq.296.1553625207906;
        Tue, 26 Mar 2019 11:33:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553625207; cv=none;
        d=google.com; s=arc-20160816;
        b=qjaARfWco/z3mjAF5yCXdK8mFM3fcNWAlEo71YfiuYDGlkXJKLhefkSMYix7rnBhep
         1KOhBShW+OygUZ/yUCdxi5/lcMGzzych7xCHZ8UqSKrBRtkDWh8azk7zf3kS0SE5vyL5
         QLUh1S1Y8tmU5iMOnNy3j838xEwR5GtMWlEv/HHh7w1S1wYd+Wdu27xrFMw4azJkeFaC
         kri24csleTzKyBPLVUT+9g9nM9p8YPcsr6A5LU+UYiwgTCWHVCaIfDXcRN7if0VGZxao
         iXQnxVLeYFENLwVrH22ie2Ms09YnDaCaglOogdHmHPF07qXkrQIDEUyL2WkQvcypgjQS
         jorA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=TD/b2/hM4h5fo7jz1LqyJuL1ejYtU2fMFb4c85iZhWw=;
        b=MdSKbNFNvUtWBKPitACP6eXs01dDBKZDjZdcI51QvhvRmFKfCJ6/wu8sWeJlRTiBWr
         shv0nnYgxov17hpwPoJUQ0Qmya2nxUOiaxcT1/7YbuPlAqiS+OBZmTaZRsil4rBxlzKX
         CMT/fPjR4KA4oH1tjW+FFBxsjHG873ufSlJ7nngIkdA+zeg2sbt3kjYpbDJcLmXoSQU1
         2xDcX57cZsehhF65AkjFNGrzdWSPesdsxPugrAcYcjzaXXZHZ4l64C/TN4qB3pxPmxoF
         uIktSghODWERNX0vSUkIa15kjSY/A6qAxmOON6UlB7fTZ/vV6ClsWiNfWwNNqptShHXZ
         MDUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id s9si8160157pgr.443.2019.03.26.11.33.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 11:33:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R511e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TNjAgnd_1553625198;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNjAgnd_1553625198)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 27 Mar 2019 02:33:24 +0800
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, dave.hansen@intel.com, keith.busch@intel.com,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
Date: Tue, 26 Mar 2019 11:33:17 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190326135837.GP28406@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/26/19 6:58 AM, Michal Hocko wrote:
> On Sat 23-03-19 12:44:25, Yang Shi wrote:
>> With Dave Hansen's patches merged into Linus's tree
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
>>
>> PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
>> effectively and efficiently is still a question.
>>
>> There have been a couple of proposals posted on the mailing list [1] [2].
>>
>> The patchset is aimed to try a different approach from this proposal [1]
>> to use PMEM as NUMA nodes.
>>
>> The approach is designed to follow the below principles:
>>
>> 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
>>
>> 2. DRAM first/by default. No surprise to existing applications and default
>> running. PMEM will not be allocated unless its node is specified explicitly
>> by NUMA policy. Some applications may be not very sensitive to memory latency,
>> so they could be placed on PMEM nodes then have hot pages promote to DRAM
>> gradually.
> Why are you pushing yourself into the corner right at the beginning? If
> the PMEM is exported as a regular NUMA node then the only difference
> should be performance characteristics (module durability which shouldn't
> play any role in this particular case, right?). Applications which are
> already sensitive to memory access should better use proper binding already.
> Some NUMA topologies might have quite a large interconnect penalties
> already. So this doesn't sound like an argument to me, TBH.

The major rationale behind this is we assume the most applications 
should be sensitive to memory access, particularly for meeting the SLA. 
The applications run on the machine may be agnostic to us, they may be 
sensitive or non-sensitive. But, assuming they are sensitive to memory 
access sounds safer from SLA point of view. Then the "cold" pages could 
be demoted to PMEM nodes by kernel's memory reclaim or other tools 
without impairing the SLA.

If the applications are not sensitive to memory access, they could be 
bound to PMEM or allowed to use PMEM (nice to have allocation on DRAM) 
explicitly, then the "hot" pages could be promoted to DRAM.

>
>> 5. Control memory allocation and hot/cold pages promotion/demotion on per VMA
>> basis.
> What does that mean? Anon vs. file backed memory?

Yes, kind of. Basically, we would like to control the memory placement 
and promotion (by NUMA balancing) per VMA basis. For example, anon VMAs 
may be DRAM by default, file backed VMAs may be PMEM by default. Anyway, 
basically this is achieved freely by mempolicy.

>
> [...]
>
>> 2. Introduce a new mempolicy, called MPOL_HYBRID to keep other mempolicy
>> semantics intact. We would like to have memory placement control on per process
>> or even per VMA granularity. So, mempolicy sounds more reasonable than madvise.
>> The new mempolicy is mainly used for launching processes on PMEM nodes then
>> migrate hot pages to DRAM nodes via NUMA balancing. MPOL_BIND could bind to
>> PMEM nodes too, but migrating to DRAM nodes would just break the semantic of
>> it. MPOL_PREFERRED can't constraint the allocation to PMEM nodes. So, it sounds
>> a new mempolicy is needed to fulfill the usecase.
> The above restriction pushes you to invent an API which is not really
> trivial to get right and it seems quite artificial to me already.

First of all, the use case is some applications may be not that 
sensitive to memory access or are willing to achieve net win by trading 
some performance to save some cost (have some memory on PMEM). So, such 
applications may be bound to PMEM at the first place then promote hot 
pages to DRAM via NUMA balancing or whatever mechanism.

Both MPOL_BIND and MPOL_PREFERRED sounds not fit into this usecase quite 
naturally.

Secondly, it looks just default policy does NUMA balancing. Once the 
policy is changed to MPOL_BIND, NUMA balancing would not chime in.

So, I invented the new mempolicy.

>
>> 3. The new mempolicy would promote pages to DRAM via NUMA balancing. IMHO, I
>> don't think kernel is a good place to implement sophisticated hot/cold page
>> distinguish algorithm due to the complexity and overhead. But, kernel should
>> have such capability. NUMA balancing sounds like a good start point.
> This is what the kernel does all the time. We call it memory reclaim.
>
>> 4. Promote twice faulted page. Use PG_promote to track if a page is faulted
>> twice. This is an optimization to NUMA balancing to reduce the migration
>> thrashing and overhead for migrating from PMEM.
> I am sorry, but page flags are an extremely scarce resource and a new
> flag is extremely hard to get. On the other hand we already do have
> use-twice detection for mapped page cache (see page_check_references). I
> believe we can generalize that to anon pages as well.

Yes, I agree. A new page flag sounds not preferred. I'm going to take a 
look at page_check_references().

>
>> 5. When DRAM has memory pressure, demote page to PMEM via page reclaim path.
>> This is quite similar to other proposals. Then NUMA balancing will promote
>> page to DRAM as long as the page is referenced again. But, the
>> promotion/demotion still assumes two tier main memory. And, the demotion may
>> break mempolicy.
> Yes, this sounds like a good idea to me ;)
>
>> 6. Anonymous page only for the time being since NUMA balancing can't promote
>> unmapped page cache.
> As long as the nvdimm access is faster than the regular storage then
> using any node (including pmem one) should be OK.

However, it still sounds better to have some frequently accessed page 
cache on DRAM.

Thanks,
Yang


