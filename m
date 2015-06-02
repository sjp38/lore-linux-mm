Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 545676B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 05:32:47 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so129088392pdb.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 02:32:47 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id e7si25536939pdl.156.2015.06.02.02.32.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 02:32:46 -0700 (PDT)
Date: Tue, 2 Jun 2015 02:32:01 -0700
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 02/36] mmu_notifier: keep track of active invalidation
 ranges v3
In-Reply-To: <1432236705-4209-3-git-send-email-j.glisse@gmail.com>
Message-ID: <alpine.LNX.2.03.1506020214160.17700@nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-3-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="279739828-311634902-1433237522=:17700"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

--279739828-311634902-1433237522=:17700
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT

On Thu, 21 May 2015, j.glisse@gmail.com wrote:

> From: JA(C)rA'me Glisse <jglisse@redhat.com>
> 
> The mmu_notifier_invalidate_range_start() and mmu_notifier_invalidate_range_end()
> can be considered as forming an "atomic" section for the cpu page table update
> point of view. Between this two function the cpu page table content is unreliable
> for the address range being invalidated.
> 
> Current user such as kvm need to know when they can trust the content of the cpu
> page table. This becomes even more important to new users of the mmu_notifier
> api (such as HMM or ODP).
> 
> This patch use a structure define at all call site to invalidate_range_start()
> that is added to a list for the duration of the invalidation. It adds two new
> helpers to allow querying if a range is being invalidated or to wait for a range
> to become valid.
> 
> For proper synchronization, user must block new range invalidation from inside
> there invalidate_range_start() callback, before calling the helper functions.
> Otherwise there is no garanty that a new range invalidation will not be added
> after the call to the helper function to query for existing range.

Hi Jerome,

Most of this information will make nice block comments for the new helper 
routines. I can help tighten up the writing slightly, but first:

Question: in hmm.c's hmm_notifier_invalidate function (looking at the 
entire patchset, for a moment), I don't see any blocking of new range 
invalidations, even though you point out, above, that this is required. Am 
I missing it, and if so, where should I be looking instead?

> 
> Changed since v1:
>   - Fix a possible deadlock in mmu_notifier_range_wait_valid()
> 
> Changed since v2:
>   - Add the range to invalid range list before calling ->range_start().
>   - Del the range from invalid range list after calling ->range_end().
>   - Remove useless list initialization.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: Haggai Eran <haggaie@mellanox.com>
> ---
>  drivers/gpu/drm/i915/i915_gem_userptr.c |  9 ++--
>  drivers/gpu/drm/radeon/radeon_mn.c      | 14 +++---
>  drivers/infiniband/core/umem_odp.c      | 16 +++----
>  drivers/misc/sgi-gru/grutlbpurge.c      | 15 +++----
>  drivers/xen/gntdev.c                    | 15 ++++---
>  fs/proc/task_mmu.c                      | 11 +++--
>  include/linux/mmu_notifier.h            | 55 ++++++++++++-----------
>  kernel/events/uprobes.c                 | 13 +++---
>  mm/huge_memory.c                        | 78 ++++++++++++++------------------
>  mm/hugetlb.c                            | 55 ++++++++++++-----------
>  mm/ksm.c                                | 28 +++++-------
>  mm/madvise.c                            | 20 ++++-----
>  mm/memory.c                             | 72 +++++++++++++++++-------------
>  mm/migrate.c                            | 36 +++++++--------
>  mm/mmu_notifier.c                       | 79 ++++++++++++++++++++++++++++-----
>  mm/mprotect.c                           | 18 ++++----
>  mm/mremap.c                             | 14 +++---
>  virt/kvm/kvm_main.c                     | 10 ++---
>  18 files changed, 302 insertions(+), 256 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> index 452e9b1..80fe72a 100644
> --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> @@ -131,16 +131,15 @@ restart:
>  
>  static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
>  						       struct mm_struct *mm,
> -						       unsigned long start,
> -						       unsigned long end,
> -						       enum mmu_event event)
> +						       const struct mmu_notifier_range *range)
>  {
>  	struct i915_mmu_notifier *mn = container_of(_mn, struct i915_mmu_notifier, mn);
>  	struct interval_tree_node *it = NULL;
> -	unsigned long next = start;
> +	unsigned long next = range->start;
>  	unsigned long serial = 0;
> +	/* interval ranges are inclusive, but invalidate range is exclusive */
> +	unsigned long end = range->end - 1, start = range->start;


A *very* minor point, but doing it that way messes up the scope of the 
comment. Something more like this might be cleaner:

unsigned long start = range->start;
unsigned long next = start;
unsigned long serial = 0;
/* interval ranges are inclusive, but invalidate range is exclusive */
unsigned long end = range->end - 1;


[...]

> -					   enum mmu_event event)
> +					   struct mmu_notifier_range *range)
>  
>  {
>  	struct mmu_notifier *mn;
>  	int id;
>  
> +	spin_lock(&mm->mmu_notifier_mm->lock);
> +	list_add_tail(&range->list, &mm->mmu_notifier_mm->ranges);
> +	mm->mmu_notifier_mm->nranges++;


Is this missing a call to wake_up(&mm->mmu_notifier_mm->wait_queue)? If 
not, then it would be helpful to explain why that's only required for 
nranges--, and not for the nranges++ case. The helper routine is merely 
waiting for nranges to *change*, not looking for greater than or less 
than.


> +	spin_unlock(&mm->mmu_notifier_mm->lock);
> +
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_range_start)
> -			mn->ops->invalidate_range_start(mn, mm, start,
> -							end, event);
> +			mn->ops->invalidate_range_start(mn, mm, range);
>  	}
>  	srcu_read_unlock(&srcu, id);
>  }
>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
>  
>  void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
> -					 unsigned long start,
> -					 unsigned long end,
> -					 enum mmu_event event)
> +					 struct mmu_notifier_range *range)
>  {
>  	struct mmu_notifier *mn;
>  	int id;
> @@ -211,12 +211,23 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>  		 * (besides the pointer check).
>  		 */
>  		if (mn->ops->invalidate_range)
> -			mn->ops->invalidate_range(mn, mm, start, end);
> +			mn->ops->invalidate_range(mn, mm,
> +						  range->start, range->end);
>  		if (mn->ops->invalidate_range_end)
> -			mn->ops->invalidate_range_end(mn, mm, start,
> -						      end, event);
> +			mn->ops->invalidate_range_end(mn, mm, range);
>  	}
>  	srcu_read_unlock(&srcu, id);
> +
> +	spin_lock(&mm->mmu_notifier_mm->lock);
> +	list_del_init(&range->list);
> +	mm->mmu_notifier_mm->nranges--;
> +	spin_unlock(&mm->mmu_notifier_mm->lock);
> +
> +	/*
> +	 * Wakeup after callback so they can do their job before any of the
> +	 * waiters resume.
> +	 */
> +	wake_up(&mm->mmu_notifier_mm->wait_queue);
>  }
>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
>  
> @@ -235,6 +246,49 @@ void __mmu_notifier_invalidate_range(struct mm_struct *mm,
>  }
>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
>  


We definitely want to put a little documentation here.


> +static bool mmu_notifier_range_is_valid_locked(struct mm_struct *mm,
> +					       unsigned long start,
> +					       unsigned long end)


This routine is named "_range_is_valid_", but it takes in an implicit 
range (start, end), and also a list of ranges (buried in mm), and so it's 
a little confusing. I'd like to consider *maybe* changing either the name, 
or the args (range* instead of start, end?), or something.

Could you please say a few words about the intent of this routine, to get 
us started there?


> +{
> +	struct mmu_notifier_range *range;
> +
> +	list_for_each_entry(range, &mm->mmu_notifier_mm->ranges, list) {
> +		if (!(range->end <= start || range->start >= end))
> +			return false;


This has a lot of negatives in it, if you count the innermost "not in 
range" expression. It can be simplified to this:

if(range->end > start && range->start < end)
	return false;


> +	}
> +	return true;
> +}
> +
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
>  static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  				    struct mm_struct *mm,
>  				    int take_mmap_sem)
> @@ -264,6 +318,9 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  	if (!mm_has_notifiers(mm)) {

[...]

That's all I could see to mention for this one, thanks,

john h

--279739828-311634902-1433237522=:17700--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
