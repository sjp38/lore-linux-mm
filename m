Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4E77B6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 17:38:36 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so1456476iec.23
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 14:38:36 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id ik3si3251490igb.46.2014.06.05.14.38.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 14:38:35 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id rp18so1524074iec.0
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 14:38:34 -0700 (PDT)
Date: Thu, 5 Jun 2014 14:38:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 6/6] mm, compaction: don't migrate in blocks that
 cannot be fully compacted in async direct compaction
In-Reply-To: <53908F10.4020603@suse.cz>
Message-ID: <alpine.DEB.2.02.1406051431030.18119@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041705140.22536@chino.kir.corp.google.com>
 <53908F10.4020603@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Thu, 5 Jun 2014, Vlastimil Babka wrote:

> > Ok, so this obsoletes my patchseries that did something similar.  I hope
> 
> Your patches 1/3 and 2/3 would still make sense. Checking alloc flags is IMHO
> better than checking async here. That way, hugepaged and kswapd would still
> try to migrate stuff which is important as Mel described in the reply to your
> 3/3.
> 

Would you mind folding those two patches into your series since you'll be 
requiring the gfp_mask in struct compact_control and your pageblock skip 
is better than mine?

> > you can rebase this set on top of linux-next and then propose it formally
> > without the RFC tag.
> 
> I posted this early to facilitate discussion, but if you want to test on
> linux-next then sure.
> 

I'd love to test these.

> > We also need to discuss the scheduling heuristics, the reliance on
> > need_resched(), to abort async compaction.  In testing, we actualy
> > sometimes see 2-3 pageblocks scanned before terminating and thp has a very
> > little chance of being allocated.  At the same time, if we try to fault
> > 64MB of anon memory in and each of the 32 calls to compaction are
> > expensive but don't result in an order-9 page, we see very lengthy fault
> > latency.
> 
> Yes, I thought you were about to try the 1GB per call setting. I don't
> currently have a test setup like you. My patch 1/6 still uses on
> need_resched() but that could be replaced with a later patch.
> 

Agreed.  I was thinking higher than 1GB would be possible once we have 
your series that does the pageblock skip for thp, I think the expense 
would be constant because we won't needlessly be migrating pages unless it 
has a good chance at succeeding.  I'm slightly concerned about the 
COMPACT_CLUSTER_MAX termination, though, before we find unmigratable 
memory but I think that will be very low probability.

> > I think it would be interesting to consider doing async compaction
> > deferral up to 1 << COMPACT_MAX_DEFER_SHIFT after a sysctl-configurable
> > amount of memory is scanned, at least for thp, and remove the scheduling
> > heuristic entirely.
> 
> That could work. How about the lock contention heuristic? Is it possible on a
> large and/or busy system to compact anything substantional without hitting the
> lock contention? Are your observations about too early abort based on
> need_resched() or lock contention?
> 

Eek, it's mostly need_resched() because we don't use zone->lru_lock, we 
have the memcg lruvec locks for lru locking.  We end up dropping and 
reacquiring different locks based on the memcg of the page being isolated 
quite a bit.

This does beg the question about parallel direct compactors, though, that 
will be contending on the same coarse zone->lru_lock locks and immediately 
aborting and falling back to PAGE_SIZE pages for thp faults that will be 
more likely if your patch to grab the high-order page and return it to the 
page allocator is merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
