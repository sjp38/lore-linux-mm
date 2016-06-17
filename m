Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id A148D6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:34:17 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so22310371lbw.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:34:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf1si966887wjb.118.2016.06.17.06.34.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 06:34:16 -0700 (PDT)
Subject: Re: [PATCH v3 9/9] mm/page_isolation: clean up confused code
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1466150259-27727-10-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b7e14660-f3e6-ee59-f81b-5f3221cf6771@suse.cz>
Date: Fri, 17 Jun 2016 15:34:12 +0200
MIME-Version: 1.0
In-Reply-To: <1466150259-27727-10-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 06/17/2016 09:57 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> When there is an isolated_page, post_alloc_hook() is called with
> page but __free_pages() is called with isolated_page. Since they are
> the same so no problem but it's very confusing. To reduce it,
> this patch changes isolated_page to boolean type and uses page variable
> consistently.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Could be also just folded to mm/page_owner: initialize page owner without 
holding the zone lock

> ---
>  mm/page_isolation.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 4639163..064b7fb 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -81,7 +81,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  {
>  	struct zone *zone;
>  	unsigned long flags, nr_pages;
> -	struct page *isolated_page = NULL;
> +	bool isolated_page = false;
>  	unsigned int order;
>  	unsigned long page_idx, buddy_idx;
>  	struct page *buddy;
> @@ -109,7 +109,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  			if (pfn_valid_within(page_to_pfn(buddy)) &&
>  			    !is_migrate_isolate_page(buddy)) {
>  				__isolate_free_page(page, order);
> -				isolated_page = page;
> +				isolated_page = true;
>  			}
>  		}
>  	}
> @@ -129,7 +129,7 @@ out:
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  	if (isolated_page) {
>  		post_alloc_hook(page, order, __GFP_MOVABLE);
> -		__free_pages(isolated_page, order);
> +		__free_pages(page, order);
>  	}
>  }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
