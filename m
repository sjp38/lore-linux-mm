Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0798E6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 09:20:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k190so15567462pge.9
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 06:20:22 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id n7si5559324pfh.660.2017.08.15.06.20.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 Aug 2017 06:20:21 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v4 1/3] mm/hugetlb: Allow arch to override and call the weak function
In-Reply-To: <20170728050127.28338-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20170728050127.28338-1-aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 15 Aug 2017 23:20:16 +1000
Message-ID: <87lgmlt1bj.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> When running in guest mode ppc64 supports a different mechanism for hugetlb
> allocation/reservation. The LPAR management application called HMC can
> be used to reserve a set of hugepages and we pass the details of
> reserved pages via device tree to the guest. (more details in
> htab_dt_scan_hugepage_blocks()) . We do the memblock_reserve of the range
> and later in the boot sequence, we add the reserved range to huge_boot_pages.
>
> But to enable 16G hugetlb on baremetal config (when we are not running as guest)
> we want to do memblock reservation during boot. Generic code already does this
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  include/linux/hugetlb.h | 1 +
>  mm/hugetlb.c            | 4 +++-
>  2 files changed, 4 insertions(+), 1 deletion(-)

I'm planning to take this and the rest of the series in the powerpc
tree. Unless someone on linux-mm yells at me :)

cheers

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
> index bc48ee783dd9..b97e6494d74d 100644
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
> -- 
> 2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
