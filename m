Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 398D46B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 16:11:51 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y20so11603465ita.5
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 13:11:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u203si6757591iod.284.2018.01.18.13.11.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 13:11:49 -0800 (PST)
Subject: Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com>
	<1516165812-3995-3-git-send-email-wei.w.wang@intel.com>
	<20180117180337-mutt-send-email-mst@kernel.org>
	<2bb0e3d9-1679-9ad3-b402-f0781f6cf094@I-love.SAKURA.ne.jp>
	<20180118210239-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180118210239-mutt-send-email-mst@kernel.org>
Message-Id: <201801190611.HGI18722.FVtOMQLSHFFOOJ@I-love.SAKURA.ne.jp>
Date: Fri, 19 Jan 2018 06:11:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Michael S. Tsirkin wrote:
> On Thu, Jan 18, 2018 at 10:30:18PM +0900, Tetsuo Handa wrote:
> > On 2018/01/18 1:44, Michael S. Tsirkin wrote:
> > >> +static void add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
> > >> +{
> > >> +	struct scatterlist sg;
> > >> +	unsigned int unused;
> > >> +	int err;
> > >> +
> > >> +	sg_init_table(&sg, 1);
> > >> +	sg_set_page(&sg, pfn_to_page(pfn), len, 0);
> > >> +
> > >> +	/* Detach all the used buffers from the vq */
> > >> +	while (virtqueue_get_buf(vq, &unused))
> > >> +		;
> > >> +
> > >> +	/*
> > >> +	 * Since this is an optimization feature, losing a couple of free
> > >> +	 * pages to report isn't important.
> > >> We simply resturn
> > > 
> > > return
> > > 
> > >> without adding
> > >> +	 * the page if the vq is full. We are adding one entry each time,
> > >> +	 * which essentially results in no memory allocation, so the
> > >> +	 * GFP_KERNEL flag below can be ignored.
> > >> +	 */
> > >> +	if (vq->num_free) {
> > >> +		err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> > > 
> > > Should we kick here? At least when ring is close to
> > > being full. Kick at half way full?
> > > Otherwise it's unlikely ring will
> > > ever be cleaned until we finish the scan.
> > 
> > Since this add_one_sg() is called between spin_lock_irqsave(&zone->lock, flags)
> > and spin_unlock_irqrestore(&zone->lock, flags), it is not permitted to sleep.
> 
> kick takes a while sometimes but it doesn't sleep.

I don't know about virtio. But the purpose of kicking here is to wait for pending data
to be flushed in order to increase vq->num_free, isn't it? Then, doesn't waiting for
pending data to be flushed involve sleeping? If yes, we can wait for completion of kick
but we can't wait for completion of flush. Is pending data flushed without sleep?

> 
> > And walk_free_mem_block() is not ready to handle resume.
> > 
> > By the way, specifying GFP_KERNEL here is confusing even though it is never used.
> > walk_free_mem_block() says:
> > 
> >   * The callback itself must not sleep or perform any operations which would
> >   * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
> >   * or via any lock dependency. 
> 
> Yea, GFP_ATOMIC would do just as well. But I think any allocation
> on this path would be problematic.
> 
> How about a flag to make all allocations fail?
> 
> E.g. 
> 
> #define GFP_FORBIDDEN (___GFP_DMA | ___GFP_HIGHMEM)
> 
> Still this is not a blocker, we can worry about this later.
> 
> 
> > > 
> > >> +		/*
> > >> +		 * This is expected to never fail, because there is always an
> > >> +		 * entry available on the vq.
> > >> +		 */
> > >> +		BUG_ON(err);
> > >> +	}
> > >> +}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
