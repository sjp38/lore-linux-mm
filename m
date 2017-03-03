Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3A446B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 11:38:57 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y51so41196599wry.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 08:38:57 -0800 (PST)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id 3si9079497wrn.310.2017.03.03.08.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 08:38:56 -0800 (PST)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [RFC PATCH 06/12] staging: android: ion: Remove crufty cache support
Date: Fri, 03 Mar 2017 18:39:30 +0200
Message-ID: <2273106.Hjr80nPvcZ@avalon>
In-Reply-To: <20170303095654.zbcqkcojo3vf6y4y@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com> <1488491084-17252-7-git-send-email-labbott@redhat.com> <20170303095654.zbcqkcojo3vf6y4y@phenom.ffwll.local>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org
Cc: Daniel Vetter <daniel@ffwll.ch>, Laura Abbott <labbott@redhat.com>, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Riley Andrews <riandrews@android.com>, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

Hi Daniel,

On Friday 03 Mar 2017 10:56:54 Daniel Vetter wrote:
> On Thu, Mar 02, 2017 at 01:44:38PM -0800, Laura Abbott wrote:
> > Now that we call dma_map in the dma_buf API callbacks there is no need
> > to use the existing cache APIs. Remove the sync ioctl and the existing
> > bad dma_sync calls. Explicit caching can be handled with the dma_buf
> > sync API.
> > 
> > Signed-off-by: Laura Abbott <labbott@redhat.com>
> > ---
> > 
> >  drivers/staging/android/ion/ion-ioctl.c         |  5 ----
> >  drivers/staging/android/ion/ion.c               | 40 --------------------
> >  drivers/staging/android/ion/ion_carveout_heap.c |  6 ----
> >  drivers/staging/android/ion/ion_chunk_heap.c    |  6 ----
> >  drivers/staging/android/ion/ion_page_pool.c     |  3 --
> >  drivers/staging/android/ion/ion_system_heap.c   |  5 ----
> >  6 files changed, 65 deletions(-)
> > 
> > diff --git a/drivers/staging/android/ion/ion-ioctl.c
> > b/drivers/staging/android/ion/ion-ioctl.c index 5b2e93f..f820d77 100644
> > --- a/drivers/staging/android/ion/ion-ioctl.c
> > +++ b/drivers/staging/android/ion/ion-ioctl.c
> > @@ -146,11 +146,6 @@ long ion_ioctl(struct file *filp, unsigned int cmd,
> > unsigned long arg)> 
> >  			data.handle.handle = handle->id;
> >  		
> >  		break;
> >  	
> >  	}
> > 
> > -	case ION_IOC_SYNC:
> > -	{
> > -		ret = ion_sync_for_device(client, data.fd.fd);
> > -		break;
> > -	}
> 
> You missed the case ION_IOC_SYNC: in compat_ion.c.
> 
> While at it: Should we also remove the entire custom_ioctl infrastructure?
> It's entirely unused afaict, and for a pure buffer allocator I don't see
> any need to have custom ioctl.

I second that, if you want to make ion a standard API, then we certainly don't 
want any custom ioctl.

> More code to remove potentially:
> - The entire compat ioctl stuff - would be an abi break, but I guess if we
>   pick the 32bit abi and clean up the uapi headers we'll be mostly fine.
>   would allow us to remove compat_ion.c entirely.
> 
> - ION_IOC_IMPORT: With this ion is purely an allocator, so not sure we
>   still need to be able to import anything. All the cache flushing/mapping
>   is done through dma-buf ops/ioctls.
> 
> 
> With the case in compat_ion.c also removed, this patch is:
> 
> Reviewed-by: Daniel Vetter <daniel.vetter@ffwll.ch>
> 
> >  	case ION_IOC_CUSTOM:
> >  	{
> >  	
> >  		if (!dev->custom_ioctl)
> > 
> > diff --git a/drivers/staging/android/ion/ion.c
> > b/drivers/staging/android/ion/ion.c index 8eef1d7..c3c316f 100644
> > --- a/drivers/staging/android/ion/ion.c
> > +++ b/drivers/staging/android/ion/ion.c
> > @@ -815,22 +815,6 @@ static void ion_unmap_dma_buf(struct
> > dma_buf_attachment *attachment,> 
> >  	free_duped_table(table);
> >  
> >  }
> > 
> > -void ion_pages_sync_for_device(struct device *dev, struct page *page,
> > -			       size_t size, enum dma_data_direction dir)
> > -{
> > -	struct scatterlist sg;
> > -
> > -	sg_init_table(&sg, 1);
> > -	sg_set_page(&sg, page, size, 0);
> > -	/*
> > -	 * This is not correct - sg_dma_address needs a dma_addr_t that is 
valid
> > -	 * for the targeted device, but this works on the currently targeted
> > -	 * hardware.
> > -	 */
> > -	sg_dma_address(&sg) = page_to_phys(page);
> > -	dma_sync_sg_for_device(dev, &sg, 1, dir);
> > -}
> > -
> > 
> >  static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
> >  {
> >  
> >  	struct ion_buffer *buffer = dmabuf->priv;
> > 
> > @@ -1042,30 +1026,6 @@ struct ion_handle *ion_import_dma_buf_fd(struct
> > ion_client *client, int fd)> 
> >  }
> >  EXPORT_SYMBOL(ion_import_dma_buf_fd);
> > 
> > -int ion_sync_for_device(struct ion_client *client, int fd)
> > -{
> > -	struct dma_buf *dmabuf;
> > -	struct ion_buffer *buffer;
> > -
> > -	dmabuf = dma_buf_get(fd);
> > -	if (IS_ERR(dmabuf))
> > -		return PTR_ERR(dmabuf);
> > -
> > -	/* if this memory came from ion */
> > -	if (dmabuf->ops != &dma_buf_ops) {
> > -		pr_err("%s: can not sync dmabuf from another exporter\n",
> > -		       __func__);
> > -		dma_buf_put(dmabuf);
> > -		return -EINVAL;
> > -	}
> > -	buffer = dmabuf->priv;
> > -
> > -	dma_sync_sg_for_device(NULL, buffer->sg_table->sgl,
> > -			       buffer->sg_table->nents, DMA_BIDIRECTIONAL);
> > -	dma_buf_put(dmabuf);
> > -	return 0;
> > -}
> > -
> > 
> >  int ion_query_heaps(struct ion_client *client, struct ion_heap_query
> >  *query) {
> >  
> >  	struct ion_device *dev = client->dev;
> > 
> > diff --git a/drivers/staging/android/ion/ion_carveout_heap.c
> > b/drivers/staging/android/ion/ion_carveout_heap.c index 9bf8e98..e0e360f
> > 100644
> > --- a/drivers/staging/android/ion/ion_carveout_heap.c
> > +++ b/drivers/staging/android/ion/ion_carveout_heap.c
> > @@ -100,10 +100,6 @@ static void ion_carveout_heap_free(struct ion_buffer
> > *buffer)> 
> >  	ion_heap_buffer_zero(buffer);
> > 
> > -	if (ion_buffer_cached(buffer))
> > -		dma_sync_sg_for_device(NULL, table->sgl, table->nents,
> > -				       DMA_BIDIRECTIONAL);
> > -
> > 
> >  	ion_carveout_free(heap, paddr, buffer->size);
> >  	sg_free_table(table);
> >  	kfree(table);
> > 
> > @@ -128,8 +124,6 @@ struct ion_heap *ion_carveout_heap_create(struct
> > ion_platform_heap *heap_data)> 
> >  	page = pfn_to_page(PFN_DOWN(heap_data->base));
> >  	size = heap_data->size;
> > 
> > -	ion_pages_sync_for_device(NULL, page, size, DMA_BIDIRECTIONAL);
> > -
> > 
> >  	ret = ion_heap_pages_zero(page, size, 
pgprot_writecombine(PAGE_KERNEL));
> >  	if (ret)
> >  	
> >  		return ERR_PTR(ret);
> > 
> > diff --git a/drivers/staging/android/ion/ion_chunk_heap.c
> > b/drivers/staging/android/ion/ion_chunk_heap.c index 8c41889..46e13f6
> > 100644
> > --- a/drivers/staging/android/ion/ion_chunk_heap.c
> > +++ b/drivers/staging/android/ion/ion_chunk_heap.c
> > @@ -101,10 +101,6 @@ static void ion_chunk_heap_free(struct ion_buffer
> > *buffer)> 
> >  	ion_heap_buffer_zero(buffer);
> > 
> > -	if (ion_buffer_cached(buffer))
> > -		dma_sync_sg_for_device(NULL, table->sgl, table->nents,
> > -				       DMA_BIDIRECTIONAL);
> > -
> > 
> >  	for_each_sg(table->sgl, sg, table->nents, i) {
> >  	
> >  		gen_pool_free(chunk_heap->pool, page_to_phys(sg_page(sg)),
> >  		
> >  			      sg->length);
> > 
> > @@ -132,8 +128,6 @@ struct ion_heap *ion_chunk_heap_create(struct
> > ion_platform_heap *heap_data)> 
> >  	page = pfn_to_page(PFN_DOWN(heap_data->base));
> >  	size = heap_data->size;
> > 
> > -	ion_pages_sync_for_device(NULL, page, size, DMA_BIDIRECTIONAL);
> > -
> > 
> >  	ret = ion_heap_pages_zero(page, size, 
pgprot_writecombine(PAGE_KERNEL));
> >  	if (ret)
> >  	
> >  		return ERR_PTR(ret);
> > 
> > diff --git a/drivers/staging/android/ion/ion_page_pool.c
> > b/drivers/staging/android/ion/ion_page_pool.c index aea89c1..532eda7
> > 100644
> > --- a/drivers/staging/android/ion/ion_page_pool.c
> > +++ b/drivers/staging/android/ion/ion_page_pool.c
> > @@ -30,9 +30,6 @@ static void *ion_page_pool_alloc_pages(struct
> > ion_page_pool *pool)> 
> >  	if (!page)
> >  	
> >  		return NULL;
> > 
> > -	if (!pool->cached)
> > -		ion_pages_sync_for_device(NULL, page, PAGE_SIZE << pool-
>order,
> > -					  DMA_BIDIRECTIONAL);
> > 
> >  	return page;
> >  
> >  }
> > 
> > diff --git a/drivers/staging/android/ion/ion_system_heap.c
> > b/drivers/staging/android/ion/ion_system_heap.c index 6cb2fe7..a33331b
> > 100644
> > --- a/drivers/staging/android/ion/ion_system_heap.c
> > +++ b/drivers/staging/android/ion/ion_system_heap.c
> > @@ -75,9 +75,6 @@ static struct page *alloc_buffer_page(struct
> > ion_system_heap *heap,> 
> >  	page = ion_page_pool_alloc(pool);
> > 
> > -	if (cached)
> > -		ion_pages_sync_for_device(NULL, page, PAGE_SIZE << order,
> > -					  DMA_BIDIRECTIONAL);
> > 
> >  	return page;
> >  
> >  }
> > 
> > @@ -401,8 +398,6 @@ static int ion_system_contig_heap_allocate(struct
> > ion_heap *heap,> 
> >  	buffer->sg_table = table;
> > 
> > -	ion_pages_sync_for_device(NULL, page, len, DMA_BIDIRECTIONAL);
> > -
> > 
> >  	return 0;
> >  
> >  free_table:

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
