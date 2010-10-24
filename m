Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B49276B0071
	for <linux-mm@kvack.org>; Sat, 23 Oct 2010 21:31:39 -0400 (EDT)
Date: Sun, 24 Oct 2010 12:31:33 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101024013133.GA3168@amd>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
 <20101021235854.GD3270@amd>
 <20101022155513.GA26790@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101022155513.GA26790@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@kernel.dk>, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 11:55:13AM -0400, Christoph Hellwig wrote:
> On Fri, Oct 22, 2010 at 10:58:54AM +1100, Nick Piggin wrote:
> > Again, I really think it needs to be per zone. Something like inode
> > cache could still have lots of allocations in ZONE_NORMAL with plenty
> > of memory free there, but a DMA zone shortage could cause it to trash
> > the caches.
> 
> I think making shrinking decision per-zone is fine.  But do we need to
> duplicate all the lru lists and infrastructure per-zone for that instead
> of simply per-zone?

No, they don't. As you can see, less important shrinkers can even
continue to do global scanning. But per-zone is the right abstraction
for the API.

>   Even with per-node lists we can easily skip over
> items from the wrong zone.

It's possible, but that would make things more complex, considering
that you don't have statistics etc in the zone.

Consider:

zone X has a shortage. zone X is in node 0, along with several more
zones.

Pagecache scan 10% of zone X, which is 5% of the total memory. Give
this information to the shrinker.

Shrinker has to make some VM assumptions like "zone X has the shortage,
but we only have lists for node 0, so let's scan 5% of node 0 objects
because we know there is another zone in there with more memory, but
just skip other zones on the node".

But then if there were fewer objects in other zones, it doesn't scan
enough (in the extreme case, 0 objects on other nodes, it scans only
half the required objects on zone X).

Then it has also trashed the LRU position of the other zones in the
node when it skipped over them -- if the shortage was actually in
both the zones, the first scan for zone X would trash the LRU, only
to have to scan again.


> Given that we have up to 6 zones per node currently, and we would mostly
> use one with a few fallbacks that seems like a lot of overkill.

A handful of words per zone? A list head, a couple of stats, and a lock?
Worrying about memory consumption for that and adding strange complexity
to the shrinker is totally the wrong tradeoff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
