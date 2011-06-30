Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFCE6B0082
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 05:39:40 -0400 (EDT)
Date: Thu, 30 Jun 2011 10:39:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/4] mm: vmscan: Correct check for kswapd sleeping in
 sleeping_prematurely
Message-ID: <20110630093933.GY9396@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
 <1308926697-22475-2-git-send-email-mgorman@suse.de>
 <20110628144900.b33412c6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110628144900.b33412c6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: P?draig Brady <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Jun 28, 2011 at 02:49:00PM -0700, Andrew Morton wrote:
> On Fri, 24 Jun 2011 15:44:54 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > During allocator-intensive workloads, kswapd will be woken frequently
> > causing free memory to oscillate between the high and min watermark.
> > This is expected behaviour.
> > 
> > A problem occurs if the highest zone is small.  balance_pgdat()
> > only considers unreclaimable zones when priority is DEF_PRIORITY
> > but sleeping_prematurely considers all zones. It's possible for this
> > sequence to occur
> > 
> >   1. kswapd wakes up and enters balance_pgdat()
> >   2. At DEF_PRIORITY, marks highest zone unreclaimable
> >   3. At DEF_PRIORITY-1, ignores highest zone setting end_zone
> >   4. At DEF_PRIORITY-1, calls shrink_slab freeing memory from
> >         highest zone, clearing all_unreclaimable. Highest zone
> >         is still unbalanced
> >   5. kswapd returns and calls sleeping_prematurely
> >   6. sleeping_prematurely looks at *all* zones, not just the ones
> >      being considered by balance_pgdat. The highest small zone
> >      has all_unreclaimable cleared but but the zone is not
> >      balanced. all_zones_ok is false so kswapd stays awake
> > 
> > This patch corrects the behaviour of sleeping_prematurely to check
> > the zones balance_pgdat() checked.
> 
> But kswapd is making progress: it's reclaiming slab.  Eventually that
> won't work any more and all_unreclaimable will not be cleared and the
> condition will fix itself up?
> 

It might, but at that point we've dumped as much slab as we can which
is very aggressive and there is no guarantee the condition is fixed
up. For example, if fork is happening often enough due to terminal
usage for example, it may be just enough allocation requests satisified
from the highest zone to clear all_unreclaimable during exit.

> btw,
> 
> 	if (!sleeping_prematurely(...))
> 		sleep();
> 
> hurts my brain.  My brain would prefer
> 
> 	if (kswapd_should_sleep(...))
> 		sleep();
> 
> no?
> 

kswapd_try_to_sleep -> should_sleep feel like it would hurt too. I
prefer the sleeping_prematurely name because it indicates what
condition we are checking but I'm biased and generally suck at naming.

> > Reported-and-tested-by: Padraig Brady <P@draigBrady.com>
> 
> But what were the before-and-after observations?  I don't understand
> how this can cause a permanent cpuchew by kswapd.
> 

Padraig has reported on his before-and-after observations.

On its own, this patch doesn't entirely fix his problem because all
the patches are required but I felt that a rolled-up patch would be
too hard to review.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
