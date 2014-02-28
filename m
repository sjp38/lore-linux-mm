Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 163136B0073
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:45:05 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id r20so476886wiv.10
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 03:45:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dl5si1353652wib.47.2014.02.28.03.45.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 03:45:04 -0800 (PST)
Date: Fri, 28 Feb 2014 11:45:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/2] mm: page_alloc: reset aging cycle with GFP_THISNODE
Message-ID: <20140228114501.GN6732@suse.de>
References: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org>
 <20140226095422.GY6732@suse.de>
 <20140226171206.GU6963@cmpxchg.org>
 <20140226201333.GV6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140226201333.GV6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Stancek <jstancek@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 26, 2014 at 03:13:33PM -0500, Johannes Weiner wrote:
> On Wed, Feb 26, 2014 at 12:12:06PM -0500, Johannes Weiner wrote:
> > On Wed, Feb 26, 2014 at 09:54:22AM +0000, Mel Gorman wrote:
> > > How about special casing the (alloc_flags & ALLOC_WMARK_LOW) check in
> > > get_page_from_freelist to also ignore GFP_THISNODE? The NR_ALLOC_BATCH
> > > will go further negative if there are storms of GFP_THISNODE allocations
> > > forcing other allocations into the slow path doing multiple calls to
> > > prepare_slowpath but it would be closer to current behaviour and avoid
> > > weirdness with kswapd.
> > 
> > I think the result would be much uglier.  The allocations wouldn't
> > participate in the fairness protocol, and they'd create work for
> > kswapd without waking it up, diminishing the latency reduction for
> > which we have kswapd in the first place.
> > 
> > If kswapd wakeups should be too aggressive, I'd rather we ratelimit
> > them in some way rather than exempting random order-0 allocation types
> > as a moderation measure.  Exempting higher order wakeups, like THP
> > does is one thing, but we want order-0 watermarks to be met at all
> > times anyway, so it would make sense to me to nudge kswapd for every
> > failing order-0 request.
> 
> So I'd still like to fix this and wake kswapd even for GFP_THISNODE
> allocations, but let's defer it for now in favor of a minimal bugfix
> that can be ported to -stable.
> 
> Would this be an acceptable replacement for 1/2?
> 
> ---
> 
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch 1/2] mm: page_alloc: exempt GFP_THISNODE allocations from zone
>  fairness
> 
> Jan Stancek reports manual page migration encountering allocation
> failures after some pages when there is still plenty of memory free,
> and bisected the problem down to 81c0a2bb515f ("mm: page_alloc: fair
> zone allocator policy").
> 
> The problem is that GFP_THISNODE obeys the zone fairness allocation
> batches on one hand, but doesn't reset them and wake kswapd on the
> other hand.  After a few of those allocations, the batches are
> exhausted and the allocations fail.
> 
> Fixing this means either having GFP_THISNODE wake up kswapd, or
> GFP_THISNODE not participating in zone fairness at all.  The latter
> seems safer as an acute bugfix, we can clean up later.
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@kernel.org> # 3.12+

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
