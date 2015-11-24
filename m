Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BF3F96B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:57:24 -0500 (EST)
Received: by wmww144 with SMTP id w144so130861855wmw.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:57:24 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id j84si25607740wma.50.2015.11.24.01.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 01:57:23 -0800 (PST)
Received: by wmuu63 with SMTP id u63so88668897wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:57:22 -0800 (PST)
Date: Tue, 24 Nov 2015 11:57:20 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm v2] mm: add page_check_address_transhuge helper
Message-ID: <20151124095720.GD15712@node.shutemov.name>
References: <1448011913-12121-1-git-send-email-vdavydov@virtuozzo.com>
 <20151124042941.GE705@swordfish>
 <20151124090930.GB15712@node.shutemov.name>
 <20151124093617.GE29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124093617.GE29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 24, 2015 at 12:36:17PM +0300, Vladimir Davydov wrote:
> On Tue, Nov 24, 2015 at 11:09:30AM +0200, Kirill A. Shutemov wrote:
> > On Tue, Nov 24, 2015 at 01:29:41PM +0900, Sergey Senozhatsky wrote:
> ...
> > > mm/built-in.o: In function `page_referenced_one':
> > > rmap.c:(.text+0x32070): undefined reference to `pmdp_clear_flush_young'
> > 
> > Something like this?
> ...
> > @@ -929,9 +929,12 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
> >  				referenced++;
> >  		}
> >  		pte_unmap(pte);
> > -	} else {
> > +	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
> >  		if (pmdp_clear_flush_young_notify(vma, address, pmd))
> >  			referenced++;
> > +	} else {
> > +		/* unexpected pmd-mapped page? */
> > +		WARN_ON_ONCE(1);
> >  	}
> >  	spin_unlock(ptl);
> 
> I think we'd better compile out page_check_address_transhuge altogether if
> CONFIG_TRANSPARENT_HUGEPAGE is disabled and use page_check_address instead.
> This would also reduce the kernel size a bit.

Looks good to me, if compiler is clever enough to remove
pmdp_clear_flush_young_notify() call for !THP. I'm not sure it is.

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

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
