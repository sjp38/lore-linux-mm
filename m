Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7076A6B0691
	for <linux-mm@kvack.org>; Fri, 18 May 2018 17:56:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 142-v6so3906353wmt.1
        for <linux-mm@kvack.org>; Fri, 18 May 2018 14:56:09 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id m12-v6si4875430wrh.58.2018.05.18.14.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 14:56:07 -0700 (PDT)
Date: Fri, 18 May 2018 22:55:48 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: dma_sync_*_for_cpu and direction=TO_DEVICE (was Re: [PATCH
 02/20] dma-mapping: provide a generic dma-noncoherent implementation)
Message-ID: <20180518215548.GH17671@n2100.armlinux.org.uk>
References: <20180511075945.16548-1-hch@lst.de>
 <20180511075945.16548-3-hch@lst.de>
 <bad125dff49f6e49c895e818c9d1abb346a46e8e.camel@synopsys.com>
 <5ac5b1e3-9b96-9c7c-4dfe-f65be45ec179@synopsys.com>
 <20180518175004.GF17671@n2100.armlinux.org.uk>
 <cecfe6bd-ef1f-1e25-bfcf-992d1f828efb@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cecfe6bd-ef1f-1e25-bfcf-992d1f828efb@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>, "hch@lst.de" <hch@lst.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "deanbo422@gmail.com" <deanbo422@gmail.com>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, May 18, 2018 at 01:35:08PM -0700, Vineet Gupta wrote:
> On 05/18/2018 10:50 AM, Russell King - ARM Linux wrote:
> >On Fri, May 18, 2018 at 10:20:02AM -0700, Vineet Gupta wrote:
> >>I never understood the need for this direction. And if memory serves me
> >>right, at that time I was seeing twice the amount of cache flushing !
> >It's necessary.  Take a moment to think carefully about this:
> >
> >	dma_map_single(, dir)
> >
> >	dma_sync_single_for_cpu(, dir)
> >
> >	dma_sync_single_for_device(, dir)
> >
> >	dma_unmap_single(, dir)
> 
> As an aside, do these imply a state machine of sorts - does a driver needs
> to always call map_single first ?

Kind-of, but some drivers do omit some of the dma_sync_*() calls.
For example, if a buffer is written to, then mapped with TO_DEVICE,
and then the CPU wishes to write to it, it's fairly common that a
driver omits the dma_sync_single_for_cpu() call.  If you think about
the cases I gave and what cache operations happen, such a scenario
practically turns out to be safe.

> My original point of contention/confusion is the specific combinations of
> API and direction, specifically for_cpu(TO_DEV) and for_device(TO_CPU)

Remember that it is expected that all calls for a mapping use the
same direction argument while that mapping exists.  In other words,
if you call dma_map_single(TO_DEVICE) and then use any of the other
functions, the other functions will also use TO_DEVICE.  The DMA
direction argument describes the direction of the DMA operation
being performed on the buffer, not on the individual dma_* operation.

What isn't expected at arch level is for drivers to do:

	dma_map_single(TO_DEVICE)
	dma_sync_single_for_cpu(FROM_DEVICE)

or vice versa.

> Semantically what does dma_sync_single_for_cpu(TO_DEV) even imply for a non
> dma coherent arch.
> 
> Your tables below have "none" for both, implying it is unlikely to be a real
> combination (for ARM and ARC atleast).

Very little for the cases that I've stated (and as I mentioned
above, some drivers do omit the call in that case.)

> The other case, actually @dir TO_CPU, independent of for_{cpu, device} 
> implies driver intends to touch it after the call, so it would invalidate
> any stray lines, unconditionally (and not just for speculative prefetch
> case).

If you don't have a CPU that speculatively prefetches, and you've
already had to invalidate the cache lines (to avoid write-backs
corrupting DMA'd data) then there's no need for the architecture
to do any work at the for_cpu(TO_CPU) case - the CPU shouldn't
be touching cache lines that are part of the buffer while it is
mapped, which means a non-speculating CPU won't pull in any
cache lines without an explicit access.

Speculating CPUs are different.  The action of the speculation is
to try and guess what data the program wants to access ahead of
the program flow.  That causes the CPU to prefetch data into the
cache.  The point in the program flow that this happens is not
really determinant to the programmer.  This means that if you try
to read from the DMA buffer after the DMA operation has complete
without invalidating the cache between the DMA completing and the
CPU reading, you have no guarantee that you're reading the data
that the DMA operation has been written.  The cache may have
loaded itself with data before the DMA operation completed, and
the CPU may see that stale data.

The difference between non-speculating CPUs and speculating CPUs
is that for non-speculating CPUs, caches work according to explicit
accesses by the program, and the program is stalled while the data
is fetched from external memory.  Speculating CPUs try to predict
ahead of time what data the program will require in the future,
and attempt to load that data into the caches _before_ the program
requires it - which means that the program suffers fewer stalls.

> >In the case of a DMA-incoherent architecture, the operations done at each
> >stage depend on the direction argument:
> >
> >	map		for_cpu		for_device	unmap
> >TO_DEV	writeback	none		writeback	none
> >TO_CPU	invalidate	invalidate*	invalidate	invalidate*
> >BIDIR	writeback	invalidate	writeback	invalidate
> >
> >* - only necessary if the CPU speculatively prefetches.
> >
> >The multiple invalidations for the TO_CPU case handles different
> >conditions that can result in data corruption, and for some CPUs, all
> >four are necessary.
> 
> Can you please explain in some more detail, TO_CPU row, why invalidate is
> conditional sometimes.

See above - I hope my explanation above is sufficient.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
