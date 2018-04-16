Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC6046B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:55:05 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o3-v6so10863636pls.11
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:55:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y190si3746949pfy.75.2018.04.16.12.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 12:55:04 -0700 (PDT)
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
References: <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
 <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
 <20180413151019.GA5660@redhat.com>
 <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz>
 <20180416142703.GA22422@redhat.com>
 <alpine.LRH.2.02.1804161031300.24222@file01.intranet.prod.int.rdu2.redhat.com>
 <20180416144638.GA22484@redhat.com>
 <alpine.LRH.2.02.1804161054410.17807@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1804161018030.9397@nuc-kabylake>
 <alpine.LRH.2.02.1804161123400.17807@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1804161043430.9622@nuc-kabylake>
 <alpine.LRH.2.02.1804161532480.19492@file01.intranet.prod.int.rdu2.redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b0e6ccf6-06ce-e50b-840e-c8d3072382fd@suse.cz>
Date: Mon, 16 Apr 2018 21:53:04 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1804161532480.19492@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, Christopher Lameter <cl@linux.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/16/2018 09:36 PM, Mikulas Patocka wrote:
> 
> 
> On Mon, 16 Apr 2018, Christopher Lameter wrote:
> 
>> On Mon, 16 Apr 2018, Mikulas Patocka wrote:
>>
>>>>
>>>> Or an increase in slab_max_order
>>>
>>> But that will increase it for all slabs (often senselessly - i.e.
>>> kmalloc-4096 would have order 4MB).
>>
>> 4MB? Nope.... That is a power of two slab so no wasted space even with
>> order 0.
> 
> See this email:
> https://www.redhat.com/archives/dm-devel/2018-March/msg00387.html
> 
> If you boot with slub_max_order=10, the kmalloc-8192 cache has 64 pages. 
> So yes, it increases the order of all slab caches (although not up to 
> 4MB).
> 
>> Its not a senseless increase. The more objects you fit into a slab page
>> the higher the performance of the allocator.

It's not universally without a cost. It might increase internal
fragmentation of the slabs, if you end up with lots of 4MB pages
containing just few objects. Thus, waste of memory. You also consume
high-order pages that could be used elsewhere. If you fail to allocate
4MB, then what's the fallback, order-0? I doubt it's "the highest
available order". Thus, a more conservative choice e.g. order-3 will
might succeed more in allocating order-3, while a choice of 4MB will
have many order-0 fallbacks.

>>> I need to increase it just for dm-bufio slabs.
>>
>> If you do this then others will want the same...
> 
> If others need it, they can turn on the flag SLAB_MINIMIZE_WASTE too.

I think it should be possible without a new flag. The slub allocator
could just balance priorities (performance vs memory efficiency) better.
Currently I get the impression that "slub_max_order" is a performance
tunable. Let's add another criteria for selecting an order, that would
try to pick an order to minimize wasted space below e.g. 10% with some
different kind of max order. Pick good defaults, add tunables if you must.

I mean, anyone who's creating a cache for 640KB objects most likely
doesn't want to waste another 384KB by each such object. They shouldn't
have to add a flag to let the slub allocator figure out that using 2MB
pages is the right thing to do here.

Vlastimil

> Mikulas
> 
