Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 889AF6B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 00:34:58 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 63so73064517pfe.3
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 21:34:58 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 195si26359362pfc.32.2016.03.06.21.34.57
        for <linux-mm@kvack.org>;
        Sun, 06 Mar 2016 21:34:57 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Mon, 7 Mar 2016 05:34:54 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414622D@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160303174615.GF2115@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E03770E33@SHSMSX101.ccr.corp.intel.com>
 <20160304081411.GD9100@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <56D9B6C2.3070708@redhat.com> <20160304185120.GB2588@work-vm>
In-Reply-To: <20160304185120.GB2588@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Roman Kagan <rkagan@virtuozzo.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

> > On 04/03/2016 15:26, Li, Liang Z wrote:
> > >> >
> > >> > The memory usage will keep increasing due to ever growing caches,
> > >> > etc, so you'll be left with very little free memory fairly soon.
> > >> >
> > > I don't think so.
> > >
> >
> > Roman is right.  For example, here I am looking at a 64 GB (physical)
> > machine which was booted about 30 minutes ago, and which is running
> > disk-heavy workloads (installing VMs).
> >
> > Since I have started writing this email (2 minutes?), the amount of
> > free memory has already gone down from 37 GB to 33 GB.  I expect that
> > by the time I have finished running the workload, in two hours, it
> > will not have any free memory.
>=20
> But what about a VM sitting idle, or that just has more RAM assigned to i=
t
> than is currently using.
>  I've got a host here that's been up for 46 days and has been doing some
> heavy VM debugging a few days ago, but today:
>=20
> # free -m
>               total        used        free      shared  buff/cache   ava=
ilable
> Mem:          96536        1146       44834         184       50555      =
 94735
>=20
> I very rarely use all it's RAM, so it's got a big chunk of free RAM, and =
yes it's
> got a big chunk of cache as well.
>=20
> Dave
>=20
> >
> > Paolo

I begin to realize Roman's opinions. The PV solution can't handle the cache=
 memory while inflating balloon could.
Inflating balloon so as to skipping the cache memory is no good for guest's=
 performance.

How much of the free memory in the guest depends on the workload in the VM =
 and the time VM has already run
before live migration. Even the memory usage will keep increasing due to ev=
er growing caches, but we don't know
when the live migration will happen, assuming there are no or very little f=
ree pages in the guest is not quite right.

The advantage of the pv solution is the smaller performance impact, compari=
ng with inflating the balloon.

Liang



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
