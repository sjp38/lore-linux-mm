Date: Tue, 29 Jan 2008 23:02:12 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080129220212.GX7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com> <20080129162004.GL7233@v2.random> <Pine.LNX.4.64.0801291153520.25300@schroedinger.engr.sgi.com> <20080129211759.GV7233@v2.random> <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2008 at 01:35:58PM -0800, Christoph Lameter wrote:
> On Tue, 29 Jan 2008, Andrea Arcangeli wrote:
> 
> > > It seems to be okay to invalidate range if you hold mmap_sem writably. In 
> > > that case no additional faults can happen that would create new ptes.
> > 
> > In that place the mmap_sem is taken but in readonly mode. I never rely
> > on the mmap_sem in the mmu notifier methods. Not invoking the notifier
> 
> Well it seems that we have to rely on mmap_sem otherwise concurrent faults 
> can occur. The mmap_sem seems to be acquired for write there.
      	     	 	  	      	       	   	 ^^^^^
> 
>               if (!has_write_lock) {
>                         up_read(&mm->mmap_sem);
>                         down_write(&mm->mmap_sem);
>                         has_write_lock = 1;
>                         goto retry;
>                 }


hmm, "there" where? When I said it was taken in readonly mode I meant
for the quoted code (it would be at the top if it wasn't cut), so I
quote below again:

> > +   mmu_notifier(invalidate_range, mm, address,
> > +                           address + PAGE_SIZE - 1, 0);
> >     page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> >     if (likely(pte_same(*page_table, orig_pte))) {
> >             if (old_page) {

The "there" for me was do_wp_page.

Even for the code you quoted in freemap.c, the has_write_lock is set
to 1 _only_ for the very first time you call sys_remap_file_pages on a
VMA. Only the transition of the VMA between linear to nonlinear
requires the mmap in write mode. So you can be sure all freemap code
99% of the time is populating (overwriting) already present ptes with
only the mmap_sem in readonly mode like do_wp_page. It would be
unnecessary to populate the nonlinear range with the mmap in write
mode. Only the "vma" mangling requires the mmap_sem in write mode, the
pte modifications only requires the PT_lock + mmap_sem in read mode.

Effectively the first invocation of populate_range runs with the
mmap_sem in write mode, I wonder why, there seem to be no good reason
for that. I guess it's a bit that should be optimized, by calling
downgrade_write before calling populate_range even for the first time
the vma switches from linear to nonlinear (after the vma has been
fully updated to the new status). But for sure all later invocations
runs populate_range with the semaphore readonly like the rest of the
VM does when instantiating ptes in the page faults.

> > before releasing the PT lock adds quite some uncertainty on the smp
> > safety of the spte invalidates, because the pte may be unmapped and
> > remapped by a minor fault before invalidate_range is invoked, but I
> > didn't figure out a kernel crashing race yet thanks to the pin we take
> > through get_user_pages (and only thanks to it). The requirement is
> > that invalidate_range is invoked after the last ptep_clear_flush or it
> > leaks pins that's why I had to move it at the end.
>  
> So "pins" means a reference count right? I still do not get why you 

Yes.

> have refcount problems. You take a refcount when you export the page 
> through KVM and then drop the refcount in invalidate page right?

Yes.

> So you walk through the KVM ptes and drop the refcount for each spte you 
> encounter?

Yes.

All pins are gone by the time invalidate_page/range returns. But there
is no critical section between invalidate_page and the _later_
ptep_clear_flush. So get_user_pages is free to run and take the PT
lock before the ptep_clear_flush, find the linux pte still
instantiated, and to create a new spte, before ptep_clear_flush runs.

Think of why the tlb flushes are being called at the end of
ptep_clear_flush. The mmu notifier invalidate has to be called after
for the exact same reason.

Perhaps somebody else should explain this, I started exposing this
smp race the moment after I've seen the backwards ordering being
proposed in export-notifier-v1, sorry if I'm not clear enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
