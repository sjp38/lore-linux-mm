Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91AB06B027F
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 04:48:18 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m184so180557240qkb.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 01:48:18 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id g8si13820498qka.164.2016.09.26.01.48.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Sep 2016 01:48:18 -0700 (PDT)
Message-ID: <57E8E0BD.2070603@huawei.com>
Date: Mon, 26 Sep 2016 16:47:57 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] mm: a question about high-order check in __zone_watermark_ok()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Yisheng Xie <xieyisheng1@huawei.com>

commit 97a16fc82a7c5b0cfce95c05dfb9561e306ca1b1
(mm, page_alloc: only enforce watermarks for order-0 allocations)
rewrite the high-order check in __zone_watermark_ok(), but I think it
quietly fix a bug. Please see the following.

Before this patch, the high-order check is this:
__zone_watermark_ok()
	...
	for (o = 0; o < order; o++) {
		/* At the next order, this order's pages become unavailable */
		free_pages -= z->free_area[o].nr_free << o;

		/* Require fewer higher order pages to be free */
		min >>= 1;

		if (free_pages <= min)
			return false;
	}
	...

If we have cma memory, and we alloc a high-order movable page, then it's right.

But if we alloc a high-order unmovable page(e.g. alloc kernel stack in dup_task_struct()),
and there are a lot of high-order cma pages, but little high-order unmovable
pages, the it is still return *true*, but we will alloc *failed* finally, because
we cannot fallback from migrate_unmovable to migrate_cma, right?

Also if we doing __alloc_pages_slowpath(), the compact will not work, because
__zone_watermark_ok() always return true, and it lead to alloc a high-order
unmovable page failed, then do direct reclaim.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
