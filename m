Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CCEC86B02A9
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 02:07:38 -0400 (EDT)
Date: Wed, 14 Jul 2010 22:40:51 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
Message-ID: <20100715054050.GB3623@codeaurora.org>
References: <4C3C0032.5020702@codeaurora.org>
 <20100713150311B.fujita.tomonori@lab.ntt.co.jp>
 <20100713121420.GB4263@codeaurora.org>
 <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
 <20100714201149.GA14008@codeaurora.org>
 <20100714220536.GE18138@n2100.arm.linux.org.uk>
 <20100715012958.GB2239@codeaurora.org>
 <m1mxttiki1.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1mxttiki1.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 14, 2010 at 06:47:34PM -0700, Eric W. Biederman wrote:
> Zach Pfeffer <zpfeffer@codeaurora.org> writes:
> 
> > On Wed, Jul 14, 2010 at 11:05:36PM +0100, Russell King - ARM Linux wrote:
> >> On Wed, Jul 14, 2010 at 01:11:49PM -0700, Zach Pfeffer wrote:
> >> > If the DMA-API contained functions to allocate virtual space separate
> >> > from physical space and reworked how chained buffers functioned it
> >> > would probably work - but then things start to look like the VCM API
> >> > which does graph based map management.
> >> 
> >> Every additional virtual mapping of a physical buffer results in
> >> additional cache aliases on aliasing caches, and more workload for
> >> developers to sort out the cache aliasing issues.
> >> 
> >> What does VCM to do mitigate that?
> >
> > The VCM ensures that all mappings that map a given physical buffer:
> > IOMMU mappings, CPU mappings and one-to-one device mappings all map
> > that buffer using the same (or compatible) attributes. At this point
> > the only attribute that users can pass is CACHED. In the absence of
> > CACHED all accesses go straight through to the physical memory.
> >
> > The architecture of the VCM allows these sorts of consistency checks
> > to be made since all mappers of a given physical resource are
> > tracked. This is feasible because the physical resources we're
> > tracking are typically large.
> 
> On x86 this is implemented in the pat code, and could reasonably be
> generalized to be cross platform.
> 
> This is controlled by HAVE_PFNMAP_TRACKING and with entry points
> like track_pfn_vma_new.
> 
> Given that we already have an implementation that tracks the cached
> vs non-cached attribute using the dma api.  I don't see that the
> API has to change.  An implementation of the cached vs non-cached
> status for arm and other architectures is probably appropriate.
> 
> It is definitely true that getting your mapping caching attributes
> out of sync can be a problem.

Sure, but we're still stuck with needing lots of scatterlist list
elements and needing to copy them to share physical buffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
