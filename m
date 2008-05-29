Date: Wed, 28 May 2008 18:42:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] Guarantee that COW faults for a process that called
 mmap(MAP_PRIVATE) on hugetlbfs will succeed
Message-Id: <20080528184246.4753a78b.akpm@linux-foundation.org>
In-Reply-To: <20080527185128.16194.87380.sendpatchset@skynet.skynet.ie>
References: <20080527185028.16194.57978.sendpatchset@skynet.skynet.ie>
	<20080527185128.16194.87380.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, apw@shadowen.org, linux-mm@kvack.org, andi@firstfloor.org, kenchen@google.com, agl@us.ibm.com, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Tue, 27 May 2008 19:51:28 +0100 (IST) Mel Gorman <mel@csn.ul.ie> wrote:

> 
> After patch 2 in this series, a process that successfully calls mmap()
> for a MAP_PRIVATE mapping will be guaranteed to successfully fault until a
> process calls fork().  At that point, the next write fault from the parent
> could fail due to COW if the child still has a reference.
> 
> We only reserve pages for the parent but a copy must be made to avoid leaking
> data from the parent to the child after fork(). Reserves could be taken for
> both parent and child at fork time to guarantee faults but if the mapping
> is large it is highly likely we will not have sufficient pages for the
> reservation, and it is common to fork only to exec() immediatly after. A
> failure here would be very undesirable.
> 
> Note that the current behaviour of mainline with MAP_PRIVATE pages is
> pretty bad.  The following situation is allowed to occur today.
> 
> 1. Process calls mmap(MAP_PRIVATE)
> 2. Process calls mlock() to fault all pages and makes sure it succeeds
> 3. Process forks()
> 4. Process writes to MAP_PRIVATE mapping while child still exists
> 5. If the COW fails at this point, the process gets SIGKILLed even though it
>    had taken care to ensure the pages existed
> 
> This patch improves the situation by guaranteeing the reliability of the
> process that successfully calls mmap(). When the parent performs COW, it
> will try to satisfy the allocation without using reserves. If that fails the
> parent will steal the page leaving any children without a page. Faults from
> the child after that point will result in failure. If the child COW happens
> first, an attempt will be made to allocate the page without reserves and
> the child will get SIGKILLed on failure.
> 
> To summarise the new behaviour:
> 
> 1. If the original mapper performs COW on a private mapping with multiple
>    references, it will attempt to allocate a hugepage from the pool or
>    the buddy allocator without using the existing reserves. On fail, VMAs
>    mapping the same area are traversed and the page being COW'd is unmapped
>    where found. It will then steal the original page as the last mapper in
>    the normal way.
> 
> 2. The VMAs the pages were unmapped from are flagged to note that pages
>    with data no longer exist. Future no-page faults on those VMAs will
>    terminate the process as otherwise it would appear that data was corrupted.
>    A warning is printed to the console that this situation occured.
> 
> 2. If the child performs COW first, it will attempt to satisfy the COW
>    from the pool if there are enough pages or via the buddy allocator if
>    overcommit is allowed and the buddy allocator can satisfy the request. If
>    it fails, the child will be killed.
> 
> If the pool is large enough, existing applications will not notice that the
> reserves were a factor. Existing applications depending on the no-reserves
> been set are unlikely to exist as for much of the history of hugetlbfs,
> pages were prefaulted at mmap(), allocating the pages at that point or failing
> the mmap().
> 

Implementation nitlets:

> +#define HPAGE_RESV_OWNER    (1UL << (BITS_PER_LONG - 1))
> +#define HPAGE_RESV_UNMAPPED (1UL << (BITS_PER_LONG - 2))
> +#define HPAGE_RESV_MASK (HPAGE_RESV_OWNER | HPAGE_RESV_UNMAPPED)
>  /*
>   * These helpers are used to track how many pages are reserved for
>   * faults in a MAP_PRIVATE mapping. Only the process that called mmap()
> @@ -54,17 +57,32 @@ static unsigned long vma_resv_huge_pages
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
>  	if (!(vma->vm_flags & VM_SHARED))
> -		return (unsigned long)vma->vm_private_data;
> +		return (unsigned long)vma->vm_private_data & ~HPAGE_RESV_MASK;
>  	return 0;
>  }

It might be better to have

unsigned long get_vma_private_data(struct vm_area_struct);
unsigned long set_vma_private_data(struct vm_area_struct);

(or even get_private & set_private)

to do away with all the funky casting.

Or it might not be, too.

> +	pgoff_t pgoff = ((address - vma->vm_start) >> HPAGE_SHIFT)
> +		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
>
> ...
>
> +	unsigned long idx;
> +
> +	mapping = vma->vm_file->f_mapping;
> +	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
> +		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));

It would be clearer to have a little helper function for the above two
snippets.

And the first uses pgoff_t whereas the second uses bare ulong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
