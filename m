Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id E73866B0078
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 18:57:25 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id tr6so6458397ieb.14
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 15:57:25 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id p11si28526304icg.29.2014.11.03.15.57.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 15:57:24 -0800 (PST)
Received: by mail-ig0-f177.google.com with SMTP id hl2so5642387igb.10
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 15:57:24 -0800 (PST)
Date: Mon, 3 Nov 2014 15:57:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/2] mm: cma: split cma-reserved in dmesg log
In-Reply-To: <1413986796-19732-1-git-send-email-pintu.k@samsung.com>
Message-ID: <alpine.DEB.2.10.1411031556140.9845@chino.kir.corp.google.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com> <1413986796-19732-1-git-send-email-pintu.k@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mina86@mina86.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

On Wed, 22 Oct 2014, Pintu Kumar wrote:

> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index 0430ed0..0b75896 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -15,6 +15,7 @@
>  
>  struct cma;
>  
> +extern unsigned long totalcma_pages;
>  extern phys_addr_t cma_get_base(struct cma *cma);
>  extern unsigned long cma_get_size(struct cma *cma);
>  
> diff --git a/mm/cma.c b/mm/cma.c
> index 963bc4a..8435762 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -288,6 +288,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  	if (ret)
>  		goto err;
>  
> +	totalcma_pages += (size / PAGE_SIZE);
>  	pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
>  		(unsigned long)base);
>  	return 0;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dd73f9a..ababbd8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -110,6 +110,7 @@ static DEFINE_SPINLOCK(managed_page_count_lock);
>  
>  unsigned long totalram_pages __read_mostly;
>  unsigned long totalreserve_pages __read_mostly;
> +unsigned long totalcma_pages __read_mostly;

Shouldn't this be __initdata instead?

>  /*
>   * When calculating the number of globally allowed dirty pages, there
>   * is a certain number of per-zone reserves that should not be
> @@ -5520,7 +5521,7 @@ void __init mem_init_print_info(const char *str)
>  
>  	pr_info("Memory: %luK/%luK available "
>  	       "(%luK kernel code, %luK rwdata, %luK rodata, "
> -	       "%luK init, %luK bss, %luK reserved"
> +	       "%luK init, %luK bss, %luK reserved, %luK cma-reserved"
>  #ifdef	CONFIG_HIGHMEM
>  	       ", %luK highmem"
>  #endif
> @@ -5528,7 +5529,8 @@ void __init mem_init_print_info(const char *str)
>  	       nr_free_pages() << (PAGE_SHIFT-10), physpages << (PAGE_SHIFT-10),
>  	       codesize >> 10, datasize >> 10, rosize >> 10,
>  	       (init_data_size + init_code_size) >> 10, bss_size >> 10,
> -	       (physpages - totalram_pages) << (PAGE_SHIFT-10),
> +	       (physpages - totalram_pages - totalcma_pages) << (PAGE_SHIFT-10),
> +	       totalcma_pages << (PAGE_SHIFT-10),
>  #ifdef	CONFIG_HIGHMEM
>  	       totalhigh_pages << (PAGE_SHIFT-10),
>  #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
