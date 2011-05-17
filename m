Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EDC546B0011
	for <linux-mm@kvack.org>; Tue, 17 May 2011 19:22:38 -0400 (EDT)
Date: Tue, 17 May 2011 16:22:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
Message-Id: <20110517162226.96974d89.akpm@linux-foundation.org>
In-Reply-To: <1305614225.6008.19.camel@mulgrave.site>
References: <1305558417-24354-1-git-send-email-mgorman@suse.de>
	<1305558417-24354-3-git-send-email-mgorman@suse.de>
	<20110516141654.2728f05a.akpm@linux-foundation.org>
	<1305614225.6008.19.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mel Gorman <mgorman@suse.de>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>

On Tue, 17 May 2011 10:37:04 +0400
James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> On Mon, 2011-05-16 at 14:16 -0700, Andrew Morton wrote:
> > On Mon, 16 May 2011 16:06:57 +0100
> > Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > Under constant allocation pressure, kswapd can be in the situation where
> > > sleeping_prematurely() will always return true even if kswapd has been
> > > running a long time. Check if kswapd needs to be scheduled.
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > Acked-by: Rik van Riel <riel@redhat.com>
> > > ---
> > >  mm/vmscan.c |    4 ++++
> > >  1 files changed, 4 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index af24d1e..4d24828 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
> > >  	unsigned long balanced = 0;
> > >  	bool all_zones_ok = true;
> > >  
> > > +	/* If kswapd has been running too long, just sleep */
> > > +	if (need_resched())
> > > +		return false;
> > > +
> > >  	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
> > >  	if (remaining)
> > >  		return true;
> > 
> > I'm a bit worried by this one.
> > 
> > Do we really fully understand why kswapd is continuously running like
> > this?  The changelog makes me think "no" ;)
> > 
> > Given that the page-allocating process is madly reclaiming pages in
> > direct reclaim (yes?) and that kswapd is madly reclaiming pages on a
> > different CPU, we should pretty promptly get into a situation where
> > kswapd can suspend itself.  But that obviously isn't happening.  So
> > what *is* going on?
> 
> The triggering workload is a massive untar using a file on the same
> filesystem, so that's a continuous stream of pages read into the cache
> for the input and a stream of dirty pages out for the writes.  We
> thought it might have been out of control shrinkers, so we already
> debugged that and found it wasn't.  It just seems to be an imbalance in
> the zones that the shrinkers can't fix which causes
> sleeping_prematurely() to return true almost indefinitely.

Is the untar disk-bound?  The untar has presumably hit the writeback
dirty_ratio?  So its rate of page allocation is approximately equal to
the write speed of the disks?

If so, the VM is consuming 100% of a CPU to reclaim pages at a mere
tens-of-megabytes-per-second.  If so, there's something seriously wrong
here - under favorable conditions one would expect reclaim to free up
100,000 pages/sec, maybe more.

If the untar is not disk-bound and the required page reclaim rate is
equal to the rate at which a CPU can read, decompress and write to
pagecache then, err, maybe possible.  But it still smells of
inefficient reclaim.

> > Secondly, taking an up-to-100ms sleep in response to a need_resched()
> > seems pretty savage and I suspect it risks undesirable side-effects.  A
> > plain old cond_resched() would be more cautious.  But presumably
> > kswapd() is already running cond_resched() pretty frequently, so why
> > didn't that work?
> 
> So the specific problem with cond_resched() is that kswapd is still
> runnable, so even if there's other work the system can be getting on
> with, it quickly comes back to looping madly in kswapd.  If we return
> false from sleeping_prematurely(), we stop kswapd until its woken up to
> do more work.  This manifests, even on non sandybridge systems that
> don't hang as a lot of time burned in kswapd.
> 
> I think the sandybridge bug I see on the laptop is that cond_resched()
> is somehow ineffective:  kswapd is usually hogging one CPU and there are
> runnable processes but they seem to cluster on other CPUs, leaving
> kswapd to spin at close to 100% system time.
> 
> When the problem was first described, we tried sprinkling more
> cond_rescheds() in the shrinker loop and it didn't work.

Seems to me that kswapd for some reason is doing too much work.  Or,
more specifically is doing its work very inefficiently.  Making kswapd
take arbitrary naps when it's misbehaving didn't fix that misbehaviour!

It would be interesting to watch kswapd's page reclaim inefficiency
when this is happening: /proc/vmstat:pgscan_kswapd_* versus
/proc/vmstat:kswapd_steal.  If that ration is high then kswapd is
scanning many pages and not reclaiming them.

But given the prominence of shrink_slab in the traces, perhaps that
isn't happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
