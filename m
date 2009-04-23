Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4FC6B0119
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 21:33:41 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3N1Ud16027870
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 21:30:39 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3N1YBHq194888
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 21:34:11 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3N1YAZv029397
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 21:34:11 -0400
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090423001311.GA26643@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-3-git-send-email-mel@csn.ul.ie>
	 <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie>
	 <1240421415.10627.93.camel@nimitz>  <20090423001311.GA26643@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 22 Apr 2009 18:34:07 -0700
Message-Id: <1240450447.10627.119.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-23 at 01:13 +0100, Mel Gorman wrote:
> On Wed, Apr 22, 2009 at 10:30:15AM -0700, Dave Hansen wrote:
> > On Wed, 2009-04-22 at 18:11 +0100, Mel Gorman wrote:
> > > On Wed, Apr 22, 2009 at 09:13:11AM -0700, Dave Hansen wrote:
> > > > On Wed, 2009-04-22 at 14:53 +0100, Mel Gorman wrote:
> > > > > No user of the allocator API should be passing in an order >= MAX_ORDER
> > > > > but we check for it on each and every allocation. Delete this check and
> > > > > make it a VM_BUG_ON check further down the call path.
> > > > 
> > > > Should we get the check re-added to some of the upper-level functions,
> > > > then?  Perhaps __get_free_pages() or things like alloc_pages_exact()? 
> > > 
> > > I don't think so, no. It just moves the source of the text bloat and
> > > for the few callers that are asking for something that will never
> > > succeed.
> > 
> > Well, it's a matter of figuring out when it can succeed.  Some of this
> > stuff, we can figure out at compile-time.  Others are a bit harder.
> > 
> 
> What do you suggest then? Some sort of constant that tells you the
> maximum size you can call for callers that think they might ever request
> too much?
> 
> Shuffling the check around to other top-level helpers seems pointless to
> me because as I said, it just moves text bloat from one place to the
> next.

Do any of the actual fast paths pass 'order' in as a real variable?  If
not, the compiler should be able to just take care of it.  From a quick
scan, it does appear that at least a third of the direct alloc_pages()
users pass an explicit '0'.  That should get optimized away
*immediately*.

> > > > I'm selfishly thinking of what I did in profile_init().  Can I slab
> > > > alloc it?  Nope.  Page allocator?  Nope.  Oh, well, try vmalloc():
> > > > 
> > > >         prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
> > > >         if (prof_buffer)
> > > >                 return 0;
> > > > 
> > > >         prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
> > > >         if (prof_buffer)
> > > >                 return 0;
> > > > 
> > > >         prof_buffer = vmalloc(buffer_bytes);
> > > >         if (prof_buffer)
> > > >                 return 0;
> > > > 
> > > >         free_cpumask_var(prof_cpu_mask);
> > > >         return -ENOMEM;
> > > > 
> > > 
> > > Can this ever actually be asking for an order larger than MAX_ORDER
> > > though? If so, you're condemning it to always behave poorly.
> > 
> > Yeah.  It is based on text size.  Smaller kernels with trimmed configs
> > and no modules have no problem fitting under MAX_ORDER, as do kernels
> > with larger base page sizes.  
> > 
> 
> It would seem that the right thing to have done here in the first place
> then was
> 
> if (buffer_bytes > PAGE_SIZE << (MAX_ORDER-1)
> 	return vmalloc(...)
> 
> kzalloc attempt
> 
> alloc_pages_exact attempt

Yeah, but honestly, I don't expect most users to get that "(buffer_bytes
> PAGE_SIZE << (MAX_ORDER-1)" right.  It seems like *exactly* the kind
of thing we should be wrapping up in common code.

Perhaps we do need an alloc_pages_nocheck() for the users that do have a
true non-compile-time-constant 'order' and still know they don't need
the check.

> > > > Same thing in __kmalloc_section_memmap():
> > > > 
> > > >         page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
> > > >         if (page)
> > > >                 goto got_map_page;
> > > > 
> > > >         ret = vmalloc(memmap_size);
> > > >         if (ret)
> > > >                 goto got_map_ptr;
> > > > 
> > > 
> > > If I'm reading that right, the order will never be a stupid order. It can fail
> > > for higher orders in which case it falls back to vmalloc() .  For example,
> > > to hit that limit, the section size for a 4K kernel, maximum usable order
> > > of 10, the section size would need to be 256MB (assuming struct page size
> > > of 64 bytes). I don't think it's ever that size and if so, it'll always be
> > > sub-optimal which is a poor choice to make.
> > 
> > I think the section size default used to be 512M on x86 because we
> > concentrate on removing whole DIMMs.  
> > 
> 
> It was a poor choice then as their sections always ended up in
> vmalloc() or else it was using the bootmem allocator in which case it
> doesn't matter that the core page allocator was doing.

True, but we tried to code that sucker to work anywhere and to be as
optimal as possible (which vmalloc() is not) when we could.

> > > > I depend on the allocator to tell me when I've fed it too high of an
> > > > order.  If we really need this, perhaps we should do an audit and then
> > > > add a WARN_ON() for a few releases to catch the stragglers.
> > > 
> > > I consider it buggy to ask for something so large that you always end up
> > > with the worst option - vmalloc(). How about leaving it as a VM_BUG_ON
> > > to get as many reports as possible on who is depending on this odd
> > > behaviour?
> > > 
> > > If there are users with good reasons, then we could convert this to WARN_ON
> > > to fix up the callers. I suspect that the allocator can already cope with
> > > recieving a stupid order silently but slowly. It should go all the way to the
> > > bottom and just never find anything useful and return NULL.  zone_watermark_ok
> > > is the most dangerous looking part but even it should never get to MAX_ORDER
> > > because it should always find there are not enough free pages and return
> > > before it overruns.
> > 
> > Whatever we do, I'd agree that it's fine that this is a degenerate case
> > that gets handled very slowly and as far out of hot paths as possible.
> > Anybody who can fall back to a vmalloc is not doing these things very
> > often.
> 
> If that's the case, the simpliest course might be to just drop the VM_BUG_ON()
> as a separate patch after asserting it's safe to call into the page
> allocator with too large an order with the consequence of it being a
> relatively expensive call considering it can never succeed.

__rmqueue_smallest() seems to do the right thing and it is awfully deep
in the allocator.

How about this:  I'll go and audit the use of order in page_alloc.c to
make sure that having an order>MAX_ORDER-1 floating around is OK and
won't break anything.  I'll also go and see what the actual .text size
changes are from this patch both for alloc_pages() and
alloc_pages_node() separately to make sure what we're dealing with here.
Does this check even *exist* in the optimized code very often?  

Deal? :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
