Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE5676B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:51:21 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hm5so16682162pac.4
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 09:51:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d198si16279552pga.237.2016.10.24.09.51.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 09:51:19 -0700 (PDT)
Subject: Re: [RESEND PATCH v3 kernel 2/7] virtio-balloon: define new feature
 bit and page bitmap head
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-3-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E3C07.701@intel.com>
Date: Mon, 24 Oct 2016 09:51:19 -0700
MIME-Version: 1.0
In-Reply-To: <1477031080-12616-3-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com

On 10/20/2016 11:24 PM, Liang Li wrote:
> Add a new feature which supports sending the page information with
> a bitmap. The current implementation uses PFNs array, which is not
> very efficient. Using bitmap can improve the performance of
> inflating/deflating significantly

Why is it not efficient?  How is using a bitmap more efficient?  What
kinds of cases is the bitmap inefficient?

> The page bitmap header will used to tell the host some information
> about the page bitmap. e.g. the page size, page bitmap length and
> start pfn.

Why did you choose to add these features to the structure?  What
benefits do they add?

Could you describe your solution a bit here, and describe its strengths
and weaknesses?

The same comments apply, even if (especially if) you change the data
structure.

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
> +	/* Used to distinguish different request */
> +	__virtio16 cmd;
> +	/* Shift width of page in the bitmap */
> +	__virtio16 page_shift;
> +	/* flag used to identify different status */
> +	__virtio16 flag;
> +	/* Reserved */
> +	__virtio16 reserved;
> +	/* ID of the request */
> +	__virtio64 req_id;
> +	/* The pfn of 0 bit in the bitmap */
> +	__virtio64 start_pfn;
> +	/* The length of the bitmap, in bytes */
> +	__virtio64 bmap_len;
> +};

FWIW this is totally unreadable.  Please do something like this:

> +struct balloon_bmap_hdr {
> +	__virtio16 cmd; 	/* Used to distinguish different ...
> +	__virtio16 page_shift; 	/* Shift width of page in the bitmap */
> +	__virtio16 flag; 	/* flag used to identify different...
> +	__virtio16 reserved;	/* Reserved */
> +	__virtio64 req_id;	/* ID of the request */
> +	__virtio64 start_pfn;	/* The pfn of 0 bit in the bitmap */
> +	__virtio64 bmap_len;	/* The length of the bitmap, in bytes */
> +};

and please make an effort to add useful comments.  "/* Reserved */"
seems like a waste of bytes to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
