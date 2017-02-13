Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA296B0388
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:53:28 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t18so40715855wmt.7
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:53:27 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id 13si13356100wrw.52.2017.02.13.02.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 02:53:26 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 8F08D1C2364
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:53:26 +0000 (GMT)
Date: Mon, 13 Feb 2017 10:53:26 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 04/10] mm, page_alloc: count movable pages when
 stealing from pageblock
Message-ID: <20170213105325.roditvyrzcl532pd@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:37PM +0100, Vlastimil Babka wrote:
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

While it's fine now, it may be necessary to unify the checks that
compaction and the page allocator use for determining if the page can
move. In general, this is still a better idea for a modest amount of
overhead in a path that is considered slow anyway so

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
