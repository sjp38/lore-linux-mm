Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D89A6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 06:33:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so320910158pfe.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 03:33:18 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id n8si7231823pac.162.2016.04.18.03.33.17
        for <linux-mm@kvack.org>;
        Mon, 18 Apr 2016 03:33:17 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: post-copy is broken?
Date: Mon, 18 Apr 2016 10:33:14 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E041813A6@shsmsx102.ccr.corp.intel.com>
References: <20160413205132.GG26364@redhat.com>
 <20160414123441.GF2252@work-vm> <20160414162230.GC9976@redhat.com>
 <20160415125236.GA3376@node.shutemov.name> <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name> <20160415163448.GJ2229@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E04181101@shsmsx102.ccr.corp.intel.com>
 <20160418095528.GD2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0418115C@shsmsx102.ccr.corp.intel.com>
 <20160418101555.GE2222@work-vm>
In-Reply-To: <20160418101555.GE2222@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> > > > > > > Interesting; it's failing reliably for me - but only with a
> > > > > > > reasonably freshly booted machine (so that the pages get THPd=
).
> > > > > >
> > > > > > The same here. Freshly booted machine with 64GiB ram. I've
> > > > > > checked
> > > > > > /proc/vmstat: huge pages were allocated
> > > > >
> > > > > Thanks for testing.
> > > > >
> > > > > Damn; this is confusing now.  I've got a RHEL7 box with
> > > > > 4.6.0-rc3 on where it works, and a fedora24 VM where it fails
> > > > > (the f24 VM is where I did the bisect so it works fine with the
> > > > > older kernel on the f24
> > > userspace in that VM).
> > > > >
> > > > > So lets see:
> > > > >    works: Kirill's (64GB machine)
> > > > >           Dave's RHEL7 host (24GB RAM, dual xeon, RHEL7
> > > > > userspace and kernel
> > > > > config)
> > > > >    fails: Dave's f24 VM (4GB RAM, 4 vcpus VM on my laptop24
> > > > > userspace and kernel config)
> > > > >
> > > > > So it's any of userspace, kernel config, machine hardware or hmm.
> > > > >
> > > > > My f24 box has transparent_hugepage_madvise, where my rhel7 has
> > > > > transparent_hugepage_always (but still works if I flip it to
> > > > > madvise at run time).  I'll try and get the configs closer togeth=
er.
> > > > >
> > > > > Liang Li: Can you run my test on your setup which fails the
> > > > > migrate and tell me what your userspace is?
> > > > >
> > > > > (If you've not built my test yet, you might find you need to add =
a :
> > > > >    tests/postcopy-test$(EXESUF): tests/postcopy-test.o
> > > > >
> > > > >   to the tests/Makefile)
> > > > >
> > > >
> > > > Hi Dave,
> > > >
> > > >   How to build and run you test? I didn't do that before.
> > >
> > > Apply the code in:
> > > http://lists.gnu.org/archive/html/qemu-devel/2016-04/msg02138.html
> > >
> > > fix the:
> > > +            if ( ((b + 1) % 255) =3D=3D last_byte && !hit_edge) {
> > > to:
> > > +            if ( ((b + 1) % 256) =3D=3D last_byte && !hit_edge) {
> > >
> > > to tests/Makefile
> > >    tests/postcopy-test$(EXESUF): tests/postcopy-test.o
> > >
> > > and do a:
> > >     make check
> > >
> > > in qemu.
> > > Then you can rerun the test with:
> > >     QTEST_QEMU_BINARY=3Dpath/to/qemu-system-
> x86_64 ./tests/postcopy-
> > > test
> > >
> > > if it works, reboot and check it still works from a fresh boot.
> > >
> > > Can you describe the system which your full test failed on? What
> > > distro on the host? What type of host was it tested on?
> > >
> > > Dave
> > >
> >
> >
> > Thanks, Dave
> >
> > The host is CenOS7, its original kernel is 3.10.0-327.el7.x86_64
> > (CentOS 7.1?), The hardware platform is HSW-EP with 64GB RAM.
>=20
> OK, so your test fails on real hardware; my guess is that my test will wo=
rk on
> there.
> Can you try your test with THP disabled on the host:
>=20
> echo never > /sys/kernel/mm/transparent_hugepage/enabled
>=20

If the THP is disabled, no fails.
And your test was always passed, even when  real post-copy was failed.=20

In my env, the output of=20
'cat /sys/kernel/mm/transparent_hugepage/enabled'  is:

 [always] ...

Liang

> Dave
>=20
> >
> >
> > > >
> > > > Thanks!
> > > > Liang
> > > >
> > > > >
> > > > > Dave
> > > > > >
> > > > > > --
> > > > > >  Kirill A. Shutemov
> > > > > --
> > > > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
> > > --
> > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
> --
> Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
