Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5DA4F6B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 03:49:55 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5482081iwn.14
        for <linux-mm@kvack.org>; Wed, 28 Jul 2010 00:49:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100728071705.GA22964@localhost>
References: <20100728071705.GA22964@localhost>
Date: Wed, 28 Jul 2010 16:49:53 +0900
Message-ID: <AANLkTimaj6+MzY5Aa_xqi75zKy1fDOQV5QiQjdX8jgm7@mail.gmail.com>
Subject: Re: [PATCH] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 4:17 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Fix "system goes unresponsive under memory pressure and lots of
> dirty/writeback pages" bug.
>
> =A0 =A0 =A0 =A0http://lkml.org/lkml/2010/4/4/86
>
> In the above thread, Andreas Mohr described that
>
> =A0 =A0 =A0 =A0Invoking any command locked up for minutes (note that I'm
> =A0 =A0 =A0 =A0talking about attempted additional I/O to the _other_,
> =A0 =A0 =A0 =A0_unaffected_ main system HDD - such as loading some shell
> =A0 =A0 =A0 =A0binaries -, NOT the external SSD18M!!).
>
> This happens when the two conditions are both meet:
> - under memory pressure
> - writing heavily to a slow device
>
> OOM also happens in Andreas' system. The OOM trace shows that 3
> processes are stuck in wait_on_page_writeback() in the direct reclaim
> path. One in do_fork() and the other two in unix_stream_sendmsg(). They
> are blocked on this condition:
>
> =A0 =A0 =A0 =A0(sc->order && priority < DEF_PRIORITY - 2)
>
> which was introduced in commit 78dc583d (vmscan: low order lumpy reclaim
> also should use PAGEOUT_IO_SYNC) one year ago. That condition may be too
> permissive. In Andreas' case, 512MB/1024 =3D 512KB. If the direct reclaim
> for the order-1 fork() allocation runs into a range of 512KB
> hard-to-reclaim LRU pages, it will be stalled.
>
> It's a severe problem in three ways.
>
> Firstly, it can easily happen in daily desktop usage. =A0vmscan priority
> can easily go below (DEF_PRIORITY - 2) on _local_ memory pressure. Even
> if the system has 50% globally reclaimable pages, it still has good
> opportunity to have 0.1% sized hard-to-reclaim ranges. For example, a
> simple dd can easily create a big range (up to 20%) of dirty pages in
> the LRU lists.
>
> Secondly, once triggered, it will stall unrelated processes (not doing IO
> at all) in the system. This "one slow USB device stalls the whole system"
> avalanching effect is very bad.
>
> Thirdly, once stalled, the stall time could be intolerable long for the
> users. =A0When there are 20MB queued writeback pages and USB 1.1 is
> writing them in 1MB/s, wait_on_page_writeback() will stuck for up to 20
> seconds. =A0Not to mention it may be called multiple times.
>
> So raise the bar to only enable PAGEOUT_IO_SYNC when priority goes below
> DEF_PRIORITY/3, or 6.25% LRU size. As the default dirty throttle ratio is
> 20%, it will hardly be triggered by pure dirty pages. We'd better treat
> PAGEOUT_IO_SYNC as some last resort workaround -- its stall time is so
> uncomfortably long (easily goes beyond 1s).
>
> The bar is only raised for (order < PAGE_ALLOC_COSTLY_ORDER) allocations,
> which are easy to satisfy in 1TB memory boxes. So, although 6.25% of
> memory could be an awful lot of pages to scan on a system with 1TB of
> memory, it won't really have to busy scan that much.
>
> Reported-by: Andreas Mohr <andi@lisas.de>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

The description and code both look  good to me.
Thanks for great effort, Wu.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
