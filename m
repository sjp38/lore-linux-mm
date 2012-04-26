Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 4A7CB6B00E7
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 05:06:50 -0400 (EDT)
Date: Thu, 26 Apr 2012 11:06:42 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch v2] thp, memcg: split hugepage for memcg oom on cow
Message-ID: <20120426090642.GC1791@redhat.com>
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com>
 <4F838385.9070309@jp.fujitsu.com>
 <alpine.DEB.2.00.1204092241180.27689@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1204092242050.27689@chino.kir.corp.google.com>
 <20120411142023.GB1789@redhat.com>
 <alpine.DEB.2.00.1204231612060.17030@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204231612060.17030@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

[ Sorry, my responsiveness is horrible these days... ]

On Mon, Apr 23, 2012 at 04:15:06PM -0700, David Rientjes wrote:
> On Wed, 11 Apr 2012, Johannes Weiner wrote:
> 
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -950,6 +950,8 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  		count_vm_event(THP_FAULT_FALLBACK);
> > >  		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
> > >  						   pmd, orig_pmd, page, haddr);
> > > +		if (ret & VM_FAULT_OOM)
> > > +			split_huge_page(page);
> > >  		put_page(page);
> > >  		goto out;
> > >  	}
> > > @@ -957,6 +959,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  
> > >  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> > >  		put_page(new_page);
> > > +		split_huge_page(page);
> > >  		put_page(page);
> > >  		ret |= VM_FAULT_OOM;
> > >  		goto out;
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -3489,6 +3489,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  	if (unlikely(is_vm_hugetlb_page(vma)))
> > >  		return hugetlb_fault(mm, vma, address, flags);
> > >  
> > > +retry:
> > >  	pgd = pgd_offset(mm, address);
> > >  	pud = pud_alloc(mm, pgd, address);
> > >  	if (!pud)
> > > @@ -3502,13 +3503,24 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  							  pmd, flags);
> > >  	} else {
> > >  		pmd_t orig_pmd = *pmd;
> > > +		int ret;
> > > +
> > >  		barrier();
> > >  		if (pmd_trans_huge(orig_pmd)) {
> > >  			if (flags & FAULT_FLAG_WRITE &&
> > >  			    !pmd_write(orig_pmd) &&
> > > -			    !pmd_trans_splitting(orig_pmd))
> > > -				return do_huge_pmd_wp_page(mm, vma, address,
> > > -							   pmd, orig_pmd);
> > > +			    !pmd_trans_splitting(orig_pmd)) {
> > > +				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
> > > +							  orig_pmd);
> > > +				/*
> > > +				 * If COW results in an oom, the huge pmd will
> > > +				 * have been split, so retry the fault on the
> > > +				 * pte for a smaller charge.
> > > +				 */
> > > +				if (unlikely(ret & VM_FAULT_OOM))
> > > +					goto retry;
> > 
> > Can you instead put a __split_huge_page_pmd(mm, pmd) here?  It has to
> > redo the get-page-ref-through-pagetable dance, but it's more robust
> > and obvious than splitting the COW page before returning OOM in the
> > thp wp handler.
> 
> I agree it's more robust if do_huge_pmd_wp_page() were modified later and 
> mistakenly returned VM_FAULT_OOM without the page being split, but 
> __split_huge_page_pmd() has the drawback of also requiring to retake 
> mm->page_table_lock to test whether orig_pmd is still legitimate so it 
> will be slower.  Do you feel strongly about the way it's currently written 
> which will be faster at runtime?

If you can't accomodate for a hugepage, this code runs 511 times in
the worst case before you also can't fit a regular page anymore.  And
compare it to the cost of the splitting itself and the subsequent 4k
COW break faults...

I don't think it's a path worth optimizing for at all, especially if
it includes sprinkling undocumented split_huge_pages around, and the
fix could be as self-contained as something like this...

diff --git a/mm/memory.c b/mm/memory.c
index 706a274..dae0afc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3505,14 +3505,29 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 							  pmd, flags);
 	} else {
 		pmd_t orig_pmd = *pmd;
+		int ret;
+
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
 			if (flags & FAULT_FLAG_WRITE &&
 			    !pmd_write(orig_pmd) &&
-			    !pmd_trans_splitting(orig_pmd))
-				return do_huge_pmd_wp_page(mm, vma, address,
+			    !pmd_trans_splitting(orig_pmd)) {
+				ret = do_huge_pmd_wp_page(mm, vma, address,
 							   pmd, orig_pmd);
-			return 0;
+				if (unlikely(ret & VM_FAULT_OOM)) {
+					/*
+					 * It's not worth going OOM
+					 * over not being able to
+					 * allocate or charge a full
+					 * copy of the huge page.
+					 * Split it up and handle as
+					 * single page COW break below.
+					 */
+					__split_huge_page_pmd(mm, pmd);
+				} else
+					return ret;
+			} else
+				return 0;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
