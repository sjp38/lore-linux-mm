Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id B1FED6B0036
	for <linux-mm@kvack.org>; Sun, 19 May 2013 16:52:31 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Sun, 19 May 2013 16:52:30 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 86CD2C90042
	for <linux-mm@kvack.org>; Sun, 19 May 2013 16:52:27 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4JKqRaA44892268
	for <linux-mm@kvack.org>; Sun, 19 May 2013 16:52:27 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4JKqQcG031934
	for <linux-mm@kvack.org>; Sun, 19 May 2013 16:52:27 -0400
Date: Sun, 19 May 2013 15:52:19 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv11 2/4] zbud: add to mm/
Message-ID: <20130519205219.GA3252@cerebellum>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130517154837.GN11497@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130517154837.GN11497@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Fri, May 17, 2013 at 04:48:37PM +0100, Mel Gorman wrote:
> On Mon, May 13, 2013 at 07:40:01AM -0500, Seth Jennings wrote:
> > zbud is an special purpose allocator for storing compressed pages. It is
> > designed to store up to two compressed pages per physical page.  While this
> > design limits storage density, it has simple and deterministic reclaim
> > properties that make it preferable to a higher density approach when reclaim
> > will be used.
> > 
> > zbud works by storing compressed pages, or "zpages", together in pairs in a
> > single memory page called a "zbud page".  The first buddy is "left
> > justifed" at the beginning of the zbud page, and the last buddy is "right
> > justified" at the end of the zbud page.  The benefit is that if either
> > buddy is freed, the freed buddy space, coalesced with whatever slack space
> > that existed between the buddies, results in the largest possible free region
> > within the zbud page.
> > 
> > zbud also provides an attractive lower bound on density. The ratio of zpages
> > to zbud pages can not be less than 1.  This ensures that zbud can never "do
> > harm" by using more pages to store zpages than the uncompressed zpages would
> > have used on their own.
> > 
> > This patch adds zbud to mm/ for later use by zswap.
> > 
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> I'm not familiar with the code in staging/zcache/zbud.c and this looks
> like a rewrite but I'm curious, why was an almost complete rewrite
> necessary? The staging code looks like it had debugfs statistics and
> the like that would help figure how well the packing was working and so
> on. I guess it was probably because it was integrated tightly with other
> components in staging but could that not be torn out? I'm guessing you
> have a good reason but it'd be nice to see that in the changelog.

I'll add a bit about that.

<snip>
> >  4 files changed, 597 insertions(+)
> > + * zbud pages are divided into "chunks".  The size of the chunks is fixed at
> > + * compile time and determined by NCHUNKS_ORDER below.  Dividing zbud pages
> > + * into chunks allows organizing unbuddied zbud pages into a manageable number
> > + * of unbuddied lists according to the number of free chunks available in the
> > + * zbud page.
> > + *
> 
> Fixing the size of the chunks at compile time is a very strict
> limitation! Distributions will have to make that decision for all workloads
> that might conceivably use zswap. Having the allocator only deal with pairs
> of pages limits the worst-case behaviour where reclaim can generate lots of
> IO to free a single physical page. However, the chunk size directly affects
> the fragmentation properties, both internal and external, of this thing.

> Once NCHUNKS is > 2 it is possible to create a workload that externally
> fragments this allocator such that each physical page only holds one
> compressed page. If this is a problem for a user then their only option
> is to rebuild the kernel which is not always possible.

You lost me here.  Do you mean NCHUNKS > 2 or NCHUNKS_ORDER > 2?

My first guess is that the external fragmentation situation you are referring to
is a workload in which all pages compress to greater than half a page.  If so,
then it doesn't matter what NCHUCNKS_ORDER is, there won't be any pages the
compress enough to fit in the < PAGE_SIZE/2 free space that remains in the
unbuddied zbud pages.

You might also be referring to the fact that if you set NCHUNKS_ORDER to 2
(i.e. there are 4 chunks per zbud page) and you receive an allocation for size
(3/4 * PAGE_SIZE) + 1, the allocator will use all 4 chunks for that allocation
and the rest of the zbud page is lost to internal fragmentation.

That is simply an argument for not choosing a small NCHUNKS_ORDER.

> 
> Please make this configurable by a kernel boot parameter at least. At
> a glance it looks like only problem would be that you have to kmalloc
> unbuddied[NCHUNKS] in the pool structure but that is hardly of earth
> shattering difficulty. Make the variables read_mostly to avoid cache-line
> bouncing problems.

I am hesitant to make this a tunable without understanding why anyone would
want to tune it.  It's hard to convey to a user what this tunable would do and
what effect it might have.  I'm not saying that isn't such a situation.
I just don't see one didn't understand your case above.

> 
> Finally, because a review would never be complete without a bitching
> session about names -- I don't like the name zbud. Buddy allocators take
> a large block of memory and split it iteratively (by halves for binary
> buddy allocators but there are variations) until it's a best fit for the
> allocation request. A key advantage of such schemes is fast searching for
> free holes. That's not what this allocator does and as the page allocator
> is a binary buddy allocator in Linux, calling this this a buddy allocator
> is a bit misleading. Looks like the existing zbud.c also has this problem
> but hey.  This thing is a first-fit segmented free list allocator with
> sub-allocator properties in that it takes fixed-sized blocks as inputs and
> splits them into pairs, not a buddy allocator. That characterisation does
> not lend itself to a snappy name but calling it zpair or something would
> be slightly less misleading than calling it a buddy allocator.

I agree that is it not a buddy allocator and the name is misleading.
zpair is fine with me.

> 
> First Fit Segmented-list Allocator for in-Kernel comprEssion (FFSAKE)? :/

Well played :)  For real though, I think that First Fit Segmented-List is
the most accurate description.  ffsl.c?  Just a thought.  I'm fine with
zpair too.

<snip> 
> > +struct zbud_pool {
> > +	spinlock_t lock;
> > +	struct list_head unbuddied[NCHUNKS];
> > +	struct list_head buddied;
> > +	struct list_head lru;
> > +	atomic_t pages_nr;
> 
> There is no need for pages_nr to be atomic. It's always manipulated
> under the lock. I see that the atomic is exported so someone can read it
> that is outside the lock but they are goign to have to deal with races
> anyway. atomic does not magically protect them

True.  I'll change it.

> 
> Also, pages_nr does not appear to be the number of zbud pages in the pool,
> it's the number of zpages. You may want to report both for debugging
> purposes as if nr_zpages != 2 * nr_zbud_pages then zswap is using more
> physical pages than it should be.

No, pages_nr is the number of pool pages, not zpages.  The number of zpages (or
allocations from zbud's point of view) is easily trackable by the user as it
does each allocation.  What the user can not know is how many pages are in the
pool.  Hence why zbud tracks this stat and makes it accessible via
zbud_get_pool_size().

In the case of zswap, the debugfs attributes stored_pages/pool_pages will give
you the density metric, albeit in a non-atomic way.

<snip>
> > +/* Initializes a zbud page from a newly allocated page */
> > +static inline struct zbud_page *init_zbud_page(struct page *page)
> > +{
> > +	struct zbud_page *zbpage = (struct zbud_page *)page;
> > +	zbpage->first_chunks = 0;
> > +	zbpage->last_chunks = 0;
> > +	INIT_LIST_HEAD(&zbpage->buddy);
> > +	INIT_LIST_HEAD(&zbpage->lru);
> > +	return zbpage;
> > +}
> 
> No need to inline. Only has one caller so the compiler will figure it
> out.

Ok.

> 
> > +
> > +/* Resets a zbud page so that it can be properly freed  */
> > +static inline struct page *reset_zbud_page(struct zbud_page *zbpage)
> > +{
> > +	struct page *page = &zbpage->page;
> > +	set_page_private(page, 0);
> > +	page->mapping = NULL;
> > +	page->index = 0;
> > +	page_mapcount_reset(page);
> > +	init_page_count(page);
> > +	INIT_LIST_HEAD(&page->lru);
> > +	return page;
> > +}
> 
> This is only used for freeing so call it free_zbud_page and have it call
> __free_page for clarity. Also, this is a bit long for inlining.

Ah yes, much cleaner.

> 
> > +
> > +/*
> > + * Encodes the handle of a particular buddy within a zbud page
> > + * Pool lock should be held as this function accesses first|last_chunks
> > + */
> > +static inline unsigned long encode_handle(struct zbud_page *zbpage,
> > +					enum buddy bud)
> > +{
> > +	unsigned long handle;
> > +
> > +	/*
> > +	 * For now, the encoded handle is actually just the pointer to the data
> > +	 * but this might not always be the case.  A little information hiding.
> > +	 */
> > +	handle = (unsigned long)page_address(&zbpage->page);
> > +	if (bud == FIRST)
> > +		return handle;
> > +	handle += PAGE_SIZE - (zbpage->last_chunks  << CHUNK_SHIFT);
> > +	return handle;
> > +}
> 
> Your handles are unsigned long and are addresses. Consider making it an
> opaque type so someone deferencing it would take a special kind of
> stupid.

My argument for keeping the handles as unsigned longs is a forward-looking
to the implementation of the pluggable allocator interface in zswap.
Typing the handles prevents the creation of an allocator neutral function
signature.

Maybe I'm overlooking an easy solution here.

<snip>
> > + * zbud_create_pool() - create a new zbud pool
> > + * @gfp:	gfp flags when allocating the zbud pool structure
> > + * @ops:	user-defined operations for the zbud pool
> > + *
> > + * Return: pointer to the new zbud pool or NULL if the metadata allocation
> > + * failed.
> > + */
> > +struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
> > +{
> > +	struct zbud_pool *pool;
> > +	int i;
> > +
> > +	pool = kmalloc(sizeof(struct zbud_pool), gfp);
> > +	if (!pool)
> > +		return NULL;
> > +	spin_lock_init(&pool->lock);
> > +	for_each_unbuddied_list(i, 0)
> > +		INIT_LIST_HEAD(&pool->unbuddied[i]);
> > +	INIT_LIST_HEAD(&pool->buddied);
> > +	INIT_LIST_HEAD(&pool->lru);
> > +	atomic_set(&pool->pages_nr, 0);
> > +	pool->ops = ops;
> > +	return pool;
> > +}
> > +EXPORT_SYMBOL_GPL(zbud_create_pool);
> > +
> 
> Why the export? It doesn't look like this thing is going to be consumed
> by modules.

This is true for now,  I'll remove them.  Can always add them back later
and save additions to the KABI in the meantime.

<snip> 
> > +int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> > +			unsigned long *handle)
> > +{
> > +	int chunks, i, freechunks;
> > +	struct zbud_page *zbpage = NULL;
> > +	enum buddy bud;
> > +	struct page *page;
> > +
> > +	if (size <= 0 || size > PAGE_SIZE || gfp & __GFP_HIGHMEM)
> > +		return -EINVAL;
> > +	chunks = size_to_chunks(size);
> > +	spin_lock(&pool->lock);
> > +
> > +	/*
> > +	 * First, try to use the zbpage we last used (at the head of the
> > +	 * LRU) to increase LRU locality of the buddies. This is first fit.
> > +	 */
> > +	if (!list_empty(&pool->lru)) {
> > +		zbpage = list_first_entry(&pool->lru, struct zbud_page, lru);
> > +		if (num_free_chunks(zbpage) >= chunks) {
> > +			if (zbpage->first_chunks == 0) {
> > +				list_del(&zbpage->buddy);
> > +				bud = FIRST;
> > +				goto found;
> > +			}
> > +			if (zbpage->last_chunks == 0) {
> > +				list_del(&zbpage->buddy);
> > +				bud = LAST;
> > +				goto found;
> > +			}
> > +		}
> > +	}
> > +
> > +	/* Second, try to find an unbuddied zbpage. This is best fit. */
> 
> No it isn't, it's also first fit.

Ok.

> 
> Give for_each_unbuddied_list() additional smarts to always start with
> the last zbpage that was used and collapse these two block of code
> together and call it first-fit.

I've removed the try the "last page used" logic since I am, at this
time, not able to demonstrate that it improves anything.

Without the contrast, I'll just refrain from any comment about the
fit type.

> > +	zbpage = NULL;
> > +	for_each_unbuddied_list(i, chunks) {
> > +		if (!list_empty(&pool->unbuddied[i])) {
> > +			zbpage = list_first_entry(&pool->unbuddied[i],
> > +					struct zbud_page, buddy);
> > +			list_del(&zbpage->buddy);
> > +			if (zbpage->first_chunks == 0)
> > +				bud = FIRST;
> > +			else
> > +				bud = LAST;
> > +			goto found;
> > +		}
> > +	}
> > +
> > +	/* Lastly, couldn't find unbuddied zbpage, create new one */
> > +	spin_unlock(&pool->lock);
> > +	page = alloc_page(gfp);
> > +	if (!page)
> > +		return -ENOMEM;
> > +	spin_lock(&pool->lock);
> > +	atomic_inc(&pool->pages_nr);
> > +	zbpage = init_zbud_page(page);
> > +	bud = FIRST;
> > +
> 
> What bounds the size of the pool? Maybe a higher layer does but should the
> higher layer set the maximum size and enforce it here instead? That way the
> higher layer does not need to know that the allocator is dealing with pages.

I see your point.  The higher layer would have to set the limit in some
units, likely pages, so it would be aware that zbud is using pages.

However, zswap (or any user) would probably make an initial determination of
the limit in pages.  Then would have to register a notifier for anything that
could change the memory size (i.e. memory add/remove) and adjust the zbud
limit.

I guess a different way would be to set the zbud limit as a percentage, then
zbud could automatically adjust when the amount of ram changes, doing a
per-allocation limit check.

Any thoughts about those options?

<snip>
> > +	spin_lock(&pool->lock);
> > +	zbpage = handle_to_zbud_page(handle);
> > +
> > +	/* If first buddy, handle will be page aligned */
> > +	if (handle & ~PAGE_MASK)
> > +		zbpage->last_chunks = 0;
> > +	else
> > +		zbpage->first_chunks = 0;
> > +
> > +	if (PageReclaim(&zbpage->page)) {
> > +		/* zbpage is under reclaim, reclaim will free */
> > +		spin_unlock(&pool->lock);
> > +		return;
> > +	}
> > +
> 
> This implies that it is possible for a zpage to get freed twice. That
> sounds wrong. It sounds like a page being reclaimed should be isolated
> from other lists that makes it accessible similar to how normal pages are
> isolated from the LRU and then freed.

No, a zpage will not be freed twice.

The problem is that even if zbud isolates the page in it's structures,
which it does now removing from the buddied/unbuddied and lru list, there is no
way to isolate it in the _users_ data structures.  Once we release the pool
lock, a free could still come in from the user.

However, the user should have protections in place in it's eviction handler that
prevent two cases:

1) If the user entry associated with the allocation being evicted has already
been freed, the eviction handler should just return 0 (already freed)

2) If the user entry lookup in the eviction handler is successful, some
lock/refcount must protect the entry and its associated zbud allocation from
being freed while it is being evicted.

<snip>
> > +	for (i = 0; i < retries; i++) {
> > +		zbpage = list_tail_entry(&pool->lru, struct zbud_page, lru);
> > +		list_del(&zbpage->lru);
> > +		list_del(&zbpage->buddy);
> > +		/* Protect zbpage against free */
> > +		SetPageReclaim(&zbpage->page);
> 
> Why not isolated it instead of using a page flag?

Same reason as above, can't isolate in the user structure.

Thanks for the review!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
