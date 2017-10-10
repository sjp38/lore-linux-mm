Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1AF56B025F
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:16:07 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k69so10406851ioi.13
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:16:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z5si2294410qtg.282.2017.10.10.08.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 08:16:06 -0700 (PDT)
Date: Tue, 10 Oct 2017 18:15:54 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v16 5/5] virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
Message-ID: <20171010180636-mutt-send-email-mst@kernel.org>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-6-git-send-email-wei.w.wang@intel.com>
 <20171001060305-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F73932025A@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73932025A@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Mon, Oct 02, 2017 at 04:38:01PM +0000, Wang, Wei W wrote:
> On Sunday, October 1, 2017 11:19 AM, Michael S. Tsirkin wrote:
> > On Sat, Sep 30, 2017 at 12:05:54PM +0800, Wei Wang wrote:
> > > +static void ctrlq_send_cmd(struct virtio_balloon *vb,
> > > +			  struct virtio_balloon_ctrlq_cmd *cmd,
> > > +			  bool inbuf)
> > > +{
> > > +	struct virtqueue *vq = vb->ctrl_vq;
> > > +
> > > +	ctrlq_add_cmd(vq, cmd, inbuf);
> > > +	if (!inbuf) {
> > > +		/*
> > > +		 * All the input cmd buffers are replenished here.
> > > +		 * This is necessary because the input cmd buffers are lost
> > > +		 * after live migration. The device needs to rewind all of
> > > +		 * them from the ctrl_vq.
> > 
> > Confused. Live migration somehow loses state? Why is that and why is it a good
> > idea? And how do you know this is migration even?
> > Looks like all you know is you got free page end. Could be any reason for this.
> 
> 
> I think this would be something that the current live migration lacks - what the
> device read from the vq is not transferred during live migration, an example is the 
> stat_vq_elem: 
> Line 476 at https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c

This does not touch guest memory though it just manipulates
internal state to make it easier to migrate.
It's transparent to guest as migration should be.

> For all the things that are added to the vq and need to be held by the device
> to use later need to consider the situation that live migration might happen at any
> time and they need to be re-taken from the vq by the device on the destination
> machine.
> 
> So, even without this live migration optimization feature, I think all the things that are 
> added to the vq for the device to hold, need a way for the device to rewind back from
> the vq - re-adding all the elements to the vq is a trick to keep a record of all of them
> on the vq so that the device side rewinding can work. 
> 
> Please let me know if anything is missed or if you have other suggestions.

IMO migration should pass enough data source to destination for
destination to continue where source left off without guest help.

> 
> > > +static void ctrlq_handle(struct virtqueue *vq) {
> > > +	struct virtio_balloon *vb = vq->vdev->priv;
> > > +	struct virtio_balloon_ctrlq_cmd *msg;
> > > +	unsigned int class, cmd, len;
> > > +
> > > +	msg = (struct virtio_balloon_ctrlq_cmd *)virtqueue_get_buf(vq, &len);
> > > +	if (unlikely(!msg))
> > > +		return;
> > > +
> > > +	/* The outbuf is sent by the host for recycling, so just return. */
> > > +	if (msg == &vb->free_page_cmd_out)
> > > +		return;
> > > +
> > > +	class = virtio32_to_cpu(vb->vdev, msg->class);
> > > +	cmd =  virtio32_to_cpu(vb->vdev, msg->cmd);
> > > +
> > > +	switch (class) {
> > > +	case VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE:
> > > +		if (cmd == VIRTIO_BALLOON_FREE_PAGE_F_STOP) {
> > > +			vb->report_free_page_stop = true;
> > > +		} else if (cmd == VIRTIO_BALLOON_FREE_PAGE_F_START) {
> > > +			vb->report_free_page_stop = false;
> > > +			queue_work(vb->balloon_wq, &vb-
> > >report_free_page_work);
> > > +		}
> > > +		vb->free_page_cmd_in.class =
> > > +
> > 	VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE;
> > > +		ctrlq_send_cmd(vb, &vb->free_page_cmd_in, true);
> > > +	break;
> > > +	default:
> > > +		dev_warn(&vb->vdev->dev, "%s: cmd class not supported\n",
> > > +			 __func__);
> > > +	}
> > 
> > Manipulating report_free_page_stop without any locks looks very suspicious.
> 
> > Also, what if we get two start commands? we should restart from beginning,
> > should we not?
> > 
> 
> 
> Yes, it will start to report free pages from the beginning.
> walk_free_mem_block() doesn't maintain any internal status, so the invoking of
> it will always start from the beginning.

Well yes but it will first complete the previous walk.

> 
> > > +/* Ctrlq commands related to VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE
> > */
> > > +#define VIRTIO_BALLOON_FREE_PAGE_F_STOP		0
> > > +#define VIRTIO_BALLOON_FREE_PAGE_F_START	1
> > > +
> > >  #endif /* _LINUX_VIRTIO_BALLOON_H */
> > 
> > The stop command does not appear to be thought through.
> > 
> > Let's assume e.g. you started migration. You ask guest for free pages.
> > Then you cancel it.  There are a bunch of pages in free vq and you are getting
> > more.  You now want to start migration again. What to do?
> > 
> > A bunch of vq flushing and waiting will maybe do the trick, but waiting on guest
> > is never a great idea.
> > 
> 
> 
> I think the device can flush (pop out what's left in the vq and push them back) the
> vq right after the Stop command is sent to the guest, rather than doing the flush
> when the 2nd initiation of live migration begins. The entries pushed back to the vq
> will be in the used ring, what would the device need to wait for?

You will be getting stale pages in available ring which were possibly
taken out of free list since memory is not tracked when migration is not
going on.



> > I previously suggested pushing the stop/start commands from guest to host on
> > the free page vq, and including an ID in host to guest and guest to host
> > commands. This way ctrl vq is just for host to guest commands, and host
> > matches commands and knows which command is a free page in response to.
> > 
> > I still think it's a good idea but go ahead and propose something else that works.
> > 
> 
> Thanks for the suggestion. Probably I haven't fully understood it. Please see the example
> below:
> 
> 1) host-to-guest ctrl_vq:
> StartCMD, ID=1
> 
> 2) guest-to-host free_page_vq:
> free_page, ID=1
> free_page, ID=1
> free_page, ID=1
> free_page, ID=1
> 
> 3) host-to-guest ctrl_vq:
> StopCMD, ID=1
> 
> 4) initiate the 2nd try of live migration via host-to-guest ctrl_vq:
> StartCMD, ID=2
> 
> 5) the guest-to-host free_page_vq might look like this:
> free_page, ID=1
> free_page, ID=1
> free_page, ID=2
> free_page, ID=2
> 
> The device will need to drop (pop out the two entries and push them back)
> the first 2 obsolete free pages which are sent by ID=1.

yes. But you do not have to attach id to each page.

It can be:

ID=1
free_page
free_page
ID=2
free_page
free_page



> I haven't found the benefits above yet. The device will perform the same operations
> to get rid of the old free pages. If we drop the old free pages after the StopCMD (
> ID may also not be needed in this case), the overhead won't be added to the live
> migration time.
> Would you have any thought about this?
> 
> 
> Best,
> Wei
> 

As these are separate vqs there is not clean way to know whether
free_page was queued before or after stop command.
Sending the ID helps detect where the free pages for a given start
command are.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
