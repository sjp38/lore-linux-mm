Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8D06B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:15:49 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id f4so147977239qte.1
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:15:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w5si7400630qte.45.2017.01.17.11.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 11:15:47 -0800 (PST)
Date: Tue, 17 Jan 2017 21:15:45 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v6 kernel 3/5] virtio-balloon: speed up inflate/deflate
 process
Message-ID: <20170117211131-mutt-send-email-mst@kernel.org>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, david@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com

On Wed, Dec 21, 2016 at 02:52:26PM +0800, Liang Li wrote:
>  
> -	/* We should always be able to add one buffer to an empty queue. */
> -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> -	virtqueue_kick(vq);
> +static void do_set_resp_bitmap(struct virtio_balloon *vb,
> +		unsigned long base_pfn, int pages)
>  
> -	/* When host has read buffer, this completes via balloon_ack */
> -	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> +{
> +	__le64 *range = vb->resp_data + vb->resp_pos;
>  
> +	if (pages > (1 << VIRTIO_BALLOON_NR_PFN_BITS)) {
> +		/* when the length field can't contain pages, set it to 0 to

/*
 * Multi-line
 * comments
 * should look like this.
 */

Also, pls start sentences with an upper-case letter.

> +		 * indicate the actual length is in the next __le64;
> +		 */

This is part of the interface so should be documented as such.

> +		*range = cpu_to_le64((base_pfn <<
> +				VIRTIO_BALLOON_NR_PFN_BITS) | 0);
> +		*(range + 1) = cpu_to_le64(pages);
> +		vb->resp_pos += 2;

Pls use structs for this kind of stuff.

> +	} else {
> +		*range = (base_pfn << VIRTIO_BALLOON_NR_PFN_BITS) | pages;
> +		vb->resp_pos++;
> +	}
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
