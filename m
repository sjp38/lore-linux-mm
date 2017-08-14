Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF406B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 13:01:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p62so11675666oih.12
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 10:01:28 -0700 (PDT)
Received: from mail-it0-x22f.google.com (mail-it0-x22f.google.com. [2607:f8b0:4001:c0b::22f])
        by mx.google.com with ESMTPS id p81si4964491oih.240.2017.08.14.10.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 10:01:26 -0700 (PDT)
Received: by mail-it0-x22f.google.com with SMTP id 76so23436081ith.0
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 10:01:26 -0700 (PDT)
Date: Mon, 14 Aug 2017 11:01:25 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170814170125.ledrnrik3km66y33@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com>
 <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
 <20170814165047.GB23428@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814165047.GB23428@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Mon, Aug 14, 2017 at 05:50:47PM +0100, Mark Rutland wrote:
> On Mon, Aug 14, 2017 at 10:35:36AM -0600, Tycho Andersen wrote:
> > Hi Mark,
> > 
> > On Sat, Aug 12, 2017 at 12:26:03PM +0100, Mark Rutland wrote:
> > > On Wed, Aug 09, 2017 at 02:07:49PM -0600, Tycho Andersen wrote:
> > > > +static inline void __flush_tlb_one(unsigned long addr)
> > > > +{
> > > > +	dsb(ishst);
> > > > +	__tlbi(vaae1is, addr >> 12);
> > > > +	dsb(ish);
> > > > +	isb();
> > > > +}
> > > 
> > > Is this going to be called by generic code?
> > 
> > Yes, it's called in mm/xpfo.c:xpfo_kunmap.
> > 
> > > It would be nice if we could drop 'kernel' into the name, to make it clear this
> > > is intended to affect the kernel mappings, which have different maintenance
> > > requirements to user mappings.
> 
> > It's named __flush_tlb_one after the x86 (and a few other arches)
> > function of the same name. I can change it to flush_tlb_kernel_page,
> > but then we'll need some x86-specific code to map the name as well.
> > 
> > Maybe since it's called from generic code that's warranted though?
> > I'll change the implementation for now, let me know what you want to
> > do about the name.
> 
> I think it would be preferable to do so, to align with 
> flush_tlb_kernel_range(), which is an existing generic interface.
> 
> That said, is there any reason not to use flush_tlb_kernel_range()
> directly?

I don't think so, I'll change the generic code to that and drop this
patch.

Thanks!

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
