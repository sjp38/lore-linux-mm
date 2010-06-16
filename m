Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B09236B01AD
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 19:38:03 -0400 (EDT)
Date: Wed, 16 Jun 2010 16:37:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 05/12] vmscan: kill prev_priority completely
Message-Id: <20100616163709.1e0f6b56.akpm@linux-foundation.org>
In-Reply-To: <1276514273-27693-6-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-6-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 2010 12:17:46 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Since 2.6.28 zone->prev_priority is unused. Then it can be removed
> safely. It reduce stack usage slightly.
> 
> Now I have to say that I'm sorry. 2 years ago, I thought prev_priority
> can be integrate again, it's useful. but four (or more) times trying
> haven't got good performance number. Thus I give up such approach.

This would have been badder in earlier days when we were using the
scanning priority to decide when to start unmapping pte-mapped pages -
page reclaim would have been recirculating large blobs of mapped pages
around the LRU until the priority had built to the level where we
started to unmap them.

However that priority-based decision got removed and right now I don't
recall what it got replaced with.  Aren't we now unmapping pages way
too early and suffering an increased major&minor fault rate?  Worried.


Things which are still broken after we broke prev_priority:

- If page reclaim is having a lot of trouble, prev_priority would
  have permitted do_try_to_free_pages() to call disable_swap_token()
  earlier on.  As things presently stand, we'll do a lot of
  thrash-detection stuff before (presumably correctly) dropping the
  swap token.

  So.  What's up with that?  I don't even remember _why_ we disable
  the swap token once the scanning priority gets severe and the code
  comments there are risible.  And why do we wait until priority==0
  rather than priority==1?

- Busted prev_priority means that lumpy reclaim will act oddly. 
  Every time someone goes into do some recalim, they'll start out not
  doing lumpy reclaim.  Then, after a while, they'll get a clue and
  will start doing the lumpy thing.  Then they return from reclaim and
  the next recalim caller will again forget that he should have done
  lumpy reclaim.

  I dunno what the effects of this are in the real world, but it
  seems dumb.

And one has to wonder: if we're making these incorrect decisions based
upon a bogus view of the current scanning difficulty, why are these
various priority-based thresholding heuristics even in there?  Are they
doing anything useful?

So..  either we have a load of useless-crap-and-cruft in there which
should be lopped out, or we don't have a load of useless-crap-and-cruft
in there, and we should fix prev_priority.

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/mmzone.h |   15 ------------
>  mm/page_alloc.c        |    2 -
>  mm/vmscan.c            |   57 ------------------------------------------------
>  mm/vmstat.c            |    2 -

The patch forgot to remove mem_cgroup_get_reclaim_priority() and friends.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
