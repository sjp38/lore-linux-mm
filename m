Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35EE38E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 07:07:31 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id a26-v6so3265981lfi.20
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 04:07:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j13-v6sor8640893lfb.46.2018.09.21.04.07.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 04:07:29 -0700 (PDT)
MIME-Version: 1.0
References: <20180920202316.GA6038@jordon-HP-15-Notebook-PC> <CANiq72kQA45ekbSruh-zTsc9B-9EOxZna=cOgOcM7--owxrWsA@mail.gmail.com>
In-Reply-To: <CANiq72kQA45ekbSruh-zTsc9B-9EOxZna=cOgOcM7--owxrWsA@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 21 Sep 2018 16:37:16 +0530
Message-ID: <CAFqt6zYtptZNeXbJwcJemb5O8rKjcB9=FpfiH60wK9v6vd0A2A@mail.gmail.com>
Subject: Re: [PATCH] auxdisplay/cfag12864bfb.c: Replace vm_insert_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 21, 2018 at 2:56 AM Miguel Ojeda
<miguel.ojeda.sandonis@gmail.com> wrote:
>
> On Thu, Sep 20, 2018 at 10:23 PM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> > There is a plan to remove vm_insert_page permanently
> > and replace it with new API vmf_insert_page which will
> > return vm_fault_t type. As part of it vm_insert_page
> > is removed from this driver.
>
> A link to the discussion/plan would be nice. The commit 1c8f422059ae5
> ("mm: change return type to vm_fault_t") explains a bit, but has a
> broken link :( Googling for the stuff returns many of the patches, but
> not the actual discussion...

This might be helpful.
https://marc.info/?l=linux-mm&m=152054772413234&w=4
>
> >  static int cfag12864bfb_mmap(struct fb_info *info, struct vm_area_struct *vma)
> >  {
> > -       return vm_insert_page(vma, vma->vm_start,
> > -               virt_to_page(cfag12864b_buffer));
> > +       struct page *page;
> > +       unsigned long size = vma->vm_end - vma->vm_start;
> > +
> > +       page = virt_to_page(cfag12864b_buffer);
> > +       return remap_pfn_range(vma, vma->vm_start, page_to_pfn(page),
> > +                               size, vma->vm_page_prot);
>
> I am out of the loop on these mm changes, so please indulge me, but:
>
>   * Why is there no documentation on vmf_insert_page() while
> vm_insert_page() had it? (specially since it seems you want to remove
> vm_insert_page()).

The plan is to convert vm_insert_{page,pfn,mixed} to
vmf_insert_{page,pfn,mixed}. As a good intermediate
steps inline wrapper vmf_insert_{pfn,page,mixed} are
introduced. After all the drivers converted, we will convert
vm_insert_page to vmf_insert_page and remove the inline
wrapper and update the document at the same time.

>
>   * Shouldn't we have a simple remap_page() or remap_kernel_page() to
> fit this use case and avoid that dance? (another driver in auxdisplay
> will require the same change, and I guess others in the kernel as
> well).


There are few drivers similar like auxdisplay where straight forward
conversion from vm_insert_page to vmf_insert_page is not possible.

So I mapped the kernel memory to user vma using remap_pfn_range
and remove vm_insert_page in this driver.

Other way, is to replace vm_insert_page with vmf_insert_page() and
then convert VM_FAULT_CODE back to errno. But as part of vm_fault_t
migration we have already removed/cleanup most the errno to VM_FAULT_CODE
mapping from drivers. So I prefer not to take this option.

Third, we can introduce a similar API like vm_insert_page say,
vm_insert_kmem_page() and use it for same scenarios like this.

If there is a better way to do this, we can discuss it.
