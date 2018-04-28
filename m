Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1375E6B000C
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 04:42:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m68so3474312pfm.20
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 01:42:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b39-v6si3087268plb.456.2018.04.28.01.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 28 Apr 2018 01:42:23 -0700 (PDT)
Date: Sat, 28 Apr 2018 01:42:21 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180428084221.GD31684@infradead.org>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180427053556.GB11339@infradead.org>
 <20180427161456.GD27853@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180427161456.GD27853@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, mhocko@kernel.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, Juergen Gross <jgross@suse.com>, linux-spi@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-scsi@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Fri, Apr 27, 2018 at 04:14:56PM +0000, Luis R. Rodriguez wrote:
> But curious, on a standard qemu x86_x64 KVM guest, which of the
> drivers do we know for certain *are* being used from the ones
> listed?

On a KVM guest probably none.  But not all the world is relatively
sane and standardized VMs unfortunately.

> > But even more importantly
> > we have plenty driver using it through dma_alloc_* and a small DMA
> > mask, and they are in use 
> 
> Do we have a list of users for x86 with a small DMA mask?
> Or, given that I'm not aware of a tool to be able to look
> for this in an easy way, would it be good to find out which
> x86 drivers do have a small mask?

Basically you'll have to grep for calls to dma_set_mask/
dma_set_coherent_mask/dma_set_mask_and_coherent and their pci_*
wrappers with masks smaller 32-bit.  Some use numeric values,
some use DMA_BIT_MASK and various places uses local variables
or struct members to parse them, so finding them will be a bit
more work.  Nothing a coccinell expert couldn't solve, though :)

> > - we actually had a 4.16 regression due to them.
> 
> Ah what commit was the culprit? Is that fixed already? If so what
> commit?

66bdb147 ("swiotlb: Use dma_direct_supported() for swiotlb_ops")

> > > SCSI is *severely* affected:
> > 
> > Not really.  We have unchecked_isa_dma to support about 4 drivers,
> 
> Ah very neat:
> 
>   * CONFIG_CHR_DEV_OSST - "SCSI OnStream SC-x0 tape support"
>   * CONFIG_SCSI_ADVANSYS - "AdvanSys SCSI support"
>   * CONFIG_SCSI_AHA1542 - "Adaptec AHA1542 support"
>   * CONFIG_SCSI_ESAS2R - "ATTO Technology's ExpressSAS RAID adapter driver"
> 
> > and less than a hand ful of drivers doing stupid things, which can
> > be fixed easily, and just need a volunteer.
> 
> Care to list what needs to be done? Can an eager beaver student do it?

Drop the drivers, as in my branch I prepared a while ago would be
easiest:

http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/unchecked_isa_dma

But unlike the other few aha1542 actually seems to have active users,
or at least had recently.  I'll need to send this out as a RFC, but
don't really expect it to fly.

If it doesn't we'll need to enhance swiotlb to support a ISA DMA pool
in addition to current 32-bit DMA pool, and also convert aha1542 to
use the DMA API.  Not really student material.

> > > That's the end of the review of all current explicit callers on x86.
> > > 
> > > # dma_alloc_coherent_gfp_flags() and dma_generic_alloc_coherent()
> > > 
> > > dma_alloc_coherent_gfp_flags() and dma_generic_alloc_coherent() set
> > > GFP_DMA if if (dma_mask <= DMA_BIT_MASK(24))
> > 
> > All that code is long gone and replaced with dma-direct.  Which still
> > uses GFP_DMA based on the dma mask, though - see above.
> 
> And that's mostly IOMMU code, on the alloc() dma_map_ops.

It is the dma mapping API, which translates the dma mask to the right
zone, and probably is the biggest user of ZONE_DMA in modern systems.

Currently there are still various arch and iommu specific
implementations of the allocator decisions, but I'm working to
consolidate them into common code.
