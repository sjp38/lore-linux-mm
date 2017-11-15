Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 595A56B0069
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 15:32:30 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id x124so1148733oia.20
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 12:32:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f64si2093253oib.13.2017.11.15.12.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 12:32:28 -0800 (PST)
Date: Wed, 15 Nov 2017 22:32:12 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v17 6/6] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20171115220743-mutt-send-email-mst@kernel.org>
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>
 <1509696786-1597-7-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509696786-1597-7-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Fri, Nov 03, 2017 at 04:13:06PM +0800, Wei Wang wrote:
> Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_VQ feature indicates the
> support of reporting hints of guest free pages to the host via
> virtio-balloon. The host requests the guest to report the free pages by
> sending commands via the virtio-balloon configuration registers.
> 
> When the guest starts to report, the first element added to the free page
> vq is a sequence id of the start reporting command. The id is given by
> the host, and it indicates whether the following free pages correspond
> to the command. For example, the host may stop the report and start again
> with a new command id. The obsolete pages for the previous start command
> can be detected by the id dismatching on the host. The id is added to the
> vq using an output buffer, and the free pages are added to the vq using
> input buffer.
> 
> Here are some explainations about the added configuration registers:
> - host2guest_cmd: a register used by the host to send commands to the
> guest.
> - guest2host_cmd: written by the guest to ACK to the host about the
> commands that have been received. The host will clear the corresponding
> bits on the host2guest_cmd register. The guest also uses this register
> to send commands to the host (e.g. when finish free page reporting).
> - free_page_cmd_id: the sequence id of the free page report command
> given by the host.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> ---
>  drivers/virtio/virtio_balloon.c     | 234 ++++++++++++++++++++++++++++++++----
>  include/uapi/linux/virtio_balloon.h |  11 ++
>  2 files changed, 223 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index b31fc25..4087f04 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -55,7 +55,12 @@ static struct vfsmount *balloon_mnt;
>  
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
> @@ -65,6 +70,10 @@ struct virtio_balloon {
>  	spinlock_t stop_update_lock;
>  	bool stop_update;
>  
> +	/* Stop reporting free pages */
> +	bool report_free_page_stop;
> +	uint32_t free_page_cmd_id;
> +
>  	/* Waiting for host to ack the pages we released. */
>  	wait_queue_head_t acked;
>  
> @@ -191,6 +200,30 @@ static void send_balloon_page_sg(struct virtio_balloon *vb,
>  		kick_and_wait(vq, vb->acked);
>  }
>  
> +static void send_free_page_sg(struct virtqueue *vq, void *addr, uint32_t size)
> +{
> +	int err = 0;
> +	unsigned int len;
> +
> +	/* Detach all the used buffers from the vq */
> +	while (virtqueue_get_buf(vq, &len))
> +		;
> +
> +	/*
> +	 * Since this is an optimization feature, losing a couple of free
> +	 * pages to report isn't important. We simply resturn without adding
> +	 * the page if the vq is full.
> +	 */
> +	if (vq->num_free) {
> +		err = add_one_sg(vq, addr, size);
> +		BUG_ON(err);
> +	}
> +
> +	/* Batch till the vq is full */
> +	if (!vq->num_free)
> +		virtqueue_kick(vq);
> +}
> +
>  /*
>   * Send balloon pages in sgs to host. The balloon pages are recorded in the
>   * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
> @@ -495,9 +528,8 @@ static void stats_handle_request(struct virtio_balloon *vb)
>  	virtqueue_kick(vq);
>  }
>  
> -static void virtballoon_changed(struct virtio_device *vdev)
> +static void virtballoon_cmd_balloon_memory(struct virtio_balloon *vb)
>  {
> -	struct virtio_balloon *vb = vdev->priv;
>  	unsigned long flags;
>  
>  	spin_lock_irqsave(&vb->stop_update_lock, flags);
> @@ -506,6 +538,50 @@ static void virtballoon_changed(struct virtio_device *vdev)
>  	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
>  }
>  
> +static void virtballoon_cmd_report_free_page_start(struct virtio_balloon *vb)
> +{
> +	unsigned long flags;
> +
> +	vb->report_free_page_stop = false;
> +	spin_lock_irqsave(&vb->stop_update_lock, flags);
> +	if (!vb->stop_update)
> +		queue_work(vb->balloon_wq, &vb->report_free_page_work);
> +	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> +}
> +
> +static void virtballoon_changed(struct virtio_device *vdev)
> +{
> +	struct virtio_balloon *vb = vdev->priv;
> +	u32 host2guest_cmd, guest2host_cmd = 0;
> +
> +	if (!virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
> +		virtballoon_cmd_balloon_memory(vb);
> +		return;
> +	}
> +
> +	virtio_cread(vb->vdev, struct virtio_balloon_config, host2guest_cmd,
> +		     &host2guest_cmd);
> +
> +	if (host2guest_cmd & VIRTIO_BALLOON_CMD_BALLOON_MEMORY) {
> +		virtballoon_cmd_balloon_memory(vb);
> +		guest2host_cmd |= VIRTIO_BALLOON_CMD_BALLOON_MEMORY;
> +	}
> +
> +	if (host2guest_cmd & VIRTIO_BALLOON_CMD_REPORT_FREE_PAGE_START) {
> +		virtballoon_cmd_report_free_page_start(vb);
> +		guest2host_cmd |= VIRTIO_BALLOON_CMD_REPORT_FREE_PAGE_START;
> +	}
> +
> +	if (host2guest_cmd & VIRTIO_BALLOON_CMD_REPORT_FREE_PAGE_STOP) {
> +		vb->report_free_page_stop = true;
> +		guest2host_cmd |= VIRTIO_BALLOON_CMD_REPORT_FREE_PAGE_STOP;
> +	}
> +
> +	/* Ack to the host about the commands that have been received */
> +	virtio_cwrite(vb->vdev, struct virtio_balloon_config, guest2host_cmd,
> +		      &guest2host_cmd);
> +}
> +
>  static inline s64 towards_target(struct virtio_balloon *vb)
>  {
>  	s64 target;
> @@ -597,42 +673,147 @@ static void update_balloon_size_func(struct work_struct *work)
>  		queue_work(system_freezable_wq, work);
>  }
>  
> -static int init_vqs(struct virtio_balloon *vb)
> +static bool virtio_balloon_send_free_pages(void *opaque, unsigned long pfn,
> +					   unsigned long nr_pages)
>  {
> -	struct virtqueue *vqs[3];
> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
> -	static const char * const names[] = { "inflate", "deflate", "stats" };
> -	int err, nvqs;
> +	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
> +	void *addr = (void *)pfn_to_kaddr(pfn);
> +	uint32_t len = nr_pages << PAGE_SHIFT;
> +
> +	if (vb->report_free_page_stop)
> +		return false;
> +
> +	send_free_page_sg(vb->free_page_vq, addr, len);
>  
> +	return true;
> +}
> +
> +static void report_free_page_end(struct virtio_balloon *vb)
> +{
> +	u32 cmd = VIRTIO_BALLOON_CMD_REPORT_FREE_PAGE_STOP;
>  	/*
> -	 * We expect two virtqueues: inflate and deflate, and
> -	 * optionally stat.
> +	 * The host may have already requested to stop the reporting before we
> +	 * finish, so no need to notify the host in this case.
>  	 */
> -	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> -	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
> +	if (vb->report_free_page_stop)
> +		return;
> +	vb->report_free_page_stop = true;
> +
> +	virtio_cwrite(vb->vdev, struct virtio_balloon_config, guest2host_cmd,
> +		      &cmd);
> +}
> +
> +static void report_free_page_cmd_id(struct virtio_balloon *vb)
> +{
> +	struct scatterlist sg;
> +	int err;
> +
> +	virtio_cread(vb->vdev, struct virtio_balloon_config, free_page_cmd_id,
> +		     &vb->free_page_cmd_id);
> +	sg_init_one(&sg, &vb->free_page_cmd_id, sizeof(uint32_t));
> +	err = virtqueue_add_outbuf(vb->free_page_vq, &sg, 1,
> +				   &vb->free_page_cmd_id, GFP_KERNEL);
> +	BUG_ON(err);
> +}
> +
> +static void report_free_page(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +
> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> +	report_free_page_cmd_id(vb);
> +	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> +	/*
> +	 * The last few free page blocks that were added may not reach the
> +	 * batch size, but need a kick to notify the device to handle them.
> +	 */
> +	virtqueue_kick(vb->free_page_vq);
> +	report_free_page_end(vb);
> +}
> +

I think there's an issue here: if pages are poisoned and hypervisor
subsequently drops them, testing them after allocation will
trigger a false positive.

The specific configuration:

PAGE_POISONING on
PAGE_POISONING_NO_SANITY off
PAGE_POISONING_ZERO off


Solutions:
1. disable the feature in that configuration
	suggested as an initial step
2. pass poison value to host so it can validate page content
   before it drops it
3. pass poison value to host so it can init allocated pages with that value

In fact one nice side effect would be that unmap
becomes safe even though free list is not locked anymore.

It would be interesting to see whether this last has
any value performance-wise.


> +static int init_vqs(struct virtio_balloon *vb)
> +{
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
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
> +		callbacks[i] = NULL;
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
> -		    < 0)
> -			BUG();
> +		    < 0) {
> +			dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
> +				 __func__);
> +			goto err_find;
> +		}
>  		virtqueue_kick(vb->stats_vq);
>  	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
> +		vb->free_page_vq = vqs[i];
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
> @@ -761,6 +942,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
>  		xb_init(&vb->page_xb);
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
> +		vb->balloon_wq = alloc_workqueue("balloon-wq",
> +					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
> +		INIT_WORK(&vb->report_free_page_work, report_free_page);
> +		vb->report_free_page_stop = true;
> +	}
> +
>  	vb->nb.notifier_call = virtballoon_oom_notify;
>  	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err = register_oom_notifier(&vb->nb);
> @@ -825,6 +1013,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	spin_unlock_irq(&vb->stop_update_lock);
>  	cancel_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
> +	cancel_work_sync(&vb->report_free_page_work);
>  
>  	remove_common(vb);
>  #ifdef CONFIG_BALLOON_COMPACTION
> @@ -878,6 +1067,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>  	VIRTIO_BALLOON_F_SG,
> +	VIRTIO_BALLOON_F_FREE_PAGE_VQ,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 37780a7..b758484 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -35,15 +35,26 @@
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */
> +#define VIRTIO_BALLOON_F_FREE_PAGE_VQ	4 /* VQ to report free pages */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
>  
> +#define	VIRTIO_BALLOON_CMD_BALLOON_MEMORY		(1 << 0)
> +#define	VIRTIO_BALLOON_CMD_REPORT_FREE_PAGE_START	(1 << 1)
> +#define	VIRTIO_BALLOON_CMD_REPORT_FREE_PAGE_STOP	(1 << 2)
> +
>  struct virtio_balloon_config {
>  	/* Number of pages host wants Guest to give up. */
>  	__u32 num_pages;
>  	/* Number of pages we've actually got in balloon. */
>  	__u32 actual;
> +	/* Host-to-guest command, readonly by guest */
> +	__u32 host2guest_cmd;
> +	/* Sequence id of the free_page report command, readonly by guest */
> +	__u32 free_page_cmd_id;
> +	/* Guest-to-host command */
> +	__u32 guest2host_cmd;
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
