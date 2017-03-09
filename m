Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3426D2808E6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:59:41 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u9so21045841wme.6
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:59:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si4580293wme.78.2017.03.09.06.59.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 06:59:39 -0800 (PST)
Date: Thu, 9 Mar 2017 15:59:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170309145937.GK11592@dhcp22.suse.cz>
References: <20170307133057.26182-1-mhocko@kernel.org>
 <1488916356.6405.4.camel@redhat.com>
 <20170308092114.GB11028@dhcp22.suse.cz>
 <1488988497.8850.23.camel@redhat.com>
 <20170309091224.GC11592@dhcp22.suse.cz>
 <1489068985.1906.1.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489068985.1906.1.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 09-03-17 09:16:25, Rik van Riel wrote:
> On Thu, 2017-03-09 at 10:12 +0100, Michal Hocko wrote:
> > On Wed 08-03-17 10:54:57, Rik van Riel wrote:
> 
> > > In fact, false OOM kills with that kind of workload is
> > > how we ended up getting the "too many isolated" logic
> > > in the first place.
> > Right, but the retry logic was considerably different than what we
> > have these days. should_reclaim_retry considers amount of reclaimable
> > memory. As I've said earlier if we see a report where the oom hits
> > prematurely with many NR_ISOLATED* we know how to fix that.
> 
> Would it be enough to simply reset no_progress_loops
> in this check inside should_reclaim_retry, if we know
> pageout IO is pending?
> 
>                         if (!did_some_progress) {
>                                 unsigned long write_pending;
> 
>                                 write_pending = zone_page_state_snapshot(zone,
>                                                         NR_ZONE_WRITE_PENDING);
> 
>                                 if (2 * write_pending > reclaimable) {
>                                         congestion_wait(BLK_RW_ASYNC, HZ/10);
>                                         return true;
>                                 }
>                         }

I am not really sure what problem we are trying to solve right now to be
honest. I would prefer to keep the logic simpler rather than over
engeneer something that is even not needed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
