Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9376B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 06:14:45 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id js8so8580640lbc.2
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 03:14:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h197si3666125wma.103.2016.06.18.03.14.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 18 Jun 2016 03:14:43 -0700 (PDT)
Subject: Re: [RFC PATCH 1/3] mm, page_alloc: free HIGHATOMIC page directly to
 the allocator
References: <1466242457-2440-1-git-send-email-wwtao0320@163.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57651F0F.2010506@suse.cz>
Date: Sat, 18 Jun 2016 12:14:39 +0200
MIME-Version: 1.0
In-Reply-To: <1466242457-2440-1-git-send-email-wwtao0320@163.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wenwei Tao <wwtao0320@163.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ww.tao0320@gmail.com

On 06/18/2016 11:34 AM, Wenwei Tao wrote:
> From: Wenwei Tao <ww.tao0320@gmail.com>
> 
> Some pages might have already been allocated before reserve
> the pageblock as HIGHATOMIC. When free these pages, put them
> directly to the allocator instead of the pcp lists since they
> might have the chance to be merged to high order pages.

Are there some data showing the improvement, or just theoretical?

> Signed-off-by: Wenwei Tao <ww.tao0320@gmail.com>
> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6903b69..19f9e76 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2412,7 +2412,8 @@ void free_hot_cold_page(struct page *page, bool cold)

The full comment that's here for context:

/*
 * We only track unmovable, reclaimable and movable on pcp lists.
 * Free ISOLATE pages back to the allocator because they are being
 * offlined but treat RESERVE as movable pages so we can get those
 * areas back if necessary. Otherwise, we may have to free
 * excessively into the page allocator
 */

That comment looks outdated as it refers to RESERVE, which was replaced
by HIGHATOMIC. But there's some reasoning why these pages go to
pcplists. I'd expect the "free excessively" part isn't as bad as
highatomic reserves are quite limited. They also shouldn't be used for
order-0 allocations, which is what this function is about, so I would
expect both the impact on "free excessively" and the improvement of
merging to be minimal?

>  	 * excessively into the page allocator
>  	 */
>  	if (migratetype >= MIGRATE_PCPTYPES) {
> -		if (unlikely(is_migrate_isolate(migratetype))) {
> +		if (unlikely(is_migrate_isolate(migratetype) ||
> +				migratetype == MIGRATE_HIGHATOMIC)) {
>  			free_one_page(zone, page, pfn, 0, migratetype);
>  			goto out;
>  		}

In any case your patch highlighted that this code could be imho
optimized like below.

if (unlikely(migratetype >= MIGRATE_PCPTYPES))
   if (is_migrate_cma(migratetype)) {
       migratetype = MIGRATE_MOVABLE;
   } else {
       free_one_page(zone, page, pfn, 0, migratetype);
       goto out;
   }
}

That's less branches than your patch, and even less than originally if
CMA is not enabled (or with ZONE_CMA).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
