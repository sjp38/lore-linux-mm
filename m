Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D59DC6B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 01:35:58 -0400 (EDT)
Date: Wed, 14 Jul 2010 22:35:46 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
Message-ID: <20100715053546.GA3623@codeaurora.org>
References: <4C3C0032.5020702@codeaurora.org>
 <20100713150311B.fujita.tomonori@lab.ntt.co.jp>
 <20100713121420.GB4263@codeaurora.org>
 <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
 <20100714201149.GA14008@codeaurora.org>
 <20100714220536.GE18138@n2100.arm.linux.org.uk>
 <20100715012958.GB2239@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100715012958.GB2239@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 14, 2010 at 06:29:58PM -0700, Zach Pfeffer wrote:
> On Wed, Jul 14, 2010 at 11:05:36PM +0100, Russell King - ARM Linux wrote:
> > On Wed, Jul 14, 2010 at 01:11:49PM -0700, Zach Pfeffer wrote:
> > > If the DMA-API contained functions to allocate virtual space separate
> > > from physical space and reworked how chained buffers functioned it
> > > would probably work - but then things start to look like the VCM API
> > > which does graph based map management.
> > 
> > Every additional virtual mapping of a physical buffer results in
> > additional cache aliases on aliasing caches, and more workload for
> > developers to sort out the cache aliasing issues.
> > 
> > What does VCM to do mitigate that?
> 
> The VCM ensures that all mappings that map a given physical buffer:
> IOMMU mappings, CPU mappings and one-to-one device mappings all map
> that buffer using the same (or compatible) attributes. At this point
> the only attribute that users can pass is CACHED. In the absence of
> CACHED all accesses go straight through to the physical memory.
> 
> The architecture of the VCM allows these sorts of consistency checks
> to be made since all mappers of a given physical resource are
> tracked. This is feasible because the physical resources we're
> tracking are typically large.

A few more things...

In addition to CACHED, the VCMM can support different cache policies
as long as the architecture can support it - they get passed down
through the device map call.

In addition, handling physical mappings in the VCMM enables it to
perform refcounting on the physical chunks (ie, to see how many
virtual spaces it's been mapped to, including the kernel's). This
allows it to turn on any coherency protocols that are available in
hardware (ie, setting the shareable bit on something that is mapped to
more than one virtual space). That same attribute can be left off on a
buffer that has only one virtual mapping (ie, scratch buffers used by
one device only). It is then up to the underlying system to deal with
that shared attribute - to enable redirection if it's supported, or to
force something to be non-cacheable, etc. Doing it all through the
VCMM allows all these mechanisms be worked out once per architecture
and then reused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
