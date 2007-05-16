Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705161343080.11234@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
	 <20070514161224.GC11115@waste.org>
	 <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
	 <1179164453.2942.26.camel@lappy>
	 <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
	 <1179170912.2942.37.camel@lappy> <1179250036.7173.7.camel@twins>
	 <Pine.LNX.4.64.0705151457060.3155@schroedinger.engr.sgi.com>
	 <1179298771.7173.16.camel@twins>
	 <Pine.LNX.4.64.0705161139540.10265@schroedinger.engr.sgi.com>
	 <1179343521.2912.20.camel@lappy>
	 <Pine.LNX.4.64.0705161235490.10660@schroedinger.engr.sgi.com>
	 <1179346738.2912.39.camel@lappy>
	 <Pine.LNX.4.64.0705161320020.11018@schroedinger.engr.sgi.com>
	 <1179348039.2912.48.camel@lappy>
	 <Pine.LNX.4.64.0705161343080.11234@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 16 May 2007 22:54:58 +0200
Message-Id: <1179348898.2912.57.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 13:44 -0700, Christoph Lameter wrote:
> On Wed, 16 May 2007, Peter Zijlstra wrote:
> 
> > > How does all of this interact with
> > > 
> > > 1. cpusets
> > > 
> > > 2. dma allocations and highmem?
> > > 
> > > 3. Containers?
> > 
> > Much like the normal kmem_cache would do; I'm not changing any of the
> > page allocation semantics.
> 
> So if we run out of memory on a cpuset then network I/O will still fail?
> 
> I do not see any distinction between DMA and regular memory. If we need 
> DMA memory to complete the transaction then this wont work?

If network relies on slabs that are cpuset constrained and the page
allocator reserves do not match that, then yes, it goes bang.

> > But its wanted to try the normal cpu_slab path first to detect that the
> > situation has subsided and we can resume normal operation.
> 
> Is there some indicator somewhere that indicates that we are in trouble? I 
> just see the ranks.

Yes, and page->rank will only ever be 0 if the page was allocated with
ALLOC_NO_WATERMARKS, and that only ever happens if we're in dire
straights and entitled to it.

Otherwise it'll be ALLOC_WMARK_MIN or somesuch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
