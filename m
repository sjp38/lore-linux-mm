Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 622206B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 18:30:59 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id t59so645093yho.34
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 15:30:59 -0800 (PST)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id s6si2543259yho.14.2014.01.08.15.30.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 15:30:58 -0800 (PST)
Received: by mail-ie0-f169.google.com with SMTP id e14so2838674iej.0
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 15:30:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140108144213.4c1995b2@lilie>
References: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389107774-54978-3-git-send-email-phacht@linux.vnet.ibm.com>
	<52CCCF24.4080300@huawei.com>
	<20140108144213.4c1995b2@lilie>
Date: Wed, 8 Jan 2014 15:30:57 -0800
Message-ID: <CAE9FiQVhutAGXeQO_fevrJ+wDXgL=x20Gg2Zkk81Lkebwzf_Nw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: free memblock.memory in free_all_bootmem
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>

On Wed, Jan 8, 2014 at 5:42 AM, Philipp Hachtmann
<phacht@linux.vnet.ibm.com> wrote:
> Am Wed, 8 Jan 2014 12:08:04 +0800
> schrieb Jianguo Wu <wujianguo@huawei.com>:
>
>> For some archs, like arm64, would use memblock.memory after system
>> booting, so we can not simply released to the buddy allocator, maybe
>> need !defined(CONFIG_ARCH_DISCARD_MEMBLOCK).
>
> Oh, I see. I have added some ifdefs to prevent memblock.memory from
> being freed when CONFIG_ARCH_DISCARD_MEMBLOCK is not set.
>
> Here is a replacement for the patch.
>
> Kind regards
>
> Philipp
>
> From aca95bcb9d79388b68bf18e7bae4353259b6758f Mon Sep 17 00:00:00 2001
> From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
> Date: Thu, 19 Dec 2013 15:53:46 +0100
> Subject: [PATCH 2/2] mm: free memblock.memory in free_all_bootmem
>
> When calling free_all_bootmem() the free areas under memblock's
> control are released to the buddy allocator. Additionally the
> reserved list is freed if it was reallocated by memblock.
> The same should apply for the memory list.
>
> Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
> ---
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 16 ++++++++++++++++
>  mm/nobootmem.c           | 10 +++++++++-
>  3 files changed, 26 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 77c60e5..d174922 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -52,6 +52,7 @@ phys_addr_t memblock_find_in_range_node(phys_addr_t start, phys_addr_t end,
>  phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
>                                    phys_addr_t size, phys_addr_t align);
>  phys_addr_t get_allocated_memblock_reserved_regions_info(phys_addr_t *addr);
> +phys_addr_t get_allocated_memblock_memory_regions_info(phys_addr_t *addr);
>  void memblock_allow_resize(void);
>  int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
>  int memblock_add(phys_addr_t base, phys_addr_t size);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 53e477b..a78b2e9 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -271,6 +271,22 @@ phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
>                           memblock.reserved.max);
>  }
>
> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> +
> +phys_addr_t __init_memblock get_allocated_memblock_memory_regions_info(
> +                                       phys_addr_t *addr)
> +{
> +       if (memblock.memory.regions == memblock_memory_init_regions)
> +               return 0;
> +
> +       *addr = __pa(memblock.memory.regions);
> +
> +       return PAGE_ALIGN(sizeof(struct memblock_region) *
> +                         memblock.memory.max);
> +}
> +
> +#endif
> +
>  /**
>   * memblock_double_array - double the size of the memblock regions array
>   * @type: memblock type of the regions array being doubled
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 3a7e14d..63ff3f6 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -122,11 +122,19 @@ static unsigned long __init free_low_memory_core_early(void)
>         for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
>                 count += __free_memory_core(start, end);
>
> -       /* free range that is used for reserved array if we allocate it */
> +       /* Free memblock.reserved array if it was allocated */
>         size = get_allocated_memblock_reserved_regions_info(&start);
>         if (size)
>                 count += __free_memory_core(start, start + size);
>
> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> +
> +       /* Free memblock.memory array if it was allocated */
> +       size = get_allocated_memblock_memory_regions_info(&start);
> +       if (size)
> +               count += __free_memory_core(start, start + size);
> +#endif
> +
>         return count;
>  }

I sent similar before.

http://www.gossamer-threads.com/lists/engine?do=post_attachment;postatt_id=49616;list=linux

http://www.gossamer-threads.com/lists/linux/kernel/1556026?do=post_view_threaded#1556026

Also for arches that do not free memblock, do they still need to access
memblock.reserved.regions ?

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
