Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 686B06B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 20:00:53 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so5024425pdb.28
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 17:00:52 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id rw9si20088538pab.37.2014.09.14.17.00.49
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 17:00:51 -0700 (PDT)
Date: Mon, 15 Sep 2014 09:00:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 00/10] implement zsmalloc shrinking
Message-ID: <20140915000058.GE2160@bbox>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
 <20140912054640.GB2160@bbox>
 <CALZtONAzfUaXpxPc83KA6edB21uptWWGZkWZZa5DTFi=CMpgXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONAzfUaXpxPc83KA6edB21uptWWGZkWZZa5DTFi=CMpgXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, Sep 12, 2014 at 01:05:11PM -0400, Dan Streetman wrote:
> On Fri, Sep 12, 2014 at 1:46 AM, Minchan Kim <minchan@kernel.org> wrote:
> > On Thu, Sep 11, 2014 at 04:53:51PM -0400, Dan Streetman wrote:
> >> Now that zswap can use zsmalloc as a storage pool via zpool, it will
> >> try to shrink its zsmalloc zs_pool once it reaches its max_pool_percent
> >> limit.  These patches implement zsmalloc shrinking.  The way the pool is
> >> shrunk is by finding a zspage and reclaiming it, by evicting each of its
> >> objects that is in use.
> >>
> >> Without these patches zswap, and any other future user of zpool/zsmalloc
> >> that attempts to shrink the zpool/zs_pool, will only get errors and will
> >> be unable to shrink its zpool/zs_pool.  With the ability to shrink, zswap
> >> can keep the most recent compressed pages in memory.
> >>
> >> Note that the design of zsmalloc makes it impossible to actually find the
> >> LRU zspage, so each class and fullness group is searched in a round-robin
> >> method to find the next zspage to reclaim.  Each fullness group orders its
> >> zspages in LRU order, so the oldest zspage is used for each fullness group.
> >>
> >
> > 1. Pz, Cc Mel who was strong against zswap with zsmalloc.
> > 2. I don't think LRU stuff should be in allocator layer. Exp, it's really
> >    hard to work well in zsmalloc design.
> 
> I didn't add any LRU - the existing fullness group LRU ordering is
> already there.  And yes, the zsmalloc design prevents any real LRU

I don't think It's not LRU for reclaiming but just simple linked list for
finding free slot.

> ordering, beyond per-fullness-group LRU ordering.

Yes.

> 
> > 3. If you want to add another writeback, make zswap writeback sane first.
> >    current implemenation(zswap store -> zbud reclaim -> zswap writeback,
> >    even) is really ugly.
> 
> why what's wrong with that?  how else can zbud/zsmalloc evict stored objects?

You can refer Mel's suggestion for zswap/zsmalloc and writeback problem.

http://www.spinics.net/lists/linux-mm/msg61601.html
http://lkml.iu.edu//hypermail/linux/kernel/1304.1/04334.html

I think LRU/writeback should be upper layer, not allocator itself.
Please, don't force every allocator to implement it for only zswap.

> 
> > 4. Don't make zsmalloc complicated without any data(benefit, regression)
> >    I will never ack if you don't give any number and real usecase.
> 
> ok, i'll run performance tests then, but let me know if you see any
> technical problems with any of the patches before then.
> 
> thanks!
> 
> >
> >> ---
> >>
> >> This patch set applies to linux-next.
> >>
> >> Dan Streetman (10):
> >>   zsmalloc: fix init_zspage free obj linking
> >>   zsmalloc: add fullness group list for ZS_FULL zspages
> >>   zsmalloc: always update lru ordering of each zspage
> >>   zsmalloc: move zspage obj freeing to separate function
> >>   zsmalloc: add atomic index to find zspage to reclaim
> >>   zsmalloc: add zs_ops to zs_pool
> >>   zsmalloc: add obj_handle_is_free()
> >>   zsmalloc: add reclaim_zspage()
> >>   zsmalloc: add zs_shrink()
> >>   zsmalloc: implement zs_zpool_shrink() with zs_shrink()
> >>
> >>  drivers/block/zram/zram_drv.c |   2 +-
> >>  include/linux/zsmalloc.h      |   7 +-
> >>  mm/zsmalloc.c                 | 314 +++++++++++++++++++++++++++++++++++++-----
> >>  3 files changed, 290 insertions(+), 33 deletions(-)
> >>
> >> --
> >> 1.8.3.1
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
