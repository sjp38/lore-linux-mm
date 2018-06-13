Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 38F766B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 08:24:07 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id s3-v6so1395684plp.21
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 05:24:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j10-v6si2747239pfk.203.2018.06.13.05.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 05:24:05 -0700 (PDT)
Date: Wed, 13 Jun 2018 05:24:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: cma: honor __GFP_ZERO flag in cma_alloc()
Message-ID: <20180613122359.GA8695@bombadil.infradead.org>
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

I think the documentation for this function needs improving.  For example,
GFP_ATOMIC does not work (it takes a mutex lock, so it can sleep).
At the very least, the kernel-doc needs:

 * Context: Process context (may sleep even if GFP flags indicate otherwise).

Unless someone wants to rework this allocator to use spinlocks instead
of mutexes ...
