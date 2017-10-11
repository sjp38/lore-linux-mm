Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 339516B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:49:25 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p1so4546156qtg.18
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 06:49:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k88si2105956qtd.521.2017.10.11.06.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 06:49:23 -0700 (PDT)
Date: Wed, 11 Oct 2017 16:49:16 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v16 5/5] virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
Message-ID: <20171011161912-mutt-send-email-mst@kernel.org>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-6-git-send-email-wei.w.wang@intel.com>
 <20171001060305-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F73932025A@shsmsx102.ccr.corp.intel.com>
 <20171010180636-mutt-send-email-mst@kernel.org>
 <59DDB428.4020208@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59DDB428.4020208@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Wed, Oct 11, 2017 at 02:03:20PM +0800, Wei Wang wrote:
> On 10/10/2017 11:15 PM, Michael S. Tsirkin wrote:
> > On Mon, Oct 02, 2017 at 04:38:01PM +0000, Wang, Wei W wrote:
> > > On Sunday, October 1, 2017 11:19 AM, Michael S. Tsirkin wrote:
> > > > On Sat, Sep 30, 2017 at 12:05:54PM +0800, Wei Wang wrote:
> > > > > +static void ctrlq_send_cmd(struct virtio_balloon *vb,
> > > > > +			  struct virtio_balloon_ctrlq_cmd *cmd,
> > > > > +			  bool inbuf)
> > > > > +{
> > > > > +	struct virtqueue *vq = vb->ctrl_vq;
> > > > > +
> > > > > +	ctrlq_add_cmd(vq, cmd, inbuf);
> > > > > +	if (!inbuf) {
> > > > > +		/*
> > > > > +		 * All the input cmd buffers are replenished here.
> > > > > +		 * This is necessary because the input cmd buffers are lost
> > > > > +		 * after live migration. The device needs to rewind all of
> > > > > +		 * them from the ctrl_vq.
> > > > Confused. Live migration somehow loses state? Why is that and why is it a good
> > > > idea? And how do you know this is migration even?
> > > > Looks like all you know is you got free page end. Could be any reason for this.
> > > 
> > > I think this would be something that the current live migration lacks - what the
> > > device read from the vq is not transferred during live migration, an example is the
> > > stat_vq_elem:
> > > Line 476 at https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c
> > This does not touch guest memory though it just manipulates
> > internal state to make it easier to migrate.
> > It's transparent to guest as migration should be.
> > 
> > > For all the things that are added to the vq and need to be held by the device
> > > to use later need to consider the situation that live migration might happen at any
> > > time and they need to be re-taken from the vq by the device on the destination
> > > machine.
> > > 
> > > So, even without this live migration optimization feature, I think all the things that are
> > > added to the vq for the device to hold, need a way for the device to rewind back from
> > > the vq - re-adding all the elements to the vq is a trick to keep a record of all of them
> > > on the vq so that the device side rewinding can work.
> > > 
> > > Please let me know if anything is missed or if you have other suggestions.
> > IMO migration should pass enough data source to destination for
> > destination to continue where source left off without guest help.
> > 
> 
> I'm afraid it would be difficult to pass the entire VirtQueueElement to the
> destination. I think
> that would also be the reason that stats_vq_elem chose to rewind from the
> guest vq, which re-do the
> virtqueue_pop() --> virtqueue_map_desc() steps (the QEMU virtual address to
> the guest physical
> address relationship may be changed on the destination).

Yes but note how that rewind does not involve modifying the ring.
It just rolls back some indices.


> 
> How about another direction which would be easier - using two 32-bit device
> specific configuration registers,
> Host2Guest and Guest2Host command registers, to replace the ctrlq for
> command exchange:
> 
> The flow can be as follows:
> 
> 1) Before Host sending a StartCMD, it flushes the free_page_vq in case any
> old free page hint is left there;

> 2) Host writes StartCMD to the Host2Guest register, and notifies the guest;
> 
> 3) Upon receiving a configuration notification, Guest reads the Host2Guest
> register, and detaches all the used buffers from free_page_vq;
> (then for each StartCMD, the free_page_vq will always have no obsolete free
> page hints, right? )
> 
> 4) Guest start report free pages:
>     4.1) Host may actively write StopCMD to the Host2Guest register before
> the guest finishes; or
>     4.2) Guest finishes reporting, write StopCMD  the Guest2HOST register,
> which traps to QEMU, to stop.
> 
> 
> Best,
> Wei

I am not sure it matters whether a VQ or the config are used to start/stop.
But I think flushing is very fragile. You will easily run into races
if one of the actors gets out of sync and keeps adding data.
I think adding an ID in the free vq stream is a more robust
approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
