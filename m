Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0EAFC280911
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 05:27:59 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g10so27037816wrg.5
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 02:27:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p201si2290750wme.108.2017.03.10.02.27.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 02:27:57 -0800 (PST)
Date: Fri, 10 Mar 2017 11:27:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170310102756.GE3753@dhcp22.suse.cz>
References: <20170307133057.26182-1-mhocko@kernel.org>
 <1488916356.6405.4.camel@redhat.com>
 <20170309180540.GA8678@cmpxchg.org>
 <1489097880.1906.16.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489097880.1906.16.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 09-03-17 17:18:00, Rik van Riel wrote:
> On Thu, 2017-03-09 at 13:05 -0500, Johannes Weiner wrote:
> > On Tue, Mar 07, 2017 at 02:52:36PM -0500, Rik van Riel wrote:
> > > 
> > > It only does this to some extent.  If reclaim made
> > > no progress, for example due to immediately bailing
> > > out because the number of already isolated pages is
> > > too high (due to many parallel reclaimers), the code
> > > could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
> > > test without ever looking at the number of reclaimable
> > > pages.
> > Hm, there is no early return there, actually. We bump the loop
> > counter
> > every time it happens, but then *do* look at the reclaimable pages.
> 
> Am I looking at an old tree?  I see this code
> before we look at the reclaimable pages.
> 
>         /*
>          * Make sure we converge to OOM if we cannot make any progress
>          * several times in the row.
>          */
>         if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
>                 /* Before OOM, exhaust highatomic_reserve */
>                 return unreserve_highatomic_pageblock(ac, true);
>         }

I believe that Johannes meant cases where we do not exhaust all the
reclaim retries and fail early because there are no reclaimable pages
during the watermark check.

> > > Could that create problems if we have many concurrent
> > > reclaimers?
> > With increased concurrency, the likelihood of OOM will go up if we
> > remove the unlimited wait for isolated pages, that much is true.
> > 
> > I'm not sure that's a bad thing, however, because we want the OOM
> > killer to be predictable and timely. So a reasonable wait time in
> > between 0 and forever before an allocating thread gives up under
> > extreme concurrency makes sense to me.
> 
> That is a fair point, a faster OOM kill is preferable
> to a system that is livelocked.
> 
> > Unless I'm mistaken, there doesn't seem to be a whole lot of urgency
> > behind this patch. Can we think about a general model to deal with
> > allocation concurrency? Unlimited parallel direct reclaim is kinda
> > bonkers in the first place. How about checking for excessive
> > isolation
> > counts from the page allocator and putting allocations on a
> > waitqueue?
> 
> The (limited) number of reclaimers can still do a
> relatively fast OOM kill, if none of them manage
> to make progress.

well, we can estimate how much memory can those relatively few
reclaimers isolate and try to reclaim. Even if we have hundreds of them which
is more towards a large number to me then we are 100*SWAP_CLUSTER_MAX
which is not all that much. And we are effectivelly OOM if there is no
other reclaimable memory left. All we need is just to put some upper
bound. We already have throttle_direct_reclaim but it doesn't really
throttle the maximum number of reclaimers.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
