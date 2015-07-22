Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 51D869003C8
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 17:42:20 -0400 (EDT)
Received: by pacan13 with SMTP id an13so146384282pac.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 14:42:20 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id o6si6526374pds.214.2015.07.22.14.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 14:42:19 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so144837808pac.3
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 14:42:18 -0700 (PDT)
Date: Wed, 22 Jul 2015 14:42:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, page_isolation: remove bogus tests for isolated
 pages
In-Reply-To: <55AF8BD2.6060009@suse.cz>
Message-ID: <alpine.DEB.2.10.1507221442070.21468@chino.kir.corp.google.com>
References: <55969822.9060907@suse.cz> <1437483218-18703-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507211540080.3833@chino.kir.corp.google.com> <55AF8BD2.6060009@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Wed, 22 Jul 2015, Vlastimil Babka wrote:

> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Wed, 22 Jul 2015 14:16:52 +0200
> Subject: [PATCH 2/3] fixup! mm, page_isolation: remove bogus tests for
>  isolated pages
> 
> ---
>  mm/page_alloc.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 41dc650..c61fef8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -789,7 +789,11 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			page = list_entry(list->prev, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
> +
>  			mt = get_freepage_migratetype(page);
> +			/* MIGRATE_ISOLATE page should not go to pcplists */
> +			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
> +			/* Pageblock could have been isolated meanwhile */
>  			if (unlikely(has_isolate_pageblock(zone)))
>  				mt = get_pageblock_migratetype(page);
>  

Looks good, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
