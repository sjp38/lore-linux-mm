Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4616B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:48:18 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so14223pad.33
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:48:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dd1si9096812pbc.122.2014.10.20.15.48.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 15:48:17 -0700 (PDT)
Date: Mon, 20 Oct 2014 15:48:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cma: split cma-reserved in dmesg log
Message-Id: <20141020154816.9403d8684639d968948b7134@linux-foundation.org>
In-Reply-To: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, vdavydov@parallels.com, nasa4836@gmail.com, ddstreet@ieee.org, m.szyprowski@samsung.com, mina86@mina86.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, lauraa@codeaurora.org, gioh.kim@lge.com, rientjes@google.com, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

On Mon, 20 Oct 2014 13:03:10 +0530 Pintu Kumar <pintu.k@samsung.com> wrote:

> When the system boots up, in the dmesg logs we can see
> the memory statistics along with total reserved as below.
> Memory: 458840k/458840k available, 65448k reserved, 0K highmem
> 
> When CMA is enabled, still the total reserved memory remains the same.
> However, the CMA memory is not considered as reserved.
> But, when we see /proc/meminfo, the CMA memory is part of free memory.
> This creates confusion.
> This patch corrects the problem by properly substracting the CMA reserved
> memory from the total reserved memory in dmesg logs.
> 
> Below is the dmesg snaphot from an arm based device with 512MB RAM and
> 12MB single CMA region.
> 
> Before this change:
> Memory: 458840k/458840k available, 65448k reserved, 0K highmem
> 
> After this change:
> Memory: 458840k/458840k available, 53160k reserved, 12288k cma-reserved, 0K highmem
> 
> ...
>
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -295,6 +295,9 @@ static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
>  /* linux/mm/page_alloc.c */
>  extern unsigned long totalram_pages;
>  extern unsigned long totalreserve_pages;
> +#ifdef CONFIG_CMA
> +extern unsigned long totalcma_pages;
> +#endif

We don't actually need the ifdefs here - the kernel will compile OK
without them.  This means that a programming error will result in a
link-time error rather than a compile-time error but that's a pretty
small cost to pay for keeping the header files neater.

>  extern unsigned long dirty_balance_reserve;
>  extern unsigned long nr_free_buffer_pages(void);
>  extern unsigned long nr_free_pagecache_pages(void);
> diff --git a/mm/cma.c b/mm/cma.c
> index 963bc4a..73fe7be 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -45,6 +45,7 @@ struct cma {
>  static struct cma cma_areas[MAX_CMA_AREAS];
>  static unsigned cma_area_count;
>  static DEFINE_MUTEX(cma_mutex);
> +unsigned long totalcma_pages __read_mostly;

This could+should be __initdata.

>  phys_addr_t cma_get_base(struct cma *cma)
>  {
> @@ -288,6 +289,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	if (ret)
>  		goto err;
>  
> +	totalcma_pages += (size / PAGE_SIZE);
>  	pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
>  		(unsigned long)base);
>  	return 0;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dd73f9a..c6165ac 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5521,6 +5521,9 @@ void __init mem_init_print_info(const char *str)
>  	pr_info("Memory: %luK/%luK available "
>  	       "(%luK kernel code, %luK rwdata, %luK rodata, "
>  	       "%luK init, %luK bss, %luK reserved"
> +#ifdef CONFIG_CMA
> +		", %luK cma-reserved"
> +#endif
>  #ifdef	CONFIG_HIGHMEM
>  	       ", %luK highmem"
>  #endif
> @@ -5528,7 +5531,12 @@ void __init mem_init_print_info(const char *str)
>  	       nr_free_pages() << (PAGE_SHIFT-10), physpages << (PAGE_SHIFT-10),
>  	       codesize >> 10, datasize >> 10, rosize >> 10,
>  	       (init_data_size + init_code_size) >> 10, bss_size >> 10,
> +#ifdef CONFIG_CMA
> +	       (physpages - totalram_pages - totalcma_pages) << (PAGE_SHIFT-10),
> +	       totalcma_pages << (PAGE_SHIFT-10),
> +#else
>  	       (physpages - totalram_pages) << (PAGE_SHIFT-10),
> +#endif
>  #ifdef	CONFIG_HIGHMEM
>  	       totalhigh_pages << (PAGE_SHIFT-10),
>  #endif

Do we really need any of the ifdefs?  A non-CMA kernel will print "0K
cma-reserved" but is that harmful?

This is all __init code so the additional code bloat isn't a
significant issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
