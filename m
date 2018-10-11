Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id D18BA6B000C
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 20:46:34 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id b202-v6so4839813oii.23
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 17:46:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t194-v6sor11533559oif.64.2018.10.10.17.46.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 17:46:33 -0700 (PDT)
MIME-Version: 1.0
References: <20180824154542.26872-1-jack@suse.cz> <20181010173015.ecb7c7ed1b2df729f058e346@linux-foundation.org>
In-Reply-To: <20181010173015.ecb7c7ed1b2df729f058e346@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 10 Oct 2018 17:46:22 -0700
Message-ID: <CAPcyv4hB+rhST7QgNcT0QyLnYY3jQagd_tw8Lz=x3eO+TBFZxg@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix warning in insert_pfn()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Dave Jiang <dave.jiang@intel.com>

On Wed, Oct 10, 2018 at 5:37 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Fri, 24 Aug 2018 17:45:42 +0200 Jan Kara <jack@suse.cz> wrote:
>
> > In DAX mode a write pagefault can race with write(2) in the following
> > way:
> >
> > CPU0                            CPU1
> >                                 write fault for mapped zero page (hole)
> > dax_iomap_rw()
> >   iomap_apply()
> >     xfs_file_iomap_begin()
> >       - allocates blocks
> >     dax_iomap_actor()
> >       invalidate_inode_pages2_range()
> >         - invalidates radix tree entries in given range
> >                                 dax_iomap_pte_fault()
> >                                   grab_mapping_entry()
> >                                     - no entry found, creates empty
> >                                   ...
> >                                   xfs_file_iomap_begin()
> >                                     - finds already allocated block
> >                                   ...
> >                                   vmf_insert_mixed_mkwrite()
> >                                     - WARNs and does nothing because there
> >                                       is still zero page mapped in PTE
> >         unmap_mapping_pages()
> >
> > This race results in WARN_ON from insert_pfn() and is occasionally
> > triggered by fstest generic/344. Note that the race is otherwise
> > harmless as before write(2) on CPU0 is finished, we will invalidate page
> > tables properly and thus user of mmap will see modified data from
> > write(2) from that point on. So just restrict the warning only to the
> > case when the PFN in PTE is not zero page.
> >
> > ...
> >
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1787,10 +1787,15 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
> >                        * in may not match the PFN we have mapped if the
> >                        * mapped PFN is a writeable COW page.  In the mkwrite
> >                        * case we are creating a writable PTE for a shared
> > -                      * mapping and we expect the PFNs to match.
> > +                      * mapping and we expect the PFNs to match. If they
> > +                      * don't match, we are likely racing with block
> > +                      * allocation and mapping invalidation so just skip the
> > +                      * update.
> >                        */
> > -                     if (WARN_ON_ONCE(pte_pfn(*pte) != pfn_t_to_pfn(pfn)))
> > +                     if (pte_pfn(*pte) != pfn_t_to_pfn(pfn)) {
> > +                             WARN_ON_ONCE(!is_zero_pfn(pte_pfn(*pte)));
> >                               goto out_unlock;
> > +                     }
> >                       entry = *pte;
>
> Shouldn't we just remove the warning?  We know it happens and we know
> why it happens and we know it's harmless.  What's the point in scaring
> people?

tl;dr let's keep it.

I think this fix effectively pushes this into "can't happen"
territory, but if it does our dax assumptions are off somewhere else.
So, I think this is useful for developers hacking around in the dax
code to make sure they aren't breaking some fundamental assumption.
