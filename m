Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3306B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 09:04:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y75so35927wrc.18
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:04:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h128si6802679wmh.130.2018.02.14.06.04.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Feb 2018 06:04:32 -0800 (PST)
Date: Wed, 14 Feb 2018 15:04:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180214140430.GB3443@dhcp22.suse.cz>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <20180208232004.GA21027@bombadil.infradead.org>
 <20180211092652.GV21609@dhcp22.suse.cz>
 <20180211112808.GA4551@bombadil.infradead.org>
 <20180211120515.GB4551@bombadil.infradead.org>
 <20180211235107.GE4680@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180211235107.GE4680@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kai Heng Feng <kai.heng.feng@canonical.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, James.Bottomley@HansenPartnership.com, davem@redhat.com

On Sun 11-02-18 15:51:07, Matthew Wilcox wrote:
> On Sun, Feb 11, 2018 at 04:05:15AM -0800, Matthew Wilcox wrote:
> > On Sun, Feb 11, 2018 at 03:28:08AM -0800, Matthew Wilcox wrote:
> > > Now, longer-term, perhaps we should do the following:
> > > 
> > > #ifdef CONFIG_ZONE_DMA32
> > > #define OPT_ZONE_DMA32	ZONE_DMA32
> > > #elif defined(CONFIG_64BIT)
> > > #define OPT_ZONE_DMA	OPT_ZONE_DMA
> > > #else
> > > #define OPT_ZONE_DMA32 ZONE_NORMAL
> > > #endif
> > 
> > For consistent / coherent memory, we have an allocation function.
> > But we don't have an allocation function for streaming memory, which is
> > what these drivers want.  They also flush the DMA memory and then access
> > the memory through a different virtual mapping, which I'm not sure is
> > going to work well on virtually-indexed caches like SPARC and PA-RISC
> > (maybe not MIPS either?)
> 
> Perhaps I (and a number of other people ...) have misunderstood the
> semantics of GFP_DMA32.  Perhaps GFP_DMA32 is not "allocate memory below
> 4GB", perhaps it's "allocate memory which can be mapped below 4GB".

Well, GFP_DMA32 is clearly under-documented. But I _believe_ the
intention was to really return a physical memory within 32b address
range.

> Machines with an IOMMU can use ZONE_NORMAL.  Machines with no IOMMU can
> choose to allocate memory with a physical address below 4GB.

This would be something for the higher level allocator I think. The page
allocator is largely unaware of IOMMU or any remapping and that is good
IMHO.

> After all, it has 'DMA' right there in the name.

The name is misnomer following GFP_DMA which is arguably a better fit.
GFP_MEM32 would be a better name.

Btw. I believe the GFP_VMALLOC32 shows that our GFP_DM32 needs some
love. The user shouldn't really care about lowmem zones layout.
GFP_DMA32 should simply use the appropriate zone regardless the arch
specific details.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
