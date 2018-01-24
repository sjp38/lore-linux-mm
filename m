Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12C66800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 12:16:01 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id n13so2918869ote.13
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 09:16:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 30si1107529otn.505.2018.01.24.09.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 09:15:59 -0800 (PST)
Date: Wed, 24 Jan 2018 19:15:12 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v24 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180124183349-mutt-send-email-mst@kernel.org>
References: <1516790562-37889-1-git-send-email-wei.w.wang@intel.com>
 <1516790562-37889-3-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1516790562-37889-3-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Wed, Jan 24, 2018 at 06:42:42PM +0800, Wei Wang wrote:
> Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
> support of reporting hints of guest free pages to host via virtio-balloon.
> 
> Host requests the guest to report free pages by sending a new cmd
> id to the guest via the free_page_report_cmd_id configuration register.
> 
> When the guest starts to report, the first element added to the free page
> vq is the cmd id given by host. When the guest finishes the reporting
> of all the free pages, VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID is added
> to the vq to tell host that the reporting is done. Host may also requests
> the guest to stop the reporting in advance by sending the stop cmd id to
> the guest via the configuration register.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> ---
>  drivers/virtio/virtio_balloon.c     | 265 +++++++++++++++++++++++++++++++-----
>  include/uapi/linux/virtio_balloon.h |   7 +
>  2 files changed, 236 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index a1fb52c..4440873 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -51,9 +51,21 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>  static struct vfsmount *balloon_mnt;
>  #endif
>  
> +/* The number of virtqueues supported by virtio-balloon */
> +#define VIRTIO_BALLOON_VQ_NUM		4
> +#define VIRTIO_BALLOON_VQ_ID_INFLATE	0
> +#define VIRTIO_BALLOON_VQ_ID_DEFLATE	1
> +#define VIRTIO_BALLOON_VQ_ID_STATS	2
> +#define VIRTIO_BALLOON_VQ_ID_FREE_PAGE	3
> +

Please do an enum instead of defines. VQ_ID can be just VQ
(it's not an ID, it's just the number).


>  struct virtio_balloon {
>  	struct virtio_device *vdev;
> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
> +
> +	/* Balloon's own wq for cpu-intensive work items */
> +	struct workqueue_struct *balloon_wq;
> +	/* The free page reporting work item submitted to the balloon wq */
> +	struct work_struct report_free_page_work;
>  
>  	/* The balloon servicing is delegated to a freezable workqueue. */
>  	struct work_struct update_balloon_stats_work;
> @@ -63,6 +75,13 @@ struct virtio_balloon {
>  	spinlock_t stop_update_lock;
>  	bool stop_update;
>  
> +	/* Start to report free pages */
> +	bool report_free_page;
> +	/* Stores the cmd id given by host to start the free page reporting */
> +	__virtio32 start_cmd_id;
> +	/* Stores STOP_ID as a sign to tell host that the reporting is done */
> +	__virtio32 stop_cmd_id;
> +
>  	/* Waiting for host to ack the pages we released. */
>  	wait_queue_head_t acked;
>  
> @@ -281,6 +300,53 @@ static unsigned int update_balloon_stats(struct virtio_balloon *vb)
>  	return idx;
>  }
>  
> +static int add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
> +{
> +	struct scatterlist sg;
> +	unsigned int unused;
> +	int ret = 0;
> +
> +	sg_init_table(&sg, 1);
> +	sg_set_page(&sg, pfn_to_page(pfn), len, 0);
> +
> +	/* Detach all the used buffers from the vq */
> +	while (virtqueue_get_buf(vq, &unused))
> +		;
> +
> +	/*
> +	 * Since this is an optimization feature, losing a couple of free
> +	 * pages to report isn't important. We simply return without adding
> +	 * the page if the vq is full.
> +	 * We are adding one entry each time, which essentially results in no
> +	 * memory allocation, so the GFP_KERNEL flag below can be ignored.
> +	 * There is always one entry reserved for the cmd id to use.
> +	 */
> +	if (vq->num_free > 1)
> +		ret = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> +
> +	if (vq->num_free < virtqueue_get_vring_size(vq) / 2)
> +		virtqueue_kick(vq);
> +
> +	return ret;
> +}
> +
> +static void send_cmd_id(struct virtio_balloon *vb, __virtio32 *cmd_id)
> +{
> +	struct scatterlist sg;
> +	struct virtqueue *vq = vb->free_page_vq;
> +
> +	if (unlikely(!virtio_has_feature(vb->vdev,
> +				         VIRTIO_BALLOON_F_FREE_PAGE_HINT)))
> +		return;
> +
> +	sg_init_one(&sg, cmd_id, sizeof(*cmd_id));
> +
> +	if (virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL))
> +		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT);

What is this doing? Basically handling the case where vq is broken?
It's kind of ugly to tweak feature bits, most code assumes they never
change.  Please just return an error to caller instead and handle it
there.

You can then avoid sprinking the check for the feature bit
all over the code.

> +
> +	virtqueue_kick(vq);
> +}
> +
>  /*
>   * While most virtqueues communicate guest-initiated requests to the hypervisor,
>   * the stats queue operates in reverse.  The driver initializes the virtqueue
> @@ -316,17 +382,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
>  	virtqueue_kick(vq);
>  }
>  
> -static void virtballoon_changed(struct virtio_device *vdev)
> -{
> -	struct virtio_balloon *vb = vdev->priv;
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&vb->stop_update_lock, flags);
> -	if (!vb->stop_update)
> -		queue_work(system_freezable_wq, &vb->update_balloon_size_work);
> -	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> -}
> -
>  static inline s64 towards_target(struct virtio_balloon *vb)
>  {
>  	s64 target;
> @@ -343,6 +398,49 @@ static inline s64 towards_target(struct virtio_balloon *vb)
>  	return target - vb->num_pages;
>  }
>  
> +static void virtballoon_changed(struct virtio_device *vdev)
> +{
> +	struct virtio_balloon *vb = vdev->priv;
> +	unsigned long flags;
> +	__u32 cmd_id;
> +	s64 diff = towards_target(vb);
> +
> +	if (diff) {
> +		spin_lock_irqsave(&vb->stop_update_lock, flags);
> +		if (!vb->stop_update)
> +			queue_work(system_freezable_wq,
> +				   &vb->update_balloon_size_work);
> +		spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> +	}
> +
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		virtio_cread(vdev, struct virtio_balloon_config,
> +			     free_page_report_cmd_id, &cmd_id);
> +		if (cmd_id == VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID) {
> +			vb->report_free_page = false;
> +		} else {
> +			/*
> +			 * The request is queued only when the ack of the
> +			 * previous request has been sent to host, which is
> +			 * indicated by start_cmd_id set to
> +			 * VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID. Otherwise,
> +			 * simply update the start_cmd_id, and when the
> +			 * previous queued work runs, the latest cmd id will
> +			 * be sent to host.
> +			 */

One thing I don't like about this one is that the previous request
will still try to run to completion.

And it all seems pretty complex.

How about:
- pass cmd id to a queued work
- queued work gets that cmd id, stores a copy and uses that,
  re-checking periodically - stop if cmd id changes:
  will replace  report_free_page too since that's set to
  stop.

This means you do not reuse the queued cmd id also
for the buffer - which is probably for the best.


> +			spin_lock_irqsave(&vb->stop_update_lock, flags);
> +			if (!vb->stop_update &&
> +			    virtio32_to_cpu(vdev, vb->start_cmd_id) ==
> +			    VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID)
> +				queue_work(vb->balloon_wq,
> +					   &vb->report_free_page_work);
> +			vb->report_free_page = true;
> +			vb->start_cmd_id = cpu_to_virtio32(vdev, cmd_id);
> +			spin_unlock_irqrestore(&vb->stop_update_lock, flags);

While it's ok to set cmd id here because of the lock, it is easier
to understand code if you set up everything before you queue the
command.


> +		}
> +	}
> +}
> +
>  static void update_balloon_size(struct virtio_balloon *vb)
>  {
>  	u32 actual = vb->num_pages;
> @@ -417,42 +515,108 @@ static void update_balloon_size_func(struct work_struct *work)
>  
>  static int init_vqs(struct virtio_balloon *vb)
>  {
> -	struct virtqueue *vqs[3];
> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
> -	static const char * const names[] = { "inflate", "deflate", "stats" };
> -	int err, nvqs;
> +	struct virtqueue *vqs[VIRTIO_BALLOON_VQ_NUM];
> +	vq_callback_t *callbacks[VIRTIO_BALLOON_VQ_NUM];
> +	const char *names[VIRTIO_BALLOON_VQ_NUM];
> +	struct scatterlist sg;
> +	int ret;
>  
>  	/*
> -	 * We expect two virtqueues: inflate and deflate, and
> -	 * optionally stat.
> +	 * Inflateq and deflateq are used unconditionally. The names[]
> +	 * will be NULL if the related feature is not enabled, which will
> +	 * cause no allocation for the corresponding virtqueue in find_vqs.
>  	 */
> -	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> -	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
> -	if (err)
> -		return err;
> +	callbacks[VIRTIO_BALLOON_VQ_ID_INFLATE] = balloon_ack;
> +	names[VIRTIO_BALLOON_VQ_ID_INFLATE] = "inflate";
> +	callbacks[VIRTIO_BALLOON_VQ_ID_DEFLATE] = balloon_ack;
> +	names[VIRTIO_BALLOON_VQ_ID_DEFLATE] = "deflate";
> +	names[VIRTIO_BALLOON_VQ_ID_STATS] = NULL;
> +	names[VIRTIO_BALLOON_VQ_ID_FREE_PAGE] = NULL;
>  
> -	vb->inflate_vq = vqs[0];
> -	vb->deflate_vq = vqs[1];
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> -		struct scatterlist sg;
> -		unsigned int num_stats;
> -		vb->stats_vq = vqs[2];
> +		names[VIRTIO_BALLOON_VQ_ID_STATS] = "stats";
> +		callbacks[VIRTIO_BALLOON_VQ_ID_STATS] = stats_request;
> +	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		names[VIRTIO_BALLOON_VQ_ID_FREE_PAGE] = "free_page_vq";
> +		callbacks[VIRTIO_BALLOON_VQ_ID_FREE_PAGE] = NULL;
> +	}
> +
> +	ret = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_NUM,
> +					 vqs, callbacks, names, NULL, NULL);
> +	if (ret)
> +		return ret;
>  
> +	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_ID_INFLATE];
> +	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_ID_DEFLATE];
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +		vb->stats_vq = vqs[VIRTIO_BALLOON_VQ_ID_STATS];
>  		/*
>  		 * Prime this virtqueue with one buffer so the hypervisor can
>  		 * use it to signal us later (it can't be broken yet!).
>  		 */
> -		num_stats = update_balloon_stats(vb);
> -
> -		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
> -		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
> -		    < 0)
> -			BUG();
> +		sg_init_one(&sg, vb->stats, sizeof(vb->stats));
> +		ret = virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb,
> +					   GFP_KERNEL);
> +		if (ret) {
> +			dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
> +				 __func__);
> +			return ret;
> +		}
>  		virtqueue_kick(vb->stats_vq);
>  	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
> +		vb->free_page_vq = vqs[VIRTIO_BALLOON_VQ_ID_FREE_PAGE];
> +
>  	return 0;
>  }
>  
> +static bool virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
> +					   unsigned long nr_pages)
> +{
> +	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
> +	uint32_t len = nr_pages << PAGE_SHIFT;
> +	int ret;
> +
> +	if (!vb->report_free_page ||
> +	    unlikely(!virtio_has_feature(vb->vdev,
> +				         VIRTIO_BALLOON_F_FREE_PAGE_HINT)))
> +		return false;
> +
> +	ret = add_one_sg(vb->free_page_vq, pfn, len);
> +	if (unlikely(ret))
> +		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT);
> +
> +	return !ret;
> +}
> +
> +static void report_free_page_func(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +	unsigned long flags;
> +
> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> +
> +	/* Start by sending the obtained cmd id to the host with an outbuf */
> +	send_cmd_id(vb, &vb->start_cmd_id);
> +
> +	/*
> +	 * Set start_cmd_id to VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID to
> +	 * indicate a new request can be queued.
> +	 */
> +	spin_lock_irqsave(&vb->stop_update_lock, flags);
> +	vb->start_cmd_id = cpu_to_virtio32(vb->vdev,
> +				VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
> +	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> +
> +	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);

Can you teach walk_free_mem_block to return the && of all
return calls, so caller knows whether it completed?


> +
> +	/* End by sending the stop id to the host with an outbuf */
> +	send_cmd_id(vb, &vb->stop_cmd_id);
> +}
> +
>  #ifdef CONFIG_BALLOON_COMPACTION
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
> @@ -537,6 +701,7 @@ static struct file_system_type balloon_fs = {
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> +	__u32 poison_val;
>  	int err;
>  
>  	if (!vdev->config->get) {
> @@ -566,18 +731,37 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		vb->balloon_wq = alloc_workqueue("balloon-wq",
> +					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);

balloon_wq is initialized conditionally here but destroyed
unconditionally below. That will crash when not initialized
I think.


> +		if (!vb->balloon_wq) {
> +			err = -ENOMEM;
> +			goto out_del_vqs;
> +		}
> +		INIT_WORK(&vb->report_free_page_work, report_free_page_func);
> +		vb->start_cmd_id = cpu_to_virtio32(vdev,
> +				VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
> +		vb->stop_cmd_id = cpu_to_virtio32(vdev,
> +				VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
> +		if(virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
> +			poison_val = PAGE_POISON;
> +			virtio_cwrite(vb->vdev, struct virtio_balloon_config,
> +				      poison_val, &poison_val);
> +		}
> +	}
> +
>  	vb->nb.notifier_call = virtballoon_oom_notify;
>  	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err = register_oom_notifier(&vb->nb);
>  	if (err < 0)
> -		goto out_del_vqs;
> +		goto out_del_balloon_wq;
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
>  	balloon_mnt = kern_mount(&balloon_fs);
>  	if (IS_ERR(balloon_mnt)) {
>  		err = PTR_ERR(balloon_mnt);
>  		unregister_oom_notifier(&vb->nb);
> -		goto out_del_vqs;
> +		goto out_del_balloon_wq;
>  	}
>  
>  	vb->vb_dev_info.migratepage = virtballoon_migratepage;
> @@ -587,7 +771,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		kern_unmount(balloon_mnt);
>  		unregister_oom_notifier(&vb->nb);
>  		vb->vb_dev_info.inode = NULL;
> -		goto out_del_vqs;
> +		goto out_del_balloon_wq;
>  	}
>  	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
>  #endif
> @@ -598,6 +782,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		virtballoon_changed(vdev);
>  	return 0;
>  
> +out_del_balloon_wq:
> +	destroy_workqueue(vb->balloon_wq);
>  out_del_vqs:
>  	vdev->config->del_vqs(vdev);
>  out_free_vb:
> @@ -630,6 +816,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	spin_unlock_irq(&vb->stop_update_lock);
>  	cancel_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
> +	cancel_work_sync(&vb->report_free_page_work);
> +	destroy_workqueue(vb->balloon_wq);
>  
>  	remove_common(vb);
>  #ifdef CONFIG_BALLOON_COMPACTION
> @@ -674,6 +862,9 @@ static int virtballoon_restore(struct virtio_device *vdev)
>  
>  static int virtballoon_validate(struct virtio_device *vdev)
>  {
> +	if (!page_poisoning_enabled())
> +		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_POISON);
> +
>  	__virtio_clear_bit(vdev, VIRTIO_F_IOMMU_PLATFORM);
>  	return 0;
>  }
> @@ -682,6 +873,8 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
> +	VIRTIO_BALLOON_F_PAGE_POISON,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7dd..3f97067 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,15 +34,22 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
> +#define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
>  
> +#define VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID		0
>  struct virtio_balloon_config {
>  	/* Number of pages host wants Guest to give up. */
>  	__u32 num_pages;
>  	/* Number of pages we've actually got in balloon. */
>  	__u32 actual;
> +	/* Free page report command id, readonly by guest */
> +	__u32 free_page_report_cmd_id;
> +	/* Stores PAGE_POISON if page poisoning is in use */
> +	__u32 poison_val;
>  };
>  
>  #define VIRTIO_BALLOON_S_SWAP_IN  0   /* Amount of memory swapped in */
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
