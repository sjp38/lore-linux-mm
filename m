Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 556106B025E
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 19:20:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id f84so20003240pfj.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 16:20:50 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k1si6516398pgn.353.2017.09.26.16.20.48
        for <linux-mm@kvack.org>;
        Tue, 26 Sep 2017 16:20:49 -0700 (PDT)
Date: Wed, 27 Sep 2017 08:20:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V3 2/2] mm: fix data corruption caused by lazyfree page
Message-ID: <20170926232046.GB32370@bbox>
References: <cover.1506446061.git.shli@fb.com>
 <08c84256b007bf3f63c91d94383bd9eb6fee2daa.1506446061.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08c84256b007bf3f63c91d94383bd9eb6fee2daa.1506446061.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 26, 2017 at 10:26:26AM -0700, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
> SwapBacked). There is no lock to prevent the page is added to swap cache
> between these two steps by page reclaim. If page reclaim finds such
> page, it will simply add the page to swap cache without pageout the page
> to swap because the page is marked as clean. Next time, page fault will
> read data from the swap slot which doesn't have the original data, so we
> have a data corruption. To fix issue, we mark the page dirty and pageout
> the page.
> 
> However, we shouldn't dirty all pages which is clean and in swap cache.
> swapin page is swap cache and clean too. So we only dirty page which is
> added into swap cache in page reclaim, which shouldn't be swapin page.
> As Minchan suggested, simply dirty the page in add_to_swap can do the
> job.
> 
> Reported-by: Artem Savkov <asavkov@redhat.com>
> Fix: 802a3a92ad7a(mm: reclaim MADV_FREE pages)
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
