Date: Thu, 24 Apr 2008 17:39:43 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080424153943.GJ24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random> <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random> <20080424095112.GC30298@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080424095112.GC30298@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 24, 2008 at 04:51:12AM -0500, Robin Holt wrote:
> It seems to me the work done by mmu_notifier_mm_destroy should really
> be done inside the mm_lock()/mm_unlock area of mmu_unregister and

There's no mm_lock/unlock for mmu_unregister anymore. That's the whole
point of using srcu so it becomes reliable and quick.

> mm_notifier_release when we have removed the last entry.  That would
> give the users job the same performance after they are done using the
> special device that they had prior to its use.

That's not feasible. Otherwise mmu_notifier_mm will go away at any
time under both _release from exit_mmap and under _unregister
too. exit_mmap holds an mm_count implicit, so freeing mmu_notifier_mm
after the last mmdrop makes it safe. mmu_notifier_unregister also
holds the mm_count because mm_count was pinned by
mmu_notifier_register. That solves the issue with mmu_notifier_mm
going away from under mmu_notifier_unregister and _release and that's
why it can only be freed after mm_count == 0.

There's at least one small issue I noticed so far, that while _release
don't need to care about _register, but _unregister definitely need to
care about _register. I've to take the mmap_sem in addition or in
replacement of the unregister_lock. The srcu_read_lock can also likely
moved just before releasing the unregister_lock but that's just a
minor optimization to make the code more strict.

> On Thu, Apr 24, 2008 at 08:49:40AM +0200, Andrea Arcangeli wrote:
> ...
> > diff --git a/mm/memory.c b/mm/memory.c
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> ...
> > @@ -603,25 +605,39 @@
> >  	 * readonly mappings. The tradeoff is that copy_page_range is more
> >  	 * efficient than faulting.
> >  	 */
> > +	ret = 0;
> >  	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
> >  		if (!vma->anon_vma)
> > -			return 0;
> > +			goto out;
> >  	}
> >  
> > -	if (is_vm_hugetlb_page(vma))
> > -		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
> > +	if (unlikely(is_vm_hugetlb_page(vma))) {
> > +		ret = copy_hugetlb_page_range(dst_mm, src_mm, vma);
> > +		goto out;
> > +	}
> >  
> > +	if (is_cow_mapping(vma->vm_flags))
> > +		mmu_notifier_invalidate_range_start(src_mm, addr, end);
> > +
> > +	ret = 0;
> 
> I don't think this is needed.

It's not needed right, but I thought it was cleaner if they all use
"ret" after I had to change the code at the end of the
function. Anyway I'll delete this to make the patch shorter and only
change the minimum, agreed.

> ...
> > +/* avoid memory allocations for mm_unlock to prevent deadlock */
> > +void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data)
> > +{
> > +	if (mm->map_count) {
> > +		if (data->nr_anon_vma_locks)
> > +			mm_unlock_vfree(data->anon_vma_locks,
> > +					data->nr_anon_vma_locks);
> > +		if (data->i_mmap_locks)
> 
> I think you really want data->nr_i_mmap_locks.

Indeed. It never happens that there are zero vmas with filebacked
mappings, this is why this couldn't be triggered in practice, thanks!

> The second paragraph of this comment seems extraneous.

ok removed.

> > +	/*
> > +	 * Wait ->release if mmu_notifier_unregister run list_del_rcu.
> > +	 * srcu can't go away from under us because one mm_count is
> > +	 * hold by exit_mmap.
> > +	 */
> 
> These two sentences don't make any sense to me.

Well that was a short explanation of why the mmu_notifier_mm structure
can only be freed after the last mmdrop, which is what you asked at
the top. I'll try to rephrase.

> > +void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
> > +{
> > +	int before_release = 0, srcu;
> > +
> > +	BUG_ON(atomic_read(&mm->mm_count) <= 0);
> > +
> > +	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
> > +	spin_lock(&mm->mmu_notifier_mm->unregister_lock);
> > +	if (!hlist_unhashed(&mn->hlist)) {
> > +		hlist_del_rcu(&mn->hlist);
> > +		before_release = 1;
> > +	}
> > +	spin_unlock(&mm->mmu_notifier_mm->unregister_lock);
> > +	if (before_release)
> > +		/*
> > +		 * exit_mmap will block in mmu_notifier_release to
> > +		 * guarantee ->release is called before freeing the
> > +		 * pages.
> > +		 */
> > +		mn->ops->release(mn, mm);
> 
> I am not certain about the need to do the release callout when the driver
> has already told this subsystem it is done.  For XPMEM, this callout
> would immediately return.  I would expect it to be the same or GRU.

The point is that you don't want to run it twice. And without this you
will have to serialize against ->release yourself in the driver. It's
much more convenient if you know that ->release will be called just
once, and before mmu_notifier_unregister returns. It could be called
by _release even after you're already inside _unregister, _release may
reach the spinlock before _unregister, you won't notice the
difference. Solving this race in the driver looked too complex, I
rather solve it once inside the mmu notifier code to be sure. Missing
a release event is fatal because all sptes have to be dropped before
_release returns. The requirement is the same for _unregister, all
sptes have to be dropped before it returns. ->release should be able
to sleep as long as it wants even with only 1/N applied. exit_mmap can
sleep too, no problem. You can't unregister inside ->release first of
all because 'ret' instruction must be still allocated to return to mmu
notifier code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
