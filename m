Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84FDE280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 05:43:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so77994395wmg.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 02:43:36 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id gg6si18689904wjd.136.2016.09.26.02.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 02:43:35 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w84so13183521wmg.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 02:43:35 -0700 (PDT)
Date: Mon, 26 Sep 2016 11:43:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm: a question about high-order check in
 __zone_watermark_ok()
Message-ID: <20160926094333.GD28550@dhcp22.suse.cz>
References: <57E8E0BD.2070603@huawei.com>
 <20160926085850.GB28550@dhcp22.suse.cz>
 <57E8E786.8030703@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E8E786.8030703@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>

On Mon 26-09-16 17:16:54, Xishi Qiu wrote:
> On 2016/9/26 16:58, Michal Hocko wrote:
> 
> > On Mon 26-09-16 16:47:57, Xishi Qiu wrote:
> >> commit 97a16fc82a7c5b0cfce95c05dfb9561e306ca1b1
> >> (mm, page_alloc: only enforce watermarks for order-0 allocations)
> >> rewrite the high-order check in __zone_watermark_ok(), but I think it
> >> quietly fix a bug. Please see the following.
> >>
> >> Before this patch, the high-order check is this:
> >> __zone_watermark_ok()
> >> 	...
> >> 	for (o = 0; o < order; o++) {
> >> 		/* At the next order, this order's pages become unavailable */
> >> 		free_pages -= z->free_area[o].nr_free << o;
> >>
> >> 		/* Require fewer higher order pages to be free */
> >> 		min >>= 1;
> >>
> >> 		if (free_pages <= min)
> >> 			return false;
> >> 	}
> >> 	...
> >>
> >> If we have cma memory, and we alloc a high-order movable page, then it's right.
> >>
> >> But if we alloc a high-order unmovable page(e.g. alloc kernel stack in dup_task_struct()),
> >> and there are a lot of high-order cma pages, but little high-order unmovable
> >> pages, the it is still return *true*, but we will alloc *failed* finally, because
> >> we cannot fallback from migrate_unmovable to migrate_cma, right?
> > 
> > AFAIR CMA wmark check was always tricky and the above commit has made
> > the situation at least a bit more clear. Anyway IIRC 
> > 
> > #ifdef CONFIG_CMA
> > 	/* If allocation can't use CMA areas don't use free CMA pages */
> > 	if (!(alloc_flags & ALLOC_CMA))
> > 		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> > #endif
> > 
> > 	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> > 		return false;
> > 
> > should reduce the prioblem because a lot of CMA pages should just get us
> > below the wmark + reserve boundary.
> 
> Hi Michal,
> 
> If we have many high-order cma pages, and the left pages (unmovable/movable/reclaimable)
> are also enough, but they are fragment, then it will triger the problem.
> If we alloc a high-order unmovable page, water mark check return *true*, but we
> will alloc *failed*, right?

As Vlastimil has written. There were known issues with the wmark checks
and high order requests.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
