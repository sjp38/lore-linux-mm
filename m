Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 375946B007E
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 23:11:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so253048973pad.0
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 20:11:09 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r123si9309735pfr.154.2016.04.24.20.11.08
        for <linux-mm@kvack.org>;
        Sun, 24 Apr 2016 20:11:08 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Date: Mon, 25 Apr 2016 03:11:05 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04185611@shsmsx102.ccr.corp.intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
 <20160419191111-mutt-send-email-mst@redhat.com>
 <20160422094837.GC2239@work-vm>
 <20160422164936-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160422164936-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

> On Fri, Apr 22, 2016 at 10:48:38AM +0100, Dr. David Alan Gilbert wrote:
> > * Michael S. Tsirkin (mst@redhat.com) wrote:
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
> > > > bitmap, there is no need to prevent the guest from using the recent=
ly-
> freed pages ...
> > > >
> > > > Liang
> > >
> > > Well one point of telling host that page is free is so that it can
> > > mark it clean even if it was dirty previously.
> > > So I think you must pass the pages to guest under the lock.
> > > This will allow host optimizations such as marking these pages
> > > MADV_DONTNEED or MADV_FREE.
> > > Otherwise it's all too tied up to a specific usecase - you aren't
> > > telling host that a page is free, you are telling it that a page was
> > > free in the past.
> >
> > But doing it under lock sounds pretty expensive, especially given how
> > long the userspace side is going to take to work through the bitmap
> > and device what to do.
> >
> > Dave
>=20
> We need to make it as fast as we can since the VCPU is stopped on exit
> anyway. This just means e.g. sizing the bitmap reasonably - don't always =
try
> to fit all memory in a single bitmap.

Then we should pause the whole VM when using the bitmap, too expensive?

> Really, if the page can in fact be in use when you tell host it's free, t=
hen it's
> rather hard to explain what does it mean from host/guest interface point =
of
> view.
>=20

How about rename the interface to a more appropriate name other than 'free =
page' ?

Liang.
> It probably can be defined but the interface seems very complex.
>=20
> Let's start with a simple thing instead unless it can be shown that there=
's a
> performance problem.
>=20
>=20
> > >
> > > --
> > > MST
> > --
> > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
