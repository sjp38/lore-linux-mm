Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 33F0D6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 07:23:41 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p65so32306261wmp.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 04:23:41 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id s3si10107499wmf.48.2016.03.03.04.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 04:23:40 -0800 (PST)
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cornelia.huck@de.ibm.com>;
	Thu, 3 Mar 2016 12:23:39 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2ECBE17D8042
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 12:24:02 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u23CNajX54329366
	for <linux-mm@kvack.org>; Thu, 3 Mar 2016 12:23:36 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u23CNaBW015988
	for <linux-mm@kvack.org>; Thu, 3 Mar 2016 05:23:36 -0700
Date: Thu, 3 Mar 2016 13:23:34 +0100
From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [RFC qemu 2/4] virtio-balloon: Add a new feature to balloon
 device
Message-ID: <20160303132334.5e4565df.cornelia.huck@de.ibm.com>
In-Reply-To: <1457001868-15949-3-git-send-email-liang.z.li@intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
	<1457001868-15949-3-git-send-email-liang.z.li@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>
Cc: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, mst@redhat.com, akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com

On Thu,  3 Mar 2016 18:44:26 +0800
Liang Li <liang.z.li@intel.com> wrote:

> Extend the virtio balloon device to support a new feature, this
> new feature can help to get guest's free pages information, which
> can be used for live migration optimzation.

Do you have a spec for this, e.g. as a patch to the virtio spec?

> 
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> ---
>  balloon.c                                       | 30 ++++++++-
>  hw/virtio/virtio-balloon.c                      | 81 ++++++++++++++++++++++++-
>  include/hw/virtio/virtio-balloon.h              | 17 +++++-
>  include/standard-headers/linux/virtio_balloon.h |  1 +
>  include/sysemu/balloon.h                        | 10 ++-
>  5 files changed, 134 insertions(+), 5 deletions(-)

> +static int virtio_balloon_free_pages(void *opaque,
> +                                     unsigned long *free_pages_bitmap,
> +                                     unsigned long *free_pages_count)
> +{
> +    VirtIOBalloon *s = opaque;
> +    VirtIODevice *vdev = VIRTIO_DEVICE(s);
> +    VirtQueueElement *elem = s->free_pages_vq_elem;
> +    int len;
> +
> +    if (!balloon_free_pages_supported(s)) {
> +        return -1;
> +    }
> +
> +    if (s->req_status == NOT_STARTED) {
> +        s->free_pages_bitmap = free_pages_bitmap;
> +        s->req_status = STARTED;
> +        s->mem_layout.low_mem = pc_get_lowmem(PC_MACHINE(current_machine));

Please don't leak pc-specific information into generic code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
