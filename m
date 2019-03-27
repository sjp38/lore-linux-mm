Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14417C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:59:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C63FD206BA
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:59:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C63FD206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CA7E6B0270; Wed, 27 Mar 2019 14:59:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5508D6B0271; Wed, 27 Mar 2019 14:59:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F21E6B0273; Wed, 27 Mar 2019 14:59:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 049206B0270
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:59:39 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i14so10467725pfd.10
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=rDuSNrY830CDsFeJewbJEp95VwnrNFpfLFdaflkx5oE=;
        b=ukMXMykT0R42nfkcCTRNfGp7NQxD8Q1ZE5NB1A4/xsiJ0jP6lofDbOEgaiaJh9xUuj
         faucaDp76aUmT4d4/pzNXsIzANQDUeprHtG94CbAhJzemUwSxSijhPHhVUI3ZiL2Q9lw
         +96Cp1YHzrVJPoZNjuHVqeQwe7gv/zz10ZbsMrElWLa2Jkiuv6NkmaaiXw8EK2iY24m3
         +0epxREr0Z9Eh+lT0bPMvt34lskchMpYz8Z82K5dDcje65O6oMLcDXq5WACunB+BUwcK
         I7fRwgu+lsrWJFXwsQCWxqsD7QVWdUZOiT4R6XtWNIxZlq3P8Zo3XhC8CKkfKKO563FA
         /gRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUntOjlqtM2/C+K4Om3OGdD9MbxaG4uPACt91cUKKbku0ATyATu
	YHRK3LwhsD/8w8NvBVv/SBn0PPPBR1aNbsTvhgQGJ7n0bcTqULPZjsiX97CcJI2Y6tpzZfF3Lra
	9bMJt602rl8ag9+2Qq3/8pF2CvfOOP/V/4AksMIsqxf7hP9T6TU+VUY7PsOPHn85XRw==
X-Received: by 2002:a65:5ac3:: with SMTP id d3mr12806041pgt.168.1553713178654;
        Wed, 27 Mar 2019 11:59:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLpgfs9SWYFHoKwg58+Yv09SqOXhOVR9tGkKTrlMed6HI7IIQEpiGZcbVOYyQWSavqkSjr
X-Received: by 2002:a65:5ac3:: with SMTP id d3mr12805981pgt.168.1553713177715;
        Wed, 27 Mar 2019 11:59:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553713177; cv=none;
        d=google.com; s=arc-20160816;
        b=npfLXb8AO0kz1knfu6H3IDSUSPWSKLos5OHapiphfYUJ9V3nn93jW+TNrH9FEFgrLB
         i7TzC6vWapSThBceti71wO2vhT7E1/EAntEneQbQ/O8HIfbpWz8blQu0s64/IokWybtr
         rhluhrQHsRhK0OKOnJ5AKUbXpznGo4SjPqHJDSJq0Nf+hJeGRJKEIgsLai10OnSVkgzd
         eEp+dLaXss+YrmnUERaY4o9hodX4XMOP5eR/uxi+vMmTpPg60MUbqgqlKnWbvfGo2i2V
         GKFgRxiGtEJ36YuCc4qiaQjGbun0ZYTyY7mScXF55hTVwpKnxWpwEWiZZ7Vt2asgzYk7
         rTiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rDuSNrY830CDsFeJewbJEp95VwnrNFpfLFdaflkx5oE=;
        b=Hf9h9uVumFCQknFJfO3uryrkHXNoH5Rs7kDlFLS8dqlGHPUHQb9H1m5jJBfDH2kwcY
         OmCHYzYFdh9kx1EwF2NlW/6nLASSdlJowAzkz0oo8ixlTGlVzABQnLcccpu3iny2JRmx
         5Flpt5KeA8nz5WBEY6EQ2ey4Fx1d4jMGHem8M4evbtpGqSELVoHfW3D8+IIm/QVD29RP
         nvSzORWYqELJ/J3E7NA/VAT365M50jUqanILxQvw+nx0zTuf8t9HQ30ZwOrW/O+yV0P+
         IkANpjW7gFebBrKlqW3MxHGx4DM3+pRr86adwI1bVnWPRyNdUT3ThO7HI/uP1f/ivCKt
         af+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id n4si18440747pgq.198.2019.03.27.11.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:59:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07488;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TNns2pG_1553713170;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNns2pG_1553713170)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 28 Mar 2019 02:59:34 +0800
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Rik van Riel
 <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
 "Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com>
Date: Wed, 27 Mar 2019 11:59:28 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/27/19 10:34 AM, Dan Williams wrote:
> On Wed, Mar 27, 2019 at 2:01 AM Michal Hocko <mhocko@kernel.org> wrote:
>> On Tue 26-03-19 19:58:56, Yang Shi wrote:
>>>
>>> On 3/26/19 11:37 AM, Michal Hocko wrote:
>>>> On Tue 26-03-19 11:33:17, Yang Shi wrote:
>>>>> On 3/26/19 6:58 AM, Michal Hocko wrote:
>>>>>> On Sat 23-03-19 12:44:25, Yang Shi wrote:
>>>>>>> With Dave Hansen's patches merged into Linus's tree
>>>>>>>
>>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
>>>>>>>
>>>>>>> PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
>>>>>>> effectively and efficiently is still a question.
>>>>>>>
>>>>>>> There have been a couple of proposals posted on the mailing list [1] [2].
>>>>>>>
>>>>>>> The patchset is aimed to try a different approach from this proposal [1]
>>>>>>> to use PMEM as NUMA nodes.
>>>>>>>
>>>>>>> The approach is designed to follow the below principles:
>>>>>>>
>>>>>>> 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
>>>>>>>
>>>>>>> 2. DRAM first/by default. No surprise to existing applications and default
>>>>>>> running. PMEM will not be allocated unless its node is specified explicitly
>>>>>>> by NUMA policy. Some applications may be not very sensitive to memory latency,
>>>>>>> so they could be placed on PMEM nodes then have hot pages promote to DRAM
>>>>>>> gradually.
>>>>>> Why are you pushing yourself into the corner right at the beginning? If
>>>>>> the PMEM is exported as a regular NUMA node then the only difference
>>>>>> should be performance characteristics (module durability which shouldn't
>>>>>> play any role in this particular case, right?). Applications which are
>>>>>> already sensitive to memory access should better use proper binding already.
>>>>>> Some NUMA topologies might have quite a large interconnect penalties
>>>>>> already. So this doesn't sound like an argument to me, TBH.
>>>>> The major rationale behind this is we assume the most applications should be
>>>>> sensitive to memory access, particularly for meeting the SLA. The
>>>>> applications run on the machine may be agnostic to us, they may be sensitive
>>>>> or non-sensitive. But, assuming they are sensitive to memory access sounds
>>>>> safer from SLA point of view. Then the "cold" pages could be demoted to PMEM
>>>>> nodes by kernel's memory reclaim or other tools without impairing the SLA.
>>>>>
>>>>> If the applications are not sensitive to memory access, they could be bound
>>>>> to PMEM or allowed to use PMEM (nice to have allocation on DRAM) explicitly,
>>>>> then the "hot" pages could be promoted to DRAM.
>>>> Again, how is this different from NUMA in general?
>>> It is still NUMA, users still can see all the NUMA nodes.
>> No, Linux NUMA implementation makes all numa nodes available by default
>> and provides an API to opt-in for more fine tuning. What you are
>> suggesting goes against that semantic and I am asking why. How is pmem
>> NUMA node any different from any any other distant node in principle?
> Agree. It's just another NUMA node and shouldn't be special cased.
> Userspace policy can choose to avoid it, but typical node distance
> preference should otherwise let the kernel fall back to it as
> additional memory pressure relief for "near" memory.

In ideal case, yes, I agree. However, in real life world the performance 
is a concern. It is well-known that PMEM (not considering NVDIMM-F or 
HBM) has higher latency and lower bandwidth. We observed much higher 
latency on PMEM than DRAM with multi threads.

In real production environment we don't know what kind of applications 
would end up on PMEM (DRAM may be full, allocation fall back to PMEM) 
then have unexpected performance degradation. I understand to have 
mempolicy to choose to avoid it. But, there might be hundreds or 
thousands of applications running on the machine, it sounds not that 
feasible to me to have each single application set mempolicy to avoid it.

So, I think we still need a default allocation node mask. The default 
value may include all nodes or just DRAM nodes. But, they should be able 
to be override by user globally, not only per process basis.

Due to the performance disparity, currently our usecases treat PMEM as 
second tier memory for demoting cold page or binding to not memory 
access sensitive applications (this is the reason for inventing a new 
mempolicy) although it is a NUMA node.

Thanks,
Yang


