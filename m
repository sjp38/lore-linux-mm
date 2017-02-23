Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE1526B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:21:27 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id s27so11668104wrb.5
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 23:21:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si4891676wrt.162.2017.02.22.23.21.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 23:21:26 -0800 (PST)
Date: Thu, 23 Feb 2017 08:21:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm/vmscan: fix high cpu usage of kswapd if there
Message-ID: <20170223072120.5herkdrum3t4l223@dhcp22.suse.cz>
References: <1487754288-5149-1-git-send-email-hejianet@gmail.com>
 <20170222201657.GA6534@cmpxchg.org>
 <28d09cda-e020-8289-1b1f-e19fbd3b3aeb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28d09cda-e020-8289-1b1f-e19fbd3b3aeb@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hejianet <hejianet@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Thu 23-02-17 10:46:01, hejianet wrote:
> sorry, resend it due to a delivery-failure:
> "Wrong MIME labeling on 8-bit character texts"
> I am sorry if anybody received it twice
> ------------
> Hi Johannes
> On 23/02/2017 4:16 AM, Johannes Weiner wrote:
> > On Wed, Feb 22, 2017 at 05:04:48PM +0800, Jia He wrote:
> > > When I try to dynamically allocate the hugepages more than system total
> > > free memory:
> > 
> > > Then the kswapd will take 100% cpu for a long time(more than 3 hours, and
> > > will not be about to end)
> > 
> > > The root cause is kswapd3 is trying to do relaim again and again but it
> > > makes no progress
> > 
> > > At that time, there are no relaimable pages in that node:
> > 
> > Yes, this is a problem with the current kswapd code.
> > 
> > A less artificial scenario that I observed recently was machines with
> > two NUMA nodes, after being up for 200+ days, getting into a state
> > where node0 is mostly consumed by anon and some kernel allocations,
> > leaving less than the high watermark free. The machines don't have
> > swap, so the anon isn't reclaimable. But also, anon LRU is never even
> > *scanned*, so the "all unreclaimable" logic doesn't kick in. Kswapd is
> > spinning at 100% CPU calculating scan counts and checking zone states.
> > 
> > One specific problem with your patch, Jia, is that there might be some
> > cache pages that are pinned one way or another. That was the case on
> > our machines, and so reclaimable pages wasn't 0. Even if we check the
> > reclaimable pages, we need a hard cutoff after X attempts. And then it
> > sounds pretty much like what the allocator/direct reclaim already does.
> > 
> > Can we use the *exact* same cutoff conditions for direct reclaim and
> > kswapd, though? I don't think so. For direct reclaim, the goal is the
> > watermark, to make an allocation happen in the caller. While kswapd
> > tries to restore the watermarks too, it might never meet them but
> > still do useful work on behalf of concurrently allocating threads. It
> > should only stop when it tries and fails to free any pages at all.
> > 
> Yes, this is what I thought before this patchi 1/4 ?but seems Michal
> doesn't like this idea :)
> Please see https://lkml.org/lkml/2017/1/24/543

Yeah, I didn't like the hard limit on kswapd retries as you proposed it.
It didn't make much sense to me because the current condition for kswapd
to back off is to have all zones balanced. Without further criterion
kswapd would just wake up and go around the same retry loops again with
no progress. I didn't realize that a direct reclaim progress might be
that criterion. Proposal from Johannes makes much more sense. I have to
think about it some more but this looks like a way forward.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
