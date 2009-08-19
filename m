Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DA4BF6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 23:29:29 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so1624065ana.26
        for <linux-mm@kvack.org>; Tue, 18 Aug 2009 20:29:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090818082247.GA31469@csn.ul.ie>
References: <alpine.LFD.2.00.0908172324130.32114@casper.infradead.org>
	 <20090818082247.GA31469@csn.ul.ie>
Date: Wed, 19 Aug 2009 15:29:27 +1200
Message-ID: <202cde0e0908182029k73292ee9k6d2782b40beaaa1c@mail.gmail.com>
Subject: Re: [PATCH 1/3]HTLB mapping for drivers. Alloc functions & some
	export symbols(take 2)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

>> =C2=A0 * Use a helper variable to find the next node and then
>> =C2=A0 * copy it back to hugetlb_next_nid afterwards:
>> =C2=A0 * otherwise there's a window in which a racer might
>
> I haven't read through the whole patchset properly yet, but at this
> point it's looking like you are going to expect drivers to create a file
> and then manually populate the page cache with hugepages they allocate
> directly from here. That would appear to put a large burden of VM
> knowledge upon a device driver author. The patch would also appear to
> expose a lot of hugetlbfs internals.
>
> Have you looked at Eric Munson's patches on the implementation of
> MAP_HUGETLB in the patch set
>
> http://marc.info/?l=3Dlinux-mm&m=3D125025895815115&w=3D2
>
> ?
Right. Simplicity is very important here and I just haven't find a
good way to make it simpler yet.
Thanks for the link neat approach is a thing I really need now. I've
studied the code and it has quite nice approach which could be
helpful.

>
> In that patchset, it was a very small number of changes required to
> expose a mapping private or shared to userspace.
>
> Would it make more sense to take an approach like that and instead add
> an additional helper within hugetlbfs (instead of the driver) that would
> return a pinned page at a given offset within a hugetlbfs file?
>
I believe it possible to to have a helper. The main problem here is
this: we need to
have a file which provides hugetlb mapping and which is not a part of
Hugetlbfs. So
the file does not have hugetlbfs file operations.It means it is
necessary to call somehow
hugetlb_get_unmapped_area & hugetlbfs_file_mmap for the file on
hugetlbfs associated
with the file related to device.

Probably, if we have non-hugetlbfs file and want to have huge pages
mappings it could make sense to have this approach:

add the following lines to mmap.c/get_unmapped_area function:

         get_area =3D current->mm->get_unmapped_area;
         if (file && file->f_op && file->f_op->get_unmapped_area)
                get_area =3D file->f_op->get_unmapped_area;
+       /* Call hugetlb_get_unmapped_area If non hugetlbfs file has
huge page mapping */
+       if (file && mapping_hugetlb(file->f_mapping) &&
!is_file_hugepages(file))
+               get_area =3D hugetlb_get_unmapped_area;
        addr =3D get_area(file, addr, len, pgoff, flags);
        if (IS_ERR_VALUE(addr))
                return addr;

add the following lines to mmap.c/mmap_region function:
                }
                vma->vm_file =3D file;
                get_file(file);
                error =3D file->f_op->mmap(file, vma);
                if (error)
                        goto unmap_and_free_vma;
+               /*
+                * If non non hugetlbfs file has huge page mapping
mmap must be called twice
+                * first time for proceeding file->fops->mmap second
time we must call hugetlbfs mmap
+               */
+               if (mapping_hugetlb(file->f_mapping) &&
!is_file_hugepages(file))
+                       error =3Dhugetlbfs_file_mmap(file, vma);
+                if (error)
+                        goto unmap_and_free_vma;

                if (vm_flags & VM_EXECUTABLE)

Where mapping_hugetlb is
+static inline int mapping_hugetlb(struct address_space *mapping)
+{
+	if (likely(mapping))
+		return test_bit(AS_HUGETLB, &mapping->flags);
+	return 0;
+}
+
In addition we also need to introduce hugetlbfs_sb_info getting macro
to avoid issues in hugetlb_get_quota/hugetlb_put_quota functions.

In this case a driver just need to announce that file has huge page
mapping (mapping_set_hugetlb(file->f_mapping)), add some pages to page
cache and set-up proper VM flag in flie->f_ops->mmap.

Do you see anything really important being missed in this approach?

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
