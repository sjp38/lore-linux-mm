Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21A946B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 12:50:38 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id cg13so150371644pac.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:50:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id de8si15040265pad.84.2016.09.29.09.50.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 09:50:37 -0700 (PDT)
Message-ID: <1475167836.3916.270.camel@linux.intel.com>
Subject: Re: [PATCH 7/8] mm/swap: Add cache for swap slots allocation
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 29 Sep 2016 09:50:36 -0700
In-Reply-To: <008401d21a1f$aa29a510$fe7cef30$@alibaba-inc.com>
References: <20160927171858.GA17943@linux.intel.com>
	 <008401d21a1f$aa29a510$fe7cef30$@alibaba-inc.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Huang Ying' <ying.huang@intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Shaohua Li' <shli@kernel.org>, 'Minchan Kim' <minchan@kernel.org>, 'Rik van Riel' <riel@redhat.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A .
 Shutemov'" <kirill.shutemov@linux.intel.com>, 'Vladimir Davydov' <vdavydov@virtuozzo.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Michal Hocko' <mhocko@kernel.org>

On Thu, 2016-09-29 at 15:04 +0800, Hillf Danton wrote:
> On Wednesday, September 28, 2016 1:19 AM Tim Chen wrote
> [...]
> > 
> > +
> > +static int alloc_swap_slot_cache(int cpu)
> > +{
> > +	struct swap_slots_cache *cache;
> > +
> > +	cache = &per_cpu(swp_slots, cpu);
> > +	mutex_init(&cache->alloc_lock);
> > +	spin_lock_init(&cache->free_lock);
> > +	cache->nr = 0;
> > +	cache->cur = 0;
> > +	cache->n_ret = 0;
> > +	cache->slots = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
> > +	if (!cache->slots) {
> > +		swap_slot_cache_enabled = false;
> > +		return -ENOMEM;
> > +	}
> > +	cache->slots_ret = vzalloc(sizeof(swp_entry_t) * SWAP_SLOTS_CACHE_SIZE);
> > +	if (!cache->slots_ret) {
> > +		vfree(cache->slots);
> > +		swap_slot_cache_enabled = false;
> > +		return -ENOMEM;
> > +	}
> > +	return 0;
> > +}
> > +
> [...]
> > 
> > +
> > +static void free_slot_cache(int cpu)
> > +{
> > +	struct swap_slots_cache *cache;
> > +
> > +	mutex_lock(&swap_slots_cache_mutex);
> > +	drain_slots_cache_cpu(cpu, SLOTS_CACHE | SLOTS_CACHE_RET);
> > +	cache = &per_cpu(swp_slots, cpu);
> > +	cache->nr = 0;
> > +	cache->cur = 0;
> > +	cache->n_ret = 0;
> > +	vfree(cache->slots);
> Also free cache->slots_ret?

Good point. A Should free cache->slots_ret here.

Tim

>A 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
