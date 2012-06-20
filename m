Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 6222D6B006C
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 09:37:02 -0400 (EDT)
Date: Wed, 20 Jun 2012 14:36:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/17] net: Do not coalesce skbs belonging to PFMEMALLOC
 sockets
Message-ID: <20120620133656.GH4011@suse.de>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
 <1340192652-31658-9-git-send-email-mgorman@suse.de>
 <1340193892.4604.865.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1340193892.4604.865.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

On Wed, Jun 20, 2012 at 02:04:52PM +0200, Eric Dumazet wrote:
> On Wed, 2012-06-20 at 12:44 +0100, Mel Gorman wrote:
> > Commit [bad43ca8: net: introduce skb_try_coalesce()] introduced an
> > optimisation to coalesce skbs to reduce memory usage and cache line
> > misses. In the case where the socket is used for swapping this can result
> > in a warning like the following.
> > 
> > [  110.476565] nbd0: page allocation failure: order:0, mode:0x20
> > [  110.476568] Pid: 2714, comm: nbd0 Not tainted 3.5.0-rc2-swapnbd-v12r2-slab #3
> > [  110.476569] Call Trace:
> > [  110.476573]  [<ffffffff811042d3>] warn_alloc_failed+0xf3/0x160
> > [  110.476578]  [<ffffffff81107c92>] __alloc_pages_nodemask+0x6e2/0x930
> >
> > <SNIP
> >  
> 
> 
> This makes absolutely no sense to me.
> 
> This patch changes input path, while your stack trace is about output
> path and a packet being fragmented.
> 

The intention was to avoid any coalescing in the input path due to avoid
packets that "were held back due to TCP_CORK or attempt at coalescing
tiny packet". I recognise that it is clumsy and will take the approach
instead of having __tcp_push_pending_frames() use sk_gfp_atomic() in the
output path.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
