Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 86ABB6B0259
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:12:47 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so8047519igc.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:12:47 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id c6si1728375pbu.132.2015.09.14.23.12.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 23:12:46 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so166528735pad.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:12:46 -0700 (PDT)
Date: Tue, 15 Sep 2015 15:13:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
Message-ID: <20150915061349.GA16485@bbox>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: sergey.senozhatsky@gmail.com, ddstreet@ieee.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>

Hello Vitaly,

It seems you sent a mail with gmail web or something which didn't use
plain-text. ;-). I will add newline manually.
Please send a mail with plain-text in future.

On Mon, Sep 14, 2015 at 03:49:01PM +0200, Vitaly Wool wrote:
> While using ZRAM on a small RAM footprint devices, together with KSM,

KSM? Is there any reason you mentioned *KSM* in this context?
IOW, if you don't use KSM, you couldn't see a problem?

> I ran into several occasions when moving pages from compressed swap back
> into the "normal" part of RAM caused significant latencies in system operation.

What kernel version did you use? Did you enable CMA? ION?
What was major factor for the latencies?

Decompress? zsmalloc-compaction overhead? rmap overheads?
compaction overheads?
There are several potential culprits.
It would be very helpful if you provide some numbers(perf will help you).

> By using zbud I lose in compression ratio but gain in determinism,
> lower latencies and lower fragmentation, so in the coming patches
> I tried to generalize what I've done to enable zbud for zram so far.

Before that, I'd like to know what is root cause.
>From my side, I had an similar experience.
At that time, problem was that *compaction* which triggered to reclaim
lots of page cache pages. The reason compaction triggered a lot was
fragmentation caused by zsmalloc, GPU and high-order allocation
request by SLUB and somethings(ex, ION, fork).

Recently, Joonsoo fixed SLUB side.
http://marc.info/?l=linux-kernel&m=143891343223853&w=2

And we added zram-auto-compaction recently so zram try to compact
objects to reduce memory usage. It might be helpful for fragment
problem as side effect but please keep it mind that it would be opposite.
Currently, zram-auto-compaction is not aware of virtual memory compaction
so as worst case, zsmalloc can spread out pinned object into movable
pageblocks via zsmalloc-compaction.
Gioh and I try to solve the issue with below patches but is pending now
by other urgent works.
https://lwn.net/Articles/650917/
https://lkml.org/lkml/2015/8/10/90

In summary, we need to clarify what's the root cause before diving into
code and hiding it.

Thanks.

> 
> -- 
> Vitaly Wool <vitalywool@gmail.com>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
