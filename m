Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id D59286B0271
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:45:59 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id c13-v6so834682uao.8
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:45:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g64-v6sor789930uag.179.2018.07.26.12.45.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Jul 2018 12:45:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Thu, 26 Jul 2018 22:45:58 +0300
Message-ID: <CAHp75VcpM5W7+xgVy6nZf2hOXD8ghy5bwoJpAFse_ccp7OopNA@mail.gmail.com>
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Matthew Wilcox <willy@infradead.org>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Thu, Jul 26, 2018 at 9:54 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> dma_pool_free() scales poorly when the pool contains many pages because
> pool_find_page() does a linear scan of all allocated pages.  Improve its
> scalability by replacing the linear scan with a red-black tree lookup.
> In big O notation, this improves the algorithm from O(n^2) to O(n * log n).

Few style related comments.

> I moved some code from dma_pool_destroy() into pool_free_page() to avoid code
> repetition.

I would rather split that part as a separate preparatory change which
doesn't change the behaviour.

>  #include <linux/string.h>
>  #include <linux/types.h>
>  #include <linux/wait.h>

> +#include <linux/rbtree.h>

It looks misordered.

> +               struct dma_page *this_page =
> +                       container_of(*node, struct dma_page, page_node);

#define to_dma_page() container_of() ?

> +                       WARN(1,
> +                            "%s: %s: DMA address overlap: old 0x%llx new 0x%llx len %zu\n",
> +                            pool->dev ? dev_name(pool->dev) : "(nodev)",
> +                            pool->name, (u64) this_page->dma, (u64) dma,

Use proper %p extensions for the DMA addresses:
https://elixir.bootlin.com/linux/latest/source/Documentation/core-api/printk-formats.rst#L150

-- 
With Best Regards,
Andy Shevchenko
