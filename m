Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57F826B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:46:05 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id n5so2431790uad.19
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:46:05 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 1si1226995uax.33.2017.12.13.16.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 16:46:04 -0800 (PST)
Subject: Re: [RFC PATCH 4/5] mm, hugetlb: get rid of surplus page accounting
 tricks
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171204140117.7191-5-mhocko@kernel.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8b07431a-547e-4330-4276-570ef861bb35@oracle.com>
Date: Wed, 13 Dec 2017 16:45:55 -0800
MIME-Version: 1.0
In-Reply-To: <20171204140117.7191-5-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/04/2017 06:01 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> alloc_surplus_huge_page increases the pool size and the number of
> surplus pages opportunistically to prevent from races with the pool size
> change. See d1c3fb1f8f29 ("hugetlb: introduce nr_overcommit_hugepages
> sysctl") for more details.
> 
> The resulting code is unnecessarily hairy, cause code duplication and
> doesn't allow to share the allocation paths. Moreover pool size changes
> tend to be very seldom so optimizing for them is not really reasonable.
> Simplify the code and allow to allocate a fresh surplus page as long as
> we are under the overcommit limit and then recheck the condition after
> the allocation and drop the new page if the situation has changed. This
> should provide a reasonable guarantee that an abrupt allocation requests
> will not go way off the limit.
> 
> If we consider races with the pool shrinking and enlarging then we
> should be reasonably safe as well. In the first case we are off by one
> in the worst case and the second case should work OK because the page is
> not yet visible. We can waste CPU cycles for the allocation but that
> should be acceptable for a relatively rare condition.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/hugetlb.c | 60 +++++++++++++++++++++---------------------------------------
>  1 file changed, 21 insertions(+), 39 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a1b8b2888ec9..0c7dc269b6c0 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1538,62 +1538,44 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  static struct page *__alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
>  		int nid, nodemask_t *nmask)
>  {
> -	struct page *page;
> -	unsigned int r_nid;
> +	struct page *page = NULL;
>  
>  	if (hstate_is_gigantic(h))
>  		return NULL;
>  
> -	/*
> -	 * Assume we will successfully allocate the surplus page to
> -	 * prevent racing processes from causing the surplus to exceed
> -	 * overcommit
> -	 *
> -	 * This however introduces a different race, where a process B
> -	 * tries to grow the static hugepage pool while alloc_pages() is
> -	 * called by process A. B will only examine the per-node
> -	 * counters in determining if surplus huge pages can be
> -	 * converted to normal huge pages in adjust_pool_surplus(). A
> -	 * won't be able to increment the per-node counter, until the
> -	 * lock is dropped by B, but B doesn't drop hugetlb_lock until
> -	 * no more huge pages can be converted from surplus to normal
> -	 * state (and doesn't try to convert again). Thus, we have a
> -	 * case where a surplus huge page exists, the pool is grown, and
> -	 * the surplus huge page still exists after, even though it
> -	 * should just have been converted to a normal huge page. This
> -	 * does not leak memory, though, as the hugepage will be freed
> -	 * once it is out of use. It also does not allow the counters to
> -	 * go out of whack in adjust_pool_surplus() as we don't modify
> -	 * the node values until we've gotten the hugepage and only the
> -	 * per-node value is checked there.
> -	 */
>  	spin_lock(&hugetlb_lock);
> -	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
> -		spin_unlock(&hugetlb_lock);
> -		return NULL;
> -	} else {
> -		h->nr_huge_pages++;
> -		h->surplus_huge_pages++;
> -	}
> +	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages)
> +		goto out_unlock;
>  	spin_unlock(&hugetlb_lock);
>  
>  	page = __hugetlb_alloc_buddy_huge_page(h, gfp_mask, nid, nmask);
> +	if (!page)
> +		goto out_unlock;
>  
>  	spin_lock(&hugetlb_lock);
> -	if (page) {
> +	/*
> +	 * We could have raced with the pool size change.
> +	 * Double check that and simply deallocate the new page
> +	 * if we would end up overcommiting the surpluses. Abuse
> +	 * temporary page to workaround the nasty free_huge_page
> +	 * codeflow
> +	 */
> +	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
> +		SetPageHugeTemporary(page);
> +		put_page(page);
> +		page = NULL;
> +	} else {
> +		h->surplus_huge_pages_node[page_to_nid(page)]++;
> +		h->surplus_huge_pages++;
>  		INIT_LIST_HEAD(&page->lru);
>  		r_nid = page_to_nid(page);
>  		set_compound_page_dtor(page, HUGETLB_PAGE_DTOR);
>  		set_hugetlb_cgroup(page, NULL);
> -		/*
> -		 * We incremented the global counters already
> -		 */
>  		h->nr_huge_pages_node[r_nid]++;
>  		h->surplus_huge_pages_node[r_nid]++;
> -	} else {
> -		h->nr_huge_pages--;
> -		h->surplus_huge_pages--;

In the case of a successful surplus allocation, the following counters
are incremented:

h->surplus_huge_pages_node[page_to_nid(page)]++;
h->surplus_huge_pages++;
h->nr_huge_pages_node[r_nid]++;
h->surplus_huge_pages_node[r_nid]++;

Looks like per-node surplus_huge_pages_node is incremented twice, and
global nr_huge_pages is not incremented at all.

Also, you removed r_nid so I'm guessing this will not compile?
-- 
Mike Kravetz


>  	}
> +
> +out_unlock:
>  	spin_unlock(&hugetlb_lock);
>  
>  	return page;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
