Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38B136B0260
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 14:43:18 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id a195so25543698qkg.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:43:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u6si6795754qkc.182.2017.01.12.11.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 11:43:17 -0800 (PST)
Date: Thu, 12 Jan 2017 21:43:15 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v6 kernel 2/5] virtio-balloon: define new feature bit and
 head struct
Message-ID: <20170112185719-mutt-send-email-mst@kernel.org>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <1482303148-22059-3-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482303148-22059-3-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, david@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com

On Wed, Dec 21, 2016 at 02:52:25PM +0800, Liang Li wrote:
> Add a new feature which supports sending the page information
> with range array. The current implementation uses PFNs array,
> which is not very efficient. Using ranges can improve the
> performance of inflating/deflating significantly.
> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Amit Shah <amit.shah@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: David Hildenbrand <david@redhat.com>
> ---
>  include/uapi/linux/virtio_balloon.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7dd..2f850bf 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,10 +34,14 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_PAGE_RANGE	3 /* Send page info with ranges */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
>  
> +/* Bits width for the length of the pfn range */

What does this mean? Couldn't figure it out.

> +#define VIRTIO_BALLOON_NR_PFN_BITS 12
> +
>  struct virtio_balloon_config {
>  	/* Number of pages host wants Guest to give up. */
>  	__u32 num_pages;
> @@ -82,4 +86,12 @@ struct virtio_balloon_stat {
>  	__virtio64 val;
>  } __attribute__((packed));
>  
> +/* Response header structure */
> +struct virtio_balloon_resp_hdr {
> +	__le64 cmd : 8; /* Distinguish different requests type */
> +	__le64 flag: 8; /* Mark status for a specific request type */
> +	__le64 id : 16; /* Distinguish requests of a specific type */
> +	__le64 data_len: 32; /* Length of the following data, in bytes */

This use of __le64 makes no sense.  Just use u8/le16/le32 pls.

> +};
> +
>  #endif /* _LINUX_VIRTIO_BALLOON_H */
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
