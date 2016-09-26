Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A75BB280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:52:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so76518546wmc.2
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:52:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si18568884wjf.185.2016.09.26.01.52.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 01:52:46 -0700 (PDT)
Subject: Re: [RFC] mm: a question about high-order check in
 __zone_watermark_ok()
References: <57E8E0BD.2070603@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8cb02c0b-0825-d180-8ce3-dce6e584fc48@suse.cz>
Date: Mon, 26 Sep 2016 10:52:42 +0200
MIME-Version: 1.0
In-Reply-To: <57E8E0BD.2070603@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

[+CC Joonsoo Kim]

On 09/26/2016 10:47 AM, Xishi Qiu wrote:
> commit 97a16fc82a7c5b0cfce95c05dfb9561e306ca1b1
> (mm, page_alloc: only enforce watermarks for order-0 allocations)
> rewrite the high-order check in __zone_watermark_ok(), but I think it
> quietly fix a bug. Please see the following.
>
> Before this patch, the high-order check is this:
> __zone_watermark_ok()
> 	...
> 	for (o = 0; o < order; o++) {
> 		/* At the next order, this order's pages become unavailable */
> 		free_pages -= z->free_area[o].nr_free << o;
>
> 		/* Require fewer higher order pages to be free */
> 		min >>= 1;
>
> 		if (free_pages <= min)
> 			return false;
> 	}
> 	...
>
> If we have cma memory, and we alloc a high-order movable page, then it's right.
>
> But if we alloc a high-order unmovable page(e.g. alloc kernel stack in dup_task_struct()),
> and there are a lot of high-order cma pages, but little high-order unmovable
> pages, the it is still return *true*, but we will alloc *failed* finally, because
> we cannot fallback from migrate_unmovable to migrate_cma, right?

Yeah I think this limitation was known to CMA people.

> Also if we doing __alloc_pages_slowpath(), the compact will not work, because
> __zone_watermark_ok() always return true, and it lead to alloc a high-order
> unmovable page failed, then do direct reclaim.

I guess that can happen as well.

> Thanks,
> Xishi Qiu
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
