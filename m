Date: Wed, 22 Aug 2007 12:19:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
In-Reply-To: <20070822074508.GA3160@elte.hu>
Message-ID: <Pine.LNX.4.64.0708221211170.14599@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <1187692586.6114.211.camel@twins>
 <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
 <1187730812.5463.12.camel@lappy> <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
 <1187734144.5463.35.camel@lappy> <Pine.LNX.4.64.0708211532560.5728@schroedinger.engr.sgi.com>
 <20070822074508.GA3160@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007, Ingo Molnar wrote:

> Could you outline the "big picture" as you see it? To me your argument 
> that reclaim can always be done instantly and that the cases where it 
> cannot be done are pathological and need to be avoided is fundamentally 
> dangerous and quite a bit short-sighted at first glance.

That is a bit overdrawing my argument. The issues that Peter saw can be 
fixed by allowing recursive reclaim (see the earlier patchset). The rest 
is so far sugar on top or building extreme cases where we already have 
trouble.

> The big picture way to think about this is the following: the free page 
> pool is the "cache" of the MM. It's what "greases" the mechanism and 
> bridges the inevitable reclaim latency and makes "atomic memory" 
> available to the reclaim mechanism itself. We _cannot_ remove that cache 
> without a conceptual replacement (or a _very_ robust argument and proof 
> that the free pages pool is not needed at all - this would be a major 
> design change (and a stupid mistake IMO)). Your patchset, in essence, 
> tries to claim that we dont really need this cache and that all that 
> matters is to keep enough clean pagecache pages around. That approach 
> misses the full picture and i dont think we can progress without 
> agreeing on the fundamentals first.

The patchset attempts to deal with the reserves in a more intelligent 
way in order not to fail when this pool becomes exhausted because some
device needs a lot of memory in the writeout path.

> That "cache" cannot be handled in your scheme: a fully or mostly 
> anonymous workload (tons of apps are like that) instantly destroys the 
> "there is always a minimal amount of atomically reclaimable pages 
> around" property of freelists, and this cannot be talked or tweaked 
> around by twiddling any existing property of anonymous reclaim. 

A extreme anonymous workload like discussed here can even cause the 
current VM to fail. Realistically at least portions of the executable and 
varios slab caches will remain in memory in addition to the reserves.

> Anonymous memory is dirty and takes ages to reclaim. The fact that your 
> patchset causes an easy anonymous OOM further underlines this flaw of 
> your thinking. Not making anonymous workloads OOM is the _hardest_ part 
> of the MM, by far. Pagecache reclaim is a breeze in comparison :-)

The central flaw in my thinking was the switching of of PF_MEMALLOC on the 
writeout path instead of allowing recursive PF_MEMALLOC reclaim as in the 
first patch. But the first patchset did not have that flaw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
