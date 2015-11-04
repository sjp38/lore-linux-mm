Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCEB82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 15:55:20 -0500 (EST)
Received: by wicll6 with SMTP id ll6so97952879wic.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 12:55:19 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b66si5424254wmf.33.2015.11.04.12.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 12:55:19 -0800 (PST)
Date: Wed, 4 Nov 2015 15:55:04 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: move lazily freed pages to inactive list
Message-ID: <20151104205504.GA9927@cmpxchg.org>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-6-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446188504-28023-6-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

On Fri, Oct 30, 2015 at 04:01:41PM +0900, Minchan Kim wrote:
> MADV_FREE is a hint that it's okay to discard pages if there is memory
> pressure and we use reclaimers(ie, kswapd and direct reclaim) to free them
> so there is no value keeping them in the active anonymous LRU so this
> patch moves them to inactive LRU list's head.
> 
> This means that MADV_FREE-ed pages which were living on the inactive list
> are reclaimed first because they are more likely to be cold rather than
> recently active pages.
> 
> An arguable issue for the approach would be whether we should put the page
> to the head or tail of the inactive list.  I chose head because the kernel
> cannot make sure it's really cold or warm for every MADV_FREE usecase but
> at least we know it's not *hot*, so landing of inactive head would be a
> comprimise for various usecases.

Even if we're wrong about the aging of those MADV_FREE pages, their
contents are invalidated; they can be discarded freely, and restoring
them is a mere GFP_ZERO allocation. All other anonymous pages have to
be written to disk, and potentially be read back.

[ Arguably, MADV_FREE pages should even be reclaimed before inactive
  page cache. It's the same cost to discard both types of pages, but
  restoring page cache involves IO. ]

It probably makes sense to stop thinking about them as anonymous pages
entirely at this point when it comes to aging. They're really not. The
LRU lists are split to differentiate access patterns and cost of page
stealing (and restoring). From that angle, MADV_FREE pages really have
nothing in common with in-use anonymous pages, and so they shouldn't
be on the same LRU list.

That would also fix the very unfortunate and unexpected consequence of
tying the lazy free optimization to the availability of swap space.

I would prefer to see this addressed before the code goes upstream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
