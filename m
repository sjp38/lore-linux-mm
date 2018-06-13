Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 648C86B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 08:52:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n19-v6so1273919pff.8
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 05:52:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p22-v6si2286456pgv.236.2018.06.13.05.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 05:52:44 -0700 (PDT)
Date: Wed, 13 Jun 2018 05:52:42 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: cma: honor __GFP_ZERO flag in cma_alloc()
Message-ID: <20180613125242.GA32016@infradead.org>
References: <CGME20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2@eucas1p2.samsung.com>
 <20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2~3rI_9nj8b0455904559eucas1p2C@eucas1p2.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180613085851eucas1p20337d050face8ff8ea87674e16a9ccd2~3rI_9nj8b0455904559eucas1p2C@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Jun 13, 2018 at 10:58:37AM +0200, Marek Szyprowski wrote:
> cma_alloc() function has gfp mask parameter, so users expect that it
> honors typical memory allocation related flags. The most imporant from
> the security point of view is handling of __GFP_ZERO flag, because memory
> allocated by this function usually can be directly remapped to userspace
> by device drivers as a part of multimedia processing and ignoring this
> flag might lead to leaking some kernel structures to userspace.
> Some callers of this function (for example arm64 dma-iommu glue code)
> already assumed that the allocated buffers are cleared when this flag
> is set. To avoid such issues, add simple code for clearing newly
> allocated buffer when __GFP_ZERO flag is set. Callers will be then
> updated to skip implicit clearing or adjust passed gfp flags.

dma mapping implementations need to zero all memory returned anyway
(even if a few implementation don't do that yet).

I'd rather keep the zeroing in the common callers.
