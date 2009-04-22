Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A1F886B0047
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:11:46 -0400 (EDT)
Date: Wed, 22 Apr 2009 18:11:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
Message-ID: <20090422171151.GF15367@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-3-git-send-email-mel@csn.ul.ie> <1240416791.10627.78.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240416791.10627.78.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 22, 2009 at 09:13:11AM -0700, Dave Hansen wrote:
> On Wed, 2009-04-22 at 14:53 +0100, Mel Gorman wrote:
> > No user of the allocator API should be passing in an order >= MAX_ORDER
> > but we check for it on each and every allocation. Delete this check and
> > make it a VM_BUG_ON check further down the call path.
> 
> Should we get the check re-added to some of the upper-level functions,
> then?  Perhaps __get_free_pages() or things like alloc_pages_exact()? 
> 

I don't think so, no. It just moves the source of the text bloat and
for the few callers that are asking for something that will never
succeed.

> I'm selfishly thinking of what I did in profile_init().  Can I slab
> alloc it?  Nope.  Page allocator?  Nope.  Oh, well, try vmalloc():
> 
>         prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
>         if (prof_buffer)
>                 return 0;
> 
>         prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
>         if (prof_buffer)
>                 return 0;
> 
>         prof_buffer = vmalloc(buffer_bytes);
>         if (prof_buffer)
>                 return 0;
> 
>         free_cpumask_var(prof_cpu_mask);
>         return -ENOMEM;
> 

Can this ever actually be asking for an order larger than MAX_ORDER
though? If so, you're condemning it to always behave poorly.

> Same thing in __kmalloc_section_memmap():
> 
>         page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
>         if (page)
>                 goto got_map_page;
> 
>         ret = vmalloc(memmap_size);
>         if (ret)
>                 goto got_map_ptr;
> 

If I'm reading that right, the order will never be a stupid order. It can fail
for higher orders in which case it falls back to vmalloc() .  For example,
to hit that limit, the section size for a 4K kernel, maximum usable order
of 10, the section size would need to be 256MB (assuming struct page size
of 64 bytes). I don't think it's ever that size and if so, it'll always be
sub-optimal which is a poor choice to make.

> I depend on the allocator to tell me when I've fed it too high of an
> order.  If we really need this, perhaps we should do an audit and then
> add a WARN_ON() for a few releases to catch the stragglers.
> 

I consider it buggy to ask for something so large that you always end up
with the worst option - vmalloc(). How about leaving it as a VM_BUG_ON
to get as many reports as possible on who is depending on this odd
behaviour?

If there are users with good reasons, then we could convert this to WARN_ON
to fix up the callers. I suspect that the allocator can already cope with
recieving a stupid order silently but slowly. It should go all the way to the
bottom and just never find anything useful and return NULL.  zone_watermark_ok
is the most dangerous looking part but even it should never get to MAX_ORDER
because it should always find there are not enough free pages and return
before it overruns.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
