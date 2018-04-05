Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4525B6B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 21:12:28 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a125so16035493qkd.4
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 18:12:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c203si2980210qke.85.2018.04.04.18.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 18:12:26 -0700 (PDT)
Date: Thu, 5 Apr 2018 04:12:20 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v30 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180405040900-mutt-send-email-mst@kernel.org>
References: <1522771805-78927-1-git-send-email-wei.w.wang@intel.com>
 <1522771805-78927-3-git-send-email-wei.w.wang@intel.com>
 <20180403214147-mutt-send-email-mst@kernel.org>
 <5AC43377.2070607@intel.com>
 <20180404155907-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7394A6E96@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F7394A6E96@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "huangzhichao@huawei.com" <huangzhichao@huawei.com>

On Thu, Apr 05, 2018 at 12:30:27AM +0000, Wang, Wei W wrote:
> On Wednesday, April 4, 2018 10:08 PM, Michael S. Tsirkin wrote:
> > On Wed, Apr 04, 2018 at 10:07:51AM +0800, Wei Wang wrote:
> > > On 04/04/2018 02:47 AM, Michael S. Tsirkin wrote:
> > > > On Wed, Apr 04, 2018 at 12:10:03AM +0800, Wei Wang wrote:
> > > > > +static int add_one_sg(struct virtqueue *vq, unsigned long pfn,
> > > > > +uint32_t len) {
> > > > > +	struct scatterlist sg;
> > > > > +	unsigned int unused;
> > > > > +
> > > > > +	sg_init_table(&sg, 1);
> > > > > +	sg_set_page(&sg, pfn_to_page(pfn), len, 0);
> > > > > +
> > > > > +	/* Detach all the used buffers from the vq */
> > > > > +	while (virtqueue_get_buf(vq, &unused))
> > > > > +		;
> > > > > +
> > > > > +	/*
> > > > > +	 * Since this is an optimization feature, losing a couple of free
> > > > > +	 * pages to report isn't important. We simply return without adding
> > > > > +	 * the page hint if the vq is full.
> > > > why not stop scanning of following pages though?
> > >
> > > Because continuing to send hints is a way to deliver the maximum
> > > possible hints to host. For example, host may have a delay in taking
> > > hints at some point, and then it resumes to take hints soon. If the
> > > driver does not stop when the vq is full, it will be able to put more
> > > hints to the vq once the vq has available entries to add.
> > 
> > What this appears to be is just lack of coordination between host and guest.
> > 
> > But meanwhile you are spending cycles walking the list uselessly.
> > Instead of trying nilly-willy, the standard thing to do is to wait for host to
> > consume an entry and proceed.
> > 
> > Coding it up might be tricky, so it's probably acceptable as is for now, but
> > please replace the justification about with a TODO entry that we should
> > synchronize with the host.
> 
> Thanks. I plan to add
> 
> TODO: The current implementation could be further improved by stopping the reporting when the vq is full and continuing the reporting when host notifies that there are available entries for the driver to add.

... that entries have been used.

> 
> > 
> > 
> > >
> > > >
> > > > > +	 * We are adding one entry each time, which essentially results in no
> > > > > +	 * memory allocation, so the GFP_KERNEL flag below can be ignored.
> > > > > +	 * Host works by polling the free page vq for hints after sending the
> > > > > +	 * starting cmd id, so the driver doesn't need to kick after filling
> > > > > +	 * the vq.
> > > > > +	 * Lastly, there is always one entry reserved for the cmd id to use.
> > > > > +	 */
> > > > > +	if (vq->num_free > 1)
> > > > > +		return virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> > > > > +
> > > > > +	return 0;
> > > > > +}
> > > > > +
> > > > > +static int virtio_balloon_send_free_pages(void *opaque, unsigned long
> > pfn,
> > > > > +					   unsigned long nr_pages)
> > > > > +{
> > > > > +	struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
> > > > > +	uint32_t len = nr_pages << PAGE_SHIFT;
> > > > > +
> > > > > +	/*
> > > > > +	 * If a stop id or a new cmd id was just received from host, stop
> > > > > +	 * the reporting, and return 1 to indicate an active stop.
> > > > > +	 */
> > > > > +	if (virtio32_to_cpu(vb->vdev, vb->cmd_id_use) != vb-
> > >cmd_id_received)
> > > > > +		return 1;
> > 
> > functions returning int should return 0 or -errno on failure, positive return
> > code should indicate progress.
> > 
> > If you want a boolean, use bool pls.
> 
> OK. I plan to change 1  to -EBUSY to indicate the case that host actively asks the driver to stop reporting (This makes the callback return value type consistent with walk_free_mem_block). 
> 

something like EINTR might be a better fit.

> 
> > 
> > 
> > > > > +
> > > > this access to cmd_id_use and cmd_id_received without locks bothers
> > > > me. Pls document why it's safe.
> > >
> > > OK. Probably we could add below to the above comments:
> > >
> > > cmd_id_use and cmd_id_received don't need to be accessed under locks
> > > because the reporting does not have to stop immediately before
> > > cmd_id_received is changed (i.e. when host requests to stop). That is,
> > > reporting more hints after host requests to stop isn't an issue for
> > > this optimization feature, because host will simply drop the stale
> > > hints next time when it needs a new reporting.
> > 
> > What about the other direction? Can this observe a stale value and exit
> > erroneously?
> 
> I'm afraid the driver couldn't be aware if the added hints are stale or not,


No - I mean that driver has code that compares two values
and stops reporting. Can one of the values be stale?

> because host and guest actions happen asynchronously. That is, host side iothread stops taking hints as soon as the migration thread asks to stop, it doesn't wait for any ACK from the driver to stop (as we discussed before, host couldn't always assume that the driver is in a responsive state).
> 
> Btw, we also don't need to worry about any memory left in the vq, since only addresses are added to the vq, there is no real memory allocations.
> 
> Best,
> Wei

When we support DMA API we will have to unmap things there.
