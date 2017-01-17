Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 837596B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 05:16:38 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id c7so12318081wjb.7
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:16:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f87si15409498wmh.24.2017.01.17.02.16.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 02:16:37 -0800 (PST)
Date: Tue, 17 Jan 2017 11:16:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Update][PATCH v5 7/9] mm/swap: Add cache for swap slots
 allocation
Message-ID: <20170117101631.GG19699@dhcp22.suse.cz>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
 <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim C Chen <tim.c.chen@intel.com>

On Tue 17-01-17 10:55:47, Huang, Ying wrote:
[...]
> +int free_swap_slot(swp_entry_t entry)
> +{
> +	struct swap_slots_cache *cache;
> +
> +	BUG_ON(!swap_slot_cache_initialized);
> +
> +	cache = &get_cpu_var(swp_slots);
> +	if (use_swap_slot_cache && cache->slots_ret) {
> +		spin_lock_irq(&cache->free_lock);
> +		/* Swap slots cache may be deactivated before acquiring lock */
> +		if (!use_swap_slot_cache) {
> +			spin_unlock_irq(&cache->free_lock);
> +			goto direct_free;
> +		}
> +		if (cache->n_ret >= SWAP_SLOTS_CACHE_SIZE) {
> +			/*
> +			 * Return slots to global pool.
> +			 * The current swap_map value is SWAP_HAS_CACHE.
> +			 * Set it to 0 to indicate it is available for
> +			 * allocation in global pool
> +			 */
> +			swapcache_free_entries(cache->slots_ret, cache->n_ret);
> +			cache->n_ret = 0;
> +		}
> +		cache->slots_ret[cache->n_ret++] = entry;
> +		spin_unlock_irq(&cache->free_lock);
> +	} else {
> +direct_free:
> +		swapcache_free_entries(&entry, 1);
> +	}
> +	put_cpu_var(swp_slots);
> +
> +	return 0;
> +}
> +
> +swp_entry_t get_swap_page(void)
> +{
> +	swp_entry_t entry, *pentry;
> +	struct swap_slots_cache *cache;
> +
> +	/*
> +	 * Preemption need to be turned on here, because we may sleep
> +	 * in refill_swap_slots_cache().  But it is safe, because
> +	 * accesses to the per-CPU data structure are protected by a
> +	 * mutex.
> +	 */

the comment doesn't really explain why it is safe. THere are other users
which are not using the lock. E.g. just look at free_swap_slot above. 
How can
	cache->slots_ret[cache->n_ret++] = entry;
be safe wrt.
	pentry = &cache->slots[cache->cur++];
	entry = *pentry;

Both of them might touch the same slot, no? Btw. I would rather prefer
this would be a follow up fix with the trace and the detailed
explanation.

> +	cache = raw_cpu_ptr(&swp_slots);
> +
> +	entry.val = 0;
> +	if (check_cache_active()) {
> +		mutex_lock(&cache->alloc_lock);
> +		if (cache->slots) {
> +repeat:
> +			if (cache->nr) {
> +				pentry = &cache->slots[cache->cur++];
> +				entry = *pentry;
> +				pentry->val = 0;
> +				cache->nr--;
> +			} else {
> +				if (refill_swap_slots_cache(cache))
> +					goto repeat;
> +			}
> +		}
> +		mutex_unlock(&cache->alloc_lock);
> +		if (entry.val)
> +			return entry;
> +	}
> +
> +	get_swap_pages(1, &entry);
> +
> +	return entry;
> +}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
