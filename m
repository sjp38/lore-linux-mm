Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB0D8D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 02:13:27 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p0I7DPbN002634
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 23:13:25 -0800
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz17.hot.corp.google.com with ESMTP id p0I7DJsN018149
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 23:13:23 -0800
Received: by pvg7 with SMTP id 7so1752703pvg.22
        for <linux-mm@kvack.org>; Mon, 17 Jan 2011 23:13:19 -0800 (PST)
Date: Mon, 17 Jan 2011 23:12:57 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
In-Reply-To: <20101126143843.801484792@chello.nl>
Message-ID: <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
References: <20101126143843.801484792@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Nov 2010, Peter Zijlstra wrote:
> This patch-set makes part of the mm a lot more preemptible. It converts
> i_mmap_lock and anon_vma->lock to mutexes and makes mmu_gather fully
> preemptible.
> 
> The main motivation was making mm_take_all_locks() preemptible, since it
> appears people are nesting hundreds of spinlocks there.
> 
> The side-effects are that can finally make mmu_gather preemptible,
> something which lots of people have wanted to do for a long time.
> 
> It also gets us anon_vma refcounting, which seems to result in a nice
> cleanup of the anon_vma lifetime rules wrt KSM and compaction.
> 
> This patch-set is build and boot-tested on x86_64 (a previous version was
> also tested on Dave's Niagra2 machines, and I suppose s390 was too when
> Martin provided the conversion patch for his arch).
> 
> There are no known architectures left unconverted.
> 
> Yanmin ran the -v3 posting through the comprehensive Intel test farm
> and didn't find any regressions.
> 
> ( Not included in this posting are the 4 Sparc64 patches that implement
>   gup_fast, those can be applied separately after this series gets
>   anywhere. )
> 
> The full series (including the Sparc64 gup_fast bits) also available in -git
> form from (against Linus' tree as of about an hour ago):
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/peterz/linux-2.6-mmu_preempt.git

Hi Peter,

I understand you're intending to update your preemptible mmu_gather
patchset against 2.6.38-rc1, so I've spent a while looking through
(and running) your last posted version (plus its two fixes from BenH).

I've had no problems in running it, I can't tell if it's quicker or
slower than the unpatched.  The only argument against the patchset,
really, would be performance: and though there are no bad reports on
it as yet, I do wonder how we proceed if a genuine workload shows up
which is adversely affected.  Oh well, silly to worry about the
hypothetical I suppose.

There's a few minor cleanups I'd hoped for (things like removing the
start and end args from tlb_finish_mmu), but you're quite right to
have stayed on course and not strayed down that path.

However, there's one more-than-cleanup that I think you will need to add:
the ZAP_BLOCK_SIZE zap_work stuff is still there, but I think it needs
to be removed now, with the need_resched() and other checks moved down
from unmap_vmas() to inside the pagetable spinlock in zap_pte_range().

Because you're now accumulating more work than ever in the mmu_gather's
buffer, and the more so with the 20/21 extended list: but this amounts
to a backlog of work which will *usually* be done at the tlb_finish_mmu,
but when memory is low (no extra buffers) may need flushing earlier -
as things stand, while holding the pagetable spinlock, so introducing
a large unpreemptible latency under those conditions.

I believe that along with the need_resched() check moved inside
zap_pte_range(), you need to check if the mmu_gather buffer is full,
and if so drop pagetable spinlock while you flush it.  Hmm, but if
it's extensible, then it wasn't full: I've not worked out how this
would actually fit together.

(I also believe that when memory is low, we *ought* to be freeing up
the pages sooner: perhaps all the GFP_ATOMICs should be GFP_NOWAITs.)

I found patch ordering a bit odd: I'm going to comment on them in
what seems a more natural ordering to me: if Andrew folds your 00
comments into 01 as he usually does, then I'd rather see them on the
main preemptible mmu_gather patch, than on reverting some anon_vma
annotations!  And with anon_vma->lock already nested inside i_mmap_lock,
I think the anon_vma mods are secondary, and can just follow after.

08/21 mm-preemptible_mmu_gather.patch
      Acked-by: Hugh Dickins <hughd@google.com>
      But I'd prefer __tlb_alloc_pages() be named __tlb_alloc_page(),
      and think it should pass __GFP_NOWARN with its GFP_ATOMIC (same
      remark would apply in several other patches too).

09/21 powerpc-preemptible_mmu_gather.patch
      I'll leave Acking to Ben, but it looked okay so far as I could tell.
      I worry how much (unpreemptible) work happens in __flush_tlb_pending
      in __switch_to, whether PPC64_TLB_BATCH_NR 192 ought to be smaller
      now (I wonder where 192 came from originally); move the _TLF_LAZY_MMU
      block below _switch() to after the local_irq_restore(flags)?
      The mods to hpte_need_flush() look like what we need in 2.6.37-stable
      to keep CONFIG_DEBUG_PREEMPT vfree() quiet, perhaps should be separated
      out - but perhaps they're inappropriate and Ben has another fix in mind.

10/21 sparc-preemptible_mmu_gather.patch
      Similarly, looked okay so far as I could tell, and this one was
      already doing flush_tlb_pending in switch_to; more of the 192
      (not from you, of course).  tlb_batch_add() has some commented-out
      (tb->fullmm) code that you probably meant to come back to.
      mm/init_32.c still has DEFINE_PER_CPU(struct mmu_gather, mmu_gathers).

11/21 s390-preemptible_mmu_gather.patch
      I'd prefer __tlb_alloc_page(), with __GFP_NOWARN as suggested above.
      mm/pgtable.c still has DEFINE_PER_CPU(struct mmu_gather, mmu_gathers).

12/21 arm-preemptible_mmu_gather.patch
13/21 sh-preemptible_mmu_gather.patch
14/21 um-preemptible_mmu_gather.patch
15/21 ia64-preemptible_mmu_gather.patch
      All straightforward, but DEFINE_PER_CPU(struct mmu_gather, mmu_gathers)
      still to be removed from these and other arches.

16/21 mm_powerpc-move_the_rcu_page-table_freeing_into.patch
      Seems good, prefer Ben and Dave to Ack.  "copmletion" -> "completion".

17/21 lockdep_mutex-provide_mutex_lock_nest_lock.patch
      Okay by me.

18/21 mutex-provide_mutex_is_contended.patch
      I suppose so, though if we use it in the truncate path, then we are
      stuck with the vm_truncate_count stuff I'd rather hoped would go away;
      but I guess you're right, that if we did spin_needbreak/need_lockbreak
      before, then we ought to do this now - though I suspect I only added
      it because I had to insert a resched-point anyway, and it seemed a good
      idea at the time to check lockbreak too since that had just been added.

19/21 mm-convert_i_mmap_lock_and_anon_vma-_lock_to_mutexes.patch
      I suggest doing just the i_mmap_lock->mutex conversion at this point.
      Acked-by: Hugh Dickins <hughd@google.com>
      except that in the past we have renamed a lock when we've done this
      kind of conversion, so I'd expect i_mmap_mutex throughout now.
      Or am I just out of date?  I don't feel very strongly about it.

20/21 mm-extended_batches_for_generic_mmu_gather.patch
      Acked-by: Hugh Dickins <hughd@google.com>
      though it struck me as overdesign at first: I guess Nick wanted it
      because he had an implementation that used the pagetables themselves,
      hence an assured supply of these buffers.  tlb_finish_mmu(), and
      perhaps others, looking rather too big for inline by this stage.

01/21 mm-revert_page_lock_anon_vma_lock_annotation.patch
      Acked-by: Hugh Dickins <hughd@google.com>

02/21 powerpc-use_call_rcu_sched_for_pagetables.patch
      Already went into 2.6.37

03/21 mm-improve_page_lock_anon_vma_comment.patch
      Acked-by: Hugh Dickins <hughd@google.com>

04/21 mm-rename_drop_anon_vma_to_put_anon_vma.patch
      Acked-by: Hugh Dickins <hughd@google.com>
      but (if you don't mind: leave it to me if you prefer) in mm/ksm.c
      please just remove wrappers hold_anon_vma() and ksm_put_anon_vma():
      they had a point when they originated the refcount but no point now.
      Note there are now two places to update in mm/migrate.c in 38-rc1.

05/21 mm-move_anon_vma_ref_out_from_under_config_ksm.patch
      Acked-by: Hugh Dickins <hughd@google.com>
      but you shouldn't need to touch mm/migrate.c again here with 38-rc1.
      Didn't you end up double-decrementing refcount in the huge_page case?

06/21 mm-simplify_anon_vma_refcounts.patch
      Acked-by: Hugh Dickins <hughd@google.com>
      except page_get_anon_vma() is being declared in rmap.h a patch early,
      and you shouldn't need to touch mm/ksm.c again here with 38-rc1.
      Did wonder if __put_anon_vma() is right to put anon_vma->root *before*
      freeing anon_vma, but suppose your not_zero strictness makes it safe.

07/21 mm-use_refcounts_for_page_lock_anon_vma.patch
      Acked-by: Hugh Dickins <hughd@google.com>
      but here I'm expecting you to use your page_get_anon_vma() in
      mm/migrate.c too, to replace my 38-rc1 lock/get/unlock sequences.
      Second page_mapped() test in page_get_anon_vma(): remove "goto out;"
      from that block, it's already reached "out".  In patch description,
      didn't understand "for each of convertion": "for sake of conversion"?
      This brings us to a nice point, ready for the lock->mutex conversion:
      the only defect being the doubled atomics in page_(un)lock_anon_vma.

19/21 mm-convert_i_mmap_lock_and_anon_vma-_lock_to_mutexes.patch
      I suggest doing the anon_vma lock->mutex conversion separately here.
      Acked-by: Hugh Dickins <hughd@google.com>
      except that in the past we have renamed a lock when we've done this
      kind of conversion, so I'd expect anon_vma->mutex throughout now.
      Or am I just out of date?  I don't feel very strongly about it.
      
21/21 mm-optimize_page_lock_anon_vma_fast-path.patch
      I certainly see the call for this patch, I want to eliminate those
      doubled atomics too.  This appears correct to me, and I've not dreamt
      up an alternative; but I do dislike it, and I suspect you don't like
      it much either.  I'm ambivalent about it, would love a better patch.

sparc64-Kill_page_table_quicklists.patch
sparc64-Use_RCU_page_table_freeing.patch
sparc64-Add_support_for__PAGE_SPECIA.patch
sparc64-Implement_get_user_pages_fast.patch
      I did not spend very long looking at these, none of my business really!
      but did notice one thing I didn't like, that pte_special() is declared
      unsigned long in the third, whereas int in every other architecture. I
      think it should follow the ia64-style there, use != 0 to return an int.

A few checkpatch warnings, many of which I don't particularly agree with -
though I do get annoyed by comments going over 80-cols without any need!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
