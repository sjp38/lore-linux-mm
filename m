Subject: Re: [RFC/PATCH] free_area[] bitmap elimination [3/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412B3785.30300@jp.fujitsu.com>
References: <412B3785.30300@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093367129.1009.63.camel@nighthawk>
Mime-Version: 1.0
Date: Tue, 24 Aug 2004 10:05:29 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>, Hirokazu Takahashi <taka@valinux.co.jp>, ncunningham@linuxmail.org
List-ID: <linux-mm.kvack.org>

On Tue, 2004-08-24 at 05:41, Hiroyuki KAMEZAWA wrote:
> +static inline int page_is_buddy(struct page *page, int order)
> +{
> +       if (page_count(page) == 0 &&
> +           PagePrivate(page) &&
> +           !PageReserved(page) &&
> +            page_order(page) == order) {
> +               /* check, check... see free_pages_check() */
> +               if (page_mapped(page) ||
> +                   page->mapping != NULL ||
> +                   (page->flags & (
> +                           1 << PG_lru |
> +                           1 << PG_locked      |
> +                           1 << PG_active      |
> +                           1 << PG_reclaim     |
> +                           1 << PG_slab        |
> +                           1 << PG_swapcache |
> +                           1 << PG_writeback )))
> +                       bad_page(__FUNCTION__, page);
> +               return 1;
> +       }
> +       return 0;
> +}

Please share some code with the free_pages_check() that you stole this
from.  It's nasty enough to have one copy of it around. :)

> +#ifdef CONFIG_VIRTUAL_MEM_MAP  
> +                       /* This check is necessary when
> +                          1. there may be holes in zone.
> +                          2. a hole is not aligned in this order.
> +                          currently, VIRTUAL_MEM_MAP case, is only case.
> +                          Is there better call than pfn_valid ?
> +                       */
> +                       if (!pfn_valid(zone->zone_start_pfn + (page_idx ^ (1 << order))))
> +                               break;
> +#endif         

This should be hidden in a header somewhere.  We don't want to have to
see ia64-specific ifdefs in generic code.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
