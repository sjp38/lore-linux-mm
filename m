Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03EE66B0387
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 05:12:02 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id w107so187733566ota.6
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 02:12:02 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id w43si47324otw.45.2017.02.14.02.11.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Feb 2017 02:12:01 -0800 (PST)
Message-ID: <58A2D6F9.6030400@huawei.com>
Date: Tue, 14 Feb 2017 18:07:53 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 04/10] mm, page_alloc: count movable pages when stealing
 from pageblock
References: <20170210172343.30283-1-vbabka@suse.cz> <20170210172343.30283-5-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-5-vbabka@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 2017/2/11 1:23, Vlastimil Babka wrote:

> When stealing pages from pageblock of a different migratetype, we count how
> many free pages were stolen, and change the pageblock's migratetype if more
> than half of the pageblock was free. This might be too conservative, as there
> might be other pages that are not free, but were allocated with the same
> migratetype as our allocation requested.
> 
> While we cannot determine the migratetype of allocated pages precisely (at
> least without the page_owner functionality enabled), we can count pages that
> compaction would try to isolate for migration - those are either on LRU or
> __PageMovable(). The rest can be assumed to be MIGRATE_RECLAIMABLE or
> MIGRATE_UNMOVABLE, which we cannot easily distinguish. This counting can be
> done as part of free page stealing with little additional overhead.
> 
> The page stealing code is changed so that it considers free pages plus pages
> of the "good" migratetype for the decision whether to change pageblock's
> migratetype.
> 
> The result should be more accurate migratetype of pageblocks wrt the actual
> pages in the pageblocks, when stealing from semi-occupied pageblocks. This
> should help the efficiency of page grouping by mobility.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Hi Vlastimil,

How about these two changes?

1. If we steal some free pages, we will add these page at the head of start_migratetype
list, it will cause more fixed, because these pages will be allocated more easily.
So how about use list_move_tail instead of list_move?

__rmqueue_fallback
	steal_suitable_fallback
		move_freepages_block
			move_freepages
				list_move

2. When doing expand() - list_add(), usually the list is empty, but in the
following case, the list is not empty, because we did move_freepages_block()
before.

__rmqueue_fallback
	steal_suitable_fallback
		move_freepages_block  // move to the list of start_migratetype
	expand  // split the largest order
		list_add  // add to the list of start_migratetype

So how about use list_add_tail instead of list_add? Then we can merge the large
block again as soon as the page freed.

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
