Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF19B6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 00:15:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t6so186140732pgt.6
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 21:15:03 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b1si14529962pld.129.2017.01.22.21.15.02
        for <linux-mm@kvack.org>;
        Sun, 22 Jan 2017 21:15:02 -0800 (PST)
Date: Mon, 23 Jan 2017 14:14:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2] HWPOISON: soft offlining for non-lru movable page
Message-ID: <20170123051459.GB11763@bbox>
References: <1484837943-21745-1-git-send-email-ysxie@foxmail.com>
MIME-Version: 1.0
In-Reply-To: <1484837943-21745-1-git-send-email-ysxie@foxmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ysxie@foxmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

Hello,

On Thu, Jan 19, 2017 at 10:59:03PM +0800, ysxie@foxmail.com wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
> 
> This patch is to extends soft offlining framework to support
> non-lru page, which already support migration after
> commit bda807d44454 ("mm: migrate: support non-lru movable page
> migration")
> 
> When memory corrected errors occur on a non-lru movable page,
> we can choose to stop using it by migrating data onto another
> page and disable the original (maybe half-broken) one.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> ---
> v2:
>  delete function soft_offline_movable_page() and hanle non-lru movable
>  page in __soft_offline_page() as Michal Hocko suggested.
> 
> Any comment is more than welcome.
> 
>  mm/memory-failure.c | 27 +++++++++++++++------------
>  1 file changed, 15 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index f283c7e..74be9e1 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1527,7 +1527,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
>  {
>  	int ret = __get_any_page(page, pfn, flags);
>  
> -	if (ret == 1 && !PageHuge(page) && !PageLRU(page)) {
> +	if (ret == 1 && !PageHuge(page) &&
> +	    !PageLRU(page) && !__PageMovable(page)) {

__PageMovable without holding page_lock could be raced so need to check
if it's okay to miss some of pages offlining by the race.
When I read description of soft_offline_page, it seems to be okay.
Just wanted double check. :)

>  		/*
>  		 * Try to free it.
>  		 */
> @@ -1609,7 +1610,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  
>  static int __soft_offline_page(struct page *page, int flags)
>  {
> -	int ret;
> +	int ret = -1;
>  	unsigned long pfn = page_to_pfn(page);
>  
>  	/*
> @@ -1619,7 +1620,8 @@ static int __soft_offline_page(struct page *page, int flags)
>  	 * so there's no race between soft_offline_page() and memory_failure().
>  	 */
>  	lock_page(page);
> -	wait_on_page_writeback(page);
> +	if (PageLRU(page))
> +		wait_on_page_writeback(page);

I doubt we need to add such limitation(i.e., Only LRU pages could be write-backed).
Do you have some reason to add that code?

>  	if (PageHWPoison(page)) {
>  		unlock_page(page);
>  		put_hwpoison_page(page);
> @@ -1630,7 +1632,8 @@ static int __soft_offline_page(struct page *page, int flags)
>  	 * Try to invalidate first. This should work for
>  	 * non dirty unmapped page cache pages.
>  	 */
> -	ret = invalidate_inode_page(page);
> +	if (PageLRU(page))
> +		ret = invalidate_inode_page(page);

Ditto.

>  	unlock_page(page);
>  	/*
>  	 * RED-PEN would be better to keep it isolated here, but we
> @@ -1649,7 +1652,10 @@ static int __soft_offline_page(struct page *page, int flags)
>  	 * Try to migrate to a new page instead. migrate.c
>  	 * handles a large number of cases for us.
>  	 */
> -	ret = isolate_lru_page(page);
> +	if (PageLRU(page))
> +		ret = isolate_lru_page(page);
> +	else
> +		ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
>  	/*
>  	 * Drop page reference which is came from get_any_page()
>  	 * successful isolate_lru_page() already took another one.
> @@ -1657,18 +1663,15 @@ static int __soft_offline_page(struct page *page, int flags)
>  	put_hwpoison_page(page);
>  	if (!ret) {
>  		LIST_HEAD(pagelist);
> -		inc_node_page_state(page, NR_ISOLATED_ANON +
> +		if (PageLRU(page))

isolate_lru_page removes PG_lru so this check will be false. Namely, happens
isolated count mismatch happens.


> +			inc_node_page_state(page, NR_ISOLATED_ANON +
>  					page_is_file_cache(page));
>  		list_add(&page->lru, &pagelist);
>  		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
>  		if (ret) {
> -			if (!list_empty(&pagelist)) {
> -				list_del(&page->lru);
> -				dec_node_page_state(page, NR_ISOLATED_ANON +
> -						page_is_file_cache(page));
> -				putback_lru_page(page);
> -			}
> +			if (!list_empty(&pagelist))
> +				putback_movable_pages(&pagelist);
>  
>  			pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>  				pfn, ret, page->flags);
> -- 
> 1.9.1
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
