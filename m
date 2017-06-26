Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 457D46B0314
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:13:47 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 4so28654313wrc.15
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:13:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w96si11896647wrc.383.2017.06.26.05.13.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 05:13:46 -0700 (PDT)
Subject: Re: [PATCH 6/6] mm, migration: do not trigger OOM killer when
 migrating memory
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-7-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <35aecfe6-4ef0-5d7f-cda0-fbe68cf356dc@suse.cz>
Date: Mon, 26 Jun 2017 14:13:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170623085345.11304-7-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On 06/23/2017 10:53 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Page migration (for memory hotplug, soft_offline_page or mbind) needs
> to allocate a new memory. This can trigger an oom killer if the target
> memory is depleated. Although quite unlikely, still possible, especially
> for the memory hotplug (offlining of memoery). Up to now we didn't
> really have reasonable means to back off. __GFP_NORETRY can fail just
> too easily and __GFP_THISNODE sticks to a single node and that is not
> suitable for all callers.
> 
> But now that we have __GFP_RETRY_MAYFAIL we should use it.  It is
> preferable to fail the migration than disrupt the system by killing some
> processes.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/migrate.h | 2 +-
>  mm/memory-failure.c     | 3 ++-
>  mm/mempolicy.c          | 3 ++-
>  3 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index f80c9882403a..9f5885dae80e 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -34,7 +34,7 @@ extern char *migrate_reason_names[MR_TYPES];
>  static inline struct page *new_page_nodemask(struct page *page, int preferred_nid,
>  		nodemask_t *nodemask)
>  {
> -	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> +	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE | __GFP_RETRY_MAYFAIL;
>  
>  	if (PageHuge(page))
>  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index e2e0cb0e1d0f..fe0c484c6fdb 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1492,7 +1492,8 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
>  
>  		return alloc_huge_page_node(hstate, nid);
>  	} else {
> -		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> +		return __alloc_pages_node(nid,
> +				GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL, 0);
>  	}
>  }
>  
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 7d8e56214ac0..d911fa5cb2a7 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1078,7 +1078,8 @@ static struct page *new_page(struct page *page, unsigned long start, int **x)
>  	/*
>  	 * if !vma, alloc_page_vma() will use task or system default policy
>  	 */
> -	return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> +	return alloc_page_vma(GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL,
> +			vma, address);
>  }
>  #else
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
