Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D765E6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 06:45:58 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so6915743wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 03:45:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si1557084wix.78.2015.05.06.03.45.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 03:45:57 -0700 (PDT)
Message-ID: <5549F0DF.4030205@suse.cz>
Date: Wed, 06 May 2015 12:45:51 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
References: <1430897296-5469-1-git-send-email-jack@suse.cz> <1430897296-5469-3-git-send-email-jack@suse.cz>
In-Reply-To: <1430897296-5469-3-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On 05/06/2015 09:28 AM, Jan Kara wrote:
> Provide new function get_vaddr_frames().  This function maps virtual
> addresses from given start and fills given array with page frame numbers of
> the corresponding pages. If given start belongs to a normal vma, the function
> grabs reference to each of the pages to pin them in memory. If start
> belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
> must make sure pfns aren't reused for anything else while he is using
> them.
>
> This function is created for various drivers to simplify handling of
> their buffers.
>
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

With some nitpicks below...

> ---
>   include/linux/mm.h |  44 +++++++++++
>   mm/gup.c           | 214 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 258 insertions(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0755b9fd03a7..dcd1f02a78e9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -20,6 +20,7 @@
>   #include <linux/shrinker.h>
>   #include <linux/resource.h>
>   #include <linux/page_ext.h>
> +#include <linux/err.h>
>
>   struct mempolicy;
>   struct anon_vma;
> @@ -1197,6 +1198,49 @@ long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>   		    int write, int force, struct page **pages);
>   int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>   			struct page **pages);
> +
> +/* Container for pinned pfns / pages */
> +struct frame_vector {
> +	unsigned int nr_allocated;	/* Number of frames we have space for */
> +	unsigned int nr_frames;	/* Number of frames stored in ptrs array */
> +	bool got_ref;		/* Did we pin pages by getting page ref? */
> +	bool is_pfns;		/* Does array contain pages or pfns? */
> +	void *ptrs[0];		/* Array of pinned pfns / pages. Use
> +				 * pfns_vector_pages() or pfns_vector_pfns()
> +				 * for access */
> +};
> +
> +struct frame_vector *frame_vector_create(unsigned int nr_frames);
> +void frame_vector_destroy(struct frame_vector *vec);
> +int get_vaddr_frames(unsigned long start, unsigned int nr_pfns,
> +		     bool write, bool force, struct frame_vector *vec);
> +void put_vaddr_frames(struct frame_vector *vec);
> +int frame_vector_to_pages(struct frame_vector *vec);
> +void frame_vector_to_pfns(struct frame_vector *vec);
> +
> +static inline unsigned int frame_vector_count(struct frame_vector *vec)
> +{
> +	return vec->nr_frames;
> +}
> +
> +static inline struct page **frame_vector_pages(struct frame_vector *vec)
> +{
> +	if (vec->is_pfns) {
> +		int err = frame_vector_to_pages(vec);
> +
> +		if (err)
> +			return ERR_PTR(err);
> +	}
> +	return (struct page **)(vec->ptrs);
> +}
> +
> +static inline unsigned long *frame_vector_pfns(struct frame_vector *vec)
> +{
> +	if (!vec->is_pfns)
> +		frame_vector_to_pfns(vec);
> +	return (unsigned long *)(vec->ptrs);
> +}
> +
>   struct kvec;
>   int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
>   			struct page **pages);
> diff --git a/mm/gup.c b/mm/gup.c
> index 6297f6bccfb1..8db5c40e65c4 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -8,6 +8,7 @@
>   #include <linux/rmap.h>
>   #include <linux/swap.h>
>   #include <linux/swapops.h>
> +#include <linux/vmalloc.h>
>
>   #include <linux/sched.h>
>   #include <linux/rwsem.h>
> @@ -936,6 +937,219 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
>   	return ret;	/* 0 or negative error code */
>   }
>
> +/*
> + * get_vaddr_frames() - map virtual addresses to pfns
> + * @start:	starting user address
> + * @nr_frames:	number of pages / pfns from start to map
> + * @write:	whether pages will be written to by the caller
> + * @force:	whether to force write access even if user mapping is
> + *		readonly. This will result in the page being COWed even
> + *		in MAP_SHARED mappings. You do not want this.

"You do not want this" and yet some of the drivers in later patches do. 
That looks weird. Explain better?

> + * @vec:	structure which receives pages / pfns of the addresses mapped.
> + *		It should have space for at least nr_frames entries.
> + *
> + * This function maps virtual addresses from @start and fills @vec structure
> + * with page frame numbers or page pointers to corresponding pages (choice
> + * depends on the type of the vma underlying the virtual address). If @start
> + * belongs to a normal vma, the function grabs reference to each of the pages
> + * to pin them in memory. If @start belongs to VM_IO | VM_PFNMAP vma, we don't
> + * touch page structures and the caller must make sure pfns aren't reused for
> + * anything else while he is using them.
> + *
> + * The function returns number of pages mapped which may be less than
> + * @nr_frames. In particular we stop mapping if there are more vmas of
> + * different type underlying the specified range of virtual addresses.

The function can also return e.g. -EFAULT, shouldn't that be documented too?

> + *
> + * This function takes care of grabbing mmap_sem as necessary.
> + */
> +int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
> +		     bool write, bool force, struct frame_vector *vec)
> +{
> +	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma;
> +	int ret = 0;
> +	int err;
> +	int locked = 1;

It looks strange that locked is set to 1 before taking the actual 
mmap_sem. Also future-proofing.

> +
> +	if (nr_frames == 0)
> +		return 0;
> +
> +	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
> +		nr_frames = vec->nr_allocated;
> +
> +	down_read(&mm->mmap_sem);
> +	vma = find_vma_intersection(mm, start, start + 1);
> +	if (!vma) {
> +		ret = -EFAULT;
> +		goto out;
> +	}
> +	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
> +		vec->got_ref = 1;
> +		vec->is_pfns = 0;
> +		ret = get_user_pages_locked(current, mm, start, nr_frames,
> +			write, force, (struct page **)(vec->ptrs), &locked);
> +		goto out;
> +	}
> +
> +	vec->got_ref = 0;
> +	vec->is_pfns = 1;
> +	do {
> +		unsigned long *nums = frame_vector_pfns(vec);
> +
> +		while (ret < nr_frames && start + PAGE_SIZE <= vma->vm_end) {
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
> +		if (ret >= nr_frames || start < vma->vm_end)
> +			break;
> +		vma = find_vma_intersection(mm, start, start + 1);
> +	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
> +out:
> +	if (locked)
> +		up_read(&mm->mmap_sem);
> +	if (!ret)
> +		ret = -EFAULT;
> +	if (ret > 0)
> +		vec->nr_frames = ret;
> +	return ret;
> +}
> +EXPORT_SYMBOL(get_vaddr_frames);
> +
> +/**
> + * put_vaddr_frames() - drop references to pages if get_vaddr_frames() acquired
> + *			them
> + * @vec:	frame vector to put
> + *
> + * Drop references to pages if get_vaddr_frames() acquired them. We also
> + * invalidate the frame vector so that it is prepared for the next call into
> + * get_vaddr_frames().
> + */
> +void put_vaddr_frames(struct frame_vector *vec)
> +{
> +	int i;
> +	struct page **pages;
> +
> +	if (!vec->got_ref)
> +		goto out;
> +	pages = frame_vector_pages(vec);
> +	/*
> +	 * frame_vector_pages() might needed to do a conversion when we

                                                           remove "we" ^

> +	 * get_vaddr_frames() got pages but vec was later converted to pfns.
> +	 * But it shouldn't really fail to convert pfns back...
> +	 */
> +	BUG_ON(IS_ERR(pages));
> +	for (i = 0; i < vec->nr_frames; i++)
> +		put_page(pages[i]);
> +	vec->got_ref = 0;
> +out:
> +	vec->nr_frames = 0;
> +}
> +EXPORT_SYMBOL(put_vaddr_frames);
> +
> +/**
> + * frame_vector_to_pages - convert frame vector to contain page pointers
> + * @vec:	frame vector to convert
> + *
> + * Convert @vec to contain array of page pointers.  If the conversion is
> + * successful, return 0. Otherwise return an error.
> + */
> +int frame_vector_to_pages(struct frame_vector *vec)
> +{
> +	int i;
> +	unsigned long *nums;
> +	struct page **pages;
> +
> +	if (!vec->is_pfns)
> +		return 0;
> +	nums = frame_vector_pfns(vec);
> +	for (i = 0; i < vec->nr_frames; i++)
> +		if (!pfn_valid(nums[i]))
> +			return -EINVAL;
> +	pages = (struct page **)nums;
> +	for (i = 0; i < vec->nr_frames; i++)
> +		pages[i] = pfn_to_page(nums[i]);
> +	vec->is_pfns = 0;
> +	return 0;
> +}
> +EXPORT_SYMBOL(frame_vector_to_pages);
> +
> +/**
> + * frame_vector_to_pfns - convert frame vector to contain pfns
> + * @vec:	frame vector to convert
> + *
> + * Convert @vec to contain array of pfns.
> + */
> +void frame_vector_to_pfns(struct frame_vector *vec)
> +{
> +	int i;
> +	unsigned long *nums;
> +	struct page **pages;
> +
> +	if (vec->is_pfns)
> +		return;
> +	pages = (struct page **)(vec->ptrs);
> +	nums = (unsigned long *)pages;
> +	for (i = 0; i < vec->nr_frames; i++)
> +		nums[i] = page_to_pfn(pages[i]);
> +	vec->is_pfns = 1;
> +}
> +EXPORT_SYMBOL(frame_vector_to_pfns);
> +
> +/**
> + * frame_vector_create() - allocate & initialize structure for pinned pfns
> + * @nr_frames:	number of pfns slots we should reserve
> + *
> + * Allocate and initialize struct pinned_pfns to be able to hold @nr_pfns
> + * pfns.
> + */
> +struct frame_vector *frame_vector_create(unsigned int nr_frames)
> +{
> +	struct frame_vector *vec;
> +	int size = sizeof(struct frame_vector) + sizeof(void *) * nr_frames;
> +
> +	if (WARN_ON_ONCE(nr_frames == 0))
> +		return NULL;
> +	/*
> +	 * Avoid higher order allocations, use vmalloc instead. It should
> +	 * be rare anyway.
> +	 */
> +	if (size <= PAGE_SIZE)
> +		vec = kmalloc(size, GFP_KERNEL);
> +	else
> +		vec = vmalloc(size);
> +	if (!vec)
> +		return NULL;
> +	vec->nr_allocated = nr_frames;
> +	vec->nr_frames = 0;
> +	return vec;
> +}
> +EXPORT_SYMBOL(frame_vector_create);
> +
> +/**
> + * frame_vector_destroy() - free memory allocated to carry frame vector
> + * @vec:	Frame vector to free
> + *
> + * Free structure allocated by frame_vector_create() to carry frames.
> + */
> +void frame_vector_destroy(struct frame_vector *vec)
> +{

Add some VM_BUG_ON()'s for nr_frames and got_ref perhaps?

> +	if (!is_vmalloc_addr(vec))
> +		kfree(vec);
> +	else
> +		vfree(vec);
> +}
> +EXPORT_SYMBOL(frame_vector_destroy);
> +
>   /**
>    * get_dump_page() - pin user page in memory while writing it to core dump
>    * @addr: user address
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
