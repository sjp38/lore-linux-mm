Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F545280300
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 07:57:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m9so7248677pgd.2
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 04:57:19 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o9si127090pgn.825.2017.09.05.04.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 04:57:16 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v15 5/5] virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
Date: Tue, 5 Sep 2017 11:57:12 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7392D799C@shsmsx102.ccr.corp.intel.com>
References: <1503914913-28893-1-git-send-email-wei.w.wang@intel.com>
 <1503914913-28893-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1503914913-28893-6-git-send-email-wei.w.wang@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>
Cc: "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

Ping for comments if possible. Thanks.

On Monday, August 28, 2017 6:09 PM, Wang, Wei W wrote:
> [PATCH v15 5/5] virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
>=20
> Add a new vq, ctrl_vq, to handle commands between the host and guest.
> With this feature, we will be able to have the control plane and data pla=
ne
> separated. In other words, the control related data of each feature will =
be sent
> via the ctrl_vq cmds, meanwhile each feature may have its own data plane =
vq.
>=20
> Free page report is the the first new feature controlled via ctrl_vq, and=
 a new
> cmd class, VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE, is added.
> Currently, this feature has two cmds:
> VIRTIO_BALLOON_FREE_PAGE_F_START: This cmd is sent from host to guest to
> start the free page reporting work.
> VIRTIO_BALLOON_FREE_PAGE_F_STOP: This cmd is used bidirectionally. The
> guest would send the cmd to the host to indicate the reporting work is do=
ne.
> The host would send the cmd to the guest to actively request the stop of =
the
> reporting work.
>=20
> The free_page_vq is used to transmit the guest free page blocks to the ho=
st.
>=20
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 247 ++++++++++++++++++++++++++++++=
+++-
> --
>  include/uapi/linux/virtio_balloon.h |  15 +++
>  2 files changed, 242 insertions(+), 20 deletions(-)
>=20
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_ball=
oon.c index
> 8ecc1d4..1d384a4 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -55,7 +55,13 @@ static struct vfsmount *balloon_mnt;
>=20
>  struct virtio_balloon {
>  	struct virtio_device *vdev;
> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *ctrl_vq,
> +			 *free_page_vq;
> +
> +	/* Balloon's own wq for cpu-intensive work items */
> +	struct workqueue_struct *balloon_wq;
> +	/* The work items submitted to the balloon wq are listed here */
> +	struct work_struct report_free_page_work;
>=20
>  	/* The balloon servicing is delegated to a freezable workqueue. */
>  	struct work_struct update_balloon_stats_work; @@ -65,6 +71,9 @@
> struct virtio_balloon {
>  	spinlock_t stop_update_lock;
>  	bool stop_update;
>=20
> +	/* Stop reporting free pages */
> +	bool report_free_page_stop;
> +
>  	/* Waiting for host to ack the pages we released. */
>  	wait_queue_head_t acked;
>=20
> @@ -93,6 +102,11 @@ struct virtio_balloon {
>=20
>  	/* To register callback in oom notifier call chain */
>  	struct notifier_block nb;
> +
> +	/* Host to guest ctrlq cmd buf for free page report */
> +	struct virtio_balloon_ctrlq_cmd free_page_cmd_in;
> +	/* Guest to Host ctrlq cmd buf for free page report */
> +	struct virtio_balloon_ctrlq_cmd free_page_cmd_out;
>  };
>=20
>  static struct virtio_device_id id_table[] =3D { @@ -177,6 +191,26 @@ sta=
tic void
> send_balloon_page_sg(struct virtio_balloon *vb,
>  	}
>  }
>=20
> +static void send_free_page_sg(struct virtqueue *vq, void *addr,
> +uint32_t size) {
> +	unsigned int len;
> +	int err =3D -ENOSPC;
> +
> +	do {
> +		if (vq->num_free) {
> +			err =3D add_one_sg(vq, addr, size);
> +			/* Sanity check: this can't really happen */
> +			WARN_ON(err);
> +			if (!err)
> +				virtqueue_kick(vq);
> +		}
> +
> +		/* Release entries if there are */
> +		while (virtqueue_get_buf(vq, &len))
> +			;
> +	} while (err =3D=3D -ENOSPC && vq->num_free); }
> +
>  /*
>   * Send balloon pages in sgs to host. The balloon pages are recorded in =
the
>   * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SI=
ZE.
> @@ -525,42 +559,206 @@ static void update_balloon_size_func(struct
> work_struct *work)
>  		queue_work(system_freezable_wq, work);  }
>=20
> -static int init_vqs(struct virtio_balloon *vb)
> +static bool virtio_balloon_send_free_pages(void *opaque, unsigned long p=
fn,
> +					   unsigned long nr_pages)
> +{
> +	struct virtio_balloon *vb =3D (struct virtio_balloon *)opaque;
> +	void *addr =3D (void *)pfn_to_kaddr(pfn);
> +	uint32_t len =3D nr_pages << PAGE_SHIFT;
> +
> +	if (vb->report_free_page_stop)
> +		return 1;
> +
> +	send_free_page_sg(vb->free_page_vq, addr, len);
> +
> +	return 0;
> +}
> +
> +static void ctrlq_add_cmd(struct virtqueue *vq,
> +			  struct virtio_balloon_ctrlq_cmd *cmd,
> +			  bool inbuf)
>  {
> -	struct virtqueue *vqs[3];
> -	vq_callback_t *callbacks[] =3D { balloon_ack, balloon_ack, stats_reques=
t };
> -	static const char * const names[] =3D { "inflate", "deflate", "stats" }=
;
> -	int err, nvqs;
> +	struct scatterlist sg;
> +	int err;
> +
> +	sg_init_one(&sg, cmd, sizeof(struct virtio_balloon_ctrlq_cmd));
> +	if (inbuf)
> +		err =3D virtqueue_add_inbuf(vq, &sg, 1, cmd, GFP_KERNEL);
> +	else
> +		err =3D virtqueue_add_outbuf(vq, &sg, 1, cmd, GFP_KERNEL);
> +
> +	/* Sanity check: this can't really happen */
> +	WARN_ON(err);
> +}
>=20
> +static void ctrlq_send_cmd(struct virtio_balloon *vb,
> +			  struct virtio_balloon_ctrlq_cmd *cmd,
> +			  bool inbuf)
> +{
> +	struct virtqueue *vq =3D vb->ctrl_vq;
> +
> +	ctrlq_add_cmd(vq, cmd, inbuf);
> +	if (!inbuf) {
> +		/*
> +		 * All the input cmd buffers are replenished here.
> +		 * This is necessary because the input cmd buffers are lost
> +		 * after live migration. The device needs to rewind all of
> +		 * them from the ctrl_vq.
> +		 */
> +		ctrlq_add_cmd(vq, &vb->free_page_cmd_in, true);
> +	}
> +	virtqueue_kick(vq);
> +}
> +
> +static void report_free_page_end(struct virtio_balloon *vb) {
>  	/*
> -	 * We expect two virtqueues: inflate and deflate, and
> -	 * optionally stat.
> +	 * The host may have already requested to stop the reporting before we
> +	 * finish, so no need to notify the host in this case.
>  	 */
> -	nvqs =3D virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ?
> 3 : 2;
> -	err =3D virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
> +	if (vb->report_free_page_stop)
> +		return;
> +
> +	vb->free_page_cmd_out.class =3D
> VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE;
> +	vb->free_page_cmd_out.cmd =3D VIRTIO_BALLOON_FREE_PAGE_F_STOP;
> +	ctrlq_send_cmd(vb, &vb->free_page_cmd_out, false);
> +	vb->report_free_page_stop =3D true;
> +}
> +
> +static void report_free_page(struct work_struct *work) {
> +	struct virtio_balloon *vb;
> +
> +	vb =3D container_of(work, struct virtio_balloon, report_free_page_work)=
;
> +	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
> +	report_free_page_end(vb);
> +}
> +
> +static void ctrlq_handle(struct virtqueue *vq) {
> +	struct virtio_balloon *vb =3D vq->vdev->priv;
> +	struct virtio_balloon_ctrlq_cmd *cmd;
> +	unsigned int len;
> +
> +	cmd =3D (struct virtio_balloon_ctrlq_cmd *)virtqueue_get_buf(vq, &len);
> +
> +	if (unlikely(!cmd))
> +		return;
> +
> +	/* The outbuf is sent by the host for recycling, so just return. */
> +	if (cmd =3D=3D &vb->free_page_cmd_out)
> +		return;
> +
> +	switch (cmd->class) {
> +	case VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE:
> +		if (cmd->cmd =3D=3D VIRTIO_BALLOON_FREE_PAGE_F_STOP) {
> +			vb->report_free_page_stop =3D true;
> +		} else if (cmd->cmd =3D=3D VIRTIO_BALLOON_FREE_PAGE_F_START)
> {
> +			vb->report_free_page_stop =3D false;
> +			queue_work(vb->balloon_wq, &vb-
> >report_free_page_work);
> +		}
> +		vb->free_page_cmd_in.class =3D
> +
> 	VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE;
> +		ctrlq_send_cmd(vb, &vb->free_page_cmd_in, true);
> +	break;
> +	default:
> +		dev_warn(&vb->vdev->dev, "%s: cmd class not supported\n",
> +			 __func__);
> +	}
> +}
> +
> +static int init_vqs(struct virtio_balloon *vb) {
> +	struct virtqueue **vqs;
> +	vq_callback_t **callbacks;
> +	const char **names;
> +	struct scatterlist sg;
> +	int i, nvqs, err =3D -ENOMEM;
> +
> +	/* Inflateq and deflateq are used unconditionally */
> +	nvqs =3D 2;
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
> +		nvqs++;
> +	/* If ctrlq is enabled, the free page vq will also be created */
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CTRL_VQ))
> +		nvqs +=3D 2;
> +
> +	/* Allocate space for find_vqs parameters */
> +	vqs =3D kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
> +	if (!vqs)
> +		goto err_vq;
> +	callbacks =3D kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
> +	if (!callbacks)
> +		goto err_callback;
> +	names =3D kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
> +	if (!names)
> +		goto err_names;
> +
> +	callbacks[0] =3D balloon_ack;
> +	names[0] =3D "inflate";
> +	callbacks[1] =3D balloon_ack;
> +	names[1] =3D "deflate";
> +
> +	i =3D 2;
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> +		callbacks[i] =3D stats_request;
> +		names[i] =3D "stats";
> +		i++;
> +	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CTRL_VQ)) {
> +		callbacks[i] =3D ctrlq_handle;
> +		names[i++] =3D "ctrlq";
> +		callbacks[i] =3D NULL;
> +		names[i] =3D "free_page_vq";
> +	}
> +
> +	err =3D vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, name=
s,
> +					 NULL, NULL);
>  	if (err)
> -		return err;
> +		goto err_find;
>=20
>  	vb->inflate_vq =3D vqs[0];
>  	vb->deflate_vq =3D vqs[1];
> +	i =3D 2;
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> -		struct scatterlist sg;
> -		unsigned int num_stats;
> -		vb->stats_vq =3D vqs[2];
> -
> +		vb->stats_vq =3D vqs[i++];
>  		/*
>  		 * Prime this virtqueue with one buffer so the hypervisor can
>  		 * use it to signal us later (it can't be broken yet!).
>  		 */
> -		num_stats =3D update_balloon_stats(vb);
> -
> -		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
> +		sg_init_one(&sg, vb->stats, sizeof(vb->stats));
>  		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
> -		    < 0)
> -			BUG();
> +		    < 0) {
> +			dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
> +				 __func__);
> +			goto err_find;
> +		}
>  		virtqueue_kick(vb->stats_vq);
>  	}
> +
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CTRL_VQ)) {
> +		vb->ctrl_vq =3D vqs[i++];
> +		vb->free_page_vq =3D vqs[i];
> +		/* Prime the ctrlq with an inbuf for the host to send a cmd */
> +		vb->free_page_cmd_in.class =3D
> +
> 	VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE;
> +		ctrlq_send_cmd(vb, &vb->free_page_cmd_in, true);
> +	}
> +
> +	kfree(names);
> +	kfree(callbacks);
> +	kfree(vqs);
>  	return 0;
> +
> +err_find:
> +	kfree(names);
> +err_names:
> +	kfree(callbacks);
> +err_callback:
> +	kfree(vqs);
> +err_vq:
> +	return err;
>  }
>=20
>  #ifdef CONFIG_BALLOON_COMPACTION
> @@ -689,6 +887,13 @@ static int virtballoon_probe(struct virtio_device *v=
dev)
>  	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
>  		xb_init(&vb->page_xb);
>=20
> +	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_CTRL_VQ)) {
> +		vb->balloon_wq =3D alloc_workqueue("balloon-wq",
> +					WQ_FREEZABLE |
> WQ_CPU_INTENSIVE, 0);
> +		INIT_WORK(&vb->report_free_page_work, report_free_page);
> +		vb->report_free_page_stop =3D true;
> +	}
> +
>  	vb->nb.notifier_call =3D virtballoon_oom_notify;
>  	vb->nb.priority =3D VIRTBALLOON_OOM_NOTIFY_PRIORITY;
>  	err =3D register_oom_notifier(&vb->nb);
> @@ -753,6 +958,7 @@ static void virtballoon_remove(struct virtio_device
> *vdev)
>  	spin_unlock_irq(&vb->stop_update_lock);
>  	cancel_work_sync(&vb->update_balloon_size_work);
>  	cancel_work_sync(&vb->update_balloon_stats_work);
> +	cancel_work_sync(&vb->report_free_page_work);
>=20
>  	remove_common(vb);
>  #ifdef CONFIG_BALLOON_COMPACTION
> @@ -806,6 +1012,7 @@ static unsigned int features[] =3D {
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>  	VIRTIO_BALLOON_F_SG,
> +	VIRTIO_BALLOON_F_CTRL_VQ,
>  };
>=20
>  static struct virtio_driver virtio_balloon_driver =3D { diff --git
> a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon=
.h
> index 37780a7..dbf0616 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -35,6 +35,7 @@
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon
> on OOM */
>  #define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists
> */
> +#define VIRTIO_BALLOON_F_CTRL_VQ	4 /* Control Virtqueue */
>=20
>  /* Size of a PFN in the balloon interface. */  #define
> VIRTIO_BALLOON_PFN_SHIFT 12 @@ -83,4 +84,18 @@ struct
> virtio_balloon_stat {
>  	__virtio64 val;
>  } __attribute__((packed));
>=20
> +enum {
> +	VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE =3D 0,
> +	VIRTIO_BALLOON_CTRLQ_CLASS_MAX,
> +};
> +
> +struct virtio_balloon_ctrlq_cmd {
> +	__virtio32 class;
> +	__virtio32 cmd;
> +};
> +
> +/* Ctrlq commands related to VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE */
> +#define VIRTIO_BALLOON_FREE_PAGE_F_STOP		0
> +#define VIRTIO_BALLOON_FREE_PAGE_F_START	1
> +
>  #endif /* _LINUX_VIRTIO_BALLOON_H */
> --
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
