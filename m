Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C24836B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:50:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q12-v6so1104710pgp.6
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:50:16 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id e22-v6si8830318pfi.184.2018.07.23.14.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 14:50:15 -0700 (PDT)
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org>
 <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com>
 <3238b5d2-fd89-a6be-0382-027a24a4d3ad@linux.alibaba.com>
 <alpine.DEB.2.21.1807201401390.231119@chino.kir.corp.google.com>
 <20180722035156.GA12125@bombadil.infradead.org>
 <alpine.DEB.2.21.1807231323460.105582@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1807231427550.103523@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <7d96258c-2973-2df5-08d4-828875058be1@linux.alibaba.com>
Date: Mon, 23 Jul 2018 14:49:34 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807231427550.103523@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, hughd@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/23/18 2:33 PM, David Rientjes wrote:
> On Mon, 23 Jul 2018, David Rientjes wrote:
>
>>>> The huge zero page can be reclaimed under memory pressure and, if it is,
>>>> it is attempted to be allocted again with gfp flags that attempt memory
>>>> compaction that can become expensive.  If we are constantly under memory
>>>> pressure, it gets freed and reallocated millions of times always trying to
>>>> compact memory both directly and by kicking kcompactd in the background.
>>>>
>>>> It likely should also be per node.
>>> Have you benchmarked making the non-huge zero page per-node?
>>>
>> Not since we disable it :)  I will, though.  The more concerning issue for
>> us, modulo CVE-2017-1000405, is the cpu cost of constantly directly
>> compacting memory for allocating the hzp in real time after it has been
>> reclaimed.  We've observed this happening tens or hundreds of thousands
>> of times on some systems.  It will be 2MB per node on x86 if the data
>> suggests we should make it NUMA aware, I don't think the cost is too high
>> to leave it persistently available even under memory pressure if
>> use_zero_page is enabled.
>>
> Measuring access latency to 4GB of memory on Naples I observe ~6.7%
> slower access latency intrasocket and ~14% slower intersocket.
>
> use_zero_page is currently a simple thp flag, meaning it rejects writes
> where val != !!val, so perhaps it would be best to overload it with
> additional options?  I can imagine 0x2 defining persistent allocation so
> that the hzp is not freed when the refcount goes to 0 and 0x4 defining if
> the hzp should be per node.  Implementing persistent allocation fixes our
> concern with it, so I'd like to start there.  Comments?

Sounds worth trying to me :-)A  It might be worth making it persistent by 
default. Keeping 2MB memory unreclaimable sounds not harmful for the use 
case which prefer to use THP.
