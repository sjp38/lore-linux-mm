Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5693C6B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:39:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x28so6228405wma.7
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 05:39:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t128si696011wma.277.2017.08.11.05.39.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 05:39:56 -0700 (PDT)
Date: Fri, 11 Aug 2017 14:39:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 07/15] mm: defining memblock_virt_alloc_try_nid_raw
Message-ID: <20170811123953.GI30811@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-8-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502138329-123460-8-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Mon 07-08-17 16:38:41, Pavel Tatashin wrote:
> A new variant of memblock_virt_alloc_* allocations:
> memblock_virt_alloc_try_nid_raw()
>     - Does not zero the allocated memory
>     - Does not panic if request cannot be satisfied

OK, this looks good but I would not introduce memblock_virt_alloc_raw
here because we do not have any users. Please move that to "mm: optimize
early system hash allocations" which actually uses the API. It would be
easier to review it that way.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>

other than that
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/bootmem.h | 27 +++++++++++++++++++++++++
>  mm/memblock.c           | 53 ++++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 73 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index e223d91b6439..ea30b3987282 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -160,6 +160,9 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
>  #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
>  
>  /* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
> +void *memblock_virt_alloc_try_nid_raw(phys_addr_t size, phys_addr_t align,
> +				      phys_addr_t min_addr,
> +				      phys_addr_t max_addr, int nid);
>  void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
>  		phys_addr_t align, phys_addr_t min_addr,
>  		phys_addr_t max_addr, int nid);
> @@ -176,6 +179,14 @@ static inline void * __init memblock_virt_alloc(
>  					    NUMA_NO_NODE);
>  }
>  
> +static inline void * __init memblock_virt_alloc_raw(
> +					phys_addr_t size,  phys_addr_t align)
> +{
> +	return memblock_virt_alloc_try_nid_raw(size, align, BOOTMEM_LOW_LIMIT,
> +					    BOOTMEM_ALLOC_ACCESSIBLE,
> +					    NUMA_NO_NODE);
> +}
> +
>  static inline void * __init memblock_virt_alloc_nopanic(
>  					phys_addr_t size, phys_addr_t align)
>  {
> @@ -257,6 +268,14 @@ static inline void * __init memblock_virt_alloc(
>  	return __alloc_bootmem(size, align, BOOTMEM_LOW_LIMIT);
>  }
>  
> +static inline void * __init memblock_virt_alloc_raw(
> +					phys_addr_t size,  phys_addr_t align)
> +{
> +	if (!align)
> +		align = SMP_CACHE_BYTES;
> +	return __alloc_bootmem_nopanic(size, align, BOOTMEM_LOW_LIMIT);
> +}
> +
>  static inline void * __init memblock_virt_alloc_nopanic(
>  					phys_addr_t size, phys_addr_t align)
>  {
> @@ -309,6 +328,14 @@ static inline void * __init memblock_virt_alloc_try_nid(phys_addr_t size,
>  					  min_addr);
>  }
>  
> +static inline void * __init memblock_virt_alloc_try_nid_raw(
> +			phys_addr_t size, phys_addr_t align,
> +			phys_addr_t min_addr, phys_addr_t max_addr, int nid)
> +{
> +	return ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size, align,
> +				min_addr, max_addr);
> +}
> +
>  static inline void * __init memblock_virt_alloc_try_nid_nopanic(
>  			phys_addr_t size, phys_addr_t align,
>  			phys_addr_t min_addr, phys_addr_t max_addr, int nid)
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 08f449acfdd1..3fbf3bcb52d9 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1327,7 +1327,6 @@ static void * __init memblock_virt_alloc_internal(
>  	return NULL;
>  done:
>  	ptr = phys_to_virt(alloc);
> -	memset(ptr, 0, size);
>  
>  	/*
>  	 * The min_count is set to 0 so that bootmem allocated blocks
> @@ -1340,6 +1339,38 @@ static void * __init memblock_virt_alloc_internal(
>  	return ptr;
>  }
>  
> +/**
> + * memblock_virt_alloc_try_nid_raw - allocate boot memory block without zeroing
> + * memory and without panicking
> + * @size: size of memory block to be allocated in bytes
> + * @align: alignment of the region and block's size
> + * @min_addr: the lower bound of the memory region from where the allocation
> + *	  is preferred (phys address)
> + * @max_addr: the upper bound of the memory region from where the allocation
> + *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
> + *	      allocate only from memory limited by memblock.current_limit value
> + * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
> + *
> + * Public function, provides additional debug information (including caller
> + * info), if enabled. Does not zero allocated memory, does not panic if request
> + * cannot be satisfied.
> + *
> + * RETURNS:
> + * Virtual address of allocated memory block on success, NULL on failure.
> + */
> +void * __init memblock_virt_alloc_try_nid_raw(
> +			phys_addr_t size, phys_addr_t align,
> +			phys_addr_t min_addr, phys_addr_t max_addr,
> +			int nid)
> +{
> +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
> +		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
> +		     (u64)max_addr, (void *)_RET_IP_);
> +
> +	return memblock_virt_alloc_internal(size, align,
> +					    min_addr, max_addr, nid);
> +}
> +
>  /**
>   * memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
>   * @size: size of memory block to be allocated in bytes
> @@ -1351,8 +1382,8 @@ static void * __init memblock_virt_alloc_internal(
>   *	      allocate only from memory limited by memblock.current_limit value
>   * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
>   *
> - * Public version of _memblock_virt_alloc_try_nid_nopanic() which provides
> - * additional debug information (including caller info), if enabled.
> + * Public function, provides additional debug information (including caller
> + * info), if enabled. This function zeroes the allocated memory.
>   *
>   * RETURNS:
>   * Virtual address of allocated memory block on success, NULL on failure.
> @@ -1362,11 +1393,17 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
>  				phys_addr_t min_addr, phys_addr_t max_addr,
>  				int nid)
>  {
> +	void *ptr;
> +
>  	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
>  		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
>  		     (u64)max_addr, (void *)_RET_IP_);
> -	return memblock_virt_alloc_internal(size, align, min_addr,
> -					     max_addr, nid);
> +
> +	ptr = memblock_virt_alloc_internal(size, align,
> +					   min_addr, max_addr, nid);
> +	if (ptr)
> +		memset(ptr, 0, size);
> +	return ptr;
>  }
>  
>  /**
> @@ -1380,7 +1417,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
>   *	      allocate only from memory limited by memblock.current_limit value
>   * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
>   *
> - * Public panicking version of _memblock_virt_alloc_try_nid_nopanic()
> + * Public panicking version of memblock_virt_alloc_try_nid_nopanic()
>   * which provides debug information (including caller info), if enabled,
>   * and panics if the request can not be satisfied.
>   *
> @@ -1399,8 +1436,10 @@ void * __init memblock_virt_alloc_try_nid(
>  		     (u64)max_addr, (void *)_RET_IP_);
>  	ptr = memblock_virt_alloc_internal(size, align,
>  					   min_addr, max_addr, nid);
> -	if (ptr)
> +	if (ptr) {
> +		memset(ptr, 0, size);
>  		return ptr;
> +	}
>  
>  	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx\n",
>  	      __func__, (u64)size, (u64)align, nid, (u64)min_addr,
> -- 
> 2.14.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
