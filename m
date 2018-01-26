Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 421226B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 21:42:17 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id s5so5505117oib.7
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 18:42:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f1si2339768otd.267.2018.01.25.18.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 18:42:15 -0800 (PST)
Date: Fri, 26 Jan 2018 04:42:08 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v25 2/2] virtio-balloon:
 VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180126042649-mutt-send-email-mst@kernel.org>
References: <1516871646-22741-1-git-send-email-wei.w.wang@intel.com>
 <1516871646-22741-3-git-send-email-wei.w.wang@intel.com>
 <20180125154708-mutt-send-email-mst@kernel.org>
 <5A6A871C.6040408@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A6A871C.6040408@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Fri, Jan 26, 2018 at 09:40:44AM +0800, Wei Wang wrote:
> On 01/25/2018 09:49 PM, Michael S. Tsirkin wrote:
> > On Thu, Jan 25, 2018 at 05:14:06PM +0800, Wei Wang wrote:
> > > +
> > > +static void report_free_page_func(struct work_struct *work)
> > > +{
> > > +	struct virtio_balloon *vb;
> > > +	int ret;
> > > +
> > > +	vb = container_of(work, struct virtio_balloon, report_free_page_work);
> > > +
> > > +	/* Start by sending the received cmd id to host with an outbuf */
> > > +	ret = send_cmd_id(vb, vb->cmd_id_received);
> > > +	if (unlikely(ret))
> > > +		goto err;
> > > +
> > > +	ret = walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> > > +	if (unlikely(ret < 0))
> > > +		goto err;
> > > +
> > > +	/* End by sending a stop id to host with an outbuf */
> > > +	ret = send_cmd_id(vb, VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID);
> > > +	if (likely(!ret))
> > > +		return;
> > > +err:
> > > +	dev_err(&vb->vdev->dev, "%s failure: free page vq is broken\n",
> > > +		__func__);
> > > +}
> > > +
> > So that's very simple, but it only works well if the whole
> > free list fits in the queue or host processes the queue faster
> > than the guest. What if it doesn't?
> 
> This is the case that the virtqueue gets full, and I think we've agreed that
> this is an optimization feature and losing some hints to report isn't
> important, right?
> 
> Actually, in the tests, there is no chance to see the ring is full. If we
> check the host patches that were shared before, the device side operation is
> quite simple, it just clears the related bits from the bitmap, and then
> continues to take entries from the virtqueue till the virtqueue gets empty.
> 
> 
> > If we had restartability you could just drop the lock
> > and wait for a vq interrupt to make more progress, which
> > would be better I think.
> > 
> 
> Restartability means that caller needs to record the state where it was when
> it stopped last time.

See my comment on the mm patch: if you rotate the previously reported
pages towards the end, then you mostly get restartability for free,
if only per zone.
The only thing remaining will be stopping at a page you already reported.

There aren't many zones so restartability wrt zones is kind of
trivial.

> The controversy is that the free list is not static
> once the lock is dropped, so everything is dynamically changing, including
> the state that was recorded. The method we are using is more prudent, IMHO.
> How about taking the fundamental solution, and seek to improve incrementally
> in the future?
> 
> 
> Best,
> Wei

I'd like to see kicks happen outside the spinlock. kick with a spinlock
taken looks like a scalability issue that won't be easy to
reproduce but hurt workloads at random unexpected times.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
