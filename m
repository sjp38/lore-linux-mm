Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 521D86B0260
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 08:52:36 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so3102091wms.7
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 05:52:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w65si3154419wmf.6.2016.12.02.05.52.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 05:52:35 -0800 (PST)
Date: Fri, 2 Dec 2016 14:52:30 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2 2/6] mm: hugetlb: add a new parameter for some
 functions
Message-ID: <20161202135229.GJ6830@dhcp22.suse.cz>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-3-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479107259-2011-3-git-send-email-shijie.huang@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Mon 14-11-16 15:07:35, Huang Shijie wrote:
> This patch adds a new parameter, the "no_init", for these functions:
>    alloc_fresh_gigantic_page_node()
>    alloc_fresh_gigantic_page()
> 
> The prep_new_huge_page() does some initialization for the new page.
> But sometime, we do not need it to do so, such as in the surplus case
> in later patch.
> 
> With this parameter, the prep_new_huge_page() can be called by needed:
>    If the "no_init" is false, calls the prep_new_huge_page() in
>    the alloc_fresh_gigantic_page_node();

This double negative just makes my head spin. I haven't got to later
patch to understand the motivation but if anything bool do_prep would
be much more clear. In general doing these "init if a parameter is
specified" is a bad idea. It just makes the code more convoluted and
sutble. If you need the separation then __foo vs foo with the first
doing the real work and the later some additional initialization on top
sounds like a better idea to me.

Let's see what other changes are about.

> This patch makes preparation for the later patches.
> 
> Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> ---
>  mm/hugetlb.c | 15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 496b703..db0177b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1127,27 +1127,29 @@ static struct page *alloc_gigantic_page(int nid, unsigned int order)
>  static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
>  static void prep_compound_gigantic_page(struct page *page, unsigned int order);
>  
> -static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
> +static struct page *alloc_fresh_gigantic_page_node(struct hstate *h,
> +					int nid, bool no_init)
>  {
>  	struct page *page;
>  
>  	page = alloc_gigantic_page(nid, huge_page_order(h));
>  	if (page) {
>  		prep_compound_gigantic_page(page, huge_page_order(h));
> -		prep_new_huge_page(h, page, nid);
> +		if (!no_init)
> +			prep_new_huge_page(h, page, nid);
>  	}
>  
>  	return page;
>  }
>  
>  static int alloc_fresh_gigantic_page(struct hstate *h,
> -				nodemask_t *nodes_allowed)
> +				nodemask_t *nodes_allowed, bool no_init)
>  {
>  	struct page *page = NULL;
>  	int nr_nodes, node;
>  
>  	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
> -		page = alloc_fresh_gigantic_page_node(h, node);
> +		page = alloc_fresh_gigantic_page_node(h, node, no_init);
>  		if (page)
>  			return 1;
>  	}
> @@ -1166,7 +1168,7 @@ static inline void free_gigantic_page(struct page *page, unsigned int order) { }
>  static inline void destroy_compound_gigantic_page(struct page *page,
>  						unsigned int order) { }
>  static inline int alloc_fresh_gigantic_page(struct hstate *h,
> -					nodemask_t *nodes_allowed) { return 0; }
> +		nodemask_t *nodes_allowed, bool no_init) { return 0; }
>  #endif
>  
>  static void update_and_free_page(struct hstate *h, struct page *page)
> @@ -2313,7 +2315,8 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  		cond_resched();
>  
>  		if (hstate_is_gigantic(h))
> -			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
> +			ret = alloc_fresh_gigantic_page(h, nodes_allowed,
> +							false);
>  		else
>  			ret = alloc_fresh_huge_page(h, nodes_allowed);
>  		spin_lock(&hugetlb_lock);
> -- 
> 2.5.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
