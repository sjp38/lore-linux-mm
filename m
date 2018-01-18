Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41FA06B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 14:09:17 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id e9so13316878oib.10
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:09:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si3516681otv.61.2018.01.18.11.09.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 11:09:16 -0800 (PST)
Date: Thu, 18 Jan 2018 21:09:08 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20180118210239-mutt-send-email-mst@kernel.org>
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com>
 <1516165812-3995-3-git-send-email-wei.w.wang@intel.com>
 <20180117180337-mutt-send-email-mst@kernel.org>
 <2bb0e3d9-1679-9ad3-b402-f0781f6cf094@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2bb0e3d9-1679-9ad3-b402-f0781f6cf094@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Thu, Jan 18, 2018 at 10:30:18PM +0900, Tetsuo Handa wrote:
> On 2018/01/18 1:44, Michael S. Tsirkin wrote:
> >> +static void add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
> >> +{
> >> +	struct scatterlist sg;
> >> +	unsigned int unused;
> >> +	int err;
> >> +
> >> +	sg_init_table(&sg, 1);
> >> +	sg_set_page(&sg, pfn_to_page(pfn), len, 0);
> >> +
> >> +	/* Detach all the used buffers from the vq */
> >> +	while (virtqueue_get_buf(vq, &unused))
> >> +		;
> >> +
> >> +	/*
> >> +	 * Since this is an optimization feature, losing a couple of free
> >> +	 * pages to report isn't important.
> >> We simply resturn
> > 
> > return
> > 
> >> without adding
> >> +	 * the page if the vq is full. We are adding one entry each time,
> >> +	 * which essentially results in no memory allocation, so the
> >> +	 * GFP_KERNEL flag below can be ignored.
> >> +	 */
> >> +	if (vq->num_free) {
> >> +		err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> > 
> > Should we kick here? At least when ring is close to
> > being full. Kick at half way full?
> > Otherwise it's unlikely ring will
> > ever be cleaned until we finish the scan.
> 
> Since this add_one_sg() is called between spin_lock_irqsave(&zone->lock, flags)
> and spin_unlock_irqrestore(&zone->lock, flags), it is not permitted to sleep.

kick takes a while sometimes but it doesn't sleep.

> And walk_free_mem_block() is not ready to handle resume.
> 
> By the way, specifying GFP_KERNEL here is confusing even though it is never used.
> walk_free_mem_block() says:
> 
>   * The callback itself must not sleep or perform any operations which would
>   * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
>   * or via any lock dependency. 

Yea, GFP_ATOMIC would do just as well. But I think any allocation
on this path would be problematic.

How about a flag to make all allocations fail?

E.g. 

#define GFP_FORBIDDEN (___GFP_DMA | ___GFP_HIGHMEM)

Still this is not a blocker, we can worry about this later.


> > 
> >> +		/*
> >> +		 * This is expected to never fail, because there is always an
> >> +		 * entry available on the vq.
> >> +		 */
> >> +		BUG_ON(err);
> >> +	}
> >> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
