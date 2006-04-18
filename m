Date: Tue, 18 Apr 2006 16:38:26 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] slab: cleanup kmem_getpages
Message-Id: <20060418163826.78af10a0.akpm@osdl.org>
In-Reply-To: <20060418232428.GA13570@lst.de>
References: <20060414183618.GA21144@lst.de>
	<20060418232000.GL2732@melbourne.sgi.com>
	<20060418232428.GA13570@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: dgc@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@lst.de> wrote:
>
> > > +	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
> > >  	if (!page)
> > >  		return NULL;
> > > -	addr = page_address(page);
> > .....
> > > +	while (nr_pages--) {
> > >  		__SetPageSlab(page);
> > >  		page++;
> > >  	}
> > > -	return addr;
> > > +	return page_address(page);
> > 
> > I think that's a bug - you return the address of the page after the
> > allocation, not the first page of the allocation.
> 
> You're right.  I wonder why this didn't show up in my testing.  Looks
> like slab will never allocate any high-order pages if your page size
> is big enough..
> 
> Andrew, please drop this for now.  I'll redo it without that bit once
> I'll get some time.

I already fixed it - it was giving me instantaneous oopses.

--- devel/mm/slab.c~slab-cleanup-kmem_getpages-fix	2006-04-15 01:00:53.000000000 -0700
+++ devel-akpm/mm/slab.c	2006-04-15 01:01:49.000000000 -0700
@@ -1492,6 +1492,7 @@ static void *kmem_getpages(struct kmem_c
 {
 	struct page *page;
 	int nr_pages;
+	int i;
 
 #ifndef CONFIG_MMU
 	/*
@@ -1510,10 +1511,8 @@ static void *kmem_getpages(struct kmem_c
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		atomic_add(nr_pages, &slab_reclaim_pages);
 	add_page_state(nr_slab, nr_pages);
-	while (nr_pages--) {
-		__SetPageSlab(page);
-		page++;
-	}
+	for (i = 0; i < nr_pages; i++)
+		__SetPageSlab(page + i);
 	return page_address(page);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
