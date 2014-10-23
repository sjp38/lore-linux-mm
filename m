Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1993E6B0074
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:42:14 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id 10so1685057lbg.14
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 16:42:14 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id ps4si4724300lbb.16.2014.10.23.16.42.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 16:42:13 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH 1/4] mm: cma: Don't crash on allocation if CMA area can't be activated
Date: Fri, 24 Oct 2014 02:42:10 +0300
Message-ID: <1463193.4qGZjcvNod@avalon>
In-Reply-To: <xa1tmw8mlobz.fsf@mina86.com>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1414074828-4488-2-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <xa1tmw8mlobz.fsf@mina86.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hi Michal,

On Thursday 23 October 2014 18:53:36 Michal Nazarewicz wrote:
> On Thu, Oct 23 2014, Laurent Pinchart wrote:
> > If activation of the CMA area fails its mutex won't be initialized,
> > leading to an oops at allocation time when trying to lock the mutex. Fix
> > this by failing allocation if the area hasn't been successfully actived,
> > and detect that condition by moving the CMA bitmap allocation after page
> > block reservation completion.
> > 
> > Signed-off-by: Laurent Pinchart
> > <laurent.pinchart+renesas@ideasonboard.com>
> 
> Cc: <stable@vger.kernel.org>  # v3.17
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> As a matter of fact, this is present in kernels earlier than 3.17 but in
> the 3.17 the code has been moved from drivers/base/dma-contiguous.c to
> mm/cma.c so this might require separate stable patch.  I can track this
> and prepare a patch if you want.

That could be done, but I'm not sure if it's really worth it. The bug only 
occurs when the CMA zone activation fails. I've ran into that case due to a 
bug introduced in v3.18-rc1, but this shouldn't be the case for older kernel 
versions.

If you think the fix should be backported to stable kernels older than v3.17 
please feel free to cook up a patch.

> > ---
> > 
> >  mm/cma.c | 17 ++++++-----------
> >  1 file changed, 6 insertions(+), 11 deletions(-)
> > 
> > diff --git a/mm/cma.c b/mm/cma.c
> > index 963bc4a..16c6650 100644
> > --- a/mm/cma.c
> > +++ b/mm/cma.c
> > @@ -93,11 +93,6 @@ static int __init cma_activate_area(struct cma *cma)
> >  	unsigned i = cma->count >> pageblock_order;
> >  	struct zone *zone;
> > 
> > -	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> > -
> > -	if (!cma->bitmap)
> > -		return -ENOMEM;
> > -
> >  	WARN_ON_ONCE(!pfn_valid(pfn));
> >  	zone = page_zone(pfn_to_page(pfn));
> > 
> > @@ -114,17 +109,17 @@ static int __init cma_activate_area(struct cma *cma)
> >  			 * to be in the same zone.
> >  			 */
> >  			if (page_zone(pfn_to_page(pfn)) != zone)
> > -				goto err;
> > +				return -EINVAL;
> >  		}
> >  		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> >  	} while (--i);
> > 
> > +	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
> > +	if (!cma->bitmap)
> > +		return -ENOMEM;
> > +
> >  	mutex_init(&cma->lock);
> >  	return 0;
> > -
> > -err:
> > -	kfree(cma->bitmap);
> > -	return -EINVAL;
> >  }
> >  
> >  static int __init cma_init_reserved_areas(void)
> > @@ -313,7 +308,7 @@ struct page *cma_alloc(struct cma *cma, int count,
> > unsigned int align)
> >  	struct page *page = NULL;
> >  	int ret;
> > 
> > -	if (!cma || !cma->count)
> > +	if (!cma || !cma->count || !cma->bitmap)
> >  		return NULL;
> >  	
> >  	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
