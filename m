Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5F36B0007
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 20:47:27 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id z136-v6so20720283itc.5
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 17:47:27 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id u33-v6si7489614jaj.25.2018.10.14.17.47.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 14 Oct 2018 17:47:25 -0700 (PDT)
Message-ID: <9cfe508c687068853a6e5e030962a78467a8d313.camel@kernel.crashing.org>
Subject: Re: [PATCH 01/33] powerpc: use mm zones more sensibly
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 15 Oct 2018 11:47:13 +1100
In-Reply-To: <20181009132500.17643-2-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
	 <20181009132500.17643-2-hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2018-10-09 at 15:24 +0200, Christoph Hellwig wrote:
>   * Find the least restrictive zone that is entirely below the
> @@ -324,11 +305,14 @@ void __init paging_init(void)
>         printk(KERN_DEBUG "Memory hole size: %ldMB\n",
>                (long int)((top_of_ram - total_ram) >> 20));
>  
> +#ifdef CONFIG_ZONE_DMA
> +       max_zone_pfns[ZONE_DMA] = min(max_low_pfn, 0x7fffffffUL >> PAGE_SHIFT);
> +#endif
> +       max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
>  #ifdef CONFIG_HIGHMEM
> -       limit_zone_pfn(ZONE_NORMAL, lowmem_end_addr >> PAGE_SHIFT);
> +       max_zone_pfns[ZONE_HIGHMEM] = max_pfn
                                               ^
Missing a  ";" here  --------------------------|

Sorry ... works with that fix on an old laptop with highmem.

>  #endif
> -       limit_zone_pfn(TOP_ZONE, top_of_ram >> PAGE_SHIFT);
> -       zone_limits_final = true;
> +
>         free_area_init_nodes(max_zone_pfns);
>  
