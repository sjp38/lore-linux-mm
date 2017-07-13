Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4DC440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:59:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h47so25666235qta.12
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 10:59:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m34si5532336qtd.363.2017.07.13.10.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 10:59:26 -0700 (PDT)
Date: Thu, 13 Jul 2017 20:59:09 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 8/8] virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
Message-ID: <20170713205247-mutt-send-email-mst@kernel.org>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-9-git-send-email-wei.w.wang@intel.com>
 <20170713032207-mutt-send-email-mst@kernel.org>
 <59673365.7080408@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59673365.7080408@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Thu, Jul 13, 2017 at 04:46:29PM +0800, Wei Wang wrote:
> On 07/13/2017 08:22 AM, Michael S. Tsirkin wrote:
> > On Wed, Jul 12, 2017 at 08:40:21PM +0800, Wei Wang wrote:
> > > Add a new vq, cmdq, to handle requests between the device and driver.
> > > 
> > > This patch implements two commands sent from the device and handled in
> > > the driver.
> > > 1) VIRTIO_BALLOON_CMDQ_REPORT_STATS: this command is used to report
> > > the guest memory statistics to the host. The stats_vq mechanism is not
> > > used when the cmdq mechanism is enabled.
> > > 2) VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES: this command is used to
> > > report the guest unused pages to the host.
> > > 
> > > Since now we have a vq to handle multiple commands, we need to keep only
> > > one vq operation at a time. Here, we change the existing START_USE()
> > > and END_USE() to lock on each vq operation.
> > > 
> > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > > Signed-off-by: Liang Li <liang.z.li@intel.com>
> > > ---
> > >   drivers/virtio/virtio_balloon.c     | 245 ++++++++++++++++++++++++++++++++++--
> > >   drivers/virtio/virtio_ring.c        |  25 +++-
> > >   include/linux/virtio.h              |   2 +
> > >   include/uapi/linux/virtio_balloon.h |  10 ++
> > >   4 files changed, 265 insertions(+), 17 deletions(-)
> > > 
> > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > index aa4e7ec..ae91fbf 100644
> > > --- a/drivers/virtio/virtio_balloon.c
> > > +++ b/drivers/virtio/virtio_balloon.c
> > > @@ -54,11 +54,12 @@ static struct vfsmount *balloon_mnt;
> > >   struct virtio_balloon {
> > >   	struct virtio_device *vdev;
> > > -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> > > +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *cmd_vq;
> > >   	/* The balloon servicing is delegated to a freezable workqueue. */
> > >   	struct work_struct update_balloon_stats_work;
> > >   	struct work_struct update_balloon_size_work;
> > > +	struct work_struct cmdq_handle_work;
> > >   	/* Prevent updating balloon when it is being canceled. */
> > >   	spinlock_t stop_update_lock;
> > > @@ -90,6 +91,12 @@ struct virtio_balloon {
> > >   	/* Memory statistics */
> > >   	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
> > > +	/* Cmdq msg buffer for memory statistics */
> > > +	struct virtio_balloon_cmdq_hdr cmdq_stats_hdr;
> > > +
> > > +	/* Cmdq msg buffer for reporting ununsed pages */

typo above btw

> > > +	struct virtio_balloon_cmdq_hdr cmdq_unused_page_hdr;
> > > +
> > >   	/* To register callback in oom notifier call chain */
> > >   	struct notifier_block nb;
> > >   };
> > > @@ -485,25 +492,214 @@ static void update_balloon_size_func(struct work_struct *work)
> > >   		queue_work(system_freezable_wq, work);
> > >   }
> > > +static unsigned int cmdq_hdr_add(struct virtqueue *vq,
> > > +				 struct virtio_balloon_cmdq_hdr *hdr,
> > > +				 bool in)
> > > +{
> > > +	unsigned int id = VIRTQUEUE_DESC_ID_INIT;
> > > +	uint64_t hdr_pa = (uint64_t)virt_to_phys((void *)hdr);
> > > +
> > > +	virtqueue_add_chain_desc(vq, hdr_pa, sizeof(*hdr), &id, &id, in);
> > > +
> > > +	/* Deliver the hdr for the host to send commands. */
> > > +	if (in) {
> > > +		hdr->flags = 0;
> > > +		virtqueue_add_chain(vq, id, 0, NULL, hdr, NULL);
> > > +		virtqueue_kick(vq);
> > > +	}
> > > +
> > > +	return id;
> > > +}
> > > +
> > > +static void cmdq_add_chain_desc(struct virtio_balloon *vb,
> > > +				struct virtio_balloon_cmdq_hdr *hdr,
> > > +				uint64_t addr,
> > > +				uint32_t len,
> > > +				unsigned int *head_id,
> > > +				unsigned int *prev_id)
> > > +{
> > > +retry:
> > > +	if (*head_id == VIRTQUEUE_DESC_ID_INIT) {
> > > +		*head_id = cmdq_hdr_add(vb->cmd_vq, hdr, 0);
> > > +		*prev_id = *head_id;
> > > +	}
> > > +
> > > +	virtqueue_add_chain_desc(vb->cmd_vq, addr, len, head_id, prev_id, 0);
> > > +	if (*head_id == *prev_id) {
> > That's an ugly way to detect ring full.
> 
> It's actually not detecting ring full. I will call it tail_id, instead of
> prev_id.
> So, *head_id == *tail_id is the case that the first desc was just added by
>  virtqueue_add_chain_desc().
> 
> Best,
> Wei

Oh so it's adding header before each list. Ugh.

I don't think we should stay with this API. It's just too tricky to use.

If we have an API that fails when it can't add descriptors
(you can reserve space for the last descriptor)
the balloon knows whether it's the first descriptor in a chain
and can just use a boolean that tells it whether that is the case.


-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
