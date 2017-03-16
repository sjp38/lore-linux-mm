Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF6206B0395
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:12:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e5so66313238pgk.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:12:32 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o20si3728572pgn.150.2017.03.15.19.12.31
        for <linux-mm@kvack.org>;
        Wed, 15 Mar 2017 19:12:32 -0700 (PDT)
Date: Thu, 16 Mar 2017 11:14:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 7/8] mm, compaction: restrict async compaction to
 pageblocks of same migratetype
Message-ID: <20170316021403.GC14063@js1304-P5Q-DELUXE>
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170307131545.28577-8-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307131545.28577-8-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, kernel-team@lge.com

On Tue, Mar 07, 2017 at 02:15:44PM +0100, Vlastimil Babka wrote:
> The migrate scanner in async compaction is currently limited to MIGRATE_MOVABLE
> pageblocks. This is a heuristic intended to reduce latency, based on the
> assumption that non-MOVABLE pageblocks are unlikely to contain movable pages.
> 
> However, with the exception of THP's, most high-order allocations are not
> movable. Should the async compaction succeed, this increases the chance that
> the non-MOVABLE allocations will fallback to a MOVABLE pageblock, making the
> long-term fragmentation worse.

I agree with this idea but have some concerns on this change.

*ASYNC* compaction is designed for reducing latency and this change
doesn't fit it. If everything works fine, there is a few movable pages
in non-MOVABLE pageblocks as you noted above. Moreover, there is quite
less the number of non-MOVABLE pageblock than MOVABLE one so finding
non-MOVABLE pageblock takes long time. These two factors will increase
the latency of *ASYNC* compaction.

And, there is a concern in implementaion side. With this change, there
is much possibilty that compaction scanner's met by ASYNC compaction.
It resets the scanner position and SYNC compaction would start the
scan at the beginning of the zone every time. It would make cached
position useless and inefficient.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
