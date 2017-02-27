Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9CB06B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:35:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t18so38932607wmt.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:35:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 10si21601426wry.3.2017.02.27.06.35.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 06:35:37 -0800 (PST)
Date: Mon, 27 Feb 2017 15:35:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 2/6] mm: don't assume anonymous pages have SwapBacked
 flag
Message-ID: <20170227143534.GE26504@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <3945232c0df3dd6c4ef001976f35a95f18dcb407.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3945232c0df3dd6c4ef001976f35a95f18dcb407.1487965799.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri 24-02-17 13:31:45, Shaohua Li wrote:
> There are a few places the code assumes anonymous pages should have
> SwapBacked flag set. MADV_FREE pages are anonymous pages but we are
> going to add them to LRU_INACTIVE_FILE list and clear SwapBacked flag
> for them. The assumption doesn't hold any more, so fix them.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Looks good to me.
[...]
> index 96eb85c..c621088 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1416,7 +1416,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			 * Store the swap location in the pte.
>  			 * See handle_pte_fault() ...
>  			 */
> -			VM_BUG_ON_PAGE(!PageSwapCache(page), page);
> +			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
> +				page);

just this part makes me scratch my head. I really do not understand what
kind of problem it tries to prevent from, maybe I am missing something
obvoious...

>  
>  			if (!PageDirty(page)) {
>  				/* It's a freeable page by MADV_FREE */
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
