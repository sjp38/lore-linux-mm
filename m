Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3F16B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 12:38:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y77so13111053pfd.2
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 09:38:26 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u2si8121354pgr.277.2017.10.02.09.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 09:38:25 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v16 5/5] virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
Date: Mon, 2 Oct 2017 16:38:01 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73932025A@shsmsx102.ccr.corp.intel.com>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-6-git-send-email-wei.w.wang@intel.com>
 <20171001060305-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171001060305-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Michael S. Tsirkin'" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Sunday, October 1, 2017 11:19 AM, Michael S. Tsirkin wrote:
> On Sat, Sep 30, 2017 at 12:05:54PM +0800, Wei Wang wrote:
> > +static void ctrlq_send_cmd(struct virtio_balloon *vb,
> > +			  struct virtio_balloon_ctrlq_cmd *cmd,
> > +			  bool inbuf)
> > +{
> > +	struct virtqueue *vq =3D vb->ctrl_vq;
> > +
> > +	ctrlq_add_cmd(vq, cmd, inbuf);
> > +	if (!inbuf) {
> > +		/*
> > +		 * All the input cmd buffers are replenished here.
> > +		 * This is necessary because the input cmd buffers are lost
> > +		 * after live migration. The device needs to rewind all of
> > +		 * them from the ctrl_vq.
>=20
> Confused. Live migration somehow loses state? Why is that and why is it a=
 good
> idea? And how do you know this is migration even?
> Looks like all you know is you got free page end. Could be any reason for=
 this.


I think this would be something that the current live migration lacks - wha=
t the
device read from the vq is not transferred during live migration, an exampl=
e is the=20
stat_vq_elem:=20
Line 476 at https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-ballo=
on.c

For all the things that are added to the vq and need to be held by the devi=
ce
to use later need to consider the situation that live migration might happe=
n at any
time and they need to be re-taken from the vq by the device on the destinat=
ion
machine.

So, even without this live migration optimization feature, I think all the =
things that are=20
added to the vq for the device to hold, need a way for the device to rewind=
 back from
the vq - re-adding all the elements to the vq is a trick to keep a record o=
f all of them
on the vq so that the device side rewinding can work.=20

Please let me know if anything is missed or if you have other suggestions.


> > +static void ctrlq_handle(struct virtqueue *vq) {
> > +	struct virtio_balloon *vb =3D vq->vdev->priv;
> > +	struct virtio_balloon_ctrlq_cmd *msg;
> > +	unsigned int class, cmd, len;
> > +
> > +	msg =3D (struct virtio_balloon_ctrlq_cmd *)virtqueue_get_buf(vq, &len=
);
> > +	if (unlikely(!msg))
> > +		return;
> > +
> > +	/* The outbuf is sent by the host for recycling, so just return. */
> > +	if (msg =3D=3D &vb->free_page_cmd_out)
> > +		return;
> > +
> > +	class =3D virtio32_to_cpu(vb->vdev, msg->class);
> > +	cmd =3D  virtio32_to_cpu(vb->vdev, msg->cmd);
> > +
> > +	switch (class) {
> > +	case VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE:
> > +		if (cmd =3D=3D VIRTIO_BALLOON_FREE_PAGE_F_STOP) {
> > +			vb->report_free_page_stop =3D true;
> > +		} else if (cmd =3D=3D VIRTIO_BALLOON_FREE_PAGE_F_START) {
> > +			vb->report_free_page_stop =3D false;
> > +			queue_work(vb->balloon_wq, &vb-
> >report_free_page_work);
> > +		}
> > +		vb->free_page_cmd_in.class =3D
> > +
> 	VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE;
> > +		ctrlq_send_cmd(vb, &vb->free_page_cmd_in, true);
> > +	break;
> > +	default:
> > +		dev_warn(&vb->vdev->dev, "%s: cmd class not supported\n",
> > +			 __func__);
> > +	}
>=20
> Manipulating report_free_page_stop without any locks looks very suspiciou=
s.

> Also, what if we get two start commands? we should restart from beginning=
,
> should we not?
>=20


Yes, it will start to report free pages from the beginning.
walk_free_mem_block() doesn't maintain any internal status, so the invoking=
 of
it will always start from the beginning.


> > +/* Ctrlq commands related to VIRTIO_BALLOON_CTRLQ_CLASS_FREE_PAGE
> */
> > +#define VIRTIO_BALLOON_FREE_PAGE_F_STOP		0
> > +#define VIRTIO_BALLOON_FREE_PAGE_F_START	1
> > +
> >  #endif /* _LINUX_VIRTIO_BALLOON_H */
>=20
> The stop command does not appear to be thought through.
>=20
> Let's assume e.g. you started migration. You ask guest for free pages.
> Then you cancel it.  There are a bunch of pages in free vq and you are ge=
tting
> more.  You now want to start migration again. What to do?
>=20
> A bunch of vq flushing and waiting will maybe do the trick, but waiting o=
n guest
> is never a great idea.
>=20


I think the device can flush (pop out what's left in the vq and push them b=
ack) the
vq right after the Stop command is sent to the guest, rather than doing the=
 flush
when the 2nd initiation of live migration begins. The entries pushed back t=
o the vq
will be in the used ring, what would the device need to wait for?


> I previously suggested pushing the stop/start commands from guest to host=
 on
> the free page vq, and including an ID in host to guest and guest to host
> commands. This way ctrl vq is just for host to guest commands, and host
> matches commands and knows which command is a free page in response to.
>=20
> I still think it's a good idea but go ahead and propose something else th=
at works.
>=20

Thanks for the suggestion. Probably I haven't fully understood it. Please s=
ee the example
below:

1) host-to-guest ctrl_vq:
StartCMD, ID=3D1

2) guest-to-host free_page_vq:
free_page, ID=3D1
free_page, ID=3D1
free_page, ID=3D1
free_page, ID=3D1

3) host-to-guest ctrl_vq:
StopCMD, ID=3D1

4) initiate the 2nd try of live migration via host-to-guest ctrl_vq:
StartCMD, ID=3D2

5) the guest-to-host free_page_vq might look like this:
free_page, ID=3D1
free_page, ID=3D1
free_page, ID=3D2
free_page, ID=3D2

The device will need to drop (pop out the two entries and push them back)
the first 2 obsolete free pages which are sent by ID=3D1.

I haven't found the benefits above yet. The device will perform the same op=
erations
to get rid of the old free pages. If we drop the old free pages after the S=
topCMD (
ID may also not be needed in this case), the overhead won't be added to the=
 live
migration time.

Would you have any thought about this?


Best,
Wei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
