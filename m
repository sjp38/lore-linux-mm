Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6616B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 08:05:48 -0400 (EDT)
Received: by oial131 with SMTP id l131so9618125oia.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 05:05:48 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id f14si480625oib.119.2015.06.16.05.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 05:05:47 -0700 (PDT)
Received: by oiha141 with SMTP id a141so9686432oih.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 05:05:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150616105732.2bc37714@redhat.com>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155256.18824.42651.stgit@devil>
	<20150616072806.GC13125@js1304-P5Q-DELUXE>
	<20150616102110.55208fdd@redhat.com>
	<20150616105732.2bc37714@redhat.com>
Date: Tue, 16 Jun 2015 21:05:47 +0900
Message-ID: <CAAmzW4OM-afGBZbWZzcH7O-mivNWvyeKpMVV4Os+i4Xb7GPgmg@mail.gmail.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-Netdev <netdev@vger.kernel.org>, Alexander Duyck <alexander.duyck@gmail.com>

2015-06-16 17:57 GMT+09:00 Jesper Dangaard Brouer <brouer@redhat.com>:
> On Tue, 16 Jun 2015 10:21:10 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>
>>
>> On Tue, 16 Jun 2015 16:28:06 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>>
>> > Is this really better than just calling __kmem_cache_free_bulk()?
>>
>> Yes, as can be seen by cover-letter, but my cover-letter does not seem
>> to have reached mm-list.
>>
>> Measurements for the entire patchset:
>>
>> Bulk - Fallback bulking           - fastpath-bulking
>>    1 -  47 cycles(tsc) 11.921 ns  -  45 cycles(tsc) 11.461 ns   improved  4.3%
>>    2 -  46 cycles(tsc) 11.649 ns  -  28 cycles(tsc)  7.023 ns   improved 39.1%
>>    3 -  46 cycles(tsc) 11.550 ns  -  22 cycles(tsc)  5.671 ns   improved 52.2%
>>    4 -  45 cycles(tsc) 11.398 ns  -  19 cycles(tsc)  4.967 ns   improved 57.8%
>>    8 -  45 cycles(tsc) 11.303 ns  -  17 cycles(tsc)  4.298 ns   improved 62.2%
>>   16 -  44 cycles(tsc) 11.221 ns  -  17 cycles(tsc)  4.423 ns   improved 61.4%
>>   30 -  75 cycles(tsc) 18.894 ns  -  57 cycles(tsc) 14.497 ns   improved 24.0%
>>   32 -  73 cycles(tsc) 18.491 ns  -  56 cycles(tsc) 14.227 ns   improved 23.3%
>>   34 -  75 cycles(tsc) 18.962 ns  -  58 cycles(tsc) 14.638 ns   improved 22.7%
>>   48 -  80 cycles(tsc) 20.049 ns  -  64 cycles(tsc) 16.247 ns   improved 20.0%
>>   64 -  87 cycles(tsc) 21.929 ns  -  74 cycles(tsc) 18.598 ns   improved 14.9%
>>  128 -  98 cycles(tsc) 24.511 ns  -  89 cycles(tsc) 22.295 ns   improved  9.2%
>>  158 - 101 cycles(tsc) 25.389 ns  -  93 cycles(tsc) 23.390 ns   improved  7.9%
>>  250 - 104 cycles(tsc) 26.170 ns  - 100 cycles(tsc) 25.112 ns   improved  3.8%
>>
>> I'll do a compare against the previous patch, and post the results.
>
> Compare against previous patch:
>
> Run:   previous-patch            - this patch
>   1 -   49 cycles(tsc) 12.378 ns -  43 cycles(tsc) 10.775 ns  improved 12.2%
>   2 -   37 cycles(tsc)  9.297 ns -  26 cycles(tsc)  6.652 ns  improved 29.7%
>   3 -   33 cycles(tsc)  8.348 ns -  21 cycles(tsc)  5.347 ns  improved 36.4%
>   4 -   31 cycles(tsc)  7.930 ns -  18 cycles(tsc)  4.669 ns  improved 41.9%
>   8 -   30 cycles(tsc)  7.693 ns -  17 cycles(tsc)  4.404 ns  improved 43.3%
>  16 -   32 cycles(tsc)  8.059 ns -  17 cycles(tsc)  4.493 ns  improved 46.9%

So, in your test, most of objects may come from one or two slabs and your
algorithm is well optimized for this case. But, is this workload normal case?
If most of objects comes from many different slabs, bulk free API does
enabling/disabling interrupt very much so I guess it work worse than
just calling __kmem_cache_free_bulk(). Could you test this case?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
