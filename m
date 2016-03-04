Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 54F616B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 20:52:59 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id x188so1892647pfb.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 17:52:59 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q5si1991149pap.42.2016.03.03.17.52.58
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 17:52:58 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Fri, 4 Mar 2016 01:52:53 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
In-Reply-To: <20160303174615.GF2115@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>

> Subject: Re: [RFC qemu 0/4] A PV solution for live migration optimization
>=20
> * Liang Li (liang.z.li@intel.com) wrote:
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
>=20
> Hi,
>   An interesting solution; I know a few different people have been lookin=
g at
> how to speed up ballooned VM migration.
>=20

Ooh, different solutions for the same purpose, and both based on the balloo=
n.

>   I wonder if it would be possible to avoid the kernel changes by parsing
> /proc/self/pagemap - if that can be used to detect unmapped/zero mapped
> pages in the guest ram, would it achieve the same result?
>=20

Only detect the unmapped/zero mapped pages is not enough. Consider the=20
situation like case 2, it can't achieve the same result.

> > This RFC version doesn't take the post-copy and RDMA into
> > consideration, maybe both of them can benefit from this PV solution by
> > with some extra modifications.
>=20
> For postcopy to be safe, you would still need to send a message to the
> destination telling it that there were zero pages, otherwise the destinat=
ion
> can't tell if it's supposed to request the page from the source or treat =
the
> page as zero.
>=20
> Dave

I will consider this later, thanks, Dave.

Liang

>=20
> >
> > Performance data
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > Test environment:
> >
> > CPU: Intel (R) Xeon(R) CPU ES-2699 v3 @ 2.30GHz Host RAM: 64GB
> > Host Linux Kernel:  4.2.0           Host OS: CentOS 7.1
> > Guest Linux Kernel:  4.5.rc6        Guest OS: CentOS 6.6
> > Network:  X540-AT2 with 10 Gigabit connection Guest RAM: 8GB
> >
> > Case 1: Idle guest just boots:
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >                     | original  |    pv
> > -------------------------------------------
> > total time(ms)      |    1894   |   421
> > --------------------------------------------
> > transferred ram(KB) |   398017  |  353242
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> >
> > Case 2: The guest has ever run some memory consuming workload, the
> > workload is terminated just before live migration.
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >                     | original  |    pv
> > -------------------------------------------
> > total time(ms)      |   7436    |   552
> > --------------------------------------------
> > transferred ram(KB) |  8146291  |  361375
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
