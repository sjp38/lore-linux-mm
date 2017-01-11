Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 480976B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 02:11:02 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id x49so125547025qtc.7
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 23:11:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o67si3169842qka.120.2017.01.10.23.11.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 23:11:01 -0800 (PST)
Date: Wed, 11 Jan 2017 08:10:52 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 2/4] page_pool: basic implementation of page_pool
Message-ID: <20170111081052.1df59d4d@redhat.com>
In-Reply-To: <20170109215825.k4grwyhffiv6wksp@techsingularity.net>
References: <20161220132444.18788.50875.stgit@firesoul>
	<20161220132817.18788.64726.stgit@firesoul>
	<52478d40-8c34-4354-c9d8-286020eb26a6@suse.cz>
	<20170104120055.7b277609@redhat.com>
	<38d42210-de93-f16f-fa54-b149127fffeb@suse.cz>
	<20170109214524.534f53a8@redhat.com>
	<20170109215825.k4grwyhffiv6wksp@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Alexander Duyck <alexander.duyck@gmail.com>, willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>, bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, brouer@redhat.com

On Mon, 9 Jan 2017 21:58:26 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Mon, Jan 09, 2017 at 09:45:24PM +0100, Jesper Dangaard Brouer wrote:
> > > I see. I guess if all page pool pages were order>0 compound pages, you
> > > could hook this to the existing compound_dtor functionality instead.  
> > 
> > The page_pool will support order>0 pages, but it is the order-0 case
> > that is optimized for.
> >   
> 
> The bulk allocator is currently not suitable for high-order pages. It would
> take more work to do that but is not necessarily even a good idea. FWIW,
> the high-order per-cpu page allocator posted some weeks ago would be the
> basis. I didn't push that series as the benefit to SLUB was too marginal
> given the complexity.
> 
> > > Well typically the VMA mapped pages are those on the LRU list (anonymous
> > > or file). But I don't suppose you will want memory reclaim to free your
> > > pages, so seems lru field should be reusable for you.  
> > 
> > Thanks for the info.
> > 
> > So, LRU-list area could be reusable, but I does not align so well with
> > the bulking API Mel just introduced/proposed, but still doable.
> >   
> 
> That's a relatively minor implementation detail. I needed something to
> hang the pages onto for returning. Using a list and page->lru is a standard
> approach but it does not mandate that the caller preserve page->lru or that
> it's related to the LRU. The caller simply needs to put the pages back onto
> a list if it's bulk freeing or call __free_pages() directly for each page.
> If any in-kernel user uses __free_pages() then the free_pages_bulk()
> API can be dropped entirely.
> 
> I'm not intending to merge the bulk allocator due to a lack of in-kernel
> users and an inability to test in-kernel users.  It was simply designed to
> illustrate how to call the core of the page allocator in a way that avoids
> the really expensive checks. If required, the pages could be returned on
> a caller-allocated array or something exotic like using one page to store
> pointers to the rest. Either of those alternatives are harder to use. A
> caller-allocated array must be sure the nr_pages parameter is correct and
> the exotic approach would require careful use by the caller. Using page->lru
> was more straight-forward when the requirements of the callers was unknown.
> 
> It opens the question of what to do with that series. I was going to wait
> for feedback but my intent was to try merge patches 1-3 if there were no
> objections and preferably with your reviewed-by or ack. I would then hand
> patch 4 over to you for addition to a series that added in-kernel callers to
> alloc_pages_bulk() be that the generic pool recycle or modifying drivers.
> You are then free to modify the API to suit your needs without having to
> figure out the best way of calling the page allocator.

I think that sound like a good plan.

Your patches 1-3 is a significant performance improvement for the page
allocator, and I want to see those merged.  Don't want to block it with
patch 4 (bulking).

I'm going to do some (more) testing on your patchset, and then ACK the
patches.

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
