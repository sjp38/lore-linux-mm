Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 589836B023B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 14:17:49 -0400 (EDT)
Date: Wed, 5 May 2010 19:17:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100505181728.GW20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org> <20100505175311.GU20979@csn.ul.ie> <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 11:02:25AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 5 May 2010, Mel Gorman wrote:
> > 
> > If the same_vma list is properly ordered then maybe something like the
> > following is allowed?
> 
> Heh. This is the same logic I just sent out. However:
> 
> > +	anon_vma = page_rmapping(page);
> > +	if (!anon_vma)
> > +		return NULL;
> > +
> > +	spin_lock(&anon_vma->lock);
> 
> RCU should guarantee that this spin_lock() is valid, but:
> 
> > +	/*
> > +	 * Get the oldest anon_vma on the list by depending on the ordering
> > +	 * of the same_vma list setup by __page_set_anon_rmap
> > +	 */
> > +	avc = list_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
> 
> We're not guaranteed that the 'anon_vma->head' list is non-empty.
> 
> Somebody could have freed the list and the anon_vma and we have a stale 
> 'page->anon_vma' (that has just not been _released_ yet). 
> 

Ahh, fair point. I asked in the other mail was the empty list check
necessary - it is. Thanks

> And shouldn't that be 'list_first_entry'? Or &anon_vma->head.next?
> 

Should have been list_first_entry.

> How did that line actually work for you? Or was it just a "it boots", but 
> no actual testing of the rmap walk?
> 

It's currently running a migration-related stress test without any
deadlocks or lockdep wobbly so far.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
