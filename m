Received: by uproxy.gmail.com with SMTP id u40so714325ugc
        for <linux-mm@kvack.org>; Tue, 21 Mar 2006 08:03:05 -0800 (PST)
Message-ID: <bc56f2f0603210803l28145c7dj@mail.gmail.com>
Date: Tue, 21 Mar 2006 11:03:05 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: Re: PATCH][1/8] 2.6.15 mlock: make_pages_wired/unwired
In-Reply-To: <441FEFB4.6050700@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <bc56f2f0603200536scb87a8ck@mail.gmail.com>
	 <441FEFB4.6050700@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We dont account HugeTLB pages for:

1. HugeTLB pages themselves are not reclaimable.

2. If we count HugeTLB pages in "Wired",then we would have no mind
   how many of the "Wired" are HugeTLB pages, and how many are
normal-size pages.
   Thus, hard to get a clear map of physical memory use,for example:
     how many pages are reclaimable?
   If we must count HugeTLB pages,more fields should be added to
"/proc/meminfo",
   for exmaple: "Wired HugeTLB:", "Wired Normal:".

Shaoping Wang

2006/3/21, Nick Piggin <nickpiggin@yahoo.com.au>:
> Stone Wang wrote:
> > 1. Add make_pages_unwired routine.
>
> Unfortunately you forgot wire_page and unwire_page, so this patch will
> not even compile.
>
> > 2. Replace make_pages_present with make_pages_wired, support rollback.
>
> What does support rollback mean?
>
> > 3. Pass 1 more param ("wire") to get_user_pages.
> >
>
> As others have pointed out, wire may be a BSD / other unix thing, but
> it does not feature in Linux memory management terminology. If you
> want to introduce it, you need to do a better job of specifying it.
>
> > Signed-off-by: Shaoping Wang <pwstone@gmail.com>
> >
>
> > +void make_pages_unwired(struct mm_struct *mm,
> > +                                     unsigned long start,unsigned long end)
> > +{
> > +     struct vm_area_struct *vma;
> > +     struct page *page;
> > +     unsigned int foll_flags;
> > +
> > +     foll_flags =0;
> > +
> > +     vma=find_vma(mm,start);
> > +     if(!vma)
> > +             BUG();
> > +     if(is_vm_hugetlb_page(vma))
> > +             return;
> > +
> > +     for(; start<end ; start+=PAGE_SIZE) {
> > +             page=follow_page(vma,start,foll_flags);
> > +             if(page)
> > +                     unwire_page(page);
> > +     }
> > +}
> > +
>
> What happens when start goes past vma->vm_end?
>
> >  int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> > -             unsigned long start, int len, int write, int force,
> > +             unsigned long start, int len, int write,int force, int wire,
> >               struct page **pages, struct vm_area_struct **vmas)
> >  {
> >       int i;
> > @@ -973,6 +995,7 @@
> >               if (!vma && in_gate_area(tsk, start)) {
> >                       unsigned long pg = start & PAGE_MASK;
> >                       struct vm_area_struct *gate_vma = get_gate_vma(tsk);
> > +                     struct page *page;
> >                       pgd_t *pgd;
> >                       pud_t *pud;
> >                       pmd_t *pmd;
> > @@ -994,6 +1017,7 @@
> >                               pte_unmap(pte);
> >                               return i ? : -EFAULT;
> >                       }
> > +                     page = vm_normal_page(gate_vma, start, *pte);
>
> You wire gate_vma pages? But it doesn't look like you can unwire them with
> make_pages_unwired.
>
> >                       if (pages) {
> >                               struct page *page = vm_normal_page(gate_vma, start, *pte);
>
> This can go now?
>
> >                               pages[i] = page;
> > @@ -1003,9 +1027,12 @@
> >                       pte_unmap(pte);
> >                       if (vmas)
> >                               vmas[i] = gate_vma;
> > +                     if(wire)
> > +                             wire_page(page);
> >                       i++;
> >                       start += PAGE_SIZE;
> >                       len--;
> > +
> >                       continue;
> >               }
> >
> > @@ -1013,6 +1040,7 @@
> >                               || !(vm_flags & vma->vm_flags))
> >                       return i ? : -EFAULT;
> >
> > +             /* We dont account wired HugeTLB pages */
>
> You don't account wired HugeTLB pages? If you can wire them you should be able
> to unwire them as well shouldn't you?
>
> --
> SUSE Labs, Novell Inc.
>
> Send instant messages to your online friends http://au.messenger.yahoo.com
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
