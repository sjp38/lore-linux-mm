Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B64F76B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 07:11:43 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id u190so24910996pfb.3
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 04:11:43 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id hj1si2931580pac.235.2016.03.15.04.11.42
        for <linux-mm@kvack.org>;
        Tue, 15 Mar 2016 04:11:42 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Tue, 15 Mar 2016 11:11:38 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414E385@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
 <20160310075728.GB4678@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A860@shsmsx102.ccr.corp.intel.com>
 <20160310111844.GB2276@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0414B118@shsmsx102.ccr.corp.intel.com>
 <20160314170334.GK2234@work-vm>
 <20160315121613-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160315121613-mutt-send-email-mst@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Amit Shah <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mohan_parthasarathy@hpe.com" <mohan_parthasarathy@hpe.com>, "jitendra.kolhe@hpe.com" <jitendra.kolhe@hpe.com>, "simhan@hpe.com" <simhan@hpe.com>

> On Mon, Mar 14, 2016 at 05:03:34PM +0000, Dr. David Alan Gilbert wrote:
> > * Li, Liang Z (liang.z.li@intel.com) wrote:
> > > >
> > > > Hi,
> > > >   I'm just catching back up on this thread; so without reference
> > > > to any particular previous mail in the thread.
> > > >
> > > >   1) How many of the free pages do we tell the host about?
> > > >      Your main change is telling the host about all the
> > > >      free pages.
> > >
> > > Yes, all the guest's free pages.
> > >
> > > >      If we tell the host about all the free pages, then we might
> > > >      end up needing to allocate more pages and update the host
> > > >      with pages we now want to use; that would have to wait for the
> > > >      host to acknowledge that use of these pages, since if we don't
> > > >      wait for it then it might have skipped migrating a page we
> > > >      just started using (I don't understand how your series solves =
that).
> > > >      So the guest probably needs to keep some free pages - how many=
?
> > >
> > > Actually, there is no need to care about whether the free pages will =
be
> used by the host.
> > > We only care about some of the free pages we get reused by the guest,
> right?
> > >
> > > The dirty page logging can be used to solve this, starting the dirty
> > > page logging before getting the free pages informant from guest.
> > > Even some of the free pages are modified by the guest during the
> > > process of getting the free pages information, these modified pages w=
ill
> be traced by the dirty page logging mechanism. So in the following
> migration_bitmap_sync() function.
> > > The pages in the free pages bitmap, but latter was modified, will be
> > > reset to dirty. We won't omit any dirtied pages.
> > >
> > > So, guest doesn't need to keep any free pages.
> >
> > OK, yes, that works; so we do:
> >   * enable dirty logging
> >   * ask guest for free pages
> >   * initialise the migration bitmap as everything-free
> >   * then later we do the normal sync-dirty bitmap stuff and it all just=
 works.
> >
> > That's nice and simple.
>=20
> This works once, sure. But there's an issue is that you have to defer mig=
ration
> until you get the free page list, and this only works once. So you end up=
 with
> heuristics about how long to wait.
>=20
> Instead I propose:
>=20
> - mark all pages dirty as we do now.
>=20
> - at start of migration, start tracking dirty
>   pages in kvm, and tell guest to start tracking free pages
>=20
> we can now introduce any kind of delay, for example wait for ack from gue=
st,
> or do whatever else, or even just start migrating pages
>=20
> - repeatedly:
> 	- get list of free pages from guest
> 	- clear them in migration bitmap
> 	- get dirty list from kvm
>=20
> - at end of migration, stop tracking writes in kvm,
>   and tell guest to stop tracking free pages

I had thought of filtering out the free pages in each migration bitmap sync=
hronization.=20
The advantage is we can skip process as many free pages as possible. Not ju=
st once.
The disadvantage is that we should change the current memory management cod=
e to track the free pages,
instead of traversing the free page list to construct the free pages bitmap=
, to reduce the overhead to get the free pages bitmap.
I am not sure the if the Kernel people would like it.

If keeping the traversing mechanism, because of the overhead, maybe it's no=
t worth to filter out the free pages repeatedly.

Liang




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
