Date: Mon, 23 Jul 2007 15:50:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] add __GFP_ZERP to GFP_LEVEL_MASK
In-Reply-To: <20070723151306.86e3e0ce.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707231544290.32603@schroedinger.engr.sgi.com>
References: <1185185020.8197.11.camel@twins> <20070723113712.c0ee29e5.akpm@linux-foundation.org>
 <1185216048.5535.1.camel@lappy> <20070723144323.1ac34b16@schroedinger.engr.sgi.com>
 <20070723151306.86e3e0ce.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007, Andrew Morton wrote:

> On Mon, 23 Jul 2007 14:43:23 -0700
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > __GFP_ZERO is implemented by the slab allocators (the page allocator
> > has no knowledge about the length of the object to be zeroed). The slab
> > allocators do not pass __GFP_ZERO to the page allocator.
> 
> OK, well that was weird.  So
> 
> 	kmalloc(42, GFP_KERNEL|__GFP_ZERO);
> 
> duplicates
> 
> 	kzalloc(42, GFP_KERNEL);

Correct.
 
> Why do it both ways?

There are now ~2.5k uses of kzalloc in the kernel.

kzalloc and friends implies that we need to duplicate all allocator 
functions. That was never done for NUMA allocators there was never a 
kzalloc_node f.e..

kzalloc also cannot be used in a parameterized way in a derived allocator 
where you would simply pass on the gfp flags.
 
__GFP_ZERO support allows all allocators to work in a consistent way. 
There is no need to special case slab zeroing allocation.

kzalloc could be removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
