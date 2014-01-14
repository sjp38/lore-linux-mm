Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f182.google.com (mail-gg0-f182.google.com [209.85.161.182])
	by kanga.kvack.org (Postfix) with ESMTP id 58D1E6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 14:22:30 -0500 (EST)
Received: by mail-gg0-f182.google.com with SMTP id e27so229770gga.27
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:22:30 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id t26si2049188yhl.205.2014.01.14.11.22.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 11:22:29 -0800 (PST)
Received: by mail-ig0-f179.google.com with SMTP id c10so2439966igq.0
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:22:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1389613034-35196-2-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389613034-35196-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389613034-35196-2-git-send-email-phacht@linux.vnet.ibm.com>
Date: Tue, 14 Jan 2014 11:22:28 -0800
Message-ID: <CAE9FiQUwAr1naCF1wBQN1xKYkb_BwS7w3bmpt8ugB=bQhOGL+Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/nobootmem: free_all_bootmem again
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>, David Howells <dhowells@redhat.com>, daeseok.youn@gmail.com, Jiang Liu <liuj97@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>, grygorii.strashko@ti.com, Tang Chen <tangchen@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Mon, Jan 13, 2014 at 3:37 AM, Philipp Hachtmann
<phacht@linux.vnet.ibm.com> wrote:
> get_allocated_memblock_reserved_regions_info() should work if it is
> compiled in. Extended the ifdef around
> get_allocated_memblock_memory_regions_info() to include
> get_allocated_memblock_reserved_regions_info() as well.
> Similar changes in nobootmem.c/free_low_memory_core_early() where
> the two functions are called.
>
> Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>

Acked-by: Yinghai Lu <yinghai@kernel.org>

> ---
>  mm/memblock.c  | 17 ++---------------
>  mm/nobootmem.c |  4 ++--
>  2 files changed, 4 insertions(+), 17 deletions(-)
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 64ed243..9c0aeef 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -266,33 +266,20 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
>         }
>  }
>
> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> +
>  phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
>                                         phys_addr_t *addr)
>  {
>         if (memblock.reserved.regions == memblock_reserved_init_regions)
>                 return 0;
>
> -       /*
> -        * Don't allow nobootmem allocator to free reserved memory regions
> -        * array if
> -        *  - CONFIG_DEBUG_FS is enabled;
> -        *  - CONFIG_ARCH_DISCARD_MEMBLOCK is not enabled;
> -        *  - reserved memory regions array have been resized during boot.
> -        * Otherwise debug_fs entry "sys/kernel/debug/memblock/reserved"
> -        * will show garbage instead of state of memory reservations.
> -        */
> -       if (IS_ENABLED(CONFIG_DEBUG_FS) &&
> -           !IS_ENABLED(CONFIG_ARCH_DISCARD_MEMBLOCK))
> -               return 0;
> -
>         *addr = __pa(memblock.reserved.regions);
>
>         return PAGE_ALIGN(sizeof(struct memblock_region) *
>                           memblock.reserved.max);
>  }
>
> -#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> -
>  phys_addr_t __init_memblock get_allocated_memblock_memory_regions_info(
>                                         phys_addr_t *addr)
>  {
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 17c8902..e2906a5 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -122,13 +122,13 @@ static unsigned long __init free_low_memory_core_early(void)
>         for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
>                 count += __free_memory_core(start, end);
>
> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> +
>         /* Free memblock.reserved array if it was allocated */
>         size = get_allocated_memblock_reserved_regions_info(&start);
>         if (size)
>                 count += __free_memory_core(start, start + size);
>
> -#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> -
>         /* Free memblock.memory array if it was allocated */
>         size = get_allocated_memblock_memory_regions_info(&start);
>         if (size)
> --
> 1.8.4.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
