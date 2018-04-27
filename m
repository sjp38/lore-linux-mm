Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 201D96B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 12:14:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y6-v6so1771771wrm.10
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 09:14:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l48-v6si1798844edd.186.2018.04.27.09.14.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Apr 2018 09:14:57 -0700 (PDT)
Date: Fri, 27 Apr 2018 16:14:56 +0000
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180427161456.GD27853@wotan.suse.de>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180427053556.GB11339@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180427053556.GB11339@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, mhocko@kernel.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, Juergen Gross <jgross@suse.com>, linux-spi@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-scsi@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Thu, Apr 26, 2018 at 10:35:56PM -0700, Christoph Hellwig wrote:
> On Thu, Apr 26, 2018 at 09:54:06PM +0000, Luis R. Rodriguez wrote:
> > In practice if you don't have a floppy device on x86, you don't need ZONE_DMA,
> 
> I call BS on that, 

I did not explain though that it was not me who claimed this though.
The list displayed below is the result of trying to confirm/deny this,
and what could be done, and also evaluating if there is *any* gain
about doing something about it.

But curious, on a standard qemu x86_x64 KVM guest, which of the
drivers do we know for certain *are* being used from the ones
listed?

What about Xen guests, I wonder?

> and you actually explain later why it it BS due
> to some drivers using it more explicitly.

Or implicitly. The list I showed is the work to show that the users
of GFP_DMA on x86 is *much* more wide spread than expected from the
above claim.

I however did not also answer the above qemu x86_64 question, but
would be good to know. Note I stated that the claim was *in practice*.

> But even more importantly
> we have plenty driver using it through dma_alloc_* and a small DMA
> mask, and they are in use 

Do we have a list of users for x86 with a small DMA mask?
Or, given that I'm not aware of a tool to be able to look
for this in an easy way, would it be good to find out which
x86 drivers do have a small mask?

> - we actually had a 4.16 regression due to them.

Ah what commit was the culprit? Is that fixed already? If so what
commit?

> > SCSI is *severely* affected:
> 
> Not really.  We have unchecked_isa_dma to support about 4 drivers,

Ah very neat:

  * CONFIG_CHR_DEV_OSST - "SCSI OnStream SC-x0 tape support"
  * CONFIG_SCSI_ADVANSYS - "AdvanSys SCSI support"
  * CONFIG_SCSI_AHA1542 - "Adaptec AHA1542 support"
  * CONFIG_SCSI_ESAS2R - "ATTO Technology's ExpressSAS RAID adapter driver"

> and less than a hand ful of drivers doing stupid things, which can
> be fixed easily, and just need a volunteer.

Care to list what needs to be done? Can an eager beaver student do it?

> > That's the end of the review of all current explicit callers on x86.
> > 
> > # dma_alloc_coherent_gfp_flags() and dma_generic_alloc_coherent()
> > 
> > dma_alloc_coherent_gfp_flags() and dma_generic_alloc_coherent() set
> > GFP_DMA if if (dma_mask <= DMA_BIT_MASK(24))
> 
> All that code is long gone and replaced with dma-direct.  Which still
> uses GFP_DMA based on the dma mask, though - see above.

And that's mostly IOMMU code, on the alloc() dma_map_ops.

  Luis
