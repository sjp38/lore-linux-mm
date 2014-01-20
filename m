Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f175.google.com (mail-gg0-f175.google.com [209.85.161.175])
	by kanga.kvack.org (Postfix) with ESMTP id EDFD66B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:28:27 -0500 (EST)
Received: by mail-gg0-f175.google.com with SMTP id c2so2176579ggn.20
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:28:27 -0800 (PST)
Received: from mail-pb0-x230.google.com (mail-pb0-x230.google.com [2607:f8b0:400e:c01::230])
        by mx.google.com with ESMTPS id 21si1830555yhx.206.2014.01.20.08.28.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 08:28:26 -0800 (PST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so7167821pbb.21
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 08:28:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1390217559-14691-2-git-send-email-phacht@linux.vnet.ibm.com>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1390217559-14691-2-git-send-email-phacht@linux.vnet.ibm.com>
Date: Mon, 20 Jan 2014 10:28:25 -0600
Message-ID: <CAPp3RGpRhjwozZiNDFfGEwrH_w6BdK3nnZk5_DD-9UKeoT_Uig@mail.gmail.com>
Subject: Re: [PATCH V5 1/3] mm/nobootmem: Fix unused variable
From: Robin Holt <robinmholt@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, Robin Holt <robin.m.holt@gmail.com>, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 20, 2014 at 5:32 AM, Philipp Hachtmann
<phacht@linux.vnet.ibm.com> wrote:
> This fixes an unused variable warning in nobootmem.c
>
> Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
> ---
>  mm/nobootmem.c | 28 +++++++++++++++++-----------
>  1 file changed, 17 insertions(+), 11 deletions(-)
>
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index e2906a5..0215c77 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -116,23 +116,29 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
>  static unsigned long __init free_low_memory_core_early(void)
>  {
>         unsigned long count = 0;
> -       phys_addr_t start, end, size;
> +       phys_addr_t start, end;
>         u64 i;
>
> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> +       phys_addr_t size;
> +#endif
> +

Is this needed?  It looks like you declare size again inside the next
#ifdef chunk.

>         for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
>                 count += __free_memory_core(start, end);
>
>  #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> -
> -       /* Free memblock.reserved array if it was allocated */
> -       size = get_allocated_memblock_reserved_regions_info(&start);
> -       if (size)
> -               count += __free_memory_core(start, start + size);
> -
> -       /* Free memblock.memory array if it was allocated */
> -       size = get_allocated_memblock_memory_regions_info(&start);
> -       if (size)
> -               count += __free_memory_core(start, start + size);
> +       {
> +               phys_addr_t size;
> +               /* Free memblock.reserved array if it was allocated */
> +               size = get_allocated_memblock_reserved_regions_info(&start);
> +               if (size)
> +                       count += __free_memory_core(start, start + size);
> +
> +               /* Free memblock.memory array if it was allocated */
> +               size = get_allocated_memblock_memory_regions_info(&start);
> +               if (size)
> +                       count += __free_memory_core(start, start + size);
> +       }
>  #endif
>
>         return count;
> --
> 1.8.4.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
