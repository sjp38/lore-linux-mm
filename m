Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8DF86B025E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 23:21:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id xm6so2917323pab.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 20:21:34 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id y22si1788083pfi.237.2016.04.25.20.21.33
        for <linux-mm@kvack.org>;
        Mon, 25 Apr 2016 20:21:33 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
Date: Tue, 26 Apr 2016 03:21:29 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E041860D6@shsmsx102.ccr.corp.intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
 <1461077659.3200.8.camel@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04182594@shsmsx102.ccr.corp.intel.com>
 <20160419191111-mutt-send-email-mst@redhat.com>
 <20160422094837.GC2239@work-vm>
 <20160422164936-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04185611@shsmsx102.ccr.corp.intel.com>
 <20160425104327.GA28009@redhat.com>
In-Reply-To: <20160425104327.GA28009@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Rik van Riel <riel@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "agraf@suse.de" <agraf@suse.de>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>

> On Mon, Apr 25, 2016 at 03:11:05AM +0000, Li, Liang Z wrote:
> > > On Fri, Apr 22, 2016 at 10:48:38AM +0100, Dr. David Alan Gilbert wrot=
e:
> > > > * Michael S. Tsirkin (mst@redhat.com) wrote:
> > > > > On Tue, Apr 19, 2016 at 03:02:09PM +0000, Li, Liang Z wrote:
> > > > > > > On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> > > > > > > > The free page bitmap will be sent to QEMU through virtio
> > > > > > > > interface and used for live migration optimization.
> > > > > > > > Drop the cache before building the free page bitmap can
> > > > > > > > get more free pages. Whether dropping the cache is decided =
by
> user.
> > > > > > > >
> > > > > > >
> > > > > > > How do you prevent the guest from using those recently-freed
> > > > > > > pages for something else, between when you build the bitmap
> > > > > > > and the live migration completes?
> > > > > >
> > > > > > Because the dirty page logging is enabled before building the
> > > > > > bitmap, there is no need to prevent the guest from using the
> > > > > > recently-
> > > freed pages ...
> > > > > >
> > > > > > Liang
> > > > >
> > > > > Well one point of telling host that page is free is so that it
> > > > > can mark it clean even if it was dirty previously.
> > > > > So I think you must pass the pages to guest under the lock.
> > > > > This will allow host optimizations such as marking these pages
> > > > > MADV_DONTNEED or MADV_FREE.
> > > > > Otherwise it's all too tied up to a specific usecase - you
> > > > > aren't telling host that a page is free, you are telling it that
> > > > > a page was free in the past.
> > > >
> > > > But doing it under lock sounds pretty expensive, especially given
> > > > how long the userspace side is going to take to work through the
> > > > bitmap and device what to do.
> > > >
> > > > Dave
> > >
> > > We need to make it as fast as we can since the VCPU is stopped on
> > > exit anyway. This just means e.g. sizing the bitmap reasonably -
> > > don't always try to fit all memory in a single bitmap.
> >
> > Then we should pause the whole VM when using the bitmap, too
> expensive?
>=20
> Why should we? I don't get it. Just make sure that at the point when you =
give
> a page to host, it's not in use. Host can clear the dirty bitmap, discard=
 the
> page, or whatever.
>=20
I did not know you mean to put the page into balloon.=20
There is no need to pause the VM if you do in that way.

> > > Really, if the page can in fact be in use when you tell host it's
> > > free, then it's rather hard to explain what does it mean from
> > > host/guest interface point of view.
> > >
> >
> > How about rename the interface to a more appropriate name other than
> 'free page' ?
> >
> > Liang.
>=20
> Maybe. But start with a description.
>=20
> The way I figured is passing a page to host meant putting it in the ballo=
on and
> immediately taking it out again. this allows things like discarding it si=
nce while
> page is in the balloon, it is owned by the balloon.
>=20
> This aligns well with how balloon works today.
>
 >=20
> If not that, then what can it actually mean?
>=20
> Without a lock, the only thing we can make it mean is that the page is in=
 the
> balloon at some point after the report is requested and before it's passe=
d to
> balloon.
>=20
> This happens to work if you only have one page in the balloon, but to mak=
e it
> asynchronous you really have to pass in a request ID, and then return it =
back
> with the bitmap. This way we can say "this page was free sometime after
> host sent request with this ID and before it received response with the s=
ame
> ID".
>=20
> And then, what host is supposed to do for pre-copy, copy the dirty bitmap
> before sending request, then on response we clear bit in this bitmap copy=
,
> then we set bits received from kvm (or another backend) afterwards.
>=20
> Of course just not retrieving the bitmap from kvm until we get a response
> also works (this is what your patches did) and then you do not need a cop=
y,
> but that's inelegant because this means guest can defer completing
> migration.

My RFC version patch did like this, but this version I changed the behavior=
,
now there is no waiting before starting live migration.

>=20
> So this works for migration but not for discarding pages.
>=20
> For this reason I think as a first step, we should focus on the simpler
> approach where we keep the lock.  Then add a feature bit that allows
> dropping the lock.
>=20
>=20

I got you this time,  but I still don't think put the free page in the ball=
oon is a good
idea for live migration optimization. There is no need to do extra things w=
hich increases
the guest's overhead, it's not worth the candle.

We can do something this to optimize the current virtio-balloon's performan=
ce.=20
but not for live migration, the efficiency should be the first thing we con=
sider
about, or we run the risk of blocking user from using this new feature.
=20
Liang
>=20
>=20
> > > It probably can be defined but the interface seems very complex.
> > >
> > > Let's start with a simple thing instead unless it can be shown that
> > > there's a performance problem.
> > >
> > >
> > > > >
> > > > > --
> > > > > MST
> > > > --
> > > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
