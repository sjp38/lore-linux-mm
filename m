Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 37B596B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 16:02:39 -0500 (EST)
Received: by wevm14 with SMTP id m14so22697883wev.8
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:02:38 -0800 (PST)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id my7si5598136wic.51.2015.02.27.13.02.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 13:02:37 -0800 (PST)
Received: by wghn12 with SMTP id n12so22817804wgh.1
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:02:35 -0800 (PST)
Date: Fri, 27 Feb 2015 22:02:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <20150227210233.GA29002@dhcp22.suse.cz>
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
Cc: 'Minchan Kim' <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

On Fri 27-02-15 11:37:18, Wang, Yalin wrote:
> This patch add ClearPageDirty() to clear AnonPage dirty flag,
> the Anonpage mapcount must be 1, so that this page is only used by
> the current process, not shared by other process like fork().
> if not clear page dirty for this anon page, the page will never be
> treated as freeable.

Very well spotted! I haven't noticed that during the review.

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

PageAnon check seems to be redundant because we are not allowing
MADV_FREE on any !anon private mappings AFAIR.

>  
>  		if (PageSwapCache(page)) {
> -			if (!trylock_page(page))
> +			if (!try_to_free_swap(page))
>  				continue;

You need to unlock the page here.

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

Please add a comment about why we need to ClearPageDirty even
!PageSwapCache. Anon pages are usually not marked dirty AFAIR. The
reason seem to be racing try_to_free_swap which sets the page that way
(although I do not seem to remember why are we doing that in the first
place...)

> +		unlock_page(page);
>  		/*
>  		 * Some of architecture(ex, PPC) don't update TLB
>  		 * with set_pte_at and tlb_remove_tlb_entry so for
> -- 
> 2.2.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
