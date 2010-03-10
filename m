Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 83B536B00C6
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 21:35:26 -0500 (EST)
Date: Wed, 10 Mar 2010 13:35:15 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/3] page-allocator: Under memory pressure, wait on
 pressure to relieve instead of congestion
Message-ID: <20100310023515.GY8653@laptop>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
 <1268048904-19397-2-git-send-email-mel@csn.ul.ie>
 <20100309133513.GL8653@laptop>
 <20100309141713.GF4883@csn.ul.ie>
 <20100309150332.GP8653@laptop>
 <20100309173535.GI4883@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100309173535.GI4883@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 05:35:36PM +0000, Mel Gorman wrote:
> On Wed, Mar 10, 2010 at 02:03:32AM +1100, Nick Piggin wrote:
> > I mean the other way around. If that zone's watermarks are not met, then
> > why shouldn't it be woken up by other zones reaching their watermarks.
> > 
> 
> Doing it requires moving to a per-node structure or a global queue. I'd rather
> not add hot lines to the node structure (and the associated lookup cost in
> the free path) if I can help it. A global queue would work on smaller machines
> but I'd be worried about thundering herd problems on larger machines. I know
> congestion_wait is already a global queue but IO is a relatively slow event.
> Potentially the wakeups from this queue are a lot faster.
> 
> Should I just move to a global queue as a starting point and see what
> problems are caused later?

Yes. This should change allocation behaviours less than your patch does
now in the presence of multiple allocatees stuck in the wait with
different preferred zones.

I would worry about thundering herds as a different problem we already
have. And if wakeups are less frequent, then each one is more likely to
cause a thundering herd anyway.


> > Yep. And it doesn't really solve that race either becuase the zone
> > might subsequently go below the watermark.
> > 
> 
> True. In theory, the same sort of races currently apply with
> congestion_wait() but that's just an excuse. There is a strong
> possibility we could behave better with respect to watermarks.

We can probably avoid all races where the process sleeps too long
(ie. misses wakeups). Waking up too early and finding pages already
allocated is harder and probably can't really be solved without all
allocatees checking the waitqueue before taking pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
