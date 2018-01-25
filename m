Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A9836800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 22:29:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u65so4825459pfd.7
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 19:29:37 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d9-v6si569809pli.825.2018.01.24.19.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 19:29:36 -0800 (PST)
Message-ID: <5A694FB5.5090803@intel.com>
Date: Thu, 25 Jan 2018 11:32:05 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v24 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1516790562-37889-1-git-send-email-wei.w.wang@intel.com> <1516790562-37889-3-git-send-email-wei.w.wang@intel.com> <20180124183349-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180124183349-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/25/2018 01:15 AM, Michael S. Tsirkin wrote:
> On Wed, Jan 24, 2018 at 06:42:42PM +0800, Wei Wang wrote:
> +
> +static void report_free_page_func(struct work_struct *work)
> +{
> +	struct virtio_balloon *vb;
> +	unsigned long flags;
> +
> +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> +
> +	/* Start by sending the obtained cmd id to the host with an outbuf */
> +	send_cmd_id(vb, &vb->start_cmd_id);
> +
> +	/*
> +	 * Set start_cmd_id to VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID to
> +	 * indicate a new request can be queued.
> +	 */
> +	spin_lock_irqsave(&vb->stop_update_lock, flags);
> +	vb->start_cmd_id = cpu_to_virtio32(vb->vdev,
> +				VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
> +	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> +
> +	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> Can you teach walk_free_mem_block to return the && of all
> return calls, so caller knows whether it completed?

There will be two cases that can cause walk_free_mem_block to return 
without completing:
1) host requests to stop in advance
2) vq->broken

How about letting walk_free_mem_block simply return the value returned 
by its callback (i.e. virtio_balloon_send_free_pages)?

For host requests to stop, it returns "1", and the above only bails out 
when walk_free_mem_block return a "< 0" value.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
