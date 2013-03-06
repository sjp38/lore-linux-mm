Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3F03E6B0005
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 21:41:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6B6343EE0BC
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:41:48 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5376545DEB6
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:41:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3194D45DEB2
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:41:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B19E1DB803E
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:41:48 +0900 (JST)
Received: from g01jpexchkw05.g01.fujitsu.local (g01jpexchkw05.g01.fujitsu.local [10.0.194.44])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C9C8E1DB803C
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:41:47 +0900 (JST)
Message-ID: <5136ACCB.8080702@jp.fujitsu.com>
Date: Wed, 6 Mar 2013 11:41:15 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH 4/5] mm: get_user_pages: migrate out CMA pages when
 FOLL_DURABLE flag is set
References: <1362466679-17111-1-git-send-email-m.szyprowski@samsung.com> <1362466679-17111-5-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1362466679-17111-5-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

2013/03/05 15:57, Marek Szyprowski wrote:
> When __get_user_pages() is called with FOLL_DURABLE flag, ensure that no
> page in CMA pageblocks gets locked. This workarounds the permanent
> migration failures caused by locking the pages by get_user_pages() call for
> a long period of time.
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>   mm/internal.h |   12 ++++++++++++
>   mm/memory.c   |   43 +++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 55 insertions(+)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 8562de0..a290d04 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -105,6 +105,18 @@ extern void prep_compound_page(struct page *page, unsigned long order);
>   extern bool is_free_buddy_page(struct page *page);
>   #endif
>   
> +#ifdef CONFIG_CMA
> +static inline int is_cma_page(struct page *page)
> +{
> +	unsigned mt = get_pageblock_migratetype(page);
> +	if (mt == MIGRATE_ISOLATE || mt == MIGRATE_CMA)
> +		return true;
> +	return false;
> +}
> +#else
> +#define is_cma_page(page) 0
> +#endif
> +
>   #if defined CONFIG_COMPACTION || defined CONFIG_CMA
>   
>   /*
> diff --git a/mm/memory.c b/mm/memory.c
> index 2b9c2dd..f81b273 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1650,6 +1650,45 @@ static inline int stack_guard_page(struct vm_area_struct *vma, unsigned long add
>   }
>   
>   /**
> + * replace_cma_page() - migrate page out of CMA page blocks
> + * @page:	source page to be migrated
> + *
> + * Returns either the old page (if migration was not possible) or the pointer
> + * to the newly allocated page (with additional reference taken).
> + *
> + * get_user_pages() might take a reference to a page for a long period of time,
> + * what prevent such page from migration. This is fatal to the preffered usage
> + * pattern of CMA pageblocks. This function replaces the given user page with
> + * a new one allocated from NON-MOVABLE pageblock, so locking CMA page can be
> + * avoided.
> + */
> +static inline struct page *migrate_replace_cma_page(struct page *page)
> +{
> +	struct page *newpage = alloc_page(GFP_HIGHUSER);
> +
> +	if (!newpage)
> +		goto out;
> +
> +	/*
> +	 * Take additional reference to the new page to ensure it won't get
> +	 * freed after migration procedure end.
> +	 */
> +	get_page_foll(newpage);
> +
> +	if (migrate_replace_page(page, newpage) == 0)
> +		return newpage;
> +
> +	put_page(newpage);
> +	__free_page(newpage);
> +out:
> +	/*
> +	 * Migration errors in case of get_user_pages() might not
> +	 * be fatal to CMA itself, so better don't fail here.
> +	 */
> +	return page;
> +}
> +
> +/**
>    * __get_user_pages() - pin user pages in memory
>    * @tsk:	task_struct of target task
>    * @mm:		mm_struct of target mm
> @@ -1884,6 +1923,10 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>   			}
>   			if (IS_ERR(page))
>   				return i ? i : PTR_ERR(page);

> +
> +			if ((gup_flags & FOLL_DURABLE) && is_cma_page(page))
> +				page = migrate_replace_cma_page(page);
> +

I might be misreading. 
If FOLL_DURABLE is set, this page is always allocated as non movable.
Is it right? If so, when does this situation occur?

Thanks,
Yasuaki Ishimatsu

>   			if (pages) {
>   				pages[i] = page;
>   
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
