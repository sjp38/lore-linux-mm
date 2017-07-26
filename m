Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20CA16B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:43:12 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 125so204637443pgi.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 22:43:12 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q26si8948517pfi.408.2017.07.25.22.43.10
        for <linux-mm@kvack.org>;
        Tue, 25 Jul 2017 22:43:10 -0700 (PDT)
Date: Wed, 26 Jul 2017 14:43:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170726054306.GA11100@bbox>
References: <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
 <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
 <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
 <20170724095832.vgvku6vlxkv75r3k@suse.de>
 <20170725073748.GB22652@bbox>
 <20170725085132.iysanhtqkgopegob@suse.de>
 <20170725091115.GA22920@bbox>
 <20170725100722.2dxnmgypmwnrfawp@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725100722.2dxnmgypmwnrfawp@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 25, 2017 at 11:10:06AM +0100, Mel Gorman wrote:
> On Tue, Jul 25, 2017 at 06:11:15PM +0900, Minchan Kim wrote:
> > On Tue, Jul 25, 2017 at 09:51:32AM +0100, Mel Gorman wrote:
> > > On Tue, Jul 25, 2017 at 04:37:48PM +0900, Minchan Kim wrote:
> > > > > Ok, as you say you have reproduced this with corruption, I would suggest
> > > > > one path for dealing with it although you'll need to pass it by the
> > > > > original authors.
> > > > > 
> > > > > When unmapping ranges, there is a check for dirty PTEs in
> > > > > zap_pte_range() that forces a flush for dirty PTEs which aims to avoid
> > > > > writable stale PTEs from CPU0 in a scenario like you laid out above.
> > > > > 
> > > > > madvise_free misses a similar class of check so I'm adding Minchan Kim
> > > > > to the cc as the original author of much of that code. Minchan Kim will
> > > > > need to confirm but it appears that two modifications would be required.
> > > > > The first should pass in the mmu_gather structure to
> > > > > madvise_free_pte_range (at minimum) and force flush the TLB under the
> > > > > PTL if a dirty PTE is encountered. The second is that it should consider
> > > > 
> > > > OTL: I couldn't read this lengthy discussion so I miss miss something.
> > > > 
> > > > About MADV_FREE, I do not understand why it should flush TLB in MADV_FREE
> > > > context. MADV_FREE's semantic allows "write(ie, dirty)" so if other thread
> > > > in parallel which has stale pte does "store" to make the pte dirty,
> > > > it's okay since try_to_unmap_one in shrink_page_list catches the dirty.
> > > > 
> > > 
> > > In try_to_unmap_one it's fine. It's not necessarily fine in KSM. Given
> > > that the key is that data corruption is avoided, you could argue with a
> > > comment that madv_free doesn't necesssarily have to flush it as long as
> > > KSM does even if it's clean due to batching.
> > 
> > Yes, I think it should be done in side where have a concern.
> > Maybe, mm_struct can carry a flag which indicates someone is
> > doing the TLB bacthing and then KSM side can flush it by the flag.
> > It would reduce unncessary flushing.
> > 
> 
> If you're confident that it's only necessary on the KSM side to avoid the
> problem then I'm ok with that. Update KSM in that case with a comment
> explaining the madv_free race and why the flush is unconditionally
> necessary. madv_free only came up because it was a critical part of having
> KSM miss a TLB flush.
> 
> > > Like madvise(), madv_free can potentially return with a stale PTE visible
> > > to the caller that observed a pte_none at the time of madv_free and uses
> > > a stale PTE that potentially allows a lost write. It's debatable whether
> > 
> > That is the part I cannot understand.
> > How does it lost "the write"? MADV_FREE doesn't discard the memory so
> > finally, the write should be done sometime.
> > Could you tell me more?
> > 
> 
> I'm relying on the fact you are the madv_free author to determine if
> it's really necessary. The race in question is CPU 0 running madv_free
> and updating some PTEs while CPU 1 is also running madv_free and looking
> at the same PTEs. CPU 1 may have writable TLB entries for a page but fail
> the pte_dirty check (because CPU 0 has updated it already) and potentially
> fail to flush. Hence, when madv_free on CPU 1 returns, there are still
> potentially writable TLB entries and the underlying PTE is still present
> so that a subsequent write does not necessarily propagate the dirty bit
> to the underlying PTE any more. Reclaim at some unknown time at the future
> may then see that the PTE is still clean and discard the page even though
> a write has happened in the meantime. I think this is possible but I could
> have missed some protection in madv_free that prevents it happening.

Thanks for the detail. You didn't miss anything. It can happen and then
it's really bug. IOW, if application does write something after madv_free,
it must see the written value, not zero.

How about adding [set|clear]_tlb_flush_pending in tlb batchin interface?
With it, when tlb_finish_mmu is called, we can know we skip the flush
but there is pending flush, so flush focefully to avoid madv_dontneed
as well as madv_free scenario.

Also, KSM can know it through mm_tlb_flush_pending?
If it's acceptable, need to look into soft dirty to use [set|clear]_tlb
_flush_pending or TLB gathering API.

To show my intention:

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 8afa4335e5b2..fffd4d86d0c4 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -113,7 +113,7 @@ struct mmu_gather {
 #define HAVE_GENERIC_MMU_GATHER
 
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end);
-void tlb_flush_mmu(struct mmu_gather *tlb);
+bool tlb_flush_mmu(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
 							unsigned long end);
 extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
diff --git a/mm/ksm.c b/mm/ksm.c
index 4dc92f138786..0fbbd5d234d5 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1037,8 +1037,9 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 	if (WARN_ONCE(!pvmw.pte, "Unexpected PMD mapping?"))
 		goto out_unlock;
 
-	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
-	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte))) {
+	if ((pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
+	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte))) ||
+		mm_tlb_flush_pending(mm)) {
 		pte_t entry;
 
 		swapped = PageSwapCache(page);
diff --git a/mm/memory.c b/mm/memory.c
index ea9f28e44b81..d5c5e6497c70 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -239,12 +239,13 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 	tlb->page_size = 0;
 
 	__tlb_reset_range(tlb);
+	set_tlb_flush_pending(tlb->mm);
 }
 
-static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+static bool tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	if (!tlb->end)
-		return;
+		return false;
 
 	tlb_flush(tlb);
 	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
@@ -252,6 +253,7 @@ static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 	tlb_table_flush(tlb);
 #endif
 	__tlb_reset_range(tlb);
+	return true;
 }
 
 static void tlb_flush_mmu_free(struct mmu_gather *tlb)
@@ -265,10 +267,16 @@ static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 	tlb->active = &tlb->local;
 }
 
-void tlb_flush_mmu(struct mmu_gather *tlb)
+/*
+ * returns true if tlb flush really happens
+ */
+bool tlb_flush_mmu(struct mmu_gather *tlb)
 {
-	tlb_flush_mmu_tlbonly(tlb);
+	bool ret;
+
+	ret = tlb_flush_mmu_tlbonly(tlb);
 	tlb_flush_mmu_free(tlb);
+	return ret;
 }
 
 /* tlb_finish_mmu
@@ -278,8 +286,11 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
 	struct mmu_gather_batch *batch, *next;
+	bool flushed = tlb_flush_mmu(tlb);
 
-	tlb_flush_mmu(tlb);
+	clear_tlb_flush_pending(tlb->mm);
+	if (!flushed && mm_tlb_flush_pending(tlb->mm))
+		flush_tlb_mm_range(tlb->mm, start, end, 0UL);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();


> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
