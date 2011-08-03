Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E69676B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 13:43:56 -0400 (EDT)
Subject: Re: [PATCH 6/8] drivers: add Contiguous Memory Allocator
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <201107051427.44899.arnd@arndb.de>
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
	 <1309851710-3828-7-git-send-email-m.szyprowski@samsung.com>
	 <20110705113345.GA8286@n2100.arm.linux.org.uk>
	 <201107051427.44899.arnd@arndb.de>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 03 Aug 2011 12:43:50 -0500
Message-ID: <1312393430.2855.51.camel@mulgrave>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Chunsang Jeong <chunsang.jeong@linaro.org>, Michal Nazarewicz <mina86@mina86.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, ksummit-2011-discuss@lists.linux-foundation.org

[cc to ks-discuss added, since this may be a relevant topic]

On Tue, 2011-07-05 at 14:27 +0200, Arnd Bergmann wrote:
> On Tuesday 05 July 2011, Russell King - ARM Linux wrote:
> > On Tue, Jul 05, 2011 at 09:41:48AM +0200, Marek Szyprowski wrote:
> > > The Contiguous Memory Allocator is a set of helper functions for DMA
> > > mapping framework that improves allocations of contiguous memory chunks.
> > > 
> > > CMA grabs memory on system boot, marks it with CMA_MIGRATE_TYPE and
> > > gives back to the system. Kernel is allowed to allocate movable pages
> > > within CMA's managed memory so that it can be used for example for page
> > > cache when DMA mapping do not use it. On dma_alloc_from_contiguous()
> > > request such pages are migrated out of CMA area to free required
> > > contiguous block and fulfill the request. This allows to allocate large
> > > contiguous chunks of memory at any time assuming that there is enough
> > > free memory available in the system.
> > > 
> > > This code is heavily based on earlier works by Michal Nazarewicz.
> > 
> > And how are you addressing the technical concerns about aliasing of
> > cache attributes which I keep bringing up with this and you keep
> > ignoring and telling me that I'm standing in your way.

Just to chime in here, parisc has an identical issue.  If the CPU ever
sees an alias with different attributes for the same page, it will HPMC
the box (that's basically the bios will kill the system as being
architecturally inconsistent), so an architecture neutral solution on
this point is essential to us as well.

> This is of course an important issue, and it's the one item listed as
> TODO in the introductory mail that sent.
> 
> It's also a preexisting problem as far as I can tell, and it needs
> to be solved in __dma_alloc for both cases, dma_alloc_from_contiguous
> and __alloc_system_pages as introduced in patch 7.
> 
> We've discussed this back and forth, and it always comes down to
> one of two ugly solutions:
> 
> 1. Put all of the MIGRATE_CMA and pages into highmem and change
> __alloc_system_pages so it also allocates only from highmem pages.
> The consequences of this are that we always need to build kernels
> with highmem enabled and that we have less lowmem on systems that
> are already small, both of which can be fairly expensive unless
> you have lots of highmem already.

So this would require that systems using the API have a highmem? (parisc
doesn't today).

> 2. Add logic to unmap pages from the linear mapping, which is
> very expensive because it forces the use of small pages in the
> linear mapping (or in parts of it), and possibly means walking
> all page tables to remove the PTEs on alloc and put them back
> in on free.
> 
> I believe that Chunsang Jeong from Linaro is planning to
> implement both variants and post them for review, so we can
> decide which one to merge, or even to merge both and make
> it a configuration option. See also
> https://blueprints.launchpad.net/linaro-mm-sig/+spec/engr-mm-dma-mapping-2011.07
> 
> I don't think we need to make merging the CMA patches depending on
> the other patches, it's clear that both need to be solved, and
> they are independent enough.

I assume from the above that ARM has a hardware page walker?

The way I'd fix this on parisc, because we have a software based TLB, is
to rely on the fact that a page may only be used either for DMA or for
Page Cache, so the aliases should never be interleaved.  Since you know
the point at which the page flips from DMA to Cache (and vice versa),
I'd purge the TLB entry and flush the page at that point and rely on the
usage guarantees to ensure that the alias TLB entry doesn't reappear.
This isn't inexpensive but the majority of the cost is the cache flush
which is a requirement to clean the aliases anyway (a TLB entry purge is
pretty cheap).

Would this work for the ARM hardware walker as well?  It would require
you to have a TLB entry purge instruction as well as some architectural
guarantees about not speculating the TLB.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
