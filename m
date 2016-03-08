Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 229416B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:11:35 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id tt10so12485149pab.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:11:35 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id ok17si4714919pab.100.2016.03.08.05.11.33
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 05:11:34 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Tue, 8 Mar 2016 13:11:30 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414811E@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
In-Reply-To: <20160308111343.GM15443@grmbl.mre>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amit Shah <amit.shah@redhat.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

> Subject: Re: [RFC qemu 0/4] A PV solution for live migration optimization
>=20
> On (Thu) 03 Mar 2016 [18:44:24], Liang Li wrote:
> > The current QEMU live migration implementation mark the all the
> > guest's RAM pages as dirtied in the ram bulk stage, all these pages
> > will be processed and that takes quit a lot of CPU cycles.
> >
> > From guest's point of view, it doesn't care about the content in free
> > pages. We can make use of this fact and skip processing the free pages
> > in the ram bulk stage, it can save a lot CPU cycles and reduce the
> > network traffic significantly while speed up the live migration
> > process obviously.
> >
> > This patch set is the QEMU side implementation.
> >
> > The virtio-balloon is extended so that QEMU can get the free pages
> > information from the guest through virtio.
> >
> > After getting the free pages information (a bitmap), QEMU can use it
> > to filter out the guest's free pages in the ram bulk stage. This make
> > the live migration process much more efficient.
> >
> > This RFC version doesn't take the post-copy and RDMA into
> > consideration, maybe both of them can benefit from this PV solution by
> > with some extra modifications.
>=20
> I like the idea, just have to prove (review) and test it a lot to ensure =
we don't
> end up skipping pages that matter.
>=20
> However, there are a couple of points:
>=20
> In my opinion, the information that's exchanged between the guest and the
> host should be exchanged over a virtio-serial channel rather than virtio-
> balloon.  First, there's nothing related to the balloon here.
> It just happens to be memory info.  Second, I would never enable balloon =
in
> a guest that I want to be performance-sensitive.  So even if you add this=
 as
> part of balloon, you'll find no one is using this solution.
>=20
> Secondly, I suggest virtio-serial, because it's meant exactly to exchange=
 free-
> flowing information between a host and a guest, and you don't need to
> extend any part of the protocol for it (hence no changes necessary to the
> spec).  You can see how spice, vnc, etc., use virtio-serial to exchange d=
ata.
>=20
>=20
> 		Amit

I don't like to use the virtio-balloon too, and it's confusing.=20
It's grate if the virtio-serial can be used, I will take a look at it.=20

Thanks for your suggestion!

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
