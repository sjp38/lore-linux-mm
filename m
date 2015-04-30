From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_pfns() helper
Date: Thu, 30 Apr 2015 16:55:31 +0100
Message-ID: <20150430155531.GY2449@suse.de>
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
 <1426593399-6549-3-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426593399-6549-3-git-send-email-jack@suse.cz>
Sender: linux-media-owner@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Cc: linux-media@vger.kernel.org, Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>
List-Id: linux-mm.kvack.org

On Tue, Mar 17, 2015 at 12:56:32PM +0100, Jan Kara wrote:
> Provide new function get_vaddr_pfns().  This function maps virtual
> addresses from given start and fills given array with page frame numbers of
> the corresponding pages. If given start belongs to a normal vma, the function
> grabs reference to each of the pages to pin them in memory. If start
> belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
> should make sure pfns aren't reused for anything else while he is using
> them.
> 
> This function is created for various drivers to simplify handling of
> their buffers.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/mm.h |  38 +++++++++++
>  mm/gup.c           | 180 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 218 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 47a93928b90f..a5045df92454 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1279,6 +1279,44 @@ long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  		    int write, int force, struct page **pages);
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			struct page **pages);
> +
> +/* Container for pinned pfns / pages */
> +struct pinned_pfns {
> +	unsigned int nr_allocated_pfns;	/* Number of pfns we have space for */
> +	unsigned int nr_pfns;		/* Number of pfns stored in pfns array */
> +	unsigned int got_ref:1;		/* Did we pin pfns by getting page ref? */
> +	unsigned int is_pages:1;	/* Does array contain pages or pfns? */

The bit field is probably overkill as I expect it'll get padded out for
pointer alignment anyway. Just use bools.

is_pfns is less ambiguous than is_pages but not very important.

The naming is not great in general. Only struct pages are pinned in the
traditional meaning of the word. The raw PFNs are not so there is no such
thing as a "pinned pfns". It might be better just to call it frame_vectors
and document that it's either raw PFNs that the caller should be responsible
for or struct pages that are pinned.

> +	void *ptrs[0];			/* Array of pinned pfns / pages.
> +					 * Use pfns_vector_pages() or
> +					 * pfns_vector_pfns() for access */
> +};
> +
> +struct pinned_pfns *pfns_vector_create(int nr_pfns);
> +void pfns_vector_destroy(struct pinned_pfns *pfns);
> +int get_vaddr_pfns(unsigned long start, int nr_pfns, int write, int force,
> +		   struct pinned_pfns *pfns);

It's not critical but I generally prefer to see bools for new APIs like
this.

unsigned int for nr_pfns.

> +void put_vaddr_pfns(struct pinned_pfns *pfns);
> +int pfns_vector_to_pages(struct pinned_pfns *pfns);
> +
> +static inline int pfns_vector_count(struct pinned_pfns *pfns)
> +{
> +	return pfns->nr_pfns;
> +}

should return unsigned int.

> +
> +static inline struct page **pfns_vector_pages(struct pinned_pfns *pfns)
> +{
> +	if (!pfns->is_pages)
> +		return NULL;
> +	return (struct page **)(pfns->ptrs);
> +}
> +
> +static inline unsigned long *pfns_vector_pfns(struct pinned_pfns *pfns)
> +{
> +	if (pfns->is_pages)
> +		return NULL;
> +	return (unsigned long *)(pfns->ptrs);
> +}
> +
>  struct kvec;
>  int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
>  			struct page **pages);
> diff --git a/mm/gup.c b/mm/gup.c
> index a6e24e246f86..63903913ab04 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -819,6 +819,186 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  EXPORT_SYMBOL(get_user_pages);
>  
>  /**
> + * get_vaddr_pfns() - map virtual addresses to pfns
> + * @start:	starting user address
> + * @nr_pfns:	number of pfns from start to map
> + * @write:	whether pages will be written to by the caller
> + * @force:	whether to force write access even if user mapping is
> + *		readonly. This will result in the page being COWed even
> + *		in MAP_SHARED mappings. You do not want this.
> + * @pfns:	structure which receives pfns of the pages mapped.
> + *		It should have space for at least nr_pfns pfns.
> + *
> + * This function maps virtual addresses from @start and fills @pfns structure
> + * with page frame numbers of corresponding pages. If @start belongs to a
> + * normal vma, the function grabs reference to each of the pages to pin them in
> + * memory. If @start belongs to VM_IO | VM_PFNMAP vma, we don't touch page
> + * structures. Caller should make sure pfns aren't reused for anything else
> + * while he is using them.
> + *
> + * This function takes care of grabbing mmap_sem as necessary.
> + */
> +int get_vaddr_pfns(unsigned long start, int nr_pfns, int write, int force,
> +		   struct pinned_pfns *pfns)
> +{
> +	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma;
> +	int ret = 0;
> +	int err;
> +
> +	if (nr_pfns <= 0)
> +		return 0;
> +

I know I suggested that nr_pfns should be unsigned earlier and then I
saw this. Is there any valid use of the API that would pass in a
negative number here?

> +	if (nr_pfns > pfns->nr_allocated_pfns)
> +		nr_pfns = pfns->nr_allocated_pfns;
> +

Should this be a WARN_ON_ONCE? You recover from it obviously but the return
value is not documented to say that it could return less than requested.
Of course, this is implied but a caller might assume it's due to a transient
error instead of broken API usage.

> +	down_read(&mm->mmap_sem);
> +	vma = find_vma_intersection(mm, start, start + 1);
> +	if (!vma) {
> +		ret = -EFAULT;
> +		goto out;
> +	}

Returning -EFAULT means that the return value has to be signed but the
structure itself has unsigned int for counters so the maximum number of
PFNs supported is not available. We'd never want that number of PFNs pinned
but still it might make sense to enforce the maximum possible size of the
structure that takes into account the values needed for returning errors.

> +	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
> +		pfns->got_ref = 1;
> +		pfns->is_pages = 1;
> +		ret = get_user_pages(current, mm, start, nr_pfns, write, force,
> +				     pfns_vector_pages(pfns), NULL);
> +		goto out;
> +	}
> +
> +	pfns->got_ref = 0;
> +	pfns->is_pages = 0;
> +	do {
> +		unsigned long *nums = pfns_vector_pfns(pfns);
> +
> +		while (ret < nr_pfns && start + PAGE_SIZE <= vma->vm_end) {
> +			err = follow_pfn(vma, start, &nums[ret]);
> +			if (err) {
> +				if (ret == 0)
> +					ret = err;
> +				goto out;
> +			}
> +			start += PAGE_SIZE;
> +			ret++;
> +		}
> +		/*
> +		 * We stop if we have enough pages or if VMA doesn't completely
> +		 * cover the tail page.
> +		 */
> +		if (ret >= nr_pfns || start < vma->vm_end)
> +			break;
> +		vma = find_vma_intersection(mm, start, start + 1);
> +	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));

Documentation probably should mention that a range that strides VMA types
will return partial results.

> +out:
> +	up_read(&mm->mmap_sem);
> +	if (!ret)
> +		ret = -EFAULT;

Really? Maybe we just failed to call get_user_pages on any of them. The
meaning of -EFAULT probably needs a comment.

> +	if (ret > 0)
> +		pfns->nr_pfns = ret;
> +	return ret;
> +}
> +EXPORT_SYMBOL(get_vaddr_pfns);
> +
> +/**
> + * put_vaddr_pfns() - drop references to pages if get_vaddr_pfns() acquired them
> + * @pfns:     structure with pfns we pinned
> + *
> + * Drop references to pages if get_vaddr_pfns() acquired them. We also
> + * invalidate the array of pfns so that it is prepared for the next call into
> + * get_vaddr_pfns().
> + */
> +void put_vaddr_pfns(struct pinned_pfns *pfns)
> +{
> +	int i;
> +
> +	if (!pfns->got_ref)
> +		goto out;
> +	if (pfns->is_pages) {
> +		struct page **pages = pfns_vector_pages(pfns);
> +
> +		for (i = 0; i < pfns->nr_pfns; i++)
> +			put_page(pages[i]);

Ok.

> +	} else {
> +		unsigned long *nums = pfns_vector_pfns(pfns);
> +
> +		for (i = 0; i < pfns->nr_pfns; i++)
> +			put_page(pfn_to_page(nums[i]));
> +	}

I'm missing something here. The !is_pages branch in get_vaddr_pfns()
used follow_pfn() and it does not take a reference on the struct page so
I'm not sure what this is putting exactly.

> +	pfns->got_ref = 0;
> +out:
> +	pfns->nr_pfns = 0;
> +}
> +EXPORT_SYMBOL(put_vaddr_pfns);
> +

EXPORT_SYMBOL_GPL?

> +/**
> + * pfns_vector_to_pages - convert vector of pfns to vector of page pointers
> + * @pfns:	structure with pinned pfns
> + *
> + * Convert @pfns to not contain array of pfns but array of page pointers.
> + * If the conversion is successful, return 0. Otherwise return an error.
> + */
> +int pfns_vector_to_pages(struct pinned_pfns *pfns)
> +{
> +	int i;
> +	unsigned long *nums;
> +	struct page **pages;
> +
> +	if (pfns->is_pages)
> +		return 0;
> +	nums = pfns_vector_pfns(pfns);
> +	for (i = 0; i < pfns->nr_pfns; i++)
> +		if (!pfn_valid(nums[i]))
> +			return -EINVAL;
> +	pages = (struct page **)nums;
> +	for (i = 0; i < pfns->nr_pfns; i++)
> +		pages[i] = pfn_to_page(nums[i]);
> +	pfns->is_pages = 1;
> +	return 0;
> +}
> +EXPORT_SYMBOL(pfns_vector_to_pages);
> +
> +/**
> + * pfns_vector_create() - allocate & initialize structure for pinned pfns
> + * @nr_pfns:	number of pfns slots we should reserve
> + *
> + * Allocate and initialize struct pinned_pfns to be able to hold @nr_pfns
> + * pfns.
> + */
> +struct pinned_pfns *pfns_vector_create(int nr_pfns)
> +{
> +	struct pinned_pfns *pfns;
> +	int size = sizeof(struct pinned_pfns) + sizeof(unsigned long) * nr_pfns;
> +

Should be sizeof(void *) 

> +	if (WARN_ON_ONCE(nr_pfns <= 0))
> +		return NULL;
> +	if (size <= PAGE_SIZE)
> +		pfns = kmalloc(size, GFP_KERNEL);

kmalloc supports larger sizes than this but I suspect this was
deliberate to avoid high-order allocations.

> +	else
> +		pfns = vmalloc(size);
> +	if (!pfns)
> +		return NULL;
> +	pfns->nr_allocated_pfns = nr_pfns;
> +	pfns->nr_pfns = 0;
> +	return pfns;
> +}
> +EXPORT_SYMBOL(pfns_vector_create);
> +
> +/**
> + * pfns_vector_destroy() - free memory allocated to carry pinned pfns
> + * @pfns:	Memory to free
> + *
> + * Free structure allocated by pfns_vector_create() to carry pinned pfns.
> + */
> +void pfns_vector_destroy(struct pinned_pfns *pfns)
> +{
> +	if (!is_vmalloc_addr(pfns))
> +		kfree(pfns);
> +	else
> +		vfree(pfns);
> +}
> +EXPORT_SYMBOL(pfns_vector_destroy);
> +
> +/**
>   * get_dump_page() - pin user page in memory while writing it to core dump
>   * @addr: user address
>   *
> -- 
> 2.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Mel Gorman
SUSE Labs
