Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 059116B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 17:43:15 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id 29so1160919yhl.5
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 14:43:15 -0800 (PST)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id q48si6513876yhb.152.2014.01.16.14.43.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 14:43:15 -0800 (PST)
Received: by mail-yk0-f171.google.com with SMTP id 142so1581430ykq.2
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 14:43:14 -0800 (PST)
Date: Thu, 16 Jan 2014 14:43:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/nobootmem: Fix unused variable
In-Reply-To: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1401161438240.31228@chino.kir.corp.google.com>
References: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 16 Jan 2014, Philipp Hachtmann wrote:

> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index e2906a5..12cbb04 100644
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
>  

Two options: (1) add a helper function declared for 
CONFIG_ARCH_DISCARD_MEMBLOCK that returns the count to add and is empty 
otherwise, or (2) initialize size to zero in its definition.  It's much 
better than #ifdef's inside the function for a variable declaration.

Also, since this is already in -mm, you'll want this fix folded into the 
original patch, "mm/nobootmem: free_all_bootmem again", so it's probably 
best to name it "mm/nobootmem: free_all_bootmem again fix".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
