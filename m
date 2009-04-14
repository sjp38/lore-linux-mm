Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 482E35F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 05:18:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E9JBUE008855
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 18:19:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD86845DD7E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 18:19:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EADE45DD7D
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 18:19:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 738811DB803E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 18:19:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BB7C1DB803C
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 18:19:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/6] IO pinning(get_user_pages()) vs fork race fix
In-Reply-To: <200904141841.50397.nickpiggin@yahoo.com.au>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <200904141841.50397.nickpiggin@yahoo.com.au>
Message-Id: <20090414175525.C67C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 18:19:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

> > but, it isn't true. mmap_sem isn't only used for vma traversal, but also prevent vs-fork race.
> > up_read(mmap_sem) mean end of critical section, IOW after up_read() code is fork unsafe.
> > (access_process_vm() explain proper get_user_pages() usage)
> > 
> > Oh well, We have many wrong caller now. What is the best fix method?
> 
> What indeed...

Yes. semantics change vs many caller change is one of most important point
in this discussion.
I hope all related person reach the same conclusion.



> > Nick, This version fixed vmsplice and aio issue (you pointed). I hope to hear your opiniton ;)
> 
> I don't see how it fixes vmsplice? vmsplice can get_user_pages pages from one
> process's address space and put them into a pipe, and they are released by
> another process after consuming the pages I think. So it's fairly hard to hold
> a lock over this.

I recognize my explanation is poor.

firstly, pipe_to_user() via vmsplice_to_user use copy_to_user. then we don't need care
receive side.
secondly, get_iovec_page_array() via vmsplice_to_pipe() use gup(read).
then we only need prevent to change the page.

I changed reuse_swap_page() at [1/6]. then if any process touch the page while
the process isn't recived yet, it makes COW break and toucher get copyed page.
then, Anybody can't change original page.

Thus, This patch series also fixes vmsplice issue, I think.
Am I missing anything?

> I guess apart from the vmsplice issue (unless I missed a clever fix), I guess
> this *does* work. I can't see any races... I'd really still like to hear a good
> reason why my proposed patch is so obviously crap.
> 
> Reasons proposed so far:
> "No locking" (I think this is a good thing; no *bugs* have been pointed out)
> "Too many page flags" (but it only uses 1 anon page flag, only fs pagecache
> has a flags shortage so we can easily overload a pagecache flag)
> "Diffstat too large" (seems comparable when you factor in the fixes to callers,
> but has the advantage of being contained within VM subsystem)
> "Horrible code" (I still don't see it. Of course the code will be nicer if we
> don't fix the issue _at all_, but I don't see this is so much worse than having
> to fix callers.)

Honestly, I don't dislike your.
but I really hope to fix this bug. if someone nak your patch, I'll seek another way.



> FWIW, I have attached my patch again (with simple function-movement hunks
> moved into another patch so it is easier to see real impact of this patch).

OK. I try to test your patch too.


 - kosaki

> 
> 
> > ChangeLog:
> >   V2 -> V3
> >    o remove early decow logic
> >    o introduce prevent unmap logic
> >    o fix nfs-directio
> >    o fix aio
> >    o fix bio (only bandaid fix)
> > 
> >   V1 -> V2
> >    o fix aio+dio case
> > 
> > TODO
> >   o implement down_write_killable()
> >   o fix kvm (need?)
> >   o fix get_arg_page() (Why this function don't use mmap_sem?)
> 
> Probably someone was shooting for a crazy optimisation because no other
> threads should be able to access this mm yet :)
> 
> Anyway, this is my proposal. It has the advantage that it fixes every
> caller in the tree.
> 
> ---
>  arch/powerpc/mm/gup.c      |    2 
>  arch/x86/mm/gup.c          |    3 
>  include/linux/mm.h         |    2 
>  include/linux/page-flags.h |    5 +
>  kernel/fork.c              |    2 
>  mm/memory.c                |  178 +++++++++++++++++++++++++++++++++++++++------
>  6 files changed, 167 insertions(+), 25 deletions(-)
> 
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -791,7 +791,7 @@ int walk_page_range(unsigned long addr,
>  void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
>  		unsigned long end, unsigned long floor, unsigned long ceiling);
>  int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
> -			struct vm_area_struct *vma);
> +		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma);
>  void unmap_mapping_range(struct address_space *mapping,
>  		loff_t const holebegin, loff_t const holelen, int even_cows);
>  int follow_phys(struct vm_area_struct *vma, unsigned long address,
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -601,12 +601,103 @@ void zap_pte(struct mm_struct *mm, struc
>  	}
>  }
>  /*
> + * breaks COW of child pte that has been marked COW by fork().
> + * Must be called with the child's ptl held and pte mapped.
> + * Returns 0 on success with ptl held and pte mapped.
> + * -ENOMEM on OOM failure, or -EAGAIN if something changed under us.
> + * ptl dropped and pte unmapped on error cases.
> + */
> +static noinline int decow_one_pte(struct mm_struct *mm, pte_t *ptep, pmd_t *pmd,
> +			spinlock_t *ptl, struct vm_area_struct *vma,
> +			unsigned long address)
> +{
> +	pte_t pte = *ptep;
> +	struct page *page, *new_page;
> +	int ret;
> +
> +	BUG_ON(!pte_present(pte));
> +	BUG_ON(pte_write(pte));
> +
> +	page = vm_normal_page(vma, address, pte);
> +	BUG_ON(!page);
> +	BUG_ON(!PageAnon(page));
> +	BUG_ON(!PageDontCOW(page));
> +
> +	/* The following code comes from do_wp_page */
> +	page_cache_get(page);
> +	pte_unmap_unlock(pte, ptl);
> +
> +	if (unlikely(anon_vma_prepare(vma)))
> +		goto oom;
> +	VM_BUG_ON(page == ZERO_PAGE(0));
> +	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> +	if (!new_page)
> +		goto oom;
> +	/*
> +	 * Don't let another task, with possibly unlocked vma,
> +	 * keep the mlocked page.
> +	 */
> +	if (vma->vm_flags & VM_LOCKED) {
> +		lock_page(page);	/* for LRU manipulation */
> +		clear_page_mlock(page);
> +		unlock_page(page);
> +	}
> +	cow_user_page(new_page, page, address, vma);
> +	__SetPageUptodate(new_page);
> +
> +	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
> +		goto oom_free_new;
> +
> +	/*
> +	 * Re-check the pte - we dropped the lock
> +	 */
> +	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	if (pte_same(*ptep, pte)) {
> +		pte_t entry;
> +
> +		flush_cache_page(vma, address, pte_pfn(pte));
> +		entry = mk_pte(new_page, vma->vm_page_prot);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		/*
> +		 * Clear the pte entry and flush it first, before updating the
> +		 * pte with the new entry. This will avoid a race condition
> +		 * seen in the presence of one thread doing SMC and another
> +		 * thread doing COW.
> +		 */
> +		ptep_clear_flush_notify(vma, address, ptep);
> +		page_add_new_anon_rmap(new_page, vma, address);
> +		set_pte_at(mm, address, ptep, entry);
> +
> +		/* See comment in do_wp_page */
> +		page_remove_rmap(page);
> +		page_cache_release(page);
> +		ret = 0;
> +	} else {
> +		if (!pte_none(*ptep))
> +			zap_pte(mm, vma, address, ptep);
> +		pte_unmap_unlock(pte, ptl);
> +		mem_cgroup_uncharge_page(new_page);
> +		page_cache_release(new_page);
> +		ret = -EAGAIN;
> +	}
> +	page_cache_release(page);
> +
> +	return ret;
> +
> +oom_free_new:
> +	page_cache_release(new_page);
> +oom:
> +	page_cache_release(page);
> +	return -ENOMEM;
> +}
> +
> +/*
>   * copy one vm_area from one task to the other. Assumes the page tables
>   * already present in the new task to be cleared in the whole range
>   * covered by this vma.
>   */
>  
> -static inline void
> +static inline int
>  copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
>  		unsigned long addr, int *rss)
> @@ -614,6 +705,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
>  	unsigned long vm_flags = vma->vm_flags;
>  	pte_t pte = *src_pte;
>  	struct page *page;
> +	int ret = 0;
>  
>  	/* pte contains position in swap or file, so copy. */
>  	if (unlikely(!pte_present(pte))) {
> @@ -665,20 +757,26 @@ copy_one_pte(struct mm_struct *dst_mm, s
>  		get_page(page);
>  		page_dup_rmap(page, vma, addr);
>  		rss[!!PageAnon(page)]++;
> +		if (unlikely(PageDontCOW(page)) && PageAnon(page))
> +			ret = 1;
>  	}
>  
>  out_set_pte:
>  	set_pte_at(dst_mm, addr, dst_pte, pte);
> +
> +	return ret;
>  }
>  
>  static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> -		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
> +		pmd_t *dst_pmd, pmd_t *src_pmd,
> +		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
>  		unsigned long addr, unsigned long end)
>  {
>  	pte_t *src_pte, *dst_pte;
>  	spinlock_t *src_ptl, *dst_ptl;
>  	int progress = 0;
>  	int rss[2];
> +	int decow;
>  
>  again:
>  	rss[1] = rss[0] = 0;
> @@ -705,7 +803,10 @@ again:
>  			progress++;
>  			continue;
>  		}
> -		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
> +		decow = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
> +						src_vma, addr, rss);
> +		if (unlikely(decow))
> +			goto decow;
>  		progress += 8;
>  	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
>  
> @@ -714,14 +815,31 @@ again:
>  	pte_unmap_nested(src_pte - 1);
>  	add_mm_rss(dst_mm, rss[0], rss[1]);
>  	pte_unmap_unlock(dst_pte - 1, dst_ptl);
> +next:
>  	cond_resched();
>  	if (addr != end)
>  		goto again;
>  	return 0;
> +
> +decow:
> +	arch_leave_lazy_mmu_mode();
> +	spin_unlock(src_ptl);
> +	pte_unmap_nested(src_pte);
> +	add_mm_rss(dst_mm, rss[0], rss[1]);
> +	decow = decow_one_pte(dst_mm, dst_pte, dst_pmd, dst_ptl, dst_vma, addr);
> +	if (decow == -ENOMEM)
> +		return -ENOMEM;
> +	if (decow == -EAGAIN)
> +		goto again;
> +	pte_unmap_unlock(dst_pte, dst_ptl);
> +	cond_resched();
> +	addr += PAGE_SIZE;
> +	goto next;
>  }
>  
>  static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> -		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
> +		pud_t *dst_pud, pud_t *src_pud,
> +		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
>  		unsigned long addr, unsigned long end)
>  {
>  	pmd_t *src_pmd, *dst_pmd;
> @@ -736,14 +854,15 @@ static inline int copy_pmd_range(struct
>  		if (pmd_none_or_clear_bad(src_pmd))
>  			continue;
>  		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
> -						vma, addr, next))
> +						dst_vma, src_vma, addr, next))
>  			return -ENOMEM;
>  	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
>  	return 0;
>  }
>  
>  static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> -		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
> +		pgd_t *dst_pgd, pgd_t *src_pgd,
> +		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
>  		unsigned long addr, unsigned long end)
>  {
>  	pud_t *src_pud, *dst_pud;
> @@ -758,19 +877,19 @@ static inline int copy_pud_range(struct
>  		if (pud_none_or_clear_bad(src_pud))
>  			continue;
>  		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
> -						vma, addr, next))
> +						dst_vma, src_vma, addr, next))
>  			return -ENOMEM;
>  	} while (dst_pud++, src_pud++, addr = next, addr != end);
>  	return 0;
>  }
>  
>  int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> -		struct vm_area_struct *vma)
> +		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma)
>  {
>  	pgd_t *src_pgd, *dst_pgd;
>  	unsigned long next;
> -	unsigned long addr = vma->vm_start;
> -	unsigned long end = vma->vm_end;
> +	unsigned long addr = src_vma->vm_start;
> +	unsigned long end = src_vma->vm_end;
>  	int ret;
>  
>  	/*
> @@ -779,20 +898,20 @@ int copy_page_range(struct mm_struct *ds
>  	 * readonly mappings. The tradeoff is that copy_page_range is more
>  	 * efficient than faulting.
>  	 */
> -	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
> -		if (!vma->anon_vma)
> +	if (!(src_vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
> +		if (!src_vma->anon_vma)
>  			return 0;
>  	}
>  
> -	if (is_vm_hugetlb_page(vma))
> -		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
> +	if (is_vm_hugetlb_page(src_vma))
> +		return copy_hugetlb_page_range(dst_mm, src_mm, src_vma);
>  
> -	if (unlikely(is_pfn_mapping(vma))) {
> +	if (unlikely(is_pfn_mapping(src_vma))) {
>  		/*
>  		 * We do not free on error cases below as remove_vma
>  		 * gets called on error from higher level routine
>  		 */
> -		ret = track_pfn_vma_copy(vma);
> +		ret = track_pfn_vma_copy(src_vma);
>  		if (ret)
>  			return ret;
>  	}
> @@ -803,7 +922,7 @@ int copy_page_range(struct mm_struct *ds
>  	 * parent mm. And a permission downgrade will only happen if
>  	 * is_cow_mapping() returns true.
>  	 */
> -	if (is_cow_mapping(vma->vm_flags))
> +	if (is_cow_mapping(src_vma->vm_flags))
>  		mmu_notifier_invalidate_range_start(src_mm, addr, end);
>  
>  	ret = 0;
> @@ -814,15 +933,16 @@ int copy_page_range(struct mm_struct *ds
>  		if (pgd_none_or_clear_bad(src_pgd))
>  			continue;
>  		if (unlikely(copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
> -					    vma, addr, next))) {
> +					    dst_vma, src_vma, addr, next))) {
>  			ret = -ENOMEM;
>  			break;
>  		}
>  	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
>  
> -	if (is_cow_mapping(vma->vm_flags))
> +	if (is_cow_mapping(src_vma->vm_flags))
>  		mmu_notifier_invalidate_range_end(src_mm,
> -						  vma->vm_start, end);
> +						  src_vma->vm_start, end);
> +
>  	return ret;
>  }
>  
> @@ -1272,8 +1392,6 @@ static inline int use_zero_page(struct v
>  	return !vma->vm_ops || !vma->vm_ops->fault;
>  }
>  
> -
> -
>  int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		     unsigned long start, int len, int flags,
>  		struct page **pages, struct vm_area_struct **vmas)
> @@ -1298,6 +1416,7 @@ int __get_user_pages(struct task_struct
>  	do {
>  		struct vm_area_struct *vma;
>  		unsigned int foll_flags;
> +		int decow;
>  
>  		vma = find_extend_vma(mm, start);
>  		if (!vma && in_gate_area(tsk, start)) {
> @@ -1352,6 +1471,14 @@ int __get_user_pages(struct task_struct
>  			continue;
>  		}
>  
> +		/*
> +		 * Except in special cases where the caller will not read to or
> +		 * write from these pages, we must break COW for any pages
> +		 * returned from get_user_pages, so that our caller does not
> +		 * subsequently end up with the pages of a parent or child
> +		 * process after a COW takes place.
> +		 */
> +		decow = (pages && is_cow_mapping(vma->vm_flags));
>  		foll_flags = FOLL_TOUCH;
>  		if (pages)
>  			foll_flags |= FOLL_GET;
> @@ -1372,7 +1499,7 @@ int __get_user_pages(struct task_struct
>  					fatal_signal_pending(current)))
>  				return i ? i : -ERESTARTSYS;
>  
> -			if (write)
> +			if (write || decow)
>  				foll_flags |= FOLL_WRITE;
>  
>  			cond_resched();
> @@ -1415,6 +1542,9 @@ int __get_user_pages(struct task_struct
>  			if (pages) {
>  				pages[i] = page;
>  
> +				if (decow && !PageDontCOW(page) &&
> +						PageAnon(page))
> +					SetPageDontCOW(page);
>  				flush_anon_page(vma, page, start);
>  				flush_dcache_page(page);
>  			}
> @@ -1966,6 +2096,8 @@ static int do_wp_page(struct mm_struct *
>  		}
>  		reuse = reuse_swap_page(old_page);
>  		unlock_page(old_page);
> +		VM_BUG_ON(PageDontCOW(old_page) && !reuse);
> +
>  	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
>  					(VM_WRITE|VM_SHARED))) {
>  		/*
> Index: linux-2.6/arch/x86/mm/gup.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/mm/gup.c
> +++ linux-2.6/arch/x86/mm/gup.c
> @@ -83,11 +83,14 @@ static noinline int gup_pte_range(pmd_t
>  		struct page *page;
>  
>  		if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
> +failed:
>  			pte_unmap(ptep);
>  			return 0;
>  		}
>  		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>  		page = pte_page(pte);
> +		if (PageAnon(page) && unlikely(!PageDontCOW(page)))
> +			goto failed;
>  		get_page(page);
>  		pages[*nr] = page;
>  		(*nr)++;
> Index: linux-2.6/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.orig/include/linux/page-flags.h
> +++ linux-2.6/include/linux/page-flags.h
> @@ -106,6 +106,9 @@ enum pageflags {
>  #endif
>  	__NR_PAGEFLAGS,
>  
> +	/* Anonymous pages */
> +	PG_dontcow = PG_owner_priv_1,	/* do not WP for COW optimisation */
> +
>  	/* Filesystems */
>  	PG_checked = PG_owner_priv_1,
>  
> @@ -225,6 +228,8 @@ PAGEFLAG(OwnerPriv1, owner_priv_1) TESTC
>   */
>  TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
>  __PAGEFLAG(Buddy, buddy)
> +__PAGEFLAG(DontCOW, dontcow)
> +SETPAGEFLAG(DontCOW, dontcow)
>  PAGEFLAG(MappedToDisk, mappedtodisk)
>  
>  /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
> Index: linux-2.6/kernel/fork.c
> ===================================================================
> --- linux-2.6.orig/kernel/fork.c
> +++ linux-2.6/kernel/fork.c
> @@ -359,7 +359,7 @@ static int dup_mmap(struct mm_struct *mm
>  		rb_parent = &tmp->vm_rb;
>  
>  		mm->map_count++;
> -		retval = copy_page_range(mm, oldmm, mpnt);
> +		retval = copy_page_range(mm, oldmm, tmp, mpnt);
>  
>  		if (tmp->vm_ops && tmp->vm_ops->open)
>  			tmp->vm_ops->open(tmp);
> Index: linux-2.6/arch/powerpc/mm/gup.c
> ===================================================================
> --- linux-2.6.orig/arch/powerpc/mm/gup.c
> +++ linux-2.6/arch/powerpc/mm/gup.c
> @@ -41,6 +41,8 @@ static noinline int gup_pte_range(pmd_t
>  			return 0;
>  		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>  		page = pte_page(pte);
> +		if (PageAnon(page) && unlikely(!PageDontCOW(page)))
> +			return 0;
>  		if (!page_cache_get_speculative(page))
>  			return 0;
>  		if (unlikely(pte_val(pte) != pte_val(*ptep))) {



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
