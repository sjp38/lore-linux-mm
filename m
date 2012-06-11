Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 5DC3D6B00F3
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:21:36 -0400 (EDT)
Date: Mon, 11 Jun 2012 11:21:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V8 14/16] hugetlb/cgroup: add charge/uncharge calls for
 HugeTLB alloc/free
Message-ID: <20120611092133.GI12402@tiehlicka.suse.cz>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339232401-14392-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339232401-14392-15-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Sat 09-06-12 14:29:59, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This adds necessary charge/uncharge calls in the HugeTLB code.  We do
> hugetlb cgroup charge in page alloc and uncharge in compound page destructor.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/hugetlb.c        |   16 +++++++++++++++-
>  mm/hugetlb_cgroup.c |    7 +------
>  2 files changed, 16 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bf79131..4ca92a9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -628,6 +628,8 @@ static void free_huge_page(struct page *page)
>  	BUG_ON(page_mapcount(page));
>  
>  	spin_lock(&hugetlb_lock);
> +	hugetlb_cgroup_uncharge_page(hstate_index(h),
> +				     pages_per_huge_page(h), page);
>  	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
>  		/* remove the page from active list */
>  		list_del(&page->lru);
> @@ -1116,7 +1118,10 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	struct hstate *h = hstate_vma(vma);
>  	struct page *page;
>  	long chg;
> +	int ret, idx;
> +	struct hugetlb_cgroup *h_cg;
>  
> +	idx = hstate_index(h);
>  	/*
>  	 * Processes that did not create the mapping will have no
>  	 * reserves and will not have accounted against subpool
> @@ -1132,6 +1137,11 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  		if (hugepage_subpool_get_pages(spool, chg))
>  			return ERR_PTR(-ENOSPC);
>  
> +	ret = hugetlb_cgroup_charge_page(idx, pages_per_huge_page(h), &h_cg);

So we do not have any page yet and hugetlb_cgroup_charge_cgroup sound
more appropriate

[...]
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
