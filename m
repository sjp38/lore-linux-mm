Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD25C6B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 11:51:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m30so1297848pgn.2
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 08:51:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g4si5041259plb.358.2017.09.18.08.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 08:51:38 -0700 (PDT)
Date: Mon, 18 Sep 2017 08:51:34 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [V5, 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN in
 non-coherent DMA mode
Message-ID: <20170918155134.GC16672@infradead.org>
References: <1505708548-4750-1-git-send-email-chenhc@lemote.com>
 <601437ae-2860-c48a-aa7c-4da37aeb6256@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <601437ae-2860-c48a-aa7c-4da37aeb6256@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Huacai Chen <chenhc@lemote.com>, Andrew Morton <akpm@linux-foundation.org>, Fuxin Zhang <zhangfx@lemote.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, Sep 18, 2017 at 10:44:54AM +0100, Robin Murphy wrote:
> On 18/09/17 05:22, Huacai Chen wrote:
> > In non-coherent DMA mode, kernel uses cache flushing operations to
> > maintain I/O coherency, so the dmapool objects should be aligned to
> > ARCH_DMA_MINALIGN. Otherwise, it will cause data corruption, at least
> > on MIPS:
> > 
> > 	Step 1, dma_map_single
> > 	Step 2, cache_invalidate (no writeback)
> > 	Step 3, dma_from_device
> > 	Step 4, dma_unmap_single
> 
> This is a massive red warning flag for the whole series, because DMA
> pools don't work like that. At best, this will do nothing, and at worst
> it is papering over egregious bugs elsewhere. Streaming mappings of
> coherent allocations means completely broken code.

Oh, I hadn't even seen that part.  Yes, dma coherent (and pool)
allocations must never be used for streaming mappings.  I wish we'd
have some debug infrastructure to warn on such uses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
