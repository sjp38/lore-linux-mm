Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05B32280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 07:02:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so80050401wmg.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:02:33 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id i2si18943736wjd.159.2016.09.26.04.02.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 04:02:32 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 133so13521960wmq.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:02:32 -0700 (PDT)
Date: Mon, 26 Sep 2016 13:02:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm: a question about high-order check in
 __zone_watermark_ok()
Message-ID: <20160926110231.GE28550@dhcp22.suse.cz>
References: <57E8E0BD.2070603@huawei.com>
 <20160926085850.GB28550@dhcp22.suse.cz>
 <57E8E786.8030703@huawei.com>
 <20160926094333.GD28550@dhcp22.suse.cz>
 <57E8F5CE.908@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E8F5CE.908@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>

On Mon 26-09-16 18:17:50, Xishi Qiu wrote:
> On 2016/9/26 17:43, Michal Hocko wrote:
> 
> > On Mon 26-09-16 17:16:54, Xishi Qiu wrote:
> >> On 2016/9/26 16:58, Michal Hocko wrote:
> >>
> >>> On Mon 26-09-16 16:47:57, Xishi Qiu wrote:
> >>>> commit 97a16fc82a7c5b0cfce95c05dfb9561e306ca1b1
> >>>> (mm, page_alloc: only enforce watermarks for order-0 allocations)
> >>>> rewrite the high-order check in __zone_watermark_ok(), but I think it
> >>>> quietly fix a bug. Please see the following.
> >>>>
> >>>> Before this patch, the high-order check is this:
> >>>> __zone_watermark_ok()
> >>>> 	...
> >>>> 	for (o = 0; o < order; o++) {
> >>>> 		/* At the next order, this order's pages become unavailable */
> >>>> 		free_pages -= z->free_area[o].nr_free << o;
> >>>>
> >>>> 		/* Require fewer higher order pages to be free */
> >>>> 		min >>= 1;
> >>>>
> >>>> 		if (free_pages <= min)
> >>>> 			return false;
> >>>> 	}
> >>>> 	...
> >>>>
> >>>> If we have cma memory, and we alloc a high-order movable page, then it's right.
> >>>>
> >>>> But if we alloc a high-order unmovable page(e.g. alloc kernel stack in dup_task_struct()),
> >>>> and there are a lot of high-order cma pages, but little high-order unmovable
> >>>> pages, the it is still return *true*, but we will alloc *failed* finally, because
> >>>> we cannot fallback from migrate_unmovable to migrate_cma, right?
> >>>
> >>> AFAIR CMA wmark check was always tricky and the above commit has made
> >>> the situation at least a bit more clear. Anyway IIRC 
> >>>
> >>> #ifdef CONFIG_CMA
> >>> 	/* If allocation can't use CMA areas don't use free CMA pages */
> >>> 	if (!(alloc_flags & ALLOC_CMA))
> >>> 		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
> >>> #endif
> >>>
> >>> 	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
> >>> 		return false;
> >>>
> >>> should reduce the prioblem because a lot of CMA pages should just get us
> >>> below the wmark + reserve boundary.
> >>
> >> Hi Michal,
> >>
> >> If we have many high-order cma pages, and the left pages (unmovable/movable/reclaimable)
> >> are also enough, but they are fragment, then it will triger the problem.
> >> If we alloc a high-order unmovable page, water mark check return *true*, but we
> >> will alloc *failed*, right?
> > 
> > As Vlastimil has written. There were known issues with the wmark checks
> > and high order requests.
> 
> Shall we backport to stable?

I dunno, it was a part of a larger series with high atomic reserves and
changes which sound a bit intrusive for the stable kernel. Considering
that CMA was known to be problematic and there are still some issues
left I do not think this is worth the trouble/risk.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
