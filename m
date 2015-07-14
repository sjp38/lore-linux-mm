Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id ED94B6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 20:55:10 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so234575410pdb.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 17:55:10 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id oy6si31062216pdb.22.2015.07.13.17.55.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 17:55:10 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so215960071pac.2
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 17:55:09 -0700 (PDT)
Date: Tue, 14 Jul 2015 09:55:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] zsmalloc: small compaction improvements
Message-ID: <20150714005459.GA12786@blaptop.AC68U>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150713233602.GA31822@blaptop.AC68U>
 <20150714003132.GA2463@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150714003132.GA2463@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 14, 2015 at 09:31:32AM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (07/14/15 08:36), Minchan Kim wrote:
> [..]
> > >       if [ `cat /sys/block/zram<id>/compact` -gt 10 ]; then
> > >           echo 1 > /sys/block/zram<id>/compact;
> > >       fi
> > > 
> > > Up until now user space could not tell whether compaction
> > > will result in any gain.
> > 
> > First of all, thanks for the looking this.
> > 
> > Question:
> > 
> > What is motivation?
> > IOW, did you see big overhead by user-triggered compaction? so,
> > do you want to throttle it by userspace?
> 
> It depends on 'big overhead' definition, of course. We don't care
> that much when compaction is issued by the shrinker, because things
> are getting bad and we can sacrifice performance. But user triggered
> compaction on a I/O pressured device can needlessly slow things down,
> especially now, when we drain ALMOST_FULL classes.

You mean performance overhead by additional alloc_pages?
If so, you mean ALMOST_EMPTY|ALMOST_FULL, not only ALMOST_FULL?

So, it's performance enhance patch?
Please give the some number to justify patchset.

> 
> /sys/block/zram<id>/compact is a black box. We provide it, we don't
> throttle it in the kernel, and user space is absolutely clueless when
> it invokes compaction. From some remote (or alternative) point of

But we have zs_can_compact so it can effectively skip the class if it
is not proper class.

> view compaction can be seen as "zsmalloc's cache flush" (unused objects
> make write path quicker - no zspage allocation needed) and it won't
> hurt to give user space some numbers so it can decide if the whole
> thing is worth it (that decision is, once again, I/O pattern and
> setup specific -- some users may be interested in compaction only
> if it will reduce zsmalloc's memory consumption by, say, 15%).

Again, your claim is performace so I need number.
If it's really horrible, I guess below interface makes user handy
without peeking nr_can_compact ad doing compact.

        /* Tell zram to compact if fragment ration is higher 15% */
        echo 15% > /sys/block/zram0/compact
        or
        echo 15% > /sys/block/zram/compact_condition

Anyway, we need a number before starting discussion.

Thanks.
> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
