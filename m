Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4696B0398
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 16:09:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u9so12883090wme.6
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 13:09:40 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id m26si20064407wrb.16.2017.03.19.13.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 13:09:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 79BE51C3124
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 20:09:38 +0000 (GMT)
Date: Sun, 19 Mar 2017 20:09:32 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [HMM 10/16] mm/hmm/mirror: mirror process address space on
 device with HMM helpers
Message-ID: <20170319200932.GH2774@techsingularity.net>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-11-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1489680335-6594-11-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J?r?me Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Thu, Mar 16, 2017 at 12:05:29PM -0400, J?r?me Glisse wrote:
> This is useful for NVidia GPU >= Pascal, Mellanox IB >= mlx5 and more
> hardware in the future.
> 

Insert boiler plate comment about in kernel user being ready here.

> +#if IS_ENABLED(CONFIG_HMM_MIRROR)
> <SNIP>
> + */
> +struct hmm_mirror_ops {
> +	/* update() - update virtual address range of memory
> +	 *
> +	 * @mirror: pointer to struct hmm_mirror
> +	 * @update: update's type (turn read only, unmap, ...)
> +	 * @start: virtual start address of the range to update
> +	 * @end: virtual end address of the range to update
> +	 *
> +	 * This callback is call when the CPU page table is updated, the device
> +	 * driver must update device page table accordingly to update's action.
> +	 *
> +	 * Device driver callback must wait until the device has fully updated
> +	 * its view for the range. Note we plan to make this asynchronous in
> +	 * later patches, so that multiple devices can schedule update to their
> +	 * page tables, and once all device have schedule the update then we
> +	 * wait for them to propagate.

That sort of future TODO comment may be more appropriate in the
changelog. It doesn't help understand what update is for.

"update" is also unnecessarily vague. sync_cpu_device_pagetables may be
unnecessarily long but at least it's a hint about what's going on. It's
also not super clear from the comment but I assume this is called via a
mmu notifier. If so, that should mentioned here.

> +int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
> +int hmm_mirror_register_locked(struct hmm_mirror *mirror,
> +			       struct mm_struct *mm);

Just a note to say this looks very dangerous and it's not clear why an
unlocked version should ever be used. It's the HMM mirror list that is
being protected but to external callers, that type is opaque so how can
they ever safely use the unlocked version?

Recommend getting rid of it unless there are really great reasons why an
external user of this API should be able to poke at HMM internals.

> diff --git a/mm/Kconfig b/mm/Kconfig
> index fe8ad24..8ae7600 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -293,6 +293,21 @@ config HMM
>  	bool
>  	depends on MMU
>  
> +config HMM_MIRROR
> +	bool "HMM mirror CPU page table into a device page table"
> +	select HMM
> +	select MMU_NOTIFIER
> +	help
> +	  HMM mirror is a set of helpers to mirror CPU page table into a device
> +	  page table. There is two side, first keep both page table synchronize

Word smithing, "there are two sides". There are a number of places in
earlier patches where there are minor typos that are worth searching
for. This one really stuck out though.

>  /*
>   * struct hmm - HMM per mm struct
>   *
>   * @mm: mm struct this HMM struct is bound to
> + * @lock: lock protecting mirrors list
> + * @mirrors: list of mirrors for this mm
> + * @wait_queue: wait queue
> + * @sequence: we track updates to the CPU page table with a sequence number
> + * @mmu_notifier: mmu notifier to track updates to CPU page table
> + * @notifier_count: number of currently active notifiers
>   */
>  struct hmm {
>  	struct mm_struct	*mm;
> +	spinlock_t		lock;
> +	struct list_head	mirrors;
> +	atomic_t		sequence;
> +	wait_queue_head_t	wait_queue;
> +	struct mmu_notifier	mmu_notifier;
> +	atomic_t		notifier_count;
>  };

Minor nit but notifier_count might be better named nr_notifiers because
it was not clear at all what the difference between the sequence count
and the notifier count is.

Also do a pahole check on this struct. There is a potential for holes with
the embedded structs and I also think that having the notifier_count and
sequence on separate cache lines just unnecessarily increases the cache
footprint. They are generally updated together so you might as well take
one cache miss to cover them both.

>  
>  /*
> @@ -47,6 +60,12 @@ static struct hmm *hmm_register(struct mm_struct *mm)
>  		hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>  		if (!hmm)
>  			return NULL;
> +		init_waitqueue_head(&hmm->wait_queue);
> +		atomic_set(&hmm->notifier_count, 0);
> +		INIT_LIST_HEAD(&hmm->mirrors);
> +		atomic_set(&hmm->sequence, 0);
> +		hmm->mmu_notifier.ops = NULL;
> +		spin_lock_init(&hmm->lock);
>  		hmm->mm = mm;
>  
>  		spin_lock(&mm->page_table_lock);
> @@ -79,3 +98,170 @@ void hmm_mm_destroy(struct mm_struct *mm)
>  	spin_unlock(&mm->page_table_lock);
>  	kfree(hmm);
>  }
> +
> +
> +#if IS_ENABLED(CONFIG_HMM_MIRROR)
> +static void hmm_invalidate_range(struct hmm *hmm,
> +				 enum hmm_update action,
> +				 unsigned long start,
> +				 unsigned long end)
> +{
> +	struct hmm_mirror *mirror;
> +
> +	/*
> +	 * Mirror being added or removed is a rare event so list traversal isn't
> +	 * protected by a lock, we rely on simple rules. All list modification
> +	 * are done using list_add_rcu() and list_del_rcu() under a spinlock to
> +	 * protect from concurrent addition or removal but not traversal.
> +	 *
> +	 * Because hmm_mirror_unregister() waits for all running invalidation to
> +	 * complete (and thus all list traversals to finish), none of the mirror
> +	 * structs can be freed from under us while traversing the list and thus
> +	 * it is safe to dereference their list pointer even if they were just
> +	 * removed.
> +	 */
> +	list_for_each_entry (mirror, &hmm->mirrors, list)
> +		mirror->ops->update(mirror, action, start, end);
> +}

Double check this very carefully because I believe it's wrong. If the
update side is protected by a spin lock then the traversal must be done
using list_for_each_entry_rcu with the the rcu read lock held. I see no
indication from this context that you have the necessary protection in
place.

> +
> +static void hmm_invalidate_page(struct mmu_notifier *mn,
> +				struct mm_struct *mm,
> +				unsigned long addr)
> +{
> +	unsigned long start = addr & PAGE_MASK;
> +	unsigned long end = start + PAGE_SIZE;
> +	struct hmm *hmm = mm->hmm;
> +
> +	VM_BUG_ON(!hmm);
> +
> +	atomic_inc(&hmm->notifier_count);
> +	atomic_inc(&hmm->sequence);
> +	hmm_invalidate_range(mm->hmm, HMM_UPDATE_INVALIDATE, start, end);
> +	atomic_dec(&hmm->notifier_count);
> +	wake_up(&hmm->wait_queue);
> +}
> +

The wait queue made me search further and I see it's only necessary for an
unregister but you end up with a bunch of atomic operations as a result
of it and a lot of wakeup checks that are almost never useful. That is a
real shame in itself but I'm not convinced it's right either.

It's not clear why both notifier count and sequence are needed considering
that nothing special is done with the sequence value. The comment says
updates are tracked with it but not why or what happens when that sequence
counter wraps. I strong suspect it can be removed.

Most importantly, with the lack of RCU locking in the invalidate_range
function, it's not clear at all how this is safe. The unregister function
says it's to keep the traversal safe but it does the list modification
before the wait so nothing is protected really.

You either need to keep the locking simple here or get the RCU details right.
If it's important that unregister return with no invalidating happening
on the mirror being unregistered then that can be achieved with a
sychronize_rcu() after the list update assuming that the invalidations
take the rcu read lock properly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
