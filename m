Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CC9FC28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 12:51:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53CBC26914
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 12:51:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53CBC26914
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDB366B027A; Fri, 31 May 2019 08:51:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8C886B027C; Fri, 31 May 2019 08:51:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A55066B027E; Fri, 31 May 2019 08:51:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5716B027A
	for <linux-mm@kvack.org>; Fri, 31 May 2019 08:51:14 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s195so4651078pgs.13
        for <linux-mm@kvack.org>; Fri, 31 May 2019 05:51:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=WUyt++ivaRQKK8ZgE3t2VGy37ZcO+VsLpiEE/ALCb78=;
        b=ak1mKHpVcYsuwMloKFsnvXWe1ASr3ieoCTq7XIJgLzGagznfDMvbLUGxb8wB/xwZYW
         gW6IwC8fQPWFy+dtlwl/8keWKzpp+X8i3Us51bB7dVt7W23bZixChVkU+PRjKQ5YFkIf
         M7Y6W7w+RHOEU84gD4ghtM5LDLTbGJD9K3s7kjvF8nKDUpzknadmepAG91fHgpbvdtrG
         ORTcvMc6xKuW/SRbcpt5+37AjO2wpDAQ95Do3tIWvFAnquSlGZHX4NKRYnI1zNWo7kVP
         nrz/XSCabqO1U8F6c4JYS+d7M2j5EO6jc9QQqNpVsYngX3o8ph1c0xvIBV4EfAXfpPim
         QZrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVmrHhKqALCFNVLDqzdHYUuQx8BYwhj0/tOrybyFfpLd6CQ0M5H
	X3fDEUVdzSU8vOfb+v0NumfK3/4PkU4BqwEXpkz671wooTIf0B2AhSa+Si+XzDzdyZcCa0sW8Bv
	gudu69Kjst1YNmkVu/3lGNtCqVwF8aHpFZW03QqoBfc1UXbR0GYWykifj5QhpApoBLg==
X-Received: by 2002:a17:902:e108:: with SMTP id cc8mr9524954plb.145.1559307074045;
        Fri, 31 May 2019 05:51:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4Ip3E3WrI4MZHDmm/XCH0If1pD2qmgii1QxiggjSSKhFxmhd+utoOwadRKQHurgMGo/kW
X-Received: by 2002:a17:902:e108:: with SMTP id cc8mr9524859plb.145.1559307073120;
        Fri, 31 May 2019 05:51:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559307073; cv=none;
        d=google.com; s=arc-20160816;
        b=QGvGS8PlkgyprHA4ZBA8xgB1fcrMODhOr8xTbUUqMANOpLxB7N/oTYBAnUhO8UrTGl
         /tezODpvUMMLHkr30IJmctuSR23ml0snb9taPFBZwQPdTinofTXp0e4ZiLSZT2BnB/lE
         AwCcgy+YgUHXKFLdojlrkpw7CWoe/fieWSGCQ5EgjlusZ1XCvxvBk1vrXAP/Nh0yDFH/
         ru/wo0yQgLbS7tNvTO3qFu00BLZkzovlEPurkNTteilvdTEIZTsjxXtrmEP8qvhNgwQA
         cpFT36FAR7y9KlaJPrUcj1uJ+QMxe0ov822U944VVSFo9xq+AOJBXa6i5wqMAsDY92rp
         xJVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WUyt++ivaRQKK8ZgE3t2VGy37ZcO+VsLpiEE/ALCb78=;
        b=cglgFWE+GDrj6/DlewZXc0Y0qzOteHHnIZ4QV5w5YjbbDoZwZhwWHWTcR/eU1Oh2rD
         vIa/1GOPSHpN3hZbRMcpHyVZfX88W/T/CpDsvN50UDJVQ15wJRXiXs5B5FUCI74XPpc/
         T3ieK1WPpA85j3dWEa6+CkBpBohzy/MkoOePx30vEfe6fdDUK1qfAYO/DvzQ9VWjqX8T
         IM6ZqkEdfkABXJCkF/cg+IUGCilBazKV8TFw5j5hNhUw+5HsLbqDEnOOsU5KFZFUXE7e
         O6wm5kzTZ5RdnW0RDiRrTmqcv+FX5x0YggKfbkzD/loI1dP1NssPif/8KFMt5czkyxUa
         Shyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id 62si5864152pgb.562.2019.05.31.05.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 05:51:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TT54NNn_1559307066;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TT54NNn_1559307066)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 31 May 2019 20:51:07 +0800
Subject: Re: [HELP] How to get task_struct from mm
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>
References: <5cf71366-ba01-8ef0-3dbd-c9fec8a2b26f@linux.alibaba.com>
 <20190530154119.GF6703@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <352de468-9091-9866-ccbd-10d80c25ebb4@linux.alibaba.com>
Date: Fri, 31 May 2019 20:51:05 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190530154119.GF6703@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/30/19 11:41 PM, Michal Hocko wrote:
> On Thu 30-05-19 14:57:46, Yang Shi wrote:
>> Hi folks,
>>
>>
>> As what we discussed about page demotion for PMEM at LSF/MM, the demotion
>> should respect to the mempolicy and allowed mems of the process which the
>> page (anonymous page only for now) belongs to.
> cpusets memory mask (aka mems_allowed) is indeed tricky and somehow
> awkward.  It is inherently an address space property and I never
> understood why we have it per _thread_. This just doesn't make any
> sense to me. This just leads to weird corner cases. What should happen
> if different threads disagree about the allocation affinity while
> working on a shared address space?

I'm supposed (just my guess) such restriction should just apply for the 
first allocation. Just like memcg charge, who does it first, whose 
policy gets applied.

>   
>> The vma that the page is mapped to can be retrieved from rmap walk easily,
>> but we need know the task_struct that the vma belongs to. It looks there is
>> not such API, and container_of seems not work with pointer member.
> I do not think this is a good idea. As you point out in the reply we
> have that for memcgs but we really hope to get rid of mm->owner there
> as well. It is just more tricky there. Moreover such a reverse mapping
> would be incorrect. Just think of a disagreeing yet overlapping cpusets
> for different threads mapping the same page.
>
> Is it such a big deal to document that the node migrate is not
> compatible with cpusets?

Not only cpuset, but get_vma_policy() also needs find task_struct from 
vma. Currently, get_vma_policy() just uses "current", so it just returns 
the current process's mempolicy if the vma doesn't have mempolicy. For 
the node migrate case, "current" is definitely not correct.

It looks there is not an easy way to workaround it unless we claim node 
migrate is not compatible with both cpusets and mempolicy.


