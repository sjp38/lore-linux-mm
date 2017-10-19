Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B910C6B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:29:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g1so3169954wra.9
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:29:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 57si11456135wrt.261.2017.10.19.08.29.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 08:29:19 -0700 (PDT)
Date: Thu, 19 Oct 2017 17:29:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/swap: Rename pagevec_lru_move_fn() as
 pagevec_lruvec_move_fn()
Message-ID: <20171019152918.2wrn6slrq7ashvpj@dhcp22.suse.cz>
References: <20171019083314.12614-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019083314.12614-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 19-10-17 14:03:14, Anshuman Khandual wrote:
> The function pagevec_lru_move_fn() actually moves pages from various
> per cpu pagevecs into per node lruvecs with a custom function which
> knows how to handle individual pages present in any given pagevec.
> Because it does movement between pagevecs and lruvecs as whole not
> to an individual list element, the name should reflect it.

I find the original name quite understandable (and shorter). I do not
think this is worth changing. It is just a code churn without a good
reason.

> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  mm/swap.c | 19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index a77d68f..fcd82bc 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -185,7 +185,7 @@ int get_kernel_page(unsigned long start, int write, struct page **pages)
>  }
>  EXPORT_SYMBOL_GPL(get_kernel_page);
>  
> -static void pagevec_lru_move_fn(struct pagevec *pvec,
> +static void pagevec_lruvec_move_fn(struct pagevec *pvec,
>  	void (*move_fn)(struct page *page, struct lruvec *lruvec, void *arg),
>  	void *arg)
>  {
> @@ -235,7 +235,7 @@ static void pagevec_move_tail(struct pagevec *pvec)
>  {
>  	int pgmoved = 0;
>  
> -	pagevec_lru_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
> +	pagevec_lruvec_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
>  	__count_vm_events(PGROTATED, pgmoved);
>  }
>  
> @@ -294,7 +294,7 @@ static void activate_page_drain(int cpu)
>  	struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
>  
>  	if (pagevec_count(pvec))
> -		pagevec_lru_move_fn(pvec, __activate_page, NULL);
> +		pagevec_lruvec_move_fn(pvec, __activate_page, NULL);
>  }
>  
>  static bool need_activate_page_drain(int cpu)
> @@ -310,7 +310,7 @@ void activate_page(struct page *page)
>  
>  		get_page(page);
>  		if (!pagevec_add(pvec, page) || PageCompound(page))
> -			pagevec_lru_move_fn(pvec, __activate_page, NULL);
> +			pagevec_lruvec_move_fn(pvec, __activate_page, NULL);
>  		put_cpu_var(activate_page_pvecs);
>  	}
>  }
> @@ -620,11 +620,11 @@ void lru_add_drain_cpu(int cpu)
>  
>  	pvec = &per_cpu(lru_deactivate_file_pvecs, cpu);
>  	if (pagevec_count(pvec))
> -		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
> +		pagevec_lruvec_move_fn(pvec, lru_deactivate_file_fn, NULL);
>  
>  	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
>  	if (pagevec_count(pvec))
> -		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
> +		pagevec_lruvec_move_fn(pvec, lru_lazyfree_fn, NULL);
>  
>  	activate_page_drain(cpu);
>  }
> @@ -650,7 +650,8 @@ void deactivate_file_page(struct page *page)
>  		struct pagevec *pvec = &get_cpu_var(lru_deactivate_file_pvecs);
>  
>  		if (!pagevec_add(pvec, page) || PageCompound(page))
> -			pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
> +			pagevec_lruvec_move_fn(pvec,
> +					lru_deactivate_file_fn, NULL);
>  		put_cpu_var(lru_deactivate_file_pvecs);
>  	}
>  }
> @@ -670,7 +671,7 @@ void mark_page_lazyfree(struct page *page)
>  
>  		get_page(page);
>  		if (!pagevec_add(pvec, page) || PageCompound(page))
> -			pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
> +			pagevec_lruvec_move_fn(pvec, lru_lazyfree_fn, NULL);
>  		put_cpu_var(lru_lazyfree_pvecs);
>  	}
>  }
> @@ -901,7 +902,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
>   */
>  void __pagevec_lru_add(struct pagevec *pvec)
>  {
> -	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, NULL);
> +	pagevec_lruvec_move_fn(pvec, __pagevec_lru_add_fn, NULL);
>  }
>  EXPORT_SYMBOL(__pagevec_lru_add);
>  
> -- 
> 1.8.5.2
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
