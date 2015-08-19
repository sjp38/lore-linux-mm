Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9533E6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 11:03:00 -0400 (EDT)
Received: by lalv9 with SMTP id v9so4873593lal.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 08:03:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e14si1875565wjq.46.2015.08.19.08.02.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Aug 2015 08:02:58 -0700 (PDT)
Subject: Re: [PATCH] zswap: update docs for runtime-changeable attributes
References: <1439924830-29275-1-git-send-email-ddstreet@ieee.org>
 <55D48C5E.7010004@suse.cz>
 <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D49A9F.7080105@suse.cz>
Date: Wed, 19 Aug 2015 17:02:55 +0200
MIME-Version: 1.0
In-Reply-To: <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 08/19/2015 04:21 PM, Dan Streetman wrote:
> On Wed, Aug 19, 2015 at 10:02 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 08/18/2015 09:07 PM, Dan Streetman wrote:
>>> +pages are freed.  The pool is not preallocated.  By default, a zpool of type
>>> +zbud is created, but it can be selected at boot time by setting the "zpool"
>>> +attribute, e.g. zswap.zpool=zbud.  It can also be changed at runtime using the
>>> +sysfs "zpool" attribute, e.g.
>>> +
>>> +echo zbud > /sys/module/zswap/parameters/zpool
>>
>> What exactly happens if zswap is already being used and has allocated pages in
>> one type of pool, and you're changing it to the other one?
> 
> zswap has a rcu list where each entry contains a specific compressor
> and zpool.  When either the compressor or zpool is changed, a new
> entry is created with a new compressor and pool and put at the front
> of the list.  New pages always use the "current" (first) entry.  Any
> old (unused) entries are freed whenever all the pages they contain are
> removed.
> 
> So when the compressor or zpool is changed, the only thing that
> happens is zswap creates a new compressor and zpool and places it at
> the front of the list, for new pages to use.  No existing pages are
> touched.

Ugh that's madness. Still, a documented madness is better than an undocumented one.

>>
>>> The zsmalloc type zpool has a more
>>> +complex compressed page storage method, and it can achieve greater storage
>>> +densities.  However, zsmalloc does not implement compressed page eviction, so
>>> +once zswap fills it cannot evict the oldest page, it can only reject new pages.
>>
>> I still wonder why anyone would use zsmalloc with zswap given this limitation.
>> It seems only fine for zram which has no real swap as fallback. And even zbud
>> doesn't have any shrinker interface that would react to memory pressure, so
>> there's a possibility of premature OOM... sigh.
> 
> for situations where zswap isn't expected to ever fill up, zsmalloc
> will outperform zbud, since it has higher density.

But then you could just use zram? :)

> i'd argue that neither zbud nor zsmalloc are responsible for reacting
> to memory pressure, they just store the pages.  It's zswap that has to
> limit its size, which it does with max_percent_pool.

Yeah but it's zbud that tracks the aging via LRU and reacts to reclaim requests
from zswap when zswap hits the limit. Zswap could easily add a shrinker that
would relay this requests in response to memory pressure as well. However,
zsmalloc doesn't implement the reclaim, or LRU tracking.

One could also argue that aging should be tracked in zswap, and it would just
tell zbud/zmalloc to drop a specific compressed page. But that wouldn't reliably
translate into freeing of page frames...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
