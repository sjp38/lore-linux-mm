Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E88D02808AC
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 04:12:27 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c143so19317990wmd.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:12:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w130si3444226wmf.134.2017.03.09.01.12.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 01:12:26 -0800 (PST)
Date: Thu, 9 Mar 2017 10:12:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170309091224.GC11592@dhcp22.suse.cz>
References: <20170307133057.26182-1-mhocko@kernel.org>
 <1488916356.6405.4.camel@redhat.com>
 <20170308092114.GB11028@dhcp22.suse.cz>
 <1488988497.8850.23.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488988497.8850.23.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-03-17 10:54:57, Rik van Riel wrote:
> On Wed, 2017-03-08 at 10:21 +0100, Michal Hocko wrote:
> 
> > > Could that create problems if we have many concurrent
> > > reclaimers?
> > 
> > As the changelog mentions it might cause a premature oom killer
> > invocation theoretically. We could easily see that from the oom
> > report
> > by checking isolated counters. My testing didn't trigger that though
> > and I was hammering the page allocator path from many threads.
> > 
> > I suspect some artificial tests can trigger that, I am not so sure
> > about
> > reasonabel workloads. If we see this happening though then the fix
> > would
> > be to resurrect my previous attempt to track NR_ISOLATED* per zone
> > and
> > use them in the allocator retry logic.
> 
> I am not sure the workload in question is "artificial".
> A heavily forking (or multi-threaded) server running out
> of physical memory could easily get hundreds of tasks
> doing direct reclaim simultaneously.

Yes, some of my OOM tests (fork many short lived processes while there
is a strong memory pressure and a lot of IO going on) are doing this and
I haven't hit a premature OOM yet. It is hard to tune those tests for almost
OOM but not yet there, though. Usually you either find a steady state or
really run out of memory.

> In fact, false OOM kills with that kind of workload is
> how we ended up getting the "too many isolated" logic
> in the first place.

Right, but the retry logic was considerably different than what we
have these days. should_reclaim_retry considers amount of reclaimable
memory. As I've said earlier if we see a report where the oom hits
prematurely with many NR_ISOLATED* we know how to fix that.

> I am perfectly fine with moving the retry logic up like
> you did, but think it may make sense to check the number
> of reclaimable pages if we have too many isolated pages,
> instead of risking a too-early OOM kill.

Actually that was my initial attempt but for that we would need per-zone
NR_ISOLATED* counters but Mel was against and wanted to start with
simpler approach if it works reasonably well which it seems it does from
my experience so far (but the reallity can surprise as I've seen so many
times already).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
