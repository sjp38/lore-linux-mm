Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 73F0B90010B
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:25:56 -0400 (EDT)
Date: Thu, 12 May 2011 19:25:14 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/3] mm: slub: Do not take expensive steps for SLUBs
 speculative high-order allocations
Message-ID: <20110512172514.GI11579@random.random>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
 <1305127773-10570-3-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105111312020.9346@chino.kir.corp.google.com>
 <20110511211043.GB17898@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110511211043.GB17898@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

Hi,

On Wed, May 11, 2011 at 10:10:43PM +0100, Mel Gorman wrote:
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index 98c358d..1071723 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -1170,7 +1170,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> > >  	 * Let the initial higher-order allocation fail under memory pressure
> > >  	 * so we fall-back to the minimum order allocation.
> > >  	 */
> > > -	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) & ~__GFP_NOFAIL;
> > > +	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) &
> > > +			~(__GFP_NOFAIL | __GFP_WAIT);
> > 
> > __GFP_NORETRY is a no-op without __GFP_WAIT.
> > 
> 
> True. I'll remove it in a V2 but I won't respin just yet.

Nothing wrong and no performance difference with clearing
__GFP_NORETRY too, if something it doesn't make sense for a caller to
use __GFP_NOFAIL without __GFP_WAIT so the original version above
looks cleaner. I like this change overall to only poll the buddy
allocator without spinning kswapd and without invoking lumpy reclaim.

Like you noted in the first mail, compaction was disabled, and very
bad behavior is expected without it unless GFP_ATOMIC|__GFP_NO_KSWAPD
is set (that was the way I had to use before disabling lumpy
compaction when first developing THP too for the same reasons).

But when compaction enabled slub could try to only clear __GFP_NOFAIL
and leave __GFP_WAIT and no bad behavior should happen... but it's
probably slower so I prefer to clear __GFP_WAIT too (for THP
compaction is worth it because the allocation is generally long lived,
but for slub allocations like tiny skb the allocation can be extremely
short lived so it's unlikely to be worth it). So this way compaction
is then invoked only by the minimal order allocation later if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
