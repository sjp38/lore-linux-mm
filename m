Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 866556B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 09:11:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v88so12701215wrb.1
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:11:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si4095380wma.181.2017.06.23.06.11.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 06:11:30 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc.c: eliminate unsigned confusion in
 __rmqueue_fallback
References: <20170621094344.GC22051@dhcp22.suse.cz>
 <20170621185529.2265-1-linux@rasmusvillemoes.dk>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d03adba2-800a-e367-fe12-87278ea2abe3@suse.cz>
Date: Fri, 23 Jun 2017 15:10:45 +0200
MIME-Version: 1.0
In-Reply-To: <20170621185529.2265-1-linux@rasmusvillemoes.dk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vinayak Menon <vinmenon@codeaurora.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Hao Lee <haolee.swjtu@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/21/2017 08:55 PM, Rasmus Villemoes wrote:
> Since current_order starts as MAX_ORDER-1 and is then only
> decremented, the second half of the loop condition seems
> superfluous. However, if order is 0, we may decrement current_order
> past 0, making it UINT_MAX. This is obviously too subtle ([1], [2]).
> 
> Since we need to add some comment anyway, change the two variables to
> signed, making the counting-down for loop look more familiar, and
> apparently also making gcc generate slightly smaller code.
> 
> [1] https://lkml.org/lkml/2016/6/20/493
> [2] https://lkml.org/lkml/2017/6/19/345
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> Michal, something like this, perhaps?
> 
> mm/page_alloc.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2302f250d6b1..e656f4da9772 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2204,19 +2204,23 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
>   * list of requested migratetype, possibly along with other pages from the same
>   * block, depending on fragmentation avoidance heuristics. Returns true if
>   * fallback was found so that __rmqueue_smallest() can grab it.
> + *
> + * The use of signed ints for order and current_order is a deliberate
> + * deviation from the rest of this file, to make the for loop
> + * condition simpler.
>   */
>  static inline bool
> -__rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
> +__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
>  {
>  	struct free_area *area;
> -	unsigned int current_order;
> +	int current_order;
>  	struct page *page;
>  	int fallback_mt;
>  	bool can_steal;
>  
>  	/* Find the largest possible block of pages in the other list */
>  	for (current_order = MAX_ORDER-1;
> -				current_order >= order && current_order <= MAX_ORDER-1;
> +				current_order >= order;
>  				--current_order) {
>  		area = &(zone->free_area[current_order]);
>  		fallback_mt = find_suitable_fallback(area, current_order,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
