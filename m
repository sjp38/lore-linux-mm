Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B02756B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 21:41:38 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so44644846pac.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 18:41:38 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id p73si14727309pfj.140.2016.04.19.18.41.28
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 18:41:29 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Date: Wed, 20 Apr 2016 01:41:24 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0418339F@shsmsx102.ccr.corp.intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
 <20160419191111-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160419191111-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

> Cc: Rik van Riel; viro@zeniv.linux.org.uk; linux-kernel@vger.kernel.org;
> quintela@redhat.com; amit.shah@redhat.com; pbonzini@redhat.com;
> dgilbert@redhat.com; linux-mm@kvack.org; kvm@vger.kernel.org; qemu-
> devel@nongnu.org; agraf@suse.de; borntraeger@de.ibm.com
> Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build th=
e
> free page bitmap
>=20
> On Tue, Apr 19, 2016 at 03:02:09PM +0000, Li, Liang Z wrote:
> > > On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> > > > The free page bitmap will be sent to QEMU through virtio interface
> > > > and used for live migration optimization.
> > > > Drop the cache before building the free page bitmap can get more
> > > > free pages. Whether dropping the cache is decided by user.
> > > >
> > >
> > > How do you prevent the guest from using those recently-freed pages
> > > for something else, between when you build the bitmap and the live
> > > migration completes?
> >
> > Because the dirty page logging is enabled before building the bitmap,
> > there is no need to prevent the guest from using the recently-freed
> pages ...
> >
> > Liang
>=20
> Well one point of telling host that page is free is so that it can mark i=
t clean
> even if it was dirty previously.
> So I think you must pass the pages to guest under the lock.

Thanks! You mean save the free page bitmap in host pages?

> This will allow host optimizations such as marking these pages
> MADV_DONTNEED or MADV_FREE
> Otherwise it's all too tied up to a specific usecase - you aren't telling=
 host that
> a page is free, you are telling it that a page was free in the past.
>=20

Then we should prevent the guest from using those recently-freed pages,=20
before doing the MADV_DONTNEED or MADV_FREE, or the pages in the
free page bitmap may be not free any more. In which case we will do somethi=
ng
like this? Balloon?

Liang


> --
> MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
