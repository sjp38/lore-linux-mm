Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 227C16B0292
	for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:15:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q87so117683174pfk.15
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 19:15:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u2si6063646pfa.28.2017.07.23.19.15.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 19:15:32 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 2/2] mm/swap: Remove lock_initialized flag from swap_slots_cache
References: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
	<867d1fb070644e6d5f0ac7780f63e75259b82cc3.1500677066.git.tim.c.chen@linux.intel.com>
Date: Mon, 24 Jul 2017 10:15:29 +0800
In-Reply-To: <867d1fb070644e6d5f0ac7780f63e75259b82cc3.1500677066.git.tim.c.chen@linux.intel.com>
	(Tim Chen's message of "Fri, 21 Jul 2017 15:45:01 -0700")
Message-ID: <878tjeh96m.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hi, Tim,

Tim Chen <tim.c.chen@linux.intel.com> writes:

> We will only reach the lock initialization code
> in alloc_swap_slot_cache when the cpu's swap_slots_cache's slots
> have not been allocated and swap_slots_cache has not been initialized
> previously.  So the lock_initialized check is redundant and unnecessary.
> Remove lock_initialized flag from swap_slots_cache to save memory.

Is there a race condition with CPU offline/online when preempt is enabled?

CPU A                                   CPU B
-----                                   -----
                                        get_swap_page()
                                          get cache[B], cache[B]->slots != NULL
                                          preempted and moved to CPU A
                                        be offlined
                                        be onlined
                                          alloc_swap_slot_cache()
mutex_lock(cache[B]->alloc_lock)
                                            mutex_init(cache[B]->alloc_lock) !!!

The cache[B]->alloc_lock will be reinitialized when it is still held.

Best Regards,
Huang, Ying

> Reported-by: Wenwei Tao <wenwei.tww@alibaba-inc.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>  include/linux/swap_slots.h | 1 -
>  mm/swap_slots.c            | 9 ++++-----
>  2 files changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
> index 6ef92d1..a75c30b 100644
> --- a/include/linux/swap_slots.h
> +++ b/include/linux/swap_slots.h
> @@ -10,7 +10,6 @@
>  #define THRESHOLD_DEACTIVATE_SWAP_SLOTS_CACHE	(2*SWAP_SLOTS_CACHE_SIZE)
>  
>  struct swap_slots_cache {
> -	bool		lock_initialized;
>  	struct mutex	alloc_lock; /* protects slots, nr, cur */
>  	swp_entry_t	*slots;
>  	int		nr;
> diff --git a/mm/swap_slots.c b/mm/swap_slots.c
> index 4c5457c..c039e6c 100644
> --- a/mm/swap_slots.c
> +++ b/mm/swap_slots.c
> @@ -140,11 +140,10 @@ static int alloc_swap_slot_cache(unsigned int cpu)
>  	if (cache->slots || cache->slots_ret)
>  		/* cache already allocated */
>  		goto out;
> -	if (!cache->lock_initialized) {
> -		mutex_init(&cache->alloc_lock);
> -		spin_lock_init(&cache->free_lock);
> -		cache->lock_initialized = true;
> -	}
> +
> +	mutex_init(&cache->alloc_lock);
> +	spin_lock_init(&cache->free_lock);
> +
>  	cache->nr = 0;
>  	cache->cur = 0;
>  	cache->n_ret = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
