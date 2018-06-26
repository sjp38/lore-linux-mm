Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 022756B0005
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 21:37:09 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 99-v6so5724319qkr.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 18:37:08 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y202-v6si417392qky.18.2018.06.25.18.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 18:37:07 -0700 (PDT)
Date: Tue, 26 Jun 2018 04:37:03 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v34 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180626002822-mutt-send-email-mst@kernel.org>
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com>
 <1529928312-30500-3-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529928312-30500-3-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On Mon, Jun 25, 2018 at 08:05:10PM +0800, Wei Wang wrote:
> Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
> support of reporting hints of guest free pages to host via virtio-balloon.
> 
> Host requests the guest to report free page hints by sending a new cmd id
> to the guest via the free_page_report_cmd_id configuration register.
> 
> As the first step here, virtio-balloon only reports free page hints from
> the max order (i.e. 10) free page list to host. This has generated similar
> good results as reporting all free page hints during our tests.
> 
> When the guest starts to report, it first sends a start cmd to host via
> the free page vq, which acks to host the cmd id received, and tells it the
> hint size (e.g. 4MB each on x86). When the guest finishes the reporting,
> a stop cmd is sent to host via the vq.
> 
> TODO:
> - support reporting free page hints from smaller order free page lists
>   when there is a need/request from users.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  drivers/virtio/virtio_balloon.c     | 347 ++++++++++++++++++++++++++++++++----
>  include/uapi/linux/virtio_balloon.h |  11 ++
>  2 files changed, 322 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 6b237e3..d05f0ba 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -43,6 +43,11 @@
>  #define OOM_VBALLOON_DEFAULT_PAGES 256
>  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
>  
> +/* The order used to allocate an array to load free page hints */
> +#define ARRAY_ALLOC_ORDER (MAX_ORDER - 1)
> +/* The size of an array in bytes */
> +#define ARRAY_ALLOC_SIZE ((1 << ARRAY_ALLOC_ORDER) << PAGE_SHIFT)
> +


Pls prefix macros so we can figure out they are local ones.

>  static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
>  module_param(oom_pages, int, S_IRUSR | S_IWUSR);
>  MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
> @@ -51,9 +56,22 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
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
> @@ -63,6 +81,15 @@ struct virtio_balloon {
>  	spinlock_t stop_update_lock;
>  	bool stop_update;
>  
> +	/* Command buffers to start and stop the reporting of hints to host */
> +	struct virtio_balloon_free_page_hints_cmd cmd_start;
> +	struct virtio_balloon_free_page_hints_cmd cmd_stop;
> +
> +	/* The cmd id received from host */
> +	uint32_t cmd_id_received;
> +	/* The cmd id that is actively in use */
> +	uint32_t cmd_id_active;
> +
>  	/* Waiting for host to ack the pages we released. */
>  	wait_queue_head_t acked;
>  

You want u32 types.

> @@ -326,17 +353,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
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
> @@ -353,6 +369,35 @@ static inline s64 towards_target(struct virtio_balloon *vb)
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
> +		    VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID &&
> +		    vb->cmd_id_received != vb->cmd_id_active) {
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
> @@ -425,44 +470,253 @@ static void update_balloon_size_func(struct work_struct *work)
>  		queue_work(system_freezable_wq, work);
>  }
>  
> +static void free_page_vq_cb(struct virtqueue *vq)
> +{
> +	unsigned int len;
> +	void *buf;
> +	struct virtio_balloon *vb = vq->vdev->priv;
> +
> +	while (1) {
> +		buf = virtqueue_get_buf(vq, &len);
> +
> +		if (!buf || buf == &vb->cmd_start || buf == &vb->cmd_stop)
> +			break;

If there's any buffer after this one we might never get another
callback.

> +		free_pages((unsigned long)buf, ARRAY_ALLOC_ORDER);
> +	}
> +}
> +
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
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		names[VIRTIO_BALLOON_VQ_FREE_PAGE] = "free_page_vq";
> +		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = free_page_vq_cb;
> +	}
> +
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

Why the change? Is it more likely to happen now?

>  		virtqueue_kick(vb->stats_vq);
>  	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
> +		vb->free_page_vq = vqs[VIRTIO_BALLOON_VQ_FREE_PAGE];
> +
>  	return 0;
>  }
>  
> +static int send_start_cmd_id(struct virtio_balloon *vb)
> +{
> +	struct scatterlist sg;
> +	struct virtqueue *vq = vb->free_page_vq;
> +
> +	vb->cmd_start.id = cpu_to_virtio32(vb->vdev, vb->cmd_id_active);
> +	vb->cmd_start.size = cpu_to_virtio32(vb->vdev,
> +					     MAX_ORDER_NR_PAGES * PAGE_SIZE);
> +	sg_init_one(&sg, &vb->cmd_start,
> +		    sizeof(struct virtio_balloon_free_page_hints_cmd));
> +	return virtqueue_add_outbuf(vq, &sg, 1, &vb->cmd_start, GFP_KERNEL);
> +}
> +
> +static int send_stop_cmd_id(struct virtio_balloon *vb)
> +{
> +	struct scatterlist sg;
> +	struct virtqueue *vq = vb->free_page_vq;
> +
> +	vb->cmd_stop.id = cpu_to_virtio32(vb->vdev,
> +				VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
> +	vb->cmd_stop.size = 0;
> +	sg_init_one(&sg, &vb->cmd_stop,
> +		    sizeof(struct virtio_balloon_free_page_hints_cmd));
> +	return virtqueue_add_outbuf(vq, &sg, 1, &vb->cmd_stop, GFP_KERNEL);
> +}
> +
> +/*
> + * virtio_balloon_send_hints - send arrays of hints to host
> + * @vb: the virtio_balloon struct
> + * @arrays: the arrays of hints
> + * @array_num: the number of arrays give by the caller
> + * @last_array_hints: the number of hints in the last array
> + *
> + * Send hints to host array by array. This begins by sending a start cmd,
> + * which contains a cmd id received from host and the free page block size in
> + * bytes of each hint. At the end, a stop cmd is sent to host to indicate the
> + * end of this reporting. If host actively requests to stop the reporting, free
> + * the arrays that have not been sent.
> + */
> +static void virtio_balloon_send_hints(struct virtio_balloon *vb,
> +				      __le64 **arrays,
> +				      uint32_t array_num,
> +				      uint32_t last_array_hints)
> +{
> +	int err, i = 0;
> +	struct scatterlist sg;
> +	struct virtqueue *vq = vb->free_page_vq;
> +
> +	/* Start by sending the received cmd id to host with an outbuf. */
> +	err = send_start_cmd_id(vb);
> +	if (unlikely(err))
> +		goto out_err;
> +	/* Kick host to start taking entries from the vq. */
> +	virtqueue_kick(vq);
> +
> +	for (i = 0; i < array_num; i++) {
> +		/*
> +		 * If a stop id or a new cmd id was just received from host,
> +		 * stop the reporting, and free the remaining arrays that
> +		 * haven't been sent to host.
> +		 */
> +		if (vb->cmd_id_received != vb->cmd_id_active)
> +			goto out_free;
> +
> +		if (i + 1 == array_num)
> +			sg_init_one(&sg, (void *)arrays[i],
> +				    last_array_hints * sizeof(__le64));
> +		else
> +			sg_init_one(&sg, (void *)arrays[i], ARRAY_ALLOC_SIZE);
> +		err = virtqueue_add_inbuf(vq, &sg, 1, (void *)arrays[i],
> +					  GFP_KERNEL);
> +		if (unlikely(err))
> +			goto out_err;
> +	}
> +
> +	/* End by sending a stop id to host with an outbuf. */
> +	err = send_stop_cmd_id(vb);
> +	if (unlikely(err))
> +		goto out_err;

Don't we need to kick here?

> +	return;
> +
> +out_err:
> +	dev_err(&vb->vdev->dev, "%s: err = %d\n", __func__, err);
> +out_free:
> +	while (i < array_num)
> +		free_pages((unsigned long)arrays[i++], ARRAY_ALLOC_ORDER);
> +}
> +
> +/*
> + * virtio_balloon_load_hints - load free page hints into arrays
> + * @vb: the virtio_balloon struct
> + * @array_num: the number of arrays allocated
> + * @last_array_hints: the number of hints loaded into the last array
> + *
> + * Only free pages blocks of MAX_ORDER - 1 are loaded into the arrays.
> + * Each array size is MAX_ORDER_NR_PAGES * PAGE_SIZE (e.g. 4MB on x86). Failing
> + * to allocate such an array essentially implies that no such free page blocks
> + * could be reported. Alloacte the number of arrays according to the free page
> + * blocks of MAX_ORDER - 1 that the system may have, and free the unused ones
> + * after loading the free page hints. The last array may be partially loaded,
> + * and @last_array_hints tells the caller about the number of hints there.
> + *
> + * Return the pointer to the memory that holds the addresses of the allocated
> + * arrays, or NULL if no arrays are allocated.
> + */
> +static  __le64 **virtio_balloon_load_hints(struct virtio_balloon *vb,
> +					   uint32_t *array_num,
> +					   uint32_t *last_array_hints)
> +{
> +	__le64 **arrays;
> +	uint32_t max_entries, entries_per_page, entries_per_array,
> +		 max_array_num, loaded_hints;

All above likely should be int.

> +	int i;
> +
> +	max_entries = max_free_page_blocks(ARRAY_ALLOC_ORDER);
> +	entries_per_page = PAGE_SIZE / sizeof(__le64);
> +	entries_per_array = entries_per_page * (1 << ARRAY_ALLOC_ORDER);
> +	max_array_num = max_entries / entries_per_array +
> +			!!(max_entries % entries_per_array);
> +	arrays = kmalloc_array(max_array_num, sizeof(__le64 *), GFP_KERNEL);

Instead of all this mess, how about get_free_pages here as well?

Also why do we need GFP_KERNEL for this?


> +	if (!arrays)
> +		return NULL;
> +
> +	for (i = 0; i < max_array_num; i++) {

So we are getting a ton of memory here just to free it up a bit later.
Why doesn't get_from_free_page_list get the pages from free list for us?
We could also avoid the 1st allocation then - just build a list
of these.


> +		arrays[i] =
> +		(__le64 *)__get_free_pages(__GFP_ATOMIC | __GFP_NOMEMALLOC,
> +					   ARRAY_ALLOC_ORDER);

Coding style says:

Descendants are always substantially shorter than the parent and
are placed substantially to the right. 

> +		if (!arrays[i]) {
Also if it does fail (small guest), shall we try with less arrays?
> +			/*
> +			 * If any one of the arrays fails to be allocated, it
> +			 * implies that the free list that we are interested
> +			 * in is empty, and there is no need to continue the
> +			 * reporting. So just free what's allocated and return
> +			 * NULL.
> +			 */
> +			while (i > 0)
> +				free_pages((unsigned long)arrays[i--],
> +					   ARRAY_ALLOC_ORDER);
> +			kfree(arrays);
> +			return NULL;
> +		}
> +	}
> +	loaded_hints = get_from_free_page_list(ARRAY_ALLOC_ORDER,
> +					       max_array_num, arrays,
> +					       entries_per_array);
> +	*array_num = loaded_hints / entries_per_array +
> +		     !!(max_entries % entries_per_array);
> +	*last_array_hints = loaded_hints -
> +			    (*array_num - 1) * entries_per_array;
> +	for (i = *array_num; i < max_array_num; i++)
> +		free_pages((unsigned long)arrays[i], ARRAY_ALLOC_ORDER);
> +
> +	return arrays;
> +}
> +
> +static void report_free_page_func(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +	uint32_t array_num = 0, last_array_hints = 0;
> +	__le64 **arrays;
> +
> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> +	vb->cmd_id_active = vb->cmd_id_received;
> +
> +	arrays = virtio_balloon_load_hints(vb, &array_num, &last_array_hints);
> +	if (arrays) {
> +		virtio_balloon_send_hints(vb, arrays, array_num,
> +					  last_array_hints);
> +		kfree(arrays);
> +	}
> +}
> +
>  #ifdef CONFIG_BALLOON_COMPACTION
>  /*
>   * virtballoon_migratepage - perform the balloon page migration on behalf of
> @@ -576,18 +830,30 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> +		vb->balloon_wq = alloc_workqueue("balloon-wq",
> +					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
> +		if (!vb->balloon_wq) {
> +			err = -ENOMEM;
> +			goto out_del_vqs;
> +		}
> +		INIT_WORK(&vb->report_free_page_work, report_free_page_func);
> +		vb->cmd_id_received = VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID;
> +		vb->cmd_id_active = VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID;
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
> @@ -597,7 +863,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		kern_unmount(balloon_mnt);
>  		unregister_oom_notifier(&vb->nb);
>  		vb->vb_dev_info.inode = NULL;
> -		goto out_del_vqs;
> +		goto out_del_balloon_wq;
>  	}
>  	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
>  #endif
> @@ -608,6 +874,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		virtballoon_changed(vdev);
>  	return 0;
>  
> +out_del_balloon_wq:
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
> +		destroy_workqueue(vb->balloon_wq);
>  out_del_vqs:
>  	vdev->config->del_vqs(vdev);
>  out_free_vb:
> @@ -641,6 +910,11 @@ static void virtballoon_remove(struct virtio_device *vdev)
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
> @@ -692,6 +966,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 13b8cb5..860456f 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,15 +34,26 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
>  
> +#define VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID	0
>  struct virtio_balloon_config {
>  	/* Number of pages host wants Guest to give up. */
>  	__u32 num_pages;
>  	/* Number of pages we've actually got in balloon. */
>  	__u32 actual;
> +	/* Free page report command id, readonly by guest */
> +	__u32 free_page_report_cmd_id;
> +};
> +
> +struct virtio_balloon_free_page_hints_cmd {
> +	/* The command id received from host */
> +	__le32 id;
> +	/* The free page block size in bytes */
> +	__le32 size;
>  };
>  
>  #define VIRTIO_BALLOON_S_SWAP_IN  0   /* Amount of memory swapped in */
> -- 
> 2.7.4
