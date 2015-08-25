Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 97F726B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 02:22:05 -0400 (EDT)
Received: by wijp15 with SMTP id p15so4722630wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 23:22:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si37035173wju.0.2015.08.24.23.22.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 23:22:04 -0700 (PDT)
Subject: Re: [PATCH] zswap: update docs for runtime-changeable attributes
References: <1439924830-29275-1-git-send-email-ddstreet@ieee.org>
 <55D48C5E.7010004@suse.cz>
 <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
 <55D49A9F.7080105@suse.cz>
 <CALZtONDfPBTJNjf+RZxFWtE_qX_dTaxX5c2tx9_D7wuuvju-CQ@mail.gmail.com>
 <20150825042224.GB412@swordfish>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC098B.8080409@suse.cz>
Date: Tue, 25 Aug 2015 08:22:03 +0200
MIME-Version: 1.0
In-Reply-To: <20150825042224.GB412@swordfish>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 25.8.2015 6:22, Sergey Senozhatsky wrote:
>>>> i'd argue that neither zbud nor zsmalloc are responsible for reacting
>>>> to memory pressure, they just store the pages.  It's zswap that has to
>>>> limit its size, which it does with max_percent_pool.
>>>
>>> Yeah but it's zbud that tracks the aging via LRU and reacts to reclaim requests
>>> from zswap when zswap hits the limit. Zswap could easily add a shrinker that
>>> would relay this requests in response to memory pressure as well. However,
>>> zsmalloc doesn't implement the reclaim, or LRU tracking.
>>
>> I wrote a patch for zsmalloc reclaim a while ago:
>>
>> https://lwn.net/Articles/611713/
>>
>> however it didn't make it in, due to the lack of zsmalloc LRU, or any
>> proven benefit to zsmalloc reclaim.
>>
>> It's not really possible to add LRU to zsmalloc, by the nature of its
>> design, using the struct page fields directly; there's no extra field
>> to use as a lru entry.
> 
> Just for information, zsmalloc now registers shrinker callbacks
> 
> https://lkml.org/lkml/2015/7/8/497

Yeah but that's just for compaction, not freeing. I think that ideally zswap
should track the LRU on the level of pages it receives as input, and then just
tell zswap/zbud to free them. Then zswap would use its compaction to make sure
that the reclaim results in actual freeing of page frames. Zbud could re-pair
the orphaned half-pages to the same effect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
