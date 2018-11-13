Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEE56B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 12:02:16 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id l7-v6so31828373qkd.5
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:02:16 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f51si8334962qvf.201.2018.11.13.09.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 09:02:13 -0800 (PST)
Date: Tue, 13 Nov 2018 20:02:07 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [bug report] mm, slab/slub: introduce kmalloc-reclaimable caches
Message-ID: <20181113170207.GA22791@unbuntlaptop>
References: <20181109171701.GB8323@unbuntlaptop>
 <a6c8eeff-801c-3773-6b96-533f519ef9f4@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6c8eeff-801c-3773-6b96-533f519ef9f4@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org

On Fri, Nov 09, 2018 at 06:28:44PM +0100, Vlastimil Babka wrote:
> On 11/9/18 6:17 PM, Dan Carpenter wrote:
> >    315  static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
> >    316  {
> >    317          int is_dma = 0;
> >    318          int type_dma = 0;
> >    319          int is_reclaimable;
> >    320  
> >    321  #ifdef CONFIG_ZONE_DMA
> >    322          is_dma = !!(flags & __GFP_DMA);
> >    323          type_dma = is_dma * KMALLOC_DMA;
> >                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > 
> > KMALLOC_DMA is the last possible valid index.
> 
> Yes, but type_dma gains the value of KMALLOC_DMA only when is_dma is 1.
> 
> >    324  #endif
> >    325  
> >    326          is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
> >    327  
> >    328          /*
> >    329           * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
> >    330           * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
> >    331           */
> >    332          return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> >                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > 
> > We're adding one to it.
> 
> Only when !is_dma is 1, which means then that type_dma is 0. So it's safe.
> 
> > This is mm/ so I assume this works,
> 
> I'll... take that as a compliment :D
> 

Yes, of course.

> > but it's
> > pretty confusing.
> 
> Indeed. Static checkers seem to hate my too clever code, so it's already
> going away [1]. Maybe your static checker can be improved to evaluate
> this better? There's already a gcc bug [2] inspired by the whole thing.
> 

It's cool that the GCC developers think they can handle this code.  I
would have to rethink how Smatch handles math entirely...

regards,
dan carpenter
