Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id AFD0E6B025D
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 06:36:43 -0500 (EST)
Received: by wmuu63 with SMTP id u63so218204194wmu.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 03:36:43 -0800 (PST)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id 202si36896546wmp.104.2015.12.09.03.36.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 03:36:42 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 10A2898C1C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:36:41 +0000 (UTC)
Date: Wed, 9 Dec 2015 11:36:35 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] MIPS: Fix DMA contiguous allocation
Message-ID: <20151209113635.GA15910@techsingularity.net>
References: <1449569930-2118-1-git-send-email-qais.yousef@imgtec.com>
 <20151208141939.d0edbb72b3c15844c5ac25ea@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20151208141939.d0edbb72b3c15844c5ac25ea@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Qais Yousef <qais.yousef@imgtec.com>, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ralf@linux-mips.org

On Tue, Dec 08, 2015 at 02:19:39PM -0800, Andrew Morton wrote:
> On Tue, 8 Dec 2015 10:18:50 +0000 Qais Yousef <qais.yousef@imgtec.com> wrote:
> 
> > Recent changes to how GFP_ATOMIC is defined seems to have broken the condition
> > to use mips_alloc_from_contiguous() in mips_dma_alloc_coherent().
> > 
> > I couldn't bottom out the exact change but I think it's this one
> > 
> > d0164adc89f6 (mm, page_alloc: distinguish between being unable to sleep,
> > unwilling to sleep and avoiding waking kswapd)
> > 
> > >From what I see GFP_ATOMIC has multiple bits set and the check for !(gfp
> > & GFP_ATOMIC) isn't enough. To verify if the flag is atomic we need to make
> > sure that (gfp & GFP_ATOMIC) == GFP_ATOMIC to verify that all bits rquired to
> > satisfy GFP_ATOMIC condition are set.
> > 
> > ...
> >
> > --- a/arch/mips/mm/dma-default.c
> > +++ b/arch/mips/mm/dma-default.c
> > @@ -145,7 +145,7 @@ static void *mips_dma_alloc_coherent(struct device *dev, size_t size,
> >  
> >  	gfp = massage_gfp_flags(dev, gfp);
> >  
> > -	if (IS_ENABLED(CONFIG_DMA_CMA) && !(gfp & GFP_ATOMIC))
> > +	if (IS_ENABLED(CONFIG_DMA_CMA) && ((gfp & GFP_ATOMIC) != GFP_ATOMIC))
> >  		page = dma_alloc_from_contiguous(dev,
> >  					count, get_order(size));
> >  	if (!page)
> 
> hm.  It seems that the code is asking "can I do a potentially-sleeping
> memory allocation"?
> 
> The way to do that under the new regime is
> 
> 	if (IS_ENABLED(CONFIG_DMA_CMA) && gfpflags_allow_blocking(gfp))
> 
> Mel, can you please confirm?

Yes, this is the correct way it should be checked. The full flags cover
watermark and kswapd treatment which potentially could be altered by
the caller.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
