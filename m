Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 262A4830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 21:36:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t124so181343374pfb.1
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 18:36:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 16si3652903pfo.244.2016.04.21.18.36.20
        for <linux-mm@kvack.org>;
        Thu, 21 Apr 2016 18:36:20 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Date: Fri, 22 Apr 2016 01:36:15 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E041845BB@shsmsx102.ccr.corp.intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
 <20160419191111-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E0418339F@shsmsx102.ccr.corp.intel.com>
 <20160421134854.GA6858@redhat.com>
In-Reply-To: <20160421134854.GA6858@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

> On Wed, Apr 20, 2016 at 01:41:24AM +0000, Li, Liang Z wrote:
> > > Cc: Rik van Riel; viro@zeniv.linux.org.uk;
> > > linux-kernel@vger.kernel.org; quintela@redhat.com;
> > > amit.shah@redhat.com; pbonzini@redhat.com; dgilbert@redhat.com;
> > > linux-mm@kvack.org; kvm@vger.kernel.org; qemu- devel@nongnu.org;
> > > agraf@suse.de; borntraeger@de.ibm.com
> > > Subject: Re: [PATCH kernel 1/2] mm: add the related functions to
> > > build the free page bitmap
> > >
> > > On Tue, Apr 19, 2016 at 03:02:09PM +0000, Li, Liang Z wrote:
> > > > > On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> > > > > > The free page bitmap will be sent to QEMU through virtio
> > > > > > interface and used for live migration optimization.
> > > > > > Drop the cache before building the free page bitmap can get
> > > > > > more free pages. Whether dropping the cache is decided by user.
> > > > > >
> > > > >
> > > > > How do you prevent the guest from using those recently-freed
> > > > > pages for something else, between when you build the bitmap and
> > > > > the live migration completes?
> > > >
> > > > Because the dirty page logging is enabled before building the
> > > > bitmap, there is no need to prevent the guest from using the
> > > > recently-freed
> > > pages ...
> > > >
> > > > Liang
> > >
> > > Well one point of telling host that page is free is so that it can
> > > mark it clean even if it was dirty previously.
> > > So I think you must pass the pages to guest under the lock.
> >
> > Thanks! You mean save the free page bitmap in host pages?
>=20
> No, I literally mean don't release &zone->lock before you pass the list o=
f
> pages to host.
>=20
> > > This will allow host optimizations such as marking these pages
> > > MADV_DONTNEED or MADV_FREE Otherwise it's all too tied up to a
> > > specific usecase - you aren't telling host that a page is free, you
> > > are telling it that a page was free in the past.
> > >
> >
> > Then we should prevent the guest from using those recently-freed
> > pages, before doing the MADV_DONTNEED or MADV_FREE, or the pages in
> > the free page bitmap may be not free any more. In which case we will
> > do something like this? Balloon?
> >
> > Liang
> >
>=20
> Wouldn't keeping &zone->lock make sure these pages aren't used?
>=20
>=20

Yes, keep the &zone->lock can ensure this, and it can make sure we get a re=
al
free page bitmap, its more semantic correct.

But once we get a 'real' free page bitmap, the pages in the free page bitma=
p may=20
became no free anymore before using it for some purposes, is there any mech=
anism
to prevent this?
If there is no strong reason, it's better to take the lock as short as poss=
ible.
Could you elaborate some use cases which require a 'real' free page bitmap?=
=20

Liang

> > > --
> > > MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
