Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C687D6B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 07:38:55 -0400 (EDT)
Date: Wed, 8 Jul 2009 13:46:26 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 2/3] kmemleak: Add callbacks to the bootmem allocator
Message-ID: <20090708114626.GA6151@cmpxchg.org>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com> <20090706105155.16051.59597.stgit@pc1117.cambridge.arm.com> <1246950530.24285.7.camel@penberg-laptop> <20090707165350.GA2782@cmpxchg.org> <1247004586.5710.16.camel@pc1117.cambridge.arm.com> <1247035701.15919.35.camel@penberg-laptop> <1247046231.6595.14.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247046231.6595.14.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 10:43:51AM +0100, Catalin Marinas wrote:

> kmemleak: Add callbacks to the bootmem allocator
> 
> From: Catalin Marinas <catalin.marinas@arm.com>
> 
> This patch adds kmemleak_alloc/free callbacks to the bootmem allocator.
> This would allow scanning of such blocks and help avoiding a whole class
> of false positives and more kmemleak annotations.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

> ---
>  mm/bootmem.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index d2a9ce9..90f3ed0 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -335,6 +335,8 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
>  {
>  	unsigned long start, end;
>  
> +	kmemleak_free_part(__va(physaddr), size);
> +
>  	start = PFN_UP(physaddr);
>  	end = PFN_DOWN(physaddr + size);
>  
> @@ -354,6 +356,8 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
>  {
>  	unsigned long start, end;
>  
> +	kmemleak_free_part(__va(addr), size);
> +
>  	start = PFN_UP(addr);
>  	end = PFN_DOWN(addr + size);
>  
> @@ -516,6 +520,7 @@ find_block:
>  		region = phys_to_virt(PFN_PHYS(bdata->node_min_pfn) +
>  				start_off);
>  		memset(region, 0, size);
> +		kmemleak_alloc(region, size, 1, 0);
>  		return region;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
