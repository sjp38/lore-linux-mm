Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97C026B026F
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:42:16 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g24-v6so1904734plq.2
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:42:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x1-v6si1803899plo.307.2018.07.26.12.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Jul 2018 12:42:15 -0700 (PDT)
Date: Thu, 26 Jul 2018 12:42:09 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
Message-ID: <20180726194209.GB12992@bombadil.infradead.org>
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Thu, Jul 26, 2018 at 02:54:56PM -0400, Tony Battersby wrote:
> dma_pool_free() scales poorly when the pool contains many pages because
> pool_find_page() does a linear scan of all allocated pages.  Improve its
> scalability by replacing the linear scan with a red-black tree lookup. 
> In big O notation, this improves the algorithm from O(n^2) to O(n * log n).

This is a lot of code to get us to O(n * log(n)) when we can use less
code to go to O(n).  dma_pool_free() is passed the virtual address.
We can go from virtual address to struct page with virt_to_page().
In struct page, we have 5 words available (20/40 bytes), and it's trivial
to use one of them to point to the struct dma_page.
