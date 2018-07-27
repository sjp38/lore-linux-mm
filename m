Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C3BAC6B0007
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 11:23:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b9-v6so3102766pgq.17
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 08:23:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w25-v6si4191917pga.58.2018.07.27.08.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 27 Jul 2018 08:23:27 -0700 (PDT)
Date: Fri, 27 Jul 2018 08:23:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
Message-ID: <20180727152322.GB13348@bombadil.infradead.org>
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
 <20180726194209.GB12992@bombadil.infradead.org>
 <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
 <20180727000708.GA785@bombadil.infradead.org>
 <cae33099-3147-5014-ab4e-c22a4d66dc49@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cae33099-3147-5014-ab4e-c22a4d66dc49@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Fri, Jul 27, 2018 at 09:23:30AM -0400, Tony Battersby wrote:
> On 07/26/2018 08:07 PM, Matthew Wilcox wrote:
> > If you're up for more major surgery, then I think we can put all the
> > information currently stored in dma_page into struct page.  Something
> > like this:
> >
> > +++ b/include/linux/mm_types.h
> > @@ -152,6 +152,12 @@ struct page {
> >                         unsigned long hmm_data;
> >                         unsigned long _zd_pad_1;        /* uses mapping */
> >                 };
> > +               struct {        /* dma_pool pages */
> > +                       struct list_head dma_list;
> > +                       unsigned short in_use;
> > +                       unsigned short offset;
> > +                       dma_addr_t dma;
> > +               };
> >  
> >                 /** @rcu_head: You can use this to free a page by RCU. */
> >                 struct rcu_head rcu_head;
> >
> > page_list -> dma_list
> > vaddr goes away (page_to_virt() exists)
> > dma -> dma
> > in_use and offset shrink from 4 bytes to 2.
> >
> > Some 32-bit systems have a 64-bit dma_addr_t, and on those systems,
> > this will be 8 + 2 + 2 + 8 = 20 bytes.  On 64-bit systems, it'll be
> > 16 + 2 + 2 + 4 bytes of padding + 8 = 32 bytes (we have 40 available).
> >
> >
> offset at least needs more bits, since allocations can be multi-page. 

Ah, rats.  That means we have to use the mapcount union too:

+++ b/include/linux/mm_types.h
@@ -152,6 +152,11 @@ struct page {
                        unsigned long hmm_data;
                        unsigned long _zd_pad_1;        /* uses mapping */
                };
+               struct {        /* dma_pool pages */
+                       struct list_head dma_list;
+                       unsigned int dma_in_use;
+                       dma_addr_t dma;
+               };
 
                /** @rcu_head: You can use this to free a page by RCU. */
                struct rcu_head rcu_head;
@@ -174,6 +179,7 @@ struct page {
 
                unsigned int active;            /* SLAB */
                int units;                      /* SLOB */
+               unsigned int dma_offset;        /* dma_pool */
        };
 
        /* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */


> See the following from mpt3sas:
> 
> cat /sys/devices/pci0000:80/0000:80:07.0/0000:85:00.0/pools
> (manually cleaned up column alignment)
> poolinfo - 0.1
> reply_post_free_array pool  1      21     192     1
> reply_free pool             1      1      41728   1
> reply pool                  1      1      1335296 1
> sense pool                  1      1      970272  1
> chain pool                  373959 386048 128     12064
> reply_post_free pool        12     12     166528  12
>                                           ^size^

Wow, that's a pretty weird way to use the dmapool.  It'd be more efficient
to just call dma_alloc_coherent() directly.
