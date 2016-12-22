Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5686B03FC
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 04:15:24 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id qs7so10177635wjc.4
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 01:15:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5si6481276wje.171.2016.12.22.01.15.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 01:15:22 -0800 (PST)
Date: Thu, 22 Dec 2016 10:15:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm/memblock.c: check return value of
 memblock_reserve() in memblock_virt_alloc_internal()
Message-ID: <20161222091519.GC6048@dhcp22.suse.cz>
References: <1482363033-24754-1-git-send-email-richard.weiyang@gmail.com>
 <1482363033-24754-3-git-send-email-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482363033-24754-3-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-12-16 23:30:33, Wei Yang wrote:
> memblock_reserve() would add a new range to memblock.reserved in case the
> new range is not totally covered by any of the current memblock.reserved
> range. If the memblock.reserved is full and can't resize,
> memblock_reserve() would fail.
> 
> This doesn't happen in real world now, I observed this during code review.
> While theoretically, it has the chance to happen. And if it happens, others
> would think this range of memory is still available and may corrupt the
> memory.

OK, this explains it much better than the previous version! The silent
memory corruption is indeed too hard to debug to have this open even
when the issue is theoretical.

> This patch checks the return value and goto "done" after it succeeds.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memblock.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 4929e06..d0f2c96 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1274,18 +1274,17 @@ static void * __init memblock_virt_alloc_internal(
>  
>  	if (max_addr > memblock.current_limit)
>  		max_addr = memblock.current_limit;
> -
>  again:
>  	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
>  					    nid, flags);
> -	if (alloc)
> +	if (alloc && !memblock_reserve(alloc, size))
>  		goto done;
>  
>  	if (nid != NUMA_NO_NODE) {
>  		alloc = memblock_find_in_range_node(size, align, min_addr,
>  						    max_addr, NUMA_NO_NODE,
>  						    flags);
> -		if (alloc)
> +		if (alloc && !memblock_reserve(alloc, size))
>  			goto done;
>  	}
>  
> @@ -1303,7 +1302,6 @@ static void * __init memblock_virt_alloc_internal(
>  
>  	return NULL;
>  done:
> -	memblock_reserve(alloc, size);
>  	ptr = phys_to_virt(alloc);
>  	memset(ptr, 0, size);
>  
> -- 
> 2.5.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
