Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id EDA8C6B002B
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 13:01:46 -0500 (EST)
Date: Mon, 10 Dec 2012 18:01:41 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kswapd craziness in 3.7
Message-ID: <20121210180141.GK1009@suse.de>
References: <20121203194208.GZ24381@cmpxchg.org>
 <20121204214210.GB20253@cmpxchg.org>
 <20121205030133.GA17438@wolff.to>
 <20121206173742.GA27297@wolff.to>
 <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com>
 <50C32D32.6040800@iskon.hr>
 <50C3AF80.8040700@iskon.hr>
 <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org>
 <20121210110337.GH1009@suse.de>
 <20121210163904.GA22101@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121210163904.GA22101@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Zlatko Calusic <zlatko.calusic@iskon.hr>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Dec 10, 2012 at 11:39:04AM -0500, Johannes Weiner wrote:
> On Mon, Dec 10, 2012 at 11:03:37AM +0000, Mel Gorman wrote:
> > On Sat, Dec 08, 2012 at 05:01:42PM -0800, Linus Torvalds wrote:
> > > On Sat, 8 Dec 2012, Zlatko Calusic wrote:
> > > > Or sooner... in short: nothing's changed!
> > > > 
> > > > On a 4GB RAM system, where applications use close to 2GB, kswapd likes to keep
> > > > around 1GB free (unused), leaving only 1GB for page/buffer cache. If I force
> > > > bigger page cache by reading a big file and thus use the unused 1GB of RAM,
> > > > kswapd will soon (in a matter of minutes) evict those (or other) pages out and
> > > > once again keep unused memory close to 1GB.
> > > 
> > > Ok, guys, what was the reclaim or kswapd patch during the merge window 
> > > that actually caused all of these insane problems?
> > 
> > I believe commit c6543459 (mm: remove __GFP_NO_KSWAPD) is the primary
> > candidate. __GFP_NO_KSWAPD was originally introduced by THP because kswapd
> > was excessively reclaiming. kswapd would stay awake aggressively reclaiming
> > even if compaction was deferred. The flag was removed in this cycle when it
> > was expected that it was no longer necessary. I'm not foisting the blame
> > on Rik here, I was on the review list for that patch and did not identify
> > that it would cause this many problems either.
> >
> > > It seems it was more 
> > > fundamentally buggered than the fifteen-million fixes for kswapd we have 
> > > already picked up.
> > 
> > It was already fundamentally buggered up. The difference was it stayed
> > asleep for THP requests in earlier kernels.
> > 
> > There is a big difference between a direct reclaim/compaction for THP
> > and kswapd doing the same work. Direct reclaim/compaction will try once,
> > give up quickly and defer requests in the near future to avoid impacting
> > the system heavily for THP. The same applies for khugepaged.
> > 
> > kswapd is different. It can keep going until it meets its watermarks for
> > a THP allocation are met. Two reasons why it might keep going for a long
> > time are that compaction is being inefficient which we know it may be due
> > to crap like this
> > 
> > end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
> > 
> > and the second reason is if the highest zone is relatively because
> > compaction_suitable will keep saying that allocations are failing due to
> > insufficient amounts of memory in the highest zone. It'll reclaim a little
> > from this highest zone and then shrink_slab() potentially dumping a large
> > amount of memory. This may be the case for Zlatko as with a 4G machine
> > his ZONE_NORMAL could be small depending on how the 32-bit address space
> > is used by his hardware.
> 
> Unlike direct reclaim, kswapd also never does sync migration.  Since
> the fragmentation index is a ratio of free pages over free page
> blocks, doing lightweight compaction that reduces the page blocks but
> never really follows through to compact a THP block increases the free
> memory requirement.
> 

True.

> I thought about the small Normal zone too.  Direct reclaim/compaction
> is fine with one zone being able to provide a THP, but kswapd requires
> 25% of the node.  A small ZONE_NORMAL would not be able to meet this
> and so the bigger DMA32 zone would also be required to be balanced for
> the THP allocation.
> 

Also true.

> > > Mel? Ideas?
> > 
> > Consider reverting the revert of __GFP_NO_KSWAPD again until this can be
> > ironed out at a more reasonable pace. Rik? Johannes?
> 
> Yes, I also think we need more time for this.
> 

Yes, the last minute band-aids are just getting worse and the result is
more mess.

> <SNIP>
> 
> I don't see a shrink_slab() invocation after this point since the
> loop_again jumps in this loop where removed, so this shouldn't change
> anything?

/me slaps self

In this last-minute disaster, I'm not thinking properly at all any more. The
shrink slab disabling should have happened before the loop_again but even
then it's wrong because it's just covering over the problem.

The way order and testorder interact with how balanced is calculated means
that we potentially call shrink_slab() multiple times and that thing is
global in nature and basically uncontrolled. You could argue that we should
only call shrink_slab() if order-0 watermarks are not met but that will
not necessarily prevent kswapd reclaiming too much. It keeps going back
to balance_pgdat needing its list of requirements drawn up and receive
some major surgery and we're not going to do that as a quick hack.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
