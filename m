Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 713216B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 00:30:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 43so3408533qtr.6
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 21:30:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i2si1547574qtd.221.2017.10.01.21.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 21:30:28 -0700 (PDT)
Date: Mon, 2 Oct 2017 07:30:17 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v16 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20171002072106-mutt-send-email-mst@kernel.org>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-4-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506744354-20979-4-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Looks good to me. minor comments below.

On Sat, Sep 30, 2017 at 12:05:52PM +0800, Wei Wang wrote:
> @@ -141,13 +146,128 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  					  page_to_balloon_pfn(page) + i);
>  }
>  
> +
> +static void kick_and_wait(struct virtqueue *vq, wait_queue_head_t wq_head)
> +{
> +	unsigned int len;
> +
> +	virtqueue_kick(vq);
> +	wait_event(wq_head, virtqueue_get_buf(vq, &len));
> +}
> +
> +static int add_one_sg(struct virtqueue *vq, void *addr, uint32_t size)
> +{
> +	struct scatterlist sg;
> +	unsigned int len;
> +
> +	sg_init_one(&sg, addr, size);
> +
> +	/* Detach all the used buffers from the vq */
> +	while (virtqueue_get_buf(vq, &len))
> +		;
> +
> +	return virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> +}
> +
> +static int send_balloon_page_sg(struct virtio_balloon *vb,
> +				 struct virtqueue *vq,
> +				 void *addr,
> +				 uint32_t size,
> +				 bool batch)
> +{
> +	int err;
> +
> +	err = add_one_sg(vq, addr, size);
> +
> +	/* If batchng is requested, we batch till the vq is full */

typo

> +	if (!batch || !vq->num_free)
> +		kick_and_wait(vq, vb->acked);
> +
> +	return err;
> +}

If add_one_sg fails, kick_and_wait will hang forever.

The reason this might work in because
1. with 1 sg there are no memory allocations
2. if adding fails on vq full, then something
   is in queue and will wake up kick_and_wait.

So in short this is expected to never fail.
How about a BUG_ON here then?
And make it void, and add a comment with above explanation.

> +
> +/*
> + * Send balloon pages in sgs to host. The balloon pages are recorded in the
> + * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
> + * The page xbitmap is searched for continuous "1" bits, which correspond
> + * to continuous pages, to chunk into sgs.
> + *
> + * @page_xb_start and @page_xb_end form the range of bits in the xbitmap that
> + * need to be searched.
> + */
> +static void tell_host_sgs(struct virtio_balloon *vb,
> +			  struct virtqueue *vq,
> +			  unsigned long page_xb_start,
> +			  unsigned long page_xb_end)
> +{
> +	unsigned long sg_pfn_start, sg_pfn_end;
> +	void *sg_addr;
> +	uint32_t sg_len, sg_max_len = round_down(UINT_MAX, PAGE_SIZE);
> +	int err = 0;
> +
> +	sg_pfn_start = page_xb_start;
> +	while (sg_pfn_start < page_xb_end) {
> +		sg_pfn_start = xb_find_next_set_bit(&vb->page_xb, sg_pfn_start,
> +						    page_xb_end);
> +		if (sg_pfn_start == page_xb_end + 1)
> +			break;
> +		sg_pfn_end = xb_find_next_zero_bit(&vb->page_xb,
> +						   sg_pfn_start + 1,
> +						   page_xb_end);
> +		sg_addr = (void *)pfn_to_kaddr(sg_pfn_start);
> +		sg_len = (sg_pfn_end - sg_pfn_start) << PAGE_SHIFT;
> +		while (sg_len > sg_max_len) {
> +			err = send_balloon_page_sg(vb, vq, sg_addr, sg_max_len,
> +						   true);
> +			if (unlikely(err < 0))
> +				goto err_out;
> +			sg_addr += sg_max_len;
> +			sg_len -= sg_max_len;
> +		}
> +		err = send_balloon_page_sg(vb, vq, sg_addr, sg_len, true);
> +		if (unlikely(err < 0))
> +			goto err_out;
> +		sg_pfn_start = sg_pfn_end + 1;
> +	}
> +
> +	/*
> +	 * The last few sgs may not reach the batch size, but need a kick to
> +	 * notify the device to handle them.
> +	 */
> +	if (vq->num_free != virtqueue_get_vring_size(vq))
> +		kick_and_wait(vq, vb->acked);
> +
> +	xb_clear_bit_range(&vb->page_xb, page_xb_start, page_xb_end);
> +	return;
> +
> +err_out:
> +	dev_warn(&vb->vdev->dev, "%s failure: %d\n", __func__, err);

so fundamentally just make send_balloon_page_sg void then.

> +}
> +
> +static inline void xb_set_page(struct virtio_balloon *vb,
> +			       struct page *page,
> +			       unsigned long *pfn_min,
> +			       unsigned long *pfn_max)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +
> +	*pfn_min = min(pfn, *pfn_min);
> +	*pfn_max = max(pfn, *pfn_max);
> +	xb_preload(GFP_KERNEL);
> +	xb_set_bit(&vb->page_xb, pfn);
> +	xb_preload_end();
> +}
> +
>  static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	unsigned num_allocated_pages;
> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
> +	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
>  
>  	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	if (!use_sg)
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
> @@ -162,7 +282,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  			msleep(200);
>  			break;
>  		}
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +
> +		if (use_sg)
> +			xb_set_page(vb, page, &pfn_min, &pfn_max);
> +		else
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		if (!virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> @@ -171,8 +296,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  
>  	num_allocated_pages = vb->num_pfns;
>  	/* Did we get any? */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->inflate_vq);
> +	if (vb->num_pfns) {
> +		if (use_sg)
> +			tell_host_sgs(vb, vb->inflate_vq, pfn_min, pfn_max);
> +		else
> +			tell_host(vb, vb->inflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	return num_allocated_pages;
> @@ -198,9 +327,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	struct page *page;
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	LIST_HEAD(pages);
> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
> +	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
>  
> -	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	/* Traditionally, we can only do one array worth at a time. */
> +	if (!use_sg)
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	/* We can't release more pages than taken */
> @@ -210,7 +342,11 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  		page = balloon_page_dequeue(vb_dev_info);
>  		if (!page)
>  			break;
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (use_sg)
> +			xb_set_page(vb, page, &pfn_min, &pfn_max);
> +		else
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +
>  		list_add(&page->lru, &pages);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -221,8 +357,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>  	 * is true, we *have* to do it in this order
>  	 */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->deflate_vq);
> +	if (vb->num_pfns) {
> +		if (use_sg)
> +			tell_host_sgs(vb, vb->deflate_vq, pfn_min, pfn_max);
> +		else
> +			tell_host(vb, vb->deflate_vq);
> +	}
>  	release_pages_balloon(vb, &pages);
>  	mutex_unlock(&vb->balloon_lock);
>  	return num_freed_pages;
> @@ -441,6 +581,7 @@ static int init_vqs(struct virtio_balloon *vb)
>  }
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
> +
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
>   *			     a compation thread.     (called under page lock)
> @@ -464,6 +605,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  {
>  	struct virtio_balloon *vb = container_of(vb_dev_info,
>  			struct virtio_balloon, vb_dev_info);
> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
>  	unsigned long flags;
>  
>  	/*
> @@ -485,16 +627,24 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	vb_dev_info->isolated_pages--;
>  	__count_vm_event(BALLOON_MIGRATE);
>  	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
> -	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> -	set_page_pfns(vb, vb->pfns, newpage);
> -	tell_host(vb, vb->inflate_vq);
> -
> +	if (use_sg) {
> +		send_balloon_page_sg(vb, vb->inflate_vq, page_address(newpage),
> +				     PAGE_SIZE, false);
> +	} else {
> +		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, vb->pfns, newpage);
> +		tell_host(vb, vb->inflate_vq);
> +	}
>  	/* balloon's page migration 2nd step -- deflate "page" */
>  	balloon_page_delete(page);
> -	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> -	set_page_pfns(vb, vb->pfns, page);
> -	tell_host(vb, vb->deflate_vq);
> -
> +	if (use_sg) {
> +		send_balloon_page_sg(vb, vb->deflate_vq, page_address(page),
> +				     PAGE_SIZE, false);
> +	} else {
> +		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, vb->pfns, page);
> +		tell_host(vb, vb->deflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	put_page(page); /* balloon reference */
> @@ -553,6 +703,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
> +		xb_init(&vb->page_xb);
> +
>  	vb->nb.notifier_call = virtballoon_oom_notify;
>  	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err = register_oom_notifier(&vb->nb);
> @@ -669,6 +822,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_SG,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7dd..37780a7 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,6 +34,7 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
