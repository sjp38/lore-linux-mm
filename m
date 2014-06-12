Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C5DA5900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:03:29 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so604273pdb.25
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 23:03:29 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ni2si40462579pbc.84.2014.06.11.23.03.27
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 23:03:28 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:07:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 04/10] DMA, CMA: support alignment constraint on cma
 region
Message-ID: <20140612060720.GD30128@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-5-git-send-email-iamjoonsoo.kim@lge.com>
 <20140612055219.GG12415@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612055219.GG12415@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 02:52:20PM +0900, Minchan Kim wrote:
> On Thu, Jun 12, 2014 at 12:21:41PM +0900, Joonsoo Kim wrote:
> > ppc kvm's cma area management needs alignment constraint on
> > cma region. So support it to prepare generalization of cma area
> > management functionality.
> > 
> > Additionally, add some comments which tell us why alignment
> > constraint is needed on cma region.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> > index 8a44c82..bc4c171 100644
> > --- a/drivers/base/dma-contiguous.c
> > +++ b/drivers/base/dma-contiguous.c
> > @@ -32,6 +32,7 @@
> >  #include <linux/swap.h>
> >  #include <linux/mm_types.h>
> >  #include <linux/dma-contiguous.h>
> > +#include <linux/log2.h>
> >  
> >  struct cma {
> >  	unsigned long	base_pfn;
> > @@ -219,6 +220,7 @@ core_initcall(cma_init_reserved_areas);
> >   * @size: Size of the reserved area (in bytes),
> >   * @base: Base address of the reserved area optional, use 0 for any
> >   * @limit: End address of the reserved memory (optional, 0 for any).
> > + * @alignment: Alignment for the contiguous memory area, should be power of 2
> >   * @res_cma: Pointer to store the created cma region.
> >   * @fixed: hint about where to place the reserved area
> >   *
> 
> Pz, move the all description to new API function rather than internal one.

Reason I leave all description as is is that I will remove it in
following patch. I think that moving these makes patch bigger and hard
to review.

But, if it is necessary, I will do it. :)

> 
> > @@ -233,15 +235,15 @@ core_initcall(cma_init_reserved_areas);
> >   */
> >  static int __init __dma_contiguous_reserve_area(phys_addr_t size,
> >  				phys_addr_t base, phys_addr_t limit,
> > +				phys_addr_t alignment,
> >  				struct cma **res_cma, bool fixed)
> >  {
> >  	struct cma *cma = &cma_areas[cma_area_count];
> > -	phys_addr_t alignment;
> >  	int ret = 0;
> >  
> > -	pr_debug("%s(size %lx, base %08lx, limit %08lx)\n", __func__,
> > -		 (unsigned long)size, (unsigned long)base,
> > -		 (unsigned long)limit);
> > +	pr_debug("%s(size %lx, base %08lx, limit %08lx align_order %08lx)\n",
> 
> Why is it called by "align_order"?

Oops... mistake.
I will fix it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
