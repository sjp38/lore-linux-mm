Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 495306B0256
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:47:20 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so23137034pad.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 08:47:20 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id q4si6136157pap.177.2015.09.17.08.47.19
        for <linux-mm@kvack.org>;
        Thu, 17 Sep 2015 08:47:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20150917154131.GA27791@linux.intel.com>
References: <1438948423-128882-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAA9_cmd9D=7YgZrCf+w3HcckoqcfmCLEHhhm9j+kv+V0ijUnqw@mail.gmail.com>
 <20150916111218.GB23026@node.dhcp.inet.fi>
 <20150917154131.GA27791@linux.intel.com>
Subject: Re: [PATCH] mm: take i_mmap_lock in unmap_mapping_range() for DAX
Content-Transfer-Encoding: 7bit
Message-Id: <20150917154715.7A857B8@black.fi.intel.com>
Date: Thu, 17 Sep 2015 18:47:15 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>

Ross Zwisler wrote:
> On Wed, Sep 16, 2015 at 02:12:18PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Sep 15, 2015 at 04:52:42PM -0700, Dan Williams wrote:
> > > Hi Kirill,
> > > 
> > > On Fri, Aug 7, 2015 at 4:53 AM, Kirill A. Shutemov
> > > <kirill.shutemov@linux.intel.com> wrote:
> > > > DAX is not so special: we need i_mmap_lock to protect mapping->i_mmap.
> > > >
> > > > __dax_pmd_fault() uses unmap_mapping_range() shoot out zero page from
> > > > all mappings. We need to drop i_mmap_lock there to avoid lock deadlock.
> > > >
> > > > Re-aquiring the lock should be fine since we check i_size after the
> > > > point.
> > > >
> > > > Not-yet-signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > ---
> > > >  fs/dax.c    | 35 +++++++++++++++++++----------------
> > > >  mm/memory.c | 11 ++---------
> > > >  2 files changed, 21 insertions(+), 25 deletions(-)
> > > >
> > > > diff --git a/fs/dax.c b/fs/dax.c
> > > > index 9ef9b80cc132..ed54efedade6 100644
> > > > --- a/fs/dax.c
> > > > +++ b/fs/dax.c
> > > > @@ -554,6 +554,25 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> > > >         if (!buffer_size_valid(&bh) || bh.b_size < PMD_SIZE)
> > > >                 goto fallback;
> > > >
> > > > +       if (buffer_unwritten(&bh) || buffer_new(&bh)) {
> > > > +               int i;
> > > > +               for (i = 0; i < PTRS_PER_PMD; i++)
> > > > +                       clear_page(kaddr + i * PAGE_SIZE);
> > > 
> > > This patch, now upstream as commit 46c043ede471, moves the call to
> > > clear_page() earlier in __dax_pmd_fault().  However, 'kaddr' is not
> > > set at this point, so I'm not sure this path was ever tested.
> > 
> > Ughh. It's obviously broken.
> > 
> > I took fs/dax.c part of the patch from Matthew. And I'm not sure now we
> > would need to move this "if (buffer_unwritten(&bh) || buffer_new(&bh)) {"
> > block around. It should work fine where it was before. Right?
> > Matthew?
> 
> Moving the "if (buffer_unwritten(&bh) || buffer_new(&bh)) {" block back seems
> correct to me.  Matthew is out for a while, so we should probably take care of
> this without him.
> 
> Kirill, do you want to whip up a quick patch?  I'm happy to do it if you're
> busy.

I would be better if you'll prepare the patch. Thanks.

-- 
 Kirill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
