Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id E339582F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 08:55:06 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so9965818wic.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 05:55:06 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id q141si3599664wmg.5.2015.10.30.05.55.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 05:55:05 -0700 (PDT)
Received: by wmll128 with SMTP id l128so11553441wml.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 05:55:05 -0700 (PDT)
Date: Fri, 30 Oct 2015 13:55:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] mm: clear PG_dirty to mark page freeable
Message-ID: <20151030125504.GC23627@dhcp22.suse.cz>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-8-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446188504-28023-8-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>

On Fri 30-10-15 16:01:43, Minchan Kim wrote:
> Basically, MADV_FREE relies on dirty bit in page table entry to decide
> whether VM allows to discard the page or not.  IOW, if page table entry
> includes marked dirty bit, VM shouldn't discard the page.
> 
> However, as a example, if swap-in by read fault happens, page table entry
> doesn't have dirty bit so MADV_FREE could discard the page wrongly.
> 
> For avoiding the problem, MADV_FREE did more checks with PageDirty
> and PageSwapCache. It worked out because swapped-in page lives on
> swap cache and since it is evicted from the swap cache, the page has
> PG_dirty flag. So both page flags check effectively prevent
> wrong discarding by MADV_FREE.
> 
> However, a problem in above logic is that swapped-in page has
> PG_dirty still after they are removed from swap cache so VM cannot
> consider the page as freeable any more even if madvise_free is
> called in future.
> 
> Look at below example for detail.
> 
>     ptr = malloc();
>     memset(ptr);
>     ..
>     ..
>     .. heavy memory pressure so all of pages are swapped out
>     ..
>     ..
>     var = *ptr; -> a page swapped-in and could be removed from
>                    swapcache. Then, page table doesn't mark
>                    dirty bit and page descriptor includes PG_dirty
>     ..
>     ..
>     madvise_free(ptr); -> It doesn't clear PG_dirty of the page.
>     ..
>     ..
>     ..
>     .. heavy memory pressure again.
>     .. In this time, VM cannot discard the page because the page
>     .. has *PG_dirty*
> 
> To solve the problem, this patch clears PG_dirty if only the page is owned
> exclusively by current process when madvise is called because PG_dirty
> represents ptes's dirtiness in several processes so we could clear it only
> if we own it exclusively.
> 
> Acked-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/madvise.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 9ee9df8c768d..fc24104d6b3a 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -303,11 +303,19 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  		if (!page)
>  			continue;
>  
> -		if (PageSwapCache(page)) {
> +		if (PageSwapCache(page) || PageDirty(page)) {
>  			if (!trylock_page(page))
>  				continue;
> +			/*
> +			 * If page is shared with others, we couldn't clear
> +			 * PG_dirty of the page.
> +			 */
> +			if (page_count(page) != 1 + !!PageSwapCache(page)) {
> +				unlock_page(page);
> +				continue;
> +			}
>  
> -			if (!try_to_free_swap(page)) {
> +			if (PageSwapCache(page) && !try_to_free_swap(page)) {
>  				unlock_page(page);
>  				continue;
>  			}
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
