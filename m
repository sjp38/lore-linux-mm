Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3797A6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:55:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y190so145016733pgb.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:55:36 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a14si4829865plt.342.2017.08.14.09.55.34
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 09:55:35 -0700 (PDT)
Date: Mon, 14 Aug 2017 17:54:23 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [kernel-hardening] [PATCH v5 07/10] arm64/mm: Don't flush the
 data cache if the page is unmapped by XPFO
Message-ID: <20170814165423.GC23428@leverpostej>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-8-tycho@docker.com>
 <20170812115736.GC16374@remoulade>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170812115736.GC16374@remoulade>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Sat, Aug 12, 2017 at 12:57:37PM +0100, Mark Rutland wrote:
> On Wed, Aug 09, 2017 at 02:07:52PM -0600, Tycho Andersen wrote:
> > From: Juerg Haefliger <juerg.haefliger@hpe.com>
> > 
> > If the page is unmapped by XPFO, a data cache flush results in a fatal
> > page fault. So don't flush in that case.
> 
> Do you have an example callchain where that happens? We might need to shuffle
> things around to cater for that case.
> 
> > @@ -30,7 +31,9 @@ void sync_icache_aliases(void *kaddr, unsigned long len)
> >  	unsigned long addr = (unsigned long)kaddr;
> >  
> >  	if (icache_is_aliasing()) {
> > -		__clean_dcache_area_pou(kaddr, len);
> > +		/* Don't flush if the page is unmapped by XPFO */
> > +		if (!xpfo_page_is_unmapped(virt_to_page(kaddr)))
> > +			__clean_dcache_area_pou(kaddr, len);
> >  		__flush_icache_all();
> >  	} else {
> >  		flush_icache_range(addr, addr + len);
> 
> I don't think this patch is correct. If data cache maintenance is required in
> the absence of XPFO, I don't see why it wouldn't be required in the presence of
> XPFO.
> 
> I'm not immediately sure why the non-aliasing case misses data cache
> maintenance. I couldn't spot where that happens otherwise.

>From another look, it seems that flush_icache_range() performs the
D-cache maintenance internally, so it's just a slightly misleading name.

However, __flush_icache_all() does not, and does need separate D-cache
maintenance.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
