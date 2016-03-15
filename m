Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0A26B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:31:57 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 124so8905214pfg.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 20:31:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id n69si7106957pfa.4.2016.03.14.20.31.56
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 20:31:56 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Tue, 15 Mar 2016 03:31:36 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E0414D67B@shsmsx102.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <20160308111343.GM15443@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A7E3@shsmsx102.ccr.corp.intel.com>
 <20160310075728.GB4678@grmbl.mre>
 <F2CBF3009FA73547804AE4C663CAB28E0414A860@shsmsx102.ccr.corp.intel.com>
 <20160310111844.GB2276@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0414B118@shsmsx102.ccr.corp.intel.com>
 <20160314170334.GK2234@work-vm>
In-Reply-To: <20160314170334.GK2234@work-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Amit Shah <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mohan_parthasarathy@hpe.com" <mohan_parthasarathy@hpe.com>, "jitendra.kolhe@hpe.com" <jitendra.kolhe@hpe.com>, "simhan@hpe.com" <simhan@hpe.com>

> > > Hi,
> > >   I'm just catching back up on this thread; so without reference to
> > > any particular previous mail in the thread.
> > >
> > >   1) How many of the free pages do we tell the host about?
> > >      Your main change is telling the host about all the
> > >      free pages.
> >
> > Yes, all the guest's free pages.
> >
> > >      If we tell the host about all the free pages, then we might
> > >      end up needing to allocate more pages and update the host
> > >      with pages we now want to use; that would have to wait for the
> > >      host to acknowledge that use of these pages, since if we don't
> > >      wait for it then it might have skipped migrating a page we
> > >      just started using (I don't understand how your series solves th=
at).
> > >      So the guest probably needs to keep some free pages - how many?
> >
> > Actually, there is no need to care about whether the free pages will be
> used by the host.
> > We only care about some of the free pages we get reused by the guest,
> right?
> >
> > The dirty page logging can be used to solve this, starting the dirty
> > page logging before getting the free pages informant from guest. Even
> > some of the free pages are modified by the guest during the process of
> > getting the free pages information, these modified pages will be traced=
 by
> the dirty page logging mechanism. So in the following
> migration_bitmap_sync() function.
> > The pages in the free pages bitmap, but latter was modified, will be
> > reset to dirty. We won't omit any dirtied pages.
> >
> > So, guest doesn't need to keep any free pages.
>=20
> OK, yes, that works; so we do:
>   * enable dirty logging
>   * ask guest for free pages
>   * initialise the migration bitmap as everything-free
>   * then later we do the normal sync-dirty bitmap stuff and it all just w=
orks.
>=20
> That's nice and simple.
>=20
> > >   2) Clearing out caches
> > >      Does it make sense to clean caches?  They're apparently useful d=
ata
> > >      so if we clean them it's likely to slow the guest down; I guess
> > >      they're also likely to be fairly static data - so at least fairl=
y
> > >      easy to migrate.
> > >      The answer here partially depends on what you want from your
> migration;
> > >      if you're after the fastest possible migration time it might mak=
e
> > >      sense to clean the caches and avoid migrating them; but that mig=
ht
> > >      be at the cost of more disruption to the guest - there's a trade=
 off
> > >      somewhere and it's not clear to me how you set that depending on
> your
> > >      guest/network/reqirements.
> > >
> >
> > Yes, clean the caches is an option.  Let the users decide using it or n=
ot.
> >
> > >   3) Why is ballooning slow?
> > >      You've got a figure of 5s to balloon on an 8GB VM - but an
> > >      8GB VM isn't huge; so I worry about how long it would take
> > >      on a big VM.   We need to understand why it's slow
> > >        * is it due to the guest shuffling pages around?
> > >        * is it due to the virtio-balloon protocol sending one page
> > >          at a time?
> > >          + Do balloon pages normally clump in physical memory
> > >             - i.e. would a 'large balloon' message help
> > >             - or do we need a bitmap because it tends not to clump?
> > >
> >
> > I didn't do a comprehensive test. But I found most of the time
> > spending on allocating the pages and sending the PFNs to guest, I
> > don't know that's the most time consuming operation, allocating the pag=
es
> or sending the PFNs.
>=20
> It might be a good idea to analyse it a bit more to convince people where=
 the
> problem is.
>=20

Yes, I will try to measure the time spending on different parts.

> > >        * is it due to the madvise on the host?
> > >          If we were using the normal balloon messages, then we
> > >          could, during migration, just route those to the migration
> > >          code rather than bothering with the madvise.
> > >          If they're clumping together we could just turn that into
> > >          one big madvise; if they're not then would we benefit from
> > >          a call that lets us madvise lots of areas?
> > >
> >
> > My test showed madvise() is not the main reason for the long time,
> > only taken 10% of the total  inflating balloon operation time.
> > Big madvise can more or less improve the performance.
>=20
> OK; 10% of the total is still pretty big even for your 8GB VM.
>=20
> > >   4) Speeding up the migration of those free pages
> > >     You're using the bitmap to avoid migrating those free pages; HPe'=
s
> > >     patchset is reconstructing a bitmap from the balloon data;  OK, s=
o
> > >     this all makes sense to avoid migrating them - I'd also been thin=
king
> > >     of using pagemap to spot zero pages that would help find other ze=
ro'd
> > >     pages, but perhaps ballooned is enough?
> > >
> > Could you describe your ideal with more details?
>=20
> At the moment the migration code spends a fair amount of time checking if=
 a
> page is zero; I was thinking perhaps the qemu could just open
> /proc/self/pagemap and check if the page was mapped; that would seem
> cheap if we're checking big ranges; and that would find all the balloon p=
ages.
>=20

Even if virtio-balloon is not enabled, it can be used to find the pages tha=
t never used
by guest.

> > >   5) Second-migrate
> > >     Given a VM where you've done all those tricks on, what happens wh=
en
> > >     you migrate it a second time?   I guess you're aiming for the gue=
st
> > >     to update it's bitmap;  HPe's solution is to migrate it's balloon
> > >     bitmap along with the migration data.
> >
> > Nothing is special in the second migration, QEMU will request the
> > guest for free pages Information, and the guest will traverse it's
> > current free page list to construct a new free page bitmap and send it =
to
> QEMU. Just like in the first migration.
>=20
> Right.
>=20
> Dave
>=20
> > Liang
> > >
> > > Dave
> > >
> > > --
> > > Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK
> --
> Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
