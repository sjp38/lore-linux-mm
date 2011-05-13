Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06AED6B0011
	for <linux-mm@kvack.org>; Fri, 13 May 2011 11:52:35 -0400 (EDT)
Date: Fri, 13 May 2011 16:52:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Reduce impact to overall system of SLUB using
 high-order allocations V2
Message-ID: <20110513155229.GJ3569@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
 <1305299984.2611.37.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1305299984.2611.37.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, May 13, 2011 at 10:19:44AM -0500, James Bottomley wrote:
> On Fri, 2011-05-13 at 15:03 +0100, Mel Gorman wrote:
> > Changelog since V1
> >   o kswapd should sleep if need_resched
> >   o Remove __GFP_REPEAT from GFP flags when speculatively using high
> >     orders so direct/compaction exits earlier
> >   o Remove __GFP_NORETRY for correctness
> >   o Correct logic in sleeping_prematurely
> >   o Leave SLUB using the default slub_max_order
> > 
> > There are a few reports of people experiencing hangs when copying
> > large amounts of data with kswapd using a large amount of CPU which
> > appear to be due to recent reclaim changes.
> > 
> > SLUB using high orders is the trigger but not the root cause as SLUB
> > has been using high orders for a while. The following four patches
> > aim to fix the problems in reclaim while reducing the cost for SLUB
> > using those high orders.
> > 
> > Patch 1 corrects logic introduced by commit [1741c877: mm:
> > 	kswapd: keep kswapd awake for high-order allocations until
> > 	a percentage of the node is balanced] to allow kswapd to
> > 	go to sleep when balanced for high orders.
> > 
> > Patch 2 prevents kswapd waking up in response to SLUBs speculative
> > 	use of high orders.
> > 
> > Patch 3 further reduces the cost by prevent SLUB entering direct
> > 	compaction or reclaim paths on the grounds that falling
> > 	back to order-0 should be cheaper.
> > 
> > Patch 4 notes that even when kswapd is failing to keep up with
> > 	allocation requests, it should still go to sleep when its
> > 	quota has expired to prevent it spinning.
> 
> This all works fine for me ... three untar runs and no kswapd hangs or
> pegging the CPU at 99% ... in fact, kswapd rarely gets over 20%
> 

Good stuff, thanks.

> This isn't as good as the kswapd sleeping_prematurely() throttling
> patch. For total CPU time on a three 90GB untar run, it's about 64s of
> CPU time with your patch rather than 6s, but that's vastly better than
> the 15 minutes of CPU time kswapd was taking even under PREEMPT.
> 

The throttling patch is unfortunately a bit hand-wavy based on number of
times it's entered and time passed. It'll be even harder to debug
problems related to this in the future particularly as it's using global
information (a static) for kswapd (per-node which could be worse in the
future depending on what memcg do).

However, as you are testing against stable, can you also apply this
patch? [2876592f: mm: vmscan: stop reclaim/compaction earlier due to
insufficient progress if !__GFP_REPEAT]. It makes a difference as to
when reclaimers give up on high-orders and go to sleep.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
