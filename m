Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id BDC586B0078
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:50:45 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id f15so306983lbj.27
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 16:50:44 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id b4si4679979lbd.70.2014.10.23.16.50.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 16:50:43 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 2/4] mm: cma: Always consider a 0 base address reservation as dynamic
Date: Fri, 24 Oct 2014 02:50:42 +0300
Message-ID: <3165257.hQsT1mEnTD@avalon>
In-Reply-To: <xa1tk33qlo93.fsf@mina86.com>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1414074828-4488-3-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <xa1tk33qlo93.fsf@mina86.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi Michal,

On Thursday 23 October 2014 18:55:20 Michal Nazarewicz wrote:
> On Thu, Oct 23 2014, Laurent Pinchart wrote:
> > The fixed parameter to cma_declare_contiguous() tells the function
> > whether the given base address must be honoured or should be considered
> > as a hint only. The API considers a zero base address as meaning any
> > base address, which must never be considered as a fixed value.
> > 
> > Part of the implementation correctly checks both fixed and base != 0,
> > but two locations check the fixed value only. Set fixed to false when
> > base is 0 to fix that and simplify the code.
> > 
> > Signed-off-by: Laurent Pinchart
> > <laurent.pinchart+renesas@ideasonboard.com>
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> And like before, this should also probably also go to stable.

v3.17 and older don't have the extra fixed checks, so I don't think there's a 
need to Cc stable.

> > ---
> > 
> >  mm/cma.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/cma.c b/mm/cma.c
> > index 16c6650..6b14346 100644
> > --- a/mm/cma.c
> > +++ b/mm/cma.c
> > @@ -239,6 +239,9 @@ int __init cma_declare_contiguous(phys_addr_t base,
> >  	size = ALIGN(size, alignment);
> >  	limit &= ~(alignment - 1);
> > 
> > +	if (!base)
> > +		fixed = false;
> > +
> >  	/* size should be aligned with order_per_bit */
> >  	if (!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit))
> >  		return -EINVAL;
> > @@ -262,7 +265,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
> >  	}
> >  	
> >  	/* Reserve memory */
> > -	if (base && fixed) {
> > +	if (fixed) {
> >  		if (memblock_is_region_reserved(base, size) ||
> >  		    memblock_reserve(base, size) < 0) {
> >  			ret = -EBUSY;

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
