Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0136B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 16:38:35 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so4636215pad.36
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 13:38:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gm1si11223244pac.216.2014.01.17.13.38.33
        for <linux-mm@kvack.org>;
        Fri, 17 Jan 2014 13:38:33 -0800 (PST)
Date: Fri, 17 Jan 2014 13:38:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/nobootmem: Fix unused variable
Message-Id: <20140117133831.2a9306a03f9c6174ff096e48@linux-foundation.org>
In-Reply-To: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>

On Thu, 16 Jan 2014 14:33:06 +0100 Philipp Hachtmann <phacht@linux.vnet.ibm.com> wrote:

> This fixes an unused variable warning in nobootmem.c
> 
> ...
>
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -116,9 +116,13 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
>  static unsigned long __init free_low_memory_core_early(void)
>  {
>  	unsigned long count = 0;
> -	phys_addr_t start, end, size;
> +	phys_addr_t start, end;
>  	u64 i;
>  
> +#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> +	phys_addr_t size;
> +#endif
> +
>  	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
>  		count += __free_memory_core(start, end);

Yes, that is a bit of an eyesore.  We often approach the problem this
way, which is nicer:

static unsigned long __init free_low_memory_core_early(void)
{
	unsigned long count = 0;
	phys_addr_t start, end;
	u64 i;

	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
		count += __free_memory_core(start, end);

#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
	{
		phys_addr_t size;

		/* Free memblock.reserved array if it was allocated */
		size = get_allocated_memblock_reserved_regions_info(&start);
		if (size)
			count += __free_memory_core(start, start + size);

		/* Free memblock.memory array if it was allocated */
		size = get_allocated_memblock_memory_regions_info(&start);
		if (size)
			count += __free_memory_core(start, start + size);
	}
#endif

	return count;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
