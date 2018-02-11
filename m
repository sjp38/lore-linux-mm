Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98CE96B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 07:05:21 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d63so1312063wma.4
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 04:05:21 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id r12si4662402wrg.527.2018.02.11.04.05.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 04:05:20 -0800 (PST)
Date: Sun, 11 Feb 2018 04:05:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180211120515.GB4551@bombadil.infradead.org>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <20180208232004.GA21027@bombadil.infradead.org>
 <20180211092652.GV21609@dhcp22.suse.cz>
 <20180211112808.GA4551@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180211112808.GA4551@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kai Heng Feng <kai.heng.feng@canonical.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, James.Bottomley@HansenPartnership.com, davem@redhat.com

On Sun, Feb 11, 2018 at 03:28:08AM -0800, Matthew Wilcox wrote:
> Now, longer-term, perhaps we should do the following:
> 
> #ifdef CONFIG_ZONE_DMA32
> #define OPT_ZONE_DMA32	ZONE_DMA32
> #elif defined(CONFIG_64BIT)
> #define OPT_ZONE_DMA	OPT_ZONE_DMA
> #else
> #define OPT_ZONE_DMA32 ZONE_NORMAL
> #endif
> 
> Then we wouldn't need the ifdef here and could always use GFP_DMA32
> | GFP_KERNEL.  Would need to audit current users and make sure they
> wouldn't be broken by such a change.

Argh, I forgot to say the most important thing.  (For those newly invited
to the party, we're talking about drivers/media, in particular
drivers/media/common/saa7146/saa7146_core.c, functions
saa7146_vmalloc_build_pgtable and vmalloc_to_sg)

I think we're missing a function in our DMA API.  These drivers don't
actually need physical memory below the 4GB mark.  They need DMA addresses
which are below the 4GB mark.  For machines with IOMMUs, this can mean
no restrictions on physical memory.  If we don't have an IOMMU, then a
bounce buffer could be used (but would be slow) -- like the swiotlb.
So we should endeavour to allocate memory below the 4GB boundary on
systems with no IOMMU, but can allocate memory anywhere on systems with
an IOMMU.

For consistent / coherent memory, we have an allocation function.
But we don't have an allocation function for streaming memory, which is
what these drivers want.  They also flush the DMA memory and then access
the memory through a different virtual mapping, which I'm not sure is
going to work well on virtually-indexed caches like SPARC and PA-RISC
(maybe not MIPS either?)

I think we want something like

struct scatterlist *dma_alloc_sg(struct device *dev, int *nents);
void dma_free_sg(struct device *dev, struct scatterlist *sg, int nents);

That lets individual architectures decide where to allocate, and handle
the tradeoff between allocating below 4GB and using bounce buffers.

I don't have a good answer to synchronising between device-view of
memory and CPU-view-through-vmalloc though.  They're already calling
dma_sync_*_for_cpu(); do they need to also call a new vflush(void *p,
unsigned long len) function which can be a no-op on x86 and flushes the
range on SPARC/PA-RISC/... ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
