Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3A76B0070
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 10:57:50 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so1697850wgg.7
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 07:57:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hr5si17992792wjb.150.2014.12.19.07.57.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 07:57:48 -0800 (PST)
Date: Fri, 19 Dec 2014 16:57:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm, vmscan: prevent kswapd livelock due to
 pfmemalloc-throttled process being killed
Message-ID: <20141219155747.GA31756@dhcp22.suse.cz>
References: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, stable@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>

On Fri 19-12-14 14:01:55, Vlastimil Babka wrote:
> Charles Shirron and Paul Cassella from Cray Inc have reported kswapd stuck
> in a busy loop with nothing left to balance, but kswapd_try_to_sleep() failing
> to sleep. Their analysis found the cause to be a combination of several
> factors:
> 
> 1. A process is waiting in throttle_direct_reclaim() on pgdat->pfmemalloc_wait
> 
> 2. The process has been killed (by OOM in this case), but has not yet been
>    scheduled to remove itself from the waitqueue and die.

pfmemalloc_wait is used as wait_event and that one uses
autoremove_wake_function for wake ups so the task shouldn't stay on the
queue if it was woken up. Moreover pfmemalloc_wait sleeps are killable
by the OOM killer AFAICS.

$ git grep "wait_event.*pfmemalloc_wait"
mm/vmscan.c:
wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
mm/vmscan.c:    wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,))

So OOM killer would wake it up already and kswapd shouldn't see this
task on the waitqueue anymore.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
