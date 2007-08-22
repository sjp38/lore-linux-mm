Date: Wed, 22 Aug 2007 09:45:08 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
Message-ID: <20070822074508.GA3160@elte.hu>
References: <20070820215040.937296148@sgi.com> <1187692586.6114.211.camel@twins> <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com> <1187730812.5463.12.camel@lappy> <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com> <1187734144.5463.35.camel@lappy> <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> > I want slab to fail when a similar page alloc would fail, no magic.
> 
> Yes I know. I do not want allocations to fail but that reclaim occurs 
> in order to avoid failing any allocation. We need provisions that make 
> sure that we never get into such a bad memory situation that would 
> cause severe slowless and usually end up in a livelock anyways.

Could you outline the "big picture" as you see it? To me your argument 
that reclaim can always be done instantly and that the cases where it 
cannot be done are pathological and need to be avoided is fundamentally 
dangerous and quite a bit short-sighted at first glance.

The big picture way to think about this is the following: the free page 
pool is the "cache" of the MM. It's what "greases" the mechanism and 
bridges the inevitable reclaim latency and makes "atomic memory" 
available to the reclaim mechanism itself. We _cannot_ remove that cache 
without a conceptual replacement (or a _very_ robust argument and proof 
that the free pages pool is not needed at all - this would be a major 
design change (and a stupid mistake IMO)). Your patchset, in essence, 
tries to claim that we dont really need this cache and that all that 
matters is to keep enough clean pagecache pages around. That approach 
misses the full picture and i dont think we can progress without 
agreeing on the fundamentals first.

That "cache" cannot be handled in your scheme: a fully or mostly 
anonymous workload (tons of apps are like that) instantly destroys the 
"there is always a minimal amount of atomically reclaimable pages 
around" property of freelists, and this cannot be talked or tweaked 
around by twiddling any existing property of anonymous reclaim. 
Anonymous memory is dirty and takes ages to reclaim. The fact that your 
patchset causes an easy anonymous OOM further underlines this flaw of 
your thinking. Not making anonymous workloads OOM is the _hardest_ part 
of the MM, by far. Pagecache reclaim is a breeze in comparison :-)

So there is a large and fundamental rift between having pages on the 
freelist (instantly available to any context) and having them on the 
(current) LRU where they might or might not be clean, etc. The freelists 
are an implicit guarantee of buffering and atomicity and they can and do 
save the day if everything else fails to keep stuff insta-freeable. (And 
then we havent even considered the performance and scalability 
differences between picking from the pcp freelists versus picking pages 
from the LRU, havent considered the better higher-order page allocation 
property of the buddy pool and havent considered the atomicity of 
in-irq-handler allocations.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
