Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 601976B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 05:50:48 -0500 (EST)
Message-ID: <5137201A.5090905@cn.fujitsu.com>
Date: Wed, 06 Mar 2013 18:53:14 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 3/5] mm: get_user_pages: use NON-MOVABLE pages when
 FOLL_DURABLE flag is set
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com> <1362466679-17111-4-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1362466679-17111-4-git-send-email-m.szyprowski@samsung.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hi Marek,

On 03/05/2013 02:57 PM, Marek Szyprowski wrote:
> Ensure that newly allocated pages, which are faulted in in FOLL_DURABLE
> mode comes from non-movalbe pageblocks, to workaround migration failures
> with Contiguous Memory Allocator.

snip
> @@ -2495,7 +2498,7 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
>   */
>  static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unsigned long address, pte_t *page_table, pmd_t *pmd,
> -		spinlock_t *ptl, pte_t orig_pte)
> +		spinlock_t *ptl, pte_t orig_pte, unsigned int flags)
>  	__releases(ptl)
>  {
>  	struct page *old_page, *new_page = NULL;
> @@ -2505,6 +2508,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *dirty_page = NULL;
>  	unsigned long mmun_start = 0;	/* For mmu_notifiers */
>  	unsigned long mmun_end = 0;	/* For mmu_notifiers */
> +	gfp_t gfp = GFP_HIGHUSER_MOVABLE;
> +
> +	if (IS_ENABLED(CONFIG_CMA) && (flags & FAULT_FLAG_NO_CMA))
> +		gfp &= ~__GFP_MOVABLE;

snip
> @@ -3187,6 +3194,11 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct vm_fault vmf;
>  	int ret;
>  	int page_mkwrite = 0;
> +	gfp_t gfp = GFP_HIGHUSER_MOVABLE;
> +
> +	if (IS_ENABLED(CONFIG_CMA) && (flags & FAULT_FLAG_NO_CMA))
> +		gfp &= ~__GFP_MOVABLE;
> +
>  
>  	/*

Since the GUP unmovable pages are only corner cases in all kinds of pagefaults, 
I'm afraid that adding special treatment codes in generic pagefault core interface
is not that necessary or worth to do.
But I'm not sure if the performance impact is as large as to be worried about.


thanks,
linfeng  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
