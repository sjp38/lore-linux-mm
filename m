Date: Mon, 20 Aug 2007 12:26:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
In-Reply-To: <84144f020708200228v1af5248cx6f6da4a7a35400f3@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708201220500.29092@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>  <20070806103658.603735000@chello.nl>
 <1187595513.6114.176.camel@twins>  <Pine.LNX.4.64.0708201211240.20591@sbz-30.cs.Helsinki.FI>
  <1187601455.6114.189.camel@twins> <84144f020708200228v1af5248cx6f6da4a7a35400f3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Aug 2007, Pekka Enberg wrote:

> Hi Peter,
> 
> On Mon, 2007-08-20 at 12:12 +0300, Pekka J Enberg wrote:
> > > Any reason why the callers that are actually interested in this don't do
> > > page->reserve on their own?
> 
> On 8/20/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > because new_slab() destroys the content?
> 
> Right. So maybe we could move the initialization parts of new_slab()
> to __new_slab() so that the callers that are actually interested in
> 'reserve' could do allocate_slab(), store page->reserve and do rest of
> the initialization with it?

I am still not convinced about this approach and there seems to be 
agreement that this is not working on large NUMA. So #ifdef it out? 
!CONFIG_NUMA? Some more general approach that does not rely on a single 
slab being a reserve?

The object is to check the alloc flags when having allocated a reserve 
slab right? Adding another flag SlabReserve and keying off on that one may 
be the easiest solution.

I have pending patches here that add per cpu structures. Those will make 
that job easier.

> As for the __GFP_WAIT handling, I *think* we can move the interrupt
> enable/disable to allocate_slab()... Christoph?

The reason the enable/disable is in new_slab is to minimize interrupt 
holdoff time. If we move it to allocate slab then the slab preparation is 
done with interrupts disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
