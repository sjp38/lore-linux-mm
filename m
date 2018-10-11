Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98DAA6B000A
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:37:32 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id y6-v6so3052519wmc.4
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:37:32 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f2-v6si14855190wmg.24.2018.10.11.06.37.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 06:37:31 -0700 (PDT)
Date: Thu, 11 Oct 2018 15:37:30 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 5/5] RISC-V: Implement sparsemem
Message-ID: <20181011133730.GB7276@lst.de>
References: <20181005161642.2462-1-logang@deltatee.com> <20181005161642.2462-6-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181005161642.2462-6-logang@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Andrew Waterman <andrew@sifive.com>, Olof Johansson <olof@lixom.net>, Michael Clark <michaeljclark@mac.com>, Rob Herring <robh@kernel.org>, Zong Li <zong@andestech.com>

> +/*
> + * Log2 of the upper bound of the size of a struct page. Used for sizing
> + * the vmemmap region only, does not affect actual memory footprint.
> + * We don't use sizeof(struct page) directly since taking its size here
> + * requires its definition to be available at this point in the inclusion
> + * chain, and it may not be a power of 2 in the first place.
> + */
> +#define STRUCT_PAGE_MAX_SHIFT	6

I know this is copied from arm64, but wouldn't this be a good time
to move this next to the struct page defintion?

Also this:

arch/arm64/mm/init.c:   BUILD_BUG_ON(sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT));

should move to comment code (or would have to be duplicated for riscv)

> +#define VMEMMAP_SIZE	(UL(1) << (CONFIG_VA_BITS - PAGE_SHIFT - 1 + \
> +				   STRUCT_PAGE_MAX_SHIFT))

Might be more readable with a another define, and without abuse of the
horrible UL macro:

#define VMEMMAP_SHIFT \
	(CONFIG_VA_BITS - PAGE_SHIFT - 1 + STRUCT_PAGE_MAX_SHIFT)
#define VMEMMAP_SIZE	(1UL << VMEMMAP_SHIFT)

> +#define VMEMMAP_END	(VMALLOC_START - 1)
> +#define VMEMMAP_START	(VMALLOC_START - VMEMMAP_SIZE)
> +
> +#define vmemmap		((struct page *)VMEMMAP_START)

This could also use some comments..

> @@ -0,0 +1,11 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +
> +#ifndef __ASM_SPARSEMEM_H
> +#define __ASM_SPARSEMEM_H
> +
> +#ifdef CONFIG_SPARSEMEM
> +#define MAX_PHYSMEM_BITS	CONFIG_PA_BITS
> +#define SECTION_SIZE_BITS	30
> +#endif
> +
> +#endif

For potentially wide-spanning ifdefs like inclusion headers it always
is nice to have a comment with the symbol on the endif line.
