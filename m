Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 9F57E6B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:44:31 -0400 (EDT)
Date: Thu, 14 Jun 2012 10:44:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V9 [updated] 10/15] hugetlb/cgroup: Add the cgroup
 pointer to page lru
Message-ID: <20120614084429.GH27397@tiehlicka.suse.cz>
References: <1339583254-895-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339587270-5831-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339587270-5831-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 13-06-12 17:04:30, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Add the hugetlb cgroup pointer to 3rd page lru.next. This limit
> the usage to hugetlb cgroup to only hugepages with 3 or more
> normal pages. I guess that is an acceptable limitation.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

I would be happier if you explicitely mentioned that both
hugetlb_cgroup_from_page and set_hugetlb_cgroup need hugetlb_lock held,
but

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/hugetlb_cgroup.h |   37 +++++++++++++++++++++++++++++++++++++
>  mm/hugetlb.c                   |    4 ++++
>  2 files changed, 41 insertions(+)
> 
> diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
> index e9944b4..2e4cb6b 100644
> --- a/include/linux/hugetlb_cgroup.h
> +++ b/include/linux/hugetlb_cgroup.h
> @@ -18,8 +18,34 @@
>  #include <linux/res_counter.h>
>  
>  struct hugetlb_cgroup;
> +/*
> + * Minimum page order trackable by hugetlb cgroup.
> + * At least 3 pages are necessary for all the tracking information.
> + */
> +#define HUGETLB_CGROUP_MIN_ORDER	2
>  
>  #ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
> +
> +static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
> +{
> +	VM_BUG_ON(!PageHuge(page));
> +
> +	if (compound_order(page) < HUGETLB_CGROUP_MIN_ORDER)
> +		return NULL;
> +	return (struct hugetlb_cgroup *)page[2].lru.next;
> +}
> +
> +static inline
> +int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
> +{
> +	VM_BUG_ON(!PageHuge(page));
> +
> +	if (compound_order(page) < HUGETLB_CGROUP_MIN_ORDER)
> +		return -1;
> +	page[2].lru.next = (void *)h_cg;
> +	return 0;
> +}
> +
>  static inline bool hugetlb_cgroup_disabled(void)
>  {
>  	if (hugetlb_subsys.disabled)
> @@ -28,6 +54,17 @@ static inline bool hugetlb_cgroup_disabled(void)
>  }
>  
>  #else
> +static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
> +{
> +	return NULL;
> +}
> +
> +static inline
> +int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
> +{
> +	return 0;
> +}
> +
>  static inline bool hugetlb_cgroup_disabled(void)
>  {
>  	return true;
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e899a2d..6a449c5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -28,6 +28,7 @@
>  
>  #include <linux/io.h>
>  #include <linux/hugetlb.h>
> +#include <linux/hugetlb_cgroup.h>
>  #include <linux/node.h>
>  #include "internal.h"
>  
> @@ -591,6 +592,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
>  				1 << PG_active | 1 << PG_reserved |
>  				1 << PG_private | 1 << PG_writeback);
>  	}
> +	VM_BUG_ON(hugetlb_cgroup_from_page(page));
>  	set_compound_page_dtor(page, NULL);
>  	set_page_refcounted(page);
>  	arch_release_hugepage(page);
> @@ -643,6 +645,7 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
>  	INIT_LIST_HEAD(&page->lru);
>  	set_compound_page_dtor(page, free_huge_page);
>  	spin_lock(&hugetlb_lock);
> +	set_hugetlb_cgroup(page, NULL);
>  	h->nr_huge_pages++;
>  	h->nr_huge_pages_node[nid]++;
>  	spin_unlock(&hugetlb_lock);
> @@ -892,6 +895,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>  		INIT_LIST_HEAD(&page->lru);
>  		r_nid = page_to_nid(page);
>  		set_compound_page_dtor(page, free_huge_page);
> +		set_hugetlb_cgroup(page, NULL);
>  		/*
>  		 * We incremented the global counters already
>  		 */
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
