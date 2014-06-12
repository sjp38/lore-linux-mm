Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id DA838900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 01:50:02 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so601567pde.14
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 22:50:02 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id pv8si40472588pbb.3.2014.06.11.22.50.01
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 22:50:02 -0700 (PDT)
Date: Thu, 12 Jun 2014 14:53:58 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 01/10] DMA, CMA: clean-up log message
Message-ID: <20140612055358.GA30128@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-2-git-send-email-iamjoonsoo.kim@lge.com>
 <87y4x2pwnk.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y4x2pwnk.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 12, 2014 at 10:11:19AM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > We don't need explicit 'CMA:' prefix, since we already define prefix
> > 'cma:' in pr_fmt. So remove it.
> >
> > And, some logs print function name and others doesn't. This looks
> > bad to me, so I unify log format to print function name consistently.
> >
> > Lastly, I add one more debug log on cma_activate_area().
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> > index 83969f8..bd0bb81 100644
> > --- a/drivers/base/dma-contiguous.c
> > +++ b/drivers/base/dma-contiguous.c
> > @@ -144,7 +144,7 @@ void __init dma_contiguous_reserve(phys_addr_t limit)
> >  	}
> >
> >  	if (selected_size && !dma_contiguous_default_area) {
> > -		pr_debug("%s: reserving %ld MiB for global area\n", __func__,
> > +		pr_debug("%s(): reserving %ld MiB for global area\n", __func__,
> >  			 (unsigned long)selected_size / SZ_1M);
> 
> Do we need to do function(), or just function:. I have seen the later
> usage in other parts of the kernel.

Hello,

I also haven't seen this format in other kernel code, but, in cma, they use
this format as following.

function(arg1, arg2, ...): some message

If we all dislike this format, we can change it after merging this
patchset. Until then, it seems better to me to leave it as is.

> 
> >
> >  		dma_contiguous_reserve_area(selected_size, selected_base,
> > @@ -163,8 +163,9 @@ static int __init cma_activate_area(struct cma *cma)
> >  	unsigned i = cma->count >> pageblock_order;
> >  	struct zone *zone;
> >
> > -	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> > +	pr_debug("%s()\n", __func__);
> 
> why ?
> 

This pr_debug() comes from ppc kvm's kvm_cma_init_reserved_areas().
I want to maintain all log messages as much as possible to reduce confusion
with this generalization.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
