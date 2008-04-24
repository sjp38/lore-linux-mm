Date: Thu, 24 Apr 2008 04:51:12 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080424095112.GC30298@sgi.com>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random> <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080424064753.GH24536@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

I am not certain of this, but it seems like this patch leaves things in
a somewhat asymetric state.  At the very least, I think that asymetry
should be documented in the comments of either mmu_notifier.h or .c.

Before I do the first mmu_notifier_register, all places that test for
mm_has_notifiers(mm) will return false and take the fast path.

After I do some mmu_notifier_register()s and their corresponding
mmu_notifier_unregister()s, The mm_has_notifiers(mm) will return true
and the slow path will be taken.  This, despite all registered notifiers
having unregistered.

It seems to me the work done by mmu_notifier_mm_destroy should really
be done inside the mm_lock()/mm_unlock area of mmu_unregister and
mm_notifier_release when we have removed the last entry.  That would
give the users job the same performance after they are done using the
special device that they had prior to its use.


On Thu, Apr 24, 2008 at 08:49:40AM +0200, Andrea Arcangeli wrote:
...
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
...
> @@ -603,25 +605,39 @@
>  	 * readonly mappings. The tradeoff is that copy_page_range is more
>  	 * efficient than faulting.
>  	 */
> +	ret = 0;
>  	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
>  		if (!vma->anon_vma)
> -			return 0;
> +			goto out;
>  	}
>  
> -	if (is_vm_hugetlb_page(vma))
> -		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
> +	if (unlikely(is_vm_hugetlb_page(vma))) {
> +		ret = copy_hugetlb_page_range(dst_mm, src_mm, vma);
> +		goto out;
> +	}
>  
> +	if (is_cow_mapping(vma->vm_flags))
> +		mmu_notifier_invalidate_range_start(src_mm, addr, end);
> +
> +	ret = 0;

I don't think this is needed.

...
> +/* avoid memory allocations for mm_unlock to prevent deadlock */
> +void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data)
> +{
> +	if (mm->map_count) {
> +		if (data->nr_anon_vma_locks)
> +			mm_unlock_vfree(data->anon_vma_locks,
> +					data->nr_anon_vma_locks);
> +		if (data->i_mmap_locks)

I think you really want data->nr_i_mmap_locks.

...
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> new file mode 100644
> --- /dev/null
> +++ b/mm/mmu_notifier.c
...
> +/*
> + * This function can't run concurrently against mmu_notifier_register
> + * or any other mmu notifier method. mmu_notifier_register can only
> + * run with mm->mm_users > 0 (and exit_mmap runs only when mm_users is
> + * zero). All other tasks of this mm already quit so they can't invoke
> + * mmu notifiers anymore. This can run concurrently only against
> + * mmu_notifier_unregister and it serializes against it with the
> + * unregister_lock in addition to RCU. struct mmu_notifier_mm can't go
> + * away from under us as the exit_mmap holds a mm_count pin itself.
> + *
> + * The ->release method can't allow the module to be unloaded, the
> + * module can only be unloaded after mmu_notifier_unregister run. This
> + * is because the release method has to run the ret instruction to
> + * return back here, and so it can't allow the ret instruction to be
> + * freed.
> + */

The second paragraph of this comment seems extraneous.

...
> +	/*
> +	 * Wait ->release if mmu_notifier_unregister run list_del_rcu.
> +	 * srcu can't go away from under us because one mm_count is
> +	 * hold by exit_mmap.
> +	 */

These two sentences don't make any sense to me.

...
> +void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	int before_release = 0, srcu;
> +
> +	BUG_ON(atomic_read(&mm->mm_count) <= 0);
> +
> +	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
> +	spin_lock(&mm->mmu_notifier_mm->unregister_lock);
> +	if (!hlist_unhashed(&mn->hlist)) {
> +		hlist_del_rcu(&mn->hlist);
> +		before_release = 1;
> +	}
> +	spin_unlock(&mm->mmu_notifier_mm->unregister_lock);
> +	if (before_release)
> +		/*
> +		 * exit_mmap will block in mmu_notifier_release to
> +		 * guarantee ->release is called before freeing the
> +		 * pages.
> +		 */
> +		mn->ops->release(mn, mm);

I am not certain about the need to do the release callout when the driver
has already told this subsystem it is done.  For XPMEM, this callout
would immediately return.  I would expect it to be the same or GRU.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
