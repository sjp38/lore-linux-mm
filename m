Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 176856B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 01:39:23 -0500 (EST)
Date: Wed, 10 Nov 2010 17:39:18 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101110063918.GA5782@amd>
References: <20101109123246.GA11477@amd>
 <20101110051813.GS2715@dastard>
 <20101110063229.GA5700@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110063229.GA5700@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 05:32:29PM +1100, Nick Piggin wrote:
> On Wed, Nov 10, 2010 at 04:18:13PM +1100, Dave Chinner wrote:
> > On Tue, Nov 09, 2010 at 11:32:46PM +1100, Nick Piggin wrote:
> > > Hi,
> > > 
> > > I'm doing some works that require per-zone shrinkers, I'd like to get
> > > the vmscan part signed off and merged by interested mm people, please.
> > > 
> > 
> > There are still plenty of unresolved issues with this general
> > approach to scaling object caches that I'd like to see sorted out
> > before we merge any significant shrinker API changes. Some things of
> 
> No changes, it just adds new APIs.

I might add that you've previously brought up and I answered every
single issue below and you've not followed up on my answers. So just
going back to the start and bringing them all up again is ridiculous.
Please stop it.

> > 	- it has been pointed out that slab caches are generally
> > 	  allocated out of a single zone per node, so per-zone
> > 	  shrinker granularity seems unnecessary.
> 
> No they are not, that's just total FUD. Where was that "pointed out"?
> 
> Slabs are generally allocated from every zone except for highmem and
> movable, and moreover there is nothing to prevent a shrinker
> implementation from needing to shrink highmem and movable pages as
> well.

Perhaps you meant here that many nodes have only one populated zone.
If that is _really_ a huge problem to add a couple of list heads per
zone per node (which it isn't), then the subsystem can do per-node
shrinking and just do zone_to_nid(zone) in the shrinker callback (but
that would be retarded so it shouldn't).

I answered Christoph's thread here, and I showed how a node based
callback can result in significant imbalances between zones in a node,
so it won't fly.

If you think that nodes are sufficient, then you can get patches through
mm to make pagecache reclaim per-node based, and changes to the
shirnker API will naturally propogate through.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
