Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B8CB06B02B7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 18:43:45 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so127326984pac.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:43:45 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id tv5si12237798pac.203.2015.07.21.15.43.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 15:43:44 -0700 (PDT)
Received: by padck2 with SMTP id ck2so126704752pad.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:43:44 -0700 (PDT)
Date: Tue, 21 Jul 2015 15:43:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, page_isolation: remove bogus tests for isolated
 pages
In-Reply-To: <1437483218-18703-1-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1507211540080.3833@chino.kir.corp.google.com>
References: <55969822.9060907@suse.cz> <1437483218-18703-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue, 21 Jul 2015, Vlastimil Babka wrote:

> The __test_page_isolated_in_pageblock() is used to verify whether all pages
> in pageblock were either successfully isolated, or are hwpoisoned. Two of the
> possible state of pages, that are tested, are however bogus and misleading.
> 
> Both tests rely on get_freepage_migratetype(page), which however has no
> guarantees about pages on freelists. Specifically, it doesn't guarantee that
> the migratetype returned by the function actually matches the migratetype of
> the freelist that the page is on. Such guarantee is not its purpose and would
> have negative impact on allocator performance.
> 
> The first test checks whether the freepage_migratetype equals MIGRATE_ISOLATE,
> supposedly to catch races between page isolation and allocator activity. These
> races should be fixed nowadays with 51bb1a4093 ("mm/page_alloc: add freepage
> on isolate pageblock to correct buddy list") and related patches. As explained
> above, the check wouldn't be able to catch them reliably anyway. For the same
> reason false positives can happen, although they are harmless, as the
> move_freepages() call would just move the page to the same freelist it's
> already on. So removing the test is not a bug fix, just cleanup. After this
> patch, we assume that all PageBuddy pages are on the correct freelist and that
> the races were really fixed. A truly reliable verification in the form of e.g.
> VM_BUG_ON() would be complicated and is arguably not needed.
> 
> The second test (page_count(page) == 0 && get_freepage_migratetype(page)
> == MIGRATE_ISOLATE) is probably supposed (the code comes from a big memory
> isolation patch from 2007) to catch pages on MIGRATE_ISOLATE pcplists.
> However, pcplists don't contain MIGRATE_ISOLATE freepages nowadays, those are
> freed directly to free lists, so the check is obsolete. Remove it as well.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Laura Abbott <lauraa@codeaurora.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/page_isolation.c | 30 ++++++------------------------
>  1 file changed, 6 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 0e69d25..9eaa489c 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -226,34 +226,16 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>  			continue;
>  		}
>  		page = pfn_to_page(pfn);
> -		if (PageBuddy(page)) {
> +		if (PageBuddy(page))
>  			/*
> -			 * If race between isolatation and allocation happens,
> -			 * some free pages could be in MIGRATE_MOVABLE list
> -			 * although pageblock's migratation type of the page
> -			 * is MIGRATE_ISOLATE. Catch it and move the page into
> -			 * MIGRATE_ISOLATE list.
> +			 * If the page is on a free list, it has to be on
> +			 * the correct MIGRATE_ISOLATE freelist. There is no
> +			 * simple way to verify that as VM_BUG_ON(), though.
>  			 */
> -			if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
> -				struct page *end_page;
> -
> -				end_page = page + (1 << page_order(page)) - 1;
> -				move_freepages(page_zone(page), page, end_page,
> -						MIGRATE_ISOLATE);
> -			}
>  			pfn += 1 << page_order(page);
> -		}
> -		else if (page_count(page) == 0 &&
> -			get_freepage_migratetype(page) == MIGRATE_ISOLATE)
> -			pfn += 1;
> -		else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
> -			/*
> -			 * The HWPoisoned page may be not in buddy
> -			 * system, and page_count() is not 0.
> -			 */
> +		else if (skip_hwpoisoned_pages && PageHWPoison(page))
> +			/* A HWPoisoned page cannot be also PageBuddy */
>  			pfn++;
> -			continue;
> -		}
>  		else
>  			break;
>  	}

You may want to consider stating your assumptions explicitly in the code, 
perhaps with VM_BUG_ON(), such as in free_pcppages_bulk() to ensure things 
like get_freepage_migratetype(page) != MIGRATE_ISOLATE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
