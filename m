Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF1C6B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 17:35:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y65so53311430pff.13
        for <linux-mm@kvack.org>; Fri, 12 May 2017 14:35:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q8si4322572pgc.167.2017.05.12.14.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 14:35:06 -0700 (PDT)
Date: Fri, 12 May 2017 14:35:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] mm/madvise: Enable (soft|hard) offline of HugeTLB
 pages at PGD level
Message-Id: <20170512143503.81e0de2ae3d88a53168c601a@linux-foundation.org>
In-Reply-To: <20170426035731.6924-1-khandual@linux.vnet.ibm.com>
References: <20170426035731.6924-1-khandual@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com

On Wed, 26 Apr 2017 09:27:31 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> Though migrating gigantic HugeTLB pages does not sound much like real
> world use case, they can be affected by memory errors. Hence migration
> at the PGD level HugeTLB pages should be supported just to enable soft
> and hard offline use cases.
> 
> While allocating the new gigantic HugeTLB page, it should not matter
> whether new page comes from the same node or not. There would be very
> few gigantic pages on the system afterall, we should not be bothered
> about node locality when trying to save a big page from crashing.
> 
> This introduces a new HugeTLB allocator called alloc_huge_page_nonid()
> which will scan over all online nodes on the system and allocate a
> single HugeTLB page.
> 
> ...
>
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1669,6 +1669,23 @@ struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
>  	return __alloc_buddy_huge_page(h, vma, addr, NUMA_NO_NODE);
>  }
>  
> +struct page *alloc_huge_page_nonid(struct hstate *h)
> +{
> +	struct page *page = NULL;
> +	int nid = 0;
> +
> +	spin_lock(&hugetlb_lock);
> +	if (h->free_huge_pages - h->resv_huge_pages > 0) {
> +		for_each_online_node(nid) {
> +			page = dequeue_huge_page_node(h, nid);
> +			if (page)
> +				break;
> +		}
> +	}
> +	spin_unlock(&hugetlb_lock);
> +	return page;
> +}
> +
>  /*
>   * This allocation function is useful in the context where vma is irrelevant.
>   * E.g. soft-offlining uses this function because it only cares physical
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index fe64d7729a8e..d4f5710cf3f7 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1481,11 +1481,15 @@ EXPORT_SYMBOL(unpoison_memory);
>  static struct page *new_page(struct page *p, unsigned long private, int **x)
>  {
>  	int nid = page_to_nid(p);
> -	if (PageHuge(p))
> +	if (PageHuge(p)) {
> +		if (hstate_is_gigantic(page_hstate(compound_head(p))))
> +			return alloc_huge_page_nonid(page_hstate(compound_head(p)));
> +
>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>  						   nid);
> -	else
> +	} else {
>  		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> +	}
>  }

Rather than adding alloc_huge_page_nonid(), would it be neater to teach
alloc_huge_page_node() (actually dequeue_huge_page_node()) to understand
nid==NUMA_NO_NODE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
