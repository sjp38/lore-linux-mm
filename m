Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBAA6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:52:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r133so143695155pgr.6
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:52:01 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c8si4883393pli.272.2017.08.14.09.51.59
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 09:51:59 -0700 (PDT)
Date: Mon, 14 Aug 2017 17:50:47 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
Message-ID: <20170814165047.GB23428@leverpostej>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com>
 <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814163536.6njceqc3dip5lrlu@smitten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Mon, Aug 14, 2017 at 10:35:36AM -0600, Tycho Andersen wrote:
> Hi Mark,
> 
> On Sat, Aug 12, 2017 at 12:26:03PM +0100, Mark Rutland wrote:
> > On Wed, Aug 09, 2017 at 02:07:49PM -0600, Tycho Andersen wrote:
> > > +static inline void __flush_tlb_one(unsigned long addr)
> > > +{
> > > +	dsb(ishst);
> > > +	__tlbi(vaae1is, addr >> 12);
> > > +	dsb(ish);
> > > +	isb();
> > > +}
> > 
> > Is this going to be called by generic code?
> 
> Yes, it's called in mm/xpfo.c:xpfo_kunmap.
> 
> > It would be nice if we could drop 'kernel' into the name, to make it clear this
> > is intended to affect the kernel mappings, which have different maintenance
> > requirements to user mappings.

> It's named __flush_tlb_one after the x86 (and a few other arches)
> function of the same name. I can change it to flush_tlb_kernel_page,
> but then we'll need some x86-specific code to map the name as well.
> 
> Maybe since it's called from generic code that's warranted though?
> I'll change the implementation for now, let me know what you want to
> do about the name.

I think it would be preferable to do so, to align with 
flush_tlb_kernel_range(), which is an existing generic interface.

That said, is there any reason not to use flush_tlb_kernel_range()
directly?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
