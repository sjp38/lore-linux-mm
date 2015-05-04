Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9EDC46B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 11:14:05 -0400 (EDT)
Received: by widdi4 with SMTP id di4so125338516wid.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 08:14:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ho2si23145169wjb.162.2015.05.04.08.14.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 May 2015 08:14:03 -0700 (PDT)
Date: Mon, 4 May 2015 17:14:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_pfns() helper
Message-ID: <20150504151401.GC5805@quack.suse.cz>
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
 <1426593399-6549-3-git-send-email-jack@suse.cz>
 <20150430155531.GY2449@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150430155531.GY2449@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-media@vger.kernel.org, Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>

On Thu 30-04-15 16:55:31, Mel Gorman wrote:
> On Tue, Mar 17, 2015 at 12:56:32PM +0100, Jan Kara wrote:
> > Provide new function get_vaddr_pfns().  This function maps virtual
> > addresses from given start and fills given array with page frame numbers of
> > the corresponding pages. If given start belongs to a normal vma, the function
> > grabs reference to each of the pages to pin them in memory. If start
> > belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
> > should make sure pfns aren't reused for anything else while he is using
> > them.
> > 
> > This function is created for various drivers to simplify handling of
> > their buffers.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  include/linux/mm.h |  38 +++++++++++
> >  mm/gup.c           | 180 +++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 218 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 47a93928b90f..a5045df92454 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1279,6 +1279,44 @@ long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> >  		    int write, int force, struct page **pages);
> >  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >  			struct page **pages);
> > +
> > +/* Container for pinned pfns / pages */
> > +struct pinned_pfns {
> > +	unsigned int nr_allocated_pfns;	/* Number of pfns we have space for */
> > +	unsigned int nr_pfns;		/* Number of pfns stored in pfns array */
> > +	unsigned int got_ref:1;		/* Did we pin pfns by getting page ref? */
> > +	unsigned int is_pages:1;	/* Does array contain pages or pfns? */
> 
> The bit field is probably overkill as I expect it'll get padded out for
> pointer alignment anyway. Just use bools.
  Makes sense.

> is_pfns is less ambiguous than is_pages but not very important.
> 
> The naming is not great in general. Only struct pages are pinned in the
> traditional meaning of the word. The raw PFNs are not so there is no such
> thing as a "pinned pfns". It might be better just to call it frame_vectors
> and document that it's either raw PFNs that the caller should be responsible
> for or struct pages that are pinned.
  Good point. I'll try to come up with a better name.

<snip> - I agree with minor comments there.

> >  /**
> > + * get_vaddr_pfns() - map virtual addresses to pfns
> > + * @start:	starting user address
> > + * @nr_pfns:	number of pfns from start to map
> > + * @write:	whether pages will be written to by the caller
> > + * @force:	whether to force write access even if user mapping is
> > + *		readonly. This will result in the page being COWed even
> > + *		in MAP_SHARED mappings. You do not want this.
> > + * @pfns:	structure which receives pfns of the pages mapped.
> > + *		It should have space for at least nr_pfns pfns.
> > + *
> > + * This function maps virtual addresses from @start and fills @pfns structure
> > + * with page frame numbers of corresponding pages. If @start belongs to a
> > + * normal vma, the function grabs reference to each of the pages to pin them in
> > + * memory. If @start belongs to VM_IO | VM_PFNMAP vma, we don't touch page
> > + * structures. Caller should make sure pfns aren't reused for anything else
> > + * while he is using them.
> > + *
> > + * This function takes care of grabbing mmap_sem as necessary.
> > + */
> > +int get_vaddr_pfns(unsigned long start, int nr_pfns, int write, int force,
> > +		   struct pinned_pfns *pfns)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	struct vm_area_struct *vma;
> > +	int ret = 0;
> > +	int err;
> > +
> > +	if (nr_pfns <= 0)
> > +		return 0;
> > +
> 
> I know I suggested that nr_pfns should be unsigned earlier and then I
> saw this. Is there any valid use of the API that would pass in a
> negative number here?
  No. It was there just because I had ints everywhere without too much
thought (it's shorter to type *grin*). I'll put unsigned types where it
makes sense and add a test for INT_MAX so that get_vaddr_pfns() can still
return negative errors.

> > +	if (nr_pfns > pfns->nr_allocated_pfns)
> > +		nr_pfns = pfns->nr_allocated_pfns;
> > +
> 
> Should this be a WARN_ON_ONCE? You recover from it obviously but the return
> value is not documented to say that it could return less than requested.
> Of course, this is implied but a caller might assume it's due to a transient
> error instead of broken API usage.
  Yep, good idea.

> > +	down_read(&mm->mmap_sem);
> > +	vma = find_vma_intersection(mm, start, start + 1);
> > +	if (!vma) {
> > +		ret = -EFAULT;
> > +		goto out;
> > +	}
> 
> Returning -EFAULT means that the return value has to be signed but the
> structure itself has unsigned int for counters so the maximum number of
> PFNs supported is not available. We'd never want that number of PFNs pinned
> but still it might make sense to enforce the maximum possible size of the
> structure that takes into account the values needed for returning errors.
  Yes. See above.

> > +	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
> > +		pfns->got_ref = 1;
> > +		pfns->is_pages = 1;
> > +		ret = get_user_pages(current, mm, start, nr_pfns, write, force,
> > +				     pfns_vector_pages(pfns), NULL);
> > +		goto out;
> > +	}
> > +
> > +	pfns->got_ref = 0;
> > +	pfns->is_pages = 0;
> > +	do {
> > +		unsigned long *nums = pfns_vector_pfns(pfns);
> > +
> > +		while (ret < nr_pfns && start + PAGE_SIZE <= vma->vm_end) {
> > +			err = follow_pfn(vma, start, &nums[ret]);
> > +			if (err) {
> > +				if (ret == 0)
> > +					ret = err;
> > +				goto out;
> > +			}
> > +			start += PAGE_SIZE;
> > +			ret++;
> > +		}
> > +		/*
> > +		 * We stop if we have enough pages or if VMA doesn't completely
> > +		 * cover the tail page.
> > +		 */
> > +		if (ret >= nr_pfns || start < vma->vm_end)
> > +			break;
> > +		vma = find_vma_intersection(mm, start, start + 1);
> > +	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
> 
> Documentation probably should mention that a range that strides VMA types
> will return partial results.
  Good point. Will add that.

> > +out:
> > +	up_read(&mm->mmap_sem);
> > +	if (!ret)
> > +		ret = -EFAULT;
> 
> Really? Maybe we just failed to call get_user_pages on any of them. The
> meaning of -EFAULT probably needs a comment.
  So the only real case where we could have 0 here is when get_user_pages()
returns 0 for whatever reason. It seemed better to me to translate 0 to
-EFAULT since all the drivers I saw did that anyway (at least those that
didn't forget about checking for 0). It just seems as a less error-prone
interface to return error or number > 0. I agree that -EFAULT doesn't
necessarily always make sense so if you have idea for a better error I'm
open to suggestions.

> > +	if (ret > 0)
> > +		pfns->nr_pfns = ret;
> > +	return ret;
> > +}
> > +EXPORT_SYMBOL(get_vaddr_pfns);
> > +
> > +/**
> > + * put_vaddr_pfns() - drop references to pages if get_vaddr_pfns() acquired them
> > + * @pfns:     structure with pfns we pinned
> > + *
> > + * Drop references to pages if get_vaddr_pfns() acquired them. We also
> > + * invalidate the array of pfns so that it is prepared for the next call into
> > + * get_vaddr_pfns().
> > + */
> > +void put_vaddr_pfns(struct pinned_pfns *pfns)
> > +{
> > +	int i;
> > +
> > +	if (!pfns->got_ref)
> > +		goto out;
> > +	if (pfns->is_pages) {
> > +		struct page **pages = pfns_vector_pages(pfns);
> > +
> > +		for (i = 0; i < pfns->nr_pfns; i++)
> > +			put_page(pages[i]);
> 
> Ok.
> 
> > +	} else {
> > +		unsigned long *nums = pfns_vector_pfns(pfns);
> > +
> > +		for (i = 0; i < pfns->nr_pfns; i++)
> > +			put_page(pfn_to_page(nums[i]));
> > +	}
> 
> I'm missing something here. The !is_pages branch in get_vaddr_pfns()
> used follow_pfn() and it does not take a reference on the struct page so
> I'm not sure what this is putting exactly.
  So this case should have covered the situation when we have a vector of
normal pages (thus got_ref == 1) and convert that to a vector of pfns.
Noone currently does that and that function for conversion even doesn't
seem to exist but it seems to me at least omap driver may need it and the
conversion I did has a bug. Anyway, I'll recheck the situation and either
drop this or make the function more comprehensible.
 
> > +	pfns->got_ref = 0;
> > +out:
> > +	pfns->nr_pfns = 0;
> > +}
> > +EXPORT_SYMBOL(put_vaddr_pfns);
> > +
> 
> EXPORT_SYMBOL_GPL?
  I've just followed what __get_user_pages() does...

> > +/**
> > + * pfns_vector_to_pages - convert vector of pfns to vector of page pointers
> > + * @pfns:	structure with pinned pfns
> > + *
> > + * Convert @pfns to not contain array of pfns but array of page pointers.
> > + * If the conversion is successful, return 0. Otherwise return an error.
> > + */
> > +int pfns_vector_to_pages(struct pinned_pfns *pfns)
> > +{
> > +	int i;
> > +	unsigned long *nums;
> > +	struct page **pages;
> > +
> > +	if (pfns->is_pages)
> > +		return 0;
> > +	nums = pfns_vector_pfns(pfns);
> > +	for (i = 0; i < pfns->nr_pfns; i++)
> > +		if (!pfn_valid(nums[i]))
> > +			return -EINVAL;
> > +	pages = (struct page **)nums;
> > +	for (i = 0; i < pfns->nr_pfns; i++)
> > +		pages[i] = pfn_to_page(nums[i]);
> > +	pfns->is_pages = 1;
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL(pfns_vector_to_pages);
> > +
> > +/**
> > + * pfns_vector_create() - allocate & initialize structure for pinned pfns
> > + * @nr_pfns:	number of pfns slots we should reserve
> > + *
> > + * Allocate and initialize struct pinned_pfns to be able to hold @nr_pfns
> > + * pfns.
> > + */
> > +struct pinned_pfns *pfns_vector_create(int nr_pfns)
> > +{
> > +	struct pinned_pfns *pfns;
> > +	int size = sizeof(struct pinned_pfns) + sizeof(unsigned long) * nr_pfns;
> > +
> 
> Should be sizeof(void *) 
  OK.

> > +	if (WARN_ON_ONCE(nr_pfns <= 0))
> > +		return NULL;
> > +	if (size <= PAGE_SIZE)
> > +		pfns = kmalloc(size, GFP_KERNEL);
> 
> kmalloc supports larger sizes than this but I suspect this was
> deliberate to avoid high-order allocations.
  Exactly.

  Thanks a lot for review Mel!

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
