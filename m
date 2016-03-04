Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE6E6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 21:32:26 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 124so26239891pfg.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 18:32:26 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id q26si2197648pfi.106.2016.03.03.18.32.25
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 18:32:25 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RFC qemu 4/4] migration: filter out guest's free pages in ram
 bulk stage
Date: Fri, 4 Mar 2016 02:32:00 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E03770F98@SHSMSX101.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
	<1457001868-15949-5-git-send-email-liang.z.li@intel.com>
 <20160303131616.753f1de5.cornelia.huck@de.ibm.com>
In-Reply-To: <20160303131616.753f1de5.cornelia.huck@de.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "rth@twiddle.net" <rth@twiddle.net>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>

> On Thu,  3 Mar 2016 18:44:28 +0800
> Liang Li <liang.z.li@intel.com> wrote:
>=20
> > Get the free pages information through virtio and filter out the free
> > pages in the ram bulk stage. This can significantly reduce the total
> > live migration time as well as network traffic.
> >
> > Signed-off-by: Liang Li <liang.z.li@intel.com>
> > ---
> >  migration/ram.c | 52
> > ++++++++++++++++++++++++++++++++++++++++++++++------
> >  1 file changed, 46 insertions(+), 6 deletions(-)
> >
>=20
> > @@ -1945,6 +1971,20 @@ static int ram_save_setup(QEMUFile *f, void
> *opaque)
> >                                              DIRTY_MEMORY_MIGRATION);
> >      }
> >      memory_global_dirty_log_start();
> > +
> > +    if (balloon_free_pages_support() &&
> > +        balloon_get_free_pages(migration_bitmap_rcu->free_pages_bmap,
> > +                               &free_pages_count) =3D=3D 0) {
> > +        qemu_mutex_unlock_iothread();
> > +        while (balloon_get_free_pages(migration_bitmap_rcu-
> >free_pages_bmap,
> > +                                      &free_pages_count) =3D=3D 0) {
> > +            usleep(1000);
> > +        }
> > +        qemu_mutex_lock_iothread();
> > +
> > +
> > + filter_out_guest_free_pages(migration_bitmap_rcu-
> >free_pages_bmap);
>=20
> A general comment: Using the ballooner to get information about pages tha=
t
> can be filtered out is too limited (there may be other ways to do this; w=
e
> might be able to use cmma on s390, for example), and I don't like hardcod=
ing
> to a specific method.
>=20
> What about the reverse approach: Code may register a handler that
> populates the free_pages_bitmap which is called during this stage?

Good suggestion, thanks!

Liang
> <I like the idea of filtering in general, but I haven't looked at the cod=
e yet>
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
