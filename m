Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 13CD56B005D
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 06:13:19 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so218504wgb.26
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 03:13:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1342508505-23492-4-git-send-email-minchan@kernel.org>
References: <1342508505-23492-1-git-send-email-minchan@kernel.org>
	<1342508505-23492-4-git-send-email-minchan@kernel.org>
Date: Tue, 17 Jul 2012 18:13:17 +0800
Message-ID: <CAA_GA1dh0RYT5wfOB=t8-XoeHOzRJCmQJifnUTGLZfjNwx2a5w@mail.gmail.com>
Subject: Re: [RFC 3/3] memory-hotplug: bug fix race between isolation and allocation
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

Hi Minchan,

On Tue, Jul 17, 2012 at 3:01 PM, Minchan Kim <minchan@kernel.org> wrote:
> Like below, memory-hotplug makes race between page-isolation
> and page-allocation so it can hit BUG_ON in __offline_isolated_pages.
>
>         CPU A                                   CPU B
>
> start_isolate_page_range
> set_migratetype_isolate
> spin_lock_irqsave(zone->lock)
>
>                                 free_hot_cold_page(Page A)
>                                 /* without zone->lock */
>                                 migratetype = get_pageblock_migratetype(Page A);
>                                 /*
>                                  * Page could be moved into MIGRATE_MOVABLE
>                                  * of per_cpu_pages
>                                  */
>                                 list_add_tail(&page->lru, &pcp->lists[migratetype]);
>
> set_pageblock_isolate
> move_freepages_block
> drain_all_pages
>
>                                 /* Page A could be in MIGRATE_MOVABLE of free_list. */
>
> check_pages_isolated
> __test_page_isolated_in_pageblock
> /*
>  * We can't catch freed page which
>  * is free_list[MIGRATE_MOVABLE]
>  */
> if (PageBuddy(page A))
>         pfn += 1 << page_order(page A);
>
>                                 /* So, Page A could be allocated */
>
> __offline_isolated_pages
> /*
>  * BUG_ON hit or offline page
>  * which is used by someone
>  */
> BUG_ON(!PageBuddy(page A));
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> I found this problem during code review so please confirm it.
> Kame?
>
>  mm/page_isolation.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index acf65a7..4699d1f 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -196,8 +196,11 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
>                         continue;
>                 }
>                 page = pfn_to_page(pfn);
> -               if (PageBuddy(page))
> +               if (PageBuddy(page)) {
>                         pfn += 1 << page_order(page);
> +                       if (get_page_migratetype(page) != MIGRATE_ISOLATE)
> +                               break;
> +               }

test_page_isolated() already have check
get_pageblock_migratetype(page) != MIGRATE_ISOLATE.

>                 else if (page_count(page) == 0 &&
>                                 get_page_migratetype(page) == MIGRATE_ISOLATE)
>                         pfn += 1;
> --
> 1.7.9.5
>


-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
