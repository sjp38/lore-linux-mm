Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C30E56B0031
	for <linux-mm@kvack.org>; Sun, 29 Jun 2014 23:58:24 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so7572654pdj.0
        for <linux-mm@kvack.org>; Sun, 29 Jun 2014 20:58:24 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id fu6si21621526pac.106.2014.06.29.20.58.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 29 Jun 2014 20:58:24 -0700 (PDT)
Date: Sun, 29 Jun 2014 20:58:17 -0700
From: John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 2/6] mm: differentiate unmap for vmscan from other
 unmap.
In-Reply-To: <1403920822-14488-3-git-send-email-j.glisse@gmail.com>
Message-ID: <alpine.DEB.2.10.1406292054080.21595@blueforge.nvidia.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com> <1403920822-14488-3-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="279739828-1357833611-1404100702=:21595"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <j.glisse@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, torvalds@linux-foundation.org, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

--279739828-1357833611-1404100702=:21595
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT

On Fri, 27 Jun 2014, JA(C)rA'me Glisse wrote:

> From: JA(C)rA'me Glisse <jglisse@redhat.com>
> 
> New code will need to be able to differentiate between a regular unmap and
> an unmap trigger by vmscan in which case we want to be as quick as possible.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> ---
>  include/linux/rmap.h | 15 ++++++++-------
>  mm/memory-failure.c  |  2 +-
>  mm/vmscan.c          |  4 ++--
>  3 files changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index be57450..eddbc07 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -72,13 +72,14 @@ struct anon_vma_chain {
>  };
>  
>  enum ttu_flags {
> -	TTU_UNMAP = 1,			/* unmap mode */
> -	TTU_MIGRATION = 2,		/* migration mode */
> -	TTU_MUNLOCK = 4,		/* munlock mode */
> -
> -	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
> -	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
> -	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
> +	TTU_VMSCAN = 1,			/* unmap for vmscan */
> +	TTU_POISON = 2,			/* unmap for poison */
> +	TTU_MIGRATION = 4,		/* migration mode */
> +	TTU_MUNLOCK = 8,		/* munlock mode */
> +
> +	TTU_IGNORE_MLOCK = (1 << 9),	/* ignore mlock */
> +	TTU_IGNORE_ACCESS = (1 << 10),	/* don't age */
> +	TTU_IGNORE_HWPOISON = (1 << 11),/* corrupted page is recoverable */

Unless there is a deeper purpose that I am overlooking, I think it would 
be better to leave the _MLOCK, _ACCESS, and _HWPOISON at their original 
values. I just can't quite see why they would need to start at bit 9 
instead of bit 8...

>  };
>  
>  #ifdef CONFIG_MMU
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index a7a89eb..ba176c4 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -887,7 +887,7 @@ static int page_action(struct page_state *ps, struct page *p,
>  static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  				  int trapno, int flags, struct page **hpagep)
>  {
> -	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
> +	enum ttu_flags ttu = TTU_POISON | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
>  	struct address_space *mapping;
>  	LIST_HEAD(tokill);
>  	int ret;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6d24fd6..5a7d286 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1163,7 +1163,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  	}
>  
>  	ret = shrink_page_list(&clean_pages, zone, &sc,
> -			TTU_UNMAP|TTU_IGNORE_ACCESS,
> +			TTU_VMSCAN|TTU_IGNORE_ACCESS,
>  			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
>  	list_splice(&clean_pages, page_list);
>  	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
> @@ -1518,7 +1518,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	if (nr_taken == 0)
>  		return 0;
>  
> -	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
> +	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_VMSCAN,
>  				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
>  				&nr_writeback, &nr_immediate,
>  				false);
> -- 
> 1.9.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

Other than that, looks good.

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
John H.
--279739828-1357833611-1404100702=:21595--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
