Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id F147E6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 23:27:30 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so160530009pab.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 20:27:30 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id ei15si27432525pdb.110.2015.08.31.20.27.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Aug 2015 20:27:29 -0700 (PDT)
Date: Mon, 31 Aug 2015 20:27:17 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 02/15] mmu_notifier: keep track of active invalidation
 ranges v4
In-Reply-To: <1439493328-1028-3-git-send-email-jglisse@redhat.com>
Message-ID: <alpine.DEB.2.00.1508312003400.18393@mdh-linux64-2.nvidia.com>
References: <1439493328-1028-1-git-send-email-jglisse@redhat.com> <1439493328-1028-3-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="8323329-360751024-1441078047=:18393"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

--8323329-360751024-1441078047=:18393
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT



On Thu, 13 Aug 2015, JA(C)rA'me Glisse wrote:

> The invalidate_range_start() and invalidate_range_end() can be
> considered as forming an "atomic" section for the cpu page table
> update point of view. Between this two function the cpu page
> table content is unreliable for the address range being
> invalidated.
> 
> This patch use a structure define at all place doing range
> invalidation. This structure is added to a list for the duration
> of the update ie added with invalid_range_start() and removed
> with invalidate_range_end().
> 
> Helpers allow querying if a range is valid and wait for it if
> necessary.
> 
> For proper synchronization, user must block any new range
> invalidation from inside there invalidate_range_start() callback.

s/there/their/

> Otherwise there is no garanty that a new range invalidation will

s/garanty/guarantee/

> not be added after the call to the helper function to query for
> existing range.
> 
> [...]
>
> +/* mmu_notifier_range_is_valid_locked() - test if range overlap with active

s/overlap/overlaps/

> + * invalidation.
> + *
> + * @mm: The mm struct.
> + * @start: Start address of the range (inclusive).
> + * @end: End address of the range (exclusive).
> + * Returns: false if overlap with an active invalidation, true otherwise.
> + *
> + * This function test whether any active invalidated range conflict with a

s/test/tests/
s/invalidated/invalidation/
s/conflict/conflicts/

> + * given range ([start, end[), active invalidation are added to a list inside

end[ -> end]
s/invalidation/invalidations/

> + * __mmu_notifier_invalidate_range_start() and removed from that list inside
> + * __mmu_notifier_invalidate_range_end().
> + */
> +static bool mmu_notifier_range_is_valid_locked(struct mm_struct *mm,
> +					       unsigned long start,
> +					       unsigned long end)
> +{
> +	struct mmu_notifier_range *range;
> +
> +	list_for_each_entry(range, &mm->mmu_notifier_mm->ranges, list) {
> +		if (range->end > start && range->start < end)
> +			return false;
> +	}
> +	return true;
> +}
> +
> +/* mmu_notifier_range_is_valid() - test if range overlap with active

s/overlap/overlaps/

> + * invalidation.
> + *
> + * @mm: The mm struct.
> + * @start: Start address of the range (inclusive).
> + * @end: End address of the range (exclusive).
> + *
> + * This function wait for any active range invalidation that conflict with the
> + * given range, to end. See mmu_notifier_range_wait_valid() on how to use this
> + * function properly.

Bad copy/paste from range_wait_valid? mmu_notifier_range_is_valid just 
queries the state, it doesn't wait.

> + */
> +bool mmu_notifier_range_is_valid(struct mm_struct *mm,
> +				 unsigned long start,
> +				 unsigned long end)
> +{
> +	bool valid;
> +
> +	spin_lock(&mm->mmu_notifier_mm->lock);
> +	valid = mmu_notifier_range_is_valid_locked(mm, start, end);
> +	spin_unlock(&mm->mmu_notifier_mm->lock);
> +	return valid;
> +}
> +EXPORT_SYMBOL_GPL(mmu_notifier_range_is_valid);
> +
> +/* mmu_notifier_range_wait_valid() - wait for a range to have no conflict with
> + * active invalidation.
> + *
> + * @mm: The mm struct.
> + * @start: Start address of the range (inclusive).
> + * @end: End address of the range (exclusive).
> + *
> + * This function wait for any active range invalidation that conflict with the
> + * given range, to end.
> + *
> + * Note by the time this function return a new range invalidation that conflict
> + * might have started. So you need to atomically block new range and query
> + * again if range is still valid with mmu_notifier_range_is_valid(). So call
> + * sequence should be :
> + *
> + * again:
> + * mmu_notifier_range_wait_valid()
> + * // block new invalidation using that lock inside your range_start callback
> + * lock_block_new_invalidation()
> + * if (!mmu_notifier_range_is_valid())
> + *     goto again;
> + * unlock()

I think this example sequence can deadlock so I wouldn't want to encourage 
its use. New invalidation regions are added to the list before the 
range_start callback is invoked.

Thread A                           Thread B
-----------------                  -----------------
mmu_notifier_range_wait_valid
// returns
                                   __mmu_notifier_invalidate_range_start
                                     list_add_tail
lock_block_new_invalidation
                                     ->invalidate_range_start
                                       // invalidation blocked in callback
mmu_notifier_range_is_valid // fails
goto again
mmu_notifier_range_wait_valid // deadlock

mmu_notifier_range_wait_valid can't finish until thread B's callback 
returns, but thread B's callback can't return because it's blocked.

I see that HMM in later patches takes the approach of not holding the lock 
when mmu_notifier_range_is_valid returns false. Instead of stalling new 
invalidations it returns -EAGAIN to the caller. While that resolves the 
deadlock, it won't prevent the faulting thread from being starved in the 
pathological case.

Is it out of the question to build a lock into the mmu notifier API 
directly? It's a little worrisome to me that the complexity for this 
locking is pushed into the callbacks rather than handled in the core. 
Something like this:

    mmu_notifier_range_lock(start, end)
    mmu_notifier_range_unlock(start, end)

If that's not feasible and we have to stick with the current approach, 
then I suggest changing the "valid" name. "valid" doesn't have a clear 
meaning at first glance because the reader doesn't know what would make a 
range "valid." How about "active" instead? Then the names would look 
something like this, assuming the polarity matches their current versions:

    mmu_notifier_range_inactive_locked
    mmu_notifier_range_inactive
    mmu_notifier_range_wait_active


> + */
> +void mmu_notifier_range_wait_valid(struct mm_struct *mm,
> +				   unsigned long start,
> +				   unsigned long end)
> +{
> +	spin_lock(&mm->mmu_notifier_mm->lock);
> +	while (!mmu_notifier_range_is_valid_locked(mm, start, end)) {
> +		int nranges = mm->mmu_notifier_mm->nranges;
> +
> +		spin_unlock(&mm->mmu_notifier_mm->lock);
> +		wait_event(mm->mmu_notifier_mm->wait_queue,
> +			   nranges != mm->mmu_notifier_mm->nranges);
> +		spin_lock(&mm->mmu_notifier_mm->lock);
> +	}
> +	spin_unlock(&mm->mmu_notifier_mm->lock);
> +}
> +EXPORT_SYMBOL_GPL(mmu_notifier_range_wait_valid);
> +
--8323329-360751024-1441078047=:18393--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
