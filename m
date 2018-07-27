Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5AC46B026C
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 20:07:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i68-v6so635190pfb.9
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:07:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e5-v6si2318949plk.304.2018.07.26.17.07.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Jul 2018 17:07:14 -0700 (PDT)
Date: Thu, 26 Jul 2018 17:07:08 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
Message-ID: <20180727000708.GA785@bombadil.infradead.org>
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
 <20180726194209.GB12992@bombadil.infradead.org>
 <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Thu, Jul 26, 2018 at 04:06:05PM -0400, Tony Battersby wrote:
> On 07/26/2018 03:42 PM, Matthew Wilcox wrote:
> > On Thu, Jul 26, 2018 at 02:54:56PM -0400, Tony Battersby wrote:
> >> dma_pool_free() scales poorly when the pool contains many pages because
> >> pool_find_page() does a linear scan of all allocated pages.  Improve its
> >> scalability by replacing the linear scan with a red-black tree lookup. 
> >> In big O notation, this improves the algorithm from O(n^2) to O(n * log n).
> > This is a lot of code to get us to O(n * log(n)) when we can use less
> > code to go to O(n).  dma_pool_free() is passed the virtual address.
> > We can go from virtual address to struct page with virt_to_page().
> > In struct page, we have 5 words available (20/40 bytes), and it's trivial
> > to use one of them to point to the struct dma_page.
> >
> Thanks for the tip.  I will give that a try.

If you're up for more major surgery, then I think we can put all the
information currently stored in dma_page into struct page.  Something
like this:

+++ b/include/linux/mm_types.h
@@ -152,6 +152,12 @@ struct page {
                        unsigned long hmm_data;
                        unsigned long _zd_pad_1;        /* uses mapping */
                };
+               struct {        /* dma_pool pages */
+                       struct list_head dma_list;
+                       unsigned short in_use;
+                       unsigned short offset;
+                       dma_addr_t dma;
+               };
 
                /** @rcu_head: You can use this to free a page by RCU. */
                struct rcu_head rcu_head;

page_list -> dma_list
vaddr goes away (page_to_virt() exists)
dma -> dma
in_use and offset shrink from 4 bytes to 2.

Some 32-bit systems have a 64-bit dma_addr_t, and on those systems,
this will be 8 + 2 + 2 + 8 = 20 bytes.  On 64-bit systems, it'll be
16 + 2 + 2 + 4 bytes of padding + 8 = 32 bytes (we have 40 available).
