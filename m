Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 01C886B0044
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 10:27:56 -0500 (EST)
Date: Thu, 18 Dec 2008 16:29:52 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-ID: <20081218152952.GW24856@random.random>
References: <491DAF8E.4080506@quantum.com> <200811191526.00036.nickpiggin@yahoo.com.au> <20081119165819.GE19209@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081119165819.GE19209@random.random>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 19, 2008 at 05:58:19PM +0100, Andrea Arcangeli wrote:
> On Wed, Nov 19, 2008 at 03:25:59PM +1100, Nick Piggin wrote:
> > The solution either involves synchronising forks and get_user_pages,
> > or probably better, to do copy on fork rather than COW in the case
> > that we detect a page is subject to get_user_pages. The trick is in
> > the details :)
> 
> We already have a patch that works.

Here it is below, had to produce it for rhel (so far it was only in
our minds and it didn't float around just yet).

So this fixes the reported bug for me, Tim can you check to be sure?
Very convenient that I didn't need to write the reproducer myself,
this was a very nice testcase thanks a lot, probably worth adding to
ltp ;).

Problem this only fixes it for rhel and other kernels that don't have
get_user_pages_fast yet. You really have to think at some way to
serialize get_user_pages_fast for this and ksm. get_user_pages_fast
makes it a unfixable bug to mark any anon pte from readwrite to
readonly when there could be O_DIRECT on it, this has to be solved
sooner or later...

So last detail, I take it as safe not to check if the pte is writeable
after handle_mm_fault returns as the new address space is private and
the page fault couldn't possibly race with anything (i.e. pte_same is
guaranteed to succeed). For the mainline version we can remove the
page lock and replace with smb_wmb in add_to_swap_cache and smp_rmb in
the page_count/PG_swapcache read to remove that trylockpage. Given
smp_wmb is barrier() it should worth it.

If you see something wrong during review below let me know, this is a
tricky place to change. Note the ->open done after copy_page_range
returns in fork, do_wp_page will run and copy anon pages before ->open
is run on the child vma, given those are anon pages I think it should
work but said that I doubt I exercised in practice any device driver
open method there yet. Thanks!

------
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: fork-o_direct-race

Think a thread writing constantly to the last 512bytes of a page, while another
thread read and writes to/from the first 512bytes of the page. We can lose
O_DIRECT reads, the very moment we mark any pte wrprotected because a third
unrelated thread forks off a child.

This fixes it by never wprotecting anon ptes if there can be any direct I/O in
flight to the page, and by instantiating a readonly pte and triggering a COW in
the child. The only trouble here are O_DIRECT reads (writes to memory, read
from disk). Checking the page_count under the PT lock guarantees no
get_user_pages could be running under us because if somebody wants to write to
the page, it has to break any cow first and that requires taking the PT lock in
follow_page before increasing the page count.

The COW triggered inside fork will run while the parent pte is read-write, this
is not usual but that's ok as it's only a page copy and it doesn't modify the
page contents.

In the long term there should be a smp_wmb() in between page_cache_get and
SetPageSwapCache in __add_to_swap_cache and a smp_rmb in between the
PageSwapCache and the page_count() to remove the trylock op.

Fixed version of original patch from Nick Piggin.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff -ur rhel-5.2/kernel/fork.c x/kernel/fork.c
--- rhel-5.2/kernel/fork.c	2008-07-10 17:26:43.000000000 +0200
+++ x/kernel/fork.c	2008-12-18 15:57:31.000000000 +0100
@@ -368,7 +368,7 @@
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		retval = copy_page_range(mm, oldmm, mpnt);
+		retval = copy_page_range(mm, oldmm, tmp);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
diff -ur rhel-5.2/mm/memory.c x/mm/memory.c
--- rhel-5.2/mm/memory.c	2008-07-10 17:26:44.000000000 +0200
+++ x/mm/memory.c	2008-12-18 15:51:17.000000000 +0100
@@ -426,7 +426,7 @@
  * covered by this vma.
  */
 
-static inline void
+static inline int
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
 		unsigned long addr, int *rss)
@@ -434,6 +434,7 @@
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
 	struct page *page;
+	int forcecow = 0;
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
@@ -464,15 +465,6 @@
 	}
 
 	/*
-	 * If it's a COW mapping, write protect it both
-	 * in the parent and the child
-	 */
-	if (is_cow_mapping(vm_flags)) {
-		ptep_set_wrprotect(src_mm, addr, src_pte);
-		pte = *src_pte;
-	}
-
-	/*
 	 * If it's a shared mapping, mark it clean in
 	 * the child
 	 */
@@ -484,11 +476,34 @@
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page);
+		if (is_cow_mapping(vm_flags) && PageAnon(page)) {
+			if (unlikely(TestSetPageLocked(page)))
+				forcecow = 1;
+			else {
+				if (unlikely(page_count(page) !=
+					     page_mapcount(page)
+					     + !!PageSwapCache(page)))
+					forcecow = 1;
+				unlock_page(page);
+			}
+		}
 		rss[!!PageAnon(page)]++;
 	}
 
+	/*
+	 * If it's a COW mapping, write protect it both
+	 * in the parent and the child
+	 */
+	if (is_cow_mapping(vm_flags)) {
+		if (!forcecow)
+			ptep_set_wrprotect(src_mm, addr, src_pte);
+		pte = pte_wrprotect(pte);
+	}
+
 out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
+
+	return forcecow;
 }
 
 static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
@@ -499,8 +514,10 @@
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
 	int rss[2];
+	int forcecow;
 
 again:
+	forcecow = 0;
 	rss[1] = rss[0] = 0;
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
@@ -510,6 +527,9 @@
 	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 
 	do {
+		if (forcecow)
+			break;
+
 		/*
 		 * We are holding two locks at this point - either of them
 		 * could generate latencies in another task on another CPU.
@@ -525,7 +545,7 @@
 			progress++;
 			continue;
 		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		forcecow = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
@@ -534,6 +554,10 @@
 	add_mm_rss(dst_mm, rss[0], rss[1]);
 	pte_unmap_unlock(dst_pte - 1, dst_ptl);
 	cond_resched();
+	if (forcecow)
+		if (__handle_mm_fault(dst_mm, vma, addr - PAGE_SIZE, 1) &
+		    (VM_FAULT_OOM | VM_FAULT_SIGBUS))
+			return -ENOMEM;
 	if (addr != end)
 		goto again;
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
