Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B1B7F6B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 03:34:03 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id y10so2308640wgg.13
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 00:34:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gq7si45782984wib.55.2014.06.06.00.34.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 00:34:02 -0700 (PDT)
Message-ID: <53916EE7.9000806@suse.cz>
Date: Fri, 06 Jun 2014 09:33:59 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/6] mm, compaction: don't migrate in blocks that
 cannot be fully compacted in async direct compaction
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041705140.22536@chino.kir.corp.google.com> <53908F10.4020603@suse.cz> <alpine.DEB.2.02.1406051431030.18119@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406051431030.18119@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/05/2014 11:38 PM, David Rientjes wrote:
> On Thu, 5 Jun 2014, Vlastimil Babka wrote:
> 
>> > Ok, so this obsoletes my patchseries that did something similar.  I hope
>> 
>> Your patches 1/3 and 2/3 would still make sense. Checking alloc flags is IMHO
>> better than checking async here. That way, hugepaged and kswapd would still
>> try to migrate stuff which is important as Mel described in the reply to your
>> 3/3.
>> 
> 
> Would you mind folding those two patches into your series since you'll be 
> requiring the gfp_mask in struct compact_control and your pageblock skip 
> is better than mine?

Sure!

>> > you can rebase this set on top of linux-next and then propose it formally
>> > without the RFC tag.
>> 
>> I posted this early to facilitate discussion, but if you want to test on
>> linux-next then sure.
>> 
> 
> I'd love to test these.

OK, I'll repost it based on -next.

>> > We also need to discuss the scheduling heuristics, the reliance on
>> > need_resched(), to abort async compaction.  In testing, we actualy
>> > sometimes see 2-3 pageblocks scanned before terminating and thp has a very
>> > little chance of being allocated.  At the same time, if we try to fault
>> > 64MB of anon memory in and each of the 32 calls to compaction are
>> > expensive but don't result in an order-9 page, we see very lengthy fault
>> > latency.
>> 
>> Yes, I thought you were about to try the 1GB per call setting. I don't
>> currently have a test setup like you. My patch 1/6 still uses on
>> need_resched() but that could be replaced with a later patch.
>> 
> 
> Agreed.  I was thinking higher than 1GB would be possible once we have 
> your series that does the pageblock skip for thp, I think the expense 
> would be constant because we won't needlessly be migrating pages unless it 
> has a good chance at succeeding.

Looks like a counter of iterations actually done in scanners, maintained in
compact_control, would work better than any memory size based limit? It could
better reflect the actual work done and thus latency. Maybe increase the counter
also for migrations, with a higher cost than for a scanner iteration.


> I'm slightly concerned about the 
> COMPACT_CLUSTER_MAX termination, though, before we find unmigratable 
> memory but I think that will be very low probability.

Well I have removed the COMPACT_CLUSTER_MAX termination for this case. But
that could be perhaps an issue with compactors starving reclaimers through
too_many_isolated().

>> > I think it would be interesting to consider doing async compaction
>> > deferral up to 1 << COMPACT_MAX_DEFER_SHIFT after a sysctl-configurable
>> > amount of memory is scanned, at least for thp, and remove the scheduling
>> > heuristic entirely.
>> 
>> That could work. How about the lock contention heuristic? Is it possible on a
>> large and/or busy system to compact anything substantional without hitting the
>> lock contention? Are your observations about too early abort based on
>> need_resched() or lock contention?
>> 
> 
> Eek, it's mostly need_resched() because we don't use zone->lru_lock, we 
> have the memcg lruvec locks for lru locking.  We end up dropping and 
> reacquiring different locks based on the memcg of the page being isolated 
> quite a bit.

Hm I will probably as a first thing remove setting cc->contended for need_resched()
Looks like a bad decision, if there's no lock contention. cc->contended = true
means that there is no second direct compaction attempt (sync for hugepaged) which
is not good. And you basically say that this happens almost always. But it makes me
wonder how much difference could your patch "mm, thp: avoid excessive compaction latency
during fault" actually make? Because it makes the second attempt async instead of sync,
but if the second attempt never happens...
Ah, I get it, it was probably before I put cc->contended setting everywhere...

> This does beg the question about parallel direct compactors, though, that 
> will be contending on the same coarse zone->lru_lock locks and immediately 
> aborting and falling back to PAGE_SIZE pages for thp faults that will be 
> more likely if your patch to grab the high-order page and return it to the 
> page allocator is merged.

Hm can you explain how the page capturing makes this worse? I don't see it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
