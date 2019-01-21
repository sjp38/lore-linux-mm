Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 951F18E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:02:04 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a2so14280128pgt.11
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:02:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c19si12423978pls.242.2019.01.21.07.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 Jan 2019 07:02:01 -0800 (PST)
Date: Mon, 21 Jan 2019 07:02:00 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Add kv_to_page()
Message-ID: <20190121150200.GA14806@infradead.org>
References: <20190121003944.GA26866@bombadil.infradead.org>
 <20190121093739.GA19725@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121093739.GA19725@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> > diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> > index d594f7520b7b..46326de4d9fe 100644
> > --- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> > +++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
> > @@ -308,10 +308,7 @@ static struct dma_page *__ttm_dma_alloc_page(struct dma_pool *pool)
> >  	vaddr = dma_alloc_attrs(pool->dev, pool->size, &d_page->dma,
> >  				pool->gfp_flags, attrs);
> >  	if (vaddr) {
> > -		if (is_vmalloc_addr(vaddr))
> > -			d_page->p = vmalloc_to_page(vaddr);
> > -		else
> > -			d_page->p = virt_to_page(vaddr);
> > +		d_page->p = kv_to_page(vaddr);
> >  		d_page->vaddr = (unsigned long)vaddr;

This code doesn't need cosmetic cleanup but a real fix.  Calling
either vmalloc_to_page OR virt_to_page on the return value of
dma_alloc_* is not allowed, an will break for many of the
implementations.

> > +++ b/drivers/md/bcache/util.c
> > @@ -244,10 +244,7 @@ void bch_bio_map(struct bio *bio, void *base)
> >  start:		bv->bv_len	= min_t(size_t, PAGE_SIZE - bv->bv_offset,
> >  					size);
> >  		if (base) {
> > -			bv->bv_page = is_vmalloc_addr(base)
> > -				? vmalloc_to_page(base)
> > -				: virt_to_page(base);
> > -
> > +			bv->bv_page = kv_to_page(base);
> >  			base += bv->bv_len;
> >  		}

This one also is broken, although not quite as badly.  Anyone using
vmalloc-like memory for bios need to call invalidate_kernel_vmap_range /
flush_kernel_vmap_range to maintain cache coherency for VIVT caches.

It seems this odd bcache API just makes it way to easy to miss that.

> > @@ -403,23 +402,14 @@ static int scif_create_remote_lookup(struct scif_dev *remote_dev,
> >  		goto error_window;
> >  	}
> > 
> > -	vmalloc_dma_phys = is_vmalloc_addr(&window->dma_addr[0]);
> > -	vmalloc_num_pages = is_vmalloc_addr(&window->num_pages[0]);
> > -
> >  	/* Now map each of the pages containing physical addresses */
> >  	for (i = 0, j = 0; i < nr_pages; i += SCIF_NR_ADDR_IN_PAGE, j++) {
> >  		err = scif_map_page(&window->dma_addr_lookup.lookup[j],
> > -				    vmalloc_dma_phys ?
> > -				    vmalloc_to_page(&window->dma_addr[i]) :
> > -				    virt_to_page(&window->dma_addr[i]),
> > -				    remote_dev);
> > +				kv_to_page(&window->dma_addr[i]), remote_dev);

Similar issue here.  We can't just DMA map pages returned from
vmalloc_to_page without very explicit cache maintainance.

> >  		pinned_pages->map_flags = SCIF_MAP_KERNEL;
> > diff --git a/drivers/spi/spi.c b/drivers/spi/spi.c
> > index 9a7def7c3237..1382cc18e7db 100644
> > --- a/drivers/spi/spi.c
> > +++ b/drivers/spi/spi.c
> > @@ -833,10 +833,7 @@ int spi_map_buf(struct spi_controller *ctlr, struct device *dev,
> >  			min = min_t(size_t, desc_len,
> >  				    min_t(size_t, len,
> >  					  PAGE_SIZE - offset_in_page(buf)));
> > -			if (vmalloced_buf)
> > -				vm_page = vmalloc_to_page(buf);
> > -			else
> > -				vm_page = kmap_to_page(buf);
> > +			vm_page = kv_to_page(buf);

Same issue here again :(

> > diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
> > index 5d6724cee38f..4e13e88dd38c 100644
> > --- a/net/ceph/crypto.c
> > +++ b/net/ceph/crypto.c
> > @@ -191,11 +191,7 @@ static int setup_sgtable(struct sg_table *sgt, struct scatterlist *prealloc_sg,
> >  		struct page *page;
> >  		unsigned int len = min(chunk_len - off, buf_len);
> > 
> > -		if (is_vmalloc)
> > -			page = vmalloc_to_page(buf);
> > -		else
> > -			page = virt_to_page(buf);
> > -
> > +		page = kv_to_page(buf);
> >  		sg_set_page(sg, page, len, off);

Another issue of the same kind.

> > 
> > -static inline struct page * __pure pgv_to_page(void *addr)
> > -{
> > -	if (is_vmalloc_addr(addr))
> > -		return vmalloc_to_page(addr);
> > -	return virt_to_page(addr);
> > -}

This one plays really odd flush_dcache_page games, which looks like
a workaround for the above proper APIs.
