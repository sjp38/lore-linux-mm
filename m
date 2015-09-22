Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 993276B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 17:17:18 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so1410329pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:17:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id uv9si5246725pac.183.2015.09.22.14.17.17
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 14:17:17 -0700 (PDT)
Date: Tue, 22 Sep 2015 15:17:16 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2] dax: fix NULL pointer in __dax_pmd_fault()
Message-ID: <20150922211716.GA32623@linux.intel.com>
References: <1442950582-10140-1-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4hubJDhWResqaG_aQLSLUVEOujk=EEDVQ1BF+sAdK45LA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hubJDhWResqaG_aQLSLUVEOujk=EEDVQ1BF+sAdK45LA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, @linux.intel.com
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>

On Tue, Sep 22, 2015 at 01:51:04PM -0700, Dan Williams wrote:
> [ adding Andrew ]
> 
> On Tue, Sep 22, 2015 at 12:36 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > The following commit:
> >
> > commit 46c043ede471 ("mm: take i_mmap_lock in unmap_mapping_range() for
> >         DAX")
> >
> > moved some code in __dax_pmd_fault() that was responsible for zeroing
> > newly allocated PMD pages.  The new location didn't properly set up
> > 'kaddr', though, so when run this code resulted in a NULL pointer BUG.
> >
> > Fix this by getting the correct 'kaddr' via bdev_direct_access().
> >
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Reported-by: Dan Williams <dan.j.williams@intel.com>
> 
> Taking into account the comment below,
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> 
> > ---
> >  fs/dax.c | 13 ++++++++++++-
> >  1 file changed, 12 insertions(+), 1 deletion(-)
> >
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 7ae6df7..bcfb14b 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -569,8 +569,20 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> >         if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
> >                 goto fallback;
> >
> > +       sector = bh.b_blocknr << (blkbits - 9);
> > +
> >         if (buffer_unwritten(&bh) || buffer_new(&bh)) {
> >                 int i;
> > +
> > +               length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn,
> > +                                               bh.b_size);
> > +               if (length < 0) {
> > +                       result = VM_FAULT_SIGBUS;
> > +                       goto out;
> > +               }
> > +               if ((length < PMD_SIZE) || (pfn & PG_PMD_COLOUR))
> > +                       goto fallback;
> > +
> 
> Hmm, we don't need the PG_PMD_COLOUR check since we aren't using the
> pfn in this path, right?

I think we care, because we'll end up bailing anyway at the later
PG_PMD_COLOUR check before we actually insert the pfn via
vmf_insert_pfn_pmd().  If we don't check the alignment we'll do 2 MiB worth of
zeroing to the media, then later fall back to PTE faults.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
