Date: Wed, 29 Oct 2008 01:43:09 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: RFC: race between o_direct and fork (harder to fix with get_user_page_fast)
Message-ID: <20081029004308.GH15599@wotan.suse.de>
References: <20080925183846.GA6877@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080925183846.GA6877@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: linux-mm@kvack.org, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 25, 2008 at 08:38:46PM +0200, Andrea Arcangeli wrote:
> Hi Nick,
> 
> with Izik and Avi, we've been discussing on how to best make ksm work
> with O_DIRECT. I don't think it's an immediate priority but eventually
> we've to fix this as KVM is close to being able to dma from disk
> directly into guest physical memory without intermediate copies.
> 
> Checking if pages have O_DIRECT (or similar other physical I/O) in
> flight is fairly easy, comparing page count with page mapcount should
> do the trick. The source of the problem is that this page count ==
> page mapcount check should happen under some lock that blocks
> get_user_pages and get_user_page_fast. If the page is already shared,
> we only need to block the get_user_pages running on the 'mm' of the
> 'pte' that we're overwriting. So for get_user_pages it'd be enough to
> do the check of page count == page mapcount under the PT lock.
> 
> 1)
>        PT lock
>        if (page_count != page_mapcount)
>        	  goto fail
>        make pte readonly
>        PT unlock
> 
> then in the final stage:
> 
> 2)
>      PT lock
>      if (!pte_same)
>      	goto fail
>      change pte to point to ksm page
>      PT unlock
> 
> If other tasks are starting in-flight O_DIRECT on the page we don't
> care, those will have to copy-on-write it before starting the O_DIRECT
> anyway, so there will be still no in-flight I/O on the physical page
> we're working on. All we care about is that get_user_pages doesn't run
> on our mm/PTlock between the page_count!=page_mapcount check and the
> mark of the pte readonly. Otherwise it won't trigger the COW and it
> should (for us to later notice it in pte_same!).
> 
> Now with get_user_pages_fast the above PT lock isn't enough anymore to
> make it safe.
> 
> While thinking at get_user_pages_fast I figured another worse way
> things can go wrong with ksm and o_direct: think a thread writing
> constantly to the last 512bytes of a page, while another thread read
> and writes to/from the first 512bytes of the page. We can lose
> O_DIRECT reads, the very moment we mark any pte wrprotected. Then Avi
> immediately pointed out this means also fork is affected by the same
> bug that ksm would have.
> 
> So Avi just found a very longstanding bug in fork. Fork has the very
> same problem of ksm in marking readonly ptes that could point to pages
> that have O_DIRECT in flight.
> 
> So this isn't a KSM problem anymore. We've to fix this longstanding
> bug in fork first. Then we'll think at KSM and we'll use the same
> locking technique to make KSM safe against O_DIRECT too
> 
> The best I can think of, is to re-introduce of the brlock (possibly
> after making it fair). We can't use RCU as far as I can tell. No idea
> why brlock was removed perhaps somebody thought RCU was an equivalent
> replacement? RCU/SRCU can't block anything, and we've to block the
> get_user_page_fast in the critical section at point 1 to be
> safe. There's a practical limit of how much things can be delayed, for
> page faults (at least practically) they can't.
> 
> ksm
> 
>        br_write_lock()
>        if (page_count != page_mapcount)
>        	  goto fail
>        make pte readonly
>        br_write_unlock()
> 
> fork
> 
> 	br_write_lock()
> 	if (page_count != page_mapcount)
> 	   copy_page()
> 	else
> 	   make pte readonly
> 	br_write_unlock()
>        
> get_user_page_fast
> 
> 	br_read_lock()
> 	walk ptes out of order w/o mmap_sem		
> 	br_read_unlock()
> 
> Another way of course is to take the mmap_sem in read mode around the
> out of order part of get_user_page_fast but that'd be invalidating the
> 'thread vs thread' smp scalability of get_user_page_fast.
> 
> If it was just for KSM I suggested we could fix it by sigstopping (or
> getting out of the scheduler in some other more reliable mean) all
> threads that shared the 'mm' that ksm was working on. That would take
> care of the fast path of get_user_page_fast and the PT lock would take
> care of the get_user_page_fast slow path. But this schedule technique
> ala stop_machine surely isn't workable for fork() for performance
> reasons.
> 
> Yet another way is as usual to use a page bitflag to serialize things
> at the page level. That will prevent multiple O_DIRECT reads to the
> same page simultaneously but it'll allow fork to wait IO completion
> and avoid the copy_page(). Ages ago I always wanted to keep the
> PG_lock for pages under O_DIRECT... We instead relied solely on page
> pinning which has a few advantages but it makes things like fork more
> complicated and harder to fix.
> 
> I'm very interested to know your ideas on how to best fix fork vs
> o_direct!

Hi Andrea,

Sorry I missed this. Thanks for pinging me again. Great set of bugs
you've found :)

We also have the related problem that any existing COWs need to be broken
by get_user_pages...

At the moment I'm just hacking around (haven't touched fast_gup yet).
But if we follow the rule that for PageAnon pages, the pte must be set
to pte_write, then I'm hoping that is going to give us enough
synchronisation to get around the problem. I've attached a really raw
hack of what I'm trying to do. get_user_pages_fast I think should
be able to do a similar check without adding locks.

I do really like the idea of locking pages before they go under direct
IO... it also closes a class of real invalidate_mapping_pages bugs where
the page is going to be dirtied by the direct-IO, but it is still allowed
to be invalidated from pagecache... As a solution to this problem... I'm not
sure if it would be entirely trivial still. We could wait on get_user_pages
in fork, but would we actually want to, rather than just COW them?
---
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -488,7 +488,7 @@ out:
  * covered by this vma.
  */
 
-static inline void
+static inline int
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
 		unsigned long addr, int *rss)
@@ -496,6 +496,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
 	struct page *page;
+	int ret = 0;
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
@@ -546,11 +547,19 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page, vma, addr);
+		if (unlikely(page_count(page) != page_mapcount(page))) { /* XXX: also have to check swapcount?! */
+			if (is_cow_mapping(vm_flags) && PageAnon(page)) {
+				printk("forcecow!\n");
+				ret = 1;
+			}
+		}
 		rss[!!PageAnon(page)]++;
 	}
 
 out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
+
+	return ret;
 }
 
 static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
@@ -561,8 +570,10 @@ static int copy_pte_range(struct mm_stru
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
 	int rss[2];
+	int forcecow;
 
 again:
+	forcecow = 0;
 	rss[1] = rss[0] = 0;
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
@@ -573,6 +584,9 @@ again:
 	arch_enter_lazy_mmu_mode();
 
 	do {
+		if (forcecow)
+			break;
+
 		/*
 		 * We are holding two locks at this point - either of them
 		 * could generate latencies in another task on another CPU.
@@ -587,7 +601,7 @@ again:
 			progress++;
 			continue;
 		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		forcecow = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
@@ -597,6 +611,10 @@ again:
 	add_mm_rss(dst_mm, rss[0], rss[1]);
 	pte_unmap_unlock(dst_pte - 1, dst_ptl);
 	cond_resched();
+	if (forcecow) {
+		if (handle_mm_fault(dst_mm, vma, addr - PAGE_SIZE, 1) & VM_FAULT_ERROR) /* XXX: should really just do a page copy? */
+			return -ENOMEM;
+	}
 	if (addr != end)
 		goto again;
 	return 0;
@@ -1216,6 +1234,7 @@ int __get_user_pages(struct task_struct 
 
 		do {
 			struct page *page;
+			int cow = 0;
 
 			/*
 			 * If tsk is ooming, cut off its access to large memory
@@ -1229,8 +1248,24 @@ int __get_user_pages(struct task_struct 
 				foll_flags |= FOLL_WRITE;
 
 			cond_resched();
-			while (!(page = follow_page(vma, start, foll_flags))) {
+
+			printk("get_user_pages address=%p\n", (void *)start);
+			for (;;) {
 				int ret;
+
+				page = follow_page(vma, start, foll_flags);
+				if (page) {
+					printk("found page is_cow_mapping=%d PageAnon=%d write=%d cow=%d\n", is_cow_mapping(vma->vm_flags), PageAnon(page), write, cow);
+
+					if (is_cow_mapping(vma->vm_flags) &&
+						PageAnon(page) && !write && !cow) {
+						foll_flags |= FOLL_WRITE;
+						printk("gup break cow\n");
+						cow = 1;
+					} else
+						break;
+				}
+
 				ret = handle_mm_fault(mm, vma, start,
 						foll_flags & FOLL_WRITE);
 				if (ret & VM_FAULT_ERROR) {
@@ -1252,8 +1287,10 @@ int __get_user_pages(struct task_struct 
 				 * pte_write. We can thus safely do subsequent
 				 * page lookups as if they were reads.
 				 */
-				if (ret & VM_FAULT_WRITE)
+				if (ret & VM_FAULT_WRITE) {
 					foll_flags &= ~FOLL_WRITE;
+					cow = 1;
+				}
 
 				cond_resched();
 			}
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -346,7 +346,7 @@ static int dup_mmap(struct mm_struct *mm
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		retval = copy_page_range(mm, oldmm, mpnt);
+		retval = copy_page_range(mm, oldmm, tmp);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
