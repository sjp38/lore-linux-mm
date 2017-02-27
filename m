Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEC66B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:21:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 73so47269942wrb.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:21:27 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 33si22103988wrk.174.2017.02.27.09.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 09:21:26 -0800 (PST)
Date: Mon, 27 Feb 2017 12:15:33 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V5 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170227171533.GB20423@cmpxchg.org>
References: <cover.1487965799.git.shli@fb.com>
 <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 24, 2017 at 01:31:46PM -0800, Shaohua Li wrote:
> madv MADV_FREE indicate pages are 'lazyfree'. They are still anonymous
> pages, but they can be freed without pageout. To destinguish them
> against normal anonymous pages, we clear their SwapBacked flag.
> 
> MADV_FREE pages could be freed without pageout, so they pretty much like
> used once file pages. For such pages, we'd like to reclaim them once
> there is memory pressure. Also it might be unfair reclaiming MADV_FREE
> pages always before used once file pages and we definitively want to
> reclaim the pages before other anonymous and file pages.
> 
> To speed up MADV_FREE pages reclaim, we put the pages into
> LRU_INACTIVE_FILE list. The rationale is LRU_INACTIVE_FILE list is tiny
> nowadays and should be full of used once file pages. Reclaiming
> MADV_FREE pages will not have much interfere of anonymous and active
> file pages. And the inactive file pages and MADV_FREE pages will be
> reclaimed according to their age, so we don't reclaim too many MADV_FREE
> pages too. Putting the MADV_FREE pages into LRU_INACTIVE_FILE_LIST also
> means we can reclaim the pages without swap support. This idea is
> suggested by Johannes.
> 
> This patch doesn't move MADV_FREE pages to LRU_INACTIVE_FILE list yet to
> avoid bisect failure, next patch will do it.
> 
> The patch is based on Minchan's original patch.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
