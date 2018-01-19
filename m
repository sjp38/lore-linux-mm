Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5375E6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:39:37 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id q195so1813522ioe.5
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:39:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z3si947923ite.166.2018.01.19.04.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 04:39:36 -0800 (PST)
Date: Fri, 19 Jan 2018 14:39:27 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
Message-ID: <20180119143517-mutt-send-email-mst@kernel.org>
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com>
 <1516165812-3995-3-git-send-email-wei.w.wang@intel.com>
 <20180117180337-mutt-send-email-mst@kernel.org>
 <5A616995.4050702@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A616995.4050702@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Fri, Jan 19, 2018 at 11:44:21AM +0800, Wei Wang wrote:
> On 01/18/2018 12:44 AM, Michael S. Tsirkin wrote:
> > On Wed, Jan 17, 2018 at 01:10:11PM +0800, Wei Wang wrote:
> > 
> 
> > 
> > > +{
> > > +	struct scatterlist sg;
> > > +	unsigned int unused;
> > > +	int err;
> > > +
> > > +	sg_init_one(&sg, addr, sizeof(uint32_t));
> > This passes a guest-endian value to host. This is a problem:
> > should always pass LE values.
> 
> I think the endianness is handled when virtqueue_add_outbuf():
> 
> desc[i].addr = cpu_to_virtio64(_vq->vdev, addr);
> 
> right?


No - that handles the address, not the value you pass in.


> > 
> > > +
> > > +	/*
> > > +	 * This handles the cornercase that the vq happens to be full when
> > > +	 * adding a cmd id. Rarely happen in practice.
> > > +	 */
> > > +	while (!vq->num_free)
> > > +		virtqueue_get_buf(vq, &unused);
> > I dislike this busy-waiting. It's a hint after all -
> > why not just retry later - hopefully after getting an
> > interrupt?
> > 
> > Alternatively, stop adding more entries when we have a single
> > ring entry left, making sure we have space for the command.
> 
> I think the second one looks good. Thanks.
> 
> > > +			queue_work(system_freezable_wq,
> > > +				   &vb->update_balloon_size_work);
> > > +		spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> > > +	}
> > > +
> > > +	virtio_cread(vb->vdev, struct virtio_balloon_config,
> > > +		     free_page_report_cmd_id, &cmd_id);
> > You want virtio_cread_feature, don't access the new field
> > if the feature has not been negotiated.
> 
> Right. We probably need to put all the following cmd id related things under
> the feature check,
> 
> How about
> 
> if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
>     virtio_cread(..);
>     if (cmd_id == VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID) {
>     ....
> }
> 
that's ok too.

> > 
> > 
> > > +	if (cmd_id == VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID) {
> > > +		WRITE_ONCE(vb->report_free_page, false);
> > > +	} else if (cmd_id != vb->start_cmd_id) {
> > > +		/*
> > > +		 * Host requests to start the reporting by sending a new cmd
> > > +		 * id.
> > > +		 */
> > > +		WRITE_ONCE(vb->report_free_page, true);
> > I don't know why we bother with WRITE_ONCE here.  The point of
> > report_free_page being used lockless is that that it's not a big deal if
> > it's wrong occasionally, right?
> 
> Actually the main reason is that "vb->report_free_page" is a value shared by
> two threads:
> Written by the config_change here, and read by the worker thread that
> reports the free pages.

Right but what's wrong if it's read or written twice and not once?

> Alternatively, we could let the two sides access to the shared variable with
> "volatile" pointers.
> 
> 
> > 
> > 
> > 
> > > +		vb->start_cmd_id = cmd_id;
> > > +		queue_work(vb->balloon_wq, &vb->report_free_page_work);
> > It seems that if a command was already queued (with a different id),
> > this will result in new command id being sent to host twice, which will
> > likely confuse the host.
> 
> I think that case won't happen, because
> - the host sends a cmd id to the guest via the config, while the guest acks
> back the received cmd id via the virtqueue;
> - the guest ack back a cmd id only when a new cmd id is received from the
> host, that is the above check:
> 
>     if (cmd_id != vb->start_cmd_id) { --> the driver only queues the
> reporting work only when a new cmd id is received
>                         /*
>                          * Host requests to start the reporting by sending a
>                          * new cmd id.
>                          */
>                         WRITE_ONCE(vb->report_free_page, true);
>                         vb->start_cmd_id = cmd_id;
>                         queue_work(vb->balloon_wq,
> &vb->report_free_page_work);
>     }
> 
> So the same cmd id wouldn't queue the reporting work twice.
> 

Like this:

		vb->start_cmd_id = cmd_id;
		queue_work(vb->balloon_wq, &vb->report_free_page_work);

command id changes

		vb->start_cmd_id = cmd_id;

work executes

		queue_work(vb->balloon_wq, &vb->report_free_page_work);

work executes again


> > 
> > 
> > 
> > > +	}
> > > +}
> > > +
> > >   static void update_balloon_size(struct virtio_balloon *vb)
> > >   {
> > >   	u32 actual = vb->num_pages;
> > > @@ -417,40 +513,113 @@ static void update_balloon_size_func(struct work_struct *work)
> > >   static int init_vqs(struct virtio_balloon *vb)
> > >   {
> > > -	struct virtqueue *vqs[3];
> > > -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
> > > -	static const char * const names[] = { "inflate", "deflate", "stats" };
> > > -	int err, nvqs;
> > > +	struct virtqueue **vqs;
> > > +	vq_callback_t **callbacks;
> > > +	const char **names;
> > > +	struct scatterlist sg;
> > > +	int i, nvqs, err = -ENOMEM;
> > > +
> > > +	/* Inflateq and deflateq are used unconditionally */
> > > +	nvqs = 2;
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
> > > +		nvqs++;
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
> > > +		nvqs++;
> > > +
> > > +	/* Allocate space for find_vqs parameters */
> > > +	vqs = kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
> > > +	if (!vqs)
> > > +		goto err_vq;
> > > +	callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
> > > +	if (!callbacks)
> > > +		goto err_callback;
> > > +	names = kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
> > > +	if (!names)
> > > +		goto err_names;
> > Why not just keep these 3 arrays on stack? they aren't large.
> 
> Sounds good. Here is the new implementation:
> 
> static int init_vqs(struct virtio_balloon *vb)
> {
>         struct virtqueue *vqs[4];
>         vq_callback_t *callbacks[4];
>         const char *names[4];
>         struct scatterlist sg;
>         int ret;
> 
> 
>         /*
>          * Inflateq and deflateq are used unconditionally. stats_vq and
>          * free_page_vq uses names[2] and names[3], respectively. The
> names[]
>          * will be NULL if the related feature is not enabled, which will
>          * cause no allocation for the corresponding virtqueue in find_vqs.
>          */
>         callbacks[0] = balloon_ack;
>         names[0] = "inflate";
>         callbacks[1] = balloon_ack;
>         names[1] = "deflate";
>         names[2] = NULL;
>         names[3] = NULL;
> 
>         if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>                 names[2] = "stats";
>                 callbacks[2] = stats_request;
>         }
>         if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
>                 names[3] = "free_page_vq";
>                 callbacks[3] = NULL;
>         }
> 
>         ret = vb->vdev->config->find_vqs(vb->vdev, 4, vqs, callbacks, names,
>                                          NULL, NULL);
>         if (ret)
>                 return ret;
> 
>         vb->inflate_vq = vqs[0];
>         vb->deflate_vq = vqs[1];
> 
>         if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>                 vb->stats_vq = vqs[2];
>                 /*
>                  * Prime this virtqueue with one buffer so the hypervisor
> can
>                  * use it to signal us later (it can't be broken yet!).
>                  */
>                 sg_init_one(&sg, vb->stats, sizeof(vb->stats));
>                 ret = virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb,
>                                            GFP_KERNEL);
>                 if (ret) {
>                         dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
>                                  __func__);
>                         return ret;
>                 }
>                 virtqueue_kick(vb->stats_vq);
>         }
> 
>         if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
>                 vb->free_page_vq = vqs[3];
> 
>         return 0;
> }
> 
> 
> Btw, the QEMU side doesn't have an option to disable STATS_VQ currently, we
> may need to add that later.
> 
> Best,
> Wei

why not

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
