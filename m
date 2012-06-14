Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 601F06B0062
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 03:28:34 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:28:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V9 06/15] hugetlb: simplify migrate_huge_page()
Message-ID: <20120614072831.GD27397@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339583254-895-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339583254-895-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 13-06-12 15:57:25, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Since we migrate only one hugepage, don't use linked list for passing the
> page around.  Directly pass the page that need to be migrated as argument.
> This also remove the usage page->lru in migrate path.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Yes nice.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/migrate.h |    4 +--
>  mm/memory-failure.c     |   13 ++--------
>  mm/migrate.c            |   65 +++++++++++++++--------------------------------
>  3 files changed, 25 insertions(+), 57 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 855c337..ce7e667 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -15,7 +15,7 @@ extern int migrate_page(struct address_space *,
>  extern int migrate_pages(struct list_head *l, new_page_t x,
>  			unsigned long private, bool offlining,
>  			enum migrate_mode mode);
> -extern int migrate_huge_pages(struct list_head *l, new_page_t x,
> +extern int migrate_huge_page(struct page *, new_page_t x,
>  			unsigned long private, bool offlining,
>  			enum migrate_mode mode);
>  
> @@ -36,7 +36,7 @@ static inline void putback_lru_pages(struct list_head *l) {}
>  static inline int migrate_pages(struct list_head *l, new_page_t x,
>  		unsigned long private, bool offlining,
>  		enum migrate_mode mode) { return -ENOSYS; }
> -static inline int migrate_huge_pages(struct list_head *l, new_page_t x,
> +static inline int migrate_huge_page(struct page *page, new_page_t x,
>  		unsigned long private, bool offlining,
>  		enum migrate_mode mode) { return -ENOSYS; }
>  
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index ab1e714..53a1495 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1414,7 +1414,6 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	int ret;
>  	unsigned long pfn = page_to_pfn(page);
>  	struct page *hpage = compound_head(page);
> -	LIST_HEAD(pagelist);
>  
>  	ret = get_any_page(page, pfn, flags);
>  	if (ret < 0)
> @@ -1429,19 +1428,11 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	}
>  
>  	/* Keep page count to indicate a given hugepage is isolated. */
> -
> -	list_add(&hpage->lru, &pagelist);
> -	ret = migrate_huge_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, 0,
> -				true);
> +	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, 0, true);
> +	put_page(hpage);
>  	if (ret) {
> -		struct page *page1, *page2;
> -		list_for_each_entry_safe(page1, page2, &pagelist, lru)
> -			put_page(page1);
> -
>  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>  			pfn, ret, page->flags);
> -		if (ret > 0)
> -			ret = -EIO;
>  		return ret;
>  	}
>  done:
> diff --git a/mm/migrate.c b/mm/migrate.c
> index be26d5c..fdce3a2 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -932,15 +932,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	if (anon_vma)
>  		put_anon_vma(anon_vma);
>  	unlock_page(hpage);
> -
>  out:
> -	if (rc != -EAGAIN) {
> -		list_del(&hpage->lru);
> -		put_page(hpage);
> -	}
> -
>  	put_page(new_hpage);
> -
>  	if (result) {
>  		if (rc)
>  			*result = rc;
> @@ -1016,48 +1009,32 @@ out:
>  	return nr_failed + retry;
>  }
>  
> -int migrate_huge_pages(struct list_head *from,
> -		new_page_t get_new_page, unsigned long private, bool offlining,
> -		enum migrate_mode mode)
> +int migrate_huge_page(struct page *hpage, new_page_t get_new_page,
> +		      unsigned long private, bool offlining,
> +		      enum migrate_mode mode)
>  {
> -	int retry = 1;
> -	int nr_failed = 0;
> -	int pass = 0;
> -	struct page *page;
> -	struct page *page2;
> -	int rc;
> -
> -	for (pass = 0; pass < 10 && retry; pass++) {
> -		retry = 0;
> -
> -		list_for_each_entry_safe(page, page2, from, lru) {
> +	int pass, rc;
> +
> +	for (pass = 0; pass < 10; pass++) {
> +		rc = unmap_and_move_huge_page(get_new_page,
> +					      private, hpage, pass > 2, offlining,
> +					      mode);
> +		switch (rc) {
> +		case -ENOMEM:
> +			goto out;
> +		case -EAGAIN:
> +			/* try again */
>  			cond_resched();
> -
> -			rc = unmap_and_move_huge_page(get_new_page,
> -					private, page, pass > 2, offlining,
> -					mode);
> -
> -			switch(rc) {
> -			case -ENOMEM:
> -				goto out;
> -			case -EAGAIN:
> -				retry++;
> -				break;
> -			case 0:
> -				break;
> -			default:
> -				/* Permanent failure */
> -				nr_failed++;
> -				break;
> -			}
> +			break;
> +		case 0:
> +			goto out;
> +		default:
> +			rc = -EIO;
> +			goto out;
>  		}
>  	}
> -	rc = 0;
>  out:
> -	if (rc)
> -		return rc;
> -
> -	return nr_failed + retry;
> +	return rc;
>  }
>  
>  #ifdef CONFIG_NUMA
> -- 
> 1.7.10
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
