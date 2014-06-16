Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 211DF6B0036
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:19:15 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id un15so988138pbc.13
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:19:14 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id cc3si12410861pad.47.2014.06.15.22.19.13
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:19:14 -0700 (PDT)
Date: Mon, 16 Jun 2014 14:23:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 05/10] DMA, CMA: support arbitrary bitmap granularity
Message-ID: <20140616052325.GC23210@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-6-git-send-email-iamjoonsoo.kim@lge.com>
 <xa1t61k6juph.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xa1t61k6juph.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 12, 2014 at 12:19:54PM +0200, Michal Nazarewicz wrote:
> On Thu, Jun 12 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > ppc kvm's cma region management requires arbitrary bitmap granularity,
> > since they want to reserve very large memory and manage this region
> > with bitmap that one bit for several pages to reduce management overheads.
> > So support arbitrary bitmap granularity for following generalization.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> > diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> > index bc4c171..9bc9340 100644
> > --- a/drivers/base/dma-contiguous.c
> > +++ b/drivers/base/dma-contiguous.c
> > @@ -38,6 +38,7 @@ struct cma {
> >  	unsigned long	base_pfn;
> >  	unsigned long	count;
> 
> Have you considered replacing count with maxno?

No, I haven't.
I think that count is better than maxno, since it represent number of
pages in this region.

> 
> >  	unsigned long	*bitmap;
> > +	int order_per_bit; /* Order of pages represented by one bit */
> 
> I'd make it unsigned.

Will fix it.

> >  	struct mutex	lock;
> >  };
> >  
> > +static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int
> > count)
> 
> For consistency cma_clear_bitmap would make more sense I think.  On the
> other hand, you're just moving stuff around so perhaps renaming the
> function at this point is not worth it any more.

Will fix it.

> > +{
> > +	unsigned long bitmapno, nr_bits;
> > +
> > +	bitmapno = (pfn - cma->base_pfn) >> cma->order_per_bit;
> > +	nr_bits = cma_bitmap_pages_to_bits(cma, count);
> > +
> > +	mutex_lock(&cma->lock);
> > +	bitmap_clear(cma->bitmap, bitmapno, nr_bits);
> > +	mutex_unlock(&cma->lock);
> > +}
> > +
> >  static int __init cma_activate_area(struct cma *cma)
> >  {
> > -	int bitmap_size = BITS_TO_LONGS(cma->count) * sizeof(long);
> > +	int bitmap_maxno = cma_bitmap_maxno(cma);
> > +	int bitmap_size = BITS_TO_LONGS(bitmap_maxno) * sizeof(long);
> >  	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
> >  	unsigned i = cma->count >> pageblock_order;
> >  	struct zone *zone;
> 
> bitmap_maxno is never used again, perhaps:
> 
> +	int bitmap_size = BITS_TO_LONGS(cma_bitmap_maxno(cma)) * sizeof(long);
> 
> instead? Up to you.

Okay!!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
