Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5943C6B04DF
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 20:49:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id j124so85465255qke.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 17:49:16 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c87si1935169qkh.22.2017.07.27.17.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 17:49:15 -0700 (PDT)
Subject: Re: [PATCH V3] mm/madvise: Enable (soft|hard) offline of HugeTLB
 pages at PGD level
References: <20170426035731.6924-1-khandual@linux.vnet.ibm.com>
 <20170516100509.20122-1-khandual@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <04ae16b1-8783-fb3b-4715-b96b6644566f@oracle.com>
Date: Thu, 27 Jul 2017 17:49:10 -0700
MIME-Version: 1.0
In-Reply-To: <20170516100509.20122-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org

On 05/16/2017 03:05 AM, Anshuman Khandual wrote:
> Though migrating gigantic HugeTLB pages does not sound much like real
> world use case, they can be affected by memory errors. Hence migration
> at the PGD level HugeTLB pages should be supported just to enable soft
> and hard offline use cases.

Hi Anshuman,

Sorry for the late question, but I just stumbled on this code when
looking at something else.

It appears the primary motivation for these changes is to handle
memory errors in gigantic pages.  In this case, you migrate to
another gigantic page.  However, doesn't this assume that there is
a pre-allocated gigantic page sitting unused that will be the target
of the migration?  alloc_huge_page_node will not allocate a gigantic
page.  Or, am I missing something?

-- 
Mike Kravetz

> 
> While allocating the new gigantic HugeTLB page, it should not matter
> whether new page comes from the same node or not. There would be very
> few gigantic pages on the system afterall, we should not be bothered
> about node locality when trying to save a big page from crashing.
> 
> This change renames dequeu_huge_page_node() function as dequeue_huge
> _page_node_exact() preserving it's original functionality. Now the new
> dequeue_huge_page_node() function scans through all available online
> nodes to allocate a huge page for the NUMA_NO_NODE case and just falls
> back calling dequeu_huge_page_node_exact() for all other cases.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
> Changes in V3:
> * Dropped alloc_huge_page_nonid() as per Andrew
> * Changed dequeue_huge_page_node() to accommodate NUMA_NO_NODE as per Andrew
> * Added dequeue_huge_page_node_exact() which implements functionality for the
>   previous dequeue_huge_page_node() function
> 
> Changes in V2:
>  * Added hstate_is_gigantic() definition when !CONFIG_HUGETLB_PAGE
>    which takes care of the build failure reported earlier.
> 
>  include/linux/hugetlb.h |  7 ++++++-
>  mm/hugetlb.c            | 18 +++++++++++++++++-
>  mm/memory-failure.c     | 13 +++++++++----
>  3 files changed, 32 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index b857fc8cc2ec..614a0a40f1ef 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -466,7 +466,11 @@ extern int dissolve_free_huge_pages(unsigned long start_pfn,
>  static inline bool hugepage_migration_supported(struct hstate *h)
>  {
>  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> -	return huge_page_shift(h) == PMD_SHIFT;
> +	if ((huge_page_shift(h) == PMD_SHIFT) ||
> +		(huge_page_shift(h) == PGDIR_SHIFT))
> +		return true;
> +	else
> +		return false;
>  #else
>  	return false;
>  #endif
> @@ -518,6 +522,7 @@ struct hstate {};
>  #define vma_mmu_pagesize(v) PAGE_SIZE
>  #define huge_page_order(h) 0
>  #define huge_page_shift(h) PAGE_SHIFT
> +#define hstate_is_gigantic(h) 0
>  static inline unsigned int pages_per_huge_page(struct hstate *h)
>  {
>  	return 1;
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e5828875f7bb..7cd0f09b8dd0 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -867,7 +867,7 @@ static void enqueue_huge_page(struct hstate *h, struct page *page)
>  	h->free_huge_pages_node[nid]++;
>  }
>  
> -static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
> +static struct page *dequeue_huge_page_node_exact(struct hstate *h, int nid)
>  {
>  	struct page *page;
>  
> @@ -887,6 +887,22 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
>  	return page;
>  }
>  
> +static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
> +{
> +	struct page *page;
> +	int node;
> +
> +	if (nid != NUMA_NO_NODE)
> +		return dequeue_huge_page_node_exact(h, nid);
> +
> +	for_each_online_node(node) {
> +		page = dequeue_huge_page_node_exact(h, node);
> +		if (page)
> +			return page;
> +	}
> +	return NULL;
> +}
> +
>  /* Movability of hugepages depends on migration support. */
>  static inline gfp_t htlb_alloc_mask(struct hstate *h)
>  {
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 2527dfeddb00..f71efae2e494 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1489,11 +1489,16 @@ EXPORT_SYMBOL(unpoison_memory);
>  static struct page *new_page(struct page *p, unsigned long private, int **x)
>  {
>  	int nid = page_to_nid(p);
> -	if (PageHuge(p))
> -		return alloc_huge_page_node(page_hstate(compound_head(p)),
> -						   nid);
> -	else
> +	if (PageHuge(p)) {
> +		struct hstate *hstate = page_hstate(compound_head(p));
> +
> +		if (hstate_is_gigantic(hstate))
> +			return alloc_huge_page_node(hstate, NUMA_NO_NODE);
> +
> +		return alloc_huge_page_node(hstate, nid);
> +	} else {
>  		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> +	}
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
