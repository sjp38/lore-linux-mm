Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1E6E6B070A
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 12:17:10 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g63-v6so1947734pfc.9
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 09:17:10 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id e8-v6si8831716plk.208.2018.11.09.09.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 09:17:09 -0800 (PST)
Date: Fri, 9 Nov 2018 20:17:02 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] mm, slab/slub: introduce kmalloc-reclaimable caches
Message-ID: <20181109171701.GB8323@unbuntlaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz
Cc: linux-mm@kvack.org

Hello Vlastimil Babka,

The patch 1291523f2c1d: "mm, slab/slub: introduce kmalloc-reclaimable
caches" from Oct 26, 2018, leads to the following static checker
warning:

	./include/linux/slab.h:585 kmalloc_node()
	warn: array off by one? 'kmalloc_caches[kmalloc_type(flags)]' '0-3 == 3'

./include/linux/slab.h
   298  /*
   299   * Whenever changing this, take care of that kmalloc_type() and
   300   * create_kmalloc_caches() still work as intended.
   301   */
   302  enum kmalloc_cache_type {
   303          KMALLOC_NORMAL = 0,
   304          KMALLOC_RECLAIM,
   305  #ifdef CONFIG_ZONE_DMA
   306          KMALLOC_DMA,
   307  #endif
   308          NR_KMALLOC_TYPES


The kmalloc_caches[] array has NR_KMALLOC_TYPES elements.

   309  };
   310  
   311  #ifndef CONFIG_SLOB
   312  extern struct kmem_cache *
   313  kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1];
   314  
   315  static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
   316  {
   317          int is_dma = 0;
   318          int type_dma = 0;
   319          int is_reclaimable;
   320  
   321  #ifdef CONFIG_ZONE_DMA
   322          is_dma = !!(flags & __GFP_DMA);
   323          type_dma = is_dma * KMALLOC_DMA;
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

KMALLOC_DMA is the last possible valid index.

   324  #endif
   325  
   326          is_reclaimable = !!(flags & __GFP_RECLAIMABLE);
   327  
   328          /*
   329           * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
   330           * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
   331           */
   332          return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We're adding one to it.  This is mm/ so I assume this works, but it's
pretty confusing.

   333  }

regards,
dan carpenter
