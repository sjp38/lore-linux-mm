Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36A756B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 13:17:00 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so28143828wjc.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 10:17:00 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f143si15138203wme.164.2017.01.23.10.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 10:16:58 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/5] mm: vmscan: fix kswapd writeback regression
Date: Mon, 23 Jan 2017 13:16:36 -0500
Message-Id: <20170123181641.23938-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

We noticed a regression on multiple hadoop workloads when moving from
3.10 to 4.0 and 4.6, which involves kswapd getting tangled up in page
writeout, causing direct reclaim herds that also don't make progress.

I tracked it down to the thrash avoidance efforts after 3.10 that make
the kernel better at keeping use-once cache and use-many cache sorted
on the inactive and active list, with more aggressive protection of
the active list as long as there is inactive cache. Unfortunately, our
workload's use-once cache is mostly from streaming writes. Waiting for
writes to avoid potential reloads in the future is not a good tradeoff.

These patches do the following:

1. Wake the flushers when kswapd sees a lump of dirty pages. It's
   possible to be below the dirty background limit and still have
   cache velocity push them through the LRU. So start a-flushin'.

2. Let kswapd only write pages that have been rotated twice. This
   makes sure we really tried to get all the clean pages on the
   inactive list before resorting to horrible LRU-order writeback.

3. Move rotating dirty pages off the inactive list. Instead of
   churning or waiting on page writeback, we'll go after clean active
   cache. This might lead to thrashing, but in this state memory
   demand outstrips IO speed anyway, and reads are faster than writes.

More details in the individual changelogs.

 include/linux/mm_inline.h        |  7 ++++
 include/linux/mmzone.h           |  2 --
 include/linux/writeback.h        |  2 +-
 include/trace/events/writeback.h |  2 +-
 mm/swap.c                        |  9 ++---
 mm/vmscan.c                      | 68 +++++++++++++++-----------------------
 6 files changed, 41 insertions(+), 49 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
