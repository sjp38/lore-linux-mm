Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id ABF106B014B
	for <linux-mm@kvack.org>; Wed, 29 May 2013 11:45:20 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 29 May 2013 09:45:19 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B767BC90045
	for <linux-mm@kvack.org>; Wed, 29 May 2013 11:45:16 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4TFjGcY305874
	for <linux-mm@kvack.org>; Wed, 29 May 2013 11:45:16 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4TFj78i031217
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:45:12 -0600
Date: Wed, 29 May 2013 10:45:00 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv12 2/4] zbud: add to mm/
Message-ID: <20130529154500.GB428@cerebellum>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, May 28, 2013 at 02:59:11PM -0700, Andrew Morton wrote:
> On Mon, 20 May 2013 11:26:06 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> 
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
> > This implementation is a rewrite of the zbud allocator internally used
> > by zcache in the driver/staging tree.  The rewrite was necessary to
> > remove some of the zcache specific elements that were ingrained throughout
> > and provide a generic allocation interface that can later be used by
> > zsmalloc and others.
> > 
> > This patch adds zbud to mm/ for later use by zswap.
> > 
> > ...
> >
> > +/**
> > + * struct zbud_page - zbud page metadata overlay
> > + * @page:	typed reference to the underlying struct page
> > + * @donotuse:	this overlays the page flags and should not be used
> > + * @first_chunks:	the size of the first buddy in chunks, 0 if free
> > + * @last_chunks:	the size of the last buddy in chunks, 0 if free
> > + * @buddy:	links the zbud page into the unbuddied/buddied lists in the pool
> > + * @lru:	links the zbud page into the lru list in the pool
> > + *
> > + * This structure overlays the struct page to store metadata needed for a
> > + * single storage page in for zbud.  There is a BUILD_BUG_ON in zbud_init()
> > + * that ensures this structure is not larger that struct page.
> > + *
> > + * The PG_reclaim flag of the underlying page is used for indicating
> > + * that this zbud page is under reclaim (see zbud_reclaim_page())
> > + */
> > +struct zbud_page {
> > +	union {
> > +		struct page page;
> > +		struct {
> > +			unsigned long donotuse;
> > +			u16 first_chunks;
> > +			u16 last_chunks;
> > +			struct list_head buddy;
> > +			struct list_head lru;
> > +		};
> > +	};
> > +};
> 
> Whoa.  So zbud scribbles on existing pageframes?

Yes.

> 
> Please tell us about this, in some detail.  How is it done and why is
> this necessary?
> 
> Presumably the pageframe must be restored at some stage, so this code
> has to be kept in sync with external unrelated changes to core MM?

Yes, this is done in free_zbud_page().

> 
> Why was it implemented in this fashion rather than going into the main
> `struct page' definition and adding the appropriate unionised fields?

Yes, modifying the struct page is the cleaner way.  I thought that adding more
convolution to struct page would create more friction on the path to getting
this merged.  Plus overlaying the struct page was the approach used by zsmalloc
and so I was thinking more along these lines.

If you'd rather add the zbud fields directly into unions in struct page,
I'm ok with that if you are.

Of course, this doesn't avoid having to reset the fields for the page allocator
before we free them.  Even slub/slob reset the mapcount before calling
__free_page(), for example.

> 
> I worry about any code which independently looks at the pageframe
> tables and expects to find page struts there.  One example is probably
> memory_failure() but there are probably others.
> 
> > 
> > ...
> >
> > +int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> > +			unsigned long *handle)
> > +{
> > +	int chunks, i, freechunks;
> > +	struct zbud_page *zbpage = NULL;
> > +	enum buddy bud;
> > +	struct page *page;
> > +
> > +	if (size <= 0 || gfp & __GFP_HIGHMEM)
> > +		return -EINVAL;
> > +	if (size > PAGE_SIZE)
> > +		return -E2BIG;
> 
> Means "Argument list too long" and isn't appropriate here.

Ok, I need a return value other than -EINVAL to convey to the user that the
allocation is larger than what the allocator can hold. I don't see an existing
errno that would be more suited for that.  Do you have a suggestion?

> 
> > +	chunks = size_to_chunks(size);
> > +	spin_lock(&pool->lock);
> > +
> > +	/* First, try to find an unbuddied zbpage. */
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
> > +	/* Couldn't find unbuddied zbpage, create new one */
> > +	spin_unlock(&pool->lock);
> > +	page = alloc_page(gfp);
> > +	if (!page)
> > +		return -ENOMEM;
> > +	spin_lock(&pool->lock);
> > +	pool->pages_nr++;
> > +	zbpage = init_zbud_page(page);
> > +	bud = FIRST;
> > +
> > +found:
> > +	if (bud == FIRST)
> > +		zbpage->first_chunks = chunks;
> > +	else
> > +		zbpage->last_chunks = chunks;
> > +
> > +	if (zbpage->first_chunks == 0 || zbpage->last_chunks == 0) {
> > +		/* Add to unbuddied list */
> > +		freechunks = num_free_chunks(zbpage);
> > +		list_add(&zbpage->buddy, &pool->unbuddied[freechunks]);
> > +	} else {
> > +		/* Add to buddied list */
> > +		list_add(&zbpage->buddy, &pool->buddied);
> > +	}
> > +
> > +	/* Add/move zbpage to beginning of LRU */
> > +	if (!list_empty(&zbpage->lru))
> > +		list_del(&zbpage->lru);
> > +	list_add(&zbpage->lru, &pool->lru);
> > +
> > +	*handle = encode_handle(zbpage, bud);
> > +	spin_unlock(&pool->lock);
> > +
> > +	return 0;
> > +}
> > 
> > ...
> >
> > +int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
> > +{
> > +	int i, ret, freechunks;
> > +	struct zbud_page *zbpage;
> > +	unsigned long first_handle = 0, last_handle = 0;
> > +
> > +	spin_lock(&pool->lock);
> > +	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
> > +			retries == 0) {
> > +		spin_unlock(&pool->lock);
> > +		return -EINVAL;
> > +	}
> > +	for (i = 0; i < retries; i++) {
> > +		zbpage = list_tail_entry(&pool->lru, struct zbud_page, lru);
> > +		list_del(&zbpage->lru);
> > +		list_del(&zbpage->buddy);
> > +		/* Protect zbpage against free */
> 
> Against free by who?  What other code paths can access this page at
> this time?

zbud has no way of serializing with the user (zswap) to prevent it calling
zbud_free() during zbud reclaim.  To prevent the zbud page from being freed
while reclaim is operating on it, we set the reclaim flag in the struct page.
zbud_free() checks this flag and, if set, only sets the chunk length of the
allocation to 0, but does not actually free the zbud page.  That is left to
this reclaim path.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
