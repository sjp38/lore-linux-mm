Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3EA6B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 15:50:43 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id p61so5189108wes.41
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 12:50:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gc5si1086471wjb.83.2014.03.31.12.50.40
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 12:50:41 -0700 (PDT)
Date: Mon, 31 Mar 2014 15:50:20 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5339c711.4568c20a.7772.64b0SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140331123740.1007bf1b67ad635495426cce@linux-foundation.org>
References: <533930a1.W68d+/5S+SyV5Fsf%fengguang.wu@intel.com>
 <53397020.435fe00a.5cb4.32f9SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140331123740.1007bf1b67ad635495426cce@linux-foundation.org>
Subject: Re: [next:master 114/486] fs/proc/task_mmu.c:1120:31: error:
 'pagemap_hugetlb' undeclared
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, kbuild-all@01.org

Hi,

On Mon, Mar 31, 2014 at 12:37:40PM -0700, Andrew Morton wrote:
> On Mon, 31 Mar 2014 09:39:37 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > On Mon, Mar 31, 2014 at 05:08:49PM +0800, kbuild test robot wrote:
> > > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > > head:   8a896813a328f23aeee5f56d3139361534796636
> > > commit: 64aa967f459ba0bb91ea8b127c9bd586db1beabc [114/486] pagemap: redefine callback functions for page table walker
> > > config: x86_64-randconfig-br2-03311043 (attached as .config)
> > > 
> > > Note: the next/master HEAD 8a896813a328f23aeee5f56d3139361534796636 builds fine.
> > >       It only hurts bisectibility.
> > > 
> > > All error/warnings:
> > > 
> > >    fs/proc/task_mmu.c: In function 'pagemap_read':
> > > >> fs/proc/task_mmu.c:1120:31: error: 'pagemap_hugetlb' undeclared (first use in this function)
> > >      pagemap_walk.hugetlb_entry = pagemap_hugetlb;
> > >                                   ^
> > >    fs/proc/task_mmu.c:1120:31: note: each undeclared identifier is reported only once for each function it appears in
> > >    fs/proc/task_mmu.c: At top level:
> > >    fs/proc/task_mmu.c:1025:12: warning: 'pagemap_hugetlb_range' defined but not used [-Wunused-function]
> > >     static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
> > >                ^
> > 
> > pagemap_hugetlb_range() should be renamed to pagemap_hugetlb() at 64aa967f459b
> > ("pagemap: redefine callback functions for page table walker"), while it is
> > currently done by dc86a8715d79 ("pagewalk: remove argument hmask from
> > hugetlb_entry()") afterward like below:
> > 
> > @@ -1022,8 +1022,7 @@ static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *
> >  }
> >  
> >  /* This function walks within one hugetlb entry in the single call */
> > -static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
> > -				 unsigned long addr, unsigned long end,
> > +static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
> >  				 struct mm_walk *walk)
> >  {
> >  	struct pagemapread *pm = walk->private;
> > 
> > Obviously, dc86a8715d79 should only remove hmask.
> > Sorry for my poor patch separation.
> 
> It gets messy.  I tried this
> pagemap-redefine-callback-functions-for-page-table-walker-fix.patch:
> 
> 
> --- a/fs/proc/task_mmu.c~pagemap-redefine-callback-functions-for-page-table-walker-fix
> +++ a/fs/proc/task_mmu.c
> @@ -1022,15 +1022,15 @@ static void huge_pte_to_pagemap_entry(pa
>  }
>  
>  /* This function walks within one hugetlb entry in the single call */
> -static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
> -				 unsigned long addr, unsigned long end,
> -				 struct mm_walk *walk)
> +static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
> +			   struct mm_walk *walk)

We can't remove hmask here, because the number of arguments of callback
hugetlb_entry() in struct mm_walk is not changed at this patch.
Just renaming in pagemap-redefine-callback-functions-for-page-table-walker-fix.patch
is fine.

Thanks,
Naoya Horiguchi

>  {
>  	struct pagemapread *pm = walk->private;
>  	struct vm_area_struct *vma = walk->vma;
>  	int err = 0;
>  	int flags2;
>  	pagemap_entry_t pme;
> +	unsigned long hmask;
>  
>  	WARN_ON_ONCE(!vma);
>  
> 
> and got 
> 
> fs/proc/task_mmu.c: In function 'pagemap_read':
> fs/proc/task_mmu.c:1120: warning: assignment from incompatible pointer type
> 
> from
> 
> #ifdef CONFIG_HUGETLB_PAGE
>         pagemap_walk.hugetlb_entry = pagemap_hugetlb;
> #endif
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
