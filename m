Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57A1A280393
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:45:20 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w63so37736342wrc.5
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 00:45:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l77si12474269wmi.128.2017.07.28.00.45.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 00:45:18 -0700 (PDT)
Subject: Re: [PATCH v2] cpuset: fix a deadlock due to incomplete patching of
 cpusets_enabled()
References: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
 <20170727164608.12701-1-dmitriyz@waymo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <41954034-9de1-de8e-f915-51a4b0334f98@suse.cz>
Date: Fri, 28 Jul 2017 09:45:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170727164608.12701-1-dmitriyz@waymo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dima Zavin <dmitriyz@waymo.com>, Christopher Lameter <cl@linux.com>
Cc: Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>

[+CC PeterZ]

On 07/27/2017 06:46 PM, Dima Zavin wrote:
> In codepaths that use the begin/retry interface for reading
> mems_allowed_seq with irqs disabled, there exists a race condition that
> stalls the patch process after only modifying a subset of the
> static_branch call sites.
> 
> This problem manifested itself as a dead lock in the slub
> allocator, inside get_any_partial. The loop reads
> mems_allowed_seq value (via read_mems_allowed_begin),
> performs the defrag operation, and then verifies the consistency
> of mem_allowed via the read_mems_allowed_retry and the cookie
> returned by xxx_begin. The issue here is that both begin and retry
> first check if cpusets are enabled via cpusets_enabled() static branch.
> This branch can be rewritted dynamically (via cpuset_inc) if a new
> cpuset is created. The x86 jump label code fully synchronizes across
> all CPUs for every entry it rewrites. If it rewrites only one of the
> callsites (specifically the one in read_mems_allowed_retry) and then
> waits for the smp_call_function(do_sync_core) to complete while a CPU is
> inside the begin/retry section with IRQs off and the mems_allowed value
> is changed, we can hang. This is because begin() will always return 0
> (since it wasn't patched yet) while retry() will test the 0 against
> the actual value of the seq counter.

Hm I wonder if there are other static branch users potentially having
similar problem. Then it would be best to fix this at static branch
level. Any idea, Peter? An inelegant solution would be to have indicate
static_branch_(un)likely() callsites ordering for the patching. I.e.
here we would make sure that read_mems_allowed_begin() callsites are
patched before read_mems_allowed_retry() when enabling the static key,
and the opposite order when disabling the static key.

> The fix is to cache the value that's returned by cpusets_enabled() at the
> top of the loop, and only operate on the seqcount (both begin and retry) if
> it was true.

Maybe we could just return e.g. -1 in read_mems_allowed_begin() when
cpusets are disabled, and test it in read_mems_allowed_retry() before
doing a proper seqcount retry check? Also I think you can still do the
cpusets_enabled() check in read_mems_allowed_retry() before the
was_enabled (or cookie == -1) test?

> The relevant stack traces of the two stuck threads:
> 
>   CPU: 107 PID: 1415 Comm: mkdir Tainted: G L  4.9.36-00104-g540c51286237 #4
>   Hardware name: Default string Default string/Hardware, BIOS 4.29.1-20170526215256 05/26/2017
>   task: ffff8817f9c28000 task.stack: ffffc9000ffa4000
>   RIP: smp_call_function_many+0x1f9/0x260
>   Call Trace:
>     ? setup_data_read+0xa0/0xa0
>     ? ___slab_alloc+0x28b/0x5a0
>     smp_call_function+0x3b/0x70
>     ? setup_data_read+0xa0/0xa0
>     on_each_cpu+0x2f/0x90
>     ? ___slab_alloc+0x28a/0x5a0
>     ? ___slab_alloc+0x28b/0x5a0
>     text_poke_bp+0x87/0xd0
>     ? ___slab_alloc+0x28a/0x5a0
>     arch_jump_label_transform+0x93/0x100
>     __jump_label_update+0x77/0x90
>     jump_label_update+0xaa/0xc0
>     static_key_slow_inc+0x9e/0xb0
>     cpuset_css_online+0x70/0x2e0
>     online_css+0x2c/0xa0
>     cgroup_apply_control_enable+0x27f/0x3d0
>     cgroup_mkdir+0x2b7/0x420
>     kernfs_iop_mkdir+0x5a/0x80
>     vfs_mkdir+0xf6/0x1a0
>     SyS_mkdir+0xb7/0xe0
>     entry_SYSCALL_64_fastpath+0x18/0xad
> 
>   ...
> 
>   CPU: 22 PID: 1 Comm: init Tainted: G L  4.9.36-00104-g540c51286237 #4
>   Hardware name: Default string Default string/Hardware, BIOS 4.29.1-20170526215256 05/26/2017
>   task: ffff8818087c0000 task.stack: ffffc90000030000
>   RIP: int3+0x39/0x70
>   Call Trace:
>     <#DB> ? ___slab_alloc+0x28b/0x5a0
>     <EOE> ? copy_process.part.40+0xf7/0x1de0
>     ? __slab_alloc.isra.80+0x54/0x90
>     ? copy_process.part.40+0xf7/0x1de0
>     ? copy_process.part.40+0xf7/0x1de0
>     ? kmem_cache_alloc_node+0x8a/0x280
>     ? copy_process.part.40+0xf7/0x1de0
>     ? _do_fork+0xe7/0x6c0
>     ? _raw_spin_unlock_irq+0x2d/0x60
>     ? trace_hardirqs_on_caller+0x136/0x1d0
>     ? entry_SYSCALL_64_fastpath+0x5/0xad
>     ? do_syscall_64+0x27/0x350
>     ? SyS_clone+0x19/0x20
>     ? do_syscall_64+0x60/0x350
>     ? entry_SYSCALL64_slow_path+0x25/0x25
> 
> Reported-by: Cliff Spradlin <cspradlin@waymo.com>
> Signed-off-by: Dima Zavin <dmitriyz@waymo.com>
> ---
> 
> v2:
>  - Moved the cached cpusets_enabled() state into the cookie, turned
>    the cookie into a struct and updated all the other call sites.
>  - Applied on top of v4.12 since one of the callers in page_alloc.c changed.
>    Still only tested on v4.9.36 and compile tested against v4.12.
> 
>  include/linux/cpuset.h | 27 +++++++++++++++++----------
>  mm/filemap.c           |  6 +++---
>  mm/hugetlb.c           | 12 ++++++------
>  mm/mempolicy.c         | 12 ++++++------
>  mm/page_alloc.c        |  8 ++++----
>  mm/slab.c              |  6 +++---
>  mm/slub.c              |  6 +++---
>  7 files changed, 42 insertions(+), 35 deletions(-)
> 
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index 119a3f9604b0..f64f6d3b1dce 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -16,6 +16,11 @@
>  #include <linux/mm.h>
>  #include <linux/jump_label.h>
>  
> +struct cpuset_mems_cookie {
> +	unsigned int seq;
> +	bool was_enabled;
> +};
> +
>  #ifdef CONFIG_CPUSETS
>  
>  extern struct static_key_false cpusets_enabled_key;
> @@ -113,12 +118,15 @@ extern void cpuset_print_current_mems_allowed(void);
>   * causing process failure. A retry loop with read_mems_allowed_begin and
>   * read_mems_allowed_retry prevents these artificial failures.
>   */
> -static inline unsigned int read_mems_allowed_begin(void)
> +static inline void read_mems_allowed_begin(struct cpuset_mems_cookie *cookie)
>  {
> -	if (!cpusets_enabled())
> -		return 0;
> +	if (!cpusets_enabled()) {
> +		cookie->was_enabled = false;
> +		return;
> +	}
>  
> -	return read_seqcount_begin(&current->mems_allowed_seq);
> +	cookie->was_enabled = true;
> +	cookie->seq = read_seqcount_begin(&current->mems_allowed_seq);
>  }
>  
>  /*
> @@ -127,12 +135,11 @@ static inline unsigned int read_mems_allowed_begin(void)
>   * update of mems_allowed. It is up to the caller to retry the operation if
>   * appropriate.
>   */
> -static inline bool read_mems_allowed_retry(unsigned int seq)
> +static inline bool read_mems_allowed_retry(struct cpuset_mems_cookie *cookie)
>  {
> -	if (!cpusets_enabled())
> +	if (!cookie->was_enabled)
>  		return false;
> -
> -	return read_seqcount_retry(&current->mems_allowed_seq, seq);
> +	return read_seqcount_retry(&current->mems_allowed_seq, cookie->seq);
>  }
>  
>  static inline void set_mems_allowed(nodemask_t nodemask)
> @@ -249,12 +256,12 @@ static inline void set_mems_allowed(nodemask_t nodemask)
>  {
>  }
>  
> -static inline unsigned int read_mems_allowed_begin(void)
> +static inline void read_mems_allowed_begin(struct cpuset_mems_cookie *cookie)
>  {
>  	return 0;
>  }
>  
> -static inline bool read_mems_allowed_retry(unsigned int seq)
> +static inline bool read_mems_allowed_retry(struct cpuset_mems_cookie *cookie)
>  {
>  	return false;
>  }
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 6f1be573a5e6..c0730b377519 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -716,12 +716,12 @@ struct page *__page_cache_alloc(gfp_t gfp)
>  	struct page *page;
>  
>  	if (cpuset_do_page_mem_spread()) {
> -		unsigned int cpuset_mems_cookie;
> +		struct cpuset_mems_cookie cpuset_mems_cookie;
>  		do {
> -			cpuset_mems_cookie = read_mems_allowed_begin();
> +			read_mems_allowed_begin(&cpuset_mems_cookie);
>  			n = cpuset_mem_spread_node();
>  			page = __alloc_pages_node(n, gfp, 0);
> -		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
> +		} while (!page && read_mems_allowed_retry(&cpuset_mems_cookie));
>  
>  		return page;
>  	}
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3eedb187e549..1defa44f4fe6 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -907,7 +907,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	struct zonelist *zonelist;
>  	struct zone *zone;
>  	struct zoneref *z;
> -	unsigned int cpuset_mems_cookie;
> +	struct cpuset_mems_cookie cpuset_mems_cookie;
>  
>  	/*
>  	 * A child process with MAP_PRIVATE mappings created by their parent
> @@ -923,7 +923,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  		goto err;
>  
>  retry_cpuset:
> -	cpuset_mems_cookie = read_mems_allowed_begin();
> +	read_mems_allowed_begin(&cpuset_mems_cookie);
>  	zonelist = huge_zonelist(vma, address,
>  					htlb_alloc_mask(h), &mpol, &nodemask);
>  
> @@ -945,7 +945,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	}
>  
>  	mpol_cond_put(mpol);
> -	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> +	if (unlikely(!page && read_mems_allowed_retry(&cpuset_mems_cookie)))
>  		goto retry_cpuset;
>  	return page;
>  
> @@ -1511,7 +1511,7 @@ static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
>  {
>  	int order = huge_page_order(h);
>  	gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
> -	unsigned int cpuset_mems_cookie;
> +	struct cpuset_mems_cookie cpuset_mems_cookie;
>  
>  	/*
>  	 * We need a VMA to get a memory policy.  If we do not
> @@ -1548,13 +1548,13 @@ static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
>  		struct zonelist *zl;
>  		nodemask_t *nodemask;
>  
> -		cpuset_mems_cookie = read_mems_allowed_begin();
> +		read_mems_allowed_begin(&cpuset_mems_cookie);
>  		zl = huge_zonelist(vma, addr, gfp, &mpol, &nodemask);
>  		mpol_cond_put(mpol);
>  		page = __alloc_pages_nodemask(gfp, order, zl, nodemask);
>  		if (page)
>  			return page;
> -	} while (read_mems_allowed_retry(cpuset_mems_cookie));
> +	} while (read_mems_allowed_retry(&cpuset_mems_cookie));
>  
>  	return NULL;
>  }
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 37d0b334bfe9..b4f2513a2296 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1971,13 +1971,13 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  {
>  	struct mempolicy *pol;
>  	struct page *page;
> -	unsigned int cpuset_mems_cookie;
> +	struct cpuset_mems_cookie cpuset_mems_cookie;
>  	struct zonelist *zl;
>  	nodemask_t *nmask;
>  
>  retry_cpuset:
>  	pol = get_vma_policy(vma, addr);
> -	cpuset_mems_cookie = read_mems_allowed_begin();
> +	read_mems_allowed_begin(&cpuset_mems_cookie);
>  
>  	if (pol->mode == MPOL_INTERLEAVE) {
>  		unsigned nid;
> @@ -2019,7 +2019,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  	page = __alloc_pages_nodemask(gfp, order, zl, nmask);
>  	mpol_cond_put(pol);
>  out:
> -	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> +	if (unlikely(!page && read_mems_allowed_retry(&cpuset_mems_cookie)))
>  		goto retry_cpuset;
>  	return page;
>  }
> @@ -2047,13 +2047,13 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
>  {
>  	struct mempolicy *pol = &default_policy;
>  	struct page *page;
> -	unsigned int cpuset_mems_cookie;
> +	struct cpuset_mems_cookie cpuset_mems_cookie;
>  
>  	if (!in_interrupt() && !(gfp & __GFP_THISNODE))
>  		pol = get_task_policy(current);
>  
>  retry_cpuset:
> -	cpuset_mems_cookie = read_mems_allowed_begin();
> +	read_mems_allowed_begin(&cpuset_mems_cookie);
>  
>  	/*
>  	 * No reference counting needed for current->mempolicy
> @@ -2066,7 +2066,7 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
>  				policy_zonelist(gfp, pol, numa_node_id()),
>  				policy_nodemask(gfp, pol));
>  
> -	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
> +	if (unlikely(!page && read_mems_allowed_retry(&cpuset_mems_cookie)))
>  		goto retry_cpuset;
>  
>  	return page;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2302f250d6b1..36cd4e95fb38 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3688,7 +3688,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	int no_progress_loops;
>  	unsigned long alloc_start = jiffies;
>  	unsigned int stall_timeout = 10 * HZ;
> -	unsigned int cpuset_mems_cookie;
> +	struct cpuset_mems_cookie cpuset_mems_cookie;
>  
>  	/*
>  	 * In the slowpath, we sanity check order to avoid ever trying to
> @@ -3713,7 +3713,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	compaction_retries = 0;
>  	no_progress_loops = 0;
>  	compact_priority = DEF_COMPACT_PRIORITY;
> -	cpuset_mems_cookie = read_mems_allowed_begin();
> +	read_mems_allowed_begin(&cpuset_mems_cookie);
>  
>  	/*
>  	 * The fast path uses conservative alloc_flags to succeed only until
> @@ -3872,7 +3872,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * It's possible we raced with cpuset update so the OOM would be
>  	 * premature (see below the nopage: label for full explanation).
>  	 */
> -	if (read_mems_allowed_retry(cpuset_mems_cookie))
> +	if (read_mems_allowed_retry(&cpuset_mems_cookie))
>  		goto retry_cpuset;
>  
>  	/* Reclaim has failed us, start killing things */
> @@ -3900,7 +3900,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * to fail, check if the cpuset changed during allocation and if so,
>  	 * retry.
>  	 */
> -	if (read_mems_allowed_retry(cpuset_mems_cookie))
> +	if (read_mems_allowed_retry(&cpuset_mems_cookie))
>  		goto retry_cpuset;
>  
>  	/*
> diff --git a/mm/slab.c b/mm/slab.c
> index 2a31ee3c5814..391fe9d9d24e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3195,13 +3195,13 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
>  	void *obj = NULL;
>  	struct page *page;
>  	int nid;
> -	unsigned int cpuset_mems_cookie;
> +	struct cpuset_mems_cookie cpuset_mems_cookie;
>  
>  	if (flags & __GFP_THISNODE)
>  		return NULL;
>  
>  retry_cpuset:
> -	cpuset_mems_cookie = read_mems_allowed_begin();
> +	read_mems_allowed_begin(&cpuset_mems_cookie);
>  	zonelist = node_zonelist(mempolicy_slab_node(), flags);
>  
>  retry:
> @@ -3245,7 +3245,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
>  		}
>  	}
>  
> -	if (unlikely(!obj && read_mems_allowed_retry(cpuset_mems_cookie)))
> +	if (unlikely(!obj && read_mems_allowed_retry(&cpuset_mems_cookie)))
>  		goto retry_cpuset;
>  	return obj;
>  }
> diff --git a/mm/slub.c b/mm/slub.c
> index 8addc535bcdc..55c4862852ec 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1849,7 +1849,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>  	struct zone *zone;
>  	enum zone_type high_zoneidx = gfp_zone(flags);
>  	void *object;
> -	unsigned int cpuset_mems_cookie;
> +	struct cpuset_mems_cookie cpuset_mems_cookie;
>  
>  	/*
>  	 * The defrag ratio allows a configuration of the tradeoffs between
> @@ -1874,7 +1874,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>  		return NULL;
>  
>  	do {
> -		cpuset_mems_cookie = read_mems_allowed_begin();
> +		read_mems_allowed_begin(&cpuset_mems_cookie);
>  		zonelist = node_zonelist(mempolicy_slab_node(), flags);
>  		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>  			struct kmem_cache_node *n;
> @@ -1896,7 +1896,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
>  				}
>  			}
>  		}
> -	} while (read_mems_allowed_retry(cpuset_mems_cookie));
> +	} while (read_mems_allowed_retry(&cpuset_mems_cookie));
>  #endif
>  	return NULL;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
