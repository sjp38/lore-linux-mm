Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E42C6B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 00:44:25 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so297226418pfb.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 21:44:25 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id u5si25540967pgi.223.2017.01.25.21.44.22
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 21:44:24 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
In-Reply-To: <20170123181641.23938-1-hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] mm: vmscan: fix kswapd writeback regression
Date: Thu, 26 Jan 2017 13:44:01 +0800
Message-ID: <007c01d27797$34178790$9c4696b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


On January 24, 2017 2:17 AM Johannes Weiner wrote:
> 
> We noticed a regression on multiple hadoop workloads when moving from
> 3.10 to 4.0 and 4.6, which involves kswapd getting tangled up in page
> writeout, causing direct reclaim herds that also don't make progress.
> 
> I tracked it down to the thrash avoidance efforts after 3.10 that make
> the kernel better at keeping use-once cache and use-many cache sorted
> on the inactive and active list, with more aggressive protection of
> the active list as long as there is inactive cache. Unfortunately, our
> workload's use-once cache is mostly from streaming writes. Waiting for
> writes to avoid potential reloads in the future is not a good tradeoff.
> 
> These patches do the following:
> 
> 1. Wake the flushers when kswapd sees a lump of dirty pages. It's
>    possible to be below the dirty background limit and still have
>    cache velocity push them through the LRU. So start a-flushin'.
> 
> 2. Let kswapd only write pages that have been rotated twice. This
>    makes sure we really tried to get all the clean pages on the
>    inactive list before resorting to horrible LRU-order writeback.
> 
> 3. Move rotating dirty pages off the inactive list. Instead of
>    churning or waiting on page writeback, we'll go after clean active
>    cache. This might lead to thrashing, but in this state memory
>    demand outstrips IO speed anyway, and reads are faster than writes.
> 
> More details in the individual changelogs.
> 
>  include/linux/mm_inline.h        |  7 ++++
>  include/linux/mmzone.h           |  2 --
>  include/linux/writeback.h        |  2 +-
>  include/trace/events/writeback.h |  2 +-
>  mm/swap.c                        |  9 ++---
>  mm/vmscan.c                      | 68 +++++++++++++++-----------------------
>  6 files changed, 41 insertions(+), 49 deletions(-)
> 
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
