Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8566B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 22:34:03 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so355748pdb.39
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 19:34:03 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id p8si13606023pds.217.2014.10.14.19.34.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 19:34:02 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so391524pab.6
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 19:34:01 -0700 (PDT)
Date: Wed, 15 Oct 2014 18:30:38 +0800
From: Fengwei Yin <yfw.kernel@gmail.com>
Subject: Re: [PATCH] smaps should deal with huge zero page exactly same as
 normal zero page
Message-ID: <20141015102959.GA14583@gmail.com>
References: <CADUXgx7QTWBMxesxgCet5rjpGu-V-xK_-5f2rX9R+v-ggi902A@mail.gmail.com>
 <5436B98E.1070407@intel.com>
 <20141010132027.GB25038@gmail.com>
 <20141014115730.GB6524@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="jho1yZJdad60DJr+"
Content-Disposition: inline
In-Reply-To: <20141014115730.GB6524@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, fengguang.wu@intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>


--jho1yZJdad60DJr+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 14, 2014 at 02:57:30PM +0300, Kirill A. Shutemov wrote:
> On Fri, Oct 10, 2014 at 09:21:08PM +0800, Fengwei Yin wrote:
> > On Thu, Oct 09, 2014 at 09:36:30AM -0700, Dave Hansen wrote:
> > > On 10/09/2014 02:19 AM, Fengwei Yin wrote:
> > > > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > > > index 80ca4fb..8550b27 100644
> > > > --- a/fs/proc/task_mmu.c
> > > > +++ b/fs/proc/task_mmu.c
> > > > @@ -476,7 +476,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
> > > >  			mss->nonlinear += ptent_size;
> > > >  	}
> > > >  
> > > > -	if (!page)
> > > > +	if (!page || is_huge_zero_page(page))
> > > >  		return;
> > > 
> > > This really seems like a bit of a hack.  A normal (small) zero page
> > > won't make it to this point because of the vm_normal_page() check in
> > > smaps_pte_entry() which hits the _PAGE_SPECIAL bit in the pte.
> > > 
> > > Is there a reason we can't set _PAGE_SPECIAL on the huge_zero_page ptes?
> > >  If we did that, we wouldn't need a special case here.
> > > 
> > > If we can't do that for some reason, can we at least teach
> > > vm_normal_page() about the huge_zero_page in some other way?
> > I suppose _PAGE_SPECIAL can't work. Two reasons:
> > 1. Not all arch have HAVE_PTE_SPECIAL set. So always need another way to
> >    handle the arch which has no PTE_SPECIAL.
> > 2. _PAGE_SPECIAL is just for PTE now. If want to add it for huge page,
> >    we need to introduce pmd_mkspecial() thing which I don't think it's
> >    worth to do now (unless you want it. :)).
> > 
> > Yes. We could move the check to vm_normal_page(). But it still needs
> > export functions from huge_memory.c.
> > 
> > Please check the new patch.
> > 
> > > 
> > > >  	if (PageAnon(page))
> > > > @@ -516,7 +516,8 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> > > >  	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
> > > >  		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
> > > >  		spin_unlock(ptl);
> > > > -		mss->anonymous_thp += HPAGE_PMD_SIZE;
> > > > +		if (!is_huge_zero_pmd(*pmd))
> > > > +			mss->anonymous_thp += HPAGE_PMD_SIZE;
> > > >  		return 0;
> > > >  	}
> > > 
> > > How about we just move this hunk in to smaps_pte_entry()?  Something
> > > along these lines:
> > > 
> > > ...
> > >         if (PageAnon(page)) {
> > >                 mss->anonymous += ptent_size;
> > > +		if (PageTransHuge(page))
> > > +			mss->anonymous_thp += ptent_size;
> > > 	}
> > Done.
> > > 
> > > If we do that, plus teaching vm_normal_page() about huge_zero_pages, it
> > > will help keep the hacks and the extra code due to huge pages to a miniumum.
> > > 
> > > > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > > > index 63579cb..758f569 100644
> > > > --- a/include/linux/huge_mm.h
> > > > +++ b/include/linux/huge_mm.h
> > > > @@ -34,6 +34,10 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> > > >  			unsigned long addr, pgprot_t newprot,
> > > >  			int prot_numa);
> > > >  
> > > > +extern bool is_huge_zero_page(struct page *page);
> > > > +
> > > > +extern bool is_huge_zero_pmd(pmd_t pmd);
> > > > +
> > > >  enum transparent_hugepage_flag {
> > > >  	TRANSPARENT_HUGEPAGE_FLAG,
> > > >  	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > index d9a21d06..bedc3ae 100644
> > > > --- a/mm/huge_memory.c
> > > > +++ b/mm/huge_memory.c
> > > > @@ -173,12 +173,12 @@ static int start_khugepaged(void)
> > > >  static atomic_t huge_zero_refcount;
> > > >  static struct page *huge_zero_page __read_mostly;
> > > >  
> > > > -static inline bool is_huge_zero_page(struct page *page)
> > > > +bool is_huge_zero_page(struct page *page)
> > > >  {
> > > >  	return ACCESS_ONCE(huge_zero_page) == page;
> > > >  }
> > > >  
> > > > -static inline bool is_huge_zero_pmd(pmd_t pmd)
> > > > +bool is_huge_zero_pmd(pmd_t pmd)
> > > >  {
> > > >  	return is_huge_zero_page(pmd_page(pmd));
> > > >  }
> > > 
> > > ^^^ And all these exports.
> > 
> > A new function is_huge_zero_pfn() is added to mm/huge_memory.c
> > and exported.
> > 
> > Thanks.
> 
> > From 4e7bdd5bc22874175982ab50303eab32843c753c Mon Sep 17 00:00:00 2001
> > From: Fengwei Yin <yfw.kernel@gmail.com>
> > Date: Thu, 9 Oct 2014 22:20:58 +0800
> > Subject: [PATCH] smaps should deal with huge zero page exactly same as normal
> >  zero page.
> > 
> 
> Description?
> 
> > Signed-off-by: Fengwei Yin <yfw.kernel@gmail.com>
> > ---
> >  fs/proc/task_mmu.c      | 6 ++++--
> >  include/linux/huge_mm.h | 2 ++
> >  mm/huge_memory.c        | 5 +++++
> >  mm/memory.c             | 4 ++++
> >  4 files changed, 15 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index c341568..fb19c0c 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -471,8 +471,11 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
> >  	if (!page)
> >  		return;
> >  
> > -	if (PageAnon(page))
> > +	if (PageAnon(page)) {
> >  		mss->anonymous += ptent_size;
> > +		if (PageTransHuge(page))
> > +			mss->anonymous_thp += HPAGE_PMD_SIZE;
> > +	}
> >  
> >  	if (page->index != pgoff)
> >  		mss->nonlinear += ptent_size;
> > @@ -508,7 +511,6 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >  	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
> >  		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
> >  		spin_unlock(ptl);
> > -		mss->anonymous_thp += HPAGE_PMD_SIZE;
> >  		return 0;
> >  	}
> >  
> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > index 63579cb..9bf6263 100644
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -34,6 +34,8 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >  			unsigned long addr, pgprot_t newprot,
> >  			int prot_numa);
> >  
> > +extern bool is_huge_zero_pfn(unsigned long pfn);
> > +
> >  enum transparent_hugepage_flag {
> >  	TRANSPARENT_HUGEPAGE_FLAG,
> >  	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index f8ffd94..71ca4ed 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -183,6 +183,11 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
> >  	return is_huge_zero_page(pmd_page(pmd));
> >  }
> >  
> > +inline bool is_huge_zero_pfn(unsigned long pfn)
> 
> There's no way the function can be inlined.
> 
> Otherwise looks good to me.
> 
Thanks a lot for the comments. Updated patch attached.
> -- 
>  Kirill A. Shutemov

--jho1yZJdad60DJr+
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-smaps-should-deal-with-huge-zero-page-exactly-same-a.patch"


--jho1yZJdad60DJr+--
