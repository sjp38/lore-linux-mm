Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0E3686B00F8
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:17:32 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3303833pbb.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 13:17:32 -0700 (PDT)
Date: Thu, 21 Jun 2012 13:17:28 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Early boot panic on machine with lots of memory
Message-ID: <20120621201728.GB4642@google.com>
References: <1339623535.3321.4.camel@lappy>
 <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
 <1339667440.3321.7.camel@lappy>
 <20120618223203.GE32733@google.com>
 <1340059850.3416.3.camel@lappy>
 <20120619041154.GA28651@shangw>
 <20120619212059.GJ32733@google.com>
 <20120619212618.GK32733@google.com>
 <CAE9FiQVECyRBie-kgBETmqxPaMx24kUt1W07qAqoGD4vNus5xQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQVECyRBie-kgBETmqxPaMx24kUt1W07qAqoGD4vNus5xQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello, Yinghai.

On Tue, Jun 19, 2012 at 07:57:45PM -0700, Yinghai Lu wrote:
> if it is that case, that change could fix other problem problem too.
> --- during the one free reserved.regions could double the array.

Yeah, that sounds much more attractive to me too.  Some comments on
the patch tho.

>  /**
>   * memblock_double_array - double the size of the memblock regions array
>   * @type: memblock type of the regions array being doubled
> @@ -216,7 +204,7 @@ static int __init_memblock memblock_doub
>  
>  	/* Calculate new doubled size */
>  	old_size = type->max * sizeof(struct memblock_region);
> -	new_size = old_size << 1;
> +	new_size = PAGE_ALIGN(old_size << 1);

We definintely can use some comments explaining why we want page
alignment.  It's kinda subtle.

This is a bit confusing here because old_size is the proper size
without padding while new_size is page aligned size with possible
padding.  Maybe discerning {old|new}_alloc_size is clearer?  Also, I
think adding @new_cnt variable which is calculated together would make
the code easier to follow.  So, sth like,

	/* explain why page aligning is necessary */
	old_size = type->max * sizeof(struct memblock_region);
	old_alloc_size = PAGE_ALIGN(old_size);

	new_max = type->max << 1;
	new_size = new_max * sizeof(struct memblock_region);
	new_alloc_size = PAGE_ALIGN(new_size);

and use alloc_sizes for alloc/frees and sizes for everything else.

>  unsigned long __init free_low_memory_core_early(int nodeid)
>  {
>  	unsigned long count = 0;
> -	phys_addr_t start, end;
> +	phys_addr_t start, end, size;
>  	u64 i;
>  
> -	/* free reserved array temporarily so that it's treated as free area */
> -	memblock_free_reserved_regions();
> +	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
> +		count += __free_memory_core(start, end);
>  
> -	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL) {
> -		unsigned long start_pfn = PFN_UP(start);
> -		unsigned long end_pfn = min_t(unsigned long,
> -					      PFN_DOWN(end), max_low_pfn);
> -		if (start_pfn < end_pfn) {
> -			__free_pages_memory(start_pfn, end_pfn);
> -			count += end_pfn - start_pfn;
> -		}
> -	}
> +	/* free range that is used for reserved array if we allocate it */
> +	size = get_allocated_memblock_reserved_regions_info(&start);
> +	if (size)
> +		count += __free_memory_core(start, start + size);

I'm afraid this is too early.  We don't want the region to be unmapped
yet.  This should only happen after all memblock usages are finished
which I don't think is the case yet.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
