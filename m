Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 416676B025E
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 06:19:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x23so196619539pgx.6
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 03:19:20 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o69si2879834pfg.230.2016.11.17.03.19.19
        for <linux-mm@kvack.org>;
        Thu, 17 Nov 2016 03:19:19 -0800 (PST)
Date: Thu, 17 Nov 2016 11:19:18 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v27 1/9] memblock: add memblock_cap_memory_range()
Message-ID: <20161117111917.GA22855@arm.com>
References: <20161102044959.11954-1-takahiro.akashi@linaro.org>
 <20161102045153.12008-1-takahiro.akashi@linaro.org>
 <20161110172720.GB17134@arm.com>
 <20161111025049.GG381@linaro.org>
 <20161111031903.GB15997@arm.com>
 <20161114055515.GH381@linaro.org>
 <20161116163015.GM7928@arm.com>
 <20161117022023.GA5704@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161117022023.GA5704@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: AKASHI Takahiro <takahiro.akashi@linaro.org>, Dennis Chen <dennis.chen@arm.com>, catalin.marinas@arm.com, akpm@linux-foundation.org, james.morse@arm.com, geoff@infradead.org, bauerman@linux.vnet.ibm.com, dyoung@redhat.com, mark.rutland@arm.com, kexec@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.orgnd@arm.com

Hi Akashi,

On Thu, Nov 17, 2016 at 02:34:24PM +0900, AKASHI Takahiro wrote:
> On Wed, Nov 16, 2016 at 04:30:15PM +0000, Will Deacon wrote:
> > I thought limit was just a physical address, and then
> 
> No, it's not.

Quite right, it's a size. Sorry about that.

> > memblock_mem_limit_remove_map operated on the end of the nearest memblock?
> 
> No, but "max_addr" returned by __find_max_addr() is a physical address
> and the end address of memory of "limit" size in total.
> 
> > You could leave the __find_max_addr call in memblock_mem_limit_remove_map,
> > given that I don't think you need/want it for memblock_cap_memory_range.
> > 
> > > So I added an extra argument, exact, to a common function to specify
> > > distinct behaviors. Confusing? Please see the patch below.
> > 
> > Oh yikes, this certainly wasn't what I had in mind! My observation was
> > just that memblock_mem_limit_remove_map(limit) does:
> > 
> > 
> >   1. memblock_isolate_range(limit - limit+ULLONG_MAX)
> >   2. memblock_remove_region(all non-nomap regions in the isolated region)
> >   3. truncate reserved regions to limit
> > 
> > and your memblock_cap_memory_range(base, size) does:
> > 
> >   1. memblock_isolate_range(base - base+size)
> >   2, memblock_remove_region(all non-nomap regions above and below the
> >      isolated region)
> >   3. truncate reserved regions around the isolated region
> > 
> > so, assuming we can invert the isolation in one of the cases, then they
> > could share the same underlying implementation.
> 
> Please see my simplified patch below which would explain what I meant.
> (Note that the size is calculated by 'max_addr - 0'.)
> 
> > I'm probably just missing something here, because the patch you've ended
> > up with is far more involved than I anticipated...
> 
> I hope that it will meet almost your anticipation.

It looks much better, thanks! Just one question below.

> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7608bc3..fea1688 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1514,11 +1514,37 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  			      (phys_addr_t)ULLONG_MAX);
>  }
>  
> +void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> +{
> +	int start_rgn, end_rgn;
> +	int i, ret;
> +
> +	if (!size)
> +		return;
> +
> +	ret = memblock_isolate_range(&memblock.memory, base, size,
> +						&start_rgn, &end_rgn);
> +	if (ret)
> +		return;
> +
> +	/* remove all the MAP regions */
> +	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +			memblock_remove_region(&memblock.memory, i);

In the case that we have only one, giant memblock that covers base all
of base + size, can't we end up with start_rgn = end_rgn = 0? In which
case, we'd end up accidentally removing the map regions here.

The existing code:

> -	/* remove all the MAP regions above the limit */
> -	for (i = end_rgn - 1; i >= start_rgn; i--) {
> -		if (!memblock_is_nomap(&type->regions[i]))
> -			memblock_remove_region(type, i);
> -	}

seems to handle this.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
