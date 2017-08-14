Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 134C86B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:35:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p62so11615851oih.12
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:35:39 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id e14si5012481oib.377.2017.08.14.09.35.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 09:35:38 -0700 (PDT)
Received: by mail-io0-x232.google.com with SMTP id j32so40267865iod.0
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:35:38 -0700 (PDT)
Date: Mon, 14 Aug 2017 10:35:36 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170814163536.6njceqc3dip5lrlu@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com>
 <20170812112603.GB16374@remoulade>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170812112603.GB16374@remoulade>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

Hi Mark,

On Sat, Aug 12, 2017 at 12:26:03PM +0100, Mark Rutland wrote:
> On Wed, Aug 09, 2017 at 02:07:49PM -0600, Tycho Andersen wrote:
> > From: Juerg Haefliger <juerg.haefliger@hpe.com>
> > 
> > Add a hook for flushing a single TLB entry on arm64.
> > 
> > Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
> > Tested-by: Tycho Andersen <tycho@docker.com>
> > ---
> >  arch/arm64/include/asm/tlbflush.h | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/arch/arm64/include/asm/tlbflush.h b/arch/arm64/include/asm/tlbflush.h
> > index af1c76981911..8e0c49105d3e 100644
> > --- a/arch/arm64/include/asm/tlbflush.h
> > +++ b/arch/arm64/include/asm/tlbflush.h
> > @@ -184,6 +184,14 @@ static inline void flush_tlb_kernel_range(unsigned long start, unsigned long end
> >  	isb();
> >  }
> >  
> > +static inline void __flush_tlb_one(unsigned long addr)
> > +{
> > +	dsb(ishst);
> > +	__tlbi(vaae1is, addr >> 12);
> > +	dsb(ish);
> > +	isb();
> > +}
> 
> Is this going to be called by generic code?

Yes, it's called in mm/xpfo.c:xpfo_kunmap.

> It would be nice if we could drop 'kernel' into the name, to make it clear this
> is intended to affect the kernel mappings, which have different maintenance
> requirements to user mappings.
> 
> We should be able to implement this more simply as:
> 
> flush_tlb_kernel_page(unsigned long addr)
> {
> 	flush_tlb_kernel_range(addr, addr + PAGE_SIZE);
> }

It's named __flush_tlb_one after the x86 (and a few other arches)
function of the same name. I can change it to flush_tlb_kernel_page,
but then we'll need some x86-specific code to map the name as well.

Maybe since it's called from generic code that's warranted though?
I'll change the implementation for now, let me know what you want to
do about the name.

Cheers,

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
