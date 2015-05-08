Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id BF1316B0032
	for <linux-mm@kvack.org>; Fri,  8 May 2015 10:49:29 -0400 (EDT)
Received: by widdi4 with SMTP id di4so32675973wid.0
        for <linux-mm@kvack.org>; Fri, 08 May 2015 07:49:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ar3si8921385wjc.106.2015.05.08.07.49.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 08 May 2015 07:49:27 -0700 (PDT)
Date: Fri, 8 May 2015 15:49:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-ID: <20150508144922.GO2462@suse.de>
References: <1430897296-5469-1-git-send-email-jack@suse.cz>
 <1430897296-5469-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1430897296-5469-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On Wed, May 06, 2015 at 09:28:09AM +0200, Jan Kara wrote:
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

Trivial comments only;

> ---
>  include/linux/mm.h |  44 +++++++++++
>  mm/gup.c           | 214 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 258 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0755b9fd03a7..dcd1f02a78e9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -20,6 +20,7 @@
>  #include <linux/shrinker.h>
>  #include <linux/resource.h>
>  #include <linux/page_ext.h>
> +#include <linux/err.h>
>  
>  struct mempolicy;
>  struct anon_vma;
> @@ -1197,6 +1198,49 @@ long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  		    int write, int force, struct page **pages);
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			struct page **pages);
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
>  struct kvec;
>  int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
>  			struct page **pages);
> diff --git a/mm/gup.c b/mm/gup.c
> index 6297f6bccfb1..8db5c40e65c4 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -8,6 +8,7 @@
>  #include <linux/rmap.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
> +#include <linux/vmalloc.h>
>  
>  #include <linux/sched.h>
>  #include <linux/rwsem.h>
> @@ -936,6 +937,219 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
>  	return ret;	/* 0 or negative error code */
>  }
>  
> +/*
> + * get_vaddr_frames() - map virtual addresses to pfns
> + * @start:	starting user address
> + * @nr_frames:	number of pages / pfns from start to map
> + * @write:	whether pages will be written to by the caller
> + * @force:	whether to force write access even if user mapping is
> + *		readonly. This will result in the page being COWed even
> + *		in MAP_SHARED mappings. You do not want this.

If they don't want it, why does it exist?

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
> +

bool locked.

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

They're bools and while correct, it looks weird. There are a few
instances of this but I won't comment on it again.

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
> +	 * get_vaddr_frames() got pages but vec was later converted to pfns.
> +	 * But it shouldn't really fail to convert pfns back...
> +	 */
> +	BUG_ON(IS_ERR(pages));

It's hard to see how it could but it is recoverable so BUG_ON is
overkill. WARN_ON and return even though we potentially leaked now.

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

If you do another version, it would not hurt to mention that a page
reference is not taken when doing this conversion.

> +int frame_vector_to_pages(struct frame_vector *vec)
> +{

I think it's probably best to make the relevant counters in frame_vector
signed and limit the maximum possible size of it. It's still not putting
any practical limit on the size of the frame_vector.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
