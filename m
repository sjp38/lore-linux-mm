Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 6549F6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 03:33:23 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:33:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V9 07/15] hugetlb: add a list for tracking in-use
 HugeTLB pages
Message-ID: <20120614073320.GE27397@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339583254-895-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339583254-895-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 13-06-12 15:57:26, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> hugepage_activelist will be used to track currently used HugeTLB pages.
> We need to find the in-use HugeTLB pages to support HugeTLB cgroup removal.
> On cgroup removal we update the page's HugeTLB cgroup to point to parent
> cgroup.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/hugetlb.h |    1 +
>  mm/hugetlb.c            |   12 +++++++-----
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 0f23c18..ed550d8 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -211,6 +211,7 @@ struct hstate {
>  	unsigned long resv_huge_pages;
>  	unsigned long surplus_huge_pages;
>  	unsigned long nr_overcommit_huge_pages;
> +	struct list_head hugepage_activelist;
>  	struct list_head hugepage_freelists[MAX_NUMNODES];
>  	unsigned int nr_huge_pages_node[MAX_NUMNODES];
>  	unsigned int free_huge_pages_node[MAX_NUMNODES];
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e54b695..b5b6e15 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -510,7 +510,7 @@ void copy_huge_page(struct page *dst, struct page *src)
>  static void enqueue_huge_page(struct hstate *h, struct page *page)
>  {
>  	int nid = page_to_nid(page);
> -	list_add(&page->lru, &h->hugepage_freelists[nid]);
> +	list_move(&page->lru, &h->hugepage_freelists[nid]);
>  	h->free_huge_pages++;
>  	h->free_huge_pages_node[nid]++;
>  }
> @@ -522,7 +522,7 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
>  	if (list_empty(&h->hugepage_freelists[nid]))
>  		return NULL;
>  	page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
> -	list_del(&page->lru);
> +	list_move(&page->lru, &h->hugepage_activelist);
>  	set_page_refcounted(page);
>  	h->free_huge_pages--;
>  	h->free_huge_pages_node[nid]--;
> @@ -626,10 +626,11 @@ static void free_huge_page(struct page *page)
>  	page->mapping = NULL;
>  	BUG_ON(page_count(page));
>  	BUG_ON(page_mapcount(page));
> -	INIT_LIST_HEAD(&page->lru);
>  
>  	spin_lock(&hugetlb_lock);
>  	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
> +		/* remove the page from active list */
> +		list_del(&page->lru);
>  		update_and_free_page(h, page);
>  		h->surplus_huge_pages--;
>  		h->surplus_huge_pages_node[nid]--;
> @@ -642,6 +643,7 @@ static void free_huge_page(struct page *page)
>  
>  static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
>  {
> +	INIT_LIST_HEAD(&page->lru);
>  	set_compound_page_dtor(page, free_huge_page);
>  	spin_lock(&hugetlb_lock);
>  	h->nr_huge_pages++;
> @@ -890,6 +892,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
>  
>  	spin_lock(&hugetlb_lock);
>  	if (page) {
> +		INIT_LIST_HEAD(&page->lru);
>  		r_nid = page_to_nid(page);
>  		set_compound_page_dtor(page, free_huge_page);
>  		/*
> @@ -994,7 +997,6 @@ retry:
>  	list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
>  		if ((--needed) < 0)
>  			break;
> -		list_del(&page->lru);
>  		/*
>  		 * This page is now managed by the hugetlb allocator and has
>  		 * no users -- drop the buddy allocator's reference.
> @@ -1009,7 +1011,6 @@ free:
>  	/* Free unnecessary surplus pages to the buddy allocator */
>  	if (!list_empty(&surplus_list)) {
>  		list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> -			list_del(&page->lru);
>  			put_page(page);
>  		}
>  	}
> @@ -1909,6 +1910,7 @@ void __init hugetlb_add_hstate(unsigned order)
>  	h->free_huge_pages = 0;
>  	for (i = 0; i < MAX_NUMNODES; ++i)
>  		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
> +	INIT_LIST_HEAD(&h->hugepage_activelist);
>  	h->next_nid_to_alloc = first_node(node_states[N_HIGH_MEMORY]);
>  	h->next_nid_to_free = first_node(node_states[N_HIGH_MEMORY]);
>  	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
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
