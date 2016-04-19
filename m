Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A04F6B0260
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 12:19:01 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id f185so39434046vkb.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 09:19:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y101si4942824qge.123.2016.04.19.09.19.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 09:19:00 -0700 (PDT)
Date: Tue, 19 Apr 2016 19:18:55 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH kernel 2/2] virtio-balloon: extend balloon driver to
 support the new feature
Message-ID: <20160419191557-mutt-send-email-mst@redhat.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-3-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461076474-3864-3-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com, linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com

On Tue, Apr 19, 2016 at 10:34:34PM +0800, Liang Li wrote:
> Extend the virtio balloon to support the new feature
> VIRTIO_BALLOON_F_GET_FREE_PAGES, so that we can use it to send
> the free page bitmap from guest to QEMU, the free page bitmap will
> be used for live migration optimization.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>

Two points:
- please post description of your interface proposals
  to virtio tc comment list
- please split this up
	- feature to use a bitmap for inflate/deflate
	- a 3rd vq which does inflate/deflate in one go

  there seems no reason to use bitmap for free pages
  but not for inflate/deflate

> ---
>  drivers/virtio/virtio_balloon.c     | 100 ++++++++++++++++++++++++++++++++++--
>  include/uapi/linux/virtio_balloon.h |   1 +
>  2 files changed, 96 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 7b6d74f..cf17694 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -45,9 +45,17 @@ static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
>  module_param(oom_pages, int, S_IRUSR | S_IWUSR);
>  MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>  
> +extern void get_free_pages(unsigned long *free_page_bitmap,
> +				unsigned long len, int drop);
> +extern unsigned long get_max_pfn(void);
> +
> +struct cache_drop_ctrl {
> +	u64 ctrl;
> +};
> +
>  struct virtio_balloon {
>  	struct virtio_device *vdev;
> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_pages_vq;
>  
>  	/* The balloon servicing is delegated to a freezable workqueue. */
>  	struct work_struct update_balloon_stats_work;
> @@ -77,6 +85,10 @@ struct virtio_balloon {
>  	unsigned int num_pfns;
>  	u32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
>  
> +	unsigned long *free_pages;
> +	unsigned long bmap_len;
> +	struct cache_drop_ctrl cache_drop;
> +
>  	/* Memory statistics */
>  	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
>  
> @@ -256,6 +268,64 @@ static void update_balloon_stats(struct virtio_balloon *vb)
>  				pages_to_bytes(available));
>  }
>  
> +static void update_free_pages_stats(struct virtio_balloon *vb)
> +{
> +	unsigned long bitmap_bytes, max_pfn;
> +
> +	max_pfn = get_max_pfn();
> +	bitmap_bytes = ALIGN(max_pfn, BITS_PER_LONG) / 8;
> +
> +	if (!vb->free_pages)
> +		vb->free_pages = kzalloc(bitmap_bytes, GFP_KERNEL);
> +	else {
> +		if (bitmap_bytes < vb->bmap_len)
> +			memset(vb->free_pages, 0, bitmap_bytes);
> +		else {
> +			kfree(vb->free_pages);
> +			vb->free_pages = kzalloc(bitmap_bytes, GFP_KERNEL);
> +		}
> +	}
> +	if (!vb->free_pages) {
> +		vb->bmap_len = 0;
> +		return;
> +	}
> +
> +	vb->bmap_len = bitmap_bytes;
> +	get_free_pages(vb->free_pages, max_pfn, vb->cache_drop.ctrl);
> +}
> +
> +static void free_pages_handle_rq(struct virtio_balloon *vb)
> +{
> +	struct virtqueue *vq;
> +	struct scatterlist sg[2];
> +	unsigned int len;
> +	struct cache_drop_ctl *ptr_cache_drop;
> +	struct scatterlist sg_in;
> +
> +	vq = vb->free_pages_vq;
> +	ptr_cache_drop = virtqueue_get_buf(vq, &len);
> +
> +	if (!ptr_cache_drop || len != sizeof(vb->cache_drop))
> +		return;
> +	update_free_pages_stats(vb);
> +	sg_init_table(sg, 2);
> +	sg_set_buf(&sg[0], &(vb->bmap_len), sizeof(vb->bmap_len));
> +	sg_set_buf(&sg[1], vb->free_pages, vb->bmap_len);
> +
> +	sg_init_one(&sg_in, &vb->cache_drop, sizeof(vb->cache_drop));
> +
> +	virtqueue_add_outbuf(vq, &sg[0], 2, vb, GFP_KERNEL);
> +	virtqueue_add_inbuf(vq, &sg_in, 1, &vb->cache_drop, GFP_KERNEL);
> +	virtqueue_kick(vq);
> +}
> +
> +static void free_pages_rq(struct virtqueue *vq)
> +{
> +	struct virtio_balloon *vb = vq->vdev->priv;
> +
> +	free_pages_handle_rq(vb);
> +}
> +
>  /*
>   * While most virtqueues communicate guest-initiated requests to the hypervisor,
>   * the stats queue operates in reverse.  The driver initializes the virtqueue
> @@ -392,16 +462,22 @@ static void update_balloon_size_func(struct work_struct *work)
>  
>  static int init_vqs(struct virtio_balloon *vb)
>  {
> -	struct virtqueue *vqs[3];
> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
> -	static const char * const names[] = { "inflate", "deflate", "stats" };
> +	struct virtqueue *vqs[4];
> +	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack,
> +					 stats_request, free_pages_rq };
> +	const char *names[] = { "inflate", "deflate", "stats", "free_pages" };
>  	int err, nvqs;
>  
>  	/*
>  	 * We expect two virtqueues: inflate and deflate, and
>  	 * optionally stat.
>  	 */
> -	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_GET_FREE_PAGES))
> +		nvqs = 4;
> +	else
> +		nvqs = virtio_has_feature(vb->vdev,
> +					  VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> +
>  	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
>  	if (err)
>  		return err;
> @@ -422,6 +498,16 @@ static int init_vqs(struct virtio_balloon *vb)
>  			BUG();
>  		virtqueue_kick(vb->stats_vq);
>  	}
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_GET_FREE_PAGES)) {
> +		struct scatterlist sg_in;
> +
> +		vb->free_pages_vq = vqs[3];
> +		sg_init_one(&sg_in, &vb->cache_drop, sizeof(vb->cache_drop));
> +		if (virtqueue_add_inbuf(vb->free_pages_vq, &sg_in, 1,
> +		    &vb->cache_drop, GFP_KERNEL) < 0)
> +			BUG();
> +		virtqueue_kick(vb->free_pages_vq);
> +	}
>  	return 0;
>  }
>  
> @@ -505,6 +591,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		goto out;
>  	}
>  
> +	vb->bmap_len = 0;
> +	vb->free_pages = NULL;
>  	INIT_WORK(&vb->update_balloon_stats_work, update_balloon_stats_func);
>  	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
>  	spin_lock_init(&vb->stop_update_lock);
> @@ -567,6 +655,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  	cancel_work_sync(&vb->update_balloon_stats_work);
>  
>  	remove_common(vb);
> +	kfree(vb->free_pages);
>  	kfree(vb);
>  }
>  
> @@ -605,6 +694,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_GET_FREE_PAGES,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7dd..2b41e4f 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,6 +34,7 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_GET_FREE_PAGES	3 /* Get free page bitmap */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
