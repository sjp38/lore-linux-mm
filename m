Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9A16B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:12:58 -0500 (EST)
Received: by pacej9 with SMTP id ej9so50148948pac.2
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 00:12:58 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id s12si32771729pfi.64.2015.11.25.00.12.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 00:12:57 -0800 (PST)
Date: Wed, 25 Nov 2015 17:13:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 5/9] mm, page_owner: track and print last migrate
 reason
Message-ID: <20151125081323.GB10494@js1304-P5Q-DELUXE>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-6-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448368581-6923-6-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Tue, Nov 24, 2015 at 01:36:17PM +0100, Vlastimil Babka wrote:
> During migration, page_owner info is now copied with the rest of the page, so
> the stacktrace leading to free page allocation during migration is overwritten.
> For debugging purposes, it might be however useful to know that the page has
> been migrated since its initial allocation. This might happen many times during
> the lifetime for different reasons and fully tracking this, especially with
> stacktraces would incur extra memory costs. As a compromise, store and print
> the migrate_reason of the last migration that occured to the page. This is
> enough to distinguish compaction, numa balancing etc.
> 
> Example page_owner entry after the patch:
> 
> Page allocated via order 0, mask 0x24280ca
> PFN 669757 type Reclaimable Block 1308 type Reclaimable Flags    UDLA
>  [<ffffffff81164e8a>] __alloc_pages_nodemask+0x15a/0xa30
>  [<ffffffff811ad435>] alloc_pages_vma+0xb5/0x250
>  [<ffffffff8118ba54>] handle_mm_fault+0x1304/0x1820
>  [<ffffffff81051213>] __do_page_fault+0x183/0x3f0
>  [<ffffffff810514a2>] do_page_fault+0x22/0x30
>  [<ffffffff81573ba8>] page_fault+0x28/0x30
>  [<ffffffffffffffff>] 0xffffffffffffffff
> Page has been migrated, last migrate reason: compaction
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/migrate.h    |  6 +++++-
>  include/linux/page_ext.h   |  1 +
>  include/linux/page_owner.h |  9 +++++++++
>  mm/migrate.c               | 20 +++++++++++++++++---
>  mm/page_owner.c            | 17 +++++++++++++++++
>  5 files changed, 49 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index cac1c09..ab92a8c 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -23,9 +23,13 @@ enum migrate_reason {
>  	MR_SYSCALL,		/* also applies to cpusets */
>  	MR_MEMPOLICY_MBIND,
>  	MR_NUMA_MISPLACED,
> -	MR_CMA
> +	MR_CMA,
> +	MR_TYPES
>  };
>  
> +/* In mm/migrate.c; also keep sync with include/trace/events/migrate.h */
> +extern char * migrate_reason_names[MR_TYPES];
> +
>  #ifdef CONFIG_MIGRATION
>  
>  extern void putback_movable_pages(struct list_head *l);
> diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
> index 17f118a..e1fe7cf 100644
> --- a/include/linux/page_ext.h
> +++ b/include/linux/page_ext.h
> @@ -45,6 +45,7 @@ struct page_ext {
>  	unsigned int order;
>  	gfp_t gfp_mask;
>  	unsigned int nr_entries;
> +	int last_migrate_reason;
>  	unsigned long trace_entries[8];
>  #endif
>  };
> diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
> index 6440daa..555893b 100644
> --- a/include/linux/page_owner.h
> +++ b/include/linux/page_owner.h
> @@ -12,6 +12,7 @@ extern void __set_page_owner(struct page *page,
>  			unsigned int order, gfp_t gfp_mask);
>  extern gfp_t __get_page_owner_gfp(struct page *page);
>  extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
> +extern void __set_page_owner_migrate_reason(struct page *page, int reason);
>  
>  static inline void reset_page_owner(struct page *page, unsigned int order)
>  {
> @@ -38,6 +39,11 @@ static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
>  	if (static_branch_unlikely(&page_owner_inited))
>  		__copy_page_owner(oldpage, newpage);
>  }
> +static inline void set_page_owner_migrate_reason(struct page *page, int reason)
> +{
> +	if (static_branch_unlikely(&page_owner_inited))
> +		__set_page_owner_migrate_reason(page, reason);
> +}
>  #else
>  static inline void reset_page_owner(struct page *page, unsigned int order)
>  {
> @@ -53,5 +59,8 @@ static inline gfp_t get_page_owner_gfp(struct page *page)
>  static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
>  {
>  }
> +static inline void set_page_owner_migrate_reason(struct page *page, int reason)
> +{
> +}
>  #endif /* CONFIG_PAGE_OWNER */
>  #endif /* __LINUX_PAGE_OWNER_H */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 863a0f1..12e9ab9 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -47,6 +47,16 @@
>  
>  #include "internal.h"
>  
> +char *migrate_reason_names[MR_TYPES] = {
> +	"compaction",
> +	"memory_failure",
> +	"memory_hotplug",
> +	"syscall_or_cpuset",
> +	"mempolicy_mbind",
> +	"numa_misplaced",
> +	"cma",
> +};
> +
>  /*
>   * migrate_prep() needs to be called before we start compiling a list of pages
>   * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
> @@ -955,8 +965,10 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  	}
>  
>  	rc = __unmap_and_move(page, newpage, force, mode);
> -	if (rc == MIGRATEPAGE_SUCCESS)
> +	if (rc == MIGRATEPAGE_SUCCESS) {
>  		put_new_page = NULL;
> +		set_page_owner_migrate_reason(newpage, reason);
> +	}
>  
>  out:
>  	if (rc != -EAGAIN) {
> @@ -1021,7 +1033,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  static int unmap_and_move_huge_page(new_page_t get_new_page,
>  				free_page_t put_new_page, unsigned long private,
>  				struct page *hpage, int force,
> -				enum migrate_mode mode)
> +				enum migrate_mode mode, int reason)
>  {
>  	int rc = -EAGAIN;
>  	int *result = NULL;
> @@ -1079,6 +1091,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	if (rc == MIGRATEPAGE_SUCCESS) {
>  		hugetlb_cgroup_migrate(hpage, new_hpage);
>  		put_new_page = NULL;
> +		set_page_owner_migrate_reason(new_hpage, reason);
>  	}
>  
>  	unlock_page(hpage);
> @@ -1151,7 +1164,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  			if (PageHuge(page))
>  				rc = unmap_and_move_huge_page(get_new_page,
>  						put_new_page, private, page,
> -						pass > 2, mode);
> +						pass > 2, mode, reason);
>  			else
>  				rc = unmap_and_move(get_new_page, put_new_page,
>  						private, page, pass > 2, mode,
> @@ -1842,6 +1855,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	set_page_memcg(new_page, page_memcg(page));
>  	set_page_memcg(page, NULL);
>  	page_remove_rmap(page, true);
> +	set_page_owner_migrate_reason(new_page, MR_NUMA_MISPLACED);
>  
>  	spin_unlock(ptl);
>  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index f571e55..59fd6f1 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -6,6 +6,7 @@
>  #include <linux/stacktrace.h>
>  #include <linux/page_owner.h>
>  #include <linux/jump_label.h>
> +#include <linux/migrate.h>
>  #include "internal.h"
>  
>  static bool page_owner_disabled = true;
> @@ -73,10 +74,18 @@ void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>  	page_ext->order = order;
>  	page_ext->gfp_mask = gfp_mask;
>  	page_ext->nr_entries = trace.nr_entries;
> +	page_ext->last_migrate_reason = -1;
>  
>  	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
>  }
>  
> +void __set_page_owner_migrate_reason(struct page *page, int reason)
> +{
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	page_ext->last_migrate_reason = reason;
> +}
> +
>  gfp_t __get_page_owner_gfp(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
> @@ -161,6 +170,14 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  	if (ret >= count)
>  		goto err;
>  
> +	if (page_ext->last_migrate_reason != -1) {
> +		ret += snprintf(kbuf + ret, count - ret,
> +			"Page has been migrated, last migrate reason: %s\n",
> +			migrate_reason_names[page_ext->last_migrate_reason]);
> +		if (ret >= count)
> +			goto err;
> +	}
> +

migrate_reason_names is defined if CONFIG_MIGRATION is enabled so
it would cause build failure in case of !CONFIG_MIGRATION and
CONFIG_PAGE_OWNER.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
