Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 734A86B0278
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 14:29:42 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id q126so24184110vkd.4
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 11:29:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 68si4020850vkn.191.2016.10.27.11.29.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 11:29:41 -0700 (PDT)
Date: Thu, 27 Oct 2016 21:29:38 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RESEND PATCH v3 kernel 6/7] virtio-balloon: define feature bit
 and head for misc virt queue
Message-ID: <20161027211928-mutt-send-email-mst@kernel.org>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-7-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1477031080-12616-7-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com

On Fri, Oct 21, 2016 at 02:24:39PM +0800, Liang Li wrote:
> Define a new feature bit which supports a new virtual queue. This
> new virtual qeuque is for information exchange between hypervisor
> and guest. The VMM hypervisor can make use of this virtual queue
> to request the guest do some operations, e.g. drop page cache,
> synchronize file system, etc.

Can we call this something more informative pls?
host request vq?

> And the VMM hypervisor can get some
> of guest's runtime information through this virtual queue, e.g. the
> guest's unused page information, which can be used for live migration
> optimization.

I guess the idea is that guest gets requests from host and
then responds to them on this vq. Pls document.

> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Amit Shah <amit.shah@redhat.com>
> ---
>  include/uapi/linux/virtio_balloon.h | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index d3b182a..3a9d633 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -35,6 +35,7 @@
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_PAGE_BITMAP	3 /* Send page info with bitmap */
> +#define VIRTIO_BALLOON_F_MISC_VQ	4 /* Misc info virtqueue */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> @@ -101,4 +102,25 @@ struct balloon_bmap_hdr {
>  	__virtio64 bmap_len;
>  };
>  
> +enum balloon_req_id {
> +	/* Get unused pages information */

unused page information


> +	BALLOON_GET_UNUSED_PAGES,
> +};
> +
> +enum balloon_flag {
> +	/* Have more data for a request */
> +	BALLOON_FLAG_CONT,
> +	/* No more data for a request */
> +	BALLOON_FLAG_DONE,
> +};

is this a bit number or a value? Pls name consistently.

> +
> +struct balloon_req_hdr {
> +	/* Used to distinguish different request */

requests

> +	__virtio16 cmd;
> +	/* Reserved */
> +	__virtio16 reserved[3];
> +	/* Request parameter */
> +	__virtio64 param;
> +};
> +
>  #endif /* _LINUX_VIRTIO_BALLOON_H */


Prefix structs with virtio_ as well pls.
Also, wouldn't it simplify code if we use __le for new structs?

> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
