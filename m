Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A6A386B0012
	for <linux-mm@kvack.org>; Tue, 17 May 2011 04:42:33 -0400 (EDT)
Date: Tue, 17 May 2011 09:42:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/4] mm: slub: Do not take expensive steps for SLUBs
 speculative high-order allocations
Message-ID: <20110517084227.GI5279@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
 <1305295404-12129-4-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105161411440.4353@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105161411440.4353@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Mon, May 16, 2011 at 02:16:46PM -0700, David Rientjes wrote:
> On Fri, 13 May 2011, Mel Gorman wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9f8a97b..057f1e2 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1972,6 +1972,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  {
> >  	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> >  	const gfp_t wait = gfp_mask & __GFP_WAIT;
> > +	const gfp_t can_wake_kswapd = !(gfp_mask & __GFP_NO_KSWAPD);
> >  
> >  	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
> >  	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
> > @@ -1984,7 +1985,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  	 */
> >  	alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
> >  
> > -	if (!wait) {
> > +	if (!wait && can_wake_kswapd) {
> >  		/*
> >  		 * Not worth trying to allocate harder for
> >  		 * __GFP_NOMEMALLOC even if it can't schedule.
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 98c358d..c5797ab 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1170,7 +1170,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >  	 * Let the initial higher-order allocation fail under memory pressure
> >  	 * so we fall-back to the minimum order allocation.
> >  	 */
> > -	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) & ~__GFP_NOFAIL;
> > +	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NO_KSWAPD) &
> > +			~(__GFP_NOFAIL | __GFP_WAIT | __GFP_REPEAT);
> >  
> >  	page = alloc_slab_page(alloc_gfp, node, oo);
> >  	if (unlikely(!page)) {
> 
> It's unnecessary to clear __GFP_REPEAT, these !__GFP_NOFAIL allocations 
> will immediately fail.
> 

We can enter enter direct compaction or direct reclaim
at least once. If compaction is enabled and we enter
reclaim/compaction, the presense of __GFP_REPEAT makes a difference
in should_continue_reclaim().  With compaction disabled, the presense
of the flag is relevant in should_alloc_retry() with it being possible
to loop in the allocator instead of failing the SLUB allocation and
dropping back.

Maybe you meant !__GFP_WAIT instead of !__GFP_NOFAIL which makes
more sense. In that case, we clear both flags because
__GFP_REPEAT && !_GFP_WAIT is a senseless combination of flags.
If for whatever reason the __GFP_WAIT was re-added, the presense of
__GFP_REPEAT could cause problems in reclaim that would be hard to
spot again.

> alloc_gfp would probably benefit from having a comment about why 
> __GFP_WAIT should be masked off here: that we don't want to do compaction 
> or direct reclaim or retry the allocation more than once (so both 
> __GFP_NORETRY and __GFP_REPEAT are no-ops).

That would have been helpful all right. I should have caught that
and explained it properly. In the event there is a new version of
the patch, I'll add one. For the moment, I'm dropping this patch
entirely. Christoph wants to maintain historic behaviour of SLUB to
maximise the number of high-order pages it uses and at the end of the
day, which option performs better depends entirely on the workload
and machine configuration.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
