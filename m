Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C8406B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 05:22:24 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6U9MKMN008372
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 30 Jul 2010 18:22:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EBFF45DE52
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 18:22:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 41E2245DE50
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 18:22:20 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 214B91DB8016
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 18:22:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BC5401DB8012
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 18:22:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/5]  [RFC] transfer ASYNC vmscan writeback IO to the flusher threads
In-Reply-To: <20100730075819.GE8811@localhost>
References: <20100729232330.GO655@dastard> <20100730075819.GE8811@localhost>
Message-Id: <20100730181014.4AEA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 30 Jul 2010 18:22:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Fri, Jul 30, 2010 at 07:23:30AM +0800, Dave Chinner wrote:
> > On Thu, Jul 29, 2010 at 07:51:42PM +0800, Wu Fengguang wrote:
> > > Andrew,
> > > 
> > > It's possible to transfer ASYNC vmscan writeback IOs to the flusher threads.
> > > This simple patchset shows the basic idea. Since it's a big behavior change,
> > > there are inevitably lots of details to sort out. I don't know where it will
> > > go after tests and discussions, so the patches are intentionally kept simple.
> > > 
> > > sync livelock avoidance (need more to be complete, but this is minimal required for the last two patches)
> > > 	[PATCH 1/5] writeback: introduce wbc.for_sync to cover the two sync stages
> > > 	[PATCH 2/5] writeback: stop periodic/background work on seeing sync works
> > > 	[PATCH 3/5] writeback: prevent sync livelock with the sync_after timestamp
> > > 
> > > let the flusher threads do ASYNC writeback for pageout()
> > > 	[PATCH 4/5] writeback: introduce bdi_start_inode_writeback()
> > > 	[PATCH 5/5] vmscan: transfer async file writeback to the flusher
> > 
> > I really do not like this - all it does is transfer random page writeback
> > from vmscan to the flusher threads rather than avoiding random page
> > writeback altogether. Random page writeback is nasty - just say no.
> 
> There are cases we have to do pageout().
> 
> - a stressed memcg with lots of dirty pages
> - a large NUMA system whose nodes have unbalanced vmscan rate and dirty pages

- 32bit highmem system too

can you please see following commit? this describe current design.




commit c4e2d7ddde9693a4c05da7afd485db02c27a7a09
Author: akpm <akpm>
Date:   Sun Dec 22 01:07:33 2002 +0000

    [PATCH] Give kswapd writeback higher priority than pdflush

    The `low latency page reclaim' design works by preventing page
    allocators from blocking on request queues (and by preventing them from
    blocking against writeback of individual pages, but that is immaterial
    here).

    This has a problem under some situations.  pdflush (or a write(2)
    caller) could be saturating the queue with highmem pages.  This
    prevents anyone from writing back ZONE_NORMAL pages.  We end up doing
    enormous amounts of scenning.

    A test case is to mmap(MAP_SHARED) almost all of a 4G machine's memory,
    then kill the mmapping applications.  The machine instantly goes from
    0% of memory dirty to 95% or more.  pdflush kicks in and starts writing
    the least-recently-dirtied pages, which are all highmem.  The queue is
    congested so nobody will write back ZONE_NORMAL pages.  kswapd chews
    50% of the CPU scanning past dirty ZONE_NORMAL pages and page reclaim
    efficiency (pages_reclaimed/pages_scanned) falls to 2%.

    So this patch changes the policy for kswapd.  kswapd may use all of a
    request queue, and is prepared to block on request queues.

    What will now happen in the above scenario is:

    1: The page alloctor scans some pages, fails to reclaim enough
       memory and takes a nap in blk_congetion_wait().

    2: kswapd() will scan the ZONE_NORMAL LRU and will start writing
       back pages.  (These pages will be rotated to the tail of the
       inactive list at IO-completion interrupt time).

       This writeback will saturate the queue with ZONE_NORMAL pages.
       Conveniently, pdflush will avoid the congested queues.  So we end up
       writing the correct pages.

    In this test, kswapd CPU utilisation falls from 50% to 2%, page reclaim
    efficiency rises from 2% to 40% and things are generally a lot happier.


    The downside is that kswapd may now do a lot less page reclaim,
    increasing page allocation latency, causing more direct reclaim,
    increasing lock contention in the VM, etc.  But I have not been able to
    demonstrate that in testing.


    The other problem is that there is only one kswapd, and there are lots
    of disks.  That is a generic problem - without being able to co-opt
    user processes we don't have enough threads to keep lots of disks saturated.

    One fix for this would be to add an additional "really congested"
    threshold in the request queues, so kswapd can still perform
    nonblocking writeout.  This gives kswapd priority over pdflush while
    allowing kswapd to feed many disk queues.  I doubt if this will be
    called for.

    BKrev: 3e051055aitHp3bZBPSqmq21KGs5aQ



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
