Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id B190D6B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 04:58:38 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id n63so333847347ywf.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 01:58:38 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 18si14494791wml.98.2016.06.20.01.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 01:30:17 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 187so12114879wmz.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 01:30:17 -0700 (PDT)
Date: Mon, 20 Jun 2016 10:30:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/1] mm/swap.c: flush lru pvecs on compound page
 arrival
Message-ID: <20160620083015.GD4340@dhcp22.suse.cz>
References: <1466180198-18854-1-git-send-email-lukasz.odzioba@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466180198-18854-1-git-send-email-lukasz.odzioba@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Odzioba <lukasz.odzioba@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, vdavydov@parallels.com, mingli199x@qq.com, minchan@kernel.org, dave.hansen@intel.com, lukasz.anaczkowski@intel.com

On Fri 17-06-16 18:16:38, Lukasz Odzioba wrote:
> Currently we can have compound pages held on per cpu pagevecs, which
> leads to a lot of memory unavailable for reclaim when needed.
> In the systems with hundreads of processors it can be GBs of memory.
> 
> On of the way of reproducing the problem is to not call munmap
> explicitly on all mapped regions (i.e. after receiving SIGTERM).
> After that some pages (with THP enabled also huge pages) may end
> up on lru_add_pvec, example below.
> 
> void main() {
> #pragma omp parallel
> {
> 	size_t size = 55 * 1000 * 1000; // smaller than  MEM/CPUS
> 	void *p = mmap(NULL, size, PROT_READ | PROT_WRITE,
> 		MAP_PRIVATE | MAP_ANONYMOUS , -1, 0);
> 	if (p != MAP_FAILED)
> 		memset(p, 0, size);
> 	//munmap(p, size); // uncomment to make the problem go away

I still think this part is confusing. munmap doesn't clear the pagevecs
on remote cpus. So it might happen to make a difference for other
reasons (timing, task might get moved to different cpus etc...).

> }
> }
> 
> When we run it with THP enabled it will leave significant amount of
> memory on lru_add_pvec. This memory will be not reclaimed if we hit
> OOM, so when we run above program in a loop:
> 	for i in `seq 100`; do ./a.out; done
> many processes (95% in my case) will be killed by OOM.
> 
> The primary point of the LRU add cache is to save the zone lru_lock
> contention with a hope that more pages will belong to the same zone
> and so their addition can be batched. The huge page is already a
> form of batched addition (it will add 512 worth of memory in one go)
> so skipping the batching seems like a safer option when compared to a
> potential excess in the caching which can be quite large and much
> harder to fix because lru_add_drain_all is way to expensive and
> it is not really clear what would be a good moment to call it.
> 
> Similarly we can reproduce the problem on lru_deactivate_pvec by
> adding: madvise(p, size, MADV_FREE); after memset.
> 
> This patch flushes lru pvecs on compound page arrival making the
> problem less severe - after applying it kill rate of above example
> drops to 0%, due to reducing maximum amount of memory held on pvec
> from 28MB (with THP) to 56kB per CPU.
> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Lukasz Odzioba <lukasz.odzioba@intel.com>

Acked-by: Michal Hocko <mhocko@suse.com>

I think this is worth backporing to stable trees. The problem has been
there for years (since THP inclusion I suspect).

Thanks!

> ---
> v2: Flush all pvecs instead of just lru_add_pvec
> ---
>  mm/swap.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 59f5faf..90530ff 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -242,7 +242,7 @@ void rotate_reclaimable_page(struct page *page)
>  		get_page(page);
>  		local_irq_save(flags);
>  		pvec = this_cpu_ptr(&lru_rotate_pvecs);
> -		if (!pagevec_add(pvec, page))
> +		if (!pagevec_add(pvec, page) || PageCompound(page))
>  			pagevec_move_tail(pvec);
>  		local_irq_restore(flags);
>  	}
> @@ -296,7 +296,7 @@ void activate_page(struct page *page)
>  		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
>  
>  		get_page(page);
> -		if (!pagevec_add(pvec, page))
> +		if (!pagevec_add(pvec, page) || PageCompound(page))
>  			pagevec_lru_move_fn(pvec, __activate_page, NULL);
>  		put_cpu_var(activate_page_pvecs);
>  	}
> @@ -391,9 +391,8 @@ static void __lru_cache_add(struct page *page)
>  	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
>  
>  	get_page(page);
> -	if (!pagevec_space(pvec))
> +	if (!pagevec_add(pvec, page) || PageCompound(page))
>  		__pagevec_lru_add(pvec);
> -	pagevec_add(pvec, page);
>  	put_cpu_var(lru_add_pvec);
>  }
>  
> @@ -628,7 +627,7 @@ void deactivate_file_page(struct page *page)
>  	if (likely(get_page_unless_zero(page))) {
>  		struct pagevec *pvec = &get_cpu_var(lru_deactivate_file_pvecs);
>  
> -		if (!pagevec_add(pvec, page))
> +		if (!pagevec_add(pvec, page) || PageCompound(page))
>  			pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
>  		put_cpu_var(lru_deactivate_file_pvecs);
>  	}
> @@ -648,7 +647,7 @@ void deactivate_page(struct page *page)
>  		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
>  
>  		get_page(page);
> -		if (!pagevec_add(pvec, page))
> +		if (!pagevec_add(pvec, page) || PageCompound(page))
>  			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
>  		put_cpu_var(lru_deactivate_pvecs);
>  	}
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
