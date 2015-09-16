Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4E04D6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 07:12:24 -0400 (EDT)
Received: by lamp12 with SMTP id p12so125165009lam.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 04:12:23 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id gx10si5600123wib.108.2015.09.16.04.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 04:12:22 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so67648616wic.1
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 04:12:22 -0700 (PDT)
Date: Wed, 16 Sep 2015 14:12:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: take i_mmap_lock in unmap_mapping_range() for DAX
Message-ID: <20150916111218.GB23026@node.dhcp.inet.fi>
References: <1438948423-128882-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAA9_cmd9D=7YgZrCf+w3HcckoqcfmCLEHhhm9j+kv+V0ijUnqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmd9D=7YgZrCf+w3HcckoqcfmCLEHhhm9j+kv+V0ijUnqw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, Dan Williams <dan.j.williams@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, ross.zwisler@linux.intel.com

On Tue, Sep 15, 2015 at 04:52:42PM -0700, Dan Williams wrote:
> Hi Kirill,
> 
> On Fri, Aug 7, 2015 at 4:53 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > DAX is not so special: we need i_mmap_lock to protect mapping->i_mmap.
> >
> > __dax_pmd_fault() uses unmap_mapping_range() shoot out zero page from
> > all mappings. We need to drop i_mmap_lock there to avoid lock deadlock.
> >
> > Re-aquiring the lock should be fine since we check i_size after the
> > point.
> >
> > Not-yet-signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  fs/dax.c    | 35 +++++++++++++++++++----------------
> >  mm/memory.c | 11 ++---------
> >  2 files changed, 21 insertions(+), 25 deletions(-)
> >
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 9ef9b80cc132..ed54efedade6 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -554,6 +554,25 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> >         if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
> >                 goto fallback;
> >
> > +       if (buffer_unwritten(&bh) || buffer_new(&bh)) {
> > +               int i;
> > +               for (i = 0; i < PTRS_PER_PMD; i++)
> > +                       clear_page(kaddr + i * PAGE_SIZE);
> 
> This patch, now upstream as commit 46c043ede471, moves the call to
> clear_page() earlier in __dax_pmd_fault().  However, 'kaddr' is not
> set at this point, so I'm not sure this path was ever tested.

Ughh. It's obviously broken.

I took fs/dax.c part of the patch from Matthew. And I'm not sure now we
would need to move this "if (buffer_unwritten(&bh) || buffer_new(&bh)) {"
block around. It should work fine where it was before. Right?
Matthew?

> I'm also not sure why the compiler is not complaining about an
> uninitialized variable?

No idea.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
