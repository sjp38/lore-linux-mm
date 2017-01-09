Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 361176B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 15:45:32 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id q186so99357159itb.0
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 12:45:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n195si10465383ita.23.2017.01.09.12.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 12:45:31 -0800 (PST)
Date: Mon, 9 Jan 2017 21:45:24 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 2/4] page_pool: basic implementation of page_pool
Message-ID: <20170109214524.534f53a8@redhat.com>
In-Reply-To: <38d42210-de93-f16f-fa54-b149127fffeb@suse.cz>
References: <20161220132444.18788.50875.stgit@firesoul>
	<20161220132817.18788.64726.stgit@firesoul>
	<52478d40-8c34-4354-c9d8-286020eb26a6@suse.cz>
	<20170104120055.7b277609@redhat.com>
	<38d42210-de93-f16f-fa54-b149127fffeb@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>, willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, Mel Gorman <mgorman@techsingularity.net>, brouer@redhat.com


On Mon, 9 Jan 2017 11:43:39 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 01/04/2017 12:00 PM, Jesper Dangaard Brouer wrote:
> > 
> > On Tue, 3 Jan 2017 17:07:49 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
> >   
> >> On 12/20/2016 02:28 PM, Jesper Dangaard Brouer wrote:  
> >>> The focus in this patch is getting the API around page_pool figured out.
> >>>
> >>> The internal data structures for returning page_pool pages is not optimal.
> >>> This implementation use ptr_ring for recycling, which is known not to scale
> >>> in case of multiple remote CPUs releasing/returning pages.    
> >>
> >> Just few very quick impressions...
> >>  
> >>> A bulking interface into the page allocator is also left for later. (This
> >>> requires cooperation will Mel Gorman, who just send me some PoC patches for this).
> >>> ---  
> > [...]  
> >>> diff --git a/include/linux/mm.h b/include/linux/mm.h
> >>> index 4424784ac374..11b4d8fb280b 100644
> >>> --- a/include/linux/mm.h
> >>> +++ b/include/linux/mm.h  
> > [...]  
> >>> @@ -765,6 +766,11 @@ static inline void put_page(struct page *page)
> >>>  {
> >>>  	page = compound_head(page);
> >>>
> >>> +	if (PagePool(page)) {
> >>> +		page_pool_put_page(page);
> >>> +		return;
> >>> +	}    
> >>
> >> Can't say I'm thrilled about a new page flag and a test in put_page().   
> > 
> > In patch 4/4, I'm scaling this back.  Avoiding to modify the inlined
> > put_page(), by letting refcnt reach zero and catching pages belonging to
> > a page_pool in __free_pages_ok() and free_hot_cold_page(). (Result
> > in being more dependent on page-refcnt and loosing some performance).
> > 
> > Still needing a new page flag, or some other method of identifying when
> > a page belongs to a page_pool.  
> 
> I see. I guess if all page pool pages were order>0 compound pages, you
> could hook this to the existing compound_dtor functionality instead.

The page_pool will support order>0 pages, but it is the order-0 case
that is optimized for.


> >> I don't know the full life cycle here, but isn't it that these pages
> >> will be specifically allocated and used in page pool aware drivers,
> >> so maybe they can be also specifically freed there without hooking to
> >> the generic page refcount mechanism?  
> > 
> > Drivers are already manipulating refcnt, to "splitup" the page (to
> > save memory) for storing more RX frames per page.  Which is something
> > the page_pool still need to support. (XDP can request one page per
> > packet and gain the direct recycle optimization and instead waste mem).
> > 
> > Notice, a page_pool aware driver doesn't handle the "free-side".  Free
> > happens when the packet/page is being consumed, spliced or transmitted
> > out another non-page_pool-aware NIC driver.  An interresting case is
> > packet-page waiting for DMA TX completion (on another NIC), thus need
> > to async-store info on page_pool and DMA-addr.
> > 
> > Could extend the SKB (with a page_pool pointer)... BUT it defeats the
> > purpose of avoiding to allocate the SKB.  E.g. in the cases where XDP
> > takes the route-decision and transmit/forward the "raw"-page (out
> > another NIC or into a "raw" socket), then we don't have a meta-data
> > structure to store this info in. Thus, this info is stored in struct
> > page.  
> 
> OK.
> 
> >>> +		 */
> >>>  		struct address_space *mapping;	/* If low bit clear, points to
> >>>  						 * inode address_space, or NULL.
> >>>  						 * If page mapped as anonymous
> >>> @@ -63,6 +69,7 @@ struct page {
> >>>  	union {
> >>>  		pgoff_t index;		/* Our offset within mapping. */
> >>>  		void *freelist;		/* sl[aou]b first free object */
> >>> +		dma_addr_t dma_addr;    /* used by page_pool */
> >>>  		/* page_deferred_list().prev	-- second tail page */
> >>>  	};
> >>>
> >>> @@ -117,6 +124,8 @@ struct page {
> >>>  	 * avoid collision and false-positive PageTail().
> >>>  	 */
> >>>  	union {
> >>> +		/* XXX: Idea reuse lru list, in page_pool to align with PCP */
> >>> +
> >>>  		struct list_head lru;	/* Pageout list, eg. active_list
> >>>  					 * protected by zone_lru_lock !
> >>>  					 * Can be used as a generic list  
> > 
> > Guess, I can move it here, as the page cannot be on the LRU-list, while
> > being used (or VMA mapped). Right?  
> 
> Well typically the VMA mapped pages are those on the LRU list (anonymous
> or file). But I don't suppose you will want memory reclaim to free your
> pages, so seems lru field should be reusable for you.

Thanks for the info.

So, LRU-list area could be reusable, but I does not align so well with
the bulking API Mel just introduced/proposed, but still doable.

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
