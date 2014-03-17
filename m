Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6911A6B00A8
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:42:06 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so4760494wes.39
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 09:42:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u18si5428530wiv.33.2014.03.17.09.42.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 09:42:04 -0700 (PDT)
Date: Mon, 17 Mar 2014 17:42:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RESEND -mm 02/12] memcg: fix race in memcg cache
 destruction path
Message-ID: <20140317164203.GC30623@dhcp22.suse.cz>
References: <cover.1394708827.git.vdavydov@parallels.com>
 <94fc308b9074e45a2aac7a06cf357a33c5d97c9f.1394708827.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94fc308b9074e45a2aac7a06cf357a33c5d97c9f.1394708827.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Thu 13-03-14 19:06:40, Vladimir Davydov wrote:
> We schedule memcg cache shrink+destruction work (memcg_params::destroy)
> from two places: when we turn memcg offline
> (mem_cgroup_destroy_all_caches) and when the last page of the cache is
> freed (memcg_params::nr_pages reachs zero, see memcg_release_pages,
> mem_cgroup_destroy_cache).

This is just ugly! Why do we mem_cgroup_destroy_all_caches from the
offline code at all? Just calling kmem_cache_shrink and then wait for
the last pages to go away should be sufficient to fix this, no?

Whether the current code is good (no it's not) is another question. But
this should be fixed also in the stable trees (is the bug there since
the very beginning?) so the fix should be as simple as possible IMO.
So if there is a simpler solution I would prefer it. But I am drowning
in the kmem trickiness spread out all over the place so I might be
missing something very easily.

> Since the latter can happen while the work
> scheduled from mem_cgroup_destroy_all_caches is in progress or still
> pending, we need to be cautious to avoid races there - we should
> accurately bail out in one of those functions if we see that the other
> is in progress. Currently we only check if memcg_params::nr_pages is 0
> in the destruction work handler and do not destroy the cache if so. But
> that's not enough. An example of race we can get is shown below:
> 
>   CPU0					CPU1
>   ----					----
>   kmem_cache_destroy_work_func:		memcg_release_pages:
> 					  atomic_sub_and_test(1<<order, &s->
> 							memcg_params->nr_pages)
> 					  /* reached 0 => schedule destroy */
> 
>     atomic_read(&cachep->memcg_params->nr_pages)
>     /* 0 => going to destroy the cache */
>     kmem_cache_destroy(cachep);
> 
> 					  mem_cgroup_destroy_cache(s):
> 					    /* the cache was destroyed on CPU0
> 					       - use after free */
> 
> An obvious way to fix this would be substituting the nr_pages counter
> with a reference counter and make memcg take a reference. The cache
> destruction would be then scheduled from that thread which decremented
> the refcount to 0. Generally, this is what this patch does, but there is
> one subtle thing here - the work handler serves not only for cache
> destruction, it also shrinks the cache if it's still in use (we can't
> call shrink directly from mem_cgroup_destroy_all_caches due to locking
> dependencies). We handle this by noting that we should only issue shrink
> if called from mem_cgroup_destroy_all_caches, because the cache is
> already empty when we release its last page. And if we drop the
> reference taken by memcg in the work handler, we can detect who exactly
> scheduled the worker - mem_cgroup_destroy_all_caches or
> memcg_release_pages.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Glauber Costa <glommer@gmail.com>
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
