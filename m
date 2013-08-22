Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 0D38A6B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 15:06:21 -0400 (EDT)
Date: Thu, 22 Aug 2013 15:06:05 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377198365-3xic0o2q-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377164907-24801-4-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377164907-24801-4-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/6] mm/hwpoison: don't set migration type twice to avoid
 hold heavy contend zone->lock
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 05:48:25PM +0800, Wanpeng Li wrote:
> Set pageblock migration type will hold zone->lock which is heavy contended 
> in system to avoid race. However, soft offline page will set pageblock 
> migration type twice during get page if the page is in used, not hugetlbfs 
> page and not on lru list. There is unnecessary to set the pageblock migration
> type and hold heavy contended zone->lock again if the first round get page 
> have already set the pageblock to right migration type.

Can we use get_pageblock_migratetype() outside zone->lock?

There are surely some users which call this function outside
zone->lock like free_hot_cold_pages(), __free_pages, etc.,
but I think that there's a race window where migratetype is
updated just after get_pageblock_migratetype() check.

> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/memory-failure.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 6bfd51e..3bfb45f 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1413,7 +1413,8 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
>  	 * was free. This flag should be kept set until the source page
>  	 * is freed and PG_hwpoison on it is set.
>  	 */
> -	set_migratetype_isolate(p, true);
> +	if (get_pageblock_migratetype(p) == MIGRATE_ISOLATE)

You meant '!=', right?

Thanks,
Naoya Horiguchi

> +		set_migratetype_isolate(p, true);
>  	/*
>  	 * When the target page is a free hugepage, just remove it
>  	 * from free hugepage list.
> -- 
> 1.8.1.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
