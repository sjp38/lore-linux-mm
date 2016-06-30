Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4626B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 08:35:06 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so59411561lfg.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 05:35:06 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id m124si4505987wmm.119.2016.06.30.05.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 05:35:04 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a66so22455099wme.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 05:35:04 -0700 (PDT)
Date: Thu, 30 Jun 2016 14:35:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: allocate order 0 page from pcb before
 zone_watermark_ok
Message-ID: <20160630123443.GA18789@dhcp22.suse.cz>
References: <CAOVJa8EPGfWwLtAY8YNOzBqG99J7xL0dMrRmvXs0d8GaXJF9Xw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOVJa8EPGfWwLtAY8YNOzBqG99J7xL0dMrRmvXs0d8GaXJF9Xw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vichy <vichy.kuo@gmail.com>
Cc: linux-mm@kvack.org

On Wed 29-06-16 22:44:19, vichy wrote:
> hi all:
> In normal case, the allocation of any order page started after
> zone_watermark_ok. But if so far pcp->count of this zone is not 0,
> why don't we just let order-0-page allocation before zone_watermark_ok.
> That mean the order-0-page will be successfully allocated even
> free_pages is beneath zone->watermark.

The watermark check has a good reason. It protects the memory reserves
which are used for important users or emergency situations. The mere
fact that there are pages available for the pcp usage doesn't mean that
we should break this protection. Note that those emergency users might
want order 0 pages as well.

So NAK to the patch.

> For above idea, I made below patch for your reference.
> 
> Signed-off-by: pierre kuo <vichy.kuo@gmail.com>
> ---
>  mm/page_alloc.c | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c1069ef..406655f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2622,6 +2622,14 @@ static void reset_alloc_batches(struct zone
> *preferred_zone)
>         } while (zone++ != preferred_zone);
>  }
> 
> +static struct page *
> +__get_hot_cold_page(bool cold, struct list_head *list)
> +{
> +       if (cold)
> +               return list_last_entry(list, struct page, lru);
> +       else
> +               return list_first_entry(list, struct page, lru);
> +}
>  /*
>   * get_page_from_freelist goes through the zonelist trying to allocate
>   * a page.
> @@ -2695,6 +2703,24 @@ zonelist_scan:
>                 if (ac->spread_dirty_pages && !zone_dirty_ok(zone))
>                         continue;
> 
> +               if (likely(order == 0)) {
> +                       struct per_cpu_pages *pcp;
> +                       struct list_head *list;
> +                       unsigned long flags;
> +                       bool cold = ((gfp_mask & __GFP_COLD) != 0);
> +
> +                       local_irq_save(flags);
> +                       pcp = &this_cpu_ptr(zone->pageset)->pcp;
> +                       list = &pcp->lists[ac->migratetype];
> +                       if (!list_empty(list)) {
> +                               page = __get_hot_cold_page(cold, list);
> +                               list_del(&page->lru);
> +                               pcp->count--;
> +                       }
> +                       local_irq_restore(flags);
> +                       if (page)
> +                               goto get_page_order0;
> +               }
>                 mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>                 if (!zone_watermark_ok(zone, order, mark,
>                                        ac->classzone_idx, alloc_flags)) {
> @@ -2730,6 +2756,7 @@ zonelist_scan:
>  try_this_zone:
>                 page = buffered_rmqueue(ac->preferred_zone, zone, order,
>                                 gfp_mask, alloc_flags, ac->migratetype);
> +get_page_order0:
>                 if (page) {
>                         if (prep_new_page(page, order, gfp_mask, alloc_flags))
>                                 goto try_this_zone;
> --
> 1.9.1
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
