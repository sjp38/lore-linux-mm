Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0C99A6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:00:30 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so28901660wgb.2
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:00:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w2si167403wif.84.2015.05.11.07.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 May 2015 07:00:26 -0700 (PDT)
Date: Mon, 11 May 2015 16:00:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/9] mm: Provide new get_vaddr_frames() helper
Message-ID: <20150511140019.GD25034@quack.suse.cz>
References: <1430897296-5469-1-git-send-email-jack@suse.cz>
 <1430897296-5469-3-git-send-email-jack@suse.cz>
 <20150508144922.GO2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150508144922.GO2462@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org

On Fri 08-05-15 15:49:22, Mel Gorman wrote:
> On Wed, May 06, 2015 at 09:28:09AM +0200, Jan Kara wrote:
> > Provide new function get_vaddr_frames().  This function maps virtual
> > addresses from given start and fills given array with page frame numbers of
> > the corresponding pages. If given start belongs to a normal vma, the function
> > grabs reference to each of the pages to pin them in memory. If start
> > belongs to VM_IO | VM_PFNMAP vma, we don't touch page structures. Caller
> > must make sure pfns aren't reused for anything else while he is using
> > them.
> > 
> > This function is created for various drivers to simplify handling of
> > their buffers.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> Trivial comments only;
...
> > @@ -936,6 +937,219 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
> >  	return ret;	/* 0 or negative error code */
> >  }
> >  
> > +/*
> > + * get_vaddr_frames() - map virtual addresses to pfns
> > + * @start:	starting user address
> > + * @nr_frames:	number of pages / pfns from start to map
> > + * @write:	whether pages will be written to by the caller
> > + * @force:	whether to force write access even if user mapping is
> > + *		readonly. This will result in the page being COWed even
> > + *		in MAP_SHARED mappings. You do not want this.
> 
> If they don't want it, why does it exist?
  This was copied from get_user_pages(). The original comment changed in
the mean time so I've updated this one somewhat and referenced comment at
get_user_pages() for details.

> > + * @vec:	structure which receives pages / pfns of the addresses mapped.
> > + *		It should have space for at least nr_frames entries.
> > + *
> > + * This function maps virtual addresses from @start and fills @vec structure
> > + * with page frame numbers or page pointers to corresponding pages (choice
> > + * depends on the type of the vma underlying the virtual address). If @start
> > + * belongs to a normal vma, the function grabs reference to each of the pages
> > + * to pin them in memory. If @start belongs to VM_IO | VM_PFNMAP vma, we don't
> > + * touch page structures and the caller must make sure pfns aren't reused for
> > + * anything else while he is using them.
> > + *
> > + * The function returns number of pages mapped which may be less than
> > + * @nr_frames. In particular we stop mapping if there are more vmas of
> > + * different type underlying the specified range of virtual addresses.
> > + *
> > + * This function takes care of grabbing mmap_sem as necessary.
> > + */
> > +int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
> > +		     bool write, bool force, struct frame_vector *vec)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	struct vm_area_struct *vma;
> > +	int ret = 0;
> > +	int err;
> > +	int locked = 1;
> > +
> 
> bool locked.
  It cannot be bool. It is passed to get_user_pages_locked() which expects
int *.

> > +	if (nr_frames == 0)
> > +		return 0;
> > +
> > +	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
> > +		nr_frames = vec->nr_allocated;
> > +
> > +	down_read(&mm->mmap_sem);
> > +	vma = find_vma_intersection(mm, start, start + 1);
> > +	if (!vma) {
> > +		ret = -EFAULT;
> > +		goto out;
> > +	}
> > +	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
> > +		vec->got_ref = 1;
> > +		vec->is_pfns = 0;
> 
> They're bools and while correct, it looks weird. There are a few
> instances of this but I won't comment on it again.
  Thanks. Fixed.

> > +		ret = get_user_pages_locked(current, mm, start, nr_frames,
> > +			write, force, (struct page **)(vec->ptrs), &locked);
> > +		goto out;
> > +	}
> > +
> > +	vec->got_ref = 0;
> > +	vec->is_pfns = 1;
> > +	do {
> > +		unsigned long *nums = frame_vector_pfns(vec);
> > +
> > +		while (ret < nr_frames && start + PAGE_SIZE <= vma->vm_end) {
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
> > +		if (ret >= nr_frames || start < vma->vm_end)
> > +			break;
> > +		vma = find_vma_intersection(mm, start, start + 1);
> > +	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
> > +out:
> > +	if (locked)
> > +		up_read(&mm->mmap_sem);
> > +	if (!ret)
> > +		ret = -EFAULT;
> > +	if (ret > 0)
> > +		vec->nr_frames = ret;
> > +	return ret;
> > +}
> > +EXPORT_SYMBOL(get_vaddr_frames);
> > +
> > +/**
> > + * put_vaddr_frames() - drop references to pages if get_vaddr_frames() acquired
> > + *			them
> > + * @vec:	frame vector to put
> > + *
> > + * Drop references to pages if get_vaddr_frames() acquired them. We also
> > + * invalidate the frame vector so that it is prepared for the next call into
> > + * get_vaddr_frames().
> > + */
> > +void put_vaddr_frames(struct frame_vector *vec)
> > +{
> > +	int i;
> > +	struct page **pages;
> > +
> > +	if (!vec->got_ref)
> > +		goto out;
> > +	pages = frame_vector_pages(vec);
> > +	/*
> > +	 * frame_vector_pages() might needed to do a conversion when we
> > +	 * get_vaddr_frames() got pages but vec was later converted to pfns.
> > +	 * But it shouldn't really fail to convert pfns back...
> > +	 */
> > +	BUG_ON(IS_ERR(pages));
> 
> It's hard to see how it could but it is recoverable so BUG_ON is
> overkill. WARN_ON and return even though we potentially leaked now.
  OK.

> > +	for (i = 0; i < vec->nr_frames; i++)
> > +		put_page(pages[i]);
> > +	vec->got_ref = 0;
> > +out:
> > +	vec->nr_frames = 0;
> > +}
> > +EXPORT_SYMBOL(put_vaddr_frames);
> > +
> > +/**
> > + * frame_vector_to_pages - convert frame vector to contain page pointers
> > + * @vec:	frame vector to convert
> > + *
> > + * Convert @vec to contain array of page pointers.  If the conversion is
> > + * successful, return 0. Otherwise return an error.
> > + */
> 
> If you do another version, it would not hurt to mention that a page
> reference is not taken when doing this conversion.
  OK, done.

> > +int frame_vector_to_pages(struct frame_vector *vec)
> > +{
> 
> I think it's probably best to make the relevant counters in frame_vector
> signed and limit the maximum possible size of it. It's still not putting
> any practical limit on the size of the frame_vector.
  I don't see a reason why counters in frame_vector should be signed... Can
you share your reason?  I've added a check into frame_vector_create() to
limit number of frames to INT_MAX / sizeof(void *) / 2 to avoid arithmetics
overflow. Thanks for review!

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
