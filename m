Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 522A66B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 19:49:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id r2-v6so6916472pgp.3
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:49:39 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id b39-v6si2827076pla.26.2018.07.20.16.49.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 16:49:38 -0700 (PDT)
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org>
 <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com>
 <3238b5d2-fd89-a6be-0382-027a24a4d3ad@linux.alibaba.com>
 <alpine.DEB.2.21.1807201401390.231119@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b258c765-ad71-0dd4-d420-75139c55e7c7@linux.alibaba.com>
Date: Fri, 20 Jul 2018 16:49:30 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807201401390.231119@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, hughd@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/20/18 2:05 PM, David Rientjes wrote:
> On Fri, 20 Jul 2018, Yang Shi wrote:
>
>>> We disable the huge zero page through this interface, there were issues
>>> related to the huge zero page shrinker (probably best to never free a
>>> per-node huge zero page after allocated) and CVE-2017-1000405 for huge
>>> dirty COW.
>> Thanks for the information. It looks the CVE has been resolved by commit
>> a8f97366452ed491d13cf1e44241bc0b5740b1f0 ("mm, thp: Do not make page table
>> dirty unconditionally in touch_p[mu]d()"), which is in 4.15 already.
>>
> For users who run kernels earlier than 4.15 they may choose to mitigate
> the CVE by using this tunable.  It's not something we permanently need to
> have, but it may likely be too early.

Yes, it might be good to keep it around for a while.

>
>> What was the shrinker related issue? I'm supposed it has been resolved, right?
>>
> The huge zero page can be reclaimed under memory pressure and, if it is,
> it is attempted to be allocted again with gfp flags that attempt memory
> compaction that can become expensive.  If we are constantly under memory
> pressure, it gets freed and reallocated millions of times always trying to
> compact memory both directly and by kicking kcompactd in the background.

Even though we don't use huge zero page, we may also run into the 
similar issue under memory pressure. Just save the cost of calling huge 
zero page shrinker, but actually its cost sound not high.

>
> It likely should also be per node.
