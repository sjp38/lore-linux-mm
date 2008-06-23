Date: Tue, 24 Jun 2008 00:08:09 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] hugetlb reservations: fix hugetlb MAP_PRIVATE reservations across vma splits V2
Message-ID: <20080623230809.GB4564@csn.ul.ie>
References: <1214242533-12104-1-git-send-email-apw@shadowen.org> <1214242533-12104-3-git-send-email-apw@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1214242533-12104-3-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (23/06/08 18:35), Andy Whitcroft didst pronounce:
> When a hugetlb mapping with a reservation is split, a new VMA is cloned
> from the original.  This new VMA is a direct copy of the original
> including the reservation count.  When this pair of VMAs are unmapped
> we will incorrect double account the unused reservation and the overall
> reservation count will be incorrect, in extreme cases it will wrap.
> 
> The problem occurs when we split an existing VMA say to unmap a page in
> the middle.  split_vma() will create a new VMA copying all fields from
> the original.  As we are storing our reservation count in vm_private_data
> this is also copies, endowing the new VMA with a duplicate of the original
> VMA's reservation.  Neither of the new VMAs can exhaust these reservations
> as they are too small, but when we unmap and close these VMAs we will
> incorrect credit the remainder twice and resv_huge_pages will become
> out of sync.  This can lead to allocation failures on mappings with
> reservations and even to resv_huge_pages wrapping which prevents all
> subsequent hugepage allocations.
> 
> The simple fix would be to correctly apportion the remaining reservation
> count when the split is made.  However the only hook we have vm_ops->open
> only has the new VMA we do not know the identity of the preceeding VMA.
> Also even if we did have that VMA to hand we do not know how much of the
> reservation was consumed each side of the split.
> 
> This patch therefore takes a different tack.  We know that the whole of any
> private mapping (which has a reservation) has a reservation over its whole
> size.  Any present pages represent consumed reservation.  Therefore if
> we track the instantiated pages we can calculate the remaining reservation.
> 
> This patch reuses the existing regions code to track the regions for which
> we have consumed reservation (ie. the instantiated pages), as each page
> is faulted in we record the consumption of reservation for the new page.
> When we need to return unused reservations at unmap time we simply count
> the consumed reservation region subtracting that from the whole of the map.
> During a VMA split the newly opened VMA will point to the same region map,
> as this map is offset oriented it remains valid for both of the split VMAs.
> This map is referenced counted so that it is removed when all VMAs which
> are part of the mmap are gone.
> 
> Thanks to Adam Litke and Mel Gorman for their review feedback.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Nice explanation. Testing on i386 with qemu, this patch allows some
small tests to pass without corruption of the rsvd counters.
libhugetlbfs tests also passed. I do not see anything new to complain
about in the code. Thanks.

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/hugetlb.c |  171 ++++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 144 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index d701e39..7ba6d4d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -49,6 +49,16 @@ static DEFINE_SPINLOCK(hugetlb_lock);
>  /*
>   * Region tracking -- allows tracking of reservations and instantiated pages
>   *                    across the pages in a mapping.
> + *
> + * The region data structures are protected by a combination of the mmap_sem
> + * and the hugetlb_instantion_mutex.  To access or modify a region the caller
> + * must either hold the mmap_sem for write, or the mmap_sem for read and
> + * the hugetlb_instantiation mutex:
> + *
> + * 	down_write(&mm->mmap_sem);
> + * or
> + * 	down_read(&mm->mmap_sem);
> + * 	mutex_lock(&hugetlb_instantiation_mutex);
>   */
>  struct file_region {
>  	struct list_head link;
> @@ -171,6 +181,30 @@ static long region_truncate(struct list_head *head, long end)
>  	return chg;
>  }
>  
> +static long region_count(struct list_head *head, long f, long t)
> +{
> +	struct file_region *rg;
> +	long chg = 0;
> +
> +	/* Locate each segment we overlap with, and count that overlap. */
> +	list_for_each_entry(rg, head, link) {
> +		int seg_from;
> +		int seg_to;
> +
> +		if (rg->to <= f)
> +			continue;
> +		if (rg->from >= t)
> +			break;
> +
> +		seg_from = max(rg->from, f);
> +		seg_to = min(rg->to, t);
> +
> +		chg += seg_to - seg_from;
> +	}
> +
> +	return chg;
> +}
> +
>  /*
>   * Convert the address within this vma to the page offset within
>   * the mapping, in base page units.
> @@ -193,9 +227,15 @@ static pgoff_t vma_pagecache_offset(struct hstate *h,
>  			(vma->vm_pgoff >> huge_page_order(h));
>  }
>  
> -#define HPAGE_RESV_OWNER    (1UL << (BITS_PER_LONG - 1))
> -#define HPAGE_RESV_UNMAPPED (1UL << (BITS_PER_LONG - 2))
> +/*
> + * Flags for MAP_PRIVATE reservations.  These are stored in the bottom
> + * bits of the reservation map pointer, which are always clear due to
> + * alignment.
> + */
> +#define HPAGE_RESV_OWNER    (1UL << 0)
> +#define HPAGE_RESV_UNMAPPED (1UL << 1)
>  #define HPAGE_RESV_MASK (HPAGE_RESV_OWNER | HPAGE_RESV_UNMAPPED)
> +
>  /*
>   * These helpers are used to track how many pages are reserved for
>   * faults in a MAP_PRIVATE mapping. Only the process that called mmap()
> @@ -205,6 +245,15 @@ static pgoff_t vma_pagecache_offset(struct hstate *h,
>   * the reserve counters are updated with the hugetlb_lock held. It is safe
>   * to reset the VMA at fork() time as it is not in use yet and there is no
>   * chance of the global counters getting corrupted as a result of the values.
> + *
> + * The private mapping reservation is represented in a subtly different
> + * manner to a shared mapping.  A shared mapping has a region map associated
> + * with the underlying file, this region map represents the backing file
> + * pages which have ever had a reservation assigned which this persists even
> + * after the page is instantiated.  A private mapping has a region map
> + * associated with the original mmap which is attached to all VMAs which
> + * reference it, this region map represents those offsets which have consumed
> + * reservation ie. where pages have been instantiated.
>   */
>  static unsigned long get_vma_private_data(struct vm_area_struct *vma)
>  {
> @@ -217,22 +266,48 @@ static void set_vma_private_data(struct vm_area_struct *vma,
>  	vma->vm_private_data = (void *)value;
>  }
>  
> -static unsigned long vma_resv_huge_pages(struct vm_area_struct *vma)
> +struct resv_map {
> +	struct kref refs;
> +	struct list_head regions;
> +};
> +
> +struct resv_map *resv_map_alloc(void)
> +{
> +	struct resv_map *resv_map = kmalloc(sizeof(*resv_map), GFP_KERNEL);
> +	if (!resv_map)
> +		return NULL;
> +
> +	kref_init(&resv_map->refs);
> +	INIT_LIST_HEAD(&resv_map->regions);
> +
> +	return resv_map;
> +}
> +
> +void resv_map_release(struct kref *ref)
> +{
> +	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
> +
> +	/* Clear out any active regions before we release the map. */
> +	region_truncate(&resv_map->regions, 0);
> +	kfree(resv_map);
> +}
> +
> +static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
>  	if (!(vma->vm_flags & VM_SHARED))
> -		return get_vma_private_data(vma) & ~HPAGE_RESV_MASK;
> +		return (struct resv_map *)(get_vma_private_data(vma) &
> +							~HPAGE_RESV_MASK);
>  	return 0;
>  }
>  
> -static void set_vma_resv_huge_pages(struct vm_area_struct *vma,
> -							unsigned long reserve)
> +static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
>  	VM_BUG_ON(vma->vm_flags & VM_SHARED);
>  
> -	set_vma_private_data(vma,
> -		(get_vma_private_data(vma) & HPAGE_RESV_MASK) | reserve);
> +	set_vma_private_data(vma, (get_vma_private_data(vma) &
> +				HPAGE_RESV_MASK) | (unsigned long)map);
>  }
>  
>  static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
> @@ -260,19 +335,12 @@ static void decrement_hugepage_resv_vma(struct hstate *h,
>  	if (vma->vm_flags & VM_SHARED) {
>  		/* Shared mappings always use reserves */
>  		h->resv_huge_pages--;
> -	} else {
> +	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
>  		/*
>  		 * Only the process that called mmap() has reserves for
>  		 * private mappings.
>  		 */
> -		if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> -			unsigned long flags, reserve;
> -			h->resv_huge_pages--;
> -			flags = (unsigned long)vma->vm_private_data &
> -							HPAGE_RESV_MASK;
> -			reserve = (unsigned long)vma->vm_private_data - 1;
> -			vma->vm_private_data = (void *)(reserve | flags);
> -		}
> +		h->resv_huge_pages--;
>  	}
>  }
>  
> @@ -289,7 +357,7 @@ static int vma_has_private_reserves(struct vm_area_struct *vma)
>  {
>  	if (vma->vm_flags & VM_SHARED)
>  		return 0;
> -	if (!vma_resv_huge_pages(vma))
> +	if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>  		return 0;
>  	return 1;
>  }
> @@ -794,12 +862,19 @@ static int vma_needs_reservation(struct hstate *h,
>  		return region_chg(&inode->i_mapping->private_list,
>  							idx, idx + 1);
>  
> -	} else {
> -		if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER))
> -			return 1;
> -	}
> +	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> +		return 1;
>  
> -	return 0;
> +	} else  {
> +		int err;
> +		pgoff_t idx = vma_pagecache_offset(h, vma, addr);
> +		struct resv_map *reservations = vma_resv_map(vma);
> +
> +		err = region_chg(&reservations->regions, idx, idx + 1);
> +		if (err < 0)
> +			return err;
> +		return 0;
> +	}
>  }
>  static void vma_commit_reservation(struct hstate *h,
>  			struct vm_area_struct *vma, unsigned long addr)
> @@ -810,6 +885,13 @@ static void vma_commit_reservation(struct hstate *h,
>  	if (vma->vm_flags & VM_SHARED) {
>  		pgoff_t idx = vma_pagecache_offset(h, vma, addr);
>  		region_add(&inode->i_mapping->private_list, idx, idx + 1);
> +
> +	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> +		pgoff_t idx = vma_pagecache_offset(h, vma, addr);
> +		struct resv_map *reservations = vma_resv_map(vma);
> +
> +		/* Mark this page used in the map. */
> +		region_add(&reservations->regions, idx, idx + 1);
>  	}
>  }
>  
> @@ -1456,13 +1538,42 @@ out:
>  	return ret;
>  }
>  
> +static void hugetlb_vm_op_open(struct vm_area_struct *vma)
> +{
> +	struct resv_map *reservations = vma_resv_map(vma);
> +
> +	/*
> +	 * This new VMA should share its siblings reservation map if present.
> +	 * The VMA will only ever have a valid reservation map pointer where
> +	 * it is being copied for another still existing VMA.  As that VMA
> +	 * has a reference to the reservation map it cannot dissappear until
> +	 * after this open call completes.  It is therefore safe to take a
> +	 * new reference here without additional locking.
> +	 */
> +	if (reservations)
> +		kref_get(&reservations->refs);
> +}
> +
>  static void hugetlb_vm_op_close(struct vm_area_struct *vma)
>  {
>  	struct hstate *h = hstate_vma(vma);
> -	unsigned long reserve = vma_resv_huge_pages(vma);
> +	struct resv_map *reservations = vma_resv_map(vma);
> +	unsigned long reserve;
> +	unsigned long start;
> +	unsigned long end;
>  
> -	if (reserve)
> -		hugetlb_acct_memory(h, -reserve);
> +	if (reservations) {
> +		start = vma_pagecache_offset(h, vma, vma->vm_start);
> +		end = vma_pagecache_offset(h, vma, vma->vm_end);
> +
> +		reserve = (end - start) -
> +			region_count(&reservations->regions, start, end);
> +
> +		kref_put(&reservations->refs, resv_map_release);
> +
> +		if (reserve)
> +			hugetlb_acct_memory(h, -reserve);
> +	}
>  }
>  
>  /*
> @@ -1479,6 +1590,7 @@ static int hugetlb_vm_op_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  
>  struct vm_operations_struct hugetlb_vm_ops = {
>  	.fault = hugetlb_vm_op_fault,
> +	.open = hugetlb_vm_op_open,
>  	.close = hugetlb_vm_op_close,
>  };
>  
> @@ -2037,8 +2149,13 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	if (!vma || vma->vm_flags & VM_SHARED)
>  		chg = region_chg(&inode->i_mapping->private_list, from, to);
>  	else {
> +		struct resv_map *resv_map = resv_map_alloc();
> +		if (!resv_map)
> +			return -ENOMEM;
> +
>  		chg = to - from;
> -		set_vma_resv_huge_pages(vma, chg);
> +
> +		set_vma_resv_map(vma, resv_map);
>  		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
>  	}
>  
> -- 
> 1.5.6.205.g7ca3a
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
