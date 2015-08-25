Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id CA26B6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 00:21:44 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so9759432pad.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 21:21:44 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id qp7si30911026pbc.93.2015.08.24.21.21.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 21:21:43 -0700 (PDT)
Received: by pacti10 with SMTP id ti10so40013608pac.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 21:21:43 -0700 (PDT)
Date: Tue, 25 Aug 2015 13:22:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zswap: update docs for runtime-changeable attributes
Message-ID: <20150825042224.GB412@swordfish>
References: <1439924830-29275-1-git-send-email-ddstreet@ieee.org>
 <55D48C5E.7010004@suse.cz>
 <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
 <55D49A9F.7080105@suse.cz>
 <CALZtONDfPBTJNjf+RZxFWtE_qX_dTaxX5c2tx9_D7wuuvju-CQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONDfPBTJNjf+RZxFWtE_qX_dTaxX5c2tx9_D7wuuvju-CQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On (08/19/15 11:56), Dan Streetman wrote:
[..]
> > Ugh that's madness. Still, a documented madness is better than an undocumented one.
> 
> heh, i'm not sure why it's madness, the alternative of
> uncompressing/recompressing all pages into the new zpool and/or with
> the new compressor seems much worse ;-)
> 

Well, I sort of still think that 'change compressor and reboot' is OK. 5cents.

> >
> >>>
> >>>> The zsmalloc type zpool has a more
> >>>> +complex compressed page storage method, and it can achieve greater storage
> >>>> +densities.  However, zsmalloc does not implement compressed page eviction, so
> >>>> +once zswap fills it cannot evict the oldest page, it can only reject new pages.
> >>>
> >>> I still wonder why anyone would use zsmalloc with zswap given this limitation.
> >>> It seems only fine for zram which has no real swap as fallback. And even zbud
> >>> doesn't have any shrinker interface that would react to memory pressure, so
> >>> there's a possibility of premature OOM... sigh.
> >>
> >> for situations where zswap isn't expected to ever fill up, zsmalloc
> >> will outperform zbud, since it has higher density.
> >
> > But then you could just use zram? :)
> 
> well not *expected* to fill up doesn't mean it *won't* fill up :)
> 
> >
> >> i'd argue that neither zbud nor zsmalloc are responsible for reacting
> >> to memory pressure, they just store the pages.  It's zswap that has to
> >> limit its size, which it does with max_percent_pool.
> >
> > Yeah but it's zbud that tracks the aging via LRU and reacts to reclaim requests
> > from zswap when zswap hits the limit. Zswap could easily add a shrinker that
> > would relay this requests in response to memory pressure as well. However,
> > zsmalloc doesn't implement the reclaim, or LRU tracking.
> 
> I wrote a patch for zsmalloc reclaim a while ago:
> 
> https://lwn.net/Articles/611713/
> 
> however it didn't make it in, due to the lack of zsmalloc LRU, or any
> proven benefit to zsmalloc reclaim.
> 
> It's not really possible to add LRU to zsmalloc, by the nature of its
> design, using the struct page fields directly; there's no extra field
> to use as a lru entry.

Just for information, zsmalloc now registers shrinker callbacks

https://lkml.org/lkml/2015/7/8/497

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
