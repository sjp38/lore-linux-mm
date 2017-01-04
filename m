Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8016B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 06:01:02 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id w39so375135469qtw.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 03:01:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z127si34940366qka.302.2017.01.04.03.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 03:01:01 -0800 (PST)
Date: Wed, 4 Jan 2017 12:00:55 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 2/4] page_pool: basic implementation of page_pool
Message-ID: <20170104120055.7b277609@redhat.com>
In-Reply-To: <52478d40-8c34-4354-c9d8-286020eb26a6@suse.cz>
References: <20161220132444.18788.50875.stgit@firesoul>
	<20161220132817.18788.64726.stgit@firesoul>
	<52478d40-8c34-4354-c9d8-286020eb26a6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>, willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, brouer@redhat.com, Mel Gorman <mgorman@techsingularity.net>


On Tue, 3 Jan 2017 17:07:49 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 12/20/2016 02:28 PM, Jesper Dangaard Brouer wrote:
> > The focus in this patch is getting the API around page_pool figured out.
> >
> > The internal data structures for returning page_pool pages is not optimal.
> > This implementation use ptr_ring for recycling, which is known not to scale
> > in case of multiple remote CPUs releasing/returning pages.  
> 
> Just few very quick impressions...
> 
> > A bulking interface into the page allocator is also left for later. (This
> > requires cooperation will Mel Gorman, who just send me some PoC patches for this).
> > ---
[...]
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 4424784ac374..11b4d8fb280b 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
[...]
> > @@ -765,6 +766,11 @@ static inline void put_page(struct page *page)
> >  {
> >  	page = compound_head(page);
> >
> > +	if (PagePool(page)) {
> > +		page_pool_put_page(page);
> > +		return;
> > +	}  
> 
> Can't say I'm thrilled about a new page flag and a test in put_page(). 

In patch 4/4, I'm scaling this back.  Avoiding to modify the inlined
put_page(), by letting refcnt reach zero and catching pages belonging to
a page_pool in __free_pages_ok() and free_hot_cold_page(). (Result
in being more dependent on page-refcnt and loosing some performance).

Still needing a new page flag, or some other method of identifying when
a page belongs to a page_pool.


> I don't know the full life cycle here, but isn't it that these pages
> will be specifically allocated and used in page pool aware drivers,
> so maybe they can be also specifically freed there without hooking to
> the generic page refcount mechanism?

Drivers are already manipulating refcnt, to "splitup" the page (to
save memory) for storing more RX frames per page.  Which is something
the page_pool still need to support. (XDP can request one page per
packet and gain the direct recycle optimization and instead waste mem).

Notice, a page_pool aware driver doesn't handle the "free-side".  Free
happens when the packet/page is being consumed, spliced or transmitted
out another non-page_pool-aware NIC driver.  An interresting case is
packet-page waiting for DMA TX completion (on another NIC), thus need
to async-store info on page_pool and DMA-addr.

Could extend the SKB (with a page_pool pointer)... BUT it defeats the
purpose of avoiding to allocate the SKB.  E.g. in the cases where XDP
takes the route-decision and transmit/forward the "raw"-page (out
another NIC or into a "raw" socket), then we don't have a meta-data
structure to store this info in. Thus, this info is stored in struct
page.


More arguing why a tight MM integration is prefered here[1]
 [1] http://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/design.html#memory-model
besides in makes it easier to convert drivers to use a page_pool.
 
> > +
> >  	if (put_page_testzero(page))
> >  		__put_page(page);
> >
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 08d947fc4c59..c74dea967f99 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -47,6 +47,12 @@ struct page {
> >  	unsigned long flags;		/* Atomic flags, some possibly
> >  					 * updated asynchronously */
> >  	union {
> > +		/* DISCUSS: Considered moving page_pool pointer here,
> > +		 * but I'm unsure if 'mapping' is needed for userspace
> > +		 * mapping the page, as this is a use-case the
> > +		 * page_pool need to support in the future. (Basically
> > +		 * mapping a NIC RX ring into userspace).  
> 
> I think so, but might be wrong here. In any case mapping usually goes with 
> index, and you put dma_addr in union with index below...

Good point, thanks.

> > +		 */
> >  		struct address_space *mapping;	/* If low bit clear, points to
> >  						 * inode address_space, or NULL.
> >  						 * If page mapped as anonymous
> > @@ -63,6 +69,7 @@ struct page {
> >  	union {
> >  		pgoff_t index;		/* Our offset within mapping. */
> >  		void *freelist;		/* sl[aou]b first free object */
> > +		dma_addr_t dma_addr;    /* used by page_pool */
> >  		/* page_deferred_list().prev	-- second tail page */
> >  	};
> >
> > @@ -117,6 +124,8 @@ struct page {
> >  	 * avoid collision and false-positive PageTail().
> >  	 */
> >  	union {
> > +		/* XXX: Idea reuse lru list, in page_pool to align with PCP */
> > +
> >  		struct list_head lru;	/* Pageout list, eg. active_list
> >  					 * protected by zone_lru_lock !
> >  					 * Can be used as a generic list

Guess, I can move it here, as the page cannot be on the LRU-list, while
being used (or VMA mapped). Right?

> > @@ -189,6 +198,8 @@ struct page {
> >  #endif
> >  #endif
> >  		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
> > +		/* XXX: Sure page_pool will have no users of "private"? */
> > +		struct page_pool *pool;
> >  	};
> >
> >  #ifdef CONFIG_MEMCG  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
