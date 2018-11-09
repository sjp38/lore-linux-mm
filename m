Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC81F6B0712
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 12:31:41 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id t1-v6so1784497ply.23
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 09:31:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j19-v6si7974452pfh.63.2018.11.09.09.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 09:31:40 -0800 (PST)
Subject: Re: [bug report] mm, slab/slub: introduce kmalloc-reclaimable caches
References: <20181109171701.GB8323@unbuntlaptop>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a6c8eeff-801c-3773-6b96-533f519ef9f4@suse.cz>
Date: Fri, 9 Nov 2018 18:28:44 +0100
MIME-Version: 1.0
In-Reply-To: <20181109171701.GB8323@unbuntlaptop>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org

On 11/9/18 6:17 PM, Dan Carpenter wrote:
> Hello Vlastimil Babka,

Hi,

> The patch 1291523f2c1d: "mm, slab/slub: introduce kmalloc-reclaimable
> caches" from Oct 26, 2018, leads to the following static checker
> warning:
> 
> 	./include/linux/slab.h:585 kmalloc_node()
> 	warn: array off by one? 'kmalloc_caches[kmalloc_type(flags)]' '0-3 == 3'

I believe that's a false positive.

> ./include/linux/slab.h
>    298  /*
>    299   * Whenever changing this, take care of that kmalloc_type() and
>    300   * create_kmalloc_caches() still work as intended.
>    301   */
>    302  enum kmalloc_cache_type {
>    303          KMALLOC_NORMAL = 0,
>    304          KMALLOC_RECLAIM,
>    305  #ifdef CONFIG_ZONE_DMA
>    306          KMALLOC_DMA,
>    307  #endif
>    308          NR_KMALLOC_TYPES
> 
> 
> The kmalloc_caches[] array has NR_KMALLOC_TYPES elements.

Yes.

>    309  };
>    310  
>    311  #ifndef CONFIG_SLOB
>    312  extern struct kmem_cache *
>    313  kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1];
>    314  
>    315  static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>    316  {
>    317          int is_dma = 0;
>    318          int type_dma = 0;
>    319          int is_reclaimable;
>    320  
>    321  #ifdef CONFIG_ZONE_DMA
>    322          is_dma = !!(flags & __GFP_DMA);
>    323          type_dma = is_dma * KMALLOC_DMA;
>                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> KMALLOC_DMA is the last possible valid index.

Yes, but type_dma gains the value of KMALLOC_DMA only when is_dma is 1.

>    324  #endif
>    325  
>    326          is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
>    327  
>    328          /*
>    329           * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
>    330           * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>    331           */
>    332          return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
>                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> We're adding one to it.

Only when !is_dma is 1, which means then that type_dma is 0. So it's safe.

> This is mm/ so I assume this works,

I'll... take that as a compliment :D

> but it's
> pretty confusing.

Indeed. Static checkers seem to hate my too clever code, so it's already
going away [1]. Maybe your static checker can be improved to evaluate
this better? There's already a gcc bug [2] inspired by the whole thing.

Thanks!
Vlastimil

[1]
https://lore.kernel.org/lkml/cbc1fc52-dc8c-aa38-8f29-22da8bcd91c1@suse.cz/T/#u
[2] https://gcc.gnu.org/bugzilla/show_bug.cgi?id=87954

>    333  }
> 
> regards,
> dan carpenter
> 
