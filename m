Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 05CD06B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:15:40 -0500 (EST)
Received: by lfaz4 with SMTP id z4so31792831lfa.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 10:15:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m77si13379406lfg.133.2015.11.24.10.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 10:15:38 -0800 (PST)
Date: Tue, 24 Nov 2015 13:15:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm v2] mm: add page_check_address_transhuge helper
Message-ID: <20151124181521.GA19885@cmpxchg.org>
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
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 24, 2015 at 12:36:17PM +0300, Vladimir Davydov wrote:
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

Tested-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
