Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l32LM9bI014362
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 17:22:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l32LM9Bn041238
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:22:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l32LM82j027876
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:22:09 -0600
Subject: Re: [PATCH 1/2] Generic Virtual Memmap suport for SPARSEMEM
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0704021351590.1224@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
	 <1175547000.22373.89.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021351590.1224@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 02 Apr 2007 14:22:04 -0700
Message-Id: <1175548924.22373.109.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 14:00 -0700, Christoph Lameter wrote:
> On Mon, 2 Apr 2007, Dave Hansen wrote:
> > > +	} else
> > > +		return __alloc_bootmem_node(NODE_DATA(node), size, size,
> > > +					__pa(MAX_DMA_ADDRESS));
> > > +}
> > 
> > Hmmmmmmm.  Can we combine this with sparse_index_alloc()?  Also, why not
> > just use the slab for this?
> 
> Use a slab for page sized allocations? No.

Why not?  We use it above for sparse_index_alloc() and if it is doing
something wrong, I'd love to fix it.  Can you elaborate?

> > Let's get rid of the _block() part, too.  I'm not sure it does any good.
> > At least make it _bytes() so that we know what the units are.  Also, if
> > you're just going to round up internally and _not_ use the slab, can you
> > just make the argument in pages, or even order?
> 
> Its used for page sized allocations.

Ok, then let's make it take pages of some kind or its argument.  

> > Can you think of any times when we'd want that BUG_ON() to be a
> > WARN_ON(), instead?  I can see preferring having my mem_map[] on the
> > wrong node than hitting a BUG().
> 
> We should probably have some error handling there instead of the BUG.
> 
> > > +#ifndef ARCH_POPULATES_VIRTUAL_MEMMAP
> > > +/*
> > > + * Virtual memmap populate functionality for architectures that support
> > > + * PMDs for huge pages like i386, x86_64 etc.
> > > + */
> > 
> > How about:
> > 
> > /*
> >  * Virtual memmap support for architectures that use Linux pagetables
> >  * natively in hardware, and support mapping huge pages with PMD
> >  * entries.
> >  */
> > 
> > It wouldn't make sense to map the vmemmap area with Linux pagetables on
> > an arch that didn't use them in hardware, right?  So, perhaps this
> > doesn't quite belong in mm/sparse.c.  Perhaps we need
> > arch/x86/sparse.c. ;)
> 
> I just extended this in V2 to also work on IA64. Its pretty generic.

Can you extend it to work on ppc? ;)

You haven't posted V2, right?

> > 
> >          map = alloc_remap(nid, sizeof(struct page) * PAGES_PER_SECTION);
> >          if (map)
> >                  return map;
> > 
> > +        map = alloc_vmemmap(map, PAGES_PER_SECTION, nid);
> > +        if (map)
> > +                return map;
> > +
> >          map = alloc_bootmem_node(NODE_DATA(nid),
> >                          sizeof(struct page) * PAGES_PER_SECTION);
> >          if (map)
> >                  return map;
> > 
> > Then, do whatever magic you want in alloc_vmemmap().
> 
> That would break if alloc_vmemmap returns NULL because it cannot allocate 
> memory.

OK, that makes sense.  However, it would still be nice to hide that
#ifdef somewhere that people are a bit less likely to run into it.  It's
just one #ifdef, so if you can kill it, great.  Otherwise, they pile up
over time and _do_ cause real readability problems.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
