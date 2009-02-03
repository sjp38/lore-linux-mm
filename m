Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB4B5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 07:26:47 -0500 (EST)
Date: Tue, 3 Feb 2009 12:26:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] SLQB slab allocator (try 2)
Message-ID: <20090203122644.GN9840@csn.ul.ie>
References: <20090123154653.GA14517@wotan.suse.de> <200902032250.55968.nickpiggin@yahoo.com.au> <20090203120139.GM9840@csn.ul.ie> <200902032307.09025.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200902032307.09025.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 03, 2009 at 11:07:07PM +1100, Nick Piggin wrote:
> On Tuesday 03 February 2009 23:01:39 Mel Gorman wrote:
> > On Tue, Feb 03, 2009 at 10:50:54PM +1100, Nick Piggin wrote:
> > > On Tuesday 03 February 2009 22:28:52 Mel Gorman wrote:
> > > > On Tue, Feb 03, 2009 at 09:36:24PM +1100, Nick Piggin wrote:
> > > > > I'd be interested to see how slub performs if booted with
> > > > > slub_min_objects=1 (which should give similar order pages to SLAB and
> > > > > SLQB).
> > > >
> > > > Just to clarify on this last point, do you mean slub_max_order=0 to
> > > > force order-0 allocations in SLUB?
> > >
> > > Hmm... I think slub_min_objects=1 should also do basically the same.
> > > Actually slub_min_object=1 and slub_max_order=1 should get closest I
> > > think.
> >
> > I'm going with slub_min_objects=1 and slub_max_order=0. A quick glance
> > of the source shows the calculation as
> >
> >         for (order = max(min_order,
> >                                 fls(min_objects * size - 1) - PAGE_SHIFT);
> >                         order <= max_order; order++) {
> >
> > so the max_order is inclusive not exclusive. This will force the order-0
> > allocations I think you are looking for.
> 
> Well, but in the case of really bad internal fragmentation in the page,
> SLAB will do order-1 allocations even if it doesn't strictly need to.
> Probably this isn't a huge deal, but I think if we do slub_min_objects=1,
> then SLUB won't care about number of objects per page, and slub_max_order=1
> will mean it stops caring about fragmentation after order-1. I think. Which
> would be pretty close to SLAB (depending on exactly how much fragmentation
> it cares about).
> 

Ok, very good point and I agree with your assessment. Tests are restarted with
slub_min_objects=1 slab_max_order=1. The dmesg line related to SLUB looks like

SLUB: Genslabs=13, HWalign=64, Order=0-1, MinObjects=1, CPUs=4, Nodes=1

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
