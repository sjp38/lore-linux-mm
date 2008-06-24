Date: Tue, 24 Jun 2008 18:49:05 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] putback_lru_page()/unevictable page handling rework v3
In-Reply-To: <20080621185408.E832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080621185408.E832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080624184122.D838.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I found one bug ;)

> -int putback_lru_page(struct page *page)
> +#ifdef CONFIG_UNEVICTABLE_LRU
> +void putback_lru_page(struct page *page)
>  {
>  	int lru;
> -	int ret = 1;
>  	int was_unevictable;
>  
> -	VM_BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(PageLRU(page));
>  
> +	was_unevictable = TestClearPageUnevictable(page);
> +
> +redo:
>  	lru = !!TestClearPageActive(page);
> -	was_unevictable = TestClearPageUnevictable(page); /* for page_evictable() */

(snip)

> +	mem_cgroup_move_lists(page, lru);
> +
> +	/*
> +	 * page's status can change while we move it among lru. If an evictable
> +	 * page is on unevictable list, it never be freed. To avoid that,
> +	 * check after we added it to the list, again.
> +	 */
> +	if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL)) {
> +		if (!isolate_lru_page(page)) {
> +			put_page(page);
> +			goto redo;

at this point, We should call ClearPageUnevictable().
otherwise, BUG() is called on isolate_lru_pages().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
