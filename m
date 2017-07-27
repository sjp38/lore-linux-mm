Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF70C6B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:01:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p43so30681082wrb.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 06:01:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f185si1763049wmg.188.2017.07.27.06.01.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 06:01:26 -0700 (PDT)
Date: Thu, 27 Jul 2017 15:01:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/3] mm/hugetlb: Allow arch to override and call the
 weak function
Message-ID: <20170727130123.GE27766@dhcp22.suse.cz>
References: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu 27-07-17 11:48:26, Aneesh Kumar K.V wrote:
> For ppc64, we want to call this function when we are not running as guest.

What does this mean?

> Also, if we failed to allocate hugepages, let the user know.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  include/linux/hugetlb.h | 1 +
>  mm/hugetlb.c            | 5 ++++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 0ed8e41aaf11..8bbbd37ab105 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -358,6 +358,7 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  			pgoff_t idx);
>  
>  /* arch callback */
> +int __init __alloc_bootmem_huge_page(struct hstate *h);
>  int __init alloc_bootmem_huge_page(struct hstate *h);
>  
>  void __init hugetlb_bad_size(void);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bc48ee783dd9..a3a7a7e6339e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2083,7 +2083,9 @@ struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
>  	return page;
>  }
>  
> -int __weak alloc_bootmem_huge_page(struct hstate *h)
> +int alloc_bootmem_huge_page(struct hstate *h)
> +	__attribute__ ((weak, alias("__alloc_bootmem_huge_page")));
> +int __alloc_bootmem_huge_page(struct hstate *h)
>  {
>  	struct huge_bootmem_page *m;
>  	int nr_nodes, node;
> @@ -2104,6 +2106,7 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
>  			goto found;
>  		}
>  	}
> +	pr_info("Failed to allocate hugepage of size %ld\n", huge_page_size(h));
>  	return 0;
>  
>  found:
> -- 
> 2.13.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
