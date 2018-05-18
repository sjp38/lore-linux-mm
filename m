Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1360C6B068F
	for <linux-mm@kvack.org>; Fri, 18 May 2018 17:33:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z7-v6so6257865wrg.11
        for <linux-mm@kvack.org>; Fri, 18 May 2018 14:33:31 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id p187-v6si5967798wme.58.2018.05.18.14.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 14:33:29 -0700 (PDT)
Date: Fri, 18 May 2018 22:33:10 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: dma_sync_*_for_cpu and direction=TO_DEVICE (was Re: [PATCH
 02/20] dma-mapping: provide a generic dma-noncoherent implementation)
Message-ID: <20180518213309.GG17671@n2100.armlinux.org.uk>
References: <20180511075945.16548-1-hch@lst.de>
 <20180511075945.16548-3-hch@lst.de>
 <bad125dff49f6e49c895e818c9d1abb346a46e8e.camel@synopsys.com>
 <5ac5b1e3-9b96-9c7c-4dfe-f65be45ec179@synopsys.com>
 <20180518175004.GF17671@n2100.armlinux.org.uk>
 <182840dedb4890a88c672b1c5d556920bf89a8fb.camel@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <182840dedb4890a88c672b1c5d556920bf89a8fb.camel@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Cc: "deanbo422@gmail.com" <deanbo422@gmail.com>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "hch@lst.de" <hch@lst.de>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "Vineet.Gupta1@synopsys.com" <Vineet.Gupta1@synopsys.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>

On Fri, May 18, 2018 at 07:57:34PM +0000, Alexey Brodkin wrote:
> Hi Russel,

That's Russell.

> On Fri, 2018-05-18 at 18:50 +0100, Russell King - ARM Linux wrote:
> > It's necessary.  Take a moment to think carefully about this:
> > 
> >         dma_map_single(, dir)
> > 
> >         dma_sync_single_for_cpu(, dir)
> > 
> >         dma_sync_single_for_device(, dir)
> > 
> >         dma_unmap_single(, dir)
> > 
> > In the case of a DMA-incoherent architecture, the operations done at each
> > stage depend on the direction argument:
> > 
> >         map             for_cpu         for_device      unmap
> > TO_DEV  writeback       none            writeback       none
> > TO_CPU  invalidate      invalidate*     invalidate      invalidate*
> > BIDIR   writeback       invalidate      writeback       invalidate
> > 
> > * - only necessary if the CPU speculatively prefetches.
> 
> I think invalidation of DMA buffer is required on for_cpu(TO_CPU) even
> if CPU doesn't preferch - what if we reuse the same buffer for multiple
> reads from DMA device?

That's fine - for non-coherent DMA, the CPU caches will only end up
containing data for that memory if:
- the CPU speculatively fetches data from that memory, or
- the CPU explicitly touches that memory

> > The multiple invalidations for the TO_CPU case handles different
> > conditions that can result in data corruption, and for some CPUs, all
> > four are necessary.
> 
> I would agree that map()/unmap() a quite a special cases and so depending
> on direction we need to execute in them either for_cpu() or for_device()
> call-backs depending on direction.
> 
> As for invalidation in case of for_device(TO_CPU) I still don't see
> a rationale behind it. Would be interesting to see a real example where
> we benefit from this.

Yes, you could avoid that, but depending how you structure the
architecture implementation, it can turn out to be a corner case.
The above table is precisely how 32-bit ARM is implemented, because
the way we implement them is based on who owns the memory - the "map"
and "for_device" operations translate internally to a cpu-to-device
ownership transition of the buffer.  Similar for "unmap" and "to_cpu".
It basically avoids having to add additional functions at the lower
implementation levels.

> > Things get more interesting if the implementation behind the DMA API has
> > to copy data between the buffer supplied to the mapping and some DMA
> > accessible buffer:
> > 
> >         map             for_cpu         for_device      unmap
> > TO_DEV  copy to dma     none            copy to dma     none
> > TO_CPU  none            copy to cpu     none            copy to cpu
> > BIDIR   copy to dma     copy to cpu     copy to dma     copy to cpu
> > 
> > So, in both cases, the value of the direction argument defines what you
> > need to do in each call.
> 
> Interesting enough in your seond table (which describes more complicated
> case indeed) you set "none" for for_device(TO_CPU) which looks logical
> to me.
> 
> So IMHO that's what make sense:
> ---------------------------->8-----------------------------
>         map             for_cpu         for_device      unmap
> TO_DEV  writeback       none            writeback       none
> TO_CPU  none            invalidate      none            invalidate*
> BIDIR   writeback       invalidate      writeback       invalidate*
> ---------------------------->8-----------------------------

That doesn't make sense for the TO_CPU case.  If the caches contain
dirty cache lines, and you're DMAing from the device to the system
RAM, other system activity can cause the dirty cache lines to be
evicted (written back) to memory which the DMA has already overwritten.
The result is data corruption.  So, you really can't have "none" in
the "map" case there.

Given that, the "for_cpu" case becomes dependent on whether the CPU
speculatively prefetches.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
