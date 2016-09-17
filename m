Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8447E6B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 11:47:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so32959726wmf.0
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 08:47:03 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id w1si8272166wjv.42.2016.09.17.08.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 08:47:02 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id l132so6892538wmf.1
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 08:47:02 -0700 (PDT)
Date: Sat, 17 Sep 2016 17:46:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: Return false instead of -EAGAIN for dummy
 functions
Message-ID: <20160917154659.GA29145@dhcp22.suse.cz>
References: <1474096836-31045-1-git-send-email-chengang@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474096836-31045-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chengang@emindsoft.com.cn
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, opensource.ganesh@gmail.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Sat 17-09-16 15:20:36, chengang@emindsoft.com.cn wrote:
> From: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> For migrate_misplaced_page and migrate_misplaced_transhuge_page, they
> are pure Boolean functions and are also used as pure Boolean functions,
> but the related dummy functions return -EAGAIN.

I agree that their return semantic is rather confusing wrt. how they are
used but

> Also change their related pure Boolean function numamigrate_isolate_page.

this is not true. Just look at the current usage

	migrated = migrate_misplaced_page(page, vma, target_nid);
	if (migrated) {
		page_nid = target_nid;
		flags |= TNF_MIGRATED;
	} else
		flags |= TNF_MIGRATE_FAIL;

and now take your change which changes -EAGAIN into false. See the
difference? Now I didn't even try to understand why
CONFIG_NUMA_BALANCING=n pretends a success but then in order to keep the
current semantic your patch should return true in that path. So NAK from
me until you either explain why this is OK or change it.

But to be honest I am not keen of this int -> bool changes much.
Especially if they are bringing a risk of subtle behavior change like
this patch. And without a good changelog explaining why this makes
sense.

> For variable isolated in migrate_misplaced_transhuge_page, it need not
> be initialized.
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  include/linux/migrate.h | 16 ++++++++--------
>  mm/migrate.c            | 24 ++++++++++++------------
>  2 files changed, 20 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index ae8d475..b5e791d 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -88,34 +88,34 @@ static inline void __ClearPageMovable(struct page *page)
>  
>  #ifdef CONFIG_NUMA_BALANCING
>  extern bool pmd_trans_migrating(pmd_t pmd);
> -extern int migrate_misplaced_page(struct page *page,
> -				  struct vm_area_struct *vma, int node);
> +extern bool migrate_misplaced_page(struct page *page,
> +				   struct vm_area_struct *vma, int node);
>  #else
>  static inline bool pmd_trans_migrating(pmd_t pmd)
>  {
>  	return false;
>  }
> -static inline int migrate_misplaced_page(struct page *page,
> -					 struct vm_area_struct *vma, int node)
> +static inline bool migrate_misplaced_page(struct page *page,
> +					  struct vm_area_struct *vma, int node)
>  {
> -	return -EAGAIN; /* can't migrate now */
> +	return false;
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
>  
>  #if defined(CONFIG_NUMA_BALANCING) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
> -extern int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> +extern bool migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  			struct vm_area_struct *vma,
>  			pmd_t *pmd, pmd_t entry,
>  			unsigned long address,
>  			struct page *page, int node);
>  #else
> -static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> +static inline bool migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  			struct vm_area_struct *vma,
>  			pmd_t *pmd, pmd_t entry,
>  			unsigned long address,
>  			struct page *page, int node)
>  {
> -	return -EAGAIN;
> +	return false;
>  }
>  #endif /* CONFIG_NUMA_BALANCING && CONFIG_TRANSPARENT_HUGEPAGE*/
>  
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7ee04a..3cdaa19 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1805,7 +1805,7 @@ static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
>  	return false;
>  }
>  
> -static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
> +static bool numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  {
>  	int page_lru;
>  
> @@ -1813,10 +1813,10 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  
>  	/* Avoid migrating to a node that is nearly full */
>  	if (!migrate_balanced_pgdat(pgdat, 1UL << compound_order(page)))
> -		return 0;
> +		return false;
>  
>  	if (isolate_lru_page(page))
> -		return 0;
> +		return false;
>  
>  	/*
>  	 * migrate_misplaced_transhuge_page() skips page migration's usual
> @@ -1827,7 +1827,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  	 */
>  	if (PageTransHuge(page) && page_count(page) != 3) {
>  		putback_lru_page(page);
> -		return 0;
> +		return false;
>  	}
>  
>  	page_lru = page_is_file_cache(page);
> @@ -1840,7 +1840,7 @@ static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  	 * disappearing underneath us during migration.
>  	 */
>  	put_page(page);
> -	return 1;
> +	return true;
>  }
>  
>  bool pmd_trans_migrating(pmd_t pmd)
> @@ -1854,11 +1854,11 @@ bool pmd_trans_migrating(pmd_t pmd)
>   * node. Caller is expected to have an elevated reference count on
>   * the page that will be dropped by this function before returning.
>   */
> -int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
> +bool migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
>  			   int node)
>  {
>  	pg_data_t *pgdat = NODE_DATA(node);
> -	int isolated;
> +	bool isolated;
>  	int nr_remaining;
>  	LIST_HEAD(migratepages);
>  
> @@ -1893,7 +1893,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
>  					page_is_file_cache(page));
>  			putback_lru_page(page);
>  		}
> -		isolated = 0;
> +		isolated = false;
>  	} else
>  		count_vm_numa_event(NUMA_PAGE_MIGRATE);
>  	BUG_ON(!list_empty(&migratepages));
> @@ -1901,7 +1901,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
>  
>  out:
>  	put_page(page);
> -	return 0;
> +	return false;
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
>  
> @@ -1910,7 +1910,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
>   * Migrates a THP to a given target node. page must be locked and is unlocked
>   * before returning.
>   */
> -int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> +bool migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  				struct vm_area_struct *vma,
>  				pmd_t *pmd, pmd_t entry,
>  				unsigned long address,
> @@ -1918,7 +1918,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  {
>  	spinlock_t *ptl;
>  	pg_data_t *pgdat = NODE_DATA(node);
> -	int isolated = 0;
> +	bool isolated;
>  	struct page *new_page = NULL;
>  	int page_lru = page_is_file_cache(page);
>  	unsigned long mmun_start = address & HPAGE_PMD_MASK;
> @@ -2052,7 +2052,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  out_unlock:
>  	unlock_page(page);
>  	put_page(page);
> -	return 0;
> +	return false;
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
>  
> -- 
> 1.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
