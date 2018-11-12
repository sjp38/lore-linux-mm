Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECF86B02A8
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 11:15:00 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w96so6904354ota.10
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 08:15:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n60sor9650001ota.162.2018.11.12.08.14.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 08:14:58 -0800 (PST)
MIME-Version: 1.0
References: <20181110085041.10071-1-jhubbard@nvidia.com> <20181110085041.10071-2-jhubbard@nvidia.com>
 <20181112154127.GA8247@localhost.localdomain>
In-Reply-To: <20181112154127.GA8247@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Nov 2018 08:14:46 -0800
Message-ID: <CAPcyv4j7nqLOFD5dZEe_nBysHDL2pQ-tRO9Crp9oyTUP7RoDHw@mail.gmail.com>
Subject: Re: [PATCH v2 1/6] mm/gup: finish consolidating error handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: John Hubbard <john.hubbard@gmail.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>

On Mon, Nov 12, 2018 at 7:45 AM Keith Busch <keith.busch@intel.com> wrote:
>
> On Sat, Nov 10, 2018 at 12:50:36AM -0800, john.hubbard@gmail.com wrote:
> > From: John Hubbard <jhubbard@nvidia.com>
> >
> > An upcoming patch wants to be able to operate on each page that
> > get_user_pages has retrieved. In order to do that, it's best to
> > have a common exit point from the routine. Most of this has been
> > taken care of by commit df06b37ffe5a4 ("mm/gup: cache dev_pagemap while
> > pinning pages"), but there was one case remaining.
> >
> > Also, there was still an unnecessary shadow declaration (with a
> > different type) of the "ret" variable, which this commit removes.
> >
> > Cc: Keith Busch <keith.busch@intel.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > ---
> >  mm/gup.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> >
> > diff --git a/mm/gup.c b/mm/gup.c
> > index f76e77a2d34b..55a41dee0340 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -696,12 +696,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >               if (!vma || start >= vma->vm_end) {
> >                       vma = find_extend_vma(mm, start);
> >                       if (!vma && in_gate_area(mm, start)) {
> > -                             int ret;
> >                               ret = get_gate_page(mm, start & PAGE_MASK,
> >                                               gup_flags, &vma,
> >                                               pages ? &pages[i] : NULL);
> >                               if (ret)
> > -                                     return i ? : ret;
> > +                                     goto out;
> >                               ctx.page_mask = 0;
> >                               goto next_page;
> >                       }
>
> This also fixes a potentially leaked dev_pagemap reference count if a
> failure occurs when an iteration crosses a vma boundary. I don't think
> it's normal to have different vma's on a users mapped zone device memory,
> but good to fix anyway.

Does not sound abnormal to me, we should promote this as a fix for the
current cycle with an updated changelog.
