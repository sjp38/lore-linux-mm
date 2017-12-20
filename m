Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C62F6B025E
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 17:43:13 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id q198so5011849vkh.18
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 14:43:13 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i21si8075761uaf.198.2017.12.20.14.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 14:43:11 -0800 (PST)
Subject: Re: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration
 improvements
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171215093309.GU16951@dhcp22.suse.cz>
 <95ba8db3-f8aa-528a-db4b-80f9d2ba9d2b@ah.jp.nec.com>
 <20171220095328.GG4831@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <233096d8-ecbc-353a-023a-4f6fa72ebb2f@oracle.com>
Date: Wed, 20 Dec 2017 14:43:03 -0800
MIME-Version: 1.0
In-Reply-To: <20171220095328.GG4831@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 12/20/2017 01:53 AM, Michal Hocko wrote:
> On Wed 20-12-17 05:33:36, Naoya Horiguchi wrote:
>> I have one comment on the code path from mbind(2).
>> The callback passed to migrate_pages() in do_mbind() (i.e. new_page())
>> calls alloc_huge_page_noerr() which currently doesn't call SetPageHugeTemporary(),
>> so hugetlb migration fails when h->surplus_huge_page >= h->nr_overcommit_huge_pages.
> 
> Yes, I am aware of that. I should have been more explicit in the
> changelog. Sorry about that and thanks for pointing it out explicitly.
> To be honest I wasn't really sure what to do about this. The code path
> is really complex and it made my head spin. I fail to see why we have to
> call alloc_huge_page and mess with reservations at all.

Oops!  I missed that in my review.

Since alloc_huge_page was called with avoid_reserve == 1, it should not
do anything with reserve counts.  One potential issue with the existing
code is cgroup accounting done by alloc_huge_page.  When the new target
page is allocated, it is charged against the cgroup even though the original
page is still accounted for.  If we are 'at the cgroup limit', the migration
may fail because of this.

I like your new code below as it explicitly takes reserve and cgroup
accounting out of the picture for migration.  Let me think about it
for another day before providing a Reviewed-by.

-- 
Mike Kravetz

>> I don't think this is a bug, but it would be better if mbind(2) works
>> more similarly with other migration callers like move_pages(2)/migrate_pages(2).
> 
> If the fix is as easy as the following I will add it to the pile.
> Otherwise I would prefer to do this separately after I find some more
> time to understand the callpath.
> ---
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index e035002d3fb6..08a4af411e25 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -345,10 +345,9 @@ struct huge_bootmem_page {
>  struct page *alloc_huge_page(struct vm_area_struct *vma,
>  				unsigned long addr, int avoid_reserve);
>  struct page *alloc_huge_page_node(struct hstate *h, int nid);
> -struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
> -				unsigned long addr, int avoid_reserve);
>  struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>  				nodemask_t *nmask);
> +struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned long address);
>  int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  			pgoff_t idx);
>  
> @@ -526,7 +525,7 @@ struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
>  #define alloc_huge_page_node(h, nid) NULL
>  #define alloc_huge_page_nodemask(h, preferred_nid, nmask) NULL
> -#define alloc_huge_page_noerr(v, a, r) NULL
> +#define alloc_huge_page_vma(vma, address) NULL
>  #define alloc_bootmem_huge_page(h) NULL
>  #define hstate_file(f) NULL
>  #define hstate_sizelog(s) NULL
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4426c5b23a20..e00deabe6d17 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1672,6 +1672,25 @@ struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
>  	return alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
>  }
>  
> +/* mempolicy aware migration callback */
> +struct page *alloc_huge_page_vma(struct vm_area_struct *vma, unsigned long address)
> +{
> +	struct mempolicy *mpol;
> +	nodemask_t *nodemask;
> +	struct page *page;
> +	struct hstate *h;
> +	gfp_t gfp_mask;
> +	int node;
> +
> +	h = hstate_vma(vma);
> +	gfp_mask = htlb_alloc_mask(h);
> +	node = huge_node(vma, address, gfp_mask, &mpol, &nodemask);
> +	page = alloc_huge_page_nodemask(h, node, nodemask);
> +	mpol_cond_put(mpol);
> +
> +	return page;
> +}
> +
>  /*
>   * Increase the hugetlb pool such that it can accommodate a reservation
>   * of size 'delta'.
> @@ -2077,20 +2096,6 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	return ERR_PTR(-ENOSPC);
>  }
>  
> -/*
> - * alloc_huge_page()'s wrapper which simply returns the page if allocation
> - * succeeds, otherwise NULL. This function is called from new_vma_page(),
> - * where no ERR_VALUE is expected to be returned.
> - */
> -struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
> -				unsigned long addr, int avoid_reserve)
> -{
> -	struct page *page = alloc_huge_page(vma, addr, avoid_reserve);
> -	if (IS_ERR(page))
> -		page = NULL;
> -	return page;
> -}
> -
>  int alloc_bootmem_huge_page(struct hstate *h)
>  	__attribute__ ((weak, alias("__alloc_bootmem_huge_page")));
>  int __alloc_bootmem_huge_page(struct hstate *h)
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f604b22ebb65..96823fa07f38 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1121,8 +1121,7 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
>  	}
>  
>  	if (PageHuge(page)) {
> -		BUG_ON(!vma);
> -		return alloc_huge_page_noerr(vma, address, 1);
> +		return alloc_huge_page_vma(vma, address);
>  	} else if (thp_migration_supported() && PageTransHuge(page)) {
>  		struct page *thp;
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
