Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1339A440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 20:44:33 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g53so14949390qtc.6
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 17:44:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i4si3779913qte.203.2017.07.12.17.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 17:44:31 -0700 (PDT)
Date: Thu, 13 Jul 2017 03:44:21 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20170713033352-mutt-send-email-mst@kernel.org>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-6-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499863221-16206-6-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Wed, Jul 12, 2017 at 08:40:18PM +0800, Wei Wang wrote:
> Add a new feature, VIRTIO_BALLOON_F_SG, which enables to
> transfer a chunk of ballooned (i.e. inflated/deflated) pages using
> scatter-gather lists to the host.
> 
> The implementation of the previous virtio-balloon is not very
> efficient, because the balloon pages are transferred to the
> host one by one. Here is the breakdown of the time in percentage
> spent on each step of the balloon inflating process (inflating
> 7GB of an 8GB idle guest).
> 
> 1) allocating pages (6.5%)
> 2) sending PFNs to host (68.3%)
> 3) address translation (6.1%)
> 4) madvise (19%)
> 
> It takes about 4126ms for the inflating process to complete.
> The above profiling shows that the bottlenecks are stage 2)
> and stage 4).
> 
> This patch optimizes step 2) by transferring pages to the host in
> sgs. An sg describes a chunk of guest physically continuous pages.
> With this mechanism, step 4) can also be optimized by doing address
> translation and madvise() in chunks rather than page by page.
> 
> With this new feature, the above ballooning process takes ~491ms
> resulting in an improvement of ~88%.
> 
> TODO: optimize stage 1) by allocating/freeing a chunk of pages
> instead of a single page each time.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 141 ++++++++++++++++++++++---
>  drivers/virtio/virtio_ring.c        | 199 +++++++++++++++++++++++++++++++++---
>  include/linux/virtio.h              |  20 ++++
>  include/uapi/linux/virtio_balloon.h |   1 +
>  4 files changed, 329 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index f0b3a0b..aa4e7ec 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -32,6 +32,7 @@
>  #include <linux/mm.h>
>  #include <linux/mount.h>
>  #include <linux/magic.h>
> +#include <linux/xbitmap.h>
>  
>  /*
>   * Balloon device works in 4K page units.  So each page is pointed to by
> @@ -79,6 +80,9 @@ struct virtio_balloon {
>  	/* Synchronize access/update to this struct virtio_balloon elements */
>  	struct mutex balloon_lock;
>  
> +	/* The xbitmap used to record ballooned pages */
> +	struct xb page_xb;
> +
>  	/* The array of pfns we tell the Host about. */
>  	unsigned int num_pfns;
>  	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
> @@ -141,13 +145,71 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  					  page_to_balloon_pfn(page) + i);
>  }
>  
> +/*
> + * Send balloon pages in sgs to host.
> + * The balloon pages are recorded in the page xbitmap. Each bit in the bitmap
> + * corresponds to a page of PAGE_SIZE. The page xbitmap is searched for
> + * continuous "1" bits, which correspond to continuous pages, to chunk into
> + * sgs.
> + *
> + * @page_xb_start and @page_xb_end form the range of bits in the xbitmap that
> + * need to be serached.

searched

> + */
> +static void tell_host_sgs(struct virtio_balloon *vb,
> +			  struct virtqueue *vq,
> +			  unsigned long page_xb_start,
> +			  unsigned long page_xb_end)
> +{
> +	unsigned int head_id = VIRTQUEUE_DESC_ID_INIT,
> +		     prev_id = VIRTQUEUE_DESC_ID_INIT;
> +	unsigned long sg_pfn_start, sg_pfn_end;
> +	uint64_t sg_addr;
> +	uint32_t sg_size;
> +
> +	sg_pfn_start = page_xb_start;
> +	while (sg_pfn_start < page_xb_end) {
> +		sg_pfn_start = xb_find_next_bit(&vb->page_xb, sg_pfn_start,
> +						page_xb_end, 1);
> +		if (sg_pfn_start == page_xb_end + 1)
> +			break;
> +		sg_pfn_end = xb_find_next_bit(&vb->page_xb, sg_pfn_start + 1,
> +					      page_xb_end, 0);
> +		sg_addr = sg_pfn_start << PAGE_SHIFT;
> +		sg_size = (sg_pfn_end - sg_pfn_start) * PAGE_SIZE;

There's an issue here - this might not fit in uint32_t.
You need to limit sg_pfn_end - something like:

	/* make sure sg_size below fits in a 32 bit integer */
	sg_pfn_end = min(sg_pfn_end, sg_pfn_start + UINT_MAX >> PAGE_SIZE);

> +		virtqueue_add_chain_desc(vq, sg_addr, sg_size, &head_id,
> +					 &prev_id, 0);
> +		xb_zero(&vb->page_xb, sg_pfn_start, sg_pfn_end);
> +		sg_pfn_start = sg_pfn_end + 1;
> +	}
> +
> +	if (head_id != VIRTQUEUE_DESC_ID_INIT) {
> +		virtqueue_add_chain(vq, head_id, 0, NULL, vb, NULL);
> +		virtqueue_kick_async(vq, vb->acked);
> +	}
> +}
> +
> +/* Update pfn_max and pfn_min according to the pfn of @page */
> +static inline void update_pfn_range(struct virtio_balloon *vb,
> +				    struct page *page,
> +				    unsigned long *pfn_min,
> +				    unsigned long *pfn_max)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +
> +	*pfn_min = min(pfn, *pfn_min);
> +	*pfn_max = max(pfn, *pfn_max);
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
> @@ -162,7 +224,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  			msleep(200);
>  			break;
>  		}
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (use_sg) {
> +			update_pfn_range(vb, page, &pfn_min, &pfn_max);
> +			xb_set_bit(&vb->page_xb, page_to_pfn(page));
> +		} else {
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		}
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		if (!virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> @@ -171,8 +238,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  
>  	num_allocated_pages = vb->num_pfns;
>  	/* Did we get any? */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->inflate_vq);
> +	if (vb->num_pfns != 0) {
> +		if (use_sg)
> +			tell_host_sgs(vb, vb->inflate_vq, pfn_min, pfn_max);
> +		else
> +			tell_host(vb, vb->inflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	return num_allocated_pages;
> @@ -198,9 +269,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
> @@ -210,7 +284,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  		page = balloon_page_dequeue(vb_dev_info);
>  		if (!page)
>  			break;
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		if (use_sg) {
> +			update_pfn_range(vb, page, &pfn_min, &pfn_max);
> +			xb_set_bit(&vb->page_xb, page_to_pfn(page));
> +		} else {
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		}
>  		list_add(&page->lru, &pages);
>  		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
>  	}
> @@ -221,8 +300,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>  	 * is true, we *have* to do it in this order
>  	 */
> -	if (vb->num_pfns != 0)
> -		tell_host(vb, vb->deflate_vq);
> +	if (vb->num_pfns != 0) {
> +		if (use_sg)
> +			tell_host_sgs(vb, vb->deflate_vq, pfn_min, pfn_max);
> +		else
> +			tell_host(vb, vb->deflate_vq);
> +	}
>  	release_pages_balloon(vb, &pages);
>  	mutex_unlock(&vb->balloon_lock);
>  	return num_freed_pages;
> @@ -441,6 +524,18 @@ static int init_vqs(struct virtio_balloon *vb)
>  }
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
> +
> +static void tell_host_one_page(struct virtio_balloon *vb, struct virtqueue *vq,
> +			       struct page *page)
> +{
> +	unsigned int id = VIRTQUEUE_DESC_ID_INIT;
> +	u64 addr = page_to_pfn(page) << VIRTIO_BALLOON_PFN_SHIFT;
> +
> +	virtqueue_add_chain_desc(vq, addr, PAGE_SIZE, &id, &id, 0);
> +	virtqueue_add_chain(vq, id, 0, NULL, (void *)addr, NULL);
> +	virtqueue_kick_async(vq, vb->acked);
> +}
> +
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
>   *			     a compation thread.     (called under page lock)
> @@ -464,6 +559,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  {
>  	struct virtio_balloon *vb = container_of(vb_dev_info,
>  			struct virtio_balloon, vb_dev_info);
> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
>  	unsigned long flags;
>  
>  	/*
> @@ -485,16 +581,22 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	vb_dev_info->isolated_pages--;
>  	__count_vm_event(BALLOON_MIGRATE);
>  	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
> -	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> -	set_page_pfns(vb, vb->pfns, newpage);
> -	tell_host(vb, vb->inflate_vq);
> -
> +	if (use_sg) {
> +		tell_host_one_page(vb, vb->inflate_vq, newpage);
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
> +		tell_host_one_page(vb, vb->deflate_vq, page);
> +	} else {
> +		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
> +		set_page_pfns(vb, vb->pfns, page);
> +		tell_host(vb, vb->deflate_vq);
> +	}
>  	mutex_unlock(&vb->balloon_lock);
>  
>  	put_page(page); /* balloon reference */
> @@ -553,6 +655,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
> +		xb_init(&vb->page_xb);
> +
>  	vb->nb.notifier_call = virtballoon_oom_notify;
>  	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err = register_oom_notifier(&vb->nb);
> @@ -618,6 +723,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	cancel_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
>  
> +	xb_empty(&vb->page_xb);
>  	remove_common(vb);
>  #ifdef CONFIG_BALLOON_COMPACTION
>  	if (vb->vb_dev_info.inode)
> @@ -669,6 +775,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_SG,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index 5e1b548..b9d7e10 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -269,7 +269,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
>  	struct vring_virtqueue *vq = to_vvq(_vq);
>  	struct scatterlist *sg;
>  	struct vring_desc *desc;
> -	unsigned int i, n, avail, descs_used, uninitialized_var(prev), err_idx;
> +	unsigned int i, n, descs_used, uninitialized_var(prev), err_id;
>  	int head;
>  	bool indirect;
>  
> @@ -387,10 +387,68 @@ static inline int virtqueue_add(struct virtqueue *_vq,
>  	else
>  		vq->free_head = i;
>  
> -	/* Store token and indirect buffer state. */
> +	END_USE(vq);
> +
> +	return virtqueue_add_chain(_vq, head, indirect, desc, data, ctx);
> +
> +unmap_release:
> +	err_id = i;
> +	i = head;
> +
> +	for (n = 0; n < total_sg; n++) {
> +		if (i == err_id)
> +			break;
> +		vring_unmap_one(vq, &desc[i]);
> +		i = virtio16_to_cpu(_vq->vdev, vq->vring.desc[i].next);
> +	}
> +
> +	vq->vq.num_free += total_sg;
> +
> +	if (indirect)
> +		kfree(desc);
> +
> +	END_USE(vq);
> +	return -EIO;
> +}
> +
> +/**
> + * virtqueue_add_chain - expose a chain of buffers to the other end
> + * @_vq: the struct virtqueue we're talking about.
> + * @head: desc id of the chain head.
> + * @indirect: set if the chain of descs are indrect descs.
> + * @indir_desc: the first indirect desc.
> + * @data: the token identifying the chain.
> + * @ctx: extra context for the token.
> + *
> + * Caller must ensure we don't call this with other virtqueue operations
> + * at the same time (except where noted).
> + *
> + * Returns zero or a negative error (ie. ENOSPC, ENOMEM, EIO).
> + */
> +int virtqueue_add_chain(struct virtqueue *_vq,
> +			unsigned int head,
> +			bool indirect,
> +			struct vring_desc *indir_desc,
> +			void *data,
> +			void *ctx)
> +{
> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +	unsigned int avail;
> +
> +	/* The desc chain is empty. */
> +	if (head == VIRTQUEUE_DESC_ID_INIT)
> +		return 0;
> +
> +	START_USE(vq);
> +
> +	if (unlikely(vq->broken)) {
> +		END_USE(vq);
> +		return -EIO;
> +	}
> +
>  	vq->desc_state[head].data = data;
>  	if (indirect)
> -		vq->desc_state[head].indir_desc = desc;
> +		vq->desc_state[head].indir_desc = indir_desc;
>  	if (ctx)
>  		vq->desc_state[head].indir_desc = ctx;
>  
> @@ -415,26 +473,87 @@ static inline int virtqueue_add(struct virtqueue *_vq,
>  		virtqueue_kick(_vq);
>  
>  	return 0;
> +}
> +EXPORT_SYMBOL_GPL(virtqueue_add_chain);
>  
> -unmap_release:
> -	err_idx = i;
> -	i = head;
> +/**
> + * virtqueue_add_chain_desc - add a buffer to a chain using a vring desc
> + * @vq: the struct virtqueue we're talking about.
> + * @addr: address of the buffer to add.
> + * @len: length of the buffer.
> + * @head_id: desc id of the chain head.
> + * @prev_id: desc id of the previous buffer.
> + * @in: set if the buffer is for the device to write.
> + *
> + * Caller must ensure we don't call this with other virtqueue operations
> + * at the same time (except where noted).
> + *
> + * Returns zero or a negative error (ie. ENOSPC, ENOMEM, EIO).
> + */
> +int virtqueue_add_chain_desc(struct virtqueue *_vq,
> +			     uint64_t addr,
> +			     uint32_t len,
> +			     unsigned int *head_id,
> +			     unsigned int *prev_id,
> +			     bool in)
> +{
> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +	struct vring_desc *desc = vq->vring.desc;
> +	uint16_t flags = in ? VRING_DESC_F_WRITE : 0;
> +	unsigned int i;
>  
> -	for (n = 0; n < total_sg; n++) {
> -		if (i == err_idx)
> -			break;
> -		vring_unmap_one(vq, &desc[i]);
> -		i = virtio16_to_cpu(_vq->vdev, vq->vring.desc[i].next);
> +	/* Sanity check */
> +	if (!_vq || !head_id || !prev_id)
> +		return -EINVAL;
> +retry:
> +	START_USE(vq);
> +	if (unlikely(vq->broken)) {
> +		END_USE(vq);
> +		return -EIO;
>  	}
>  
> -	vq->vq.num_free += total_sg;
> +	if (vq->vq.num_free < 1) {
> +		/*
> +		 * If there is no desc avail in the vq, so kick what is
> +		 * already added, and re-start to build a new chain for
> +		 * the passed sg.
> +		 */
> +		if (likely(*head_id != VIRTQUEUE_DESC_ID_INIT)) {
> +			END_USE(vq);
> +			virtqueue_add_chain(_vq, *head_id, 0, NULL, vq, NULL);
> +			virtqueue_kick_sync(_vq);
> +			*head_id = VIRTQUEUE_DESC_ID_INIT;
> +			*prev_id = VIRTQUEUE_DESC_ID_INIT;
> +			goto retry;
> +		} else {
> +			END_USE(vq);
> +			return -ENOSPC;
> +		}
> +	}
>  
> -	if (indirect)
> -		kfree(desc);
> +	i = vq->free_head;
> +	flags &= ~VRING_DESC_F_NEXT;
> +	desc[i].flags = cpu_to_virtio16(_vq->vdev, flags);
> +	desc[i].addr = cpu_to_virtio64(_vq->vdev, addr);
> +	desc[i].len = cpu_to_virtio32(_vq->vdev, len);
> +
> +	/* Add the desc to the end of the chain */
> +	if (*prev_id != VIRTQUEUE_DESC_ID_INIT) {
> +		desc[*prev_id].next = cpu_to_virtio16(_vq->vdev, i);
> +		desc[*prev_id].flags |= cpu_to_virtio16(_vq->vdev,
> +							 VRING_DESC_F_NEXT);
> +	}
> +	*prev_id = i;
> +	if (*head_id == VIRTQUEUE_DESC_ID_INIT)
> +		*head_id = *prev_id;
>  
> +	vq->vq.num_free--;
> +	vq->free_head = virtio16_to_cpu(_vq->vdev, desc[i].next);
>  	END_USE(vq);
> -	return -EIO;
> +
> +	return 0;
>  }
> +EXPORT_SYMBOL_GPL(virtqueue_add_chain_desc);
>  
>  /**
>   * virtqueue_add_sgs - expose buffers to other end
> @@ -627,6 +746,56 @@ bool virtqueue_kick(struct virtqueue *vq)
>  }
>  EXPORT_SYMBOL_GPL(virtqueue_kick);
>  
> +/**
> + * virtqueue_kick_sync - update after add_buf and busy wait till update is done
> + * @vq: the struct virtqueue
> + *
> + * After one or more virtqueue_add_* calls, invoke this to kick
> + * the other side. Busy wait till the other side is done with the update.
> + *
> + * Caller must ensure we don't call this with other virtqueue
> + * operations at the same time (except where noted).
> + *
> + * Returns false if kick failed, otherwise true.
> + */
> +bool virtqueue_kick_sync(struct virtqueue *vq)
> +{
> +	u32 len;
> +
> +	if (likely(virtqueue_kick(vq))) {
> +		while (!virtqueue_get_buf(vq, &len) &&
> +		       !virtqueue_is_broken(vq))
> +			cpu_relax();
> +		return true;
> +	}
> +	return false;
> +}
> +EXPORT_SYMBOL_GPL(virtqueue_kick_sync);
> +
> +/**
> + * virtqueue_kick_async - update after add_buf and blocking till update is done
> + * @vq: the struct virtqueue
> + *
> + * After one or more virtqueue_add_* calls, invoke this to kick
> + * the other side. Blocking till the other side is done with the update.
> + *
> + * Caller must ensure we don't call this with other virtqueue
> + * operations at the same time (except where noted).
> + *
> + * Returns false if kick failed, otherwise true.
> + */
> +bool virtqueue_kick_async(struct virtqueue *vq, wait_queue_head_t wq)
> +{
> +	u32 len;
> +
> +	if (likely(virtqueue_kick(vq))) {
> +		wait_event(wq, virtqueue_get_buf(vq, &len));
> +		return true;
> +	}
> +	return false;
> +}
> +EXPORT_SYMBOL_GPL(virtqueue_kick_async);
> +

This happens to
1. drop the buf
2. not do the right thing if more than one is in flight

which means this API isn't all that useful. Even balloon
might benefit from keeping multiple bufs in flight down
the road.


>  static void detach_buf(struct vring_virtqueue *vq, unsigned int head,
>  		       void **ctx)
>  {
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 28b0e96..9f27101 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -57,8 +57,28 @@ int virtqueue_add_sgs(struct virtqueue *vq,
>  		      void *data,
>  		      gfp_t gfp);
>  
> +/* A desc with this init id is treated as an invalid desc */
> +#define VIRTQUEUE_DESC_ID_INIT UINT_MAX
> +int virtqueue_add_chain_desc(struct virtqueue *_vq,
> +			     uint64_t addr,
> +			     uint32_t len,
> +			     unsigned int *head_id,
> +			     unsigned int *prev_id,
> +			     bool in);
> +
> +int virtqueue_add_chain(struct virtqueue *_vq,
> +			unsigned int head,
> +			bool indirect,
> +			struct vring_desc *indirect_desc,
> +			void *data,
> +			void *ctx);
> +
>  bool virtqueue_kick(struct virtqueue *vq);
>  
> +bool virtqueue_kick_sync(struct virtqueue *vq);
> +
> +bool virtqueue_kick_async(struct virtqueue *vq, wait_queue_head_t wq);
> +
>  bool virtqueue_kick_prepare(struct virtqueue *vq);
>  
>  bool virtqueue_notify(struct virtqueue *vq);
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
