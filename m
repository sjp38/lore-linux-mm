Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83FCB6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 19:20:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so19958783pfj.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 16:20:08 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e8si6572295pgf.23.2017.09.26.16.20.06
        for <linux-mm@kvack.org>;
        Tue, 26 Sep 2017 16:20:07 -0700 (PDT)
Date: Wed, 27 Sep 2017 08:20:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V3 1/2] mm: avoid marking swap cached page as lazyfree
Message-ID: <20170926232005.GA32370@bbox>
References: <cover.1506446061.git.shli@fb.com>
 <6537ef3814398c0073630b03f176263bc81f0902.1506446061.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6537ef3814398c0073630b03f176263bc81f0902.1506446061.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 26, 2017 at 10:26:25AM -0700, Shaohua Li wrote:
> From: Shaohua Li <shli@fb.com>
> 
> MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
> SwapBacked). There is no lock to prevent the page is added to swap cache
> between these two steps by page reclaim. Page reclaim could add the page
> to swap cache and unmap the page. After page reclaim, the page is added
> back to lru. At that time, we probably start draining per-cpu pagevec
> and mark the page lazyfree. So the page could be in a state with
> SwapBacked cleared and PG_swapcache set. Next time there is a refault in
> the virtual address, do_swap_page can find the page from swap cache but
> the page has PageSwapCache false because SwapBacked isn't set, so
> do_swap_page will bail out and do nothing. The task will keep running
> into fault handler.

With new description, I got why you want to seperate this. Yub, it should
be separated. Sorry for the noise. What I was missing is PageSwapCache's
change which checked PG_swapbacked as well as PG_swapcache. I didn't 
notice that the change.

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
