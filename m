Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0A046B0265
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:35:58 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i34so6288933qkh.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:35:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r190si1699904qkd.122.2016.10.26.08.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 08:35:58 -0700 (PDT)
Date: Wed, 26 Oct 2016 18:35:54 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RESEND PATCH v3 kernel 2/7] virtio-balloon: define new feature
 bit and page bitmap head
Message-ID: <20161026162123-mutt-send-email-mst@kernel.org>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-3-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1477031080-12616-3-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com

On Fri, Oct 21, 2016 at 02:24:35PM +0800, Liang Li wrote:
> Add a new feature which supports sending the page information with
> a bitmap. The current implementation uses PFNs array, which is not
> very efficient. Using bitmap can improve the performance of
> inflating/deflating significantly
> 
> The page bitmap header will used to tell the host some information
> about the page bitmap. e.g. the page size, page bitmap length and
> start pfn.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Amit Shah <amit.shah@redhat.com>
> ---
>  include/uapi/linux/virtio_balloon.h | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7dd..d3b182a 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,6 +34,7 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_PAGE_BITMAP	3 /* Send page info with bitmap */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> @@ -82,4 +83,22 @@ struct virtio_balloon_stat {
>  	__virtio64 val;
>  } __attribute__((packed));
>  
> +/* Page bitmap header structure */
> +struct balloon_bmap_hdr {

Should be virtio_balloon.

> +	/* Used to distinguish different request */

different requests? what are the legal values?

> +	__virtio16 cmd;
> +	/* Shift width of page in the bitmap */

In which units?

> +	__virtio16 page_shift;
> +	/* flag used to identify different status */

this comment does not seem to add any value.

> +	__virtio16 flag;
> +	/* Reserved */

this too

> +	__virtio16 reserved;
> +	/* ID of the request */
> +	__virtio64 req_id;
> +	/* The pfn of 0 bit in the bitmap */
> +	__virtio64 start_pfn;
> +	/* The length of the bitmap, in bytes */

Why not in bits?

> +	__virtio64 bmap_len;
> +};
> +
>  #endif /* _LINUX_VIRTIO_BALLOON_H */
> -- 
> 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
