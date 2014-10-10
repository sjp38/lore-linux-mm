Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 05C7F6B0038
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 21:37:06 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so713095pdb.30
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 18:37:06 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id zg1si2140791pbc.101.2014.10.09.18.37.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Oct 2014 18:37:05 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so740546pab.20
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 18:37:04 -0700 (PDT)
Date: Fri, 10 Oct 2014 17:33:50 +0800
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: Re: [PATCH] smaps should deal with huge zero page exactly same as
 normal zero page
Message-ID: <20141010093302.GA25038@gmail.com>
References: <CADUXgx7QTWBMxesxgCet5rjpGu-V-xK_-5f2rX9R+v-ggi902A@mail.gmail.com>
 <5436B98E.1070407@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5436B98E.1070407@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, fengguang.wu@intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Oct 09, 2014 at 09:36:30AM -0700, Dave Hansen wrote:
> On 10/09/2014 02:19 AM, Fengwei Yin wrote:
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 80ca4fb..8550b27 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -476,7 +476,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
> >  			mss->nonlinear += ptent_size;
> >  	}
> >  
> > -	if (!page)
> > +	if (!page || is_huge_zero_page(page))
> >  		return;
> 
> This really seems like a bit of a hack.  A normal (small) zero page
> won't make it to this point because of the vm_normal_page() check in
> smaps_pte_entry() which hits the _PAGE_SPECIAL bit in the pte.
> 
> Is there a reason we can't set _PAGE_SPECIAL on the huge_zero_page ptes?
>  If we did that, we wouldn't need a special case here.
> 
> If we can't do that for some reason, can we at least teach
> vm_normal_page() about the huge_zero_page in some other way?
> 
Thanks a lot for the comments. I will check whether could remove the
hack.

> >  	if (PageAnon(page))
> > @@ -516,7 +516,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >  	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
> >  		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
> >  		spin_unlock(ptl);
> > -		mss->anonymous_thp += HPAGE_PMD_SIZE;
> > +		if (!is_huge_zero_pmd(*pmd))
> > +			mss->anonymous_thp += HPAGE_PMD_SIZE;
> >  		return 0;
> >  	}
> 
> How about we just move this hunk in to smaps_pte_entry()?  Something
> along these lines:
> 
> ...
>         if (PageAnon(page)) {
>                 mss->anonymous += ptent_size;
> +		if (PageTransHuge(page))
> +			mss->anonymous_thp += ptent_size;
> 	}
> 
> If we do that, plus teaching vm_normal_page() about huge_zero_pages, it
> will help keep the hacks and the extra code due to huge pages to a miniumum.
> 
> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > index 63579cb..758f569 100644
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -34,6 +34,10 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >  			unsigned long addr, pgprot_t newprot,
> >  			int prot_numa);
> >  
> > +extern bool is_huge_zero_page(struct page *page);
> > +
> > +extern bool is_huge_zero_pmd(pmd_t pmd);
> > +
> >  enum transparent_hugepage_flag {
> >  	TRANSPARENT_HUGEPAGE_FLAG,
> >  	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index d9a21d06..bedc3ae 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -173,12 +173,12 @@ static int start_khugepaged(void)
> >  static atomic_t huge_zero_refcount;
> >  static struct page *huge_zero_page __read_mostly;
> >  
> > -static inline bool is_huge_zero_page(struct page *page)
> > +bool is_huge_zero_page(struct page *page)
> >  {
> >  	return ACCESS_ONCE(huge_zero_page) == page;
> >  }
> >  
> > -static inline bool is_huge_zero_pmd(pmd_t pmd)
> > +bool is_huge_zero_pmd(pmd_t pmd)
> >  {
> >  	return is_huge_zero_page(pmd_page(pmd));
> >  }
> 
> ^^^ And all these exports.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
