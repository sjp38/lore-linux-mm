Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77ABA6B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 07:00:27 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id e3-v6so8917437pld.13
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 04:00:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y26-v6sor719493pfa.69.2018.10.12.04.00.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 04:00:26 -0700 (PDT)
Date: Fri, 12 Oct 2018 14:00:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2] mm/gup: Cache dev_pagemap while pinning pages
Message-ID: <20181012110020.pu5oanl6tnz4mibr@kshutemo-mobl1>
References: <20181011175542.13045-1-keith.busch@intel.com>
 <CAPcyv4gGqhGpR8g-HmNzoEnMAysO5uAO+8njeAokHq2CT9x71A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gGqhGpR8g-HmNzoEnMAysO5uAO+8njeAokHq2CT9x71A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Keith Busch <keith.busch@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Oct 11, 2018 at 04:24:02PM -0700, Dan Williams wrote:
> On Thu, Oct 11, 2018 at 11:00 AM Keith Busch <keith.busch@intel.com> wrote:
> >
> > Getting pages from ZONE_DEVICE memory needs to check the backing device's
> > live-ness, which is tracked in the device's dev_pagemap metadata. This
> > metadata is stored in a radix tree and looking it up adds measurable
> > software overhead.
> >
> > This patch avoids repeating this relatively costly operation when
> > dev_pagemap is used by caching the last dev_pagemap while getting user
> > pages. The gup_benchmark kernel self test reports this reduces time to
> > get user pages to as low as 1/3 of the previous time.
> >
> > Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> 
> Other than the 2 comments below, this looks good to me:
> 
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>

Looks good to me too:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> 
> [..]
> > diff --git a/mm/gup.c b/mm/gup.c
> > index 1abc8b4afff6..d2700dff6f66 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> [..]
> > @@ -431,7 +430,22 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> >                 return no_page_table(vma, flags);
> >         }
> >
> > -       return follow_p4d_mask(vma, address, pgd, flags, page_mask);
> > +       return follow_p4d_mask(vma, address, pgd, flags, ctx);
> > +}
> > +
> > +struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
> > +                        unsigned int foll_flags)
> > +{
> > +       struct page *page;
> > +       struct follow_page_context ctx = {
> > +               .pgmap = NULL,
> > +               .page_mask = 0,
> > +       };
> 
> You don't need to init all members. It is defined that if you init at
> least one member then all non initialized members are set to zero, so
> you should be able to do " = { 0 }".
> 
> > +
> > +       page = follow_page_mask(vma, address, foll_flags, &ctx);
> > +       if (ctx.pgmap)
> > +               put_dev_pagemap(ctx.pgmap);
> > +       return page;
> >  }
> >
> >  static int get_gate_page(struct mm_struct *mm, unsigned long address,
> > @@ -659,9 +673,9 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >                 unsigned int gup_flags, struct page **pages,
> >                 struct vm_area_struct **vmas, int *nonblocking)
> >  {
> > -       long i = 0;
> > -       unsigned int page_mask;
> > +       long ret = 0, i = 0;
> >         struct vm_area_struct *vma = NULL;
> > +       struct follow_page_context ctx = {};
> 
> Does this have defined behavior? I would feel better with " = { 0 }"
> to be explicit.

Well, it's not allowed by the standart, but GCC allows this.
You can see a warning with -pedantic.

We use empty-list initializers a lot in the kernel:
$ git grep 'struct .*= {};' | wc -l
997

It should be fine.

-- 
 Kirill A. Shutemov
