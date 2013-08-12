Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0339F6B0036
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 18:15:40 -0400 (EDT)
Date: Mon, 12 Aug 2013 18:15:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/9] mm: thrash detection-based file cache sizing v3
Message-ID: <20130812221524.GU715@cmpxchg.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
 <20130809155309.71d93380425ef8e19c0ff44c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130809155309.71d93380425ef8e19c0ff44c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 09, 2013 at 03:53:09PM -0700, Andrew Morton wrote:
> On Tue,  6 Aug 2013 18:44:01 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > This series solves the problem by maintaining a history of pages
> > evicted from the inactive list, enabling the VM to tell streaming IO
> > from thrashing and rebalance the page cache lists when appropriate.
> 
> Looks nice. The lack of testing results is conspicuous ;)
> 
> It only really solves the problem in the case where
> 
> 	size-of-inactive-list < size-of-working-set < size-of-total-memory
> 
> yes?  In fact less than that, because the active list presumably
> doesn't get shrunk to zero (how far *can* it go?).

It can theoretically shrink to 0 if the replacing working set needs
exactly 100% of the available memory and is perfectly sequential and
the page allocator is 100% fair.  So in practice, it probably won't.

It's more likely that after some active pages have been deactivated
and pushed out of memory that new pages get a chance to get activated
so there will always be some pages on the active list.

> I wonder how many workloads fit into those constraints in the real
> world.

If the working set exceeds memory and the reference frequency is the
same for each page in the set, there is nothing we can reasonably do
to cache.

If the working set exceeds memory and all reference distances are
bigger than memory but not all equal to each other, it would be great
to be able to detect the more frequently used pages and prefer
reclaiming the others over them.  But I don't think that's actually
possible without a true LRU algorithm (as opposed to our
approximation) because we would need to know about reference distances
in the active page list and compare them to the refault distances.

So yes, this algorithm is limited to interpreting reference distances
up to memory size.

The development of this was kicked off by actual bug reports and I'm
working with the reporters to get these patches tested in the
production environments that exhibited the problem.  The reporters
always had usecases where the working set should have fit into memory
but wasn't cached even after repeatedly referencing it, that's why
they complained in the first place.  So it's hard to tell how many
environments fall into this category, but they certainly do exist,
they are not unreasonable setups, and the behavior is pretty abysmal
(most accesses major faults when everything should fit in memory).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
