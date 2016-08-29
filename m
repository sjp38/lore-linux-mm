Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC55F830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:26:07 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so267686618pab.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:26:07 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id b7si39187199pas.289.2016.08.29.06.26.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 06:26:07 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm/nobootmem.c: make CONFIG_NO_BOOTMEM depend on
 CONFIG_HAVE_MEMBLOCK
References: <9e9ff2eb-c7e3-4790-9678-85548306e3ac@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <f5cda0af-3137-ef00-2aa3-dd830c4997a9@zoho.com>
Date: Mon, 29 Aug 2016 21:25:42 +0800
MIME-Version: 1.0
In-Reply-To: <9e9ff2eb-c7e3-4790-9678-85548306e3ac@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mingo@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com

i am sorry, this patch has many bugs
i resend it in another mail thread
please ignore it

On 2016/8/27 23:27, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> this patch fixes the following bugs:
> 
>  - no bootmem is implemented by memblock currently, but config option
>    CONFIG_NO_BOOTMEM doesn't depend on CONFIG_HAVE_MEMBLOCK
> 
>  - the same ARCH_LOW_ADDRESS_LIMIT statements are duplicated between
>    header and relevant source
> 
>  - don't ensure ARCH_LOW_ADDRESS_LIMIT perhaps defined by ARCH in
>    asm/processor.h is preferred over default in linux/bootmem.h
>    completely since the former header isn't included by the latter
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> ---
>  include/linux/bootmem.h | 13 +++++++------
>  mm/Kconfig              |  6 ++++--
>  mm/nobootmem.c          |  6 +-----
>  3 files changed, 12 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index f9be32691718..95968236abc7 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -7,6 +7,7 @@
>  #include <linux/mmzone.h>
>  #include <linux/mm_types.h>
>  #include <asm/dma.h>
> +#include <asm/processor.h>
>  
>  /*
>   *  simple boot-time physical memory area allocator.
> @@ -119,6 +120,10 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
>  #define BOOTMEM_LOW_LIMIT __pa(MAX_DMA_ADDRESS)
>  #endif
>  
> +#ifndef ARCH_LOW_ADDRESS_LIMIT
> +#define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
> +#endif
> +
>  #define alloc_bootmem(x) \
>  	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
>  #define alloc_bootmem_align(x, align) \
> @@ -148,7 +153,7 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
>  	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
>  
>  
> -#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
> +#if defined(CONFIG_NO_BOOTMEM)
>  
>  /* FIXME: use MEMBLOCK_ALLOC_* variants here */
>  #define BOOTMEM_ALLOC_ACCESSIBLE	0
> @@ -180,10 +185,6 @@ static inline void * __init memblock_virt_alloc_nopanic(
>  						    NUMA_NO_NODE);
>  }
>  
> -#ifndef ARCH_LOW_ADDRESS_LIMIT
> -#define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
> -#endif
> -
>  static inline void * __init memblock_virt_alloc_low(
>  					phys_addr_t size, phys_addr_t align)
>  {
> @@ -333,7 +334,7 @@ static inline void __init memblock_free_late(
>  {
>  	free_bootmem_late(base, size);
>  }
> -#endif /* defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM) */
> +#endif /* defined(CONFIG_NO_BOOTMEM) */
>  
>  #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
>  extern void *alloc_remap(int nid, unsigned long size);
> diff --git a/mm/Kconfig b/mm/Kconfig
> index be0ee11fa0d9..b7f19ff4b743 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -144,14 +144,16 @@ config ARCH_DISCARD_MEMBLOCK
>  	bool
>  
>  config NO_BOOTMEM
> -	bool
> +	bool "No legacy boot memory"
> +	depends on HAVE_MEMBLOCK
> +	help
> +	 NO_BOOTMEM is implemented by memblock
>  
>  config MEMORY_ISOLATION
>  	bool
>  
>  config MOVABLE_NODE
>  	bool "Enable to assign a node which has only movable memory"
> -	depends on HAVE_MEMBLOCK
>  	depends on NO_BOOTMEM
>  	depends on X86_64
>  	depends on NUMA
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index bd05a70f44b9..1802c9bbe11a 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -11,15 +11,14 @@
>  #include <linux/init.h>
>  #include <linux/pfn.h>
>  #include <linux/slab.h>
> -#include <linux/bootmem.h>
>  #include <linux/export.h>
>  #include <linux/kmemleak.h>
>  #include <linux/range.h>
>  #include <linux/memblock.h>
> +#include <linux/bootmem.h>
>  
>  #include <asm/bug.h>
>  #include <asm/io.h>
> -#include <asm/processor.h>
>  
>  #include "internal.h"
>  
> @@ -395,9 +394,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
>  	return __alloc_bootmem_node(pgdat, size, align, goal);
>  }
>  
> -#ifndef ARCH_LOW_ADDRESS_LIMIT
> -#define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
> -#endif
>  
>  /**
>   * __alloc_bootmem_low - allocate low boot memory
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
