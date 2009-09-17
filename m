Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E80E6B005A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 05:18:12 -0400 (EDT)
Date: Thu, 17 Sep 2009 10:18:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Identification of huge pages mapping (Take 3)
Message-ID: <20090917091818.GC13002@csn.ul.ie>
References: <202cde0e0909132216l79aae251ya3a6685587c7692c@mail.gmail.com> <20090915121456.GB31840@csn.ul.ie> <202cde0e0909160511y6f4542d1p38f9a8818c2a454d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0909160511y6f4542d1p38f9a8818c2a454d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 17, 2009 at 12:11:33AM +1200, Alexey Korolev wrote:
> Mel,
> 
> > I suggest a subject change to
> >
> > "Identify huge page mappings from address_space->flags instead of file_operations comparison"
> >
> > for the purposes of having an easier-to-understand changelog.
> >
>
> Yes. It is a bit longer but it is definitely clear. Will be corrected.
> 

Thanks

> > On Mon, Sep 14, 2009 at 05:16:13PM +1200, Alexey Korolev wrote:
> >> This patch changes a little bit the procedures of huge pages file
> >> identification. We need this because we may have huge page mapping for
> >> files which are not on hugetlbfs (the same case in ipc/shm.c).
> >
> > Is this strictly-speaking true as there is still a file on hugetlbfs for
> > the driver? Maybe something like
> >
> > This patch identifies whether a mapping uses huge pages based on the
> > address_space flags instead of the file operations. A later patch allows
> > a driver to manage an underlying hugetlbfs file while exposing it via a
> > different file_operations structure.
> >
> > I haven't read the rest of the series yet so take the suggestion with a
> > grain of salt.
> 
> You understood properly. Thanks for the comments. I need to work on
> the description more, it seems not to be completely clear.
> 
> >> Just file operations check will not work as drivers should have own
> >> file operations. So if we need to identify if file has huge pages
> >> mapping, we need to check the file mapping flags.
> >> New identification procedure obsoletes existing workaround for hugetlb
> >> file identification in ipc/shm.c
> >> Also having huge page mapping for files which are not on hugetlbfs do
> >> not allow us to get hstate based on file dentry, we need to be based
> >> on file mapping instead.
> >
> > Can you clarify this a bit more? I think the reasoning is as follows but
> > confirmation would be nice.
> >
> > "As part of this, the hstate for a given file as implemented by hstate_file()
> > must be based on file mapping instead of dentry. Even if a driver is
> > maintaining an underlying hugetlbfs file, the mmap() operation is still
> > taking place on a device-specific file. That dentry is unlikely to be on
> > a hugetlbfs file. A device driver must ensure that file->f_mapping->host
> > resolves correctly."
> >
> > If this is accurate, a comment in hstate_file() wouldn't hurt in case
> > someone later decides that dentry really was the way to go.
> >
>
> Right. Getting hstate via mapping instead of dentry is important here, so it is
> necessary to add a comment in order to prevent people breaking this.
> A comment will be added.
> 

Thanks

> >>
> >>  static inline int is_file_hugepages(struct file *file)
> >>  {
> >> -     if (file->f_op == &hugetlbfs_file_operations)
> >> -             return 1;
> >> -     if (is_file_shm_hugepages(file))
> >> -             return 1;
> >> -
> >> -     return 0;
> >> -}
> >> -
> >> -static inline void set_file_hugepages(struct file *file)
> >> -{
> >> -     file->f_op = &hugetlbfs_file_operations;
> >> +     return mapping_hugetlb(file->f_mapping);
> >>  }
> >>  #else /* !CONFIG_HUGETLBFS */
> >>
> >>  #define is_file_hugepages(file)                      0
> >> -#define set_file_hugepages(file)             BUG()
> >>  #define hugetlb_file_setup(name,size,acct,user,creat)        ERR_PTR(-ENOSYS)
> >>
> >
> > Why do you remove this BUG()? It still seems to be a valid check.
>
> I removed this function - because it has not been called since 2.6.15 and
> it is confusing the user a bit after applying new changes. I think it
> was necessary to write about this little change in description, sorry
> about that.

If it's really confusing, it should be a separate patch. It doesn't need to
be folded into this one.

> >>
> >> +static inline void mapping_set_hugetlb(struct address_space *mapping)
> >> +{
> >> +     set_bit(AS_HUGETLB, &mapping->flags);
> >> +}
> >> +
> >> +static inline int mapping_hugetlb(struct address_space *mapping)
> >> +{
> >> +     if (likely(mapping))
> >> +             return test_bit(AS_HUGETLB, &mapping->flags);
> >> +     return 0;
> >> +}
> >
> > Is mapping_hugetlb necessary? Why not just make that the implementation
> > of is_file_hugepages()
>
> No. It is not necessary. The reason I wrote these functions is just
> there are the
> similar function for other mapping flags. I see no problem to have
> only: is_file_hugepages and
> set_file_huge_pages in hugetlb.h instead of mapping_set_hugetlb and
> mapping_hugetlb.
> 

I'd also be ok with you converting is_file_hugepages and set_file_huge_pages()
to mapping_set_hugetlb and mapping_hugetlb to bring hugetlb functions more
in line with the core VM.

> >> -     if (file->f_op == &shm_file_operations) {
> >> -             struct shm_file_data *sfd;
> >> -             sfd = shm_file_data(file);
> >> -             ret = is_file_hugepages(sfd->file);
> >> -     }
> >> -     return ret;
> >> -}
> >
> > What about the declarations and definitions in include/linux/shm.h?
> 
> Ahh. Thank you! Will be fixed.
> 
> Thanks,
> Alexey
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
