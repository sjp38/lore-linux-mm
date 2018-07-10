Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3727F6B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 02:44:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so778130pgr.15
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 23:44:57 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o3-v6si14926815pga.609.2018.07.09.23.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 23:44:54 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 03/21] mm, THP, swap: Support PMD swap mapping in swap_duplicate()
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-4-ying.huang@intel.com>
	<92b86ab6-6f51-97b0-337c-b7e98a30b6cb@linux.intel.com>
Date: Tue, 10 Jul 2018 14:44:50 +0800
In-Reply-To: <92b86ab6-6f51-97b0-337c-b7e98a30b6cb@linux.intel.com> (Dave
	Hansen's message of "Mon, 9 Jul 2018 09:51:42 -0700")
Message-ID: <878t6jio7x.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

>> +static inline bool thp_swap_supported(void)
>> +{
>> +	return IS_ENABLED(CONFIG_THP_SWAP);
>> +}
>
> This seems like rather useless abstraction.  Why do we need it?

I just want to make it shorter, 19 vs 27 characters.  But if you think
IS_ENABLED(CONFIG_THP_SWAP) is much better, I can use that instead.

> ...
>> -static inline int swap_duplicate(swp_entry_t swp)
>> +static inline int swap_duplicate(swp_entry_t *swp, bool cluster)
>>  {
>>  	return 0;
>>  }
>
> FWIW, I despise true/false function arguments like this.  When I see
> this in code:
>
> 	swap_duplicate(&entry, false);
>
> I have no idea what false does.  I'd much rather see:
>
> enum do_swap_cluster {
> 	SWP_DO_CLUSTER,
> 	SWP_NO_CLUSTER
> };
>
> So you see:
>
> 	swap_duplicate(&entry, SWP_NO_CLUSTER);
>
> vs.
>
> 	swap_duplicate(&entry, SWP_DO_CLUSTER);
>

Yes.  Boolean parameter isn't good at most times.  Matthew Wilcox
suggested to use

        swap_duplicate(&entry, HPAGE_PMD_NR);

vs.

        swap_duplicate(&entry, 1);

He thinks this makes the interface more flexible to support other swap
entry size in the future.  What do you think about that?

>> diff --git a/mm/memory.c b/mm/memory.c
>> index e9cac1c4fa69..f3900282e3da 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -951,7 +951,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>>  		swp_entry_t entry = pte_to_swp_entry(pte);
>>  
>>  		if (likely(!non_swap_entry(entry))) {
>> -			if (swap_duplicate(entry) < 0)
>> +			if (swap_duplicate(&entry, false) < 0)
>>  				return entry.val;
>>  
>>  			/* make sure dst_mm is on swapoff's mmlist. */
>
> I'll also point out that in a multi-hundred-line patch, adding arguments
> to a existing function would not be something I'd try to include in the
> patch.  I'd break it out separately unless absolutely necessary.

You mean add another patch, which only adds arguments to the function,
but not change the body of the function?

>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index f42b1b0cdc58..48e2c54385ee 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -49,6 +49,9 @@ static bool swap_count_continued(struct swap_info_struct *, pgoff_t,
>>  				 unsigned char);
>>  static void free_swap_count_continuations(struct swap_info_struct *);
>>  static sector_t map_swap_entry(swp_entry_t, struct block_device**);
>> +static int add_swap_count_continuation_locked(struct swap_info_struct *si,
>> +					      unsigned long offset,
>> +					      struct page *page);
>>  
>>  DEFINE_SPINLOCK(swap_lock);
>>  static unsigned int nr_swapfiles;
>> @@ -319,6 +322,11 @@ static inline void unlock_cluster_or_swap_info(struct swap_info_struct *si,
>>  		spin_unlock(&si->lock);
>>  }
>>  
>> +static inline bool is_cluster_offset(unsigned long offset)
>> +{
>> +	return !(offset % SWAPFILE_CLUSTER);
>> +}
>> +
>>  static inline bool cluster_list_empty(struct swap_cluster_list *list)
>>  {
>>  	return cluster_is_null(&list->head);
>> @@ -1166,16 +1174,14 @@ struct swap_info_struct *get_swap_device(swp_entry_t entry)
>>  	return NULL;
>>  }
>>  
>> -static unsigned char __swap_entry_free(struct swap_info_struct *p,
>> -				       swp_entry_t entry, unsigned char usage)
>> +static unsigned char __swap_entry_free_locked(struct swap_info_struct *p,
>> +					      struct swap_cluster_info *ci,
>> +					      unsigned long offset,
>> +					      unsigned char usage)
>>  {
>> -	struct swap_cluster_info *ci;
>> -	unsigned long offset = swp_offset(entry);
>>  	unsigned char count;
>>  	unsigned char has_cache;
>>  
>> -	ci = lock_cluster_or_swap_info(p, offset);
>> -
>>  	count = p->swap_map[offset];
>>  
>>  	has_cache = count & SWAP_HAS_CACHE;
>> @@ -1203,6 +1209,17 @@ static unsigned char __swap_entry_free(struct swap_info_struct *p,
>>  	usage = count | has_cache;
>>  	p->swap_map[offset] = usage ? : SWAP_HAS_CACHE;
>>  
>> +	return usage;
>> +}
>> +
>> +static unsigned char __swap_entry_free(struct swap_info_struct *p,
>> +				       swp_entry_t entry, unsigned char usage)
>> +{
>> +	struct swap_cluster_info *ci;
>> +	unsigned long offset = swp_offset(entry);
>> +
>> +	ci = lock_cluster_or_swap_info(p, offset);
>> +	usage = __swap_entry_free_locked(p, ci, offset, usage);
>>  	unlock_cluster_or_swap_info(p, ci);
>>  
>>  	return usage;
>> @@ -3450,32 +3467,12 @@ void si_swapinfo(struct sysinfo *val)
>>  	spin_unlock(&swap_lock);
>>  }
>>  
>> -/*
>> - * Verify that a swap entry is valid and increment its swap map count.
>> - *
>> - * Returns error code in following case.
>> - * - success -> 0
>> - * - swp_entry is invalid -> EINVAL
>> - * - swp_entry is migration entry -> EINVAL
>> - * - swap-cache reference is requested but there is already one. -> EEXIST
>> - * - swap-cache reference is requested but the entry is not used. -> ENOENT
>> - * - swap-mapped reference requested but needs continued swap count. -> ENOMEM
>> - */
>> -static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>> +static int __swap_duplicate_locked(struct swap_info_struct *p,
>> +				   unsigned long offset, unsigned char usage)
>>  {
>> -	struct swap_info_struct *p;
>> -	struct swap_cluster_info *ci;
>> -	unsigned long offset;
>>  	unsigned char count;
>>  	unsigned char has_cache;
>> -	int err = -EINVAL;
>> -
>> -	p = get_swap_device(entry);
>> -	if (!p)
>> -		goto out;
>> -
>> -	offset = swp_offset(entry);
>> -	ci = lock_cluster_or_swap_info(p, offset);
>> +	int err = 0;
>>  
>>  	count = p->swap_map[offset];
>>  
>> @@ -3485,12 +3482,11 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>>  	 */
>>  	if (unlikely(swap_count(count) == SWAP_MAP_BAD)) {
>>  		err = -ENOENT;
>> -		goto unlock_out;
>> +		goto out;
>>  	}
>>  
>>  	has_cache = count & SWAP_HAS_CACHE;
>>  	count &= ~SWAP_HAS_CACHE;
>> -	err = 0;
>>  
>>  	if (usage == SWAP_HAS_CACHE) {
>>  
>> @@ -3517,11 +3513,39 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>>  
>>  	p->swap_map[offset] = count | has_cache;
>>  
>> -unlock_out:
>> +out:
>> +	return err;
>> +}
>
> ... and that all looks like refactoring, not actively implementing PMD
> swap support.  That's unfortunate.
>
>> +/*
>> + * Verify that a swap entry is valid and increment its swap map count.
>> + *
>> + * Returns error code in following case.
>> + * - success -> 0
>> + * - swp_entry is invalid -> EINVAL
>> + * - swp_entry is migration entry -> EINVAL
>> + * - swap-cache reference is requested but there is already one. -> EEXIST
>> + * - swap-cache reference is requested but the entry is not used. -> ENOENT
>> + * - swap-mapped reference requested but needs continued swap count. -> ENOMEM
>> + */
>> +static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>> +{
>> +	struct swap_info_struct *p;
>> +	struct swap_cluster_info *ci;
>> +	unsigned long offset;
>> +	int err = -EINVAL;
>> +
>> +	p = get_swap_device(entry);
>> +	if (!p)
>> +		goto out;
>
> Is this an error, or just for running into something like a migration
> entry?  Comments please.

__swap_duplicate() may be called with invalid swap entry because the swap
device may be swapoff after we get swap entry during page fault.  Yes, I
will add some comments here.

>> +	offset = swp_offset(entry);
>> +	ci = lock_cluster_or_swap_info(p, offset);
>> +	err = __swap_duplicate_locked(p, offset, usage);
>>  	unlock_cluster_or_swap_info(p, ci);
>> +
>> +	put_swap_device(p);
>>  out:
>> -	if (p)
>> -		put_swap_device(p);
>>  	return err;
>>  }
>
> Not a comment on this patch, but lock_cluster_or_swap_info() is woefully
> uncommented.

OK.  Will add some comments for that.

>> @@ -3534,6 +3558,81 @@ void swap_shmem_alloc(swp_entry_t entry)
>>  	__swap_duplicate(entry, SWAP_MAP_SHMEM);
>>  }
>>  
>> +#ifdef CONFIG_THP_SWAP
>> +static int __swap_duplicate_cluster(swp_entry_t *entry, unsigned char usage)
>> +{
>> +	struct swap_info_struct *si;
>> +	struct swap_cluster_info *ci;
>> +	unsigned long offset;
>> +	unsigned char *map;
>> +	int i, err = 0;
>
> Instead of an #ifdef, is there a reason we can't just do:
>
> 	if (!IS_ENABLED(THP_SWAP))
> 		return 0;
>
> ?

Good idea.  Will do this for the whole patchset.

>> +	si = get_swap_device(*entry);
>> +	if (!si) {
>> +		err = -EINVAL;
>> +		goto out;
>> +	}
>> +	offset = swp_offset(*entry);
>> +	ci = lock_cluster(si, offset);
>
> Could you explain a bit why we do lock_cluster() and not
> lock_cluster_or_swap_info() here?

The code size of lock_cluster() is a little smaller, and I think it is a
little easier to read.  But I know lock_cluster_or_swap_info() can be used
here without functionality problems.  If we try to merge the code for
huge and normal swap entry, that could be used.

>> +	if (cluster_is_free(ci)) {
>> +		err = -ENOENT;
>> +		goto unlock;
>> +	}
>
> Needs comments on how this could happen.  We just took the lock, so I
> assume this is some kind of race, but can you elaborate?

Sure.  Will add some comments for this.

>> +	if (!cluster_is_huge(ci)) {
>> +		err = -ENOTDIR;
>> +		goto unlock;
>> +	}
>
> Yikes!  This function is the core of the new functionality and its
> comment count is exactly 0.  There was quite a long patch description,
> which will be surely lost to the ages, but nothing in the code that
> folks _will_ be looking at for decades to come.
>
> Can we fix that?

Sure.  Will add more comments.

>> +	VM_BUG_ON(!is_cluster_offset(offset));
>> +	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
>
> So, by this point, we know we are looking at (or supposed to be looking
> at) a cluster on the device?

Yes.

>> +	map = si->swap_map + offset;
>> +	if (usage == SWAP_HAS_CACHE) {
>> +		if (map[0] & SWAP_HAS_CACHE) {
>> +			err = -EEXIST;
>> +			goto unlock;
>> +		}
>> +		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>> +			VM_BUG_ON(map[i] & SWAP_HAS_CACHE);
>> +			map[i] |= SWAP_HAS_CACHE;
>> +		}
>
> So, it's OK to race with the first entry, but after that it's a bug
> because the tail pages should agree with the head page's state?

Yes.  Will add some comments about this.

>> +	} else {
>> +		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
>> +retry:
>> +			err = __swap_duplicate_locked(si, offset + i, usage);
>> +			if (err == -ENOMEM) {
>> +				struct page *page;
>> +
>> +				page = alloc_page(GFP_ATOMIC | __GFP_HIGHMEM);
>
> I noticed that the non-clustering analog of this function takes a GFP
> mask.  Why not this one?

The value of gfp_mask is GFP_ATOMIC in swap_duplicate(), so they are
exactly same.

>> +				err = add_swap_count_continuation_locked(
>> +					si, offset + i, page);
>> +				if (err) {
>> +					*entry = swp_entry(si->type, offset+i);
>> +					goto undup;
>> +				}
>> +				goto retry;
>> +			} else if (err)
>> +				goto undup;
>> +		}
>> +		cluster_set_count(ci, cluster_count(ci) + usage);
>> +	}
>> +unlock:
>> +	unlock_cluster(ci);
>> +	put_swap_device(si);
>> +out:
>> +	return err;
>> +undup:
>> +	for (i--; i >= 0; i--)
>> +		__swap_entry_free_locked(
>> +			si, ci, offset + i, usage);
>> +	goto unlock;
>> +}
>
> So, we've basically created a fork of the __swap_duplicate() code for
> huge pages, along with a presumably new set of bugs and a second code
> path to update.  Was this unavoidable?  Can we unify this any more with
> the small pages path?

Will discuss this in another thread.

>>  /*
>>   * Increase reference count of swap entry by 1.
>>   * Returns 0 for success, or -ENOMEM if a swap_count_continuation is required
>> @@ -3541,12 +3640,15 @@ void swap_shmem_alloc(swp_entry_t entry)
>>   * if __swap_duplicate() fails for another reason (-EINVAL or -ENOENT), which
>>   * might occur if a page table entry has got corrupted.
>>   */
>> -int swap_duplicate(swp_entry_t entry)
>> +int swap_duplicate(swp_entry_t *entry, bool cluster)
>>  {
>>  	int err = 0;
>>  
>> -	while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
>> -		err = add_swap_count_continuation(entry, GFP_ATOMIC);
>> +	if (thp_swap_supported() && cluster)
>> +		return __swap_duplicate_cluster(entry, 1);
>> +
>> +	while (!err && __swap_duplicate(*entry, 1) == -ENOMEM)
>> +		err = add_swap_count_continuation(*entry, GFP_ATOMIC);
>>  	return err;
>>  }
>
> Reading this, I wonder whether this has been refactored as much as
> possible.  Both add_swap_count_continuation() and
> __swap_duplciate_cluster() start off with the same get_swap_device() dance.

Yes.  There's some duplicated code logic.  Will think about how to
improve it.

>> @@ -3558,9 +3660,12 @@ int swap_duplicate(swp_entry_t entry)
>>   * -EBUSY means there is a swap cache.
>>   * Note: return code is different from swap_duplicate().
>>   */
>> -int swapcache_prepare(swp_entry_t entry)
>> +int swapcache_prepare(swp_entry_t entry, bool cluster)
>>  {
>> -	return __swap_duplicate(entry, SWAP_HAS_CACHE);
>> +	if (thp_swap_supported() && cluster)
>> +		return __swap_duplicate_cluster(&entry, SWAP_HAS_CACHE);
>> +	else
>> +		return __swap_duplicate(entry, SWAP_HAS_CACHE);
>>  }
>>  
>>  struct swap_info_struct *swp_swap_info(swp_entry_t entry)
>> @@ -3590,51 +3695,13 @@ pgoff_t __page_file_index(struct page *page)
>>  }
>>  EXPORT_SYMBOL_GPL(__page_file_index);
>>  
>> -/*
>> - * add_swap_count_continuation - called when a swap count is duplicated
>> - * beyond SWAP_MAP_MAX, it allocates a new page and links that to the entry's
>> - * page of the original vmalloc'ed swap_map, to hold the continuation count
>> - * (for that entry and for its neighbouring PAGE_SIZE swap entries).  Called
>> - * again when count is duplicated beyond SWAP_MAP_MAX * SWAP_CONT_MAX, etc.
>
> This closes out with a lot of refactoring noise.  Any chance that can be
> isolated into another patch?

Sure.  Will do that.

Best Regards,
Huang, Ying
