Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC9F06B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:01:54 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 03:01:42 +1100
References: <20090311170611.GA2079@elte.hu> <200903141559.12484.nickpiggin@yahoo.com.au> <20090316135654.GA17949@random.random>
In-Reply-To: <20090316135654.GA17949@random.random>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903170301.43091.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 00:56:54 Andrea Arcangeli wrote:
> On Sat, Mar 14, 2009 at 03:59:11PM +1100, Nick Piggin wrote:
> > It does touch gup-fast, but it just adds one branch and no barrier in the
>
> My question is what trick to you use to stop gup-fast from returning
> the page mapped read-write by the pte if gup-fast doesn't take any
> lock whatsoever, it doesn't set any bit in any page or vma, and it
> doesn't recheck the pte is still viable after having set any bit on
> page or vmas, and you still don't send a flood of ipis from fork fast
> path (no race case).

If the page is not marked PageDontCOW, then it decows it, which
gives synchronisation against fork. If it is marked PageDontCOW,
then it can't possibly be COWed by fork, previous or subsequent.


> > Possibly that's the right way to go. Depends if it is in the slightest
> > performance critical. If not, I would just let do_wp_page do the work
> > to avoid a little bit of logic, but either way is not a big deal to me.
>
> fork is less performance critical than do_wp_page, still in fork
> microbenchmark no slowdown is measured with the patch. Before I
> introduced PG_gup there were false positives triggered by the pagevec
> temporary pins, that was measurable, after PG_gup the fast path is

OK. Mine doesn't get false positives, but it doesn't try to reintroduce
pages as COW candidates after the get_user_pages is finished. This is
how it is simpler than your patch.


> unaffected (I've still to measure gup-fast slowdown in setting PG_gup
> but I'm rather optimistic that you're understimating the cost of
> walking 4 layers of pagetables compared to a locked op on a l1
> exclusive cacheline, so I think it'll be lost in the noise). I think
> the big thing of gup-fast is primarly in not having to search vmas,
> and in turn to take any shared lock like mmap_sem/PT lock and to scale
> on a page level with just a get-page being the troublesome cacheline.

You lost the get_head_page_multiple too for huge pages. This is the
path that Oracle/DB2 will always go down when running any benchmarks.
At the current DIO_PAGES size, this means adding up to 63 atomics,
64 mfences, and and touching cachelines of 63-64 of the non-head struct
pages per request.

OK probably even those databases don't get a chance to do such big IOs,
but they definitely will be doing larger than 4K at a time in many
cases (probably even their internal block size can be larger).


> > One side of the race is direct IO read writing to fork child page.
> > The other side of the race is fork child page write leaking into
> > the direct IO.
> >
> > My patch solves both sides by de-cowing *any* COW page before it
> > may be returned from get_user_pages (for read or write).
>
> I see what you mean now. If you read the comment of my patch you'll
> see I explicitly intended that only people writing into memory with
> gup was troublesome here. Like you point out, using gup for _reading_
> from memory is troublesome as well if child writes to those
> pages. This is kind of a lower problem because the major issue is that
> fork is enough to generate memory corruption even if the child isn't
> touching those pages. The reverse race requires the child to write to
> those pages so I guess it never triggered in real life apps. But
> nevertheless I totally agree if we fix the write-to-memory-with-gup
> we've to fix the read-from-memory-with-gup.

Yes.


> Below I updated my patch and relative commit header to fix the reverse
> race too. However I had to enlarge the buffer to 40M to reproduce with
> your testcase because my HD was too fast otherwise.

You're using a solid state disk? :)


> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -89,6 +89,26 @@ static noinline int gup_pte_range(pmd_t
>  		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>  		page = pte_page(pte);
>  		get_page(page);
> +		if (PageAnon(page)) {
> +			if (!PageGUP(page))
> +				SetPageGUP(page);
> +			smp_mb();
> +			/*
> +			 * Fork doesn't want to flush the smp-tlb for
> +			 * every pte that it marks readonly but newly
> +			 * created shared anon pages cannot have
> +			 * direct-io going to them, so check if fork
> +			 * made the page shared before we taken the
> +			 * page pin.
> +			 * de-cow to make direct read from memory safe.
> +			 */
> +			if ((pte_flags(gup_get_pte(ptep)) &
> +			     (mask | _PAGE_SPECIAL)) != (mask|_PAGE_RW)) {
> +				put_page(page);
> +				pte_unmap(ptep);
> +				return 0;

Hmm, so this is disabling fast-gup for RO anonymous ranges?

I guess this seems like it covers the reverse race then... btw powerpc
has a slightly different fast-gup scheme where it isn't actually holding
off TLB shootdown. I don't think you need to do anything too different,
but better double check.

And here is my improved patch. Same logic but just streamlines the
decow stuff a bit and cuts out some unneeded stuff. This should be
pretty complete for 4K pages. Except I'm a little unsure about the
"ptes don't match, retry" path of the decow procedure. Lots of tricky
little details to get right... And I'm not quite sure that you got
this right either -- vmscan.c can turn the child pte into a swap pte
here, right? In which case I think you need to drop its swapcache
entry don't you? I don't know if there are other ways it could be
changed, but I import the full zap_pte function over just in case.

--
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2009-03-14 02:48:06.000000000 +1100
+++ linux-2.6/include/linux/mm.h	2009-03-17 00:37:59.000000000 +1100
@@ -789,7 +789,7 @@ int walk_page_range(unsigned long addr, 
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
-			struct vm_area_struct *vma);
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2009-03-14 02:48:06.000000000 +1100
+++ linux-2.6/mm/memory.c	2009-03-17 02:43:21.000000000 +1100
@@ -533,12 +533,171 @@ out:
 }
 
 /*
+ * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
+ * servicing faults for write access.  In the normal case, do always want
+ * pte_mkwrite.  But get_user_pages can cause write faults for mappings
+ * that do not have writing enabled, when used by access_process_vm.
+ */
+static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
+{
+	if (likely(vma->vm_flags & VM_WRITE))
+		pte = pte_mkwrite(pte);
+	return pte;
+}
+
+static void cow_user_page(struct page *dst, struct page *src,
+			unsigned long va, struct vm_area_struct *vma)
+{
+	/*
+	 * If the source page was a PFN mapping, we don't have
+	 * a "struct page" for it. We do a best-effort copy by
+	 * just copying from the original user address. If that
+	 * fails, we just zero-fill it. Live with it.
+	 */
+	if (unlikely(!src)) {
+		void *kaddr = kmap_atomic(dst, KM_USER0);
+		void __user *uaddr = (void __user *)(va & PAGE_MASK);
+
+		/*
+		 * This really shouldn't fail, because the page is there
+		 * in the page tables. But it might just be unreadable,
+		 * in which case we just give up and fill the result with
+		 * zeroes.
+		 */
+		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
+			memset(kaddr, 0, PAGE_SIZE);
+		kunmap_atomic(kaddr, KM_USER0);
+		flush_dcache_page(dst);
+	} else
+		copy_user_highpage(dst, src, va, vma);
+}
+
+void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long addr, pte_t *ptep)
+{
+	pte_t pte = *ptep;
+
+	if (pte_present(pte)) {
+		struct page *page;
+
+		flush_cache_page(vma, addr, pte_pfn(pte));
+		pte = ptep_clear_flush(vma, addr, ptep);
+		page = vm_normal_page(vma, addr, pte);
+		if (page) {
+			if (pte_dirty(pte))
+				set_page_dirty(page);
+			page_remove_rmap(page);
+			page_cache_release(page);
+			update_hiwater_rss(mm);
+			if (PageAnon(page))
+				dec_mm_counter(mm, anon_rss);
+			else
+				dec_mm_counter(mm, file_rss);
+		}
+	} else {
+		if (!pte_file(pte))
+			free_swap_and_cache(pte_to_swp_entry(pte));
+		pte_clear_not_present_full(mm, addr, ptep, 0);
+	}
+}
+/*
+ * breaks COW of child pte that has been marked COW by fork().
+ * Must be called with the child's ptl held and pte mapped.
+ * Returns 0 on success with ptl held and pte mapped.
+ * -ENOMEM on OOM failure, or -EAGAIN if something changed under us.
+ * ptl dropped and pte unmapped on error cases.
+ */
+static noinline int decow_one_pte(struct mm_struct *mm, pte_t *ptep, pmd_t *pmd,
+			spinlock_t *ptl, struct vm_area_struct *vma,
+			unsigned long address)
+{
+	pte_t pte = *ptep;
+	struct page *page, *new_page;
+	int ret;
+
+	BUG_ON(!pte_present(pte));
+	BUG_ON(pte_write(pte));
+
+	page = vm_normal_page(vma, address, pte);
+	BUG_ON(!page);
+	BUG_ON(!PageAnon(page));
+	BUG_ON(!PageDontCOW(page));
+
+	/* The following code comes from do_wp_page */
+	page_cache_get(page);
+	pte_unmap_unlock(pte, ptl);
+
+	if (unlikely(anon_vma_prepare(vma)))
+		goto oom;
+	VM_BUG_ON(page == ZERO_PAGE(0));
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	if (!new_page)
+		goto oom;
+	/*
+	 * Don't let another task, with possibly unlocked vma,
+	 * keep the mlocked page.
+	 */
+	if (vma->vm_flags & VM_LOCKED) {
+		lock_page(page);	/* for LRU manipulation */
+		clear_page_mlock(page);
+		unlock_page(page);
+	}
+	cow_user_page(new_page, page, address, vma);
+	__SetPageUptodate(new_page);
+
+	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
+		goto oom_free_new;
+
+	/*
+	 * Re-check the pte - we dropped the lock
+	 */
+	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (pte_same(*ptep, pte)) {
+		pte_t entry;
+
+		flush_cache_page(vma, address, pte_pfn(pte));
+		entry = mk_pte(new_page, vma->vm_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		/*
+		 * Clear the pte entry and flush it first, before updating the
+		 * pte with the new entry. This will avoid a race condition
+		 * seen in the presence of one thread doing SMC and another
+		 * thread doing COW.
+		 */
+		ptep_clear_flush_notify(vma, address, ptep);
+		page_add_new_anon_rmap(new_page, vma, address);
+		set_pte_at(mm, address, ptep, entry);
+
+		/* See comment in do_wp_page */
+		page_remove_rmap(page);
+		page_cache_release(page);
+		ret = 0;
+	} else {
+		if (!pte_none(*ptep))
+			zap_pte(mm, vma, address, ptep);
+		pte_unmap_unlock(pte, ptl);
+		mem_cgroup_uncharge_page(new_page);
+		page_cache_release(new_page);
+		ret = -EAGAIN;
+	}
+	page_cache_release(page);
+
+	return ret;
+
+oom_free_new:
+	page_cache_release(new_page);
+oom:
+	page_cache_release(page);
+	return -ENOMEM;
+}
+
+/*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
  * covered by this vma.
  */
 
-static inline void
+static inline int
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
 		unsigned long addr, int *rss)
@@ -546,6 +705,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
 	struct page *page;
+	int ret = 0;
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
@@ -597,20 +757,26 @@ copy_one_pte(struct mm_struct *dst_mm, s
 		get_page(page);
 		page_dup_rmap(page, vma, addr);
 		rss[!!PageAnon(page)]++;
+		if (unlikely(PageDontCOW(page)))
+			ret = 1;
 	}
 
 out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
+
+	return ret;
 }
 
 static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
+		pmd_t *dst_pmd, pmd_t *src_pmd,
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
 		unsigned long addr, unsigned long end)
 {
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
 	int rss[2];
+	int decow;
 
 again:
 	rss[1] = rss[0] = 0;
@@ -637,7 +803,10 @@ again:
 			progress++;
 			continue;
 		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		decow = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
+						src_vma, addr, rss);
+		if (unlikely(decow))
+			goto decow;
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
@@ -646,14 +815,31 @@ again:
 	pte_unmap_nested(src_pte - 1);
 	add_mm_rss(dst_mm, rss[0], rss[1]);
 	pte_unmap_unlock(dst_pte - 1, dst_ptl);
+next:
 	cond_resched();
 	if (addr != end)
 		goto again;
 	return 0;
+
+decow:
+	arch_leave_lazy_mmu_mode();
+	spin_unlock(src_ptl);
+	pte_unmap_nested(src_pte);
+	add_mm_rss(dst_mm, rss[0], rss[1]);
+	decow = decow_one_pte(dst_mm, dst_pte, dst_pmd, dst_ptl, dst_vma, addr);
+	if (decow == -ENOMEM)
+		return -ENOMEM;
+	if (decow == -EAGAIN)
+		goto again;
+	pte_unmap_unlock(dst_pte, dst_ptl);
+	cond_resched();
+	addr += PAGE_SIZE;
+	goto next;
 }
 
 static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
+		pud_t *dst_pud, pud_t *src_pud,
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
 		unsigned long addr, unsigned long end)
 {
 	pmd_t *src_pmd, *dst_pmd;
@@ -668,14 +854,15 @@ static inline int copy_pmd_range(struct 
 		if (pmd_none_or_clear_bad(src_pmd))
 			continue;
 		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
+						dst_vma, src_vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
 	return 0;
 }
 
 static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
+		pgd_t *dst_pgd, pgd_t *src_pgd,
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
 		unsigned long addr, unsigned long end)
 {
 	pud_t *src_pud, *dst_pud;
@@ -690,19 +877,19 @@ static inline int copy_pud_range(struct 
 		if (pud_none_or_clear_bad(src_pud))
 			continue;
 		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
+						dst_vma, src_vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pud++, src_pud++, addr = next, addr != end);
 	return 0;
 }
 
 int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		struct vm_area_struct *vma)
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma)
 {
 	pgd_t *src_pgd, *dst_pgd;
 	unsigned long next;
-	unsigned long addr = vma->vm_start;
-	unsigned long end = vma->vm_end;
+	unsigned long addr = src_vma->vm_start;
+	unsigned long end = src_vma->vm_end;
 	int ret;
 
 	/*
@@ -711,20 +898,20 @@ int copy_page_range(struct mm_struct *ds
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
-	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
-		if (!vma->anon_vma)
+	if (!(src_vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
+		if (!src_vma->anon_vma)
 			return 0;
 	}
 
-	if (is_vm_hugetlb_page(vma))
-		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
+	if (is_vm_hugetlb_page(src_vma))
+		return copy_hugetlb_page_range(dst_mm, src_mm, src_vma);
 
-	if (unlikely(is_pfn_mapping(vma))) {
+	if (unlikely(is_pfn_mapping(src_vma))) {
 		/*
 		 * We do not free on error cases below as remove_vma
 		 * gets called on error from higher level routine
 		 */
-		ret = track_pfn_vma_copy(vma);
+		ret = track_pfn_vma_copy(src_vma);
 		if (ret)
 			return ret;
 	}
@@ -735,7 +922,7 @@ int copy_page_range(struct mm_struct *ds
 	 * parent mm. And a permission downgrade will only happen if
 	 * is_cow_mapping() returns true.
 	 */
-	if (is_cow_mapping(vma->vm_flags))
+	if (is_cow_mapping(src_vma->vm_flags))
 		mmu_notifier_invalidate_range_start(src_mm, addr, end);
 
 	ret = 0;
@@ -746,15 +933,16 @@ int copy_page_range(struct mm_struct *ds
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
 		if (unlikely(copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-					    vma, addr, next))) {
+					    dst_vma, src_vma, addr, next))) {
 			ret = -ENOMEM;
 			break;
 		}
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
-	if (is_cow_mapping(vma->vm_flags))
+	if (is_cow_mapping(src_vma->vm_flags))
 		mmu_notifier_invalidate_range_end(src_mm,
-						  vma->vm_start, end);
+						  src_vma->vm_start, end);
+
 	return ret;
 }
 
@@ -1199,8 +1387,6 @@ static inline int use_zero_page(struct v
 	return !vma->vm_ops || !vma->vm_ops->fault;
 }
 
-
-
 int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     unsigned long start, int len, int flags,
 		struct page **pages, struct vm_area_struct **vmas)
@@ -1225,6 +1411,7 @@ int __get_user_pages(struct task_struct 
 	do {
 		struct vm_area_struct *vma;
 		unsigned int foll_flags;
+		int decow;
 
 		vma = find_extend_vma(mm, start);
 		if (!vma && in_gate_area(tsk, start)) {
@@ -1279,6 +1466,14 @@ int __get_user_pages(struct task_struct 
 			continue;
 		}
 
+		/*
+		 * Except in special cases where the caller will not read to or
+		 * write from these pages, we must break COW for any pages
+		 * returned from get_user_pages, so that our caller does not
+		 * subsequently end up with the pages of a parent or child
+		 * process after a COW takes place.
+		 */
+		decow = (pages && is_cow_mapping(vma->vm_flags));
 		foll_flags = FOLL_TOUCH;
 		if (pages)
 			foll_flags |= FOLL_GET;
@@ -1299,7 +1494,7 @@ int __get_user_pages(struct task_struct 
 					fatal_signal_pending(current)))
 				return i ? i : -ERESTARTSYS;
 
-			if (write)
+			if (write || decow)
 				foll_flags |= FOLL_WRITE;
 
 			cond_resched();
@@ -1342,6 +1537,8 @@ int __get_user_pages(struct task_struct 
 			if (pages) {
 				pages[i] = page;
 
+				if (decow && !PageDontCOW(page))
+					SetPageDontCOW(page);
 				flush_anon_page(vma, page, start);
 				flush_dcache_page(page);
 			}
@@ -1370,7 +1567,6 @@ int get_user_pages(struct task_struct *t
 				start, len, flags,
 				pages, vmas);
 }
-
 EXPORT_SYMBOL(get_user_pages);
 
 pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
@@ -1829,45 +2025,6 @@ static inline int pte_unmap_same(struct 
 }
 
 /*
- * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
- * servicing faults for write access.  In the normal case, do always want
- * pte_mkwrite.  But get_user_pages can cause write faults for mappings
- * that do not have writing enabled, when used by access_process_vm.
- */
-static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
-{
-	if (likely(vma->vm_flags & VM_WRITE))
-		pte = pte_mkwrite(pte);
-	return pte;
-}
-
-static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct 
vm_area_struct *vma)
-{
-	/*
-	 * If the source page was a PFN mapping, we don't have
-	 * a "struct page" for it. We do a best-effort copy by
-	 * just copying from the original user address. If that
-	 * fails, we just zero-fill it. Live with it.
-	 */
-	if (unlikely(!src)) {
-		void *kaddr = kmap_atomic(dst, KM_USER0);
-		void __user *uaddr = (void __user *)(va & PAGE_MASK);
-
-		/*
-		 * This really shouldn't fail, because the page is there
-		 * in the page tables. But it might just be unreadable,
-		 * in which case we just give up and fill the result with
-		 * zeroes.
-		 */
-		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
-			memset(kaddr, 0, PAGE_SIZE);
-		kunmap_atomic(kaddr, KM_USER0);
-		flush_dcache_page(dst);
-	} else
-		copy_user_highpage(dst, src, va, vma);
-}
-
-/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -1930,6 +2087,8 @@ static int do_wp_page(struct mm_struct *
 		}
 		reuse = reuse_swap_page(old_page);
 		unlock_page(old_page);
+		VM_BUG_ON(PageDontCOW(old_page) && !reuse);
+
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
 		/*
@@ -2936,7 +3095,8 @@ int make_pages_present(unsigned long add
 	BUG_ON(end > vma->vm_end);
 	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
 	ret = get_user_pages(current, current->mm, addr,
-			len, write, 0, NULL, NULL);
+			len, write, 0,
+			NULL, NULL);
 	if (ret < 0)
 		return ret;
 	return ret == len ? 0 : -EFAULT;
@@ -3086,7 +3246,7 @@ int access_process_vm(struct task_struct
 		struct page *page = NULL;
 
 		ret = get_user_pages(tsk, mm, addr, 1,
-				write, 1, &page, &vma);
+				0, 1, &page, &vma);
 		if (ret <= 0) {
 			/*
 			 * Check if this is a VM_IO | VM_PFNMAP VMA, which
Index: linux-2.6/arch/x86/mm/gup.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/gup.c	2009-03-14 02:48:06.000000000 +1100
+++ linux-2.6/arch/x86/mm/gup.c	2009-03-14 16:21:40.000000000 +1100
@@ -83,11 +83,14 @@ static noinline int gup_pte_range(pmd_t 
 		struct page *page;
 
 		if ((pte_flags(pte) & (mask | _PAGE_SPECIAL)) != mask) {
+failed:
 			pte_unmap(ptep);
 			return 0;
 		}
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
+		if (PageAnon(page) && unlikely(!PageDontCOW(page)))
+			goto failed;
 		get_page(page);
 		pages[*nr] = page;
 		(*nr)++;
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2009-03-14 02:48:06.000000000 +1100
+++ linux-2.6/include/linux/page-flags.h	2009-03-14 02:48:13.000000000 +1100
@@ -94,6 +94,7 @@ enum pageflags {
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_buddy,		/* Page is free, on buddy lists */
 	PG_swapbacked,		/* Page is backed by RAM/swap */
+	PG_dontcow,		/* PageAnon page in a VM_DONTCOW vma */
 #ifdef CONFIG_UNEVICTABLE_LRU
 	PG_unevictable,		/* Page is "unevictable"  */
 	PG_mlocked,		/* Page is vma mlocked */
@@ -208,6 +209,8 @@ __PAGEFLAG(SlubDebug, slub_debug)
  */
 TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
 __PAGEFLAG(Buddy, buddy)
+__PAGEFLAG(DontCOW, dontcow)
+SETPAGEFLAG(DontCOW, dontcow)
 PAGEFLAG(MappedToDisk, mappedtodisk)
 
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2009-03-14 02:48:06.000000000 +1100
+++ linux-2.6/kernel/fork.c	2009-03-14 15:12:09.000000000 +1100
@@ -353,7 +353,7 @@ static int dup_mmap(struct mm_struct *mm
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		retval = copy_page_range(mm, oldmm, mpnt);
+		retval = copy_page_range(mm, oldmm, tmp, mpnt);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h	2009-03-13 20:25:00.000000000 +1100
+++ linux-2.6/mm/internal.h	2009-03-17 02:41:48.000000000 +1100
@@ -15,6 +15,8 @@
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
+void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long addr, pte_t *ptep);
 
 extern void prep_compound_page(struct page *page, unsigned long order);
 extern void prep_compound_gigantic_page(struct page *page, unsigned long order);
Index: linux-2.6/arch/powerpc/mm/gup.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/gup.c	2009-03-17 01:00:48.000000000 +1100
+++ linux-2.6/arch/powerpc/mm/gup.c	2009-03-17 01:02:10.000000000 +1100
@@ -39,6 +39,8 @@ static noinline int gup_pte_range(pmd_t 
 			return 0;
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
+		if (PageAnon(page) && unlikely(!PageDontCOW(page)))
+			return 0;
 		if (!page_cache_get_speculative(page))
 			return 0;
 		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2009-03-17 02:37:21.000000000 +1100
+++ linux-2.6/mm/fremap.c	2009-03-17 02:42:11.000000000 +1100
@@ -23,32 +23,6 @@
 
 #include "internal.h"
 
-static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long addr, pte_t *ptep)
-{
-	pte_t pte = *ptep;
-
-	if (pte_present(pte)) {
-		struct page *page;
-
-		flush_cache_page(vma, addr, pte_pfn(pte));
-		pte = ptep_clear_flush(vma, addr, ptep);
-		page = vm_normal_page(vma, addr, pte);
-		if (page) {
-			if (pte_dirty(pte))
-				set_page_dirty(page);
-			page_remove_rmap(page);
-			page_cache_release(page);
-			update_hiwater_rss(mm);
-			dec_mm_counter(mm, file_rss);
-		}
-	} else {
-		if (!pte_file(pte))
-			free_swap_and_cache(pte_to_swp_entry(pte));
-		pte_clear_not_present_full(mm, addr, ptep, 0);
-	}
-}
-
 /*
  * Install a file pte to a given virtual memory address, release any
  * previously existing mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
