Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CBB386B017B
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:41:16 -0400 (EDT)
Date: Tue, 25 Aug 2009 12:05:14 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3]HTLB mapping for drivers. Alloc functions & some
	export symbols(take 2)
Message-ID: <20090825110514.GC21335@csn.ul.ie>
References: <alpine.LFD.2.00.0908172324130.32114@casper.infradead.org> <20090818082247.GA31469@csn.ul.ie> <202cde0e0908182029k73292ee9k6d2782b40beaaa1c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0908182029k73292ee9k6d2782b40beaaa1c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 03:29:27PM +1200, Alexey Korolev wrote:
> >>   * Use a helper variable to find the next node and then
> >>   * copy it back to hugetlb_next_nid afterwards:
> >>   * otherwise there's a window in which a racer might
> >
> > I haven't read through the whole patchset properly yet, but at this
> > point it's looking like you are going to expect drivers to create a file
> > and then manually populate the page cache with hugepages they allocate
> > directly from here. That would appear to put a large burden of VM
> > knowledge upon a device driver author. The patch would also appear to
> > expose a lot of hugetlbfs internals.
> >
> > Have you looked at Eric Munson's patches on the implementation of
> > MAP_HUGETLB in the patch set
> >
> > http://marc.info/?l=linux-mm&m=125025895815115&w=2
> >
> > ?
>
> Right. Simplicity is very important here and I just haven't find a
> good way to make it simpler yet.
> Thanks for the link neat approach is a thing I really need now. I've
> studied the code and it has quite nice approach which could be
> helpful.
> 
> >
> > In that patchset, it was a very small number of changes required to
> > expose a mapping private or shared to userspace.
> >
> > Would it make more sense to take an approach like that and instead add
> > an additional helper within hugetlbfs (instead of the driver) that would
> > return a pinned page at a given offset within a hugetlbfs file?
> >
>
> I believe it possible to to have a helper. The main problem here is
> this: we need to
> have a file which provides hugetlb mapping and which is not a part of
> Hugetlbfs.

So you have a

device_file_ops
	o Have mapping between device_file and a hugetlbfs file
	  complete with hugetlb_fops already setup.
	o device->get_unmapped_area calls
	  hugetlb_fops->get_unmapped_area

> So
> the file does not have hugetlbfs file operations.It means it is
> necessary to call somehow
> hugetlb_get_unmapped_area & hugetlbfs_file_mmap for the file on
> hugetlbfs associated
> with the file related to device.
> 

The fact I haven't prototyped anything doesn't help, but if a device driver
calls hugetlb_file_setup(), I don't see why your devices get_unmapped_area()
hook cannot call the hugetlbfs mappings get_unmapped_area() hook. Maybe I'm
missing something obvious.

> Probably, if we have non-hugetlbfs file and want to have huge pages
> mappings it could make sense to have this approach:
> 
> add the following lines to mmap.c/get_unmapped_area function:
> 
>          get_area = current->mm->get_unmapped_area;
>          if (file && file->f_op && file->f_op->get_unmapped_area)
>                 get_area = file->f_op->get_unmapped_area;
> +       /* Call hugetlb_get_unmapped_area If non hugetlbfs file has
> huge page mapping */
> +       if (file && mapping_hugetlb(file->f_mapping) &&
> !is_file_hugepages(file))
> +               get_area = hugetlb_get_unmapped_area;

Again, I'm not seeing why the file->f_op that represents your device file
cannot remember where it's hugetlbfs file is and simply call down to its
get_unmapped_area.

>         addr = get_area(file, addr, len, pgoff, flags);
>         if (IS_ERR_VALUE(addr))
>                 return addr;
> 
> add the following lines to mmap.c/mmap_region function:
>                 }
>                 vma->vm_file = file;
>                 get_file(file);
>                 error = file->f_op->mmap(file, vma);
>                 if (error)
>                         goto unmap_and_free_vma;
> +               /*
> +                * If non non hugetlbfs file has huge page mapping
> mmap must be called twice
> +                * first time for proceeding file->fops->mmap second
> time we must call hugetlbfs mmap
> +               */
> +               if (mapping_hugetlb(file->f_mapping) &&
> !is_file_hugepages(file))
> +                       error =hugetlbfs_file_mmap(file, vma);
> +                if (error)
> +                        goto unmap_and_free_vma;
> 
>                 if (vm_flags & VM_EXECUTABLE)
> 
> Where mapping_hugetlb is
> +static inline int mapping_hugetlb(struct address_space *mapping)
> +{
> +	if (likely(mapping))
> +		return test_bit(AS_HUGETLB, &mapping->flags);
> +	return 0;
> +}
> +
> In addition we also need to introduce hugetlbfs_sb_info getting macro
> to avoid issues in hugetlb_get_quota/hugetlb_put_quota functions.
> 

What is the quota difficulty? shm manages to use the internal mount
without quota-related difficulty so why is your driver different?

> In this case a driver just need to announce that file has huge page
> mapping (mapping_set_hugetlb(file->f_mapping)), add some pages to page
> cache and set-up proper VM flag in flie->f_ops->mmap.
> 
> Do you see anything really important being missed in this approach?
> 

Just that it still seems too complicated with a large amount of
hugetlbfs internals being exposed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
