Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id BF07A6B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 09:54:52 -0400 (EDT)
Date: Mon, 20 May 2013 14:54:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCHv11 2/4] zbud: add to mm/
Message-ID: <20130520135439.GR11497@suse.de>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130517154837.GN11497@suse.de>
 <20130519205219.GA3252@cerebellum>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130519205219.GA3252@cerebellum>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Sun, May 19, 2013 at 03:52:19PM -0500, Seth Jennings wrote:
> <snip>
> > >  4 files changed, 597 insertions(+)
> > > + * zbud pages are divided into "chunks".  The size of the chunks is fixed at
> > > + * compile time and determined by NCHUNKS_ORDER below.  Dividing zbud pages
> > > + * into chunks allows organizing unbuddied zbud pages into a manageable number
> > > + * of unbuddied lists according to the number of free chunks available in the
> > > + * zbud page.
> > > + *
> > 
> > Fixing the size of the chunks at compile time is a very strict
> > limitation! Distributions will have to make that decision for all workloads
> > that might conceivably use zswap. Having the allocator only deal with pairs
> > of pages limits the worst-case behaviour where reclaim can generate lots of
> > IO to free a single physical page. However, the chunk size directly affects
> > the fragmentation properties, both internal and external, of this thing.
> 
> > Once NCHUNKS is > 2 it is possible to create a workload that externally
> > fragments this allocator such that each physical page only holds one
> > compressed page. If this is a problem for a user then their only option
> > is to rebuild the kernel which is not always possible.
> 
> You lost me here.  Do you mean NCHUNKS > 2 or NCHUNKS_ORDER > 2?
> 

NCHUNKS

> My first guess is that the external fragmentation situation you are referring to
> is a workload in which all pages compress to greater than half a page.  If so,
> then it doesn't matter what NCHUCNKS_ORDER is, there won't be any pages the
> compress enough to fit in the < PAGE_SIZE/2 free space that remains in the
> unbuddied zbud pages.
> 

There are numerous aspects to this, too many to write them all down.
Modelling the external fragmentation one and how it affects swap IO
would be a complete pain in the ass so lets consider the following
example instead as it's a bit clearer.

Three processes. Process A compresses by 75%, Process B compresses to 15%,
Process C pages compress to 15%. They are all adding to zswap in lockstep.
Lets say that zswap can hold 100 physical pages.

NCHUNKS == 2
	All Process A pages get rejected.
	All Process B and C pages get added to zswap until zswap fills
	Zswap fills 300 allocation requests
		Swap IO is 33 physical pages (all process A rejects)
	Process B and C see no swap IO

NCHUNKS == 6
	Zswap fills after 100 allocation requests
		zswap holds 200 compressed pages
	All other requests go to swap.

If both configurations were to compare each other for 300 allocation
requests, NCHUNKS==6 results in more swap IO with a mix of page writes
from A, B and C than if NCHUNKS==2.

This obviously is overly simplistic because it's ignoring writeback and
how that will impact page avalability and I didn't model what it would
look like for arbitrarily long request strings. The point is that the
value of NCHUNKS affects the amount of swap IO and when it kicks in. A
higher NCHUNKS might defer when swap IO starts but when it starts, it may
be continual. A lower NCHUNKS might start writing to swap earlier but in
some cases will result in less swap IO overall.

> You might also be referring to the fact that if you set NCHUNKS_ORDER to 2
> (i.e. there are 4 chunks per zbud page) and you receive an allocation for size
> (3/4 * PAGE_SIZE) + 1, the allocator will use all 4 chunks for that allocation
> and the rest of the zbud page is lost to internal fragmentation.
> 

I'm less ocncerned about internal fragmentation because there are only
ever 2 compressed page in a single physical page. The internal
fragmentation characteristics are going to suck no matter what.

> That is simply an argument for not choosing a small NCHUNKS_ORDER.
> 
> > 
> > Please make this configurable by a kernel boot parameter at least. At
> > a glance it looks like only problem would be that you have to kmalloc
> > unbuddied[NCHUNKS] in the pool structure but that is hardly of earth
> > shattering difficulty. Make the variables read_mostly to avoid cache-line
> > bouncing problems.
> 
> I am hesitant to make this a tunable without understanding why anyone would
> want to tune it.  It's hard to convey to a user what this tunable would do and
> what effect it might have.  I'm not saying that isn't such a situation.
> I just don't see one didn't understand your case above.
> 

I would only expect the tunable to be used by a developer supporting a user
of zswap that complains about zswap-related stalls. They would be checking
what the rate of swap IO is with default nchunks vs nchunks==2.  They would
not necessarily be able to do anything useful with this information until
they were willing to develop zswap. There would be no recommended value
for this because it's completely workload dependant but data gathered from
the tunable could potentially be used to justify the full zsmalloc allocator.

> > > +struct zbud_pool {
> > > +	spinlock_t lock;
> > > +	struct list_head unbuddied[NCHUNKS];
> > > +	struct list_head buddied;
> > > +	struct list_head lru;
> > > +	atomic_t pages_nr;
> > 
> > There is no need for pages_nr to be atomic. It's always manipulated
> > under the lock. I see that the atomic is exported so someone can read it
> > that is outside the lock but they are goign to have to deal with races
> > anyway. atomic does not magically protect them
> 
> True.  I'll change it.
> 
> > 
> > Also, pages_nr does not appear to be the number of zbud pages in the pool,
> > it's the number of zpages. You may want to report both for debugging
> > purposes as if nr_zpages != 2 * nr_zbud_pages then zswap is using more
> > physical pages than it should be.
> 
> No, pages_nr is the number of pool pages, not zpages.  The number of zpages (or
> allocations from zbud's point of view) is easily trackable by the user as it
> does each allocation.  What the user can not know is how many pages are in the
> pool.  Hence why zbud tracks this stat and makes it accessible via
> zbud_get_pool_size().
> 

Bah, I missed up my terminiology. When I wrote this, I thought zbud must
be a "buddy" page or a compressed page. Bit confusing but it'll settle
in eventually.

> > > +/*
> > > + * Encodes the handle of a particular buddy within a zbud page
> > > + * Pool lock should be held as this function accesses first|last_chunks
> > > + */
> > > +static inline unsigned long encode_handle(struct zbud_page *zbpage,
> > > +					enum buddy bud)
> > > +{
> > > +	unsigned long handle;
> > > +
> > > +	/*
> > > +	 * For now, the encoded handle is actually just the pointer to the data
> > > +	 * but this might not always be the case.  A little information hiding.
> > > +	 */
> > > +	handle = (unsigned long)page_address(&zbpage->page);
> > > +	if (bud == FIRST)
> > > +		return handle;
> > > +	handle += PAGE_SIZE - (zbpage->last_chunks  << CHUNK_SHIFT);
> > > +	return handle;
> > > +}
> > 
> > Your handles are unsigned long and are addresses. Consider making it an
> > opaque type so someone deferencing it would take a special kind of
> > stupid.
> 
> My argument for keeping the handles as unsigned longs is a forward-looking
> to the implementation of the pluggable allocator interface in zswap.
> Typing the handles prevents the creation of an allocator neutral function
> signature.
> 

I don't see how but I don't know what your forward-looking
implementation looks like either so I'll take your word for it.

> > > +	zbpage = NULL;
> > > +	for_each_unbuddied_list(i, chunks) {
> > > +		if (!list_empty(&pool->unbuddied[i])) {
> > > +			zbpage = list_first_entry(&pool->unbuddied[i],
> > > +					struct zbud_page, buddy);
> > > +			list_del(&zbpage->buddy);
> > > +			if (zbpage->first_chunks == 0)
> > > +				bud = FIRST;
> > > +			else
> > > +				bud = LAST;
> > > +			goto found;
> > > +		}
> > > +	}
> > > +
> > > +	/* Lastly, couldn't find unbuddied zbpage, create new one */
> > > +	spin_unlock(&pool->lock);
> > > +	page = alloc_page(gfp);
> > > +	if (!page)
> > > +		return -ENOMEM;
> > > +	spin_lock(&pool->lock);
> > > +	atomic_inc(&pool->pages_nr);
> > > +	zbpage = init_zbud_page(page);
> > > +	bud = FIRST;
> > > +
> > 
> > What bounds the size of the pool? Maybe a higher layer does but should the
> > higher layer set the maximum size and enforce it here instead? That way the
> > higher layer does not need to know that the allocator is dealing with pages.
> 
> I see your point.  The higher layer would have to set the limit in some
> units, likely pages, so it would be aware that zbud is using pages.
> 

I don't think the higher layer necessarily has to inform zbud.

> However, zswap (or any user) would probably make an initial determination of
> the limit in pages. Then would have to register a notifier for anything that
> could change the memory size (i.e. memory add/remove) and adjust the zbud
> limit.
> 

To be honest, I would have expected zbud to set the limit as it's the
allocator. I would also expect it to register the notifier for hotplug
events because it's the allocator that knows how many physical pages are
used. The higher layer should not necessarily care about how many pages
are in use.

> I guess a different way would be to set the zbud limit as a percentage, then
> zbud could automatically adjust when the amount of ram changes, doing a
> per-allocation limit check.
> 
> Any thoughts about those options?
> 

Nothing specific, just the general observation that the allocator is
what is responsible for the physical resource and deferring the sizing
of it to a higher layer will complicate the API.

> <snip>
> > > +	spin_lock(&pool->lock);
> > > +	zbpage = handle_to_zbud_page(handle);
> > > +
> > > +	/* If first buddy, handle will be page aligned */
> > > +	if (handle & ~PAGE_MASK)
> > > +		zbpage->last_chunks = 0;
> > > +	else
> > > +		zbpage->first_chunks = 0;
> > > +
> > > +	if (PageReclaim(&zbpage->page)) {
> > > +		/* zbpage is under reclaim, reclaim will free */
> > > +		spin_unlock(&pool->lock);
> > > +		return;
> > > +	}
> > > +
> > 
> > This implies that it is possible for a zpage to get freed twice. That
> > sounds wrong. It sounds like a page being reclaimed should be isolated
> > from other lists that makes it accessible similar to how normal pages are
> > isolated from the LRU and then freed.
> 
> No, a zpage will not be freed twice.
> 
> The problem is that even if zbud isolates the page in it's structures,
> which it does now removing from the buddied/unbuddied and lru list, there is no
> way to isolate it in the _users_ data structures.  Once we release the pool
> lock, a free could still come in from the user.
> 

That sounds very fragile although I cannot point my finger on exactly
why. I worry that depending on the ordering of events that we might leak
pages although again I cannot point to exactly where this would happen.

> However, the user should have protections in place in it's eviction handler that
> prevent two cases:
> 
> 1) If the user entry associated with the allocation being evicted has already
> been freed, the eviction handler should just return 0 (already freed)
> 
> 2) If the user entry lookup in the eviction handler is successful, some
> lock/refcount must protect the entry and its associated zbud allocation from
> being freed while it is being evicted.
> 
> <snip>
> > > +	for (i = 0; i < retries; i++) {
> > > +		zbpage = list_tail_entry(&pool->lru, struct zbud_page, lru);
> > > +		list_del(&zbpage->lru);
> > > +		list_del(&zbpage->buddy);
> > > +		/* Protect zbpage against free */
> > > +		SetPageReclaim(&zbpage->page);
> > 
> > Why not isolated it instead of using a page flag?
> 
> Same reason as above, can't isolate in the user structure.

Because I cannot point to exactly where this can go to hell I will not
object to this longer but it feels like zpages should be reference
counted and get freed (potentially freeing the zbud page) when it drops
to zero.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
