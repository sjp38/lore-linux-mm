Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22E796B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 23:49:49 -0500 (EST)
Date: Fri, 6 Feb 2009 05:49:07 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
Message-ID: <20090206044907.GA18467@cmpxchg.org>
References: <20090206031125.693559239@cmpxchg.org> <20090206031324.004715023@cmpxchg.org> <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 06, 2009 at 12:39:22PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> I have some comment.
> 
> > File cache pages are saved to disk either through normal writeback by
> > reclaim or by including them in the suspend image written to a
> > swapfile.
> > 
> > Writing them either way should take the same amount of time but doing
> > normal writeback and unmap changes the fault behaviour on resume from
> > prefault to on-demand paging, smoothening out resume and giving
> > previously cached pages the chance to stay out of memory completely if
> > they are not used anymore.
> > 
> > Another reason for preferring file page eviction is that the locality
> > principle is visible in fault patterns and swap might perform really
> > bad with subsequent faulting of contiguously mapped pages.
> > 
> > Since anon and file pages now live on different lists, selectively
> > scanning one type only is straight-forward.
> 
> I don't understand your point.
> Which do you want to improve suspend performance or resume performance?

If there is lots of clean file cache, memory shrinking time on suspend
is fast.  In a test here, a shrink that swaps a lot had 60mb/s
throughput while a shrink on memory crowded with file cache had a
throughput of 500mb/s.

If we have to shrink n pages, aggressively shrinking the
cheap-to-evict ones is a speed improvement already.

The patch is also an improvement in suspend time becauses it doesn't
scan the anon list while it's not allowed to swap.  And what should it
do with anon pages if not swap them out? :)

But that is more a nice side effect.

> if we think suspend performance, we should consider swap device and file-backed device
> are different block device.
> the interleave of file-backed page out and swap out can improve total write out performce.

Hm, good point.  We could probably improve that but I don't think it's
too pressing because at least on my test boxen, actual shrinking time
is really short compared to the total of suspending to disk.

> if we think resume performance, we shold how think the on-disk contenious of the swap consist
> process's virtual address contenious.
> it cause to reduce unnecessary seek.
> but your patch doesn't this.
> 
> Could you explain this patch benefit?

The patch tries to shrink those pages first that are most unlikely to
be needed again after resume.  It assumes that active anon pages are
immediately needed after resume while inactive file pages are not.  So
it defers shrinking anon pages after file cache.

But I just noticed that the old behaviour defers it as well, because
even if it does scan anon pages from the beginning, it allows writing
only starting from pass 3.

I couldn't quite understand what you wrote about on-disk
contiguousness, but that claim still stands: faulting in contiguous
pages from swap can be much slower than faulting file pages.  And my
patch prefers mapped file pages over anon pages.  This is probably
where I have seen the improvements after resume in my tests.

So assuming that we can not save the whole working set, it's better to
preserve as much as possible of those pages that are the most
expensive ones to refault.

> and, I think you should mesure performence result.

Yes, I'm still thinking about ideas how to quantify it properly.  I
have not yet found a reliable way to check for whether the working set
is intact besides seeing whether the resumed applications are
responsive right away or if they first have to swap in their pages
again.

> <snip>
> 
> 
> > @@ -2134,17 +2144,17 @@ unsigned long shrink_all_memory(unsigned
> >  
> >  	/*
> >  	 * We try to shrink LRUs in 5 passes:
> > -	 * 0 = Reclaim from inactive_list only
> > -	 * 1 = Reclaim from active list but don't reclaim mapped
> > -	 * 2 = 2nd pass of type 1
> > -	 * 3 = Reclaim mapped (normal reclaim)
> > -	 * 4 = 2nd pass of type 3
> > +	 * 0 = Reclaim unmapped inactive file pages
> > +	 * 1 = Reclaim unmapped file pages
> 
> I think your patch reclaim mapped file at priority 0 and 1 too.

Doesn't the following check in shrink_page_list prevent this:

                if (!sc->may_swap && page_mapped(page))
                        goto keep_locked;

?

> > +	 * 2 = Reclaim file and inactive anon pages
> > +	 * 3 = Reclaim file and anon pages
> > +	 * 4 = Second pass 3
> >  	 */
> >  	for (pass = 0; pass < 5; pass++) {
> >  		int prio;
> >  
> > -		/* Force reclaiming mapped pages in the passes #3 and #4 */
> > -		if (pass > 2)
> > +		/* Reclaim mapped pages in higher passes */
> > +		if (pass > 1)
> >  			sc.may_swap = 1;
> 
> Why need this line?
> If you reclaim only file backed lru, may_swap isn't effective.
> So, Can't we just remove this line and always set may_swap=1 ?

Same as the above, I think mapped pages are not touched when may_swap
is 0 due to the check quoted above.  Please correct me if I'm wrong.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
