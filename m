Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id C97116B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 11:04:49 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so3996137wes.15
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 08:04:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o19si11244989wie.61.2014.07.14.08.04.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 08:04:48 -0700 (PDT)
Date: Mon, 14 Jul 2014 17:04:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 12/13] mm: memcontrol: rewrite charge API
Message-ID: <20140714150446.GD30713@dhcp22.suse.cz>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-13-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403124045-24361-13-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,
I've finally manage to untagle myself from internal stuff...

On Wed 18-06-14 16:40:44, Johannes Weiner wrote:
> The memcg charge API charges pages before they are rmapped - i.e. have
> an actual "type" - and so every callsite needs its own set of charge
> and uncharge functions to know what type is being operated on.  Worse,
> uncharge has to happen from a context that is still type-specific,
> rather than at the end of the page's lifetime with exclusive access,
> and so requires a lot of synchronization.
> 
> Rewrite the charge API to provide a generic set of try_charge(),
> commit_charge() and cancel_charge() transaction operations, much like
> what's currently done for swap-in:
> 
>   mem_cgroup_try_charge() attempts to reserve a charge, reclaiming
>   pages from the memcg if necessary.
> 
>   mem_cgroup_commit_charge() commits the page to the charge once it
>   has a valid page->mapping and PageAnon() reliably tells the type.
> 
>   mem_cgroup_cancel_charge() aborts the transaction.
> 
> This reduces the charge API and enables subsequent patches to
> drastically simplify uncharging.
> 
> As pages need to be committed after rmap is established but before
> they are added to the LRU, page_add_new_anon_rmap() must stop doing
> LRU additions again.  Revive lru_cache_add_active_or_unevictable().

I think it would make more sense to do
lru_cache_add_active_or_unevictable in a separate patch for easier
review. Too late, though...

Few comments bellow
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

The patch looks correct but the code is quite tricky so I hope I didn't
miss anything.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  Documentation/cgroups/memcg_test.txt |  32 +--
>  include/linux/memcontrol.h           |  53 ++---
>  include/linux/swap.h                 |   3 +
>  kernel/events/uprobes.c              |   1 +
>  mm/filemap.c                         |   9 +-
>  mm/huge_memory.c                     |  57 +++--
>  mm/memcontrol.c                      | 407 ++++++++++++++---------------------
>  mm/memory.c                          |  41 ++--
>  mm/rmap.c                            |  19 --
>  mm/shmem.c                           |  24 ++-
>  mm/swap.c                            |  34 +++
>  mm/swapfile.c                        |  14 +-
>  12 files changed, 314 insertions(+), 380 deletions(-)
> 
[...]
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index eb65d29516ca..1a9a096858e0 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -54,28 +54,11 @@ struct mem_cgroup_reclaim_cookie {
>  };
>  
>  #ifdef CONFIG_MEMCG
> -/*
> - * All "charge" functions with gfp_mask should use GFP_KERNEL or
> - * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
> - * alloc memory but reclaims memory from all available zones. So, "where I want
> - * memory from" bits of gfp_mask has no meaning. So any bits of that field is
> - * available but adding a rule is better. charge functions' gfp_mask should
> - * be set to GFP_KERNEL or gfp_mask & GFP_RECLAIM_MASK for avoiding ambiguous
> - * codes.
> - * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
> - */

I think we should slightly modify the comment but the primary idea
should stay there. What about the following?
/*
 * Although memcg charge functions do not allocate any memory they are
 * still getting GFP mask to control the reclaim process (therefore
 * gfp_mask & GFP_RECLAIM_MASK is expected).
 * GFP_KERNEL should be used for the general charge path without any
 * constraints for the reclaim
 * __GFP_WAIT should be cleared for atomic contexts
 * __GFP_NORETRY should be set for charges which might fail rather than
 * spend too much time reclaiming
 * __GFP_NOFAIL should be set for charges which cannot fail.
 */

> -
> -extern int mem_cgroup_charge_anon(struct page *page, struct mm_struct *mm,
> -				gfp_t gfp_mask);
> -/* for swap handling */
> -extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
> -		struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
> -extern void mem_cgroup_commit_charge_swapin(struct page *page,
> -					struct mem_cgroup *memcg);
> -extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg);
> -
> -extern int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
> -					gfp_t gfp_mask);
> +int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
> +			  gfp_t gfp_mask, struct mem_cgroup **memcgp);
> +void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
> +			      bool lrucare);
> +void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg);
>  
>  struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
>  struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);

[...]

> @@ -948,6 +951,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  					struct page *page,
>  					unsigned long haddr)
>  {
> +	struct mem_cgroup *memcg;
>  	spinlock_t *ptl;
>  	pgtable_t pgtable;
>  	pmd_t _pmd;
> @@ -968,20 +972,21 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  					       __GFP_OTHER_NODE,
>  					       vma, address, page_to_nid(page));
>  		if (unlikely(!pages[i] ||
> -			     mem_cgroup_charge_anon(pages[i], mm,
> -						       GFP_KERNEL))) {
> +			     mem_cgroup_try_charge(pages[i], mm, GFP_KERNEL,
> +						   &memcg))) {
>  			if (pages[i])
>  				put_page(pages[i]);
> -			mem_cgroup_uncharge_start();
>  			while (--i >= 0) {
> -				mem_cgroup_uncharge_page(pages[i]);
> +				memcg = (void *)page_private(pages[i]);

Hmm, OK the memcg couldn't go away even if mm owner has left it because
the charge is already there and the page is not on LRU so the
mem_cgroup_css_free will wait until we uncharge it or put to LRU.

> +				set_page_private(pages[i], 0);
> +				mem_cgroup_cancel_charge(pages[i], memcg);
>  				put_page(pages[i]);
>  			}
> -			mem_cgroup_uncharge_end();
>  			kfree(pages);
>  			ret |= VM_FAULT_OOM;
>  			goto out;
>  		}

		/*
		 * Pages might end up charged to a different memcgs
		 * because the mm owner might move while we are allocating
		 * them. Abuse ->private field to store the charged
		 * memcg until we know whether to commit or cancel the
		 * charge.
		 */
> +		set_page_private(pages[i], (unsigned long)memcg);
>  	}
>  
>  	for (i = 0; i < HPAGE_PMD_NR; i++) {

[...]

> +/**
> + * mem_cgroup_commit_charge - commit a page charge
> + * @page: page to charge
> + * @memcg: memcg to charge the page to
> + * @lrucare: page might be on LRU already
> + *
> + * Finalize a charge transaction started by mem_cgroup_try_charge(),
> + * after page->mapping has been set up.  This must happen atomically
> + * as part of the page instantiation, i.e. under the page table lock
> + * for anonymous pages, under the page lock for page and swap cache.
> + *
> + * In addition, the page must not be on the LRU during the commit, to
> + * prevent racing with task migration.  If it might be, use @lrucare.
> + *
> + * Use mem_cgroup_cancel_charge() to cancel the transaction instead.
> + */
> +void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
> +			      bool lrucare)

I think we should be explicit that this is only required for LRU pages.
kmem doesn't have to finalize the transaction.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
