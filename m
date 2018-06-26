Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50A866B0007
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 23:56:31 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id t138-v6so8816370qke.0
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 20:56:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 31-v6si599318qtb.264.2018.06.25.20.56.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 20:56:30 -0700 (PDT)
Date: Tue, 26 Jun 2018 06:56:25 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v34 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180626064338-mutt-send-email-mst@kernel.org>
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com>
 <1529928312-30500-3-git-send-email-wei.w.wang@intel.com>
 <20180626002822-mutt-send-email-mst@kernel.org>
 <5B31B71B.6080709@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B31B71B.6080709@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On Tue, Jun 26, 2018 at 11:46:35AM +0800, Wei Wang wrote:
> On 06/26/2018 09:37 AM, Michael S. Tsirkin wrote:
> > On Mon, Jun 25, 2018 at 08:05:10PM +0800, Wei Wang wrote:
> > 
> > > @@ -326,17 +353,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
> > >   	virtqueue_kick(vq);
> > >   }
> > > -static void virtballoon_changed(struct virtio_device *vdev)
> > > -{
> > > -	struct virtio_balloon *vb = vdev->priv;
> > > -	unsigned long flags;
> > > -
> > > -	spin_lock_irqsave(&vb->stop_update_lock, flags);
> > > -	if (!vb->stop_update)
> > > -		queue_work(system_freezable_wq, &vb->update_balloon_size_work);
> > > -	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> > > -}
> > > -
> > >   static inline s64 towards_target(struct virtio_balloon *vb)
> > >   {
> > >   	s64 target;
> > > @@ -353,6 +369,35 @@ static inline s64 towards_target(struct virtio_balloon *vb)
> > >   	return target - vb->num_pages;
> > >   }
> > > +static void virtballoon_changed(struct virtio_device *vdev)
> > > +{
> > > +	struct virtio_balloon *vb = vdev->priv;
> > > +	unsigned long flags;
> > > +	s64 diff = towards_target(vb);
> > > +
> > > +	if (diff) {
> > > +		spin_lock_irqsave(&vb->stop_update_lock, flags);
> > > +		if (!vb->stop_update)
> > > +			queue_work(system_freezable_wq,
> > > +				   &vb->update_balloon_size_work);
> > > +		spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> > > +	}
> > > +
> > > +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> > > +		virtio_cread(vdev, struct virtio_balloon_config,
> > > +			     free_page_report_cmd_id, &vb->cmd_id_received);
> > > +		if (vb->cmd_id_received !=
> > > +		    VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID &&
> > > +		    vb->cmd_id_received != vb->cmd_id_active) {
> > > +			spin_lock_irqsave(&vb->stop_update_lock, flags);
> > > +			if (!vb->stop_update)
> > > +				queue_work(vb->balloon_wq,
> > > +					   &vb->report_free_page_work);
> > > +			spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> > > +		}
> > > +	}
> > > +}
> > > +
> > >   static void update_balloon_size(struct virtio_balloon *vb)
> > >   {
> > >   	u32 actual = vb->num_pages;
> > > @@ -425,44 +470,253 @@ static void update_balloon_size_func(struct work_struct *work)
> > >   		queue_work(system_freezable_wq, work);
> > >   }
> > > +static void free_page_vq_cb(struct virtqueue *vq)
> > > +{
> > > +	unsigned int len;
> > > +	void *buf;
> > > +	struct virtio_balloon *vb = vq->vdev->priv;
> > > +
> > > +	while (1) {
> > > +		buf = virtqueue_get_buf(vq, &len);
> > > +
> > > +		if (!buf || buf == &vb->cmd_start || buf == &vb->cmd_stop)
> > > +			break;
> > If there's any buffer after this one we might never get another
> > callback.
> 
> I think every used buffer can get the callback, because host takes from the
> arrays one by one, and puts back each with a vq notify.

It's probabky racy even in this case. Besides, host is free to do it in
any way that's legal in spec.

> 
> 
> > > +		free_pages((unsigned long)buf, ARRAY_ALLOC_ORDER);
> > > +	}
> > > +}
> > > +
> > >   static int init_vqs(struct virtio_balloon *vb)
> > >   {
> > > -	struct virtqueue *vqs[3];
> > > -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
> > > -	static const char * const names[] = { "inflate", "deflate", "stats" };
> > > -	int err, nvqs;
> > > +	struct virtqueue *vqs[VIRTIO_BALLOON_VQ_MAX];
> > > +	vq_callback_t *callbacks[VIRTIO_BALLOON_VQ_MAX];
> > > +	const char *names[VIRTIO_BALLOON_VQ_MAX];
> > > +	struct scatterlist sg;
> > > +	int ret;
> > >   	/*
> > > -	 * We expect two virtqueues: inflate and deflate, and
> > > -	 * optionally stat.
> > > +	 * Inflateq and deflateq are used unconditionally. The names[]
> > > +	 * will be NULL if the related feature is not enabled, which will
> > > +	 * cause no allocation for the corresponding virtqueue in find_vqs.
> > >   	 */
> > > -	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> > > -	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
> > > -	if (err)
> > > -		return err;
> > > +	callbacks[VIRTIO_BALLOON_VQ_INFLATE] = balloon_ack;
> > > +	names[VIRTIO_BALLOON_VQ_INFLATE] = "inflate";
> > > +	callbacks[VIRTIO_BALLOON_VQ_DEFLATE] = balloon_ack;
> > > +	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> > > +	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> > > +	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > > -	vb->inflate_vq = vqs[0];
> > > -	vb->deflate_vq = vqs[1];
> > >   	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > > -		struct scatterlist sg;
> > > -		unsigned int num_stats;
> > > -		vb->stats_vq = vqs[2];
> > > +		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> > > +		callbacks[VIRTIO_BALLOON_VQ_STATS] = stats_request;
> > > +	}
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> > > +		names[VIRTIO_BALLOON_VQ_FREE_PAGE] = "free_page_vq";
> > > +		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = free_page_vq_cb;
> > > +	}
> > > +
> > > +	ret = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> > > +					 vqs, callbacks, names, NULL, NULL);
> > > +	if (ret)
> > > +		return ret;
> > > +
> > > +	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
> > > +	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
> > > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > > +		vb->stats_vq = vqs[VIRTIO_BALLOON_VQ_STATS];
> > >   		/*
> > >   		 * Prime this virtqueue with one buffer so the hypervisor can
> > >   		 * use it to signal us later (it can't be broken yet!).
> > >   		 */
> > > -		num_stats = update_balloon_stats(vb);
> > > -
> > > -		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
> > > -		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
> > > -		    < 0)
> > > -			BUG();
> > > +		sg_init_one(&sg, vb->stats, sizeof(vb->stats));
> > > +		ret = virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb,
> > > +					   GFP_KERNEL);
> > > +		if (ret) {
> > > +			dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
> > > +				 __func__);
> > > +			return ret;
> > > +		}
> > Why the change? Is it more likely to happen now?
> 
> Actually this part remains the same as the previous versions (e.g. v32). It
> is changed because we agreed that using BUG() isn't necessary here, and
> better to bail out nicely.

Why is this part of the hinting patch though? I'd rather have
a separate one.

> 
> 
> > 
> > +/*
> > + * virtio_balloon_send_hints - send arrays of hints to host
> > + * @vb: the virtio_balloon struct
> > + * @arrays: the arrays of hints
> > + * @array_num: the number of arrays give by the caller
> > + * @last_array_hints: the number of hints in the last array
> > + *
> > + * Send hints to host array by array. This begins by sending a start cmd,
> > + * which contains a cmd id received from host and the free page block size in
> > + * bytes of each hint. At the end, a stop cmd is sent to host to indicate the
> > + * end of this reporting. If host actively requests to stop the reporting, free
> > + * the arrays that have not been sent.
> > + */
> > +static void virtio_balloon_send_hints(struct virtio_balloon *vb,
> > +				      __le64 **arrays,
> > +				      uint32_t array_num,
> > +				      uint32_t last_array_hints)
> > +{
> > +	int err, i = 0;
> > +	struct scatterlist sg;
> > +	struct virtqueue *vq = vb->free_page_vq;
> > +
> > +	/* Start by sending the received cmd id to host with an outbuf. */
> > +	err = send_start_cmd_id(vb);
> > +	if (unlikely(err))
> > +		goto out_err;
> > +	/* Kick host to start taking entries from the vq. */
> > +	virtqueue_kick(vq);
> > +
> > +	for (i = 0; i < array_num; i++) {
> > +		/*
> > +		 * If a stop id or a new cmd id was just received from host,
> > +		 * stop the reporting, and free the remaining arrays that
> > +		 * haven't been sent to host.
> > +		 */
> > +		if (vb->cmd_id_received != vb->cmd_id_active)
> > +			goto out_free;
> > +
> > +		if (i + 1 == array_num)
> > +			sg_init_one(&sg, (void *)arrays[i],
> > +				    last_array_hints * sizeof(__le64));
> > +		else
> > +			sg_init_one(&sg, (void *)arrays[i], ARRAY_ALLOC_SIZE);
> > +		err = virtqueue_add_inbuf(vq, &sg, 1, (void *)arrays[i],
> > +					  GFP_KERNEL);
> > +		if (unlikely(err))
> > +			goto out_err;
> > +	}
> > +
> > +	/* End by sending a stop id to host with an outbuf. */
> > +	err = send_stop_cmd_id(vb);
> > +	if (unlikely(err))
> > +		goto out_err;
> > Don't we need to kick here?
> 
> I think not needed, because we have kicked host about starting the report,
> and the host side optimization won't exit unless receiving this stop sign or
> the migration thread asks to exit.

You can't assume that. Host might want to sleep.
If it doesn't then it will disable notifications and kick will be free.

> > 
> > > +	int i;
> > > +
> > > +	max_entries = max_free_page_blocks(ARRAY_ALLOC_ORDER);
> > > +	entries_per_page = PAGE_SIZE / sizeof(__le64);
> > > +	entries_per_array = entries_per_page * (1 << ARRAY_ALLOC_ORDER);
> > > +	max_array_num = max_entries / entries_per_array +
> > > +			!!(max_entries % entries_per_array);
> > > +	arrays = kmalloc_array(max_array_num, sizeof(__le64 *), GFP_KERNEL);
> > Instead of all this mess, how about get_free_pages here as well?
> 
> Sounds good, will replace kmalloc_array with __get_free_pages(),

Or alloc_pages, __ APIs are better avoided if possible.

> but still
> need the above calculation to get max_array_num.

Maybe alloc_pages?

> > 
> > Also why do we need GFP_KERNEL for this?
> 
> I guess it is better to use "__GFP_ATOMIC | __GFP_NOMEMALLOC", thanks.
> 
> > 
> > 
> > > +	if (!arrays)
> > > +		return NULL;
> > > +
> > > +	for (i = 0; i < max_array_num; i++) {
> > So we are getting a ton of memory here just to free it up a bit later.
> > Why doesn't get_from_free_page_list get the pages from free list for us?
> > We could also avoid the 1st allocation then - just build a list
> > of these.
> 
> That wouldn't be a good choice for us. If we check how the regular
> allocation works, there are many many things we need to consider when pages
> are allocated to users.
> For example, we need to take care of the nr_free
> counter, we need to check the watermark and perform the related actions.
> Also the folks working on arch_alloc_page to monitor page allocation
> activities would get a surprise..if page allocation is allowed to work in
> this way.
> 

mm/ code is well positioned to handle all this correctly.


> 
> 
> 
> > 
> > > +		arrays[i] =
> > > +		(__le64 *)__get_free_pages(__GFP_ATOMIC | __GFP_NOMEMALLOC,
> > > +					   ARRAY_ALLOC_ORDER);
> > Coding style says:
> > 
> > Descendants are always substantially shorter than the parent and
> > are placed substantially to the right.
> 
> Thanks, will rearrange it:
> 
> arrays[i] = (__le64 *)__get_free_pages(__GFP_ATOMIC |
> 				__GFP_NOMEMALLOC, ARRAY_ALLOC_ORDER);
> 
> 
> 
> > 
> > > +		if (!arrays[i]) {
> > Also if it does fail (small guest), shall we try with less arrays?
> 
> I think it's not needed. If the free list is empty, no matter it is a huge
> guest or a small guest, get_from_free_page_list() will load nothing even we
> pass a small array to it.
> 
> 
> Best,
> Wei

Yes but the reason it's empty is maybe because we used a ton of
memory for all of the arrays. Why allocate a top level array at all?
Can't we pass in a list?

-- 
MST
