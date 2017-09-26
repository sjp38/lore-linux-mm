Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0C246B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 15:40:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z1so299462wre.6
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:40:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z24si8016240edb.493.2017.09.26.12.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Sep 2017 12:40:22 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:40:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 2/2] mm: fix data corruption caused by lazyfree page
Message-ID: <20170926194017.GB30943@cmpxchg.org>
References: <cover.1506446061.git.shli@fb.com>
 <08c84256b007bf3f63c91d94383bd9eb6fee2daa.1506446061.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08c84256b007bf3f63c91d94383bd9eb6fee2daa.1506446061.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

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

Reclaim and MADV_FREE hold the page lock when manipulating the dirty
and the swapcache state.

Instead of undoing a racing MADV_FREE in reclaim, wouldn't it be safe
to check the dirty bit before add_to_swap() and skip clean pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
