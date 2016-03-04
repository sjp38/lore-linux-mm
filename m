Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7796B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 21:38:46 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fl4so25902783pad.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 18:38:46 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id f88si2222722pfj.136.2016.03.03.18.38.45
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 18:38:45 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 2/4] virtio-balloon: Add a new feature to balloon
 device
Date: Fri, 4 Mar 2016 02:38:29 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E03770FC5@SHSMSX101.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
	<1457001868-15949-3-git-send-email-liang.z.li@intel.com>
 <20160303132334.5e4565df.cornelia.huck@de.ibm.com>
In-Reply-To: <20160303132334.5e4565df.cornelia.huck@de.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

> On Thu,  3 Mar 2016 18:44:26 +0800
> Liang Li <liang.z.li@intel.com> wrote:
>=20
> > Extend the virtio balloon device to support a new feature, this new
> > feature can help to get guest's free pages information, which can be
> > used for live migration optimzation.
>=20
> Do you have a spec for this, e.g. as a patch to the virtio spec?

Not yet.
>=20
> >
> > Signed-off-by: Liang Li <liang.z.li@intel.com>
> > ---
> >  balloon.c                                       | 30 ++++++++-
> >  hw/virtio/virtio-balloon.c                      | 81 +++++++++++++++++=
+++++++-
> >  include/hw/virtio/virtio-balloon.h              | 17 +++++-
> >  include/standard-headers/linux/virtio_balloon.h |  1 +
> >  include/sysemu/balloon.h                        | 10 ++-
> >  5 files changed, 134 insertions(+), 5 deletions(-)
>=20
> > +static int virtio_balloon_free_pages(void *opaque,
> > +                                     unsigned long *free_pages_bitmap,
> > +                                     unsigned long *free_pages_count)
> > +{
> > +    VirtIOBalloon *s =3D opaque;
> > +    VirtIODevice *vdev =3D VIRTIO_DEVICE(s);
> > +    VirtQueueElement *elem =3D s->free_pages_vq_elem;
> > +    int len;
> > +
> > +    if (!balloon_free_pages_supported(s)) {
> > +        return -1;
> > +    }
> > +
> > +    if (s->req_status =3D=3D NOT_STARTED) {
> > +        s->free_pages_bitmap =3D free_pages_bitmap;
> > +        s->req_status =3D STARTED;
> > +        s->mem_layout.low_mem =3D
> > + pc_get_lowmem(PC_MACHINE(current_machine));
>=20
> Please don't leak pc-specific information into generic code.

I have already notice that and just leave it here in this  initial RFC vers=
ion, =20
the hard part of this solution is how to handle different architecture ...

Thanks!

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
