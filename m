Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64B94280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:04:51 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id u134so38926087itb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 00:04:51 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id d136si14790137iog.76.2016.09.29.00.04.22
        for <linux-mm@kvack.org>;
        Thu, 29 Sep 2016 00:04:24 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160927171858.GA17943@linux.intel.com>
In-Reply-To: <20160927171858.GA17943@linux.intel.com>
Subject: Re: [PATCH 7/8] mm/swap: Add cache for swap slots allocation
Date: Thu, 29 Sep 2016 15:04:03 +0800
Message-ID: <008401d21a1f$aa29a510$fe7cef30$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tim.c.chen@linux.intel.com, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Huang Ying' <ying.huang@intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Shaohua Li' <shli@kernel.org>, 'Minchan Kim' <minchan@kernel.org>, 'Rik van Riel' <riel@redhat.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, 'Vladimir Davydov' <vdavydov@virtuozzo.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@kernel.org>

On Wednesday, September 28, 2016 1:19 AM Tim Chen wrote
[...]
> +
> +static int alloc_swap_slot_cache(int cpu)
> +{
> +	struct swap_slots_cache *cache;
> +
> +	cache = &per_cpu(swp_slots, cpu);
> +	mutex_init(&cache->alloc_lock);
> +	spin_lock_init(&cache->free_lock);
> +	cache->nr = 0;
> +	cache->cur = 0;
> +	cache->n_ret = 0;
> +	cache->slots = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
> +	if (!cache->slots) {
> +		swap_slot_cache_enabled = false;
> +		return -ENOMEM;
> +	}
> +	cache->slots_ret = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
> +	if (!cache->slots_ret) {
> +		vfree(cache->slots);
> +		swap_slot_cache_enabled = false;
> +		return -ENOMEM;
> +	}
> +	return 0;
> +}
> +
[...]
> +
> +static void free_slot_cache(int cpu)
> +{
> +	struct swap_slots_cache *cache;
> +
> +	mutex_lock(&swap_slots_cache_mutex);
> +	drain_slots_cache_cpu(cpu, SLOTS_CACHE | SLOTS_CACHE_RET);
> +	cache = &per_cpu(swp_slots, cpu);
> +	cache->nr = 0;
> +	cache->cur = 0;
> +	cache->n_ret = 0;
> +	vfree(cache->slots);

Also free cache->slots_ret?
Or fold the relevant two allocations into one?
 
> +	mutex_unlock(&swap_slots_cache_mutex);
> +}
> 
thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
