Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 191076B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:47:11 -0500 (EST)
Received: by pacej9 with SMTP id ej9so17404591pac.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:47:10 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sj4si25412562pac.228.2015.11.24.01.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 01:47:10 -0800 (PST)
Date: Tue, 24 Nov 2015 12:46:59 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH -mm v2] mm: add page_check_address_transhuge helper
Message-ID: <20151124094659.GF29014@esperanza>
References: <1448011913-12121-1-git-send-email-vdavydov@virtuozzo.com>
 <20151124042941.GE705@swordfish>
 <20151124090930.GB15712@node.shutemov.name>
 <20151124093617.GE29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151124093617.GE29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 24, 2015 at 12:36:17PM +0300, Vladimir Davydov wrote:
...
> I think we'd better compile out page_check_address_transhuge altogether if
> CONFIG_TRANSPARENT_HUGEPAGE is disabled and use page_check_address instead.
> This would also reduce the kernel size a bit.

Sergey, could you please check if the patch below fixes build for you?

Thanks,
Vladimir

> ---
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index b9eedc63e9e6..77d1ba57d495 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -219,9 +219,20 @@ static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
>   * Used by idle page tracking to check if a page was referenced via page
>   * tables.
>   */
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  bool page_check_address_transhuge(struct page *page, struct mm_struct *mm,
>  				  unsigned long address, pmd_t **pmdp,
>  				  pte_t **ptep, spinlock_t **ptlp);
> +#else
> +static inline bool page_check_address_transhuge(struct page *page,
> +				struct mm_struct *mm, unsigned long address,
> +				pmd_t **pmdp, pte_t **ptep, spinlock_t **ptlp)
> +{
> +	*ptep = page_check_address(page, mm, address, ptlp, 0);
> +	*pmdp = NULL;
> +	return !!*ptep;
> +}
> +#endif
>  
>  /*
>   * Used by swapoff to help locate where page is expected in vma.
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 27916086ac50..6f371261dd12 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -798,6 +798,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
>  	return 1;
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  /*
>   * Check that @page is mapped at @address into @mm. In contrast to
>   * page_check_address(), this function can handle transparent huge pages.
> @@ -885,6 +886,7 @@ found:
>  	*ptlp = ptl;
>  	return true;
>  }
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
>  struct page_referenced_arg {
>  	int mapcount;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
