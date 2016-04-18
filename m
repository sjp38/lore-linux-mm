Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id D02A26B025E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 06:06:22 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id zy2so229276003pac.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 03:06:22 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qg6si4641969pac.60.2016.04.18.03.06.21
        for <linux-mm@kvack.org>;
        Mon, 18 Apr 2016 03:06:22 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: post-copy is broken?
Date: Mon, 18 Apr 2016 10:06:17 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0418115C@shsmsx102.ccr.corp.intel.com>
References: <20160413114103.GB2270@work-vm> <20160413125053.GC2270@work-vm>
 <20160413205132.GG26364@redhat.com> <20160414123441.GF2252@work-vm>
 <20160414162230.GC9976@redhat.com>
 <20160415125236.GA3376@node.shutemov.name> <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name> <20160415163448.GJ2229@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E04181101@shsmsx102.ccr.corp.intel.com>
 <20160418095528.GD2222@work-vm>
In-Reply-To: <20160418095528.GD2222@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> * Li, Liang Z (liang.z.li@intel.com) wrote:
> > > > > > I've run it directly, setting relevant QTEST_QEMU_BINARY.
> > > > >
> > > > > Interesting; it's failing reliably for me - but only with a
> > > > > reasonably freshly booted machine (so that the pages get THPd).
> > > >
> > > > The same here. Freshly booted machine with 64GiB ram. I've checked
> > > > /proc/vmstat: huge pages were allocated
> > >
> > > Thanks for testing.
> > >
> > > Damn; this is confusing now.  I've got a RHEL7 box with 4.6.0-rc3 on
> > > where it works, and a fedora24 VM where it fails (the f24 VM is
> > > where I did the bisect so it works fine with the older kernel on the =
f24
> userspace in that VM).
> > >
> > > So lets see:
> > >    works: Kirill's (64GB machine)
> > >           Dave's RHEL7 host (24GB RAM, dual xeon, RHEL7 userspace
> > > and kernel
> > > config)
> > >    fails: Dave's f24 VM (4GB RAM, 4 vcpus VM on my laptop24
> > > userspace and kernel config)
> > >
> > > So it's any of userspace, kernel config, machine hardware or hmm.
> > >
> > > My f24 box has transparent_hugepage_madvise, where my rhel7 has
> > > transparent_hugepage_always (but still works if I flip it to madvise
> > > at run time).  I'll try and get the configs closer together.
> > >
> > > Liang Li: Can you run my test on your setup which fails the migrate
> > > and tell me what your userspace is?
> > >
> > > (If you've not built my test yet, you might find you need to add a :
> > >    tests/postcopy-test$(EXESUF): tests/postcopy-test.o
> > >
> > >   to the tests/Makefile)
> > >
> >
> > Hi Dave,
> >
> >   How to build and run you test? I didn't do that before.
>=20
> Apply the code in:
> http://lists.gnu.org/archive/html/qemu-devel/2016-04/msg02138.html
>=20
> fix the:
> +            if ( ((b + 1) % 255) =3D=3D last_byte && !hit_edge) {
> to:
> +            if ( ((b + 1) % 256) =3D=3D last_byte && !hit_edge) {
>=20
> to tests/Makefile
>    tests/postcopy-test$(EXESUF): tests/postcopy-test.o
>=20
> and do a:
>     make check
>=20
> in qemu.
> Then you can rerun the test with:
>     QTEST_QEMU_BINARY=3Dpath/to/qemu-system-x86_64 ./tests/postcopy-
> test
>=20
> if it works, reboot and check it still works from a fresh boot.
>=20
> Can you describe the system which your full test failed on? What distro o=
n
> the host? What type of host was it tested on?
>=20
> Dave
>=20


Thanks, Dave

The host is CenOS7, its original kernel is 3.10.0-327.el7.x86_64 (CentOS 7.=
1?),
The hardware platform is HSW-EP with 64GB RAM.


> >
> > Thanks!
> > Liang
> >
> > >
> > > Dave
> > > >
> > > > --
> > > >  Kirill A. Shutemov
> > > --
> > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
> --
> Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
