Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 742706B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 11:10:11 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id p65so118739477wmp.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 08:10:11 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id w195si9528764wmd.112.2016.03.31.08.10.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 08:10:08 -0700 (PDT)
Date: Thu, 31 Mar 2016 16:09:23 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 2/4] scatterlist: add sg_alloc_table_from_buf() helper
Message-ID: <20160331150923.GL19428@n2100.arm.linux.org.uk>
References: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
 <1459427384-21374-3-git-send-email-boris.brezillon@free-electrons.com>
 <20160331141412.GK19428@n2100.arm.linux.org.uk>
 <20160331164557.544ed780@bbrezillon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160331164557.544ed780@bbrezillon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>
Cc: David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>, linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Vinod Koul <vinod.koul@intel.com>, Richard Weinberger <richard@nod.at>, Joerg Roedel <joro@8bytes.org>, linux-kernel@vger.kernel.org, linux-spi@vger.kernel.org, Vignesh R <vigneshr@ti.com>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Mark Brown <broonie@kernel.org>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, dmaengine@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, linux-media@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org, Mauro Carvalho Chehab <m.chehab@samsung.com>

On Thu, Mar 31, 2016 at 04:45:57PM +0200, Boris Brezillon wrote:
> Hi Russell,
> 
> On Thu, 31 Mar 2016 15:14:13 +0100
> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> 
> > On Thu, Mar 31, 2016 at 02:29:42PM +0200, Boris Brezillon wrote:
> > > sg_alloc_table_from_buf() provides an easy solution to create an sg_table
> > > from a virtual address pointer. This function takes care of dealing with
> > > vmallocated buffers, buffer alignment, or DMA engine limitations (maximum
> > > DMA transfer size).
> > 
> > Please note that the DMA API does not take account of coherency of memory
> > regions other than non-high/lowmem - there are specific extensions to
> > deal with this.
> 
> Ok, you said 'non-high/lowmem', this means vmalloced and kmapped buffers
> already fall in this case, right?
> 
> Could you tell me more about those specific extensions?

I was slightly confused - the extensions I was thinking of are those
listed at the bottom of Documentation/cachetlb.txt, which have nothing
to do with DMA.

However, it's probably worth reading Documentation/DMA-API-HOWTO.txt
to read up on what kinds of memory are considered to be DMA-able in
the kernel.

> > What this means is that having an API that takes any virtual address
> > pointer, converts it to a scatterlist which is then DMA mapped, is
> > unsafe.
> 
> Which means some implementations already get this wrong (see
> spi_map_buf(), and I'm pretty sure it's not the only one).

Quite possible, but that is driver stuff, and driver stuff gets things
wrong all the time. :)

> > It'll be okay for PIPT and non-aliasing VIPT cache architectures, but
> > for other cache architectures this will hide this problem and make
> > review harder.
> > 
> 
> Ok, you lost me. I'll have to do my homework and try to understand what
> this means :).

P = physical address
V = virtual address
I = indexed
T = tag

The tag is held in each cache line.  When a location is looked up in the
cache, an index is used to locate a set of cache lines and the tag is
compared to check which cache line in the set is the correct one (or
whether the address even exists in the cache.)

How the index and tag are derived varies between cache architectures.

PIPT = indexed by physical address, tagged with physical address.  Never
aliases with itself in the presence of multiple virtual mappings.

VIPT = indexed by virtual address, tagged with physical address.  If the
bits from the virtual address do not overlap the MMU page size, it is
also alias free, otherwise aliases can exist, but can be eliminated by
"cache colouring" - ensuring that a physical address is always mapped
with the same overlapping bits.

VIVT = indexed by virtual address, tagged with virtual address.  The
worst kind of cache, since every different mapping of the same physical
address is guaranteed by design to alias with other mappings.

There is little cache colouring between different kernel mappings (eg,
between lowmem and vmalloc space.)

What this means is that, while the DMA API takes care of DMA aliases
in the lowmem mappings, an alias-prone VIPT cache will remain incoherent
with DMA if it is remapped into vmalloc space, and the mapping happens
to have a different cache colour.  In other words, this is a data
corruption issue.

Hence, taking a range of vmalloc() addresses, converting them into a
scatterlist, then using the DMA API on the scatterlist _only_ guarantees
that the lowmem (and kmap'd highmem mappings) are coherent with DMA.
There is no way for the DMA API to know that other mappings exist, and
obviously flushing every possible cache line just because a mapping might
exist multiplies the expense of the DMA API: not only in terms of time
spent running through all the possibilities, which doubles for every
aliasing bit of VIPT, but also TLB pressure since you'd have to create
a mapping for each alias and tear it back down.

VIVT is even worse, since there is no other virtual mapping which is
coherent, would need to be known, and each mapping would need to be
individually flushed.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
