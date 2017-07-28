Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1FB56B051B
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:41:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i187so14107170wma.15
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:41:10 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id l55si6704763edb.80.2017.07.28.03.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 03:41:09 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 5E2B91C20D7
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 11:41:09 +0100 (IST)
Date: Fri, 28 Jul 2017 11:41:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 4/6] mm, kswapd: wake up kcompactd when kswapd had too
 many failures
Message-ID: <20170728104108.lnq6vw4ibdm33g6v@techsingularity.net>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <20170727160701.9245-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170727160701.9245-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Jul 27, 2017 at 06:06:59PM +0200, Vlastimil Babka wrote:
> This patch deals with a corner case found when testing kcompactd with a very
> simple testcase that first fragments memory (by creating a large shmem file and
> then punching hole in every even page) and then uses artificial order-9
> GFP_NOWAIT allocations in a loop. This is freshly after virtme-run boot in KVM
> and no other activity.
> 
> What happens is that after few kswapd runs, there are no more reclaimable
> pages, and high-order pages can only be created by compaction. Because kswapd
> can't reclaim anything, pgdat->kswapd_failures increases up to
> MAX_RECLAIM_RETRIES and kswapd is no longer woken up. Thus kcompactd is also
> not woken up. After this patch, we will try to wake up kcompactd immediately
> instead of kswapd.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

If kswapd cannot make any progress then it's possible that kcompact
won'y be able to move the pages either. However, an exception is
anonymous pages without swap configured so

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
