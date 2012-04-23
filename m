Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 516A96B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 19:15:09 -0400 (EDT)
Received: by iajr24 with SMTP id r24so143463iaj.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 16:15:08 -0700 (PDT)
Date: Mon, 23 Apr 2012 16:15:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] thp, memcg: split hugepage for memcg oom on cow
In-Reply-To: <20120411142023.GB1789@redhat.com>
Message-ID: <alpine.DEB.2.00.1204231612060.17030@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com> <4F838385.9070309@jp.fujitsu.com> <alpine.DEB.2.00.1204092241180.27689@chino.kir.corp.google.com> <alpine.DEB.2.00.1204092242050.27689@chino.kir.corp.google.com>
 <20120411142023.GB1789@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Wed, 11 Apr 2012, Johannes Weiner wrote:

> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -950,6 +950,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		count_vm_event(THP_FAULT_FALLBACK);
> >  		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
> >  						   pmd, orig_pmd, page, haddr);
> > +		if (ret & VM_FAULT_OOM)
> > +			split_huge_page(page);
> >  		put_page(page);
> >  		goto out;
> >  	}
> > @@ -957,6 +959,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  
> >  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> >  		put_page(new_page);
> > +		split_huge_page(page);
> >  		put_page(page);
> >  		ret |= VM_FAULT_OOM;
> >  		goto out;
> > diff --git a/mm/memory.c b/mm/memory.c
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3489,6 +3489,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	if (unlikely(is_vm_hugetlb_page(vma)))
> >  		return hugetlb_fault(mm, vma, address, flags);
> >  
> > +retry:
> >  	pgd = pgd_offset(mm, address);
> >  	pud = pud_alloc(mm, pgd, address);
> >  	if (!pud)
> > @@ -3502,13 +3503,24 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  							  pmd, flags);
> >  	} else {
> >  		pmd_t orig_pmd = *pmd;
> > +		int ret;
> > +
> >  		barrier();
> >  		if (pmd_trans_huge(orig_pmd)) {
> >  			if (flags & FAULT_FLAG_WRITE &&
> >  			    !pmd_write(orig_pmd) &&
> > -			    !pmd_trans_splitting(orig_pmd))
> > -				return do_huge_pmd_wp_page(mm, vma, address,
> > -							   pmd, orig_pmd);
> > +			    !pmd_trans_splitting(orig_pmd)) {
> > +				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
> > +							  orig_pmd);
> > +				/*
> > +				 * If COW results in an oom, the huge pmd will
> > +				 * have been split, so retry the fault on the
> > +				 * pte for a smaller charge.
> > +				 */
> > +				if (unlikely(ret & VM_FAULT_OOM))
> > +					goto retry;
> 
> Can you instead put a __split_huge_page_pmd(mm, pmd) here?  It has to
> redo the get-page-ref-through-pagetable dance, but it's more robust
> and obvious than splitting the COW page before returning OOM in the
> thp wp handler.
> 

I agree it's more robust if do_huge_pmd_wp_page() were modified later and 
mistakenly returned VM_FAULT_OOM without the page being split, but 
__split_huge_page_pmd() has the drawback of also requiring to retake 
mm->page_table_lock to test whether orig_pmd is still legitimate so it 
will be slower.  Do you feel strongly about the way it's currently written 
which will be faster at runtime?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
