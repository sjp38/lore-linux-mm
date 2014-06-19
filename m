Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE1E6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 04:13:45 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so1594493pdj.28
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 01:13:45 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id e10si5005616pat.80.2014.06.19.01.13.43
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 01:13:44 -0700 (PDT)
Date: Thu, 19 Jun 2014 17:18:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 -next 4/9] DMA, CMA: support arbitrary bitmap
 granularity
Message-ID: <20140619081807.GA28611@js1304-P5Q-DELUXE>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402897251-23639-5-git-send-email-iamjoonsoo.kim@lge.com>
 <20140618134815.69c4d0a5f916846f9857e9ff@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140618134815.69c4d0a5f916846f9857e9ff@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Jun 18, 2014 at 01:48:15PM -0700, Andrew Morton wrote:
> On Mon, 16 Jun 2014 14:40:46 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > PPC KVM's CMA area management requires arbitrary bitmap granularity,
> > since they want to reserve very large memory and manage this region
> > with bitmap that one bit for several pages to reduce management overheads.
> > So support arbitrary bitmap granularity for following generalization.
> > 
> > ...
> >
> > --- a/drivers/base/dma-contiguous.c
> > +++ b/drivers/base/dma-contiguous.c
> > @@ -38,6 +38,7 @@ struct cma {
> >  	unsigned long	base_pfn;
> >  	unsigned long	count;
> >  	unsigned long	*bitmap;
> > +	unsigned int order_per_bit; /* Order of pages represented by one bit */
> >  	struct mutex	lock;
> >  };
> >  
> > @@ -157,9 +158,37 @@ void __init dma_contiguous_reserve(phys_addr_t limit)
> >  
> >  static DEFINE_MUTEX(cma_mutex);
> >  
> > +static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
> > +{
> > +	return (1 << (align_order >> cma->order_per_bit)) - 1;
> > +}
> 
> Might want a "1UL << ..." here.

Okay!

> 
> > +static unsigned long cma_bitmap_maxno(struct cma *cma)
> > +{
> > +	return cma->count >> cma->order_per_bit;
> > +}
> > +
> > +static unsigned long cma_bitmap_pages_to_bits(struct cma *cma,
> > +						unsigned long pages)
> > +{
> > +	return ALIGN(pages, 1 << cma->order_per_bit) >> cma->order_per_bit;
> > +}
> 
> Ditto.  I'm not really sure what the compiler will do in these cases,
> but would prefer not to rely on it anyway!

Okay!

Thanks for fix!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
