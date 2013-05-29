Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 7B6E36B00D5
	for <linux-mm@kvack.org>; Wed, 29 May 2013 16:42:46 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 29 May 2013 16:42:44 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6BE166E8040
	for <linux-mm@kvack.org>; Wed, 29 May 2013 16:42:38 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4TKgfoR321724
	for <linux-mm@kvack.org>; Wed, 29 May 2013 16:42:41 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4TKgeq8026129
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:42:41 -0300
Date: Wed, 29 May 2013 15:42:36 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv12 2/4] zbud: add to mm/
Message-ID: <20130529204236.GD428@cerebellum>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org>
 <20130529154500.GB428@cerebellum>
 <20130529113434.b2ced4cc1e66c7a0a520d908@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529113434.b2ced4cc1e66c7a0a520d908@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, May 29, 2013 at 11:34:34AM -0700, Andrew Morton wrote:
> On Wed, 29 May 2013 10:45:00 -0500 Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> 
> > > > +struct zbud_page {
> > > > +	union {
> > > > +		struct page page;
> > > > +		struct {
> > > > +			unsigned long donotuse;
> > > > +			u16 first_chunks;
> > > > +			u16 last_chunks;
> > > > +			struct list_head buddy;
> > > > +			struct list_head lru;
> > > > +		};
> > > > +	};
> > > > +};
> > > 
> > > Whoa.  So zbud scribbles on existing pageframes?
> > 
> > Yes.
> > 
> > > 
> > > Please tell us about this, in some detail.  How is it done and why is
> > > this necessary?
> > > 
> > > Presumably the pageframe must be restored at some stage, so this code
> > > has to be kept in sync with external unrelated changes to core MM?
> > 
> > Yes, this is done in free_zbud_page().
> > 
> > > 
> > > Why was it implemented in this fashion rather than going into the main
> > > `struct page' definition and adding the appropriate unionised fields?
> > 
> > Yes, modifying the struct page is the cleaner way.  I thought that adding more
> > convolution to struct page would create more friction on the path to getting
> > this merged.  Plus overlaying the struct page was the approach used by zsmalloc
> > and so I was thinking more along these lines.
> 
> I'd be interested in seeing what the modifications to struct page look
> like.  It really is the better way.

I'll do it then.

> 
> > If you'd rather add the zbud fields directly into unions in struct page,
> > I'm ok with that if you are.
> > 
> > Of course, this doesn't avoid having to reset the fields for the page allocator
> > before we free them.  Even slub/slob reset the mapcount before calling
> > __free_page(), for example.
> > 
> > > 
> > > I worry about any code which independently looks at the pageframe
> > > tables and expects to find page struts there.  One example is probably
> > > memory_failure() but there are probably others.
> 
> ^^ this, please.  It could be kinda fatal.

I'll look into this.

The expected behavior is that memory_failure() should handle zbud pages in the
same way that it handles in-use slub/slab/slob pages and return -EBUSY.

> 
> > > > 
> > > > ...
> > > >
> > > > +int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> > > > +			unsigned long *handle)
> > > > +{
> > > > +	int chunks, i, freechunks;
> > > > +	struct zbud_page *zbpage = NULL;
> > > > +	enum buddy bud;
> > > > +	struct page *page;
> > > > +
> > > > +	if (size <= 0 || gfp & __GFP_HIGHMEM)
> > > > +		return -EINVAL;
> > > > +	if (size > PAGE_SIZE)
> > > > +		return -E2BIG;
> > > 
> > > Means "Argument list too long" and isn't appropriate here.
> > 
> > Ok, I need a return value other than -EINVAL to convey to the user that the
> > allocation is larger than what the allocator can hold. I don't see an existing
> > errno that would be more suited for that.  Do you have a suggestion?
> 
> ENOMEM perhaps.  That's also somewhat misleading, but I guess there's
> precedent for ENOMEM meaning "allocation too large" as well as "out
> of memory".

Works for me.

> 
> > > > +int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
> > > > +{
> > > > +	int i, ret, freechunks;
> > > > +	struct zbud_page *zbpage;
> > > > +	unsigned long first_handle = 0, last_handle = 0;
> > > > +
> > > > +	spin_lock(&pool->lock);
> > > > +	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
> > > > +			retries == 0) {
> > > > +		spin_unlock(&pool->lock);
> > > > +		return -EINVAL;
> > > > +	}
> > > > +	for (i = 0; i < retries; i++) {
> > > > +		zbpage = list_tail_entry(&pool->lru, struct zbud_page, lru);
> > > > +		list_del(&zbpage->lru);
> > > > +		list_del(&zbpage->buddy);
> > > > +		/* Protect zbpage against free */
> > > 
> > > Against free by who?  What other code paths can access this page at
> > > this time?
> > 
> > zbud has no way of serializing with the user (zswap) to prevent it calling
> > zbud_free() during zbud reclaim.  To prevent the zbud page from being freed
> > while reclaim is operating on it, we set the reclaim flag in the struct page.
> > zbud_free() checks this flag and, if set, only sets the chunk length of the
> > allocation to 0, but does not actually free the zbud page.  That is left to
> > this reclaim path.
> 
> Sounds strange.  Page refcounting is a well-established protocol and
> works well in other places?

Yes, refcounting seemed like overkill for this situation since the refcount
will only ever be 1 or 2 (2 if under reclaim) which basically reduces it to a
boolean. I'm also not sure if there is room left in the struct page for a
refcount with all the existing zbud metadata.

However, if you really don't like this, I can look at doing it via refcounts.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
