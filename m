Date: Wed, 16 May 2007 11:43:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179298771.7173.16.camel@twins>
Message-ID: <Pine.LNX.4.64.0705161139540.10265@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
 <20070514161224.GC11115@waste.org>  <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
  <1179164453.2942.26.camel@lappy>  <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
  <1179170912.2942.37.camel@lappy> <1179250036.7173.7.camel@twins>
 <Pine.LNX.4.64.0705151457060.3155@schroedinger.engr.sgi.com>
 <1179298771.7173.16.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, Peter Zijlstra wrote:

> On Tue, 2007-05-15 at 15:02 -0700, Christoph Lameter wrote:
> > On Tue, 15 May 2007, Peter Zijlstra wrote:
> > 
> > > How about something like this; it seems to sustain a little stress.
> > 
> > Argh again mods to kmem_cache.
> 
> Hmm, I had not understood you minded that very much; I did stay away
> from all the fast paths this time.

Well you added a new locking level and changed the locking hierachy!
 
> The thing is, I wanted to fold all the emergency allocs into a single
> slab, not a per cpu thing. And once you loose the per cpu thing, you
> need some extra serialization. Currently the top level lock is
> slab_lock(page), but that only works because we have interrupts disabled
> and work per cpu.

SLUB can only allocate from a per cpu slab. You will have to reserve one 
slab per cpu anyways unless we flush the cpu slab after each access. Same 
thing is true for SLAB. It wants objects in its per cpu queues.

> Why is it bad to extend kmem_cache a bit?

Because it is for all practical purposes a heavily accessed read only 
structure. Modifications only occur to per node and per cpu structures.
In a 4k systems any write will kick out the kmem_cache cacheline in 4k 
processors.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
