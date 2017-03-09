Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B45A22808A2
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 03:50:57 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u108so18859536wrb.3
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 00:50:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e63si3500230wma.43.2017.03.09.00.50.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 00:50:56 -0800 (PST)
Date: Thu, 9 Mar 2017 09:50:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: "mm: fix lazyfree BUG_ON check in try_to_unmap_one()" build error
Message-ID: <20170309085053.GA11592@dhcp22.suse.cz>
References: <20170309042908.GA26702@jagdpanzerIV.localdomain>
 <20170309060226.GB854@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309060226.GB854@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 09-03-17 15:02:26, Minchan Kim wrote:
[...]
> >From 38b10e560d066c2cef8f9d028e14008cefdaa3e0 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Thu, 9 Mar 2017 14:58:23 +0900
> Subject: [PATCH] mm: do not use VM_WARN_ON_ONCE as if condition
> 
> Sergey reported VM_WARN_ON_ONCE returns void with !CONFIG_DEBUG_VM
> so we cannot use it as if's condition unlike WARN_ON.

I would swear I've seen WARN_ON_ONCE there when looking at the previous
patch! Btw. could have simply s@VM_@@ 

> This patch fixes it.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/rmap.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 1d82057144ba..7d24bb93445b 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1413,12 +1413,11 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			 * Store the swap location in the pte.
>  			 * See handle_pte_fault() ...
>  			 */
> -			if (VM_WARN_ON_ONCE(PageSwapBacked(page) !=
> -						PageSwapCache(page))) {
> +			if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
> +				WARN_ON_ONCE(1);
>  				ret = SWAP_FAIL;
>  				page_vma_mapped_walk_done(&pvmw);
>  				break;
> -
>  			}
>  
>  			/* MADV_FREE page check */
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
