Date: Tue, 29 Jan 2008 23:35:03 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080129223503.GY7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com> <20080129162004.GL7233@v2.random> <20080129182831.GS7233@v2.random> <Pine.LNX.4.64.0801291219030.25629@schroedinger.engr.sgi.com> <20080129213604.GW7233@v2.random> <Pine.LNX.4.64.0801291343530.26824@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801291343530.26824@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2008 at 01:53:05PM -0800, Christoph Lameter wrote:
> On Tue, 29 Jan 2008, Andrea Arcangeli wrote:
> 
> > > We invalidate the range *after* populating it? Isnt it okay to establish 
> > > references while populate_range() runs?
> > 
> > It's not ok because that function can very well overwrite existing and
> > present ptes (it's actually the nonlinear common case fast path for
> > db). With your code the sptes created between invalidate_range and
> > populate_range, will keep pointing forever to the old physical page
> > instead of the newly populated one.
> 
> Seems though that the mmap_sem is taken for regular vmas writably and will 
> hold off new mappings.

It's taken writable due to the code being inefficient the first time,
all later times remap_populate_range overwrites ptes with the mmap_sem
in readonly mode (finally rightfully so). The first remap_file_pages I
guess it's irrelevant to optimize, the whole point of nonlinear is to
call remap_file_pages zillon of times on the same vma, overwriting
present ptes the whole time, so if the first time the mutex is not
readonly it probably doesn't make a difference.

get_user_pages invoked by the kvm spte-fault, can happen between
invalidate_range and populate_range. If it can't happen, for sure
nobody pointed out a good reason why it can't happen. The kvm page
faults as well rightfully only takes the mmap_sem in readonly mode, so
get_user_pages is only called internally to gfn_to_page with the
readonly semaphore.

With my approach ptep_clear_flush was not only invalidating sptes
after ptep_clear_flush, but it was also invalidating them inside the
PT lock, so it was totally obvious there could be no race vs
get_user_pages.

> > I'm also asking myself if it's a smp race not to call
> > mmu_notifier(invalidate_page) between ptep_clear_flush and set_pte_at
> > in install_file_pte. Probably not because the guest VM running in a
> > different thread would need to serialize outside the install_file_pte
> > code with the task running install_file_pte, if it wants to be sure to
> > write either all its data to the old or the new page. Certainly doing
> > the invalidate_page inside the PT lock was obviously safe but I hope
> > this is safe and this can accommodate your needs too.
> 
> But that would be doing two invalidates on one pte. One range and one page 
> invalidate.

Yes, but it would have been micro-optimized later if you really cared,
by simply changing ptep_clear_flush to __ptep_clear_flush, no big
deal. Definitely all methods must be robust about them being called
multiple times, even if the rmap finds no spte mapping such host
virtual address.

> Hmmm... So we could only do an invalidate_page here? Drop the strange 
> invalidate_range()?

That's a question you should answer.

> > > > @@ -1676,6 +1674,8 @@ gotten:
> > > >  		page_cache_release(old_page);
> > > >  unlock:
> > > >  	pte_unmap_unlock(page_table, ptl);
> > > > +	mmu_notifier(invalidate_range, mm, address,
> > > > +				address + PAGE_SIZE - 1, 0);
> > > >  	if (dirty_page) {
> > > >  		if (vma->vm_file)
> > > >  			file_update_time(vma->vm_file);
> > > 
> > > Now we invalidate the page after the transaction is complete. This means 
> > > external pte can persist while we change the pte? Possibly even dirty the 
> > > page?
> > 
> > Yes, and the only reason this can be safe is for the reason explained
> > at the top of the email, if the other cpu wants to serialize to be
> > sure to write in the "new" page, it has to serialize with the
> > page-fault but to serialize it has to wait the page fault to return
> > (example: we're not going to call futex code until the page fault
> > returns).
> 
> Serialize how? mmap_sem?

No, that's a different angle.

But now I think there may be an issue with a third thread that may
show unsafe the removal of invalidate_page from ptep_clear_flush.

A third thread writing to a page through the linux-pte and the guest
VM writing to the same page through the sptes, will be writing on the
same physical page concurrently and using an userspace spinlock w/o
ever entering the kernel. With your patch that invalidate_range after
dropping the PT lock, the third thread may start writing on the new
page, when the guest is still writing to the old page through the
sptes. While this couldn't happen with my patch.

So really at the light of the third thread, it seems your approach is
smp racey and ptep_clear_flush should invalidate_page as last thing
before returning. My patch was enforcing that ptep_clear_flush would
stop the third thread in a linux page fault, and to drop the spte,
before the new mapping could be instantiated in both the linux pte and
in the sptes. The PT lock provided the needed serialization. This
ensured the third thread and the guest VM would always write on the
same physical page even if the first thread runs a flood of
remap_file_pages on that same page moving it around the pagecache. So
it seems I found a unfixable smp race in pretending to invalidate in a
sleeping place.

Perhaps you want to change the PT lock to a mutex instead of a
spinlock, that may be your only chance to sleep while maintaining 100%
memory coherency with threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
