Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C981AC04AB6
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:34:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6694721721
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:34:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6694721721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B46CB6B0279; Tue, 28 May 2019 22:34:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF7566B027C; Tue, 28 May 2019 22:34:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0CBA6B027F; Tue, 28 May 2019 22:34:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65C226B0279
	for <linux-mm@kvack.org>; Tue, 28 May 2019 22:34:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d22so666840pgg.2
        for <linux-mm@kvack.org>; Tue, 28 May 2019 19:34:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=V32LT4utKo0TDLbAK6fqAj6cLnWicD8aRnm9gNomHVM=;
        b=ufeppDYudSXzhzua2TMmfFcwjueeyZna2PZpPHcdTNWVR6L5KLeI23K+aCCPLPSZ9u
         k6KF7IAP4KLNnGi/a2oVdCmMifoZFA7BJltb2FxjbjnRVm8ihwsQpRE6Ul9dnVWwUlBH
         YN561uQPNL8xRJhZiiUUmhWn+cCvRK4/4pfwra0v2xgqNYDvMm0dMZkhOY+UwT/Ffiad
         q3dNcE4DY1m47g8P09uIdO3UbUdTN+puoR2IbuAbHhY0Pezsb6AVdpknsYCFZ3tHK4lv
         otzVt/AxfYGGP/GF9mdiR90pjB0UHfdsMGPASVWlIz5mYGiK4lrVBD7yx1lXPqfrZ1Gg
         gnFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW/2QFmQz7qrxhYdSR4frodLxVjZwlHlGSnqe8q+CgvY0e7PnPl
	8vPWOcVa3quFdAIUyOlbijUTYg2qRekQiLnFdyHqFeMa2rqEWY1D9ZVBuB3GXfFNBiUwwUJBnr5
	gGCSSiSv2tEPdty0z7zHgtvPUONEQM6lBfNzn7cyBQi7W4sKxd8B/ri81w6MqCZpw9w==
X-Received: by 2002:a63:2d0:: with SMTP id 199mr77958303pgc.188.1559097280964;
        Tue, 28 May 2019 19:34:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrQIdprZm+rWaW9zbL8rEhE4SimCleMu+mFxPOiUuclw9C3c32SrLdKW/DRRqOd8JYeTAX
X-Received: by 2002:a63:2d0:: with SMTP id 199mr77958267pgc.188.1559097280092;
        Tue, 28 May 2019 19:34:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559097280; cv=none;
        d=google.com; s=arc-20160816;
        b=0WpDHw6Rz3biC6cXWfyKGy3lqkEoXhX7I+/weiwCGmqe/j1bC8pJuqaO8gL74fMusy
         y2EXsODbUgYlMzchDKa9fp1vNz1GROFrrBo3TUeF6lWIButh6QjXXl9Xo36m0cVt7nVA
         jVHvbwa/+WGxKyY9FXWwIpbn3qiqrAvqIx5ME/BEuDj3rVK12xdgLW+mxRRoEC9ilH11
         IfGSR7Wyxe+O3m+Ys5iIcrVZl9Vh49P15Wpd9v7oN3Vqb5h+YNnAtWyz6chSEvlZa7un
         bDKC76PuxCD/kCZ68NnQBUC+LCqIsN20i7/TjkqUnJadtnCL1/ynyUD/eadFFfx67I6b
         /UXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=V32LT4utKo0TDLbAK6fqAj6cLnWicD8aRnm9gNomHVM=;
        b=c4icf2T98C8nBdNXbkxgClGqkwPowTBmh9lK0VDeWzWhg5GLEExFnFwZShqiHIbNM4
         /4rIWaoy+Ylkmj6bnd48FR1Z4rmi2xMSpMH0Y9325Vh5XlxboZchtE9G+f0ly/bYnZvZ
         xig4PiZ3cRB6JCGxcdHarK+9IzFWeiclOUt+bDcvhIQzXAwS1w6LVjcwP/ecFnkQYVWQ
         t7TWhdKjSs8edmayFE0opCYn4I3hQ2KAPba4hJW32rwvmtNA+V03ksDNYm71HBbLNk3N
         acJDQYo5yMXV65DKYiRZkREvdBNviZKk2RRlapoIX29wsOqEp0efA6g9VbkufmZ98Agh
         2y3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id x19si5294402pjq.79.2019.05.28.19.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 19:34:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R381e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TSvOYQ4_1559097264;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSvOYQ4_1559097264)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 29 May 2019 10:34:25 +0800
Subject: Re: [RFC PATCH 0/3] Make deferred split shrinker memcg aware
To: David Rientjes <rientjes@google.com>
Cc: ktkhai@virtuozzo.com, hannes@cmpxchg.org, mhocko@suse.com,
 kirill.shutemov@linux.intel.com, hughd@google.com, shakeelb@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.DEB.2.21.1905281817090.86034@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <2e23bd8c-6120-5a86-9e9e-ab43b02ce150@linux.alibaba.com>
Date: Wed, 29 May 2019 10:34:24 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1905281817090.86034@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/29/19 9:22 AM, David Rientjes wrote:
> On Tue, 28 May 2019, Yang Shi wrote:
>
>> I got some reports from our internal application team about memcg OOM.
>> Even though the application has been killed by oom killer, there are
>> still a lot THPs reside, page reclaim doesn't reclaim them at all.
>>
>> Some investigation shows they are on deferred split queue, memcg direct
>> reclaim can't shrink them since THP deferred split shrinker is not memcg
>> aware, this may cause premature OOM in memcg.  The issue can be
>> reproduced easily by the below test:
>>
> Right, we've also encountered this.  I talked to Kirill about it a week or
> so ago where the suggestion was to split all compound pages on the
> deferred split queues under the presence of even memory pressure.
>
> That breaks cgroup isolation and perhaps unfairly penalizes workloads that
> are running attached to other memcg hierarchies that are not under
> pressure because their compound pages are now split as a side effect.
> There is a benefit to keeping these compound pages around while not under
> memory pressure if all pages are subsequently mapped again.

Yes, I do agree. I tried other approaches too, it sounds making deferred 
split queue per memcg is the optimal one.

>
>> $ cgcreate -g memory:thp
>> $ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
>> $ cgexec -g memory:thp ./transhuge-stress 4000
>>
>> transhuge-stress comes from kernel selftest.
>>
>> It is easy to hit OOM, but there are still a lot THP on the deferred split
>> queue, memcg direct reclaim can't touch them since the deferred split
>> shrinker is not memcg aware.
>>
> Yes, we have seen this on at least 4.15 as well.
>
>> Convert deferred split shrinker memcg aware by introducing per memcg deferred
>> split queue.  The THP should be on either per node or per memcg deferred
>> split queue if it belongs to a memcg.  When the page is immigrated to the
>> other memcg, it will be immigrated to the target memcg's deferred split queue
>> too.
>>
>> And, move deleting THP from deferred split queue in page free before memcg
>> uncharge so that the page's memcg information is available.
>>
>> Reuse the second tail page's deferred_list for per memcg list since the same
>> THP can't be on multiple deferred split queues at the same time.
>>
>> Remove THP specific destructor since it is not used anymore with memcg aware
>> THP shrinker (Please see the commit log of patch 2/3 for the details).
>>
>> Make deferred split shrinker not depend on memcg kmem since it is not slab.
>> It doesn't make sense to not shrink THP even though memcg kmem is disabled.
>>
>> With the above change the test demonstrated above doesn't trigger OOM anymore
>> even though with cgroup.memory=nokmem.
>>
> I'm curious if your internal applications team is also asking for
> statistics on how much memory can be freed if the deferred split queues
> can be shrunk?  We have applications that monitor their own memory usage

No, but this reminds me. The THPs on deferred split queue should be 
accounted into available memory too.

> through memcg stats or usage and proactively try to reduce that usage when
> it is growing too large.  The deferred split queues have significantly
> increased both memcg usage and rss when they've upgraded kernels.
>
> How are your applications monitoring how much memory from deferred split
> queues can be freed on memory pressure?  Any thoughts on providing it as a
> memcg stat?

I don't think they have such monitor. I saw rss_huge is abormal in memcg 
stat even after the application is killed by oom, so I realized the 
deferred split queue may play a role here.

The memcg stat doesn't have counters for available memory as global 
vmstat. It may be better to have such statistics, or extending 
reclaimable "slab" to shrinkable/reclaimable "memory".

>
> Thanks!

