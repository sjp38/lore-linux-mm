Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE7E831ED
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:55:01 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 9so93079595qkk.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:55:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f7si3242895qtf.104.2017.03.08.07.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:55:00 -0800 (PST)
Message-ID: <1488988497.8850.23.camel@redhat.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Rik van Riel <riel@redhat.com>
Date: Wed, 08 Mar 2017 10:54:57 -0500
In-Reply-To: <20170308092114.GB11028@dhcp22.suse.cz>
References: <20170307133057.26182-1-mhocko@kernel.org>
	 <1488916356.6405.4.camel@redhat.com>
	 <20170308092114.GB11028@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 2017-03-08 at 10:21 +0100, Michal Hocko wrote:

> > Could that create problems if we have many concurrent
> > reclaimers?
> 
> As the changelog mentions it might cause a premature oom killer
> invocation theoretically. We could easily see that from the oom
> report
> by checking isolated counters. My testing didn't trigger that though
> and I was hammering the page allocator path from many threads.
> 
> I suspect some artificial tests can trigger that, I am not so sure
> about
> reasonabel workloads. If we see this happening though then the fix
> would
> be to resurrect my previous attempt to track NR_ISOLATED* per zone
> and
> use them in the allocator retry logic.

I am not sure the workload in question is "artificial".
A heavily forking (or multi-threaded) server running out
of physical memory could easily get hundreds of tasks
doing direct reclaim simultaneously.

In fact, false OOM kills with that kind of workload is
how we ended up getting the "too many isolated" logic
in the first place.

I am perfectly fine with moving the retry logic up like
you did, but think it may make sense to check the number
of reclaimable pages if we have too many isolated pages,
instead of risking a too-early OOM kill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
