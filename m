Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 050456B0689
	for <linux-mm@kvack.org>; Fri, 18 May 2018 16:35:24 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id u7-v6so5740354plq.3
        for <linux-mm@kvack.org>; Fri, 18 May 2018 13:35:23 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id c23-v6si8233677pli.540.2018.05.18.13.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 13:35:22 -0700 (PDT)
Subject: Re: dma_sync_*_for_cpu and direction=TO_DEVICE (was Re: [PATCH 02/20]
 dma-mapping: provide a generic dma-noncoherent implementation)
References: <20180511075945.16548-1-hch@lst.de>
 <20180511075945.16548-3-hch@lst.de>
 <bad125dff49f6e49c895e818c9d1abb346a46e8e.camel@synopsys.com>
 <5ac5b1e3-9b96-9c7c-4dfe-f65be45ec179@synopsys.com>
 <20180518175004.GF17671@n2100.armlinux.org.uk>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <cecfe6bd-ef1f-1e25-bfcf-992d1f828efb@synopsys.com>
Date: Fri, 18 May 2018 13:35:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180518175004.GF17671@n2100.armlinux.org.uk>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>, "hch@lst.de" <hch@lst.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "deanbo422@gmail.com" <deanbo422@gmail.com>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 05/18/2018 10:50 AM, Russell King - ARM Linux wrote:
> On Fri, May 18, 2018 at 10:20:02AM -0700, Vineet Gupta wrote:
>> I never understood the need for this direction. And if memory serves me
>> right, at that time I was seeing twice the amount of cache flushing !
> It's necessary.  Take a moment to think carefully about this:
>
> 	dma_map_single(, dir)
>
> 	dma_sync_single_for_cpu(, dir)
>
> 	dma_sync_single_for_device(, dir)
>
> 	dma_unmap_single(, dir)

As an aside, do these imply a state machine of sorts - does a driver needs to 
always call map_single first ?

My original point of contention/confusion is the specific combinations of API and 
direction, specifically for_cpu(TO_DEV) and for_device(TO_CPU)

Semantically what does dma_sync_single_for_cpu(TO_DEV) even imply for a non dma 
coherent arch.
Your tables below have "none" for both, implying it is unlikely to be a real 
combination (for ARM and ARC atleast).

The other case, actually @dir TO_CPU, independent of for_{cpu, device}A  implies 
driver intends to touch it after the call, so it would invalidate any stray lines, 
unconditionally (and not just for speculative prefetch case).


> In the case of a DMA-incoherent architecture, the operations done at each
> stage depend on the direction argument:
>
> 	map		for_cpu		for_device	unmap
> TO_DEV	writeback	none		writeback	none
> TO_CPU	invalidate	invalidate*	invalidate	invalidate*
> BIDIR	writeback	invalidate	writeback	invalidate
>
> * - only necessary if the CPU speculatively prefetches.
>
> The multiple invalidations for the TO_CPU case handles different
> conditions that can result in data corruption, and for some CPUs, all
> four are necessary.

Can you please explain in some more detail, TO_CPU row, why invalidate is 
conditional sometimes.
