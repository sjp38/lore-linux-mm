Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 334006B0006
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:21:34 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t17-v6so10475092ply.13
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:21:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 123-v6si12713858pgj.399.2018.06.18.10.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Jun 2018 10:21:33 -0700 (PDT)
Subject: Re: [PATCH 10/11] docs/mm: memblock: add overview documentation
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1529341199-17682-11-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <fd545e61-6ccc-58b6-e9be-4e7f180c2ca9@infradead.org>
Date: Mon, 18 Jun 2018 10:21:31 -0700
MIME-Version: 1.0
In-Reply-To: <1529341199-17682-11-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Hi,

On 06/18/2018 09:59 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  mm/memblock.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 55 insertions(+)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index c4838a9..8bfeb82 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -26,6 +26,61 @@
>  
>  #include "internal.h"
>  
> +/**
> + * DOC: memblock overview
> + *
> + * Memblock is a method of managing memory regions during the early
> + * boot period when the usual kernel memory allocators are not up and
> + * running.
> + *
> + * Memblock views the system memory as collections of contiguous
> + * regions. There are several types of these collections:
> + *
> + * * ``memory`` - describes the physical memory available to the
> + *   kernel; this may differ from the actual physical memory installed
> + *   in the system, for instance when the memory is restricted with
> + *   ``mem=`` command line parameter
> + * * ``reserved`` - describes the regions that were allocated
> + * * ``physmap`` - describes the actual physical memory regardless of
> + *   the possible restrictions; the ``physmap`` type is only available
> + *   on some architectures.
> + *
> + * Each region is represented by :c:type:`struct memblock_region` that
> + * defines the region extents, its attributes and NUMA node id on NUMA
> + * systems. Every memory type is described by the :c:type:`struct
> + * memblock_type` which contains an array of memory regions along with
> + * the allocator metadata. The memory types are nicely wrapped with
> + * :c:type:`struct memblock`. This structure is statically initialzed
> + * at build time. The region arrays for the "memory" and "reserved"
> + * types are initially sized to %INIT_MEMBLOCK_REGIONS and for the
> + * "physmap" type to %INIT_PHYSMEM_REGIONS.
> + * The :c:func:`memblock_allow_resize` enables automatic resizing of
> + * the region arrays during addition of new regions. This feature
> + * should be used with care so that memory allocated for the region
> + * array will not overlap with areas that should be reserved, for
> + * example initrd.
> + *
> + * The early architecture setup should tell memblock what is the

      The early architecture setup should tell memblock what the physical
      memory layout is by using :c:func:`memblock_add` or

> + * physical memory layout using :c:func:`memblock_add` or
> + * :c:func:`memblock_add_node` functions. The first function does not
> + * assign the region to a NUMA node and it is approptiate for UMA

                                                 appropriate

> + * systems. Yet, it is possible to use it on NUMA systems as well and
> + * assign the region to a NUMA node later in the setup process using
> + * :c:func:`memblock_set_node`. The :c:func:`memblock_add_node`
> + * performs such an assignment directly.
> + *
> + * Once memblock is setup the memory can be allocated using either
> + * memblock or bootmem APIs.
> + *
> + * As the system boot progresses, the architecture specific
> + * :c:func:`mem_init` function frees all the memory to the buddy page
> + * allocator.
> + *
> + * If an architecure enables %CONFIG_ARCH_DISCARD_MEMBLOCK, the
> + * memblock data structures will be discarded after the system
> + * intialization compltes

      initialization completes.

> + */
> +
>  static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
>  static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
>  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> 


-- 
~Randy
