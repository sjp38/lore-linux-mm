Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF116B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:25:12 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id k7so2885064qke.11
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:25:12 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d14si645700qte.132.2018.02.08.11.25.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 11:25:11 -0800 (PST)
Date: Thu, 8 Feb 2018 21:25:10 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v28 4/4] virtio-balloon: VIRTIO_BALLOON_F_PAGE_POISON
Message-ID: <20180208212414-mutt-send-email-mst@kernel.org>
References: <1518083420-11108-1-git-send-email-wei.w.wang@intel.com>
 <1518083420-11108-5-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518083420-11108-5-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On Thu, Feb 08, 2018 at 05:50:20PM +0800, Wei Wang wrote:
> The VIRTIO_BALLOON_F_PAGE_POISON feature bit is used to indicate if the
> guest is using page poisoning. Guest writes to the poison_val config
> field to tell host about the page poisoning value in use.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  drivers/virtio/virtio_balloon.c     | 13 +++++++++++++
>  include/uapi/linux/virtio_balloon.h |  3 +++
>  2 files changed, 16 insertions(+)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 39ecce3..9fa7fcf 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -685,6 +685,7 @@ static struct file_system_type balloon_fs = {
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> +	__u32 poison_val;
>  	int err;
>  
>  	if (!vdev->config->get) {
> @@ -728,6 +729,12 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  			goto out_del_vqs;
>  		}
>  		INIT_WORK(&vb->report_free_page_work, report_free_page_func);
> +		if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
> +			page_poison_val_get((u8 *)&poison_val);
> +			memset(&poison_val, poison_val, sizeof(poison_val));

This will not DTRT on big-endian platforms.
Just use a local u8 variable.

> +			virtio_cwrite(vb->vdev, struct virtio_balloon_config,
> +				      poison_val, &poison_val);
> +		}
>  	}
>  
>  	vb->nb.notifier_call = virtballoon_oom_notify;
> @@ -846,6 +853,11 @@ static int virtballoon_restore(struct virtio_device *vdev)
>  
>  static int virtballoon_validate(struct virtio_device *vdev)
>  {
> +	uint8_t unused;
> +
> +	if (!page_poison_val_get(&unused))
> +		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_POISON);
> +
>  	__virtio_clear_bit(vdev, VIRTIO_F_IOMMU_PLATFORM);
>  	return 0;
>  }
> @@ -855,6 +867,7 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>  	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
> +	VIRTIO_BALLOON_F_PAGE_POISON,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 0c654db..3f97067 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -35,6 +35,7 @@
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
> +#define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> @@ -47,6 +48,8 @@ struct virtio_balloon_config {
>  	__u32 actual;
>  	/* Free page report command id, readonly by guest */
>  	__u32 free_page_report_cmd_id;
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
