Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A571B6B0096
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:45:53 -0400 (EDT)
Date: Tue, 25 Aug 2009 21:45:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
Message-ID: <20090825194530.GU14722@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
 <20090825145832.GP14722@random.random>
 <20090825152217.GQ14722@random.random>
 <Pine.LNX.4.64.0908251836050.30372@sister.anvils>
 <20090825181019.GT14722@random.random>
 <Pine.LNX.4.64.0908251958170.5871@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908251958170.5871@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, "Justin M. Forbes" <jmforbes@linuxtx.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 07:58:43PM +0100, Hugh Dickins wrote:
> On Tue, 25 Aug 2009, Andrea Arcangeli wrote:
> > On Tue, Aug 25, 2009 at 06:49:09PM +0100, Hugh Dickins wrote:
> > Looking ksm.c it should have been down_write indeed...
> > 
> > > Nor do we want to change your down_read here to down_write, that will
> > > just reintroduce the OOM deadlock that 9/12 was about solving.
> > 
> > I'm not sure anymore I get what this fix is about...
> 
> Yes, it's easy to drop one end of the string while picking up the other ;)
> 
> And it wouldn't be exactly the same deadlock, but similar.
> The original deadlock that 9/12 was about was:
>     There's a now-obvious deadlock in KSM's out-of-memory handling:
>     imagine ksmd or KSM_RUN_UNMERGE handling, holding ksm_thread_mutex,
>     trying to allocate a page to break KSM in an mm which becomes the
>     OOM victim (quite likely in the unmerge case): it's killed and goes
>     to exit, and hangs there waiting to acquire ksm_thread_mutex.

Yes I see that, that was before ksm was capable of noticing that it
was looping indefinitely triggering COW (allocating memory) on a mm
with mm_users == 0 selected by the OOM killer for release. Not true
anymore after ksm_test_exit is introduced in the KSM inner paths... I
mean that part of the fix is enough.

> Whereas with down_write(&mm->mmap_sem); up_write(&mm->mmap_sem)
> just before calling exit_mmap(), the deadlock comes on mmap_sem
> instead: the exiting OOM-killed task waiting there (for break_cow
> or the like to up_read mmap_sem), before it has freed any memory
> to allow break_cow etc. to proceed.

The whole difference is that now KSM will notice that mm_users is
already zero and it will release the mmap_sem promptly allowing
exit_mmap to run...

> Yes, but one of those checks that mm_users is 0 has to be lie below
> handle_mm_fault, because mm_users may go to 0 and exit_mmap proceed
> while one of handle_pte_fault's helpers is waiting to allocate a page
> (for example; but SMP could race anywhere).  Hence ksm_test_exit()s
> in mm/memory.c.

Hmm but you're trying here to perfect something that isn't needed to
be perfected... and that is a generic issue that always happens with
the OOM killer. I doesn't make any difference if it's KSM or the
application that triggered a page fault on the MM. If mmap_sem is hold
in read mode by a regular application page fault while OOM killer
fires, the exit_mmap routine will not run until the page fault is
complete. The SMP race anywhere is the reason the OOM killer has to
stop a moment before killing a second task to give a chance to the
task to run exit_mmap...

> (And as I remarked in the 9/12 comments, it's no use bumping up
> mm_users in break_ksm, say, though that would be a normal thing to
> do: that just ensures the memory we'd be waiting for cannot be freed.)

Yes, that would also prevent KSM to notice that the OOM killer
selected the mm for release. Well unless we check against mm_users ==
1, which only works as only as only ksm does that and no other driver
similar to KSM ;) so it's not a real solution...

> just an issue we've not yet found the right fix for ;)

I think you already did the right fix in simply doing ksm_test_exit
inside the KSM inner loops and adding as well a dummy
down_write;up_write in the ksm_exit case where rmap_items exists on
the mm_slot that is exiting. But there was no need of actually
teaching the page faults to bail out to react immediately to the OOM
killer (the task itself will not react immediately) and second
ksm_exit with its serializing down_write should be moved back before
exit_mmap and it will have the same effect of my previous patch with
down_write (s/read/write) just before exit_mmap.

> The idea I'm currently playing with, would fix one of your objections
> but violate another, is to remove the ksm_test_exit()s from mm/memory.c,
> allow KSM to racily fault in too late, but observe mm_users 0 afterwards
> and zap it then.

;)

> I agree with you that it seems _wrong_ for KSM to fault into an area
> being exited, which was why the ksm_test_exit()s; but the neatest
> answer might turn out to be to allow it to do so after all.

Hmm no... I think it's definitely asking for troubles, I would agree
with you if an immediate reaction to OOM killer would actually provide
any benefit, but I don't see the benefit, and this makes exit_mmap
simpler, and it avoids messing with tlb_gather and putting a
definitive stop on KSM before pagetables are freed.

I did this new patch what you think? And any further change in the
anti-oom-deadlock area if still needed, should reside on ksm.c.

--------
From: Andrea Arcangeli <aarcange@redhat.com>

Allowing page faults triggered by drivers tracking the mm during
exit_mmap with mm_users already zero is asking for troubles. And we
can't stop page faults from happening during exit_mmap or munlock fails
(munlock also better stop triggering page faults with mm_users zero).

ksm_exit if there are rmap_items still chained on this mm slot, will
take mmap_sem write side so preventing ksm to keep working on a mm while
exit_mmap runs. And ksm will bail out as soon as it notices that
mm_users is already zero thanks to the ksm_test_exit checks. So that
when a task is killed by OOM killer or the user, ksm will not
indefinitely prevent it to run exit_mmap and release its memory. 

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 2d64ff3..0e26de6 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -18,8 +18,7 @@ struct mmu_gather;
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
-void __ksm_exit(struct mm_struct *mm,
-		struct mmu_gather **tlbp, unsigned long end);
+void __ksm_exit(struct mm_struct *mm);
 
 static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
@@ -41,11 +40,10 @@ static inline bool ksm_test_exit(struct mm_struct *mm)
 	return atomic_read(&mm->mm_users) == 0;
 }
 
-static inline void ksm_exit(struct mm_struct *mm,
-			    struct mmu_gather **tlbp, unsigned long end)
+static inline void ksm_exit(struct mm_struct *mm)
 {
 	if (test_bit(MMF_VM_MERGEABLE, &mm->flags))
-		__ksm_exit(mm, tlbp, end);
+		__ksm_exit(mm);
 }
 
 /*
@@ -86,8 +84,7 @@ static inline bool ksm_test_exit(struct mm_struct *mm)
 	return 0;
 }
 
-static inline void ksm_exit(struct mm_struct *mm,
-			    struct mmu_gather **tlbp, unsigned long end)
+static inline void ksm_exit(struct mm_struct *mm)
 {
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 9a16c21..6f93809 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -515,6 +515,7 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		exit_aio(mm);
+		ksm_exit(mm);
 		exit_mmap(mm);
 		set_mm_exe_file(mm, NULL);
 		if (!list_empty(&mm->mmlist)) {
diff --git a/mm/ksm.c b/mm/ksm.c
index d03627f..329ebe9 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1428,8 +1428,7 @@ int __ksm_enter(struct mm_struct *mm)
 	return 0;
 }
 
-void __ksm_exit(struct mm_struct *mm,
-		struct mmu_gather **tlbp, unsigned long end)
+void __ksm_exit(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
 	int easy_to_free = 0;
@@ -1462,10 +1461,8 @@ void __ksm_exit(struct mm_struct *mm,
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
 		mmdrop(mm);
 	} else if (mm_slot) {
-		tlb_finish_mmu(*tlbp, 0, end);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
-		*tlbp = tlb_gather_mmu(mm, 1);
 	}
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 4a2c60d..025431e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2603,7 +2603,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_none(*page_table) || ksm_test_exit(mm))
+	if (!pte_none(*page_table))
 		goto release;
 
 	inc_mm_counter(mm, anon_rss);
@@ -2753,7 +2753,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte) && !ksm_test_exit(mm))) {
+	if (likely(pte_same(*page_table, orig_pte))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
diff --git a/mm/mmap.c b/mm/mmap.c
index 1b0a709..f3f2a22 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2111,13 +2111,6 @@ void exit_mmap(struct mm_struct *mm)
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 
-	/*
-	 * For KSM to handle OOM without deadlock when it's breaking COW in a
-	 * likely victim of the OOM killer, we must serialize with ksm_exit()
-	 * after freeing mm's pages but before freeing its page tables.
-	 */
-	ksm_exit(mm, &tlb, end);
-
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
