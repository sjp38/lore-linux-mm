Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6F73D6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 15:18:41 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id ey11so1633541pad.7
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 12:18:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qv8si2364363pbb.75.2014.10.23.12.18.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 12:18:40 -0700 (PDT)
Date: Thu, 23 Oct 2014 12:18:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: memblock: change default cnt for regions from 1 to 0
Message-Id: <20141023121840.f88439912f23a3c2a01eb54f@linux-foundation.org>
In-Reply-To: <1414083413-61756-1-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1414083413-61756-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>

(cc's added)

On Thu, 23 Oct 2014 17:56:53 +0100 Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com> wrote:

> The default region counts are set to 1 with a comment saying empty
> dummy entry.
> 
> If this is a dummy entry, should this be changed to 0?
> 
> We have faced this in mips/kernel/setup.c arch_mem_init.
> 
> cma uses memblock. But even with cma disabled.
> The for_each_memblock(reserved, reg) goes inside the loop.
> Even without any reserved regions.
> 
> Traced it to the following, when the macro
> for_each_memblock(memblock_type, region) is used.
> 
> It expands to add the cnt variable.
> 
> for (region = memblock.memblock_type.regions; 		\
> 	region < (memblock.memblock_type.regions + memblock.memblock_type.cnt); \
> 	region++)
> 
> In the corner case, that there are no reserved regions.
> Due to the default 1 value of cnt.
> The loop under for_each_memblock still runs once.
> 
> Even when there is no reserved region.
> 
> Is this by design? or unintentional?
> It might be that this loop runs an extra time every instance out there?
> ---
>  mm/memblock.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 6d2f219..b91301c 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -33,16 +33,16 @@ static struct memblock_region memblock_physmem_init_regions[INIT_PHYSMEM_REGIONS
>  
>  struct memblock memblock __initdata_memblock = {
>  	.memory.regions		= memblock_memory_init_regions,
> -	.memory.cnt		= 1,	/* empty dummy entry */
> +	.memory.cnt		= 0,	/* empty dummy entry */
>  	.memory.max		= INIT_MEMBLOCK_REGIONS,
>  
>  	.reserved.regions	= memblock_reserved_init_regions,
> -	.reserved.cnt		= 1,	/* empty dummy entry */
> +	.reserved.cnt		= 0,	/* empty dummy entry */
>  	.reserved.max		= INIT_MEMBLOCK_REGIONS,
>  
>  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
>  	.physmem.regions	= memblock_physmem_init_regions,
> -	.physmem.cnt		= 1,	/* empty dummy entry */
> +	.physmem.cnt		= 0,	/* empty dummy entry */
>  	.physmem.max		= INIT_PHYSMEM_REGIONS,
>  #endif
>  
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
