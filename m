Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1BD226B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 08:26:13 -0400 (EDT)
Date: Fri, 30 Jul 2010 20:25:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/5]  [RFC] transfer ASYNC vmscan writeback IO to the
 flusher threads
Message-ID: <20100730122553.GA6262@localhost>
References: <20100729232330.GO655@dastard>
 <20100730075819.GE8811@localhost>
 <20100730181014.4AEA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100730181014.4AEA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> > There are cases we have to do pageout().
> > 
> > - a stressed memcg with lots of dirty pages
> > - a large NUMA system whose nodes have unbalanced vmscan rate and dirty pages
> 
> - 32bit highmem system too

Ah yes!

> can you please see following commit? this describe current design.

Good staff. Thanks.

Thanks,
Fengguang


> 
> 
> 
> commit c4e2d7ddde9693a4c05da7afd485db02c27a7a09
> Author: akpm <akpm>
> Date:   Sun Dec 22 01:07:33 2002 +0000
> 
>     [PATCH] Give kswapd writeback higher priority than pdflush
> 
>     The `low latency page reclaim' design works by preventing page
>     allocators from blocking on request queues (and by preventing them from
>     blocking against writeback of individual pages, but that is immaterial
>     here).
> 
>     This has a problem under some situations.  pdflush (or a write(2)
>     caller) could be saturating the queue with highmem pages.  This
>     prevents anyone from writing back ZONE_NORMAL pages.  We end up doing
>     enormous amounts of scenning.
> 
>     A test case is to mmap(MAP_SHARED) almost all of a 4G machine's memory,
>     then kill the mmapping applications.  The machine instantly goes from
>     0% of memory dirty to 95% or more.  pdflush kicks in and starts writing
>     the least-recently-dirtied pages, which are all highmem.  The queue is
>     congested so nobody will write back ZONE_NORMAL pages.  kswapd chews
>     50% of the CPU scanning past dirty ZONE_NORMAL pages and page reclaim
>     efficiency (pages_reclaimed/pages_scanned) falls to 2%.
> 
>     So this patch changes the policy for kswapd.  kswapd may use all of a
>     request queue, and is prepared to block on request queues.
> 
>     What will now happen in the above scenario is:
> 
>     1: The page alloctor scans some pages, fails to reclaim enough
>        memory and takes a nap in blk_congetion_wait().
> 
>     2: kswapd() will scan the ZONE_NORMAL LRU and will start writing
>        back pages.  (These pages will be rotated to the tail of the
>        inactive list at IO-completion interrupt time).
> 
>        This writeback will saturate the queue with ZONE_NORMAL pages.
>        Conveniently, pdflush will avoid the congested queues.  So we end up
>        writing the correct pages.
> 
>     In this test, kswapd CPU utilisation falls from 50% to 2%, page reclaim
>     efficiency rises from 2% to 40% and things are generally a lot happier.
> 
> 
>     The downside is that kswapd may now do a lot less page reclaim,
>     increasing page allocation latency, causing more direct reclaim,
>     increasing lock contention in the VM, etc.  But I have not been able to
>     demonstrate that in testing.
> 
> 
>     The other problem is that there is only one kswapd, and there are lots
>     of disks.  That is a generic problem - without being able to co-opt
>     user processes we don't have enough threads to keep lots of disks saturated.
> 
>     One fix for this would be to add an additional "really congested"
>     threshold in the request queues, so kswapd can still perform
>     nonblocking writeout.  This gives kswapd priority over pdflush while
>     allowing kswapd to feed many disk queues.  I doubt if this will be
>     called for.
> 
>     BKrev: 3e051055aitHp3bZBPSqmq21KGs5aQ
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
