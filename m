Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4416B0033
	for <linux-mm@kvack.org>; Sat, 20 Jan 2018 09:24:13 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f18so4898448iof.8
        for <linux-mm@kvack.org>; Sat, 20 Jan 2018 06:24:13 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g5si2876236itb.149.2018.01.20.06.24.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 20 Jan 2018 06:24:11 -0800 (PST)
Subject: Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180117180337-mutt-send-email-mst@kernel.org>
	<2bb0e3d9-1679-9ad3-b402-f0781f6cf094@I-love.SAKURA.ne.jp>
	<20180118210239-mutt-send-email-mst@kernel.org>
	<201801190611.HGI18722.FVtOMQLSHFFOOJ@I-love.SAKURA.ne.jp>
	<20180119003101-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180119003101-mutt-send-email-mst@kernel.org>
Message-Id: <201801202323.JHH12456.VtOFHSLOMQFOFJ@I-love.SAKURA.ne.jp>
Date: Sat, 20 Jan 2018 23:23:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Michael S. Tsirkin wrote:
> > > > >> +	 * the page if the vq is full. We are adding one entry each time,
> > > > >> +	 * which essentially results in no memory allocation, so the
> > > > >> +	 * GFP_KERNEL flag below can be ignored.
> > > > >> +	 */
> > > > >> +	if (vq->num_free) {
> > > > >> +		err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> > > > > 
> > > > > Should we kick here? At least when ring is close to
> > > > > being full. Kick at half way full?
> > > > > Otherwise it's unlikely ring will
> > > > > ever be cleaned until we finish the scan.
> > > > 
> > > > Since this add_one_sg() is called between spin_lock_irqsave(&zone->lock, flags)
> > > > and spin_unlock_irqrestore(&zone->lock, flags), it is not permitted to sleep.
> > > 
> > > kick takes a while sometimes but it doesn't sleep.
> > 
> > I don't know about virtio. But the purpose of kicking here is to wait for pending data
> > to be flushed in order to increase vq->num_free, isn't it?
> 
> It isn't. It's to wake up device out of sleep to make it start
> processing the pending data. If device isn't asleep, it's a nop.

We need to wait until vq->num_free > 0 if vq->num_free == 0 if we want to allow
virtqueue_add_inbuf() to succeed. When will vq->num_free++ be called?

You said virtqueue_kick() is a no-op if the device is not asleep.
Then, there will be no guarantee that we can make vq->num_free > 0
by calling virtqueue_kick(). Are you saying that

	virtqueue_kick(vq);
	while (!vq->num_free)
		virtqueue_get_buf(vq, &unused);
	err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
	BUG_ON(err);

sequence from IRQ disabled atomic context is safe? If no, what is
the point with calling virtqueue_kick() when ring is close to being
(half way) full? We can't guarantee that all data is sent to QEMU after all.



Also, why does the cmd id matter? If VIRTIO_BALLOON_F_FREE_PAGE_VQ does not
guarantee the atomicity, I don't see the point of communicating the cmd id
between the QEMU and the guest kernel. Just an EOF marker should be enough.
I do want to see changes for the QEMU side in order to review changes for
the guest kernel side.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
