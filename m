Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com>
	 <1187692586.6114.211.camel@twins>
	 <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
	 <1187730812.5463.12.camel@lappy>
	 <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 22 Aug 2007 00:09:03 +0200
Message-Id: <1187734144.5463.35.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-21 at 14:29 -0700, Christoph Lameter wrote:
> On Tue, 21 Aug 2007, Peter Zijlstra wrote:
> 
> > It quickly ends up with all of memory in the laundry list and then
> > recursing into __alloc_pages which will fail to make progress and OOMs.
> 
> Hmmmm... Okay that needs to be addressed. Reserves need to be used and we 
> only should enter reclaim if that runs out (like the first patch that I 
> did).
> 
> > But aside from the numerous issues with the patch set as presented, I'm
> > not seeing the seeing the big picture, why are you doing this.
> 
> I want general improvements to reclaim to address the issues that you see 
> and other issues related to reclaim instead of the strange code that makes 
> PF_MEMALLOC allocs compete for allocations from a single slab and putting 
> logic into the kernel to decide which allocs to fail. We can reclaim after 
> all. Its just a matter of finding the right way to do this. 

The latest patch I posted got rid of that global slab.

Also, all I want is for slab to honour gfp flags like page allocation
does, nothing more, nothing less.

(well, actually slightly less, since I'm only really interrested in the
ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER -> ALLOC_NO_WATERMARKS transition and
not all higher ones)

I want slab to fail when a similar page alloc would fail, no magic.

Strictly speaking:

if:

 page = alloc_page(gfp);

fails but:

 obj = kmem_cache_alloc(s, gfp);

succeeds then its a bug.

But I'm not actually needing it that strict, just the ALLOC_NO_WATERMARK
part needs to be done, ALLOC_HARDER, ALLOC_HIGH those may fudge a bit.

> > Anonymous pages are a there to stay, and we cannot tell people how to
> > use them. So we need some free or freeable pages in order to avoid the
> > vm deadlock that arises from all memory dirty.
> 
> No one is trying to abolish Anonymous pages. Free memory is readily 
> available on demand if one calls reclaim. Your scheme introduces complex 
> negotiations over a few scraps of memory when large amounts of memory 
> would still be readily available if one would do the right thing and call 
> into reclaim.

This is the thing I contend, there need not be large amounts of memory
around. In my test prog the hot code path fits into a single page, the
rest can be anonymous.

> > 'Optimizing' this by switching to freeable pages has mainly
> > disadvantages IMHO, finding them scrambles LRU order and complexifies
> > relcaim and all that for a relatively small gain in space for clean
> > pagecache pages.
> 
> Sounds like you would like to change the way we handle memory in general 
> in the VM? Reclaim (and thus finding freeable pages) is basic to Linux 
> memory management.

Not quite, currently we have free pages in the reserves, if you want to
replace some (or all) of that by freeable pages then that is a change.

I'm just using the reserves.

> > Please, stop writing patches and write down a solid proposal of how you
> > envision the VM working in the various scenarios and why its better than
> > the current approach.
> 
> Sorry I just got into this a short time ago and I may need a few cycles 
> to get this all straight. An approach that uses memory instead of 
> ignoring available memory is certainly better.

Sure if and when possible. There will always be need to fall back to the
reserves.

A bit off-topic, re that reclaim from atomic context:
Currently we try to hold spinlocks only for short periods of time so
that reclaim can be preempted, if you run all of reclaim from a
non-preemptible context you get very large preemption latencies and if
done from int context it'd also generate large int latencies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
