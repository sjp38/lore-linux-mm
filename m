Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 26C026B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 21:03:59 -0400 (EDT)
Date: Thu, 2 Jun 2011 02:03:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110602010352.GD7306@suse.de>
References: <20110530175334.GI19505@random.random>
 <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110601005747.GC7019@csn.ul.ie>
 <20110601175809.GB7306@suse.de>
 <20110601191529.GY19505@random.random>
 <20110601214018.GC7306@suse.de>
 <20110601233036.GZ19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110601233036.GZ19505@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Thu, Jun 02, 2011 at 01:30:36AM +0200, Andrea Arcangeli wrote:
> Hi Mel,
> 
> On Wed, Jun 01, 2011 at 10:40:18PM +0100, Mel Gorman wrote:
> > On Wed, Jun 01, 2011 at 09:15:29PM +0200, Andrea Arcangeli wrote:
> > > On Wed, Jun 01, 2011 at 06:58:09PM +0100, Mel Gorman wrote:
> > > > Umm, HIGHMEM4G implies a two-level pagetable layout so where are
> > > > things like _PAGE_BIT_SPLITTING being set when THP is enabled?
> > > 
> > > They should be set on the pgd, pud_offset/pgd_offset will just bypass.
> > > The splitting bit shouldn't be special about it, the present bit
> > > should work the same.
> > 
> > This comment is misleading at best then.
> > 
> > #define _PAGE_BIT_SPLITTING     _PAGE_BIT_UNUSED1 /* only valid on a PSE pmd */
> 
> From common code point of view it's set in the pmd, the comment can be
> extended to specify it's actually the pgd in case of 32bit noPAE but I
> didn't think it was too misleading as we think in common code terms
> all over the code, the fact it's a bypass is pretty clear across the
> whole archs.
> 

Fair point.

> > At the PGD level, it can have PSE set obviously but it's not a
> > PMD. I confess I haven't checked the manual to see if it's safe to
> > use _PAGE_BIT_UNUSED1 like this so am taking your word for it. I
> 
> To be sure I re-checked on 253668.pdf page 113/114 noPAE and page 122
> PAE, on x86 32bit/64 all ptes/pmd/pgd (32bit/64bit PAE/noPAE) have bit
> 9-11 "Avail" to software. So I think we should be safe here.
> 

Good stuff. I was reasonably sure this was the case but as this was
already "impossible", it needed to be ruled out.

> > found that the bug is far harder to reproduce with 3 pagetable levels
> > than with 2 but that is just timing. So far it has proven impossible
> > on x86-64 at least within 27 hours so that has me looking at how
> > pagetable management between x86 and x86-64 differ.
> 
> Weird.
> 
> However I could see it screwing the nr_inactive/active_* stats, but
> the nr_isolated should never go below zero, and especially not anon
> even if split_huge_page does the accounting wrong (and
> migrate/compaction won't mess with THP), or at least I'd expect things
> to fall apart in other ways and not with just a fairly innocuous and
> not-memory corrupting nr_isolated_ counter going off just by one.
> 

Again, agreed. I found it hard to come up with a reason why file would
get messed up particularly as PageSwapBacked does not get cleared in the
ordinary case until the page is freed. If we were using pages after
being freed due to bad refcounting, it would show up in all sorts of bad
ways.

> The khugepaged nr_isolated_anon increment couldn't affect the file one
> and we hold mmap_sem write mode there to prevent the pte to change
> from under us, in addition to the PT and anon_vma lock. Anon_vma lock
> being wrong sounds unlikely too, and even if it was it should screw
> the nr_isolated_anon counter, impossible to screw the nr_isolated_file
> with khugepaged.
> 

After reviewing, I still could not find a problem with the locking that
might explain this. I thought last night anon_vma might be bust in some
way but today I couldn't find a problem.

> Where did you put your bugcheck? It looked like you put it in the < 0
> reader, can you add it to all _inc/dec/mod (even _inc just in case) so
> we may get a stack trace including the culprit? (not guaranteed but
> better chance)
> 

Did that, didn't really help other than showing the corruption happens
early in the process lifetime while huge PMDs are being faulted. This
made me think the problem might be on or near fork.

> > Barriers are a big different between how 32-bit !SMP and X86-64 but
> > don't know yet which one is relevant or if this is even the right
> > direction.
> 
> The difference is we need xchg on SMP to avoid losing the dirty
> bit. Otherwise if we do pmd_t pmd = *pmdp; *pmdp = 0; the dirty bit
> may have been set in between the two by another thread running in
> userland in a different CPU, while the pmd was still "present". As
> long as interrupts don't write to read-write userland memory with the
> pte dirty bit clear, we shouldn't need xchg on !SMP.
> 

Yep.

> On PAE we also need to write 0 into pmd_low before worrying about
> pmd_high so the present bit is cleared before clearing the high part
> of the 32bit PAE pte, and we relay on xchg implicit lock to avoid a
> smp_wmb() in between the two writes.
> 

Yep.

> I'm unsure if any of this could be relevant to our problem, also there

I concluded after a while that it wasn't. Partially from reasoning about
it and part by testing forcing the use of the SMP versions and finding
the bug was still reproducible.

> can't be more than one writer at once in the pmd, as nobody can modify
> it without the page_table_lock held. xchg there is just to be safe for
> the dirty bit (or we'd corrupt memory with threads running in userland
> and writing to memory on other cpus while we ptep_clear_flush).
> 
> I've been wondering about the lack of "lock" on the bus in atomic.h
> too, but I can't see how it can possibly matter on !SMP, vmstat
> modifications should execute only 1 asm insn so preempt or irq can't
> interrupt it.

To be honest, I haven't fully figured out yet why it makes such
a difference on !SMP. I have a vague notion that it's because
the page table page and the data is visible before the bit set by
SetPageSwapBacked on the struct page is visible but haven't reasoned
it out yet. If this was the case, it might allow an "anon" page to
be treated as a file by compaction for accounting purposes and push
the counter negative but you'd think then the anon isolation would
be positive so it's something else.

As I thought fork() be an issue, I looked closer at what we do
there. We are calling pmd_alloc at copy_pmd_range which is a no-op
when PMD is folded and copy_huge_pmd() is calling pte_alloc_one()
which also has no barrier. I haven't checked this fully (it's very
late again as I wasn't able to work on this during most of the day)
but I wonder if it's then possible the PMD setup is not visible before
insertion into the page table leading to weirdness? Why it matters to
SMP is unclear unless this is a preemption thing I'm not thinking of.

On a similar vein, during collapse_huge_page(), we use a barrier
to ensure the data copy is visible before the PMD insertion but in
__do_huge_pmd_anonymous_page(), we assume the "spinlocking to take the
lru_lock inside page_add_new_anon_rmap() acts as a full memory". Thing
is, it's calling lru_cache_add_lru() adding the page to a pagevec
which is not necessarily taking the LRU lock and !SMP is leaving a
big enough race before the pagevec gets drained to cause a problem.
Of course, maybe it *is* happening on SMP but the negative counters
are being reported as zero :)

To see if this is along the right lines, I'm currently testing with
this patch against 2.6.38.4. It hasn't blown up in 35 minutes which
is an improvement over getting into trouble after 5 so I'll leave
it running overnight and see can I convince myself of what is going
on tomorrow.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2d29c9a..65fa251 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -631,12 +631,14 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		entry = mk_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		entry = pmd_mkhuge(entry);
+
 		/*
-		 * The spinlocking to take the lru_lock inside
-		 * page_add_new_anon_rmap() acts as a full memory
-		 * barrier to be sure clear_huge_page writes become
-		 * visible after the set_pmd_at() write.
+		 * Need a write barrier to ensure the writes from
+		 * clear_huge_page become visible before the
+		 * set_pmd_at
 		 */
+		smp_wmb();
+
 		page_add_new_anon_rmap(page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		prepare_pmd_huge_pte(pgtable, mm);
@@ -753,6 +755,13 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
+
+	/*
+	 * Write barrier to make sure the setup for the PMD is fully visible
+	 * before the set_pmd_at
+	 */
+	smp_wmb();
+
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 	prepare_pmd_huge_pte(pgtable, dst_mm);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
