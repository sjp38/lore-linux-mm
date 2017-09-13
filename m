Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47C3E6B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 08:43:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 97so109378wrb.1
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 05:43:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o30si10934429wrb.197.2017.09.13.05.43.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 05:43:02 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:42:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC Patch 1/1] mm/hugetlb: Clarify OOM message on size of
 hugetlb and requested hugepages total
Message-ID: <20170913124258.dipjsogp6vzqyjf4@dhcp22.suse.cz>
References: <20170911154820.16203-1-Liam.Howlett@Oracle.com>
 <20170911154820.16203-2-Liam.Howlett@Oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170911154820.16203-2-Liam.Howlett@Oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@Oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

On Mon 11-09-17 11:48:20, Liam R. Howlett wrote:
> Change the output of hugetlb_show_meminfo to give the size of the
> hugetlb in more than just Kb and add a warning message if the requested
> hugepages is larger than the allocated hugepages.  The warning message
> for very badly configured hugepages has been removed in favour of this
> method.
> 
> The new messages look like this:
> ----
> Node 0 hugepages_total=1 hugepages_free=1 hugepages_surp=0
> hugepages_size=1.00 GiB
> 
> Node 0 hugepages_total=1326 hugepages_free=1326 hugepages_surp=0
> hugepages_size=2.00 MiB
> 
> hugepage_size 1.00 GiB: Requested 5 hugepages (5.00 GiB) but 1 hugepages
> (1.00 GiB) were allocated.
> 
> hugepage_size 2.00 MiB: Requested 4000 hugepages (7.81 GiB) but 1326
> hugepages (2.59 GiB) were allocated.
> ----
> 
> The old messages look like this:
> ----
> Node 0 hugepages_total=1 hugepages_free=1 hugepages_surp=0
> hugepages_size=1048576kB
> 
> Node 0 hugepages_total=1435 hugepages_free=1435 hugepages_surp=0
> hugepages_size=2048kB
> ----
> 
> Signed-off-by: Liam R. Howlett <Liam.Howlett@Oracle.com>

To be honest, I really dislike this. It doesn't really add anything
really new to the OOM report. We already know how much memory is
unreclaimable because it is reserved for hugetlb usage. Why does the
requested size make any difference? We could fail to allocate requested
number of pages because of memory pressure or fragmentation without any
sign of misconfiguration.

Also req_max_huge_pages would have to be per NUMA node othwerise you are
just losing information when allocation hugetlb pages via sysfs per node
interface.

> ---
>  include/linux/hugetlb.h |  1 +
>  mm/hugetlb.c            | 35 +++++++++++++++++++++++++++++++----
>  2 files changed, 32 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index b857fc8cc2ec..9f188d621ae0 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -313,6 +313,7 @@ struct hstate {
>  	unsigned int order;
>  	unsigned long mask;
>  	unsigned long max_huge_pages;
> +	unsigned long req_max_huge_pages;
>  	unsigned long nr_huge_pages;
>  	unsigned long free_huge_pages;
>  	unsigned long resv_huge_pages;
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3eedb187e549..83c06ce89bfd 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1461,6 +1461,7 @@ static int dissolve_free_huge_page(struct page *page)
>  		h->free_huge_pages--;
>  		h->free_huge_pages_node[nid]--;
>  		h->max_huge_pages--;
> +		h->req_max_huge_pages--;
>  		update_and_free_page(h, head);
>  	}
>  out:
> @@ -2430,6 +2431,7 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>  		goto out;
>  	}
>  
> +	h->req_max_huge_pages = count;
>  	if (nid == NUMA_NO_NODE) {
>  		/*
>  		 * global hstate attribute
> @@ -3026,14 +3028,39 @@ void hugetlb_show_meminfo(void)
>  	if (!hugepages_supported())
>  		return;
>  
> -	for_each_node_state(nid, N_MEMORY)
> -		for_each_hstate(h)
> -			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",
> +	for_each_node_state(nid, N_MEMORY) {
> +		for_each_hstate(h) {
> +			char hp_size[32];
> +
> +			string_get_size(huge_page_size(h), 1, STRING_UNITS_2,
> +					hp_size, 32);
> +			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%s\n",
>  				nid,
>  				h->nr_huge_pages_node[nid],
>  				h->free_huge_pages_node[nid],
>  				h->surplus_huge_pages_node[nid],
> -				1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
> +				hp_size);
> +		}
> +	}
> +
> +	for_each_hstate(h) {
> +		if (h->max_huge_pages < h->req_max_huge_pages) {
> +			char hp_size[32];
> +			char hpr_size[32];
> +			char hpt_size[32];
> +
> +			string_get_size(huge_page_size(h), 1, STRING_UNITS_2,
> +					hp_size, 32);
> +			string_get_size(huge_page_size(h),
> +					h->req_max_huge_pages, STRING_UNITS_2,
> +					hpr_size, 32);
> +			string_get_size(huge_page_size(h), h->max_huge_pages,
> +					STRING_UNITS_2, hpt_size, 32);
> +			pr_warn("hugepage_size %s: Requested %lu hugepages (%s) but %lu hugepages (%s) were allocated.\n",
> +				hp_size, h->req_max_huge_pages, hpr_size,
> +				h->max_huge_pages, hpt_size);
> +		}
> +	}
>  }
>  
>  void hugetlb_report_usage(struct seq_file *m, struct mm_struct *mm)
> -- 
> 2.14.1.145.gb3622a4ee
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
