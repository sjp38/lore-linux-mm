Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D25CB6B006A
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 07:34:55 -0500 (EST)
Date: Mon, 23 Feb 2009 12:34:52 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
Message-ID: <20090223123452.GG6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <87prhauiry.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87prhauiry.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 12:57:37AM +0100, Andi Kleen wrote:
> Mel Gorman <mel@csn.ul.ie> writes:
> 
> > The complexity of the page allocator has been increasing for some time
> > and it has now reached the point where the SLUB allocator is doing strange
> > tricks to avoid the page allocator. This is obviously bad as it may encourage
> > other subsystems to try avoiding the page allocator as well.
> 
> Congratulations! That was long overdue. Haven't read the patches yet though.
> 

Thanks

> > Patch 15 reduces the number of times interrupts are disabled by reworking
> > what free_page_mlock() does. However, I notice that the cost of calling
> > TestClearPageMlocked() is still quite high and I'm guessing it's because
> > it's a locked bit operation. It's be nice if it could be established if
> > it's safe to use an unlocked version here. Rik, can you comment?
> 
> What machine was that again?
> 

It's a AMD Phenom 9950 quad core.

> > Patch 16 avoids using the zonelist cache on non-NUMA machines
> 
> My suspicion is that it can be even dropped on most small (all?) NUMA systems.
> 

I'm assuming it should not be dropped for all. My vague memory was that this
was introduced for large IA-64 machines and that they were able to show a
clear gain when scanning large numbers of zones. Patch 16 disables zonelist
caching if there is only one NUMA node but maybe it should be disabled for
more than that.

> > Patch 20 gets rid of hot/cold freeing of pages because it incurs cost for
> > what I believe to be very dubious gain. I'm not sure we currently gain
> > anything by it but it's further discussed in the patch itself.
> 
> Yes the hot/cold thing was always quite dubious.
> 

Andrew mentioned a micro-benchmark so I will be digging that up to see
what it can show.

> > Counters are surprising expensive, we spent a good chuck of our time in
> > functions like __dec_zone_page_state and __dec_zone_state. In a profiled
> > run of kernbench, the time spent in __dec_zone_state was roughly equal to
> > the combined cost of the rest of the page free path. A quick check showed
> > that almost half of the time in that function is spent on line 233 alone
> > which for me is;
> >
> > 	(*p)--;
> >
> > That's worth a separate investigation but it might be a case that
> > manipulating int8_t on the machine I was using for profiling is unusually
> > expensive. 
> 
> What machine was that?
> 

This is the AMD Phenom again but I might be mistaken on the line causing
the problem. A second profile run shows all the cost in the function entry
so it might just be a co-incidence that the sampling happened to trigger on
that particular line. It's high on the profiles simply because it's called
a lot. The assembler doesn't look particularly bad or anything.

> In general I wouldn't expect even on a system with slow char
> operations to be that expensive. It sounds more like a cache miss or a
> cache line bounce. You could possibly confirm by using appropiate
> performance counters.
> 

I'll check for cache line misses.

> > Converting this to an int might be faster but the increased
> > memory consumption and cache footprint might be a problem. Opinions?
> 
> One possibility would be to move the zone statistics to allocated
> per cpu data. Or perhaps just stop counting per zone at all and
> only count per cpu.
> 
> > The downside is that the patches do increase text size because of the
> > splitting of the fast path into one inlined blob and the slow path into a
> > number of other functions. On my test machine, text increased by 1.2K so
> > I might revisit that again and see how much of a difference it really made.
> >
> > That all said, I'm seeing good results on actual benchmarks with these
> > patches.
> >
> > o On many machines, I'm seeing a 0-2% improvement on kernbench. The dominant
> 
> Neat.
> 
> > So, by and large it's an improvement of some sort.
> 
> That seems like an understatement.
> 

It'll all depend on what other peoples machines turn up :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
