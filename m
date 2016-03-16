Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D92436B0260
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 21:20:43 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id x3so51765199pfb.1
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 18:20:43 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 79si1371242pfm.61.2016.03.15.18.20.42
        for <linux-mm@kvack.org>;
        Tue, 15 Mar 2016 18:20:42 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Wed, 16 Mar 2016 01:20:39 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414F1BC@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
 <20160310075728.GB4678@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A860@shsmsx102.ccr.corp.intel.com>
 <20160310111844.GB2276@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0414B118@shsmsx102.ccr.corp.intel.com>
 <20160314170334.GK2234@work-vm>
 <20160315121613-mutt-send-email-mst@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E0414E385@shsmsx102.ccr.corp.intel.com>
 <20160315195515.GL11728@work-vm>
In-Reply-To: <20160315195515.GL11728@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Amit Shah <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mohan_parthasarathy@hpe.com" <mohan_parthasarathy@hpe.com>, "jitendra.kolhe@hpe.com" <jitendra.kolhe@hpe.com>, "simhan@hpe.com" <simhan@hpe.com>

> > > > > >   I'm just catching back up on this thread; so without
> > > > > > reference to any particular previous mail in the thread.
> > > > > >
> > > > > >   1) How many of the free pages do we tell the host about?
> > > > > >      Your main change is telling the host about all the
> > > > > >      free pages.
> > > > >
> > > > > Yes, all the guest's free pages.
> > > > >
> > > > > >      If we tell the host about all the free pages, then we migh=
t
> > > > > >      end up needing to allocate more pages and update the host
> > > > > >      with pages we now want to use; that would have to wait for=
 the
> > > > > >      host to acknowledge that use of these pages, since if we d=
on't
> > > > > >      wait for it then it might have skipped migrating a page we
> > > > > >      just started using (I don't understand how your series sol=
ves that).
> > > > > >      So the guest probably needs to keep some free pages - how
> many?
> > > > >
> > > > > Actually, there is no need to care about whether the free pages
> > > > > will be
> > > used by the host.
> > > > > We only care about some of the free pages we get reused by the
> > > > > guest,
> > > right?
> > > > >
> > > > > The dirty page logging can be used to solve this, starting the
> > > > > dirty page logging before getting the free pages informant from g=
uest.
> > > > > Even some of the free pages are modified by the guest during the
> > > > > process of getting the free pages information, these modified
> > > > > pages will
> > > be traced by the dirty page logging mechanism. So in the following
> > > migration_bitmap_sync() function.
> > > > > The pages in the free pages bitmap, but latter was modified,
> > > > > will be reset to dirty. We won't omit any dirtied pages.
> > > > >
> > > > > So, guest doesn't need to keep any free pages.
> > > >
> > > > OK, yes, that works; so we do:
> > > >   * enable dirty logging
> > > >   * ask guest for free pages
> > > >   * initialise the migration bitmap as everything-free
> > > >   * then later we do the normal sync-dirty bitmap stuff and it all =
just
> works.
> > > >
> > > > That's nice and simple.
> > >
> > > This works once, sure. But there's an issue is that you have to
> > > defer migration until you get the free page list, and this only
> > > works once. So you end up with heuristics about how long to wait.
> > >
> > > Instead I propose:
> > >
> > > - mark all pages dirty as we do now.
> > >
> > > - at start of migration, start tracking dirty
> > >   pages in kvm, and tell guest to start tracking free pages
> > >
> > > we can now introduce any kind of delay, for example wait for ack
> > > from guest, or do whatever else, or even just start migrating pages
> > >
> > > - repeatedly:
> > > 	- get list of free pages from guest
> > > 	- clear them in migration bitmap
> > > 	- get dirty list from kvm
> > >
> > > - at end of migration, stop tracking writes in kvm,
> > >   and tell guest to stop tracking free pages
> >
> > I had thought of filtering out the free pages in each migration bitmap
> synchronization.
> > The advantage is we can skip process as many free pages as possible. No=
t
> just once.
> > The disadvantage is that we should change the current memory
> > management code to track the free pages, instead of traversing the free
> page list to construct the free pages bitmap, to reduce the overhead to g=
et
> the free pages bitmap.
> > I am not sure the if the Kernel people would like it.
> >
> > If keeping the traversing mechanism, because of the overhead, maybe it'=
s
> not worth to filter out the free pages repeatedly.
>=20
> Well, Michael's idea of not waiting for the dirty bitmap to be filled doe=
s make
> that idea of constnatly using the free-bitmap better.
>=20

No wait is a good idea.
Actually, we could shorten the waiting time by pre allocating the free page=
s bit map
and update it when guest allocating/freeing pages. it requires to modify th=
e mm=20
related code. I don't know whether the kernel people like this.

> In that case, is it easier if something (guest/host?) allocates some memo=
ry in
> the guests physical RAM space and just points the host to it, rather than
> having an explicit 'send'.
>=20

Good idea too.

Liang
> Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
