Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67A2D6B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 21:42:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 76so3753901pfr.3
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 18:42:28 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n7si2138943pga.352.2017.11.01.18.42.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 18:42:27 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm: extend reuse_swap_page range as much as possible
References: <1509533474-98584-1-git-send-email-zhouxianrong@huawei.com>
Date: Thu, 02 Nov 2017 09:42:22 +0800
In-Reply-To: <1509533474-98584-1-git-send-email-zhouxianrong@huawei.com>
	(zhouxianrong@huawei.com's message of "Wed, 1 Nov 2017 18:51:14
	+0800")
Message-ID: <87tvyd4fsx.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ying.huang@intel.com, tim.c.chen@linux.intel.com, mhocko@suse.com, rientjes@google.com, mingo@kernel.org, vegard.nossum@oracle.com, minchan@kernel.org, aaron.lu@intel.com, zhouxiyu@huawei.com, weidu.du@huawei.com, fanghua3@huawei.com, hutj@huawei.com, won.ho.park@huawei.com

<zhouxianrong@huawei.com> writes:

> From: zhouxianrong <zhouxianrong@huawei.com>
>
> origanlly reuse_swap_page requires that the sum of page's
> mapcount and swapcount less than or equal to one.
> in this case we can reuse this page and avoid COW currently.
>
> now reuse_swap_page requires only that page's mapcount
> less than or equal to one and the page is not dirty in
> swap cache. in this case we do not care its swap count.
>
> the page without dirty in swap cache means that it has
> been written to swap device successfully for reclaim before
> and then read again on a swap fault. in this case the page
> can be reused even though its swap count is greater than one
> and postpone the COW on other successive accesses to the swap
> cache page later rather than now.
>
> i did this patch test in kernel 4.4.23 with arm64 and none huge
> memory. it work fine.

Why do you need this?  You saved copying one page from memory to memory
(COW) now, at the cost of reading a page from disk to memory later?

Best Regards,
Huang, Ying

> Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
> ---
>  mm/swapfile.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index bf91dc9..c21cf07 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1543,22 +1543,27 @@ static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
>  bool reuse_swap_page(struct page *page, int *total_map_swapcount)
>  {
>  	int count, total_mapcount, total_swapcount;
> +	int dirty;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	if (unlikely(PageKsm(page)))
>  		return false;
> +	dirty = PageDirty(page);
>  	count = page_trans_huge_map_swapcount(page, &total_mapcount,
>  					      &total_swapcount);
>  	if (total_map_swapcount)
>  		*total_map_swapcount = total_mapcount + total_swapcount;
> -	if (count == 1 && PageSwapCache(page) &&
> +	if ((total_mapcount <= 1 && !dirty) ||
> +		(count == 1 && PageSwapCache(page) &&
>  	    (likely(!PageTransCompound(page)) ||
>  	     /* The remaining swap count will be freed soon */
> -	     total_swapcount == page_swapcount(page))) {
> +	     total_swapcount == page_swapcount(page)))) {
>  		if (!PageWriteback(page)) {
>  			page = compound_head(page);
>  			delete_from_swap_cache(page);
>  			SetPageDirty(page);
> +			if (!dirty)
> +				return true;
>  		} else {
>  			swp_entry_t entry;
>  			struct swap_info_struct *p;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
