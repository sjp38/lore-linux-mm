Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 573096B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:29:29 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id w62so4179512wes.12
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:29:28 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id hn8si6207743wib.43.2014.09.15.07.29.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 07:29:28 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id z12so4072045wgg.16
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:29:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140915000058.GE2160@bbox>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
 <20140912054640.GB2160@bbox> <CALZtONAzfUaXpxPc83KA6edB21uptWWGZkWZZa5DTFi=CMpgXA@mail.gmail.com>
 <20140915000058.GE2160@bbox>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 15 Sep 2014 10:29:07 -0400
Message-ID: <CALZtONA7Pr_JXWDHGkPOdWAYwMs2Q-8b3MVnS4fuOAh-jyDCVA@mail.gmail.com>
Subject: Re: [PATCH 00/10] implement zsmalloc shrinking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Sun, Sep 14, 2014 at 8:00 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Fri, Sep 12, 2014 at 01:05:11PM -0400, Dan Streetman wrote:
>> On Fri, Sep 12, 2014 at 1:46 AM, Minchan Kim <minchan@kernel.org> wrote:
>> > On Thu, Sep 11, 2014 at 04:53:51PM -0400, Dan Streetman wrote:
>> >> Now that zswap can use zsmalloc as a storage pool via zpool, it will
>> >> try to shrink its zsmalloc zs_pool once it reaches its max_pool_percent
>> >> limit.  These patches implement zsmalloc shrinking.  The way the pool is
>> >> shrunk is by finding a zspage and reclaiming it, by evicting each of its
>> >> objects that is in use.
>> >>
>> >> Without these patches zswap, and any other future user of zpool/zsmalloc
>> >> that attempts to shrink the zpool/zs_pool, will only get errors and will
>> >> be unable to shrink its zpool/zs_pool.  With the ability to shrink, zswap
>> >> can keep the most recent compressed pages in memory.
>> >>
>> >> Note that the design of zsmalloc makes it impossible to actually find the
>> >> LRU zspage, so each class and fullness group is searched in a round-robin
>> >> method to find the next zspage to reclaim.  Each fullness group orders its
>> >> zspages in LRU order, so the oldest zspage is used for each fullness group.
>> >>
>> >
>> > 1. Pz, Cc Mel who was strong against zswap with zsmalloc.
>> > 2. I don't think LRU stuff should be in allocator layer. Exp, it's really
>> >    hard to work well in zsmalloc design.
>>
>> I didn't add any LRU - the existing fullness group LRU ordering is
>> already there.  And yes, the zsmalloc design prevents any real LRU
>
> I don't think It's not LRU for reclaiming but just simple linked list for
> finding free slot.

yes, but it does happen to be in LRU order.  However the LRU ordering
here isn't as important as being able to free the least amount of
pages in order to shrink the zspool.

>
>> ordering, beyond per-fullness-group LRU ordering.
>
> Yes.
>
>>
>> > 3. If you want to add another writeback, make zswap writeback sane first.
>> >    current implemenation(zswap store -> zbud reclaim -> zswap writeback,
>> >    even) is really ugly.
>>
>> why what's wrong with that?  how else can zbud/zsmalloc evict stored objects?
>
> You can refer Mel's suggestion for zswap/zsmalloc and writeback problem.

As far as I can tell Mel's complaint was with zswap synchronously
shrinking the pool one-page-at-a-time during store(), which will block
anything trying to write a swap page - although Mel correct me if I'm
minunderstanding it.

That's not relevant for the reclaim->evict portion of zbud and
zsmalloc.  Once zbud or zsmalloc have been asked to shrink their size,
they must reclaim a zbud page or zspage, respectively, and to do that
they have to clear out any used handles from it.  Asking the handle
owner (zswap in this case) to evict it is the only option I can see.
And I don't see what is wrong with that, from the perspective of
zbud/zsmalloc.

Updating zswap to pre-emptively shrink its pool before filling up is
something that could be done, but would be entirely in zswap, and
doesn't affect how zbud or zsmalloc work w.r.t shrinking, reclaim, or
evict.  It's not related to adding shrinking to zsmalloc.

>
> http://www.spinics.net/lists/linux-mm/msg61601.html
> http://lkml.iu.edu//hypermail/linux/kernel/1304.1/04334.html
>
> I think LRU/writeback should be upper layer, not allocator itself.
> Please, don't force every allocator to implement it for only zswap.

zswap could maintain an LRU list, but what it can't do it know which
of its stored pages are grouped together by the allocator.  So freeing
pages in a strictly LRU order would almost certainly 1) require
evicting many more pages than the allocator would have just to shrink
the pool by 1 page, and 2) increase the allocator's fragmentation,
possibly quite badly depending on how much shrinking is needed.

At the point when zswap needs to start shrinking its pool, there is
clearly a lot of memory pressure, and it doesn't make sense to evict
more pages than it needs to, nor does it make sense to increase
fragmentation in the storage pool, and waste memory.

>
>>
>> > 4. Don't make zsmalloc complicated without any data(benefit, regression)
>> >    I will never ack if you don't give any number and real usecase.
>>
>> ok, i'll run performance tests then, but let me know if you see any
>> technical problems with any of the patches before then.
>>
>> thanks!
>>
>> >
>> >> ---
>> >>
>> >> This patch set applies to linux-next.
>> >>
>> >> Dan Streetman (10):
>> >>   zsmalloc: fix init_zspage free obj linking
>> >>   zsmalloc: add fullness group list for ZS_FULL zspages
>> >>   zsmalloc: always update lru ordering of each zspage
>> >>   zsmalloc: move zspage obj freeing to separate function
>> >>   zsmalloc: add atomic index to find zspage to reclaim
>> >>   zsmalloc: add zs_ops to zs_pool
>> >>   zsmalloc: add obj_handle_is_free()
>> >>   zsmalloc: add reclaim_zspage()
>> >>   zsmalloc: add zs_shrink()
>> >>   zsmalloc: implement zs_zpool_shrink() with zs_shrink()
>> >>
>> >>  drivers/block/zram/zram_drv.c |   2 +-
>> >>  include/linux/zsmalloc.h      |   7 +-
>> >>  mm/zsmalloc.c                 | 314 +++++++++++++++++++++++++++++++++++++-----
>> >>  3 files changed, 290 insertions(+), 33 deletions(-)
>> >>
>> >> --
>> >> 1.8.3.1
>> >>
>> >> --
>> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >> the body to majordomo@kvack.org.  For more info on Linux MM,
>> >> see: http://www.linux-mm.org/ .
>> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>> > --
>> > Kind regards,
>> > Minchan Kim
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim
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
