Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCBF3800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 00:02:03 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id z8so1825269otb.11
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 21:02:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w69si730093ota.418.2018.01.23.21.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 21:02:02 -0800 (PST)
Date: Wed, 24 Jan 2018 07:01:50 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v23 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20180124064923-mutt-send-email-mst@kernel.org>
References: <1516762227-36346-1-git-send-email-wei.w.wang@intel.com>
 <1516762227-36346-3-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1516762227-36346-3-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Wed, Jan 24, 2018 at 10:50:27AM +0800, Wei Wang wrote:
> Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_VQ feature indicates the
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
>  drivers/virtio/virtio_balloon.c     | 228 ++++++++++++++++++++++++++++++------
>  include/uapi/linux/virtio_balloon.h |   6 +
>  2 files changed, 201 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index a1fb52c..d038f4a 100644
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
> @@ -281,6 +300,56 @@ static unsigned int update_balloon_stats(struct virtio_balloon *vb)
>  	return idx;
>  }
>  
> +static void add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
> +{
> +	struct scatterlist sg;
> +	unsigned int unused;
> +	int err;
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
> +	if (vq->num_free > 1) {
> +		err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> +		/*
> +		 * This is expected to never fail, because there is always an
> +		 * entry available on the vq.
> +		 */
> +		BUG_ON(err);
> +	}
> +
> +	if (vq->num_free == virtqueue_get_vring_size(vq) / 2)
> +		virtqueue_kick(vq);

This will not DTRT in all cases. It's quite possible
that host does not need the kick when ring is half full but
does need it later when ring is full.
You can kick at ring half full as optimization but you absolutely
still must kick on ring full. Something like:

if (vq->num_free == virtqueue_get_vring_size(vq) / 2 ||
	vq->num_free <= 2)

> +}
> +
> +static void send_cmd_id(struct virtqueue *vq, __virtio32 *cmd_id)
> +{
> +	struct scatterlist sg;
> +	int err;
> +
> +	sg_init_one(&sg, cmd_id, sizeof(*cmd_id));
> +
> +	err = virtqueue_add_outbuf(vq, &sg, 1, vq, GFP_KERNEL);
> +	/*
> +	 * This is expected to never fail, because there is always an
> +	 * entry reserved for the cmd id.
> +	 */
> +	BUG_ON(err);
> +	virtqueue_kick(vq);

Actually add can fail if device becomes broken. I'd like to see us
bail out gracefully rather than BUG_ON.

> +}
> +
>  /*
>   * While most virtqueues communicate guest-initiated requests to the hypervisor,
>   * the stats queue operates in reverse.  The driver initializes the virtqueue
> @@ -316,17 +385,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
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
> @@ -343,6 +401,42 @@ static inline s64 towards_target(struct virtio_balloon *vb)
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
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
> +		virtio_cread(vdev, struct virtio_balloon_config,
> +			     free_page_report_cmd_id, &cmd_id);
> +		if (cmd_id == VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID) {
> +			vb->report_free_page = false;
> +		} else if (cmd_id != virtio32_to_cpu(vdev, vb->start_cmd_id)) {
> +			/*
> +			 * Host requests to start the reporting by sending a
> +			 * new cmd id.
> +			 */
> +			vb->report_free_page = true;
> +			vb->start_cmd_id = cpu_to_virtio32(vdev, cmd_id);
> +			spin_lock_irqsave(&vb->stop_update_lock, flags);
> +			if (!vb->stop_update)
> +				queue_work(vb->balloon_wq,
> +					   &vb->report_free_page_work);
> +			spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> +		}
> +	}
> +}
> +
>  static void update_balloon_size(struct virtio_balloon *vb)
>  {
>  	u32 actual = vb->num_pages;
> @@ -417,42 +511,91 @@ static void update_balloon_size_func(struct work_struct *work)
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
> +	 * Inflateq and deflateq are used unconditionally. stats_vq and
> +	 * free_page_vq uses names[2] and names[3], respectively. The names[]
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
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
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
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
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
> +
> +	if (!vb->report_free_page)
> +		return false;
> +
> +	add_one_sg(vb->free_page_vq, pfn, len);
> +
> +	return true;
> +}
> +
> +static void report_free_page_func(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +
> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> +	/* Start by sending the obtained cmd id to the host with an outbuf */
> +	send_cmd_id(vb->free_page_vq, &vb->start_cmd_id);
> +	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> +	/* End by sending the stop id to the host with an outbuf */
> +	send_cmd_id(vb->free_page_vq, &vb->stop_cmd_id);
> +}
> +
>  #ifdef CONFIG_BALLOON_COMPACTION
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
> @@ -537,6 +680,7 @@ static struct file_system_type balloon_fs = {
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> +	__u32 poison_val;
>  	int err;
>  
>  	if (!vdev->config->get) {
> @@ -566,6 +710,21 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
> +		vb->balloon_wq = alloc_workqueue("balloon-wq",
> +					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);

why don't you check the return value here?

> +		INIT_WORK(&vb->report_free_page_work, report_free_page_func);
> +		vb->stop_cmd_id = cpu_to_virtio32(vdev,
> +				VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
> +		if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY) ||
> +		    !page_poisoning_enabled())
> +			poison_val = 0;
> +		else
> +			poison_val = PAGE_POISON;
> +		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
> +			      poison_val, &poison_val);

I think we should differentiate between 0 and not poison.
How about we use a separate feature bit for the poison flag?

> +	}
> +
>  	vb->nb.notifier_call = virtballoon_oom_notify;
>  	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err = register_oom_notifier(&vb->nb);
> @@ -630,6 +789,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	spin_unlock_irq(&vb->stop_update_lock);
>  	cancel_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
> +	cancel_work_sync(&vb->report_free_page_work);
> +	destroy_workqueue(vb->balloon_wq);
>  
>  	remove_common(vb);
>  #ifdef CONFIG_BALLOON_COMPACTION
> @@ -682,6 +843,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_FREE_PAGE_VQ,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7dd..5861876 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,15 +34,21 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_FREE_PAGE_VQ	3 /* VQ to report free pages */

I'd call it something like FREE_PAGE_HINT

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
> +	/* Stores PAGE_POISON if page poisoning with sanity check is in use */
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
