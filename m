Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 195A36B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 15:25:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v109so13422799wrc.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:25:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w57si1014045edb.269.2017.09.26.12.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Sep 2017 12:25:33 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:25:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 1/2] mm: avoid marking swap cached page as lazyfree
Message-ID: <20170926192524.GA30943@cmpxchg.org>
References: <cover.1506446061.git.shli@fb.com>
 <6537ef3814398c0073630b03f176263bc81f0902.1506446061.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6537ef3814398c0073630b03f176263bc81f0902.1506446061.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

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

The patch lgtm, but for the changelog it probably makes sense to start
with the user-visible behavior, i.e. the endlessly looping swap fault
handler because it thinks it's racing with the swap slot being freed.

Makes it easier for other distro/vendor people to identify this for
backporting.

On that note, I think this should go into 4.13 and be tagged for 4.12
stable.

> Reported-and-tested-by: Artem Savkov <asavkov@redhat.com>
> Fix: 802a3a92ad7a(mm: reclaim MADV_FREE pages)
> Signed-off-by: Shaohua Li <shli@fb.com>
> Cc: stable@vger.kernel.org
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
