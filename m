Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 7CAFF6B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 10:18:39 -0400 (EDT)
Date: Wed, 20 Jun 2012 15:18:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/17] net: Do not coalesce skbs belonging to PFMEMALLOC
 sockets
Message-ID: <20120620141833.GI4011@suse.de>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
 <1340192652-31658-9-git-send-email-mgorman@suse.de>
 <1340193892.4604.865.camel@edumazet-glaptop>
 <20120620133656.GH4011@suse.de>
 <1340200312.4604.1008.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1340200312.4604.1008.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

On Wed, Jun 20, 2012 at 03:51:52PM +0200, Eric Dumazet wrote:
> On Wed, 2012-06-20 at 14:36 +0100, Mel Gorman wrote:
> > The intention was to avoid any coalescing in the input path due to avoid
> > packets that "were held back due to TCP_CORK or attempt at coalescing
> > tiny packet". I recognise that it is clumsy and will take the approach
> > instead of having __tcp_push_pending_frames() use sk_gfp_atomic() in the
> > output path.
> 
> But coalescing in input path needs no additional memory allocation, it
> can actually free some memory.
> 

When I wrote it I thought the timing of the transmission of pending frames
was the problem rather than the actual memory usage. My intention was that
any data related to swapping be handled immediately without delay instead of
deferring until a time when GFP_ATOMIC allocations might fail. I arrived
at this patch because tcp_input.c does call tcp_push_pending_frames()
on the receive path and that led me to believe that coalescing was a
factor.

> And it avoids most of the time the infamous "tcp collapses" that needed
> extra memory allocations to group tcp payload on single pages.
> 
> If you want tcp output path being safer, you should disable TSO/GSO
> because some drivers have special handling for skbs that cannot be
> mapped because of various hardware limitations.
> 

Understood. Thanks for the explanation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
