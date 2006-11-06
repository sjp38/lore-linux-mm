From: Andi Kleen <ak@suse.de>
Subject: Re: Page allocator: Single Zone optimizations
Date: Mon, 6 Nov 2006 18:07:16 +0100
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com> <200611061756.00623.ak@suse.de> <Pine.LNX.4.64.0611060856590.25351@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611060856590.25351@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200611061807.16890.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Monday 06 November 2006 18:00, Christoph Lameter wrote:
> On Mon, 6 Nov 2006, Andi Kleen wrote:
> 
> > > Because acceses to the structure can occur after kfree. The RCU 
> > > implementation only delays the destruction of the slab. Locks are always 
> > > in a definite state regardless if the object is in use or not.
> > 
> > Only objects that have been used at least once can be still visible. And 
> > those would be still constructed of course -- just after the kmem_cache_alloc,
> > not inside. For those that have never been used it shouldn't matter.
> 
> Constructors are only called on allocation of the slab, not on 
> kmem_cache_alloc. 

I know this.

> And you are right: It does not matter for those that  
> have never been used.

This means it is fine to replace the constructor with an function
that runs after kmem_cache_alloc() in this case.

> > > I think this is an attempt to avoid having to initialize pmds/pgds after 
> > > intializaiton and also the use of the slab caches keeps the cache lines 
> > > hot.
> > 
> > Ah, we got __GFP_ZERO for that, although it never quite did the work 
> > completely. I'm not sure it helps a lot anyways
> 
> Not exactly. The implementation in the i386 arch code avoids the 
> __GFP_ZERO by relying on empty pgd/pmds be zero. But you could copy Robin 
> Holt's implementation via page lists from ia64 that does the saem. It
> avoids the constructor/destructors and slab use. It is cleaner and 
> probably faster.

i386 used to have such lists some time ago too, until they were removed.

What I meant: some time ago i had patches to add a __GFP_ZERO queue to the
page allocator. The page allocator would handle all this for everybody. 
For various reasons they never got pushed.

But I am not sure it is worth it all that much because there are not
that many PMDs allocated typically.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
