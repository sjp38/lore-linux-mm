Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 89BF45F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 18:45:19 -0400 (EDT)
Date: Wed, 8 Apr 2009 06:45:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 02/14] mm: fix major/minor fault accounting on retried
	fault
Message-ID: <20090407224545.GA5607@localhost>
References: <20090407071729.233579162@intel.com> <20090407072132.943283183@intel.com> <604427e00904071258y78eea757m6d95d08deec49450@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <604427e00904071258y78eea757m6d95d08deec49450@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 08, 2009 at 03:58:16AM +0800, Ying Han wrote:
> On Tue, Apr 7, 2009 at 12:17 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > VM_FAULT_RETRY does make major/minor faults accounting a bit twisted..
> >
> > Cc: Ying Han <yinghan@google.com>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  arch/x86/mm/fault.c |    2 ++
> >  mm/memory.c         |   22 ++++++++++++++--------
> >  2 files changed, 16 insertions(+), 8 deletions(-)
> >
> > --- mm.orig/arch/x86/mm/fault.c
> > +++ mm/arch/x86/mm/fault.c
> > @@ -1160,6 +1160,8 @@ good_area:
> >        if (fault & VM_FAULT_RETRY) {
> >                if (retry_flag) {
> >                        retry_flag = 0;
> > +                       tsk->maj_flt++;
> > +                       tsk->min_flt--;
> >                        goto retry;
> >                }
> >                BUG();
> sorry, little bit confuse here. are we assuming the retry path will
> return min_flt as always?

Sure - except for some really exceptional ftruncate cases.
The page was there ready, and we'll retry immediately.

maj_flt/min_flt are not _exact_ numbers by their nature, so 99.9%
accuracy shall be fine.

Thanks,
Fengguang

> > --- mm.orig/mm/memory.c
> > +++ mm/mm/memory.c
> > @@ -2882,26 +2882,32 @@ int handle_mm_fault(struct mm_struct *mm
> >        pud_t *pud;
> >        pmd_t *pmd;
> >        pte_t *pte;
> > +       int ret;
> >
> >        __set_current_state(TASK_RUNNING);
> >
> > -       count_vm_event(PGFAULT);
> > -
> > -       if (unlikely(is_vm_hugetlb_page(vma)))
> > -               return hugetlb_fault(mm, vma, address, write_access);
> > +       if (unlikely(is_vm_hugetlb_page(vma))) {
> > +               ret = hugetlb_fault(mm, vma, address, write_access);
> > +               goto out;
> > +       }
> >
> > +       ret = VM_FAULT_OOM;
> >        pgd = pgd_offset(mm, address);
> >        pud = pud_alloc(mm, pgd, address);
> >        if (!pud)
> > -               return VM_FAULT_OOM;
> > +               goto out;
> >        pmd = pmd_alloc(mm, pud, address);
> >        if (!pmd)
> > -               return VM_FAULT_OOM;
> > +               goto out;
> >        pte = pte_alloc_map(mm, pmd, address);
> >        if (!pte)
> > -               return VM_FAULT_OOM;
> > +               goto out;
> >
> > -       return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> > +       ret = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> > +out:
> > +       if (!(ret & VM_FAULT_RETRY))
> > +               count_vm_event(PGFAULT);
> > +       return ret;
> >  }
> >
> >  #ifndef __PAGETABLE_PUD_FOLDED
> >
> > --
> >
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
