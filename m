Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 38DC96B02A5
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 18:20:05 -0400 (EDT)
Date: Tue, 20 Jul 2010 15:20:01 -0700
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: Re: [RFC 1/3 v3] mm: iommu: An API to unify IOMMU, CPU and device
 memory management
Message-ID: <20100720221959.GC12250@codeaurora.org>
References: <20100713121420.GB4263@codeaurora.org>
 <20100714104353B.fujita.tomonori@lab.ntt.co.jp>
 <20100714201149.GA14008@codeaurora.org>
 <20100715080710T.fujita.tomonori@lab.ntt.co.jp>
 <20100715014148.GC2239@codeaurora.org>
 <20100719082213.GA7421@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100719082213.GA7421@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, ebiederm@xmission.com, linux-arch@vger.kernel.org, dwalker@codeaurora.org, mel@csn.ul.ie, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 09:22:13AM +0100, Russell King - ARM Linux wrote:
> On Wed, Jul 14, 2010 at 06:41:48PM -0700, Zach Pfeffer wrote:
> > On Thu, Jul 15, 2010 at 08:07:28AM +0900, FUJITA Tomonori wrote:
> > > Why we we need a new abstraction layer to solve the problem that the
> > > current API can handle?
> > 
> > The current API can't really handle it because the DMA API doesn't
> > separate buffer allocation from buffer mapping.
> 
> That's not entirely correct.  The DMA API provides two things:
> 
> 1. An API for allocating DMA coherent buffers
> 2. An API for mapping streaming buffers
> 
> Some implementations of (2) end up using (1) to work around broken
> hardware - but that's a separate problem (and causes its own set of
> problems.)
> 
> > For instance: I need 10, 1 MB physical buffers and a 64 KB physical
> > buffer. With the DMA API I need to allocate 10*1MB/PAGE_SIZE + 64
> > KB/PAGE_SIZE scatterlist elements, fix them all up to follow the
> > chaining specification and then go through all of them again to fix up
> > their virtual mappings for the mapper that's mapping the physical
> > buffer.
> 
> You're making it sound like extremely hard work.
> 
> 	struct scatterlist *sg;
> 	int i, nents = 11;
> 
> 	sg = kmalloc(sizeof(*sg) * nents, GFP_KERNEL);
> 	if (!sg)
> 		return -ENOMEM;
> 
> 	sg_init_table(sg, nents);
> 	for (i = 0; i < nents; i++) {
> 		if (i != nents - 1)
> 			len = 1048576;
> 		else
> 			len = 64*1024;
> 		buf = alloc_buffer(len);
> 		sg_set_buf(&sg[i], buf, len);
> 	}
> 
> There's no need to split the scatterlist elements up into individual
> pages - the block layer doesn't do that when it passes scatterlists
> down to block device drivers.

Okay. Thank you for the example.

> 
> I'm not saying that it's reasonable to pass (or even allocate) a 1MB
> buffer via the DMA API.

But given a bunch of large chunks of memory, is there any API that can
manage them (asked this on the other thread as well)?

> > If I want to share the buffer with another device I have to
> > make a copy of the entire thing then fix up the virtual mappings for
> > the other device I'm sharing with.
> 
> This is something the DMA API doesn't do - probably because there hasn't
> been a requirement for it.
> 
> One of the issues for drivers is that by separating the mapped scatterlist
> from the input buffer scatterlist, it creates something else for them to
> allocate, which causes an additional failure point - and as all users sit
> well with the current API, there's little reason to change especially
> given the number of drivers which would need to be updated.
> 
> What you can do is:
> 
> struct map {
> 	dma_addr_t addr;
> 	size_t len;
> };
> 
> int map_sg(struct device *dev, struct scatterlist *list,
> 	unsigned int nents, struct map *map, enum dma_data_direction dir)
> {
> 	struct scatterlist *sg;
> 	unsigned int i, j = 0;
> 
> 	for_each_sg(list, sg, nents, i) {
> 		map[j]->addr = dma_map_page(dev, sg_page(sg), sg->offset,
> 					sg->length, dir);
> 		map[j]->len = length;
> 		if (dma_mapping_error(map[j]->addr))
> 			break;
> 		j++;
> 	}
> 
> 	return j;
> }
> 
> void unmap(struct device *dev, struct map *map, unsigned int nents,
> 	enum dma_data_direction dir)
> {
> 	while (nents) {
> 		dma_unmap_page(dev, map->addr, map->len, dir);
> 		map++;
> 		nents--;
> 	}
> }
> 
> Note: this may not be portable to all architectures.  It may also break
> if there's something like the dmabounce or swiotlb code remapping buffers
> which don't fit the DMA mask for the device - that's a different problem.

True but given a higher-level "map(virtual_range, physical_chunks)"
wouldn't break on all architectures.

> You can then map the same scatterlist into multiple different 'map'
> arrays for several devices simultaneously.  What you can't do is access
> the buffers from the CPU while they're mapped to any device.

Which is considered a feature  ;)

> I'm not saying that you should do the above - I'm just proving that it's
> not as hard as you seem to be making out.

That's fair. I didn't mean to say things were hard, just that using
the DMA API for big buffer management and mapping was not ideal since
our goals are to allocate big buffers using a device specific
algorithm, give them various attributes and share them. What we
created looked generally useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
