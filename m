Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0526B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 20:34:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u7so188648058pgo.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:34:38 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c3si10781350pld.94.2017.07.26.17.34.35
        for <linux-mm@kvack.org>;
        Wed, 26 Jul 2017 17:34:36 -0700 (PDT)
Date: Thu, 27 Jul 2017 09:34:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170727003434.GA537@bbox>
References: <20170724095832.vgvku6vlxkv75r3k@suse.de>
 <20170725073748.GB22652@bbox>
 <20170725085132.iysanhtqkgopegob@suse.de>
 <20170725091115.GA22920@bbox>
 <20170725100722.2dxnmgypmwnrfawp@suse.de>
 <20170726054306.GA11100@bbox>
 <20170726092228.pyjxamxweslgaemi@suse.de>
 <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com>
 <20170726234025.GA4491@bbox>
 <60FF1876-AC4F-49BB-BC36-A144C3B6EA9E@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <60FF1876-AC4F-49BB-BC36-A144C3B6EA9E@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Jul 26, 2017 at 05:09:09PM -0700, Nadav Amit wrote:
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > Hello Nadav,
> > 
> > On Wed, Jul 26, 2017 at 12:18:37PM -0700, Nadav Amit wrote:
> >> Mel Gorman <mgorman@suse.de> wrote:
> >> 
> >>> On Wed, Jul 26, 2017 at 02:43:06PM +0900, Minchan Kim wrote:
> >>>>> I'm relying on the fact you are the madv_free author to determine if
> >>>>> it's really necessary. The race in question is CPU 0 running madv_free
> >>>>> and updating some PTEs while CPU 1 is also running madv_free and looking
> >>>>> at the same PTEs. CPU 1 may have writable TLB entries for a page but fail
> >>>>> the pte_dirty check (because CPU 0 has updated it already) and potentially
> >>>>> fail to flush. Hence, when madv_free on CPU 1 returns, there are still
> >>>>> potentially writable TLB entries and the underlying PTE is still present
> >>>>> so that a subsequent write does not necessarily propagate the dirty bit
> >>>>> to the underlying PTE any more. Reclaim at some unknown time at the future
> >>>>> may then see that the PTE is still clean and discard the page even though
> >>>>> a write has happened in the meantime. I think this is possible but I could
> >>>>> have missed some protection in madv_free that prevents it happening.
> >>>> 
> >>>> Thanks for the detail. You didn't miss anything. It can happen and then
> >>>> it's really bug. IOW, if application does write something after madv_free,
> >>>> it must see the written value, not zero.
> >>>> 
> >>>> How about adding [set|clear]_tlb_flush_pending in tlb batchin interface?
> >>>> With it, when tlb_finish_mmu is called, we can know we skip the flush
> >>>> but there is pending flush, so flush focefully to avoid madv_dontneed
> >>>> as well as madv_free scenario.
> >>> 
> >>> I *think* this is ok as it's simply more expensive on the KSM side in
> >>> the event of a race but no other harmful change is made assuming that
> >>> KSM is the only race-prone. The check for mm_tlb_flush_pending also
> >>> happens under the PTL so there should be sufficient protection from the
> >>> mm struct update being visible at teh right time.
> >>> 
> >>> Check using the test program from "mm: Always flush VMA ranges affected
> >>> by zap_page_range v2" if it handles the madvise case as well as that
> >>> would give some degree of safety. Make sure it's tested against 4.13-rc2
> >>> instead of mmotm which already includes the madv_dontneed fix. If yours
> >>> works for both then it supersedes the mmotm patch.
> >>> 
> >>> It would also be interesting if Nadav would use his slowdown hack to see
> >>> if he can still force the corruption.
> >> 
> >> The proposed fix for the KSM side is likely to work (I will try later), but
> >> on the tlb_finish_mmu() side, I think there is a problem, since if any TLB
> >> flush is performed by tlb_flush_mmu(), flush_tlb_mm_range() will not be
> >> executed. This means that tlb_finish_mmu() may flush one TLB entry, leave
> >> another one stale and not flush it.
> > 
> > Okay, I will change that part like this to avoid partial flush problem.
> > 
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 1c42d69490e4..87d0ebac6605 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -529,10 +529,13 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
> >  * The barriers below prevent the compiler from re-ordering the instructions
> >  * around the memory barriers that are already present in the code.
> >  */
> > -static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
> > +static inline int mm_tlb_flush_pending(struct mm_struct *mm)
> > {
> > +	int nr_pending;
> > +
> > 	barrier();
> > -	return atomic_read(&mm->tlb_flush_pending) > 0;
> > +	nr_pending = atomic_read(&mm->tlb_flush_pending);
> > +	return nr_pending;
> > }
> > static inline void set_tlb_flush_pending(struct mm_struct *mm)
> > {
> > diff --git a/mm/memory.c b/mm/memory.c
> > index d5c5e6497c70..b5320e96ec51 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -286,11 +286,15 @@ bool tlb_flush_mmu(struct mmu_gather *tlb)
> > void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
> > {
> > 	struct mmu_gather_batch *batch, *next;
> > -	bool flushed = tlb_flush_mmu(tlb);
> > 
> > +	if (!tlb->fullmm && !tlb->need_flush_all &&
> > +			mm_tlb_flush_pending(tlb->mm) > 1) {
> 
> I saw you noticed my comment about the access of the flag without a lock. I
> must say it feels strange that a memory barrier would be needed here, but
> that what I understood from the documentation.

I saw your recent barriers fix patch, too.
[PATCH v2 2/2] mm: migrate: fix barriers around tlb_flush_pending

As I commented out in there, I hope to use below here without being
aware of complex barrier stuff. Instead, mm_tlb_flush_pending should
call the right barrier inside.

        mm_tlb_flush_pending(tlb->mm, false:no-pte-locked) > 1

> 
> > +		tlb->start = min(start, tlb->start);
> > +		tlb->end = max(end, tlb->end);
> 
> Erra?| You open-code mmu_gather which is arch-specific. It appears that all of
> them have start and end members, but not need_flush_all. Besides, I am not

When I see tlb_gather_mmu which is not arch-specific, it intializes
need_flush_all to zero so it would be no harmful although some of
architecture doesn't set the flag.
Please correct me if I miss something.

> sure whether they regard start and end the same way.

I understand your worry but my patch takes longer range by min/max
so I cannot imagine how it breaks. During looking the code, I found
__tlb_adjust_range so better to use it rather than open-code.


diff --git a/mm/memory.c b/mm/memory.c
index b5320e96ec51..b23188daa396 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -288,10 +288,8 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long e
 	struct mmu_gather_batch *batch, *next;
 
 	if (!tlb->fullmm && !tlb->need_flush_all &&
-			mm_tlb_flush_pending(tlb->mm) > 1) {
-		tlb->start = min(start, tlb->start);
-		tlb->end = max(end, tlb->end);
-	}
+			mm_tlb_flush_pending(tlb->mm) > 1)
+		__tlb_adjust_range(tlb->mm, start, end - start);
 
 	tlb_flush_mmu(tlb);
 	clear_tlb_flush_pending(tlb->mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
