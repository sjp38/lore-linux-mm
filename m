Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42B0B6B049F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:26:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id f16so180713248itb.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:26:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a73si10976069itd.32.2017.07.27.08.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 08:26:07 -0700 (PDT)
Date: Thu, 27 Jul 2017 11:25:56 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [PATCH v3 1/3] mm/hugetlb: Allow arch to override and call the
 weak function
Message-ID: <20170727152556.s4uw5cuvdf36hodl@oracle.com>
References: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

* Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> [170727 02:18]:
> For ppc64, we want to call this function when we are not running as guest.
> Also, if we failed to allocate hugepages, let the user know.
> 
[...]
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

There is already a call to warn the user in the
hugetlb_hstate_alloc_pages function.  If you look there, you will see
that the huge_page_size was translated into a more user friendly format
and the count prior to the failure is included.  What call path are you
trying to cover?  Also, you may want your print to be a pr_warn since it
is a failure?

Thanks,
Liam


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
