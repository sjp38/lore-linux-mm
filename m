Date: Tue, 29 Jan 2008 14:39:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080129220212.GX7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com>
 <20080129162004.GL7233@v2.random> <Pine.LNX.4.64.0801291153520.25300@schroedinger.engr.sgi.com>
 <20080129211759.GV7233@v2.random> <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com>
 <20080129220212.GX7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

n Tue, 29 Jan 2008, Andrea Arcangeli wrote:

> hmm, "there" where? When I said it was taken in readonly mode I meant
> for the quoted code (it would be at the top if it wasn't cut), so I
> quote below again:
> 
> > > +   mmu_notifier(invalidate_range, mm, address,
> > > +                           address + PAGE_SIZE - 1, 0);
> > >     page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> > >     if (likely(pte_same(*page_table, orig_pte))) {
> > >             if (old_page) {
> 
> The "there" for me was do_wp_page.

Maybe we better focus on one call at a time?

> Even for the code you quoted in freemap.c, the has_write_lock is set
> to 1 _only_ for the very first time you call sys_remap_file_pages on a
> VMA. Only the transition of the VMA between linear to nonlinear
> requires the mmap in write mode. So you can be sure all freemap code
> 99% of the time is populating (overwriting) already present ptes with
> only the mmap_sem in readonly mode like do_wp_page. It would be
> unnecessary to populate the nonlinear range with the mmap in write
> mode. Only the "vma" mangling requires the mmap_sem in write mode, the
> pte modifications only requires the PT_lock + mmap_sem in read mode.
> 
> Effectively the first invocation of populate_range runs with the
> mmap_sem in write mode, I wonder why, there seem to be no good reason
> for that. I guess it's a bit that should be optimized, by calling
> downgrade_write before calling populate_range even for the first time
> the vma switches from linear to nonlinear (after the vma has been
> fully updated to the new status). But for sure all later invocations
> runs populate_range with the semaphore readonly like the rest of the
> VM does when instantiating ptes in the page faults.

If it does not run in write mode then concurrent faults are permissible 
while we remap pages. Weird. Maybe we better handle this like individual
page operations? Put the invalidate_page back into zap_pte. But then there 
would be no callback w/o lock as required by Robin. Doing the 
invalidate_range after populate allows access to memory for which ptes 
were zapped and the refcount was released.

> All pins are gone by the time invalidate_page/range returns. But there
> is no critical section between invalidate_page and the _later_
> ptep_clear_flush. So get_user_pages is free to run and take the PT
> lock before the ptep_clear_flush, find the linux pte still
> instantiated, and to create a new spte, before ptep_clear_flush runs.

Hmmm... Right. Did not consider get_user_pages. A write to the page that 
is not marked dirty would typically require a fault that will serialize.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
