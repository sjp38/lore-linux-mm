Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4EAF76B0253
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 11:56:51 -0400 (EDT)
Received: by igfj19 with SMTP id j19so9453524igf.1
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 08:56:51 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id h16si922370ioh.200.2015.08.19.08.56.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 08:56:50 -0700 (PDT)
Received: by iodv127 with SMTP id v127so13982489iod.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 08:56:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55D49A9F.7080105@suse.cz>
References: <1439924830-29275-1-git-send-email-ddstreet@ieee.org>
 <55D48C5E.7010004@suse.cz> <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
 <55D49A9F.7080105@suse.cz>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 19 Aug 2015 11:56:10 -0400
Message-ID: <CALZtONDfPBTJNjf+RZxFWtE_qX_dTaxX5c2tx9_D7wuuvju-CQ@mail.gmail.com>
Subject: Re: [PATCH] zswap: update docs for runtime-changeable attributes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jonathan Corbet <corbet@lwn.net>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Aug 19, 2015 at 11:02 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 08/19/2015 04:21 PM, Dan Streetman wrote:
>> On Wed, Aug 19, 2015 at 10:02 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>> On 08/18/2015 09:07 PM, Dan Streetman wrote:
>>>> +pages are freed.  The pool is not preallocated.  By default, a zpool of type
>>>> +zbud is created, but it can be selected at boot time by setting the "zpool"
>>>> +attribute, e.g. zswap.zpool=zbud.  It can also be changed at runtime using the
>>>> +sysfs "zpool" attribute, e.g.
>>>> +
>>>> +echo zbud > /sys/module/zswap/parameters/zpool
>>>
>>> What exactly happens if zswap is already being used and has allocated pages in
>>> one type of pool, and you're changing it to the other one?
>>
>> zswap has a rcu list where each entry contains a specific compressor
>> and zpool.  When either the compressor or zpool is changed, a new
>> entry is created with a new compressor and pool and put at the front
>> of the list.  New pages always use the "current" (first) entry.  Any
>> old (unused) entries are freed whenever all the pages they contain are
>> removed.
>>
>> So when the compressor or zpool is changed, the only thing that
>> happens is zswap creates a new compressor and zpool and places it at
>> the front of the list, for new pages to use.  No existing pages are
>> touched.
>
> Ugh that's madness. Still, a documented madness is better than an undocumented one.

heh, i'm not sure why it's madness, the alternative of
uncompressing/recompressing all pages into the new zpool and/or with
the new compressor seems much worse ;-)

>
>>>
>>>> The zsmalloc type zpool has a more
>>>> +complex compressed page storage method, and it can achieve greater storage
>>>> +densities.  However, zsmalloc does not implement compressed page eviction, so
>>>> +once zswap fills it cannot evict the oldest page, it can only reject new pages.
>>>
>>> I still wonder why anyone would use zsmalloc with zswap given this limitation.
>>> It seems only fine for zram which has no real swap as fallback. And even zbud
>>> doesn't have any shrinker interface that would react to memory pressure, so
>>> there's a possibility of premature OOM... sigh.
>>
>> for situations where zswap isn't expected to ever fill up, zsmalloc
>> will outperform zbud, since it has higher density.
>
> But then you could just use zram? :)

well not *expected* to fill up doesn't mean it *won't* fill up :)

>
>> i'd argue that neither zbud nor zsmalloc are responsible for reacting
>> to memory pressure, they just store the pages.  It's zswap that has to
>> limit its size, which it does with max_percent_pool.
>
> Yeah but it's zbud that tracks the aging via LRU and reacts to reclaim requests
> from zswap when zswap hits the limit. Zswap could easily add a shrinker that
> would relay this requests in response to memory pressure as well. However,
> zsmalloc doesn't implement the reclaim, or LRU tracking.

I wrote a patch for zsmalloc reclaim a while ago:

https://lwn.net/Articles/611713/

however it didn't make it in, due to the lack of zsmalloc LRU, or any
proven benefit to zsmalloc reclaim.

It's not really possible to add LRU to zsmalloc, by the nature of its
design, using the struct page fields directly; there's no extra field
to use as a lru entry.


>
> One could also argue that aging should be tracked in zswap, and it would just
> tell zbud/zmalloc to drop a specific compressed page. But that wouldn't reliably
> translate into freeing of page frames...
>

Yep, that was Minchan's suggestion as well, which I agree with,
although that would also require a new api function to free the entire
page that a single compressed page is in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
