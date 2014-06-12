Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 01D41900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 01:58:15 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so374299pbc.12
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 22:58:15 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id mj4si2357230pab.19.2014.06.11.22.58.13
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 22:58:14 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:02:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 02/10] DMA, CMA: fix possible memory leak
Message-ID: <20140612060211.GC30128@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20140612052543.GE12415@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612052543.GE12415@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, kvm@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Graf <agraf@suse.de>, kvm-ppc@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo Bonzini <pbonzini@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Thu, Jun 12, 2014 at 02:25:43PM +0900, Minchan Kim wrote:
> On Thu, Jun 12, 2014 at 12:21:39PM +0900, Joonsoo Kim wrote:
> > We should free memory for bitmap when we find zone mis-match,
> > otherwise this memory will leak.
> 
> Then, -stable stuff?

I don't think so. This is just possible leak candidate, so we don't
need to push this to stable tree.

> 
> > 
> > Additionally, I copy code comment from ppc kvm's cma code to notify
> > why we need to check zone mis-match.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
> > index bd0bb81..fb0cdce 100644
> > --- a/drivers/base/dma-contiguous.c
> > +++ b/drivers/base/dma-contiguous.c
> > @@ -177,14 +177,24 @@ static int __init cma_activate_area(struct cma *cma)
> >  		base_pfn = pfn;
> >  		for (j = pageblock_nr_pages; j; --j, pfn++) {
> >  			WARN_ON_ONCE(!pfn_valid(pfn));
> > +			/*
> > +			 * alloc_contig_range requires the pfn range
> > +			 * specified to be in the same zone. Make this
> > +			 * simple by forcing the entire CMA resv range
> > +			 * to be in the same zone.
> > +			 */
> >  			if (page_zone(pfn_to_page(pfn)) != zone)
> > -				return -EINVAL;
> > +				goto err;
> 
> At a first glance, I thought it would be better to handle such error
> before activating.
> So when I see the registration code(ie, dma_contiguous_revere_area),
> I realized it is impossible because we didn't set up zone yet. :(
> 
> If so, when we detect to fail here, it would be better to report more
> meaningful error message like what was successful zone and what is
> new zone and failed pfn number?

What I want to do in early phase of this patchset is to make cma code
on DMA APIs similar to ppc kvm's cma code. ppc kvm's cma code already
has this error handling logic, so I make this patch.

If we think that we need more things, we can do that on general cma code
after merging this patchset.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
