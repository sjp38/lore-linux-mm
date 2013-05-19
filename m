Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A7BFD6B0037
	for <linux-mm@kvack.org>; Sun, 19 May 2013 19:33:30 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Sun, 19 May 2013 17:33:29 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 5C5183E4003F
	for <linux-mm@kvack.org>; Sun, 19 May 2013 17:33:10 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4JNXQhF126068
	for <linux-mm@kvack.org>; Sun, 19 May 2013 17:33:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4JNXPAV031656
	for <linux-mm@kvack.org>; Sun, 19 May 2013 17:33:26 -0600
Date: Sun, 19 May 2013 18:33:18 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
Message-ID: <20130519233318.GB3252@cerebellum>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130517165418.GP11497@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130517165418.GP11497@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Fri, May 17, 2013 at 05:54:18PM +0100, Mel Gorman wrote:
> On Mon, May 13, 2013 at 07:40:02AM -0500, Seth Jennings wrote:
> > zswap is a thin compression backend for frontswap. It receives pages from
> > frontswap and attempts to store them in a compressed memory pool, resulting in
> > an effective partial memory reclaim and dramatically reduced swap device I/O.
> > 
> 
> potentially reduces IO. No guarantees.

Sorry, I was in marketing mode I guess.

> > Additionally, in most cases, pages can be retrieved from this compressed store
> > much more quickly than reading from tradition swap devices resulting in faster
> > performance for many workloads.
> > 
> 
> While this is likely, it's also not necessarily true if the swap device
> is particularly fast. Also, swap devices can be asynchronously written,
> is the same true for zswap? I doubt it as I would expect the compression
> operation to slow down pages being added to swap cache.

Same here.

The compression happens synchronously at pageout() time, more precisely the
frontswap_store() in swap_writepage().  The advantage here is that pages
synchronously stored in zswap can be immediately reclaimed in
shrink_page_list().

> 
> > It also has support for evicting swap pages that are currently compressed in
> > zswap to the swap device on an LRU(ish) basis.
> 
> I know I initially suggested an LRU but don't worry about this thing
> being an LRU too much. A FIFO list would be just fine as the pages are
> presumably idle if they ended up in zswap in the first place.

The LRU stuff is already in zbud and doesn't add much complexity.  It is
cheap and understandable so may as well do it I figure.  You'll have to
select a page one way or another.  May as well be consistent with the
rest of the MM.

<snip>
> > +/*********************************
> > +* statistics
> > +**********************************/
> > +/* Number of memory pages used by the compressed pool */
> > +static atomic_t zswap_pool_pages = ATOMIC_INIT(0);
> 
> They underlying allocator should be tracking the number of physical
> pages used, not this layer.

zbud does track the number of pool pages.  This variable just mirrors the zbud
value when it has the potential to change so that it is accessible in the zswap
debugfs.

However, since the conversion to zbud, this atomic isn't inc/dec anymore,
just set, so no need to be atomic.

> 
> > +/* The number of compressed pages currently stored in zswap */
> > +static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
> > +
> > +/*
> > + * The statistics below are not protected from concurrent access for
> > + * performance reasons so they may not be a 100% accurate.  However,
> > + * they do provide useful information on roughly how many times a
> > + * certain event is occurring.
> > +*/
> > +static u64 zswap_pool_limit_hit;
> > +static u64 zswap_written_back_pages;
> > +static u64 zswap_reject_reclaim_fail;
> > +static u64 zswap_reject_compress_poor;
> > +static u64 zswap_reject_alloc_fail;
> > +static u64 zswap_reject_kmemcache_fail;
> > +static u64 zswap_duplicate_entry;
> > +
> 
> Document what these mean.

Will do.

> 
> > +/*********************************
> > +* tunables
> > +**********************************/
> > +/* Enable/disable zswap (disabled by default, fixed at boot for now) */
> > +static bool zswap_enabled;
> 
> read_mostly

Yep.

> 
> > +module_param_named(enabled, zswap_enabled, bool, 0);
> > +
> > +/* Compressor to be used by zswap (fixed at boot for now) */
> > +#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> > +static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
> > +module_param_named(compressor, zswap_compressor, charp, 0);
> > +
> > +/* The maximum percentage of memory that the compressed pool can occupy */
> > +static unsigned int zswap_max_pool_percent = 20;
> > +module_param_named(max_pool_percent,
> > +			zswap_max_pool_percent, uint, 0644);
> > +
> 
> This will need additional love in the future. If you have an 8 node machine
> then zswap pool could completely exhaust a single NUMA node with this
> parameter. This is pretty much a big fat hammer that stops zswap getting
> compltely out of control and taking over the system but it'll need some
> sort of sensible automatic resizing based on system activity in the future.
> It's not an obstacle to merging because you have to start somewhere but
> the fixed-pool size thing is fugly and you should plan on putting it down
> in the future.

Agreed, it is a starting point and making this policy better and NUMA-aware
is at the top of my TODO list.

> 
> > +/*
> > + * Maximum compression ratio, as as percentage, for an acceptable
> > + * compressed page. Any pages that do not compress by at least
> > + * this ratio will be rejected.
> > +*/
> > +static unsigned int zswap_max_compression_ratio = 80;
> > +module_param_named(max_compression_ratio,
> > +			zswap_max_compression_ratio, uint, 0644);
> > +
> 
> I would be very surprised if a user wanted to tune this. What is a sensible
> recommendation for it? I don't think you can give one because it depends
> entirely on the workload and the current system state. A good value for
> one day may be a bad choice the next day if a backup takes place or the
> workload changes pattern frequently.  As there is no sensible recommendation
> for this value, just don't expose it to userspace at all.

Agreed, this mattered more for zsmalloc.  Upon reexamination, this should
be done in the allocator.  If the allocator can't (optimally) store the
compressed page, it can just return -E2BIG and zswap will increment
zswap_reject_compress_poor.

> 
> I guess you could apply the same critism to the suggestion that NCHUNKS
> be tunable but that has only two settings really. The default and 2 if
> the pool is continually fragmented.

I think you might be misunderstanding NCHUNKS.  NCHUNKS is the number of
chunks per zbud page.  If you set NCHUNKS to 2, zbud basically won't be
able to pair and buddy that is larger than PAGE_SIZE/2.

> 
> > +/*********************************
> > +* compression functions
> > +**********************************/
> > <SNIP>
> 
> I'm glossed over a lot of this. It looks fairly similar to what was reviewed
> before and I'm assuming there are no major changes. Much of it is in the
> category of "it'll either work or fail spectacularly early in the lifetime
> of the system" and I'm assuming you tested this. Note that the comments
> are out of sync with the structures. Fix that.

Yes, you said this before and I forgot to pick it up.  Sorry :-/
> 
> > +/*********************************
> > +* helpers
> > +**********************************/
> > +static inline bool zswap_is_full(void)
> > +{
> > +	int pool_pages = atomic_read(&zswap_pool_pages);
> 
> Does this thing really have to be an atomic? Why not move it into the tree
> structure, protect it with the tree lock and then sum the individual counts
> when checking if zswap_is_full? It'll be a little race but not much more
> so than using atomics outside of a lock like this.

When zswap was doing the accounting with zsmalloc it did need to be atomic
but not anymore. I'll fix it up.

> > + * zswap_get_swap_cache_page
> > + *
> > + * This is an adaption of read_swap_cache_async()
> > + *
> > + * This function tries to find a page with the given swap entry
> > + * in the swapper_space address space (the swap cache).  If the page
> > + * is found, it is returned in retpage.  Otherwise, a page is allocated,
> > + * added to the swap cache, and returned in retpage.
> > + *
> > + * If success, the swap cache page is returned in retpage
> > + * Returns 0 if page was already in the swap cache, page is not locked
> > + * Returns 1 if the new page needs to be populated, page is locked
> > + * Returns <0 on error
> > + */
> 
> Still not massively happy that this is duplicating code from
> read_swap_cache_async(). It's just begging for trouble. I do not have
> suggestions on how it can be done cleanly at this time because I haven't
> put the effort in.

Yes, how to reuse the code here isn't a trivial thing, but I can look
again how if and how it could be done cleanly.

<snip>
> > +	};
> > +
> > +	/* extract swpentry from data */
> > +	zhdr = zbud_map(pool, handle);
> > +	swpentry = zhdr->swpentry; /* here */
> > +	zbud_unmap(pool, handle);
> > +	tree = zswap_trees[swp_type(swpentry)];
> 
> This is going to further solidify the use of PTEs to store the swap file
> and offset for swap pages that Hugh complained about at LSF/MM. It's
> unfortunate but it's not like there is queue of people waiting to fix
> that particular problem :(

Yes, but there are a lot of places that will have to be updated I imagine.
This will just be one more.  I for one, wouldn't mind undertaking that
improvement (swap entry abstraction layer). But that's for another day.

 
> > +	offset = swp_offset(swpentry);
> > +	BUG_ON(pool != tree->pool);
> > +
> > +	/* find and ref zswap entry */
> > +	spin_lock(&tree->lock);
> > +	entry = zswap_rb_search(&tree->rbroot, offset);
> > +	if (!entry) {
> > +		/* entry was invalidated */
> > +		spin_unlock(&tree->lock);
> > +		return 0;
> > +	}
> > +	zswap_entry_get(entry);
> > +	spin_unlock(&tree->lock);
> > +	BUG_ON(offset != entry->offset);
> > +
> > +	/* try to allocate swap cache page */
> > +	switch (zswap_get_swap_cache_page(swpentry, &page)) {
> > +	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
> > +		ret = -ENOMEM;
> > +		goto fail;
> > +
> 
> Yikes. So it's possible to fail a zpage writeback? Can this livelock? I
> expect you are protected by a combination of the 20% memory limitation
> and that it is likely that *some* file pages can be reclaimed but this
> is going to cause a bug report eventually. Consider using a mempool to
> guarantee that some writeback progress can always be made.

If the reclaim fails here, then the overall store operation just fails and the
page is written to swap as if zswap wasn't there But this happens VERY rarely
since we are using GFP_KERNEL.

If you are talking about the allocation in zswap_get_swap_cache_page()
resulting in a swap_writepage() that calls back down this path I've never seen
that but can't explain exactly why it isn't possible.

What if we used GFP_NOIO, that way shrink_page_list() wouldn't swap out
addition pages in response to an allocation for zswap writeback?  If the zone
is congested with dirty pages then this might fail more often.  I'd have to try
it out.

What do you think?  Or have I completely misunderstood your concern?

> > +	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
> > +		/* page is already in the swap cache, ignore for now */
> > +		page_cache_release(page);
> > +		ret = -EEXIST;
> > +		goto fail;
> > +
> > +	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
> > +		/* decompress */
> > +		dlen = PAGE_SIZE;
> > +		src = (u8 *)zbud_map(tree->pool, entry->handle) +
> > +			sizeof(struct zswap_header);
> > +		dst = kmap_atomic(page);
> > +		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src,
> > +				entry->length, dst, &dlen);
> > +		kunmap_atomic(dst);
> > +		zbud_unmap(tree->pool, entry->handle);
> > +		BUG_ON(ret);
> > +		BUG_ON(dlen != PAGE_SIZE);
> > +
> > +		/* page is up to date */
> > +		SetPageUptodate(page);
> > +	}
> > +
> > +	/* start writeback */
> > +	SetPageReclaim(page);
> > +	__swap_writepage(page, &wbc, end_swap_bio_write);
> > +	page_cache_release(page);
> > +	zswap_written_back_pages++;
> > +
> 
> SetPageReclaim? Why?. If the page is under writeback then why do you not
> mark it as that? Do not free pages that are currently under writeback
> obviously.

You're right, no need to set Reclaim here.  Not sure why I had that there.
__swap_writeback() sets the writeback flag.

> It's likely that it was PageWriteback you wanted in zbud.c too.

In zbud, the reclaim flag is just being repurposed for internal use.

<snip>
> > +	/* reclaim space if needed */
> > +	if (zswap_is_full()) {
> > +		zswap_pool_limit_hit++;
> > +		if (zbud_reclaim_page(tree->pool, 8)) {
> > +			zswap_reject_reclaim_fail++;
> > +			ret = -ENOMEM;
> > +			goto reject;
> > +		}
> > +	}
> > +
> 
> If the allocator layer handled the sizing limitations then you could defer
> the size checks until it calls alloc_page. From a layering perspective
> this would be a hell of a lot cleaner. As it is, this layer has excessive
> knowledge of the zbud layer which feels wrong.

Ok.  I responded to this in the zbud patch thread.  Short rehash, yes it could
work.  Just how will the limit be expressed (and updated if needed)?

> > +	/* allocate entry */
> > +	entry = zswap_entry_cache_alloc(GFP_KERNEL);
> > +	if (!entry) {
> > +		zswap_reject_kmemcache_fail++;
> > +		ret = -ENOMEM;
> > +		goto reject;
> > +	}
> > +
> > +	/* compress */
> > +	dst = get_cpu_var(zswap_dstmem);
> > +	src = kmap_atomic(page);
> > +	ret = zswap_comp_op(ZSWAP_COMPOP_COMPRESS, src, PAGE_SIZE, dst, &dlen);
> > +	kunmap_atomic(src);
> > +	if (ret) {
> > +		ret = -EINVAL;
> > +		goto freepage;
> > +	}
> > +	len = dlen + sizeof(struct zswap_header);
> > +	if ((len * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
> > +		zswap_reject_compress_poor++;
> > +		ret = -E2BIG;
> > +		goto freepage;
> > +	}
> > +
> > +	/* store */
> > +	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
> > +		&handle);
> 
> You do all the compression work and then check if you can store it?
> It's harmless, but it's a little silly. Do the alloc work first and push
> the sizing checks down a layer to the time you call alloc_pages.

You don't know how large the zbud allocation needs to be until after you've
actually compressed the page.

<snip>
> > +MODULE_LICENSE("GPL");
> > +MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
> > +MODULE_DESCRIPTION("Compressed cache for swap pages");
> 
> I think there is still a lot of ugly in here so see what you can fix up
> quickly. It's not mandatory to me that you get all this fixed up prior
> to merging because it's long gone past the point where dealing with it
> out-of-tree or in staging is going to work. By the time you address all the
> concerns, it will have reached the point where it's too complex to review
> and back to square one. At least if it's in mm/ it can be incrementally
> developed but it should certainly start with a big fat warning that it's
> a WIP. I wouldn't slap "ready for production" sticker on this just yet :/

We are in agreement on all points.  I'll send out the revised patchset
ASAP.

Thanks for the review!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
