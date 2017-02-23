Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C39206B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 05:19:07 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id s27so13789792wrb.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:19:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w67si5859374wma.76.2017.02.23.02.19.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 02:19:06 -0800 (PST)
Date: Thu, 23 Feb 2017 11:19:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm/vmscan: fix high cpu usage of kswapd if there
Message-ID: <20170223101901.tr2j7d3p6vt55knn@dhcp22.suse.cz>
References: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
 <20170222201657.GA6534@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222201657.GA6534@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Wed 22-02-17 15:16:57, Johannes Weiner wrote:
[...]
> Can we simply count the number of balance_pgdat() runs that didn't
> reclaim anything and have kswapd sleep after MAX_RECLAIM_RETRIES?
> 
> And a follow-up: once it gives up, when should kswapd return to work?
> We used to reset NR_PAGES_SCANNED whenever a page gets freed. But
> that's a branch in a common allocator path, just to recover kswapd - a
> latency tool, not a necessity for functional correctness - from a
> situation that's exceedingly pretty rare. How about we leave it
> disabled until a direct reclaimer manages to free something?

Yes, this makes sense to me and it looks much better than the proposed
solution here. There some theoretical corner cases, like heavy metadata
and GFP_NOFS workload which wouldn't be able to reclaim from FS
shrinkers and kspwad would be really helpful at that time. But that
would need a general solution on its own.

I also welcome removing NR_PAGES_SCANNED, because this was just too
ephemeral to be actually useful when debugging the reclaim behavior.
I think we can accomplish much more by existing tracepoints. I would
just split that up in a separate follow up patch.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
