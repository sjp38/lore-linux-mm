Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 056EB6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 06:30:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f84so11344128pfj.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 03:30:52 -0700 (PDT)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id r59si8023172plb.637.2017.10.02.03.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 03:30:51 -0700 (PDT)
Message-ID: <1506940241.28397.36.camel@mtkswgap22>
Subject: Re: [PATCH v3] dma-debug: fix incorrect pfn calculation
From: Miles Chen <miles.chen@mediatek.com>
Date: Mon, 2 Oct 2017 18:30:41 +0800
In-Reply-To: <20171001080449.GB11843@lst.de>
References: <1506484087-1177-1-git-send-email-miles.chen@mediatek.com>
	 <273077fd-c5ad-82c8-60aa-cde89355e5e8@arm.com>
	 <20171001080449.GB11843@lst.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Robin Murphy <robin.murphy@arm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, wsd_upstream@mediatek.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, linux-mediatek@lists.infradead.org

On Sun, 2017-10-01 at 10:04 +0200, Christoph Hellwig wrote:
> On Wed, Sep 27, 2017 at 11:23:52AM +0100, Robin Murphy wrote:
> > > I found that debug_dma_alloc_coherent() and debug_dma_free_coherent()
> > > assume that dma_alloc_coherent() always returns a linear address.
> > > However it's possible that dma_alloc_coherent() returns a non-linear
> > > address. In this case, page_to_pfn(virt_to_page(virt)) will return an
> > > incorrect pfn. If the pfn is valid and mapped as a COW page,
> > > we will hit the warning when doing wp_page_copy().
> 
> Hmm, can the debug code assume anything?  Right now you're just patching
> it from supporting linear and vmalloc.  But what about other
> potential mapping types?

thanks for the review.

ARCHs like metag and xtensa define their mappings (non-vmalloc and
non-linear) for dma allocation.
These mapping types are architecture-dependent and should not be used
outside arch folders. So it is hard to check the mappings and convert
a virtual address to a correct pfn in lib/dam-debug.c

How about recording only vmalloc (by is_vmalloc_addr()) and linear
address (by virt_addr_valid()) in lib/dma-debug? Since current 
implementation is not correct for those ARCHs.

if (!is_vmalloc_addr(addr) && !virt_addr_valid(addr))
    return;

or

every ARCH should define its own dmava-to-pfn API to convert
a dma-allocted virtual address to a correct pfn and lib/dma-debug.c
can use that API directly. (long-term)

> 
> > > +	entry->pfn	 = is_vmalloc_addr(virt) ? vmalloc_to_pfn(virt) :
> > > +						page_to_pfn(virt_to_page(virt));
> 
> Please use normal if/else conditionsals:

Is this for better readability? I'll send another patch for this.


thanks 
> 
> 	if (is_vmalloc_addr(virt))
> 		entry->pfn = vmalloc_to_pfn(virt);
> 	else
> 		entry->pfn = page_to_pfn(virt_to_page(virt));
> 
> > > +		.pfn		= is_vmalloc_addr(virt) ? vmalloc_to_pfn(virt) :
> > > +						page_to_pfn(virt_to_page(virt)),
> 
> Same here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
