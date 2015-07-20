Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 029D49003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:54:16 -0400 (EDT)
Received: by pacan13 with SMTP id an13so101437423pac.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:54:15 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id dt1si35537664pdb.120.2015.07.20.04.54.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 04:54:15 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so29992748pdb.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:54:14 -0700 (PDT)
Date: Mon, 20 Jul 2015 20:54:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm/page_owner: set correct gfp_mask on page_owner
Message-ID: <20150720115352.GA13474@bgram>
References: <1436942039-16897-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1436942039-16897-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20150716000613.GE988@bgram>
 <55ACDB3B.8010607@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55ACDB3B.8010607@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Jul 20, 2015 at 01:27:55PM +0200, Vlastimil Babka wrote:
> On 07/16/2015 02:06 AM, Minchan Kim wrote:
> >On Wed, Jul 15, 2015 at 03:33:59PM +0900, Joonsoo Kim wrote:
> >>@@ -2003,7 +2005,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
> >>  	zone->free_area[order].nr_free--;
> >>  	rmv_page_order(page);
> >>
> >>-	set_page_owner(page, order, 0);
> >>+	set_page_owner(page, order, __GFP_MOVABLE);
> >
> >It seems the reason why  __GFP_MOVABLE is okay is that __isolate_free_page
> >works on a free page on MIGRATE_MOVABLE|MIGRATE_CMA's pageblock. But if we
> >break the assumption in future, here is broken again?
> 
> I didn't study the page owner code yet and I'm catching up after
> vacation, but I share your concern. But I don't think the
> correctness depends on the pageblock we are isolating from. I think
> the assumption is that the isolated freepage will be used as a
> target for migration, and that only movable pages can be
> successfully migrated (but also CMA pages, and that information can
> be lost?). However there are also efforts to allow migrate e.g.
> driver pages that won't be marked as movable. And I'm not sure which
> migratetype are balloon pages which already have special migration
> code.

I am one of people who want to migrate driver pages from compaction
from zram point of view so I agree with you.
However, If I make zram support migratepages, I will use __GFP_MOVABLE.
So, I'm not sure there is any special driver that it can support migrate
via migratepage but it doesn't set __GFP_MOVABLE.

Having said that, I support your opinion because __GFP_MOVABLE is not
only gfp mask for allocating so we should take care of complete gfp
mask from original page.


> 
> So what I would think (without knowing all details) that the page
> owner info should be transferred during page migration with all the
> other flags, and shouldn't concern __isolate_free_page() at all?
> 

I agree.
 
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
