Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71A7A6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 11:04:25 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id na2so4955075lbb.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 08:04:25 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id v203si32268913wmg.33.2016.06.08.08.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 08:04:24 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id m124so3690443wme.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 08:04:24 -0700 (PDT)
Date: Wed, 8 Jun 2016 17:04:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
Message-ID: <20160608150422.GO22570@dhcp22.suse.cz>
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Odzioba <lukasz.odzioba@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, vdavydov@parallels.com, mingli199x@qq.com, minchan@kernel.org, dave.hansen@intel.com, lukasz.anaczkowski@intel.com

On Wed 08-06-16 16:35:37, Lukasz Odzioba wrote:
> When the application does not exit cleanly (i.e. SIGTERM) we might

I do not see how a SIGTERM would make any difference. But see below.

> end up with some pages in lru_add_pvec, which is ok. With THP
> enabled huge pages may also end up on per cpu lru_add_pvecs.
> In the systems with a lot of processors we end up with quite a lot
> of memory pending for addition to LRU cache - in the worst case
> scenario up to CPUS * PAGE_SIZE * PAGEVEC_SIZE, which on machine
> with 200+CPUs means GBs in practice.

It is 56kB per CPU for normal pages which is not really that bad.
28MB for THP only cache is a lot though.

> We are able to reproduce this problem with the following program:
> 
> void main() {
> {
> 	size_t size = 55 * 1000 * 1000; // smaller than  MEM/CPUS
> 	void *p = mmap(NULL, size, PROT_READ | PROT_WRITE,
> 		MAP_PRIVATE | MAP_ANONYMOUS , -1, 0);
> 	if (p != MAP_FAILED)
> 		memset(p, 0, size);
> 	//munmap(p, size); // uncomment to make the problem go away

Is this really true? Both munmap and exit_mmap do the same
lru_add_drain() which flushes only the local CPU cache so munmap
shouldn't make any difference.

> }
> 
> When we run it it will leave significant amount of memory on pvecs.
> This memory will be not reclaimed if we hit OOM, so when we run
> above program in a loop:
> 	$ for i in `seq 100`; do ./a.out; done
> many processes (95% in my case) will be killed by OOM.
> 
> This patch flushes lru_add_pvecs on compound page arrival making
> the problem less severe - kill rate drops to 0%.

I believe this deserves a more explanation. What do you think about the
following.
"
The primary point of the LRU add cache is to save the zone lru_lock
contention with a hope that more pages will belong to the same zone
and so their addition can be batched. The huge page is already a
form of batched addition (it will add 512 worth of memory in one go)
so skipping the batching seems like a safer option when compared to a
potential excess in the caching which can be quite large and much
harder to fix because lru_add_drain_all is way to expensive and
it is not really clear what would be a good moment to call it.
"

Does this sound better?

> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Tested-by: Lukasz Odzioba <lukasz.odzioba@intel.com>
> Signed-off-by: Lukasz Odzioba <lukasz.odzioba@intel.com>
> ---
>  mm/swap.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 9591614..3fe4f18 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
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
