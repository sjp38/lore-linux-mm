Date: Mon, 14 May 2007 12:56:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179170912.2942.37.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705141253130.12045@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
 <20070514161224.GC11115@waste.org>  <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
  <1179164453.2942.26.camel@lappy>  <Pine.LNX.4.64.0705141051170.11251@schroedinger.engr.sgi.com>
 <1179170912.2942.37.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Peter Zijlstra wrote:

> > You can pull the big switch (only on a SLUB slab I fear) to switch 
> > off the fast path. Do SetSlabDebug() when allocating a precious 
> > allocation that should not be gobbled up by lower level processes. 
> > Then you can do whatever you want in the __slab_alloc debug section and we 
> > wont care because its not the hot path.
> 
> One allocator is all I need; it would just be grand if all could be
> supported.
> 
> So what you suggest is not placing the 'emergency' slab into the regular
> place so that normal allocations will not be able to find it. Then if an
> emergency allocation cannot be satified by the regular path, we fall
> back to the slow path and find the emergency slab.

Hmmm.. Maybe we could do that.... But what I had in mind was simply to 
set a page flag (DebugSlab()) if you know in alloc_slab that the slab 
should be only used for emergency allocation. If DebugSlab is set then the
fastpath will not be called. You can trap all allocation attempts and 
insert whatever fancy logic you want in the debug path since its not 
performance critical.

> The thing is; I'm not needing any speed, as long as the machine stay
> alive I'm good. However others are planing to build a full reserve based
> allocator to properly fix the places that now use __GFP_NOFAIL and
> situation such as in add_to_swap().

Well I have version of SLUB here that allows you do redirect the alloc 
calls at will. Adds a kmem_cache_ops structure and in the kmem_cache_ops 
structure you can redirect allocation and freeing of slabs (not objects!) 
at will. Would that help?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
