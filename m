Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B554280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:27:54 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id e19so12053158otf.4
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 01:27:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k123si1654800oih.415.2018.01.17.01.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 01:27:53 -0800 (PST)
Date: Wed, 17 Jan 2018 04:27:51 -0500 (EST)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1239524301.1023371.1516181271621.JavaMail.zimbra@redhat.com>
In-Reply-To: <5A5F109B.7090200@intel.com>
References: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com> <1516165812-3995-3-git-send-email-wei.w.wang@intel.com> <1003745745.1007975.1516177271163.JavaMail.zimbra@redhat.com> <5A5F109B.7090200@intel.com>
Subject: Re: [PATCH v22 2/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang opensource <liliang.opensource@gmail.com>, yang zhang wz <yang.zhang.wz@gmail.com>, quan xu0 <quan.xu0@gmail.com>, nilal@redhat.com, riel@redhat.com


> On 01/17/2018 04:21 PM, Pankaj Gupta wrote:
> >> Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_VQ feature indicates the
> >> support of reporting hints of guest free pages to host via virtio-balloon.
> >>
> >> Host requests the guest to report free pages by sending a new cmd
> >> id to the guest via the free_page_report_cmd_id configuration register.
> >>
> >> When the guest starts to report, the first element added to the free page
> >> vq is the cmd id given by host. When the guest finishes the reporting
> >> of all the free pages, VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID is added
> >> to the vq to tell host that the reporting is done. Host may also requests
> >> the guest to stop the reporting in advance by sending the stop cmd id to
> >> the guest via the configuration register.
> >>
> >> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> >> Signed-off-by: Liang Li <liang.z.li@intel.com>
> >> Cc: Michael S. Tsirkin <mst@redhat.com>
> >> Cc: Michal Hocko <mhocko@kernel.org>
> >> ---
> >>   drivers/virtio/virtio_balloon.c     | 242
> >>   +++++++++++++++++++++++++++++++-----
> >>   include/uapi/linux/virtio_balloon.h |   4 +
> >>   2 files changed, 214 insertions(+), 32 deletions(-)
> >>
> >> diff --git a/drivers/virtio/virtio_balloon.c
> >> b/drivers/virtio/virtio_balloon.c
> >> index a1fb52c..b9561a5 100644
> >> --- a/drivers/virtio/virtio_balloon.c
> >> +++ b/drivers/virtio/virtio_balloon.c
> >> @@ -53,7 +53,12 @@ static struct vfsmount *balloon_mnt;
> >>   
> >>   struct virtio_balloon {
> >>           struct virtio_device *vdev;
> >> -        struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> >> +        struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
> >> +
> >> +        /* Balloon's own wq for cpu-intensive work items */
> >> +        struct workqueue_struct *balloon_wq;
> >> +        /* The free page reporting work item submitted to the balloon wq */
> >> +        struct work_struct report_free_page_work;
> >>   
> >>           /* The balloon servicing is delegated to a freezable workqueue. */
> >>           struct work_struct update_balloon_stats_work;
> >> @@ -63,6 +68,13 @@ struct virtio_balloon {
> >>           spinlock_t stop_update_lock;
> >>           bool stop_update;
> >>   
> >> +        /* Start to report free pages */
> >> +        bool report_free_page;
> >> +        /* Stores the cmd id given by host to start the free page reporting */
> >> +        uint32_t start_cmd_id;
> >> +        /* Stores STOP_ID as a sign to tell host that the reporting is done */
> >> +        uint32_t stop_cmd_id;
> >> +
> >>           /* Waiting for host to ack the pages we released. */
> >>           wait_queue_head_t acked;
> >>   
> >> @@ -281,6 +293,71 @@ static unsigned int update_balloon_stats(struct
> >> virtio_balloon *vb)
> >>           return idx;
> >>   }
> >>   
> >> +static void add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t
> >> len)
> >> +{
> >> +        struct scatterlist sg;
> >> +        unsigned int unused;
> >> +        int err;
> >> +
> >> +        sg_init_table(&sg, 1);
> >> +        sg_set_page(&sg, pfn_to_page(pfn), len, 0);
> >> +
> >> +        /* Detach all the used buffers from the vq */
> >> +        while (virtqueue_get_buf(vq, &unused))
> >> +                ;
> >> +
> >> +        /*
> >> +         * Since this is an optimization feature, losing a couple of free
> >> +         * pages to report isn't important. We simply resturn without adding
> >> +         * the page if the vq is full. We are adding one entry each time,
> >> +         * which essentially results in no memory allocation, so the
> >> +         * GFP_KERNEL flag below can be ignored.
> >> +         */
> >> +        if (vq->num_free) {
> >> +                err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
> >> +                /*
> >> +                 * This is expected to never fail, because there is always an
> >> +                 * entry available on the vq.
> >> +                 */
> >> +                BUG_ON(err);
> >> +        }
> >> +}
> >> +
> >> +static void batch_free_page_sg(struct virtqueue *vq,
> >> +                               unsigned long pfn,
> >> +                               uint32_t len)
> >> +{
> >> +        add_one_sg(vq, pfn, len);
> >> +
> >> +        /* Batch till the vq is full */
> >> +        if (!vq->num_free)
> >> +                virtqueue_kick(vq);
> >> +}
> >> +
> >> +static void send_cmd_id(struct virtqueue *vq, void *addr)
> >> +{
> >> +        struct scatterlist sg;
> >> +        unsigned int unused;
> >> +        int err;
> >> +
> >> +        sg_init_one(&sg, addr, sizeof(uint32_t));
> >> +
> >> +        /*
> >> +         * This handles the cornercase that the vq happens to be full when
> >> +         * adding a cmd id. Rarely happen in practice.
> >> +         */
> >> +        while (!vq->num_free)
> >> +                virtqueue_get_buf(vq, &unused);
> >> +
> >> +        err = virtqueue_add_outbuf(vq, &sg, 1, vq, GFP_KERNEL);
> >> +        /*
> >> +         * This is expected to never fail, because there is always an
> >> +         * entry available on the vq.
> >> +         */
> >> +        BUG_ON(err);
> >> +        virtqueue_kick(vq);
> >> +}
> >> +
> >>   /*
> >>    * While most virtqueues communicate guest-initiated requests to the
> >>    hypervisor,
> >>    * the stats queue operates in reverse.  The driver initializes the
> >>    virtqueue
> >> @@ -316,17 +393,6 @@ static void stats_handle_request(struct
> >> virtio_balloon
> >> *vb)
> >>           virtqueue_kick(vq);
> >>   }
> >>   
> >> -static void virtballoon_changed(struct virtio_device *vdev)
> >> -{
> >> -        struct virtio_balloon *vb = vdev->priv;
> >> -        unsigned long flags;
> >> -
> >> -        spin_lock_irqsave(&vb->stop_update_lock, flags);
> >> -        if (!vb->stop_update)
> >> -                queue_work(system_freezable_wq, &vb->update_balloon_size_work);
> >> -        spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> >> -}
> >> -
> >>   static inline s64 towards_target(struct virtio_balloon *vb)
> >>   {
> >>           s64 target;
> >> @@ -343,6 +409,36 @@ static inline s64 towards_target(struct
> >> virtio_balloon
> >> *vb)
> >>           return target - vb->num_pages;
> >>   }
> >>   
> >> +static void virtballoon_changed(struct virtio_device *vdev)
> >> +{
> >> +        struct virtio_balloon *vb = vdev->priv;
> >> +        unsigned long flags;
> >> +        __u32 cmd_id;
> >> +        s64 diff = towards_target(vb);
> >> +
> >> +        if (diff) {
> >> +                spin_lock_irqsave(&vb->stop_update_lock, flags);
> >> +                if (!vb->stop_update)
> >> +                        queue_work(system_freezable_wq,
> >> +                                   &vb->update_balloon_size_work);
> >> +                spin_unlock_irqrestore(&vb->stop_update_lock, flags);
> >> +        }
> >> +
> >> +        virtio_cread(vb->vdev, struct virtio_balloon_config,
> >> +                     free_page_report_cmd_id, &cmd_id);
> >> +        if (cmd_id == VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID) {
> >> +                WRITE_ONCE(vb->report_free_page, false);
> >> +        } else if (cmd_id != vb->start_cmd_id) {
> >> +                /*
> >> +                 * Host requests to start the reporting by sending a new cmd
> >> +                 * id.
> >> +                 */
> >> +                WRITE_ONCE(vb->report_free_page, true);
> >> +                vb->start_cmd_id = cmd_id;
> >> +                queue_work(vb->balloon_wq, &vb->report_free_page_work);
> >> +        }
> >> +}
> >> +
> >>   static void update_balloon_size(struct virtio_balloon *vb)
> >>   {
> >>           u32 actual = vb->num_pages;
> >> @@ -417,40 +513,113 @@ static void update_balloon_size_func(struct
> >> work_struct *work)
> >>   
> >>   static int init_vqs(struct virtio_balloon *vb)
> >>   {
> >> -        struct virtqueue *vqs[3];
> >> -        vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request
> >> };
> >> -        static const char * const names[] = { "inflate", "deflate", "stats" };
> >> -        int err, nvqs;
> >> +        struct virtqueue **vqs;
> >> +        vq_callback_t **callbacks;
> >> +        const char **names;
> >> +        struct scatterlist sg;
> >> +        int i, nvqs, err = -ENOMEM;
> >> +
> >> +        /* Inflateq and deflateq are used unconditionally */
> >> +        nvqs = 2;
> >> +        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
> >> +                nvqs++;
> >> +        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
> >> +                nvqs++;
> >> +
> >> +        /* Allocate space for find_vqs parameters */
> >> +        vqs = kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
> >> +        if (!vqs)
> >> +                goto err_vq;
> >> +        callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
> >> +        if (!callbacks)
> >> +                goto err_callback;
> >> +        names = kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
> >> +        if (!names)
> >> +                goto err_names;
> >> +
> >> +        callbacks[0] = balloon_ack;
> >> +        names[0] = "inflate";
> >> +        callbacks[1] = balloon_ack;
> >> +        names[1] = "deflate";
> >> +
> >> +        i = 2;
> >> +        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> >> +                callbacks[i] = stats_request;
> >> +                names[i] = "stats";
> >> +                i++;
> >> +        }
> >>   
> >> -        /*
> >> -         * We expect two virtqueues: inflate and deflate, and
> >> -         * optionally stat.
> >> -         */
> >> -        nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> >> -        err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
> >> +        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ)) {
> >> +                callbacks[i] = NULL;
> >> +                names[i] = "free_page_vq";
> >> +        }
> >> +
> >> +        err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names,
> >> +                                         NULL, NULL);
> >>           if (err)
> >> -                return err;
> >> +                goto err_find;
> >>   
> >>           vb->inflate_vq = vqs[0];
> >>           vb->deflate_vq = vqs[1];
> >> +        i = 2;
> >>           if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> >> -                struct scatterlist sg;
> >> -                unsigned int num_stats;
> >> -                vb->stats_vq = vqs[2];
> >> -
> >> +                vb->stats_vq = vqs[i++];
> >>                   /*
> >>                    * Prime this virtqueue with one buffer so the hypervisor can
> >>                    * use it to signal us later (it can't be broken yet!).
> >>                    */
> >> -                num_stats = update_balloon_stats(vb);
> >> -
> >> -                sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
> >> +                sg_init_one(&sg, vb->stats, sizeof(vb->stats));
> >>                   if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
> >> -                    < 0)
> >> -                        BUG();
> >> +                    < 0) {
> >> +                        dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
> >> +                                 __func__);
> >> +                        goto err_find;
> >> +                }
> >>                   virtqueue_kick(vb->stats_vq);
> >>           }
> >> +
> >> +        if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_VQ))
> >> +                vb->free_page_vq = vqs[i];
> >> +
> >> +        kfree(names);
> >> +        kfree(callbacks);
> >> +        kfree(vqs);
> >>           return 0;
> >   
> > We can assign err=0 and remove above duplicate code?
> >   
> 
> Where do you want to assign err=0? Could you show it using code?

o.k  you have initialize "err = -ENOMEM;"

Remove these four lines.
 
 -        kfree(names);
 -        kfree(callbacks);
 -        kfree(vqs);
 -        return 0;

 +        err = 0;              // if executed without any error

Below code is already there, so for error, err is already 'ENOMEM'
and a jump to any label. 

 +
 +err_find:
 +        kfree(names);
 +err_names:
 +        kfree(callbacks);
 +err_callback:
 +        kfree(vqs);
> +err_vq:
> +       return err;
> +}


Thanks,
Pankaj

> 
> 
> Best,
> Wei
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
