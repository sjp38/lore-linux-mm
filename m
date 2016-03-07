Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 35E9F6B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 01:49:39 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id tt10so11338141pab.3
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 22:49:39 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qp8si987230pac.244.2016.03.06.22.49.38
        for <linux-mm@kvack.org>;
        Sun, 06 Mar 2016 22:49:38 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Mon, 7 Mar 2016 06:49:19 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160305214748-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Roman Kagan <rkagan@virtuozzo.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> > No. And it's exactly what I mean. The ballooned memory is still
> > processed during live migration without skipping. The live migration co=
de is
> in migration/ram.c.
>=20
> So if guest acknowledged VIRTIO_BALLOON_F_MUST_TELL_HOST, we can
> teach qemu to skip these pages.
> Want to write a patch to do this?
>=20

Yes, we really can teach qemu to skip these pages and it's not hard. =20
The problem is the poor performance, this PV solution is aimed to make it m=
ore
efficient and reduce the performance impact on guest.

> > >
> > > > > > The only advantage of ' inflating the balloon before live
> > > > > > migration' is simple,
> > > > > nothing more.
> > > > >
> > > > > That's a big advantage.  Another one is that it does something
> > > > > useful in real- world scenarios.
> > > > >
> > > >
> > > > I don't think the heave performance impaction is something useful
> > > > in real
> > > world scenarios.
> > > >
> > > > Liang
> > > > > Roman.
> > >
> > > So fix the performance then. You will have to try harder if you want
> > > to convince people that the performance is due to bad host/guest
> > > interface, and so we have to change *that*.
> > >
> >
> > Actually, the PV solution is irrelevant with the balloon mechanism, I
> > just use it to transfer information between host and guest.
> > I am not sure if I should implement a new virtio device, and I want to
> > get the answer from the community.
> > In this RFC patch, to make things simple, I choose to extend the
> > virtio-balloon and use the extended interface to transfer the request a=
nd
> free_page_bimap content.
> >
> > I am not intend to change the current virtio-balloon implementation.
> >
> > Liang
>=20
> And the answer would depend on the answer to my question above.
> Does balloon need an interface passing page bitmaps around?

Yes, I need a new interface.

> Does this speed up any operations?

No, a new interface will not speed up anything, but it is the easiest way t=
o solve the compatibility issue.

> OTOH what if you use the regular balloon interface with your patches?
>

The regular balloon interfaces have their specific function and I can't use=
 them in my patches.
If using these regular interface, I have to do a lot of changes to keep the=
 compatibility.=20

>=20
> > > --
> > > MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
