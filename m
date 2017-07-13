Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF97440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 20:23:01 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p45so14683498qtg.11
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 17:23:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b73si3586923qkc.387.2017.07.12.17.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 17:23:00 -0700 (PDT)
Date: Thu, 13 Jul 2017 03:22:50 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 8/8] virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
Message-ID: <20170713032207-mutt-send-email-mst@kernel.org>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-9-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499863221-16206-9-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Wed, Jul 12, 2017 at 08:40:21PM +0800, Wei Wang wrote:
> Add a new vq, cmdq, to handle requests between the device and driver.
> 
> This patch implements two commands sent from the device and handled in
> the driver.
> 1) VIRTIO_BALLOON_CMDQ_REPORT_STATS: this command is used to report
> the guest memory statistics to the host. The stats_vq mechanism is not
> used when the cmdq mechanism is enabled.
> 2) VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES: this command is used to
> report the guest unused pages to the host.
> 
> Since now we have a vq to handle multiple commands, we need to keep only
> one vq operation at a time. Here, we change the existing START_USE()
> and END_USE() to lock on each vq operation.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 245 ++++++++++++++++++++++++++++++++++--
>  drivers/virtio/virtio_ring.c        |  25 +++-
>  include/linux/virtio.h              |   2 +
>  include/uapi/linux/virtio_balloon.h |  10 ++
>  4 files changed, 265 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index aa4e7ec..ae91fbf 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -54,11 +54,12 @@ static struct vfsmount *balloon_mnt;
>  
>  struct virtio_balloon {
>  	struct virtio_device *vdev;
> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *cmd_vq;
>  
>  	/* The balloon servicing is delegated to a freezable workqueue. */
>  	struct work_struct update_balloon_stats_work;
>  	struct work_struct update_balloon_size_work;
> +	struct work_struct cmdq_handle_work;
>  
>  	/* Prevent updating balloon when it is being canceled. */
>  	spinlock_t stop_update_lock;
> @@ -90,6 +91,12 @@ struct virtio_balloon {
>  	/* Memory statistics */
>  	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
>  
> +	/* Cmdq msg buffer for memory statistics */
> +	struct virtio_balloon_cmdq_hdr cmdq_stats_hdr;
> +
> +	/* Cmdq msg buffer for reporting ununsed pages */
> +	struct virtio_balloon_cmdq_hdr cmdq_unused_page_hdr;
> +
>  	/* To register callback in oom notifier call chain */
>  	struct notifier_block nb;
>  };
> @@ -485,25 +492,214 @@ static void update_balloon_size_func(struct work_struct *work)
>  		queue_work(system_freezable_wq, work);
>  }
>  
> +static unsigned int cmdq_hdr_add(struct virtqueue *vq,
> +				 struct virtio_balloon_cmdq_hdr *hdr,
> +				 bool in)
> +{
> +	unsigned int id = VIRTQUEUE_DESC_ID_INIT;
> +	uint64_t hdr_pa = (uint64_t)virt_to_phys((void *)hdr);
> +
> +	virtqueue_add_chain_desc(vq, hdr_pa, sizeof(*hdr), &id, &id, in);
> +
> +	/* Deliver the hdr for the host to send commands. */
> +	if (in) {
> +		hdr->flags = 0;
> +		virtqueue_add_chain(vq, id, 0, NULL, hdr, NULL);
> +		virtqueue_kick(vq);
> +	}
> +
> +	return id;
> +}
> +
> +static void cmdq_add_chain_desc(struct virtio_balloon *vb,
> +				struct virtio_balloon_cmdq_hdr *hdr,
> +				uint64_t addr,
> +				uint32_t len,
> +				unsigned int *head_id,
> +				unsigned int *prev_id)
> +{
> +retry:
> +	if (*head_id == VIRTQUEUE_DESC_ID_INIT) {
> +		*head_id = cmdq_hdr_add(vb->cmd_vq, hdr, 0);
> +		*prev_id = *head_id;
> +	}
> +
> +	virtqueue_add_chain_desc(vb->cmd_vq, addr, len, head_id, prev_id, 0);
> +	if (*head_id == *prev_id) {

That's an ugly way to detect ring full.

> +		/*
> +		 * The VQ was full and kicked to release some descs. Now we
> +		 * will re-start to build the chain by using the hdr as the
> +		 * first desc, so we need to detach the desc that was just
> +		 * added, and re-start to add the hdr.
> +		 */
> +		virtqueue_detach_buf(vb->cmd_vq, *head_id, NULL);
> +		*head_id = VIRTQUEUE_DESC_ID_INIT;
> +		*prev_id = VIRTQUEUE_DESC_ID_INIT;
> +		goto retry;
> +	}
> +}
> +
> +static void cmdq_handle_stats(struct virtio_balloon *vb)
> +{
> +	unsigned int num_stats,
> +		     head_id = VIRTQUEUE_DESC_ID_INIT,
> +		     prev_id = VIRTQUEUE_DESC_ID_INIT;
> +	uint64_t addr = (uint64_t)virt_to_phys((void *)vb->stats);
> +	uint32_t len;
> +
> +	spin_lock(&vb->stop_update_lock);
> +	if (!vb->stop_update) {
> +		num_stats = update_balloon_stats(vb);
> +		len = sizeof(struct virtio_balloon_stat) * num_stats;
> +		cmdq_add_chain_desc(vb, &vb->cmdq_stats_hdr, addr, len,
> +				    &head_id, &prev_id);
> +		virtqueue_add_chain(vb->cmd_vq, head_id, 0, NULL, vb, NULL);
> +		virtqueue_kick_sync(vb->cmd_vq);
> +	}
> +	spin_unlock(&vb->stop_update_lock);
> +}
> +
> +static void cmdq_add_unused_page(struct virtio_balloon *vb,
> +				 struct zone *zone,
> +				 unsigned int order,
> +				 unsigned int type,
> +				 struct page *page,
> +				 unsigned int *head_id,
> +				 unsigned int *prev_id)
> +{
> +	uint64_t addr;
> +	uint32_t len;
> +
> +	while (!report_unused_page_block(zone, order, type, &page)) {
> +		addr = (u64)page_to_pfn(page) << VIRTIO_BALLOON_PFN_SHIFT;
> +		len = (u64)(1 << order) << VIRTIO_BALLOON_PFN_SHIFT;
> +		cmdq_add_chain_desc(vb, &vb->cmdq_unused_page_hdr, addr, len,
> +				    head_id, prev_id);
> +	}
> +}
> +
> +static void cmdq_handle_unused_pages(struct virtio_balloon *vb)
> +{
> +	struct virtqueue *vq = vb->cmd_vq;
> +	unsigned int order = 0, type = 0,
> +		     head_id = VIRTQUEUE_DESC_ID_INIT,
> +		     prev_id = VIRTQUEUE_DESC_ID_INIT;
> +	struct zone *zone = NULL;
> +	struct page *page = NULL;
> +
> +	for_each_populated_zone(zone)
> +		for_each_migratetype_order(order, type)
> +			cmdq_add_unused_page(vb, zone, order, type, page,
> +					     &head_id, &prev_id);
> +
> +	/* Set the cmd completion flag. */
> +	vb->cmdq_unused_page_hdr.flags |=
> +				cpu_to_le32(VIRTIO_BALLOON_CMDQ_F_COMPLETION);
> +	virtqueue_add_chain(vq, head_id, 0, NULL, vb, NULL);
> +	virtqueue_kick_sync(vb->cmd_vq);
> +}
> +
> +static void cmdq_handle(struct virtio_balloon *vb)
> +{
> +	struct virtio_balloon_cmdq_hdr *hdr;
> +	unsigned int len;
> +
> +	while ((hdr = (struct virtio_balloon_cmdq_hdr *)
> +			virtqueue_get_buf(vb->cmd_vq, &len)) != NULL) {
> +		switch (__le32_to_cpu(hdr->cmd)) {
> +		case VIRTIO_BALLOON_CMDQ_REPORT_STATS:
> +			cmdq_handle_stats(vb);
> +			break;
> +		case VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES:
> +			cmdq_handle_unused_pages(vb);
> +			break;
> +		default:
> +			dev_warn(&vb->vdev->dev, "%s: wrong cmd\n", __func__);
> +			return;
> +		}
> +		/*
> +		 * Replenish all the command buffer to the device after a
> +		 * command is handled. This is for the convenience of the
> +		 * device to rewind the cmdq to get back all the command
> +		 * buffer after live migration.
> +		 */
> +		cmdq_hdr_add(vb->cmd_vq, &vb->cmdq_stats_hdr, 1);
> +		cmdq_hdr_add(vb->cmd_vq, &vb->cmdq_unused_page_hdr, 1);
> +	}
> +}
> +
> +static void cmdq_handle_work_func(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +
> +	vb = container_of(work, struct virtio_balloon,
> +			  cmdq_handle_work);
> +	cmdq_handle(vb);
> +}
> +
> +static void cmdq_callback(struct virtqueue *vq)
> +{
> +	struct virtio_balloon *vb = vq->vdev->priv;
> +
> +	queue_work(system_freezable_wq, &vb->cmdq_handle_work);
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
> +	int err = -ENOMEM;
> +	int nvqs;
> +
> +	/* Inflateq and deflateq are used unconditionally */
> +	nvqs = 2;
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CMD_VQ) ||
> +	    virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
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
>  
>  	/*
> -	 * We expect two virtqueues: inflate and deflate, and
> -	 * optionally stat.
> +	 * The stats_vq is used only when cmdq is not supported (or disabled)
> +	 * by the device.
>  	 */
> -	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> -	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
> -	if (err)
> -		return err;
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CMD_VQ)) {
> +		callbacks[2] = cmdq_callback;
> +		names[2] = "cmdq";
> +	} else if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +		callbacks[2] = stats_request;
> +		names[2] = "stats";
> +	}
>  
> +	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks,
> +					 names, NULL, NULL);
> +	if (err)
> +		goto err_find;
>  	vb->inflate_vq = vqs[0];
>  	vb->deflate_vq = vqs[1];
> -	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CMD_VQ)) {
> +		vb->cmd_vq = vqs[2];
> +		/* Prime the cmdq with the header buffer. */
> +		cmdq_hdr_add(vb->cmd_vq, &vb->cmdq_stats_hdr, 1);
> +		cmdq_hdr_add(vb->cmd_vq, &vb->cmdq_unused_page_hdr, 1);
> +	} else if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>  		struct scatterlist sg;
>  		unsigned int num_stats;
>  		vb->stats_vq = vqs[2];
> @@ -520,6 +716,16 @@ static int init_vqs(struct virtio_balloon *vb)
>  			BUG();
>  		virtqueue_kick(vb->stats_vq);
>  	}
> +
> +err_find:
> +	kfree(names);
> +err_names:
> +	kfree(callbacks);
> +err_callback:
> +	kfree(vqs);
> +err_vq:
> +	return err;
> +
>  	return 0;
>  }
>  
> @@ -640,7 +846,18 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		goto out;
>  	}
>  
> -	INIT_WORK(&vb->update_balloon_stats_work, update_balloon_stats_func);
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_CMD_VQ)) {
> +		vb->cmdq_stats_hdr.cmd =
> +				cpu_to_le32(VIRTIO_BALLOON_CMDQ_REPORT_STATS);
> +		vb->cmdq_stats_hdr.flags = 0;
> +		vb->cmdq_unused_page_hdr.cmd =
> +			cpu_to_le32(VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES);
> +		vb->cmdq_unused_page_hdr.flags = 0;
> +		INIT_WORK(&vb->cmdq_handle_work, cmdq_handle_work_func);
> +	} else if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +		INIT_WORK(&vb->update_balloon_stats_work,
> +			  update_balloon_stats_func);
> +	}
>  	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
>  	spin_lock_init(&vb->stop_update_lock);
>  	vb->stop_update = false;
> @@ -722,6 +939,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	spin_unlock_irq(&vb->stop_update_lock);
>  	cancel_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
> +	cancel_work_sync(&vb->cmdq_handle_work);
>  
>  	xb_empty(&vb->page_xb);
>  	remove_common(vb);
> @@ -776,6 +994,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>  	VIRTIO_BALLOON_F_SG,
> +	VIRTIO_BALLOON_F_CMD_VQ,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index b9d7e10..793de12 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -52,8 +52,13 @@
>  			"%s:"fmt, (_vq)->vq.name, ##args);	\
>  		(_vq)->broken = true;				\
>  	} while (0)
> -#define START_USE(vq)
> -#define END_USE(vq)
> +#define START_USE(_vq)						\
> +	do {							\
> +		while ((_vq)->in_use)				\
> +			cpu_relax();				\
> +		(_vq)->in_use = __LINE__;			\
> +	} while (0)
> +#define END_USE(_vq)	((_vq)->in_use = 0)
>  #endif
>  
>  struct vring_desc_state {
> @@ -101,9 +106,9 @@ struct vring_virtqueue {
>  	size_t queue_size_in_bytes;
>  	dma_addr_t queue_dma_addr;
>  
> -#ifdef DEBUG
>  	/* They're supposed to lock for us. */
>  	unsigned int in_use;
> +#ifdef DEBUG
>  
>  	/* Figure out if their kicks are too delayed. */
>  	bool last_add_time_valid;
> @@ -845,6 +850,18 @@ static void detach_buf(struct vring_virtqueue *vq, unsigned int head,
>  	}
>  }
>  
> +void virtqueue_detach_buf(struct virtqueue *_vq, unsigned int head, void **ctx)
> +{
> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +
> +	START_USE(vq);
> +
> +	detach_buf(vq, head, ctx);
> +
> +	END_USE(vq);
> +}
> +EXPORT_SYMBOL_GPL(virtqueue_detach_buf);
> +
>  static inline bool more_used(const struct vring_virtqueue *vq)
>  {
>  	return vq->last_used_idx != virtio16_to_cpu(vq->vq.vdev, vq->vring.used->idx);
> @@ -1158,8 +1175,8 @@ struct virtqueue *__vring_new_virtqueue(unsigned int index,
>  	vq->avail_idx_shadow = 0;
>  	vq->num_added = 0;
>  	list_add_tail(&vq->vq.list, &vdev->vqs);
> +	vq->in_use = 0;
>  #ifdef DEBUG
> -	vq->in_use = false;
>  	vq->last_add_time_valid = false;
>  #endif
>  
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 9f27101..9df480b 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -88,6 +88,8 @@ void *virtqueue_get_buf(struct virtqueue *vq, unsigned int *len);
>  void *virtqueue_get_buf_ctx(struct virtqueue *vq, unsigned int *len,
>  			    void **ctx);
>  
> +void virtqueue_detach_buf(struct virtqueue *_vq, unsigned int head, void **ctx);
> +
>  void virtqueue_disable_cb(struct virtqueue *vq);
>  
>  bool virtqueue_enable_cb(struct virtqueue *vq);
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 37780a7..b38c370 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -35,6 +35,7 @@
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */
> +#define VIRTIO_BALLOON_F_CMD_VQ		4 /* Command virtqueue */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> @@ -83,4 +84,13 @@ struct virtio_balloon_stat {
>  	__virtio64 val;
>  } __attribute__((packed));
>  
> +struct virtio_balloon_cmdq_hdr {
> +#define VIRTIO_BALLOON_CMDQ_REPORT_STATS	0
> +#define VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES	1
> +	__le32 cmd;
> +/* Flag to indicate the completion of handling a command */
> +#define VIRTIO_BALLOON_CMDQ_F_COMPLETION	1
> +	__le32 flags;
> +};
> +
>  #endif /* _LINUX_VIRTIO_BALLOON_H */
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
