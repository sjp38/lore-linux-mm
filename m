Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 723196B007D
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 17:26:23 -0400 (EDT)
Received: by dakp5 with SMTP id p5so11135793dak.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:26:22 -0700 (PDT)
Date: Tue, 19 Jun 2012 14:26:18 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Early boot panic on machine with lots of memory
Message-ID: <20120619212618.GK32733@google.com>
References: <1339623535.3321.4.camel@lappy>
 <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
 <1339667440.3321.7.camel@lappy>
 <20120618223203.GE32733@google.com>
 <1340059850.3416.3.camel@lappy>
 <20120619041154.GA28651@shangw>
 <20120619212059.GJ32733@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120619212059.GJ32733@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Jun 19, 2012 at 02:20:59PM -0700, Tejun Heo wrote:
> Something like the following should fix it.
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 32a0a5e..2770970 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -148,11 +148,15 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
>   */
>  int __init_memblock memblock_free_reserved_regions(void)
>  {
> +#ifndef CONFIG_DEBUG_PAGEALLOC
>  	if (memblock.reserved.regions == memblock_reserved_init_regions)
>  		return 0;
>  
>  	return memblock_free(__pa(memblock.reserved.regions),
>  		 sizeof(struct memblock_region) * memblock.reserved.max);
> +#else
> +	return 0;
> +#endif

BTW, this is just ugly and I don't think we're saving any noticeable
amount by doing this "free - give it to page allocator - reserve
again" dancing.  We should just allocate regions aligned to page
boundaries and free them later when memblock is no longer in use.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
