Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D37706B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 20:41:21 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id td3so27394561pab.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 17:41:21 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id lm9si2074156pab.142.2016.03.09.17.41.20
        for <linux-mm@kvack.org>;
        Wed, 09 Mar 2016 17:41:20 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 0/4] A PV solution for live migration
 optimization
Date: Thu, 10 Mar 2016 01:41:16 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414A41D@shsmsx102.ccr.corp.intel.com>
References: <F2CBF3009FA73547804AE4C663CAB28E0377160A@SHSMSX101.ccr.corp.intel.com>
 <20160304102346.GB2479@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E0414516C@shsmsx102.ccr.corp.intel.com>
 <20160304163246-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E041452EA@shsmsx102.ccr.corp.intel.com>
 <20160305214748-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E04146308@shsmsx102.ccr.corp.intel.com>
 <20160307110852-mutt-send-email-mst@redhat.com>
 <20160309142851.GA9715@rkaganb.sw.ru>
 <F2CBF3009FA73547804AE4C663CAB28E041498BA@shsmsx102.ccr.corp.intel.com>
 <20160309172929-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160309172929-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Roman Kagan <rkagan@virtuozzo.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>, "riel@redhat.com" <riel@redhat.com>

> > > > > Yes, we really can teach qemu to skip these pages and it's not ha=
rd.
> > > > > The problem is the poor performance, this PV solution
> > > >
> > > > Balloon is always PV. And do not call patches solutions please.
> > > >
> > > > > is aimed to make it more
> > > > > efficient and reduce the performance impact on guest.
> > > >
> > > > We need to get a bit beyond this.  You are making multiple
> > > > changes, it seems to make sense to split it all up, and analyse
> > > > each change separately.
> > >
> > > Couldn't agree more.
> > >
> > > There are three stages in this optimization:
> > >
> > > 1) choosing which pages to skip
> > >
> > > 2) communicating them from guest to host
> > >
> > > 3) skip transferring uninteresting pages to the remote side on
> > > migration
> > >
> > > For (3) there seems to be a low-hanging fruit to amend
> > > migration/ram.c:iz_zero_range() to consult /proc/self/pagemap.  This
> > > would work for guest RAM that hasn't been touched yet or which has
> > > been ballooned out.
> > >
> > > For (1) I've been trying to make a point that skipping clean pages
> > > is much more likely to result in noticable benefit than free pages on=
ly.
> > >
> >
> > I am considering to drop the pagecache before getting the free pages.
> >
> > > As for (2), we do seem to have a problem with the existing balloon:
> > > according to your measurements it's very slow; besides, I guess it
> > > plays badly
> >
> > I didn't say communicating is slow. Even this is very slow, my
> > solution use bitmap instead of PFNs, there is fewer data traffic, so it=
's
> faster than the existing balloon which use PFNs.
>=20
> By how much?
>=20

Haven't measured yet.=20
To identify a page, 1 bit is needed if using bitmap, 4 Bytes(32bit) is need=
ed if using PFN,=20

For a guest with 8GB RAM,  the corresponding free page bitmap size is 256KB=
.
And the corresponding total PFNs size is 8192KB. Assuming the inflating siz=
e
is 7GB, the total PFNs size is 7168KB.

Maybe this is not the point.

Liang

> > > with transparent huge pages (as both the guest and the host work
> > > with one 4k page at a time).  This is a problem for other use cases
> > > of balloon (e.g. as a facility for resource management); tackling
> > > that appears a more natural application for optimization efforts.
> > >
> > > Thanks,
> > > Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
