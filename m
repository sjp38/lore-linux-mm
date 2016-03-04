Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E59876B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 20:35:05 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fi3so23022803pac.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 17:35:05 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id p9si1895475pfi.23.2016.03.03.17.35.04
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 17:35:04 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Fri, 4 Mar 2016 01:35:00 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E03770E06@SHSMSX101.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303135833.GA9100@rkaganb.sw.ru>
In-Reply-To: <20160303135833.GA9100@rkaganb.sw.ru>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Kagan <rkagan@virtuozzo.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> On Thu, Mar 03, 2016 at 06:44:24PM +0800, Liang Li wrote:
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
>=20
> Both cases look very artificial to me.  Normally you migrate VMs which ha=
ve
> started long ago and which can't have their services terminated before th=
e
> migration, so I wouldn't expect any useful amount of free pages obtained
> this way.
>=20

Yes, it's somewhat artificial, just to emphasize the effect.  And I think t=
hese two
cases are very easy to reproduce. Using the real workload and do the test
in production environment will be more convince.

We can predict that as long as the guest doesn't use out of its memory, thi=
s solution
may still take affect and shorten the total live migration time. (Off cause=
, we should
consider the time cost of the virtio communication.)

> OTOH I don't see why you can't just inflate the balloon before the migrat=
ion,
> and really optimize the amount of transferred data this way?
> With the recently proposed VIRTIO_BALLOON_S_AVAIL you can have a fairly
> good estimate of the optimal balloon size, and with the recently merged
> balloon deflation on OOM it's a safe thing to do without exposing the gue=
st
> workloads to OOM risks.
>=20
> Roman.

Thanks for your information.  The size of the free page bitmap is not very =
large, for a
guest with 8GB RAM, only 256KB  extra memory is required.
Comparing to this solution, inflate the balloon is more expensive. If the b=
alloon size
is not so optimal and guest request more memory during live migration, the =
guest's
performance will be impacted.

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
