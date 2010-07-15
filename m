Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B92276B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 01:41:58 -0400 (EDT)
Date: Wed, 14 Jul 2010 18:41:48 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
Message-ID: <20100715014148.GC2239@codeaurora.org>
References: <20100713121420.GB4263@codeaurora.org>
 <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
 <20100714201149.GA14008@codeaurora.org>
 <20100715080710T.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100715080710T.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux@arm.linux.org.uk, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 15, 2010 at 08:07:28AM +0900, FUJITA Tomonori wrote:
> On Wed, 14 Jul 2010 13:11:49 -0700
> Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
> 
> > On Wed, Jul 14, 2010 at 10:59:38AM +0900, FUJITA Tomonori wrote:
> > > On Tue, 13 Jul 2010 05:14:21 -0700
> > > Zach Pfeffer <zpfeffer@codeaurora.org> wrote:
> > > 
> > > > > You mean that you want to specify this alignment attribute every time
> > > > > you create an IOMMU mapping? Then you can set segment_boundary_mask
> > > > > every time you create an IOMMU mapping. It's odd but it should work.
> > > > 
> > > > Kinda. I want to forget about IOMMUs, devices and CPUs. I just want to
> > > > create a mapping that has the alignment I specify, regardless of the
> > > > mapper. The mapping is created on a VCM and the VCM is associated with
> > > > a mapper: a CPU, an IOMMU'd device or a direct mapped device.
> > > 
> > > Sounds like you can do the above with the combination of the current
> > > APIs, create a virtual address and then an I/O address.
> > > 
> > 
> > Yes, and that's what the implementation does - and all the other
> > implementations that need to do this same thing. Why not solve the
> > problem once?
> 
> Why we we need a new abstraction layer to solve the problem that the
> current API can handle?

The current API can't really handle it because the DMA API doesn't
separate buffer allocation from buffer mapping. To use the DMA API a
scatterlist would need to be synthesized from the physical buffers
that we've allocated. 

For instance: I need 10, 1 MB physical buffers and a 64 KB physical
buffer. With the DMA API I need to allocate 10*1MB/PAGE_SIZE + 64
KB/PAGE_SIZE scatterlist elements, fix them all up to follow the
chaining specification and then go through all of them again to fix up
their virtual mappings for the mapper that's mapping the physical
buffer. If I want to share the buffer with another device I have to
make a copy of the entire thing then fix up the virtual mappings for
the other device I'm sharing with. The VCM splits the two things up so
that I do a physical allocation, then 2 virtual allocations and then
map both.

> 
> The above two operations don't sound too complicated. The combination
> of the current API sounds much simpler than your new abstraction.
> 
> Please show how the combination of the current APIs doesn't
> work. Otherwise, we can't see what's the benefit of your new
> abstraction.

See above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
