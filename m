Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F06D06B0543
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 09:06:31 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d78so11931639qkb.0
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 06:06:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b38si2255956qtb.346.2017.07.12.06.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 06:06:31 -0700 (PDT)
Date: Wed, 12 Jul 2017 16:06:18 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20170712160129-mutt-send-email-mst@kernel.org>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-6-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499863221-16206-6-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Wed, Jul 12, 2017 at 08:40:18PM +0800, Wei Wang wrote:
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index 28b0e96..9f27101 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -57,8 +57,28 @@ int virtqueue_add_sgs(struct virtqueue *vq,
>  		      void *data,
>  		      gfp_t gfp);
>  
> +/* A desc with this init id is treated as an invalid desc */
> +#define VIRTQUEUE_DESC_ID_INIT UINT_MAX
> +int virtqueue_add_chain_desc(struct virtqueue *_vq,
> +			     uint64_t addr,
> +			     uint32_t len,
> +			     unsigned int *head_id,
> +			     unsigned int *prev_id,
> +			     bool in);
> +
> +int virtqueue_add_chain(struct virtqueue *_vq,
> +			unsigned int head,
> +			bool indirect,
> +			struct vring_desc *indirect_desc,
> +			void *data,
> +			void *ctx);
> +
>  bool virtqueue_kick(struct virtqueue *vq);
>  
> +bool virtqueue_kick_sync(struct virtqueue *vq);
> +
> +bool virtqueue_kick_async(struct virtqueue *vq, wait_queue_head_t wq);
> +
>  bool virtqueue_kick_prepare(struct virtqueue *vq);
>  
>  bool virtqueue_notify(struct virtqueue *vq);

I don't much care for this API. It does exactly what balloon needs,
but at cost of e.g. transparently busy-waiting. Unlikely to be
a good fit for anything else.

If you don't like my original _first/_next/_last, you will
need to come up with something else.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
