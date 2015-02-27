Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C293C6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 00:28:16 -0500 (EST)
Received: by pablj1 with SMTP id lj1so3881641pab.13
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 21:28:16 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ir6si3977964pbc.106.2015.02.26.21.28.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 21:28:15 -0800 (PST)
Received: by pablj1 with SMTP id lj1so17500213pab.9
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 21:28:15 -0800 (PST)
Date: Fri, 27 Feb 2015 14:28:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <20150227052805.GA20805@blaptop>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz>
 <20150225000809.GA6468@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

Hello,

On Fri, Feb 27, 2015 at 11:37:18AM +0800, Wang, Yalin wrote:
> This patch add ClearPageDirty() to clear AnonPage dirty flag,
> the Anonpage mapcount must be 1, so that this page is only used by
> the current process, not shared by other process like fork().
> if not clear page dirty for this anon page, the page will never be
> treated as freeable.

In case of anonymous page, it has PG_dirty when VM adds it to
swap cache and clear it in clear_page_dirty_for_io. That's why
I added ClearPageDirty if we found it in swapcache.
What case am I missing? It would be better to understand if you
describe specific scenario.

Thanks.

> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  mm/madvise.c | 15 +++++----------
>  1 file changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 6d0fcb8..257925a 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -297,22 +297,17 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  			continue;
>  
>  		page = vm_normal_page(vma, addr, ptent);
> -		if (!page)
> +		if (!page || !PageAnon(page) || !trylock_page(page))
>  			continue;
>  
>  		if (PageSwapCache(page)) {
> -			if (!trylock_page(page))
> +			if (!try_to_free_swap(page))
>  				continue;
> -
> -			if (!try_to_free_swap(page)) {
> -				unlock_page(page);
> -				continue;
> -			}
> -
> -			ClearPageDirty(page);
> -			unlock_page(page);
>  		}
>  
> +		if (page_mapcount(page) == 1)
> +			ClearPageDirty(page);
> +		unlock_page(page);
>  		/*
>  		 * Some of architecture(ex, PPC) don't update TLB
>  		 * with set_pte_at and tlb_remove_tlb_entry so for
> -- 
> 2.2.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
