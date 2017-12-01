Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1A9A6B025E
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:38:22 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f27so5273205ote.16
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:38:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m84si2135547oib.75.2017.12.01.07.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 07:38:21 -0800 (PST)
Date: Fri, 1 Dec 2017 17:38:06 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v18 07/10] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20171201171746-mutt-send-email-mst@kernel.org>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
 <1511963726-34070-8-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511963726-34070-8-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

On Wed, Nov 29, 2017 at 09:55:23PM +0800, Wei Wang wrote:
> Add a new feature, VIRTIO_BALLOON_F_SG, which enables the transfer of
> balloon (i.e. inflated/deflated) pages using scatter-gather lists to the
> host. A scatter-gather list is described by a vring desc.
> 
> The implementation of the previous virtio-balloon is not very efficient,
> because the balloon pages are transferred to the host by one array each
> time. Here is the breakdown of the time in percentage spent on each step
> of the balloon inflating process (inflating 7GB of an 8GB idle guest).
> 
> 1) allocating pages (6.5%)
> 2) sending PFNs to host (68.3%)
> 3) address translation (6.1%)
> 4) madvise (19%)
> 
> It takes about 4126ms for the inflating process to complete. The above
> profiling shows that the bottlenecks are stage 2) and stage 4).
> 
> This patch optimizes step 2) by transferring pages to host in sgs. An sg
> describes a chunk of guest physically continuous pages. With this
> mechanism, step 4) can also be optimized by doing address translation and
> madvise() in chunks rather than page by page.
> 
> With this new feature, the above ballooning process takes ~440ms resulting
> in an improvement of ~89%.
> 
> TODO: optimize stage 1) by allocating/freeing a chunk of pages instead of
> a single page each time.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  drivers/virtio/virtio_balloon.c     | 230 +++++++++++++++++++++++++++++++++---
>  include/uapi/linux/virtio_balloon.h |   1 +
>  2 files changed, 212 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 7960746..2c21c5a 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -32,6 +32,8 @@
>  #include <linux/mm.h>
>  #include <linux/mount.h>
>  #include <linux/magic.h>
> +#include <linux/xbitmap.h>
> +#include <asm/page.h>
>  
>  /*
>   * Balloon device works in 4K page units.  So each page is pointed to by
> @@ -79,6 +81,9 @@ struct virtio_balloon {
>  	/* Synchronize access/update to this struct virtio_balloon elements */
>  	struct mutex balloon_lock;
>  
> +	/* The xbitmap used to record balloon pages */
> +	struct xb page_xb;
> +
>  	/* The array of pfns we tell the Host about. */
>  	unsigned int num_pfns;
>  	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
> @@ -141,15 +146,121 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  					  page_to_balloon_pfn(page) + i);
>  }
>  
> +static void kick_and_wait(struct virtqueue *vq, wait_queue_head_t wq_head)
> +{
> +	unsigned int len;
> +
> +	virtqueue_kick(vq);
> +	wait_event(wq_head, virtqueue_get_buf(vq, &len));
> +}
> +
> +static void send_one_desc(struct virtio_balloon *vb,
> +			  struct virtqueue *vq,
> +			  uint64_t addr,
> +			  uint32_t len,
> +			  bool inbuf,
> +			  bool batch)
> +{
> +	int err;
> +	unsigned int size;
> +
> +	/* Detach all the used buffers from the vq */
> +	while (virtqueue_get_buf(vq, &size))
> +		;
> +
> +	err = virtqueue_add_one_desc(vq, addr, len, inbuf, vq);
> +	/*
> +	 * This is expected to never fail: there is always at least 1 entry
> +	 * available on the vq, because when the vq is full the worker thread
> +	 * that adds the desc will be put into sleep until at least 1 entry is
> +	 * available to use.
> +	 */
> +	BUG_ON(err);
> +
> +	/* If batching is requested, we batch till the vq is full */
> +	if (!batch || !vq->num_free)
> +		kick_and_wait(vq, vb->acked);
> +}
> +

This internal kick complicates callers. I suggest that instead,
you move this to callers, just return a "kick required" boolean.
This way callers do not need to play with num_free at all.

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
> +	unsigned long pfn_start, pfn_end;
> +	uint64_t addr;
> +	uint32_t len, max_len = round_down(UINT_MAX, PAGE_SIZE);
> +
> +	pfn_start = page_xb_start;
> +	while (pfn_start < page_xb_end) {
> +		pfn_start = xb_find_next_set_bit(&vb->page_xb, pfn_start,
> +						 page_xb_end);
> +		if (pfn_start == page_xb_end + 1)
> +			break;
> +		pfn_end = xb_find_next_zero_bit(&vb->page_xb,
> +						pfn_start + 1,
> +						page_xb_end);
> +		addr = pfn_start << PAGE_SHIFT;
> +		len = (pfn_end - pfn_start) << PAGE_SHIFT;

This assugnment can overflow. Next line compares with UINT_MAX but by
that time it is too late.  I think you should do all math in 64 bit to
avoid surprises, then truncate to max_len and then it's safe to assign
to sg.

> +		while (len > max_len) {
> +			send_one_desc(vb, vq, addr, max_len, true, true);
> +			addr += max_len;
> +			len -= max_len;
> +		}
> +		send_one_desc(vb, vq, addr, len, true, true);
> +		pfn_start = pfn_end + 1;
> +	}
> +
> +	/*
> +	 * The last few desc-s may not reach the batch size, but need a kick to
> +	 * notify the device to handle them.
> +	 */
> +	if (vq->num_free != virtqueue_get_vring_size(vq))
> +		kick_and_wait(vq, vb->acked);

the actual trigger for kick is if we did not kick after
the last send_one_desc. If kick is moved out of send_one_desc,
you can test for that explicitly.

> +
> +	xb_clear_bit_range(&vb->page_xb, page_xb_start, page_xb_end);
> +}
> +
> +static inline int xb_set_page(struct virtio_balloon *vb,
> +			       struct page *page,
> +			       unsigned long *pfn_min,
> +			       unsigned long *pfn_max)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +	int ret;
> +
> +	*pfn_min = min(pfn, *pfn_min);
> +	*pfn_max = max(pfn, *pfn_max);
> +
> +	do {
> +		ret = xb_preload_and_set_bit(&vb->page_xb, pfn,
> +					     GFP_NOWAIT | __GFP_NOWARN);
> +	} while (unlikely(ret == -EAGAIN));

what exactly does this loop do? Does this wait
forever until there is some free memory? why GFP_NOWAIT?

> +
> +	return ret;
> +}
> +
>  static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	unsigned num_allocated_pages;
>  	unsigned num_pfns;
>  	struct page *page;
>  	LIST_HEAD(pages);
> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
> +	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
>  
>  	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	if (!use_sg)
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	for (num_pfns = 0; num_pfns < num;
>  	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> @@ -172,11 +283,18 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  	vb->num_pfns = 0;
>  
>  	while ((page = balloon_page_pop(&pages))) {
> +		if (use_sg) {
> +			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
> +				__free_page(page);
> +				break;
> +			}
> +		} else {
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		}
> +
>  		balloon_page_enqueue(&vb->vb_dev_info, page);
>  
>  		vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE;
> -
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		if (!virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> @@ -185,8 +303,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
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
> @@ -212,9 +334,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
> @@ -224,7 +349,14 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  		page = balloon_page_dequeue(vb_dev_info);
>  		if (!page)
>  			break;
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (use_sg) {
> +			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
> +				balloon_page_enqueue(&vb->vb_dev_info, page);
> +				break;
> +			}
> +		} else {
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		}
>  		list_add(&page->lru, &pages);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -235,13 +367,55 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
>  }
>  
> +/*
> + * The regular leak_balloon() with VIRTIO_BALLOON_F_SG needs memory allocation
> + * for xbitmap, which is not suitable for the oom case. This function does not
> + * use xbitmap to chunk pages, so it can be used by oom notifier to deflate
> + * pages when VIRTIO_BALLOON_F_SG is negotiated.
> + */

I guess we can live with this for now.

Two things to consider
- adding support for pre-allocating indirect buffers
- sorting the internal page queue (how?)


> +static unsigned int leak_balloon_sg_oom(struct virtio_balloon *vb)
> +{
> +	unsigned int n;
> +	struct page *page;
> +	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
> +	struct virtqueue *vq = vb->deflate_vq;
> +	LIST_HEAD(pages);
> +
> +	mutex_lock(&vb->balloon_lock);
> +	for (n = 0; n < oom_pages; n++) {
> +		page = balloon_page_dequeue(vb_dev_info);
> +		if (!page)
> +			break;
> +
> +		list_add(&page->lru, &pages);
> +		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		send_one_desc(vb, vq, virt_to_phys(page_address(page)),
> +			      PAGE_SIZE, true, true);
> +		release_pages_balloon(vb, &pages);
> +	}
> +
> +	/*
> +	 * The last few sgs may not reach the batch size, but need a kick to
> +	 * notify the device to handle them.
> +	 */
> +	if (vq->num_free != virtqueue_get_vring_size(vq))
> +		kick_and_wait(vq, vb->acked);
> +	mutex_unlock(&vb->balloon_lock);
> +
> +	return n;
> +}
> +
>  static inline void update_stat(struct virtio_balloon *vb, int idx,
>  			       u16 tag, u64 val)
>  {
> @@ -381,7 +555,10 @@ static int virtballoon_oom_notify(struct notifier_block *self,
>  		return NOTIFY_OK;
>  
>  	freed = parm;
> -	num_freed_pages = leak_balloon(vb, oom_pages);
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG))
> +		num_freed_pages = leak_balloon_sg_oom(vb);
> +	else
> +		num_freed_pages = leak_balloon(vb, oom_pages);
>  	update_balloon_size(vb);
>  	*freed += num_freed_pages;
>  
> @@ -478,6 +655,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  {
>  	struct virtio_balloon *vb = container_of(vb_dev_info,
>  			struct virtio_balloon, vb_dev_info);
> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
>  	unsigned long flags;
>  
>  	/*
> @@ -499,16 +677,26 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	vb_dev_info->isolated_pages--;
>  	__count_vm_event(BALLOON_MIGRATE);
>  	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
> -	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> -	set_page_pfns(vb, vb->pfns, newpage);
> -	tell_host(vb, vb->inflate_vq);
> -
> +	if (use_sg) {
> +		send_one_desc(vb, vb->inflate_vq,
> +			      virt_to_phys(page_address(newpage)),
> +			      PAGE_SIZE, true, false);
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
> +		send_one_desc(vb, vb->inflate_vq,
> +			      virt_to_phys(page_address(page)),
> +			      PAGE_SIZE, true, false);
> +	} else {
> +		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, vb->pfns, page);
> +		tell_host(vb, vb->deflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	put_page(page); /* balloon reference */
> @@ -567,6 +755,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
> +		xb_init(&vb->page_xb);
> +
>  	vb->nb.notifier_call = virtballoon_oom_notify;
>  	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err = register_oom_notifier(&vb->nb);
> @@ -683,6 +874,7 @@ static unsigned int features[] = {
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
