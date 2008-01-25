Date: Fri, 25 Jan 2008 12:39:34 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
Message-ID: <20080125183934.GO26420@sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125055801.212744875@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080125055801.212744875@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> +#define mmu_notifier(function, mm, args...)				\
...
> +				if (__mn->ops->function)		\
> +					__mn->ops->function(__mn,	\
> +							    mm,		\
> +							    args);	\

					__mn->ops->function(__mn, mm, args);	\
I realize it is a minor nit, but since we put the continuation in column
81 in the next define, can we do the same here and make this more
readable?

> +			rcu_read_unlock();				\
...
> +#define mmu_rmap_notifier(function, args...)					\
> +	do {									\
> +		struct mmu_rmap_notifier *__mrn;				\
> +		struct hlist_node *__n;						\
> +										\



> +void mmu_notifier_release(struct mm_struct *mm)
> +{
> +	struct mmu_notifier *mn;
> +	struct hlist_node *n;
> +
> +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> +		rcu_read_lock();
> +		hlist_for_each_entry_rcu(mn, n,
> +					  &mm->mmu_notifier.head, hlist) {
> +			if (mn->ops->release)
> +				mn->ops->release(mn, mm);
> +			hlist_del(&mn->hlist);

I think the hlist_del needs to be before the function callout so we can free
the structure without a use-after-free issue.

		hlist_for_each_entry_rcu(mn, n,
					  &mm->mmu_notifier.head, hlist) {
			hlist_del_rcu(&mn->hlist);
			if (mn->ops->release)
				mn->ops->release(mn, mm);



> +static DEFINE_SPINLOCK(mmu_notifier_list_lock);

Remove

> +
> +void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	spin_lock(&mmu_notifier_list_lock);

Shouldn't this really be protected by the down_write(mmap_sem)?  Maybe:
	BUG_ON(!rwsem_is_write_locked(&mm->mmap_sem));

> +	hlist_add_head(&mn->hlist, &mm->mmu_notifier.head);
	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);

> +	spin_unlock(&mmu_notifier_list_lock);
> +}
> +EXPORT_SYMBOL_GPL(mmu_notifier_register);
> +
> +void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
> +{
> +	spin_lock(&mmu_notifier_list_lock);
> +	hlist_del(&mn->hlist);

hlist_del_rcu?  Ditto on the lock.

> +	spin_unlock(&mmu_notifier_list_lock);
> +}
> +EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
> +
> +HLIST_HEAD(mmu_rmap_notifier_list);

static DEFINE_SPINLOCK(mmu_rmap_notifier_list_lock);

> +
> +void mmu_rmap_notifier_register(struct mmu_rmap_notifier *mrn)
> +{
> +	spin_lock(&mmu_notifier_list_lock);
> +	hlist_add_head_rcu(&mrn->hlist, &mmu_rmap_notifier_list);
> +	spin_unlock(&mmu_notifier_list_lock);

	spin_lock(&mmu_rmap_notifier_list_lock);
	hlist_add_head_rcu(&mrn->hlist, &mmu_rmap_notifier_list);
	spin_unlock(&mmu_rmap_notifier_list_lock);

> +}
> +EXPORT_SYMBOL(mmu_rmap_notifier_register);
> +
> +void mmu_rmap_notifier_unregister(struct mmu_rmap_notifier *mrn)
> +{
> +	spin_lock(&mmu_notifier_list_lock);
> +	hlist_del_rcu(&mrn->hlist);
> +	spin_unlock(&mmu_notifier_list_lock);

	spin_lock(&mmu_rmap_notifier_list_lock);
	hlist_del_rcu(&mrn->hlist);
	spin_unlock(&mmu_rmap_notifier_list_lock);


> @@ -2043,6 +2044,7 @@ void exit_mmap(struct mm_struct *mm)
>  	vm_unacct_memory(nr_accounted);
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
>  	tlb_finish_mmu(tlb, 0, end);
> +	mmu_notifier_release(mm);

Can we consider moving this notifier or introducing an additional notifier
in the release or a flag to this one indicating early/late.

The GRU that Jack is concerned with would benefit from the early in
that it could just invalidate the GRU context and immediately all GRU
TLB entries are invalid.  I believe Jack would like to also be able to
remove his entry from the mmu_notifier list in an effort to avoid the
page and range callouts.

XPMEM, would also benefit from a call early.  We could make all the
segments as being torn down and start the recalls.  We already have
this code in and working (have since it was first written 6 years ago).
In this case, all segments are torn down with a single message to each
of the importing partitions.  In contrast, the teardown code which would
happen now would be one set of messages for each vma.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
