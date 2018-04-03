Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64EE66B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 14:47:32 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id d205so9834820qkg.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 11:47:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z38si1241782qtb.349.2018.04.03.11.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 11:47:31 -0700 (PDT)
Date: Tue, 3 Apr 2018 21:47:24 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v30 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180403214147-mutt-send-email-mst@kernel.org>
References: <1522771805-78927-1-git-send-email-wei.w.wang@intel.com>
 <1522771805-78927-3-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522771805-78927-3-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On Wed, Apr 04, 2018 at 12:10:03AM +0800, Wei Wang wrote:
> Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
> support of reporting hints of guest free pages to host via virtio-balloon.
> 
> Host requests the guest to report free page hints by sending a new cmd
> id to the guest via the free_page_report_cmd_id configuration register.
> 
> When the guest starts to report, the first element added to the free page
> vq is the cmd id given by host. When the guest finishes the reporting
> of all the free pages, VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID is added
> to the vq to tell host that the reporting is done. Host polls the free
> page vq after sending the starting cmd id, so the guest doesn't need to
> kick after filling an element to the vq.
> 
> Host may also requests the guest to stop the reporting in advance by
> sending the stop cmd id to the guest via the configuration register.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> ---
>  drivers/virtio/virtio_balloon.c     | 257 +++++++++++++++++++++++++++++++-----
>  include/uapi/linux/virtio_balloon.h |   4 +
>  2 files changed, 225 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index dfe5684..18d24a4 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -51,9 +51,22 @@
>  static struct vfsmount *balloon_mnt;
>  #endif
>  
> +enum virtio_balloon_vq {
> +	VIRTIO_BALLOON_VQ_INFLATE,
> +	VIRTIO_BALLOON_VQ_DEFLATE,
> +	VIRTIO_BALLOON_VQ_STATS,
> +	VIRTIO_BALLOON_VQ_FREE_PAGE,
> +	VIRTIO_BALLOON_VQ_MAX
> +};
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
> @@ -63,6 +76,13 @@ struct virtio_balloon {
>  	spinlock_t stop_update_lock;
>  	bool stop_update;
>  
> +	/* The new cmd id received from host */
> +	uint32_t cmd_id_received;
> +	/* The cmd id that is in use */
> +	__virtio32 cmd_id_use;
> +	/* Buffer to store the stop sign */
> +	__virtio32 stop_cmd_id;
> +
>  	/* Waiting for host to ack the pages we released. */
>  	wait_queue_head_t acked;
>  
> @@ -320,17 +340,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
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
> @@ -347,6 +356,34 @@ static inline s64 towards_target(struct virtio_balloon *vb)
>  	return target - vb->num_pages;
>  }
>  
> +static void virtballoon_changed(struct virtio_device *vdev)
> +{
> +	struct virtio_balloon *vb = vdev->priv;
> +	unsigned long flags;
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
> +			     free_page_report_cmd_id, &vb->cmd_id_received);
> +		if (vb->cmd_id_received !=
> +		    VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID) {
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
> @@ -421,42 +458,163 @@ static void update_balloon_size_func(struct work_struct *work)
>  
>  static int init_vqs(struct virtio_balloon *vb)
>  {
> -	struct virtqueue *vqs[3];
> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
> -	static const char * const names[] = { "inflate", "deflate", "stats" };
> -	int err, nvqs;
> +	struct virtqueue *vqs[VIRTIO_BALLOON_VQ_MAX];
> +	vq_callback_t *callbacks[VIRTIO_BALLOON_VQ_MAX];
> +	const char *names[VIRTIO_BALLOON_VQ_MAX];
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
> +	callbacks[VIRTIO_BALLOON_VQ_INFLATE] = balloon_ack;
> +	names[VIRTIO_BALLOON_VQ_INFLATE] = "inflate";
> +	callbacks[VIRTIO_BALLOON_VQ_DEFLATE] = balloon_ack;
> +	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> +	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> +	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>  
> -	vb->inflate_vq = vqs[0];
> -	vb->deflate_vq = vqs[1];
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> -		struct scatterlist sg;
> -		unsigned int num_stats;
> -		vb->stats_vq = vqs[2];
> +		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> +		callbacks[VIRTIO_BALLOON_VQ_STATS] = stats_request;
> +	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		names[VIRTIO_BALLOON_VQ_FREE_PAGE] = "free_page_vq";
> +		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> +	}
>  
> +	ret = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> +					 vqs, callbacks, names, NULL, NULL);
> +	if (ret)
> +		return ret;
> +
> +	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
> +	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +		vb->stats_vq = vqs[VIRTIO_BALLOON_VQ_STATS];
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
> +		vb->free_page_vq = vqs[VIRTIO_BALLOON_VQ_FREE_PAGE];
> +
>  	return 0;
>  }
>  
> +static int add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
> +{
> +	struct scatterlist sg;
> +	unsigned int unused;
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
> +	 * the page hint if the vq is full.

why not stop scanning of following pages though?

> +	 * We are adding one entry each time, which essentially results in no
> +	 * memory allocation, so the GFP_KERNEL flag below can be ignored.
> +	 * Host works by polling the free page vq for hints after sending the
> +	 * starting cmd id, so the driver doesn't need to kick after filling
> +	 * the vq.
> +	 * Lastly, there is always one entry reserved for the cmd id to use.
> +	 */
> +	if (vq->num_free > 1)
> +		return virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> +
> +	return 0;
> +}
> +
> +static int virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
> +					   unsigned long nr_pages)
> +{
> +	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
> +	uint32_t len = nr_pages << PAGE_SHIFT;
> +
> +	/*
> +	 * If a stop id or a new cmd id was just received from host, stop
> +	 * the reporting, and return 1 to indicate an active stop.
> +	 */
> +	if (virtio32_to_cpu(vb->vdev, vb->cmd_id_use) != vb->cmd_id_received)
> +		return 1;
> +

this access to cmd_id_use and cmd_id_received without locks
bothers me. Pls document why it's safe.

> +	return add_one_sg(vb->free_page_vq, pfn, len);
> +}
> +
> +static int send_start_cmd_id(struct virtio_balloon *vb, uint32_t cmd_id)
> +{
> +	struct scatterlist sg;
> +	struct virtqueue *vq = vb->free_page_vq;
> +
> +	vb->cmd_id_use = cpu_to_virtio32(vb->vdev, cmd_id);
> +	sg_init_one(&sg, &vb->cmd_id_use, sizeof(vb->cmd_id_use));
> +	return virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> +}
> +
> +static int send_stop_cmd_id(struct virtio_balloon *vb)
> +{
> +	struct scatterlist sg;
> +	struct virtqueue *vq = vb->free_page_vq;
> +
> +	sg_init_one(&sg, &vb->stop_cmd_id, sizeof(vb->cmd_id_use));

why the inconsistency?

> +	return virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> +}
> +
> +static void report_free_page_func(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +	struct virtqueue *vq;
> +	unsigned int unused;
> +	int ret;
> +
> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> +	vq = vb->free_page_vq;
> +
> +	/* Start by sending the received cmd id to host with an outbuf */
> +	ret = send_start_cmd_id(vb, vb->cmd_id_received);
> +	if (unlikely(ret))
> +		goto err;
> +
> +	ret = walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> +	if (unlikely(ret == -EIO))
> +		goto err;
> +
> +	/* End by sending a stop id to host with an outbuf */
> +	ret = send_stop_cmd_id(vb);
> +	if (likely(!ret)) {
> +		/*
> +		 * Ending: make sure all the used buffers have been detached
> +		 * from the vq.
> +		 */
> +		while (vq->num_free != virtqueue_get_vring_size(vq))
> +			virtqueue_get_buf(vq, &unused);
> +		return;
> +	}
> +err:
> +	dev_err(&vb->vdev->dev, "%s: free page vq failure, ret=%d\n",
> +		__func__, ret);
> +}
> +
>  #ifdef CONFIG_BALLOON_COMPACTION
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
> @@ -570,18 +728,36 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		/*
> +		 * There is always one entry reserved for cmd id, so the ring
> +		 * size needs to be at least two to report free page hints.
> +		 */
> +		if (virtqueue_get_vring_size(vb->free_page_vq) < 2)
> +			goto out_free_vb;
> +		vb->balloon_wq = alloc_workqueue("balloon-wq",
> +					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
> +		if (!vb->balloon_wq) {
> +			err = -ENOMEM;
> +			goto out_del_vqs;
> +		}
> +		vb->stop_cmd_id = cpu_to_virtio32(vb->vdev,
> +				VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
> +		INIT_WORK(&vb->report_free_page_work, report_free_page_func);
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
> @@ -591,7 +767,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		kern_unmount(balloon_mnt);
>  		unregister_oom_notifier(&vb->nb);
>  		vb->vb_dev_info.inode = NULL;
> -		goto out_del_vqs;
> +		goto out_del_balloon_wq;
>  	}
>  	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
>  #endif
> @@ -602,6 +778,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		virtballoon_changed(vdev);
>  	return 0;
>  
> +out_del_balloon_wq:
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
> +		destroy_workqueue(vb->balloon_wq);
>  out_del_vqs:
>  	vdev->config->del_vqs(vdev);
>  out_free_vb:
> @@ -635,6 +814,11 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	cancel_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		cancel_work_sync(&vb->report_free_page_work);
> +		destroy_workqueue(vb->balloon_wq);
> +	}
> +
>  	remove_common(vb);
>  #ifdef CONFIG_BALLOON_COMPACTION
>  	if (vb->vb_dev_info.inode)
> @@ -686,6 +870,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 4e8b830..b2d86c2 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,15 +34,19 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
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
>  };
>  
>  #define VIRTIO_BALLOON_S_SWAP_IN  0   /* Amount of memory swapped in */
> -- 
> 1.8.3.1
