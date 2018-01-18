Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55E256B025E
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:37:29 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id e9so13667034oib.10
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 14:37:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 20si3256750oii.146.2018.01.18.14.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 14:37:28 -0800 (PST)
Date: Fri, 19 Jan 2018 00:37:18 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v22 3/3] virtio-balloon: don't report free pages when
 page poisoning is enabled
Message-ID: <20180119003650-mutt-send-email-mst@kernel.org>
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com>
 <1516165812-3995-4-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1516165812-3995-4-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Wed, Jan 17, 2018 at 01:10:12PM +0800, Wei Wang wrote:
> The guest free pages should not be discarded by the live migration thread
> when page poisoning is enabled with PAGE_POISONING_NO_SANITY=n, because
> skipping the transfer of such poisoned free pages will trigger false
> positive when new pages are allocated and checked on the destination.
> This patch adds a config field, poison_val. Guest writes to the config
> field to tell the host about the poisoning value. The value will be 0 in
> the following cases:
> 1) PAGE_POISONING_NO_SANITY is enabled;
> 2) page poisoning is disabled; or
> 3) PAGE_POISONING_ZERO is enabled.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>


Pls squash with the previous patch. It's not nice to break a
config, then fix it up later.

> ---
>  drivers/virtio/virtio_balloon.c     | 8 ++++++++
>  include/uapi/linux/virtio_balloon.h | 2 ++
>  2 files changed, 10 insertions(+)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index b9561a5..5a42235 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -706,6 +706,7 @@ static struct file_system_type balloon_fs = {
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> +	__u32 poison_val;
>  	int err;
>  
>  	if (!vdev->config->get) {
> @@ -740,6 +741,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
>  		INIT_WORK(&vb->report_free_page_work, report_free_page_func);
>  		vb->stop_cmd_id = VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID;
> +		if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY) ||
> +		    !page_poisoning_enabled())
> +			poison_val = 0;
> +		else
> +			poison_val = PAGE_POISON;
> +		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
> +			      poison_val, &poison_val);
>  	}
>  
>  	vb->nb.notifier_call = virtballoon_oom_notify;
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 55e2456..5861876 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -47,6 +47,8 @@ struct virtio_balloon_config {
>  	__u32 actual;
>  	/* Free page report command id, readonly by guest */
>  	__u32 free_page_report_cmd_id;
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
