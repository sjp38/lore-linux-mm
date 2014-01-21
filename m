Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f169.google.com (mail-gg0-f169.google.com [209.85.161.169])
	by kanga.kvack.org (Postfix) with ESMTP id 17C7F6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:16:38 -0500 (EST)
Received: by mail-gg0-f169.google.com with SMTP id j5so2468096ggn.14
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:16:37 -0800 (PST)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id v21si4356824yhm.173.2014.01.20.22.16.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 22:16:37 -0800 (PST)
Received: by mail-yk0-f170.google.com with SMTP id 9so2135384ykp.1
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:16:36 -0800 (PST)
Date: Mon, 20 Jan 2014 22:16:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V5 1/3] mm/nobootmem: Fix unused variable
In-Reply-To: <1390217559-14691-2-git-send-email-phacht@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1401202214540.21729@chino.kir.corp.google.com>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com> <1390217559-14691-2-git-send-email-phacht@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Jan 2014, Philipp Hachtmann wrote:

> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index e2906a5..0215c77 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -116,23 +116,29 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
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
>  
>  #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
> -
> -	/* Free memblock.reserved array if it was allocated */
> -	size = get_allocated_memblock_reserved_regions_info(&start);
> -	if (size)
> -		count += __free_memory_core(start, start + size);
> -
> -	/* Free memblock.memory array if it was allocated */
> -	size = get_allocated_memblock_memory_regions_info(&start);
> -	if (size)
> -		count += __free_memory_core(start, start + size);
> +	{
> +		phys_addr_t size;

I think you may have misunderstood Andrew's suggestion: "size" here is 
overloading the "size" you have already declared for this configuration.

Not sure why you don't just do a one line patch:

-	phys_addr_t size;
+	phys_addr_t size __maybe_unused;

to fix it.

> +		/* Free memblock.reserved array if it was allocated */
> +		size = get_allocated_memblock_reserved_regions_info(&start);
> +		if (size)
> +			count += __free_memory_core(start, start + size);
> +		
> +		/* Free memblock.memory array if it was allocated */
> +		size = get_allocated_memblock_memory_regions_info(&start);
> +		if (size)
> +			count += __free_memory_core(start, start + size);
> +	}
>  #endif
>  
>  	return count;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
