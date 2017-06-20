Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 388066B0317
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:18:55 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id v20so83447989qtg.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:18:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t27si1869055qkt.98.2017.06.20.09.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 09:18:54 -0700 (PDT)
Date: Tue, 20 Jun 2017 19:18:46 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 6/6] virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
Message-ID: <20170620190343-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
 <1497004901-30593-7-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497004901-30593-7-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On Fri, Jun 09, 2017 at 06:41:41PM +0800, Wei Wang wrote:
> -	if (!virtqueue_indirect_desc_table_add(vq, desc, num)) {
> +	if (!virtqueue_indirect_desc_table_add(vq, desc, *num)) {
>  		virtqueue_kick(vq);
> -		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> -		vb->balloon_page_chunk.chunk_num = 0;
> +		if (busy_wait)
> +			while (!virtqueue_get_buf(vq, &len) &&
> +			       !virtqueue_is_broken(vq))
> +				cpu_relax();
> +		else
> +			wait_event(vb->acked, virtqueue_get_buf(vq, &len));


This is something I didn't previously notice.
As you always keep a single buffer in flight, you do not
really need indirect at all. Just add all descriptors
in the ring directly, then kick.

E.g.
	virtqueue_add_first
	virtqueue_add_next
	virtqueue_add_last

?

You also want a flag to avoid allocations but there's no need to do it
per descriptor, set it on vq.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
