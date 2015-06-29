Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8CD6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:19:46 -0400 (EDT)
Received: by wgck11 with SMTP id k11so139957226wgc.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 05:19:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si64734663wja.1.2015.06.29.05.19.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 05:19:44 -0700 (PDT)
Date: Mon, 29 Jun 2015 14:19:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Make zone_reclaim() return ZONE_RECLAIM_NOSCAN not
 zero
Message-ID: <20150629121940.GB4617@dhcp22.suse.cz>
References: <1435286348-26366-1-git-send-email-sh.yoon@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435286348-26366-1-git-send-email-sh.yoon@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sh.yoon@lge.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, seungho1.park@lge.com

On Fri 26-06-15 11:39:08, sh.yoon@lge.com wrote:
> From: "sh.yoon" <sh.yoon@lge.com>
> 
> When zone watermark is not ok in get_page_from_freelist(), we call
> zone_reclaim(). But !CONFIG_NUMA system`s zone_reclaim() just returns zero.
> Zero means ZONE_RECLAIM_SOME and check zone watermark again needlessly.

The return value might be indeed confusing, but

> To avoid needless zone watermark check, change it as ZONE_RECLAIM_NOSCAN.

this shouldn't happen because zone_reclaim_mode is always 0 for
!CONFIG_NUMA so we do not even get to call zone_reclaim. So this part of
the changelog is misleading.

> Signed-off-by: sh.yoon <sh.yoon@lge.com>
> ---
>  include/linux/swap.h | 7 ++++++-
>  mm/internal.h        | 5 -----
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 3887472..e04e435 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -332,6 +332,11 @@ extern int vm_swappiness;
>  extern int remove_mapping(struct address_space *mapping, struct page *page);
>  extern unsigned long vm_total_pages;
>  
> +#define ZONE_RECLAIM_NOSCAN	-2
> +#define ZONE_RECLAIM_FULL	-1
> +#define ZONE_RECLAIM_SOME	0
> +#define ZONE_RECLAIM_SUCCESS	1
> +
>  #ifdef CONFIG_NUMA
>  extern int zone_reclaim_mode;
>  extern int sysctl_min_unmapped_ratio;
> @@ -341,7 +346,7 @@ extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
>  #define zone_reclaim_mode 0
>  static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
>  {
> -	return 0;
> +	return ZONE_RECLAIM_NOSCAN;
>  }
>  #endif
>  
> diff --git a/mm/internal.h b/mm/internal.h
> index a25e359..d8ec7f8 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -397,11 +397,6 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
>  }
>  #endif /* CONFIG_SPARSEMEM */
>  
> -#define ZONE_RECLAIM_NOSCAN	-2
> -#define ZONE_RECLAIM_FULL	-1
> -#define ZONE_RECLAIM_SOME	0
> -#define ZONE_RECLAIM_SUCCESS	1
> -
>  extern int hwpoison_filter(struct page *p);
>  
>  extern u32 hwpoison_filter_dev_major;
> -- 
> 2.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
