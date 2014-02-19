Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC346B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 19:04:03 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id hi5so4092009wib.9
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 16:04:02 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id a9si13744525wiy.42.2014.02.18.16.03.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 16:03:59 -0800 (PST)
Date: Wed, 19 Feb 2014 00:03:52 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [GIT PULL] ARM fixes
Message-ID: <20140219000352.GP21483@n2100.arm.linux.org.uk>
References: <20140217234644.GA5171@rmk-PC.arm.linux.org.uk> <CA+55aFy7ApiQRudxPAd3v5k_apppxRnePHb1HZPH13erqhmX=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy7ApiQRudxPAd3v5k_apppxRnePHb1HZPH13erqhmX=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, James Bottomley <James.Bottomley@parallels.com>, Linux SCSI List <linux-scsi@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, ARM SoC <arm@kernel.org>

On Tue, Feb 18, 2014 at 03:49:03PM -0800, Linus Torvalds wrote:
> On Mon, Feb 17, 2014 at 3:46 PM, Russell King <rmk@arm.linux.org.uk> wrote:
> >
> > One fix touches code outside of arch/arm, which is related to sorting
> > out the DMA masks correctly.  There is a long standing issue with the
> > conversion from PFNs to addresses where people assume that shifting an
> > unsigned long left by PAGE_SHIFT results in a correct address.
> 
> You should probably have used PFN_PHYS(), which does this correctly.
> Your explicit u64 isn't exactly wrong, but phys_addr_t is really the
> right type for the result.

Almost, but not quite.  If we're going to avoid u64, then dma_addr_t
woudl be the right type here because we're talking about DMA addresses.
We could also switch to keeping this as PFNs - block internally converts
it to a PFN anyway:

void blk_queue_bounce_limit(struct request_queue *q, u64 max_addr)
{
        unsigned long b_pfn = max_addr >> PAGE_SHIFT;
...

and that is ultimately assigned to q->limits.bounce_pfn.  So, if we
arranged for blk_queue_bounce_limit() to take a PFN, and then modified
it's two callers, then we don't need to care about converting between
phys and pfns.

Maybe blk_queue_bounce_pfn_limit() so we ensure all users get caught?

> That said, it's admittedly a disgusting name, and I wonder if we
> should introduce a nicer-named "pfn_to_phys()" that matches the other
> "xyz_to_abc()" functions we have (including "pfn_to_virt()")

We have these on ARM:

arch/arm/include/asm/memory.h:#define	__pfn_to_phys(pfn)	((phys_addr_t)(pfn) << PAGE_SHIFT)
arch/arm/include/asm/memory.h:#define	__phys_to_pfn(paddr)	((unsigned long)((paddr) >> PAGE_SHIFT))

it probably makes sense to pick those right out, maybe losing the
__ prefix on them.

> Looking at it, the Xen people then do this disgusting thing:
> "__va(PFN_PHYS(pfn))" which is both ugly and pointless (__va() isn't
> going to work for a phys_addr_t anyway). And <linux/mm.h> has this
> gem:
> 
>   __va(PFN_PHYS(page_to_pfn(page)));

Wow.  Two things spring to mind there... highmem pages, and don't we
already have page_address() for that?

> Anyway, I pulled your change to scsi_lib.c, since it's certainly no
> worse than what we used to have, but James and company cc'd too.

Thanks.  I do worry about all the other places which I also found -
but the first step is getting concensus on what the macro should be.

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
