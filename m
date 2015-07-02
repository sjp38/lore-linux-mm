Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 818339003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 05:52:40 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so191177340wiw.0
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 02:52:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gb5si7943627wjb.21.2015.07.02.02.52.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jul 2015 02:52:38 -0700 (PDT)
Message-ID: <559509E4.3010708@suse.cz>
Date: Thu, 02 Jul 2015 11:52:36 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] fix: decrease NR_FREE_PAGES when isolate page from buddy
References: <1435713478-19646-1-git-send-email-minkyung88.kim@lge.com>
In-Reply-To: <1435713478-19646-1-git-send-email-minkyung88.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minkyung88.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Seungho Park <seungho1.park@lge.com>, kmk3210@gmail.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>

[+CC Joonsoo and Minchan]

On 07/01/2015 03:17 AM, minkyung88.kim@lge.com wrote:
> From: "minkyung88.kim" <minkyung88.kim@lge.com>
>
> NR_FREEPAGE should be decreased when pages are isolated from buddy.
> Therefore fix the count.

Did you really observe an accounting bug and this patch fixed it, or is 
it just because of code inspection?

The patched code has this comment:

/*
  * If race between isolatation and allocation happens,
  * some free pages could be in MIGRATE_MOVABLE list
  * although pageblock's migratation type of the page
  * is MIGRATE_ISOLATE. Catch it and move the page into
  * MIGRATE_ISOLATE list.
  */

This is from 2012 and I'm not sure if it still applies. Joonsoo's series 
last year was to eliminate these races, see e.g. 51bb1a4093 
("mm/page_alloc: add freepage on isolate pageblock to correct buddy list").

So I think that this piece of code shouldn't be useful anymore. Well, 
actually I think it can trigger, but it's a false positive and (before 
your patch) result in basically a no-op. The reason is that the value of 
get_freepage_migratetype(page) is a just an optimization used only for 
pages on pcplists. It's not guaranteed to be correct for pages in the 
buddy free lists (and it can get stale even on the pcplists).

Now, the code from Joonsoo's patch mentioned above does this in
free_pcppages_bulk():

mt = get_freepage_migratetype(page);
if (unlikely(has_isolate_pageblock(zone)))
         mt = get_pageblock_migratetype(page);

/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
__free_one_page(page, page_to_pfn(page), zone, 0, mt);

So if get_freepage_migratetype(page) returns e.g. MIGRATE_MOVABLE but 
the pageblock is MIGRATE_ISOLATE, it will catch this and tell 
__free_one_page() the correct migratetype. However, nothing will update 
the freepage's migratetype by set_freepage_migratetype(), because it 
would be a pointless waste of CPU cycles. The page however goes to the 
correct MIGRATE_ISOLATE list. (note that this is likely not the only way 
how freepage_migratetype can be perceived as incorrect)

That means the code you are patching can really find the page where 
get_freepage_migratetype(page) will return MIGRATE_MOVABLE, i.e. != 
MIGRATE_ISOLATE will be true. But the move_freepages() call would be a 
no-op, as the page is already on the correct list and the accounting of 
freepages is correct.

So my conclusion is that after your patch, the freepage accounting could 
actually get broken, not fixed. But I may be wrong. Hopefully Joonsoo 
can verify this :)

If that's true, then the whole test you are patching should be dropped. 
Also we should make it clearer that get_freepage_migratetype() is only 
used for pages on pcplists (and even there it may differ from 
pageblock's migratetype and also from the pcplist the page is actually 
on, in cases of page stealing), as this is not the first confusion.
We should also drop the usage set_freepage_migratetype() from 
move_freepages() while at it.
Now the last usage of get_freepage_migratetype() outside of page_alloc.c 
is the page isolation code and I argue it's wrong. So after that is 
removed, we can actually also make the functions internal to page_alloc.c.

> Signed-off-by: minkyung88.kim <minkyung88.kim@lge.com>
> ---
>   mm/page_isolation.c | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 303c908..16cc172 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -233,10 +233,14 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>   			 */
>   			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
>   				struct page *end_page;
> +				struct zone *zone = page_zone(page);
> +				int mt = get_freepage_migratetype(page);
> +				unsigned long nr_pages;
>
>   				end_page = page + (1 << page_order(page)) - 1;
> -				move_freepages(page_zone(page), page, end_page,
> +				nr_pages = move_freepages(zone, page, end_page,
>   						MIGRATE_ISOLATE);
> +				__mod_zone_freepage_state(zone, -nr_pages, mt);
>   			}
>   			pfn += 1 << page_order(page);
>   		}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
