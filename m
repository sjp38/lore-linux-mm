Date: Mon, 6 Nov 2006 09:00:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <200611061756.00623.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0611060856590.25351@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <200611040232.52644.ak@suse.de> <Pine.LNX.4.64.0611060837040.25271@schroedinger.engr.sgi.com>
 <200611061756.00623.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Nov 2006, Andi Kleen wrote:

> > Because acceses to the structure can occur after kfree. The RCU 
> > implementation only delays the destruction of the slab. Locks are always 
> > in a definite state regardless if the object is in use or not.
> 
> Only objects that have been used at least once can be still visible. And 
> those would be still constructed of course -- just after the kmem_cache_alloc,
> not inside. For those that have never been used it shouldn't matter.

Constructors are only called on allocation of the slab, not on 
kmem_cache_alloc. And you are right: It does not matter for those that 
have never been used.

> > I think this is an attempt to avoid having to initialize pmds/pgds after 
> > intializaiton and also the use of the slab caches keeps the cache lines 
> > hot.
> 
> Ah, we got __GFP_ZERO for that, although it never quite did the work 
> completely. I'm not sure it helps a lot anyways

Not exactly. The implementation in the i386 arch code avoids the 
__GFP_ZERO by relying on empty pgd/pmds be zero. But you could copy Robin 
Holt's implementation via page lists from ia64 that does the saem. It
avoids the constructor/destructors and slab use. It is cleaner and 
probably faster.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
