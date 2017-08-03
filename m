Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E78A96B06A8
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 08:34:03 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l22so5395632qtf.9
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 05:34:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y62si31356853qke.380.2017.08.03.05.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 05:34:02 -0700 (PDT)
Date: Thu, 3 Aug 2017 15:33:54 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v13 5/5] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20170803152739-mutt-send-email-mst@kernel.org>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
 <1501742299-4369-6-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501742299-4369-6-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Thu, Aug 03, 2017 at 02:38:19PM +0800, Wei Wang wrote:
> Add a new vq to report hints of guest free pages to the host.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 164 ++++++++++++++++++++++++++++++------
>  include/uapi/linux/virtio_balloon.h |   1 +
>  2 files changed, 140 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 29aca0c..29c4a61 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -54,11 +54,12 @@ static struct vfsmount *balloon_mnt;
>  
>  struct virtio_balloon {
>  	struct virtio_device *vdev;
> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
>  
>  	/* The balloon servicing is delegated to a freezable workqueue. */
>  	struct work_struct update_balloon_stats_work;
>  	struct work_struct update_balloon_size_work;
> +	struct work_struct report_free_page_work;
>  
>  	/* Prevent updating balloon when it is being canceled. */
>  	spinlock_t stop_update_lock;
> @@ -90,6 +91,13 @@ struct virtio_balloon {
>  	/* Memory statistics */
>  	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
>  
> +	/*
> +	 * Used by the device and driver to signal each other.
> +	 * device->driver: start the free page report.
> +	 * driver->device: end the free page report.
> +	 */
> +	__virtio32 report_free_page_signal;
> +
>  	/* To register callback in oom notifier call chain */
>  	struct notifier_block nb;
>  };
> @@ -146,7 +154,7 @@ static void set_page_pfns(struct virtio_balloon *vb,
>  }
>  
>  static void send_one_sg(struct virtio_balloon *vb, struct virtqueue *vq,
> -			void *addr, uint32_t size)
> +			void *addr, uint32_t size, bool busywait)
>  {
>  	struct scatterlist sg;
>  	unsigned int len;
> @@ -165,7 +173,12 @@ static void send_one_sg(struct virtio_balloon *vb, struct virtqueue *vq,
>  			cpu_relax();
>  	}
>  	virtqueue_kick(vq);
> -	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> +	if (busywait)
> +		while (!virtqueue_get_buf(vq, &len) &&
> +		       !virtqueue_is_broken(vq))
> +			cpu_relax();
> +	else
> +		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
>  }
>  
>  /*
> @@ -197,11 +210,11 @@ static void tell_host_sgs(struct virtio_balloon *vb,
>  		sg_addr = pfn_to_kaddr(sg_pfn_start);
>  		sg_len = (sg_pfn_end - sg_pfn_start) << PAGE_SHIFT;
>  		while (sg_len > sg_max_len) {
> -			send_one_sg(vb, vq, sg_addr, sg_max_len);
> +			send_one_sg(vb, vq, sg_addr, sg_max_len, 0);
>  			sg_addr += sg_max_len;
>  			sg_len -= sg_max_len;
>  		}
> -		send_one_sg(vb, vq, sg_addr, sg_len);
> +		send_one_sg(vb, vq, sg_addr, sg_len, 0);
>  		xb_zero(&vb->page_xb, sg_pfn_start, sg_pfn_end);
>  		sg_pfn_start = sg_pfn_end + 1;
>  	}
> @@ -503,42 +516,138 @@ static void update_balloon_size_func(struct work_struct *work)
>  		queue_work(system_freezable_wq, work);
>  }
>  
> +static void virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
> +					   unsigned long nr_pages)
> +{
> +	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
> +	void *addr = pfn_to_kaddr(pfn);
> +	uint32_t len = nr_pages << PAGE_SHIFT;
> +
> +	send_one_sg(vb, vb->free_page_vq, addr, len, 1);
> +}
> +
> +static void report_free_page_completion(struct virtio_balloon *vb)
> +{
> +	struct virtqueue *vq = vb->free_page_vq;
> +	struct scatterlist sg;
> +	unsigned int len;
> +
> +	sg_init_one(&sg, &vb->report_free_page_signal, sizeof(__virtio32));
> +	while (unlikely(virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL)
> +			== -ENOSPC)) {
> +		virtqueue_kick(vq);
> +		while (!virtqueue_get_buf(vq, &len) &&
> +		       !virtqueue_is_broken(vq))
> +			cpu_relax();
> +	}
> +	virtqueue_kick(vq);
> +}

This unlimited busy waiting needs to go away. A bit of polling might be
ok but even though it'd be better off as a separate driver.  You do not
want to peg CPU for unlimited periods of time for something that's an
optimization.

> +
> +static void report_free_page(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +
> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> +	walk_free_mem_block(vb, 1, &virtio_balloon_send_free_pages);
> +	report_free_page_completion(vb);
> +}
> +
> +static void free_page_request(struct virtqueue *vq)
> +{
> +	struct virtio_balloon *vb = vq->vdev->priv;
> +
> +	queue_work(system_freezable_wq, &vb->report_free_page_work);
> +}
> +
>  static int init_vqs(struct virtio_balloon *vb)
>  {
> -	struct virtqueue *vqs[3];
> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
> -	static const char * const names[] = { "inflate", "deflate", "stats" };
> -	int err, nvqs;
> +	struct virtqueue **vqs;
> +	vq_callback_t **callbacks;
> +	const char **names;
> +	struct scatterlist sg;
> +	int i, nvqs, err = -ENOMEM;
> +
> +	/* Inflateq and deflateq are used unconditionally */
> +	nvqs = 2;
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
> +		nvqs++;
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
> +		nvqs++;
> +
> +	/* Allocate space for find_vqs parameters */
> +	vqs = kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
> +	if (!vqs)
> +		goto err_vq;
> +	callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
> +	if (!callbacks)
> +		goto err_callback;
> +	names = kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
> +	if (!names)
> +		goto err_names;
> +
> +	callbacks[0] = balloon_ack;
> +	names[0] = "inflate";
> +	callbacks[1] = balloon_ack;
> +	names[1] = "deflate";
> +
> +	i = 2;
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +		callbacks[i] = stats_request;
> +		names[i] = "stats";
> +		i++;
> +	}
>  
> -	/*
> -	 * We expect two virtqueues: inflate and deflate, and
> -	 * optionally stat.
> -	 */
> -	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> -	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
> +		callbacks[i] = free_page_request;
> +		names[i] = "free_page_vq";
> +	}
> +
> +	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names,
> +					 NULL, NULL);
>  	if (err)
> -		return err;
> +		goto err_find;
>  
>  	vb->inflate_vq = vqs[0];
>  	vb->deflate_vq = vqs[1];
> +	i = 2;
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> -		struct scatterlist sg;
> -		unsigned int num_stats;
> -		vb->stats_vq = vqs[2];
> -
> +		vb->stats_vq = vqs[i++];
>  		/*
>  		 * Prime this virtqueue with one buffer so the hypervisor can
>  		 * use it to signal us later (it can't be broken yet!).
>  		 */
> -		num_stats = update_balloon_stats(vb);
> -
> -		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
> +		sg_init_one(&sg, vb->stats, sizeof(vb->stats));
>  		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
>  		    < 0)
>  			BUG();
>  		virtqueue_kick(vb->stats_vq);
>  	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
> +		vb->free_page_vq = vqs[i];
> +		vb->report_free_page_signal = 0;
> +		sg_init_one(&sg, &vb->report_free_page_signal,
> +			    sizeof(__virtio32));
> +		if (virtqueue_add_outbuf(vb->free_page_vq, &sg, 1, vb,
> +					 GFP_KERNEL) < 0)
> +			dev_warn(&vb->vdev->dev, "%s: add signal buf fail\n",

failed.

And we likely want to fail probe here.

> +				 __func__);
> +		virtqueue_kick(vb->free_page_vq);
> +	}
> +
> +	kfree(names);
> +	kfree(callbacks);
> +	kfree(vqs);
>  	return 0;
> +
> +err_find:
> +	kfree(names);
> +err_names:
> +	kfree(callbacks);
> +err_callback:
> +	kfree(vqs);
> +err_vq:
> +	return err;
>  }
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
> @@ -590,7 +699,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
>  	if (use_sg) {
>  		send_one_sg(vb, vb->inflate_vq, page_address(newpage),
> -			    PAGE_SIZE);
> +			    PAGE_SIZE, 0);
>  	} else {
>  		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		set_page_pfns(vb, vb->pfns, newpage);
> @@ -600,7 +709,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
>  	balloon_page_delete(page);
>  	if (use_sg) {
>  		send_one_sg(vb, vb->deflate_vq, page_address(page),
> -			    PAGE_SIZE);
> +			    PAGE_SIZE, 0);
>  	} else {
>  		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		set_page_pfns(vb, vb->pfns, page);
> @@ -667,6 +776,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
>  		xb_init(&vb->page_xb);
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
> +		INIT_WORK(&vb->report_free_page_work, report_free_page);
> +
>  	vb->nb.notifier_call = virtballoon_oom_notify;
>  	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err = register_oom_notifier(&vb->nb);
> @@ -731,6 +843,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	spin_unlock_irq(&vb->stop_update_lock);
>  	cancel_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
> +	cancel_work_sync(&vb->report_free_page_work);
>  
>  	xb_empty(&vb->page_xb);
>  	remove_common(vb);
> @@ -785,6 +898,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>  	VIRTIO_BALLOON_F_SG,
> +	VIRTIO_BALLOON_F_FREE_PAGE_VQ,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 37780a7..8214f84 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -35,6 +35,7 @@
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */
> +#define VIRTIO_BALLOON_F_FREE_PAGE_VQ	4 /* Virtqueue to report free pages */
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
