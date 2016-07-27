Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B52C86B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:07:23 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n69so21086571ion.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 15:07:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r142si9120264itb.99.2016.07.27.15.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 15:07:22 -0700 (PDT)
Date: Thu, 28 Jul 2016 01:07:15 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Message-ID: <20160728010616-mutt-send-email-mst@kernel.org>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

On Wed, Jul 27, 2016 at 09:23:33AM +0800, Liang Li wrote:
> The implementation of the current virtio-balloon is not very
> efficient, the time spends on different stages of inflating
> the balloon to 7GB of a 8GB idle guest:
> 
> a. allocating pages (6.5%)
> b. sending PFNs to host (68.3%)
> c. address translation (6.1%)
> d. madvise (19%)
> 
> It takes about 4126ms for the inflating process to complete.
> Debugging shows that the bottle neck are the stage b and stage d.
> 
> If using a bitmap to send the page info instead of the PFNs, we
> can reduce the overhead in stage b quite a lot. Furthermore, we
> can do the address translation and call madvise() with a bulk of
> RAM pages, instead of the current page per page way, the overhead
> of stage c and stage d can also be reduced a lot.
> 
> This patch is the kernel side implementation which is intended to
> speed up the inflating & deflating process by adding a new feature
> to the virtio-balloon device. With this new feature, inflating the
> balloon to 7GB of a 8GB idle guest only takes 590ms, the
> performance improvement is about 85%.
> 
> TODO: optimize stage a by allocating/freeing a chunk of pages
> instead of a single page at a time.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Amit Shah <amit.shah@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c | 184 +++++++++++++++++++++++++++++++++++-----
>  1 file changed, 162 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 8d649a2..2d18ff6 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -41,10 +41,28 @@
>  #define OOM_VBALLOON_DEFAULT_PAGES 256
>  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
>  
> +/*
> + * VIRTIO_BALLOON_PFNS_LIMIT is used to limit the size of page bitmap
> + * to prevent a very large page bitmap, there are two reasons for this:
> + * 1) to save memory.
> + * 2) allocate a large bitmap may fail.
> + *
> + * The actual limit of pfn is determined by:
> + * pfn_limit = min(max_pfn, VIRTIO_BALLOON_PFNS_LIMIT);
> + *
> + * If system has more pages than VIRTIO_BALLOON_PFNS_LIMIT, we will scan
> + * the page list and send the PFNs with several times. To reduce the
> + * overhead of scanning the page list. VIRTIO_BALLOON_PFNS_LIMIT should
> + * be set with a value which can cover most cases.
> + */
> +#define VIRTIO_BALLOON_PFNS_LIMIT ((32 * (1ULL << 30)) >> PAGE_SHIFT) /* 32GB */
> +
>  static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
>  module_param(oom_pages, int, S_IRUSR | S_IWUSR);
>  MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>  
> +extern unsigned long get_max_pfn(void);
> +

Please just include the correct header. No need for this hackery.

>  struct virtio_balloon {
>  	struct virtio_device *vdev;
>  	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> @@ -62,6 +80,15 @@ struct virtio_balloon {
>  
>  	/* Number of balloon pages we've told the Host we're not using. */
>  	unsigned int num_pages;
> +	/* Pointer of the bitmap header. */
> +	void *bmap_hdr;
> +	/* Bitmap and length used to tell the host the pages */
> +	unsigned long *page_bitmap;
> +	unsigned long bmap_len;
> +	/* Pfn limit */
> +	unsigned long pfn_limit;
> +	/* Used to record the processed pfn range */
> +	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
>  	/*
>  	 * The pages we've told the Host we're not using are enqueued
>  	 * at vb_dev_info->pages list.
> @@ -105,12 +132,45 @@ static void balloon_ack(struct virtqueue *vq)
>  	wake_up(&vb->acked);
>  }
>  
> +static inline void init_pfn_range(struct virtio_balloon *vb)
> +{
> +	vb->min_pfn = ULONG_MAX;
> +	vb->max_pfn = 0;
> +}
> +
> +static inline void update_pfn_range(struct virtio_balloon *vb,
> +				 struct page *page)
> +{
> +	unsigned long balloon_pfn = page_to_balloon_pfn(page);
> +
> +	if (balloon_pfn < vb->min_pfn)
> +		vb->min_pfn = balloon_pfn;
> +	if (balloon_pfn > vb->max_pfn)
> +		vb->max_pfn = balloon_pfn;
> +}
> +
>  static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>  {
>  	struct scatterlist sg;
>  	unsigned int len;
>  
> -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP)) {
> +		struct balloon_bmap_hdr *hdr = vb->bmap_hdr;
> +		unsigned long bmap_len;
> +
> +		/* cmd and req_id are not used here, set them to 0 */
> +		hdr->cmd = cpu_to_virtio16(vb->vdev, 0);
> +		hdr->page_shift = cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
> +		hdr->reserved = cpu_to_virtio16(vb->vdev, 0);
> +		hdr->req_id = cpu_to_virtio64(vb->vdev, 0);
> +		hdr->start_pfn = cpu_to_virtio64(vb->vdev, vb->start_pfn);
> +		bmap_len = min(vb->bmap_len,
> +			(vb->end_pfn - vb->start_pfn) / BITS_PER_BYTE);
> +		hdr->bmap_len = cpu_to_virtio64(vb->vdev, bmap_len);
> +		sg_init_one(&sg, hdr,
> +			 sizeof(struct balloon_bmap_hdr) + bmap_len);
> +	} else
> +		sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
>  
>  	/* We should always be able to add one buffer to an empty queue. */
>  	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> @@ -118,7 +178,6 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>  
>  	/* When host has read buffer, this completes via balloon_ack */
>  	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> -
>  }
>  
>  static void set_page_pfns(struct virtio_balloon *vb,
> @@ -133,13 +192,53 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  					  page_to_balloon_pfn(page) + i);
>  }
>  
> -static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> +static void set_page_bitmap(struct virtio_balloon *vb,
> +			 struct list_head *pages, struct virtqueue *vq)
> +{
> +	unsigned long pfn;
> +	struct page *page;
> +	bool found;
> +
> +	vb->min_pfn = rounddown(vb->min_pfn, BITS_PER_LONG);
> +	vb->max_pfn = roundup(vb->max_pfn, BITS_PER_LONG);
> +	for (pfn = vb->min_pfn; pfn < vb->max_pfn;
> +			pfn += vb->pfn_limit) {
> +		vb->start_pfn = pfn + vb->pfn_limit;
> +		vb->end_pfn = pfn;
> +		memset(vb->page_bitmap, 0, vb->bmap_len);
> +		found = false;
> +		list_for_each_entry(page, pages, lru) {
> +			unsigned long balloon_pfn = page_to_balloon_pfn(page);
> +
> +			if (balloon_pfn < pfn ||
> +				 balloon_pfn >= pfn + vb->pfn_limit)
> +				continue;
> +			set_bit(balloon_pfn - pfn, vb->page_bitmap);
> +			if (balloon_pfn > vb->end_pfn)
> +				vb->end_pfn = balloon_pfn;
> +			if (balloon_pfn < vb->start_pfn)
> +				vb->start_pfn = balloon_pfn;
> +			found = true;
> +		}
> +		if (found) {
> +			vb->start_pfn = rounddown(vb->start_pfn, BITS_PER_LONG);
> +			vb->end_pfn = roundup(vb->end_pfn, BITS_PER_LONG);
> +			tell_host(vb, vq);
> +		}
> +	}
> +}
> +
> +static unsigned int fill_balloon(struct virtio_balloon *vb, size_t num,
> +				 bool use_bmap)
>  {
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
> -	unsigned num_allocated_pages;
> +	unsigned int num_allocated_pages;
>  
> -	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	if (use_bmap)
> +		init_pfn_range(vb);
> +	else
> +		/* We can only do one array worth at a time. */
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
> @@ -154,7 +253,10 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  			msleep(200);
>  			break;
>  		}
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (use_bmap)
> +			update_pfn_range(vb, page);
> +		else
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		if (!virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> @@ -163,8 +265,13 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  
>  	num_allocated_pages = vb->num_pfns;
>  	/* Did we get any? */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->inflate_vq);
> +	if (vb->num_pfns != 0) {
> +		if (use_bmap)
> +			set_page_bitmap(vb, &vb_dev_info->pages,
> +					vb->inflate_vq);
> +		else
> +			tell_host(vb, vb->inflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	return num_allocated_pages;
> @@ -184,15 +291,19 @@ static void release_pages_balloon(struct virtio_balloon *vb,
>  	}
>  }
>  
> -static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
> +static unsigned int leak_balloon(struct virtio_balloon *vb, size_t num,
> +				bool use_bmap)
>  {
> -	unsigned num_freed_pages;
> +	unsigned int num_freed_pages;
>  	struct page *page;
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	LIST_HEAD(pages);
>  
> -	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	if (use_bmap)
> +		init_pfn_range(vb);
> +	else
> +		/* We can only do one array worth at a time. */
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	for (vb->num_pfns = 0; vb->num_pfns < num;
> @@ -200,7 +311,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  		page = balloon_page_dequeue(vb_dev_info);
>  		if (!page)
>  			break;
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (use_bmap)
> +			update_pfn_range(vb, page);
> +		else
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		list_add(&page->lru, &pages);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -211,9 +325,14 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>  	 * is true, we *have* to do it in this order
>  	 */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->deflate_vq);
> -	release_pages_balloon(vb, &pages);
> +	if (vb->num_pfns != 0) {
> +		if (use_bmap)
> +			set_page_bitmap(vb, &pages, vb->deflate_vq);
> +		else
> +			tell_host(vb, vb->deflate_vq);
> +
> +		release_pages_balloon(vb, &pages);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  	return num_freed_pages;
>  }
> @@ -347,13 +466,15 @@ static int virtballoon_oom_notify(struct notifier_block *self,
>  	struct virtio_balloon *vb;
>  	unsigned long *freed;
>  	unsigned num_freed_pages;
> +	bool use_bmap;
>  
>  	vb = container_of(self, struct virtio_balloon, nb);
>  	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  		return NOTIFY_OK;
>  
>  	freed = parm;
> -	num_freed_pages = leak_balloon(vb, oom_pages);
> +	use_bmap = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
> +	num_freed_pages = leak_balloon(vb, oom_pages, use_bmap);
>  	update_balloon_size(vb);
>  	*freed += num_freed_pages;
>  
> @@ -373,15 +494,17 @@ static void update_balloon_size_func(struct work_struct *work)
>  {
>  	struct virtio_balloon *vb;
>  	s64 diff;
> +	bool use_bmap;
>  
>  	vb = container_of(work, struct virtio_balloon,
>  			  update_balloon_size_work);
> +	use_bmap = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
>  	diff = towards_target(vb);
>  
>  	if (diff > 0)
> -		diff -= fill_balloon(vb, diff);
> +		diff -= fill_balloon(vb, diff, use_bmap);
>  	else if (diff < 0)
> -		diff += leak_balloon(vb, -diff);
> +		diff += leak_balloon(vb, -diff, use_bmap);
>  	update_balloon_size(vb);
>  
>  	if (diff)
> @@ -489,7 +612,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> -	int err;
> +	int err, hdr_len;
>  
>  	if (!vdev->config->get) {
>  		dev_err(&vdev->dev, "%s failure: config access disabled\n",
> @@ -508,6 +631,18 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	spin_lock_init(&vb->stop_update_lock);
>  	vb->stop_update = false;
>  	vb->num_pages = 0;
> +	vb->pfn_limit = VIRTIO_BALLOON_PFNS_LIMIT;
> +	vb->pfn_limit = min(vb->pfn_limit, get_max_pfn());
> +	vb->bmap_len = ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
> +	hdr_len = sizeof(struct balloon_bmap_hdr);
> +	vb->bmap_hdr = kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);
> +
> +	/* Clear the feature bit if memory allocation fails */
> +	if (!vb->bmap_hdr)
> +		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
> +	else
> +		vb->page_bitmap = vb->bmap_hdr + hdr_len;
>  	mutex_init(&vb->balloon_lock);
>  	init_waitqueue_head(&vb->acked);
>  	vb->vdev = vdev;
> @@ -541,9 +676,12 @@ out:
>  
>  static void remove_common(struct virtio_balloon *vb)
>  {
> +	bool use_bmap;
> +
> +	use_bmap = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
>  	/* There might be pages left in the balloon: free them. */
>  	while (vb->num_pages)
> -		leak_balloon(vb, vb->num_pages);
> +		leak_balloon(vb, vb->num_pages, use_bmap);
>  	update_balloon_size(vb);
>  
>  	/* Now we reset the device so we can clean up the queues. */
> @@ -565,6 +703,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	cancel_work_sync(&vb->update_balloon_stats_work);
>  
>  	remove_common(vb);
> +	kfree(vb->page_bitmap);
>  	kfree(vb);
>  }
>  
> @@ -603,6 +742,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_PAGE_BITMAP,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
