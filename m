Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27D736B6F20
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 09:25:44 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so12668866pll.0
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 06:25:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y26si18070563pfd.25.2018.12.04.06.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 06:25:43 -0800 (PST)
Date: Tue, 4 Dec 2018 06:25:30 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3, RFC] iommu/io-pgtable-arm-v7s: Use page_frag to
 request DMA32 memory
Message-ID: <20181204142530.GA2917@infradead.org>
References: <20181204082300.95106-1-drinkcat@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204082300.95106-1-drinkcat@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Boichat <drinkcat@chromium.org>
Cc: Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>, yingjoe.chen@mediatek.com, hch@infradead.org, Matthew Wilcox <willy@infradead.org>

On Tue, Dec 04, 2018 at 04:23:00PM +0800, Nicolas Boichat wrote:
> IOMMUs using ARMv7 short-descriptor format require page tables
> (level 1 and 2) to be allocated within the first 4GB of RAM, even
> on 64-bit systems.
> 
> For level 1/2 tables, ensure GFP_DMA32 is used if CONFIG_ZONE_DMA32
> is defined (e.g. on arm64 platforms).
> 
> For level 2 tables (1 KB), we use page_frag to allocate these pages,
> as we cannot directly use kmalloc (no slab cache for GFP_DMA32) or
> kmem_cache (mm/ code treats GFP_DMA32 as an invalid flag).
> 
> One downside is that we only free the allocated page if all the
> 4 fragments (4 IOMMU L2 tables) are freed, but given that we
> usually only allocate limited number of IOMMU L2 tables, this
> should not have too much impact on memory usage: In the absolute
> worst case (4096 L2 page tables, each on their own 4K page),
> we would use 16 MB of memory for 4 MB of L2 tables.

I think this needs to be documemented in the code.  That is move
the explanation about into a comment in the code.
