From: Andi Kleen <ak@suse.de>
Subject: Re: Page allocator: Single Zone optimizations
Date: Mon, 6 Nov 2006 17:56:00 +0100
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com> <200611040232.52644.ak@suse.de> <Pine.LNX.4.64.0611060837040.25271@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611060837040.25271@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200611061756.00623.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Monday 06 November 2006 17:40, Christoph Lameter wrote:
> On Sat, 4 Nov 2006, Andi Kleen wrote:
> 
> > > I would appreciate patches to that effect, voting will not help much. It 
> > > would make my new slab project much easier. But I doubt that this is as 
> > > easy as you think. F.e. I wonder how you going to do anonvma RCU without 
> > > constructors. I think constructors/destructors are here to stay.
> > 
> > Hmm. Why? Why can't the work of the constructor not be done after the
> > kmem_cache_alloc() ?
> 
> Because acceses to the structure can occur after kfree. The RCU 
> implementation only delays the destruction of the slab. Locks are always 
> in a definite state regardless if the object is in use or not.

Only objects that have been used at least once can be still visible. And 
those would be still constructed of course -- just after the kmem_cache_alloc,
not inside. For those that have never been used it shouldn't matter.
 
> > > One thing I would appreciate very much and its in your area. Deal 
> > > with the use of slab for page size allocations (pmd, pgd etc) in i386 arch 
> > > code. 
> > I can do that for pte/pmd. Never quite understood why those were made
> > slabs -- on x86-64 they are just pages and that works great.
> 
> I think this is an attempt to avoid having to initialize pmds/pgds after 
> intializaiton and also the use of the slab caches keeps the cache lines 
> hot.

Ah, we got __GFP_ZERO for that, although it never quite did the work 
completely. I'm not sure it helps a lot anyways

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
