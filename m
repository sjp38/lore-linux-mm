Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D95F26B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 07:56:15 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so3063613plt.7
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 04:56:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d25si10530056pgd.88.2018.11.13.04.56.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 04:56:14 -0800 (PST)
Date: Tue, 13 Nov 2018 13:56:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] vmscan: return NODE_RECLAIM_NOSCAN in node_reclaim()
 when CONFIG_NUMA is n
Message-ID: <20181113125611.GA16182@dhcp22.suse.cz>
References: <20181113041750.20784-1-richard.weiyang@gmail.com>
 <20181113080436.22078-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113080436.22078-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, willy@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 13-11-18 16:04:36, Wei Yang wrote:
> Commit fa5e084e43eb ("vmscan: do not unconditionally treat zones that
> fail zone_reclaim() as full") changed the return value of node_reclaim().
> The original return value 0 means NODE_RECLAIM_SOME after this commit.
> 
> While the return value of node_reclaim() when CONFIG_NUMA is n is not
> changed. This will leads to call zone_watermark_ok() again.
> 
> This patch fix the return value by adjusting to NODE_RECLAIM_NOSCAN. Since
> node_reclaim() is only called in page_alloc.c, move it to mm/internal.h.

The issue should be cosmetic but the code consistency is definitely an
improvement. Moving this from swap.h makes a lot of sense as well.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> v2:  move node_reclaim() to mm/internal.h
> ---
>  include/linux/swap.h |  6 ------
>  mm/internal.h        | 10 ++++++++++
>  2 files changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index d8a07a4f171d..065988c27373 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -358,14 +358,8 @@ extern unsigned long vm_total_pages;
>  extern int node_reclaim_mode;
>  extern int sysctl_min_unmapped_ratio;
>  extern int sysctl_min_slab_ratio;
> -extern int node_reclaim(struct pglist_data *, gfp_t, unsigned int);
>  #else
>  #define node_reclaim_mode 0
> -static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
> -				unsigned int order)
> -{
> -	return 0;
> -}
>  #endif
>  
>  extern int page_evictable(struct page *page);
> diff --git a/mm/internal.h b/mm/internal.h
> index 291eb2b6d1d8..6a57811ae47d 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -444,6 +444,16 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
>  #define NODE_RECLAIM_SOME	0
>  #define NODE_RECLAIM_SUCCESS	1
>  
> +#ifdef CONFIG_NUMA
> +extern int node_reclaim(struct pglist_data *, gfp_t, unsigned int);
> +#else
> +static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
> +				unsigned int order)
> +{
> +	return NODE_RECLAIM_NOSCAN;
> +}
> +#endif
> +
>  extern int hwpoison_filter(struct page *p);
>  
>  extern u32 hwpoison_filter_dev_major;
> -- 
> 2.15.1

-- 
Michal Hocko
SUSE Labs
