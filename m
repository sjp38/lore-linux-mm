Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 31D4C6B0022
	for <linux-mm@kvack.org>; Tue, 24 May 2011 05:21:17 -0400 (EDT)
Date: Tue, 24 May 2011 10:21:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: vmscan: Correctly check if reclaimer should
 schedule during shrink_slab
Message-ID: <20110524092110.GE5279@suse.de>
References: <1306144435-2516-1-git-send-email-mgorman@suse.de>
 <1306144435-2516-3-git-send-email-mgorman@suse.de>
 <20110523130303.6b7dad1c.akpm@linux-foundation.org>
 <1306181256.2442.4.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1306181256.2442.4.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>

On Tue, May 24, 2011 at 12:07:36AM +0400, James Bottomley wrote:
> On Mon, 2011-05-23 at 13:03 -0700, Andrew Morton wrote:
> > On Mon, 23 May 2011 10:53:55 +0100
> > Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > It has been reported on some laptops that kswapd is consuming large
> > > amounts of CPU and not being scheduled when SLUB is enabled during
> > > large amounts of file copying. It is expected that this is due to
> > > kswapd missing every cond_resched() point because;
> > > 
> > > shrink_page_list() calls cond_resched() if inactive pages were isolated
> > >         which in turn may not happen if all_unreclaimable is set in
> > >         shrink_zones(). If for whatver reason, all_unreclaimable is
> > >         set on all zones, we can miss calling cond_resched().
> > > 
> > > balance_pgdat() only calls cond_resched if the zones are not
> > >         balanced. For a high-order allocation that is balanced, it
> > >         checks order-0 again. During that window, order-0 might have
> > >         become unbalanced so it loops again for order-0 and returns
> > >         that it was reclaiming for order-0 to kswapd(). It can then
> > >         find that a caller has rewoken kswapd for a high-order and
> > >         re-enters balance_pgdat() without ever calling cond_resched().
> > > 
> > > shrink_slab only calls cond_resched() if we are reclaiming slab
> > > 	pages. If there are a large number of direct reclaimers, the
> > > 	shrinker_rwsem can be contended and prevent kswapd calling
> > > 	cond_resched().
> > > 
> > > This patch modifies the shrink_slab() case. If the semaphore is
> > > contended, the caller will still check cond_resched(). After each
> > > successful call into a shrinker, the check for cond_resched() remains
> > > in case one shrinker is particularly slow.
> > 
> > So CONFIG_PREEMPT=y kernels don't exhibit this problem?
> 
> Yes, they do.  They just don't hang on my sandybridge system in the same
> way than non-PREEMPT kernels do.  I'm still sure it's got something to
> do with rescheduling kswapd onto a different CPU ...
> 
> > I'm still unconvinced that we know what's going on here.  What's kswapd
> > *doing* with all those cycles?  And if kswapd is now scheduling away,
> > who is doing that work instead?  Direct reclaim?
> 
> Still in the dark about this one, too.
> 

I still very strongly suspect that what gets us into this situation
is all_unreclaiable being set when there are a large bunch of dirty
pages together in the LRU pushing up the scanning rates high enough
after slab is shrunk as far as they can be at this time. Without
a local reproduction case, I'm undecided as to how this should be
investigated other than sticking in printks when all_unreclaimable
is set that outputs the number of LRU pages - anon, file and dirty
(even though this information in itself will be incomplete) and see
what falls out. I'm trying to borrow a similar laptop but haven't
found someone with a similar model yet in the locality.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
