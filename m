Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BDD0C28CC1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 03:22:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D465C245D0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 03:22:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D465C245D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 563846B0010; Wed, 29 May 2019 23:22:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EC446B026D; Wed, 29 May 2019 23:22:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 367176B026E; Wed, 29 May 2019 23:22:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF9316B0010
	for <linux-mm@kvack.org>; Wed, 29 May 2019 23:22:30 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i3so3021740plb.8
        for <linux-mm@kvack.org>; Wed, 29 May 2019 20:22:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=xwtOiLuZd58QK4SB59arQBVji0E7OX67Ljil442vX9s=;
        b=RgKGreiXpFpuvxUvKpWjE+3fLjjvnulXN2BWvFuzijhwCwhpLVc9vK89R4z70476iZ
         FupEUlLmc/YJfUGhUzvH7feFZu1uh6Tqs6Ur3w3wDiJbKvOoEDyKYPPtd/jKUVCFHP01
         /Da67df9wo59fKdyDoXjoWQpD4hC+0IX8wwL47B7cp8OaueV2x5NlX7r3kCkjwFiXpoW
         mExwoooUqpCD2hqRraH/SyzgVUBDuFEAOV9lDI6gx1CP9DbJSB9+n0MlRSSkw7n8kemY
         Xe4gWKtmhXkN2HuP0m+ewQnmx4KJsvqwMn4ivjzzaFY4mRAohvQ/pnKsHjUcJPAk2WB8
         ZLiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUFxyctITaWIosnKs/AHMiLj3m7gsbmde/l6WLJXotUj5+z6Do0
	j5WY8mqb+5pgp8cHdp9tPrkU6XmXX+cWtKwCeagK11w08KIJKpc3PGY/ZmCLDIL2uN6O/F04rma
	ZymhhrHWMnwyTQJamZK29VKzFDAp3b/rYxBmSVW1s2xNjZJMoMgygB4yb60g0RgfD6A==
X-Received: by 2002:a63:441c:: with SMTP id r28mr1627579pga.255.1559186550436;
        Wed, 29 May 2019 20:22:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyt4yy42Ce1P7Hi/Iukn2l2Ge79ZInwll/HlwC+QAARvO8XGfJ1X//PL2D32+16CbaWC+iF
X-Received: by 2002:a63:441c:: with SMTP id r28mr1627490pga.255.1559186549264;
        Wed, 29 May 2019 20:22:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559186549; cv=none;
        d=google.com; s=arc-20160816;
        b=UBNwTW//2tQS71r53Ag85qngZC4GWHOdOoggw4WVTPKVkeym9g36Go28ywRhcaGr/V
         P8N24TVYqXrETZW5i7Yrf768Rnr4cyFg6ju1O+lNPvOMikWKGX1KXAswyEVu+ZaCO62Z
         dIwSspHeKnxqA6QcB4v/OODor2CnLoztXODm0XnL76hbwaWANPCKFcLYQmfOmIIorlzS
         Crz0b/dC49XQy3rY8QALahx6aJoUI9TSYvAcoDzh/uzeNAvf5eULcMdB4MwX3j17BkV0
         coBiIfEPqA7mgg+Ftw22jVRbiTSL13OId7KeC+/02RrV7XaoHLjEL0qvUoisDxIW9DIw
         Eg6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xwtOiLuZd58QK4SB59arQBVji0E7OX67Ljil442vX9s=;
        b=p2r0qayaRk5Kyjrz+O2bP59V3dM6qFt1ElHwfcxxos2fn9jYL3qBSwHLs0i98/IhN9
         rtlF/kMCn/0x561wsIM0EvZqnGFARYhLWRPr4cZbtbkSGAgzbyHwAbxL1/f2N3CK8Mp6
         +rKOHD6WeovqXEHEdm39D3bk7sRP92r6PwKzNLviFnmISGC8n5W4hKOrWZkeiAJO7T+r
         fFuCUJW9ctnKQqPkHXowyMKJ2iDXTHhmqGrjksidxkRHH72JpELY18FKfCOoEReeu8qP
         rDN3L1ZMeiOF5PKGAQ7gjG7q50J/yvhRut3X0mrUp5O6mj1EW08PswlC1Wrkz258c5h8
         dtXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id b18si2091910pgm.82.2019.05.29.20.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 20:22:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R451e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TT-SMAB_1559186545;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TT-SMAB_1559186545)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 30 May 2019 11:22:26 +0800
Subject: Re: [RFC PATCH 0/3] Make deferred split shrinker memcg aware
To: David Rientjes <rientjes@google.com>
Cc: ktkhai@virtuozzo.com, hannes@cmpxchg.org, mhocko@suse.com,
 kirill.shutemov@linux.intel.com, hughd@google.com, shakeelb@google.com,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.DEB.2.21.1905281817090.86034@chino.kir.corp.google.com>
 <2e23bd8c-6120-5a86-9e9e-ab43b02ce150@linux.alibaba.com>
 <alpine.DEB.2.21.1905291402360.242480@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9af25d50-576a-3cc3-20a3-c0c61cf3e494@linux.alibaba.com>
Date: Thu, 30 May 2019 11:22:21 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1905291402360.242480@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/30/19 5:07 AM, David Rientjes wrote:
> On Wed, 29 May 2019, Yang Shi wrote:
>
>>> Right, we've also encountered this.  I talked to Kirill about it a week or
>>> so ago where the suggestion was to split all compound pages on the
>>> deferred split queues under the presence of even memory pressure.
>>>
>>> That breaks cgroup isolation and perhaps unfairly penalizes workloads that
>>> are running attached to other memcg hierarchies that are not under
>>> pressure because their compound pages are now split as a side effect.
>>> There is a benefit to keeping these compound pages around while not under
>>> memory pressure if all pages are subsequently mapped again.
>> Yes, I do agree. I tried other approaches too, it sounds making deferred split
>> queue per memcg is the optimal one.
>>
> The approach we went with were to track the actual counts of compound
> pages on the deferred split queue for each pgdat for each memcg and then
> invoke the shrinker for memcg reclaim and iterate those not charged to the
> hierarchy under reclaim.  That's suboptimal and was a stop gap measure
> under time pressure: it's refreshing to see the optimal method being
> pursued, thanks!

We did the exactly same thing for a temporary hotfix.

>
>>> I'm curious if your internal applications team is also asking for
>>> statistics on how much memory can be freed if the deferred split queues
>>> can be shrunk?  We have applications that monitor their own memory usage
>> No, but this reminds me. The THPs on deferred split queue should be accounted
>> into available memory too.
>>
> Right, and we have also seen this for users of MADV_FREE that have both an
> increased rss and memcg usage that don't realize that the memory is freed
> under pressure.  I'm thinking that we need some kind of MemAvailable for
> memcg hierarchies to be the authoritative source of what can be reclaimed
> under pressure.

It sounds useful. We also need know the available memory in memcg scope 
in our containers.

>
>>> through memcg stats or usage and proactively try to reduce that usage when
>>> it is growing too large.  The deferred split queues have significantly
>>> increased both memcg usage and rss when they've upgraded kernels.
>>>
>>> How are your applications monitoring how much memory from deferred split
>>> queues can be freed on memory pressure?  Any thoughts on providing it as a
>>> memcg stat?
>> I don't think they have such monitor. I saw rss_huge is abormal in memcg stat
>> even after the application is killed by oom, so I realized the deferred split
>> queue may play a role here.
>>
> Exactly the same in my case :)  We were likely looking at the exact same
> issue at the same time.

Yes, it seems so. :-)

>> The memcg stat doesn't have counters for available memory as global vmstat. It
>> may be better to have such statistics, or extending reclaimable "slab" to
>> shrinkable/reclaimable "memory".
>>
> Have you considered following how NR_ANON_MAPPED is tracked for each pgdat
> and using that as an indicator of when the modify a memcg stat to track
> the amount of memory on a compound page?  I think this would be necessary
> for userspace to know what their true memory usage is.

No, I haven't. Do you mean minus MADV_FREE and deferred split THP from 
NR_ANON_MAPPED? It looks they have been decreased from NR_ANON_MAPPED 
when removing rmap.


