Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id C26866B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:55:04 -0400 (EDT)
Received: by qgj62 with SMTP id 62so89135178qgj.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:55:04 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id r84si9471208qkr.12.2015.08.24.08.55.03
        for <linux-mm@kvack.org>;
        Mon, 24 Aug 2015 08:55:04 -0700 (PDT)
Date: Mon, 24 Aug 2015 11:55:03 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150824155503.GB17005@akamai.com>
References: <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
 <CALYGNiPcruTM+2KKNZr7ebCVCPsqytSrW8rSzSmj+1Qp4OqXEw@mail.gmail.com>
 <55DB1C77.8070705@suse.cz>
 <CALYGNiNuZgQFzZ+_dQsPOvSJAX7QfZ38zbabn4wRc=oC5Lb9wA@mail.gmail.com>
 <55DB29EB.1000308@suse.cz>
 <20150824150912.GA17005@akamai.com>
 <CALYGNiMO+bHCJxqC_f__iS_OgjxTWDUXF4XWVKdS4jGLenWX=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bCsyhTFzCvuiizWE"
Content-Disposition: inline
In-Reply-To: <CALYGNiMO+bHCJxqC_f__iS_OgjxTWDUXF4XWVKdS4jGLenWX=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>


--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 24 Aug 2015, Konstantin Khlebnikov wrote:

> On Mon, Aug 24, 2015 at 6:09 PM, Eric B Munson <emunson@akamai.com> wrote:
> > On Mon, 24 Aug 2015, Vlastimil Babka wrote:
> >
> >> On 08/24/2015 03:50 PM, Konstantin Khlebnikov wrote:
> >> >On Mon, Aug 24, 2015 at 4:30 PM, Vlastimil Babka <vbabka@suse.cz> wro=
te:
> >> >>On 08/24/2015 12:17 PM, Konstantin Khlebnikov wrote:
> >> >>>>
> >> >>>>
> >> >>>>I am in the middle of implementing lock on fault this way, but I c=
annot
> >> >>>>see how we will hanlde mremap of a lock on fault region.  Say we h=
ave
> >> >>>>the following:
> >> >>>>
> >> >>>>      addr =3D mmap(len, MAP_ANONYMOUS, ...);
> >> >>>>      mlock(addr, len, MLOCK_ONFAULT);
> >> >>>>      ...
> >> >>>>      mremap(addr, len, 2 * len, ...)
> >> >>>>
> >> >>>>There is no way for mremap to know that the area being remapped wa=
s lock
> >> >>>>on fault so it will be locked and prefaulted by remap.  How can we=
 avoid
> >> >>>>this without tracking per vma if it was locked with lock or lock on
> >> >>>>fault?
> >> >>>
> >> >>>
> >> >>>remap can count filled ptes and prefault only completely populated =
areas.
> >> >>
> >> >>
> >> >>Does (and should) mremap really prefault non-present pages? Shouldn'=
t it
> >> >>just prepare the page tables and that's it?
> >> >
> >> >As I see mremap prefaults pages when it extends mlocked area.
> >> >
> >> >Also quote from manpage
> >> >: If  the memory segment specified by old_address and old_size is loc=
ked
> >> >: (using mlock(2) or similar), then this lock is maintained when the =
segment is
> >> >: resized and/or relocated.  As a  consequence, the amount of memory =
locked
> >> >: by the process may change.
> >>
> >> Oh, right... Well that looks like a convincing argument for having a
> >> sticky VM_LOCKONFAULT after all. Having mremap guess by scanning
> >> existing pte's would slow it down, and be unreliable (was the area
> >> completely populated because MLOCK_ONFAULT was not used or because
> >> the process aulted it already? Was it not populated because
> >> MLOCK_ONFAULT was used, or because mmap(MAP_LOCKED) failed to
> >> populate it all?).
> >
> > Given this, I am going to stop working in v8 and leave the vma flag in
> > place.
> >
> >>
> >> The only sane alternative is to populate always for mremap() of
> >> VM_LOCKED areas, and document this loss of MLOCK_ONFAULT information
> >> as a limitation of mlock2(MLOCK_ONFAULT). Which might or might not
> >> be enough for Eric's usecase, but it's somewhat ugly.
> >>
> >
> > I don't think that this is the right solution, I would be really
> > surprised as a user if an area I locked with MLOCK_ONFAULT was then
> > fully locked and prepopulated after mremap().
>=20
> If mremap is the only problem then we can add opposite flag for it:
>=20
> "MREMAP_NOPOPULATE"
> - do not populate new segment of locked areas
> - do not copy normal areas if possible (anonymous/special must be copied)
>=20
> addr =3D mmap(len, MAP_ANONYMOUS, ...);
> mlock(addr, len, MLOCK_ONFAULT);
> ...
> addr2 =3D mremap(addr, len, 2 * len, MREMAP_NOPOPULATE);
> ...
>=20

But with this, the user must remember what areas are locked with
MLOCK_LOCKONFAULT and which are locked the with prepopulate so the
correct mremap flags can be used.


--bCsyhTFzCvuiizWE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV2z5XAAoJELbVsDOpoOa9IEMQAI8cPCWLNydnJXMJ1i2dcpvo
iOoOMBLXHN4Co3EW1uj+6N+GC5/YOTSDiA+gIs4oocfvDxq5JgxTiYtd3xNHYDQi
+4Y8Yu4MIq2GrJycb1rIuvfV5rzydExQnbZjLwgw/PCO0cXvS9xGuQ142fR7xRkr
KRO07FSsBgPZ6lxsj7Puhcqne+V1FcTAezeTflKklI/L1uPoOvkIf629uWtyTgFD
DXoJWSevVMEkafzkddlvHx8eBqqFW96R5CIof7Biyl2fQeTne9jPed0825VuQ5AT
klntGa2+yGG+SbTS7bE9bP7xYZk52KzLYkUlEeRMHa+UIWuBYSQahAE3UXt234q2
eft+I05U/ke9oVig1pYi6BRS9n0QLSv2bMDKLHKRNWZGJIxEFnDi8CnXaqXbrEFP
0H7k3SF8gboYYjRAC/MrgA0nO1Nlo9qCKvPXIok0PQHSM4LeCsj6XleFdmaC9SUi
VfVHT/Auxz4qkHbc3iM04uyG9i3+5cqdY8rxlsnw/nhcroySVpzYhMgq5hOW0pkU
cqZ9jERfMFt3r5+zCwHaFfUkZotP1794IJ22z6xkiRIPtYd4rh1X/MwpCd2R8HDs
xfpZEaadbhnBnoEGBsqdDQlqnRVDvT6VlFJwLFsAdS7eR/m5pV5pALgurl7imvLe
x5SPgOkSEXGR6o3S3Bbk
=VIeL
-----END PGP SIGNATURE-----

--bCsyhTFzCvuiizWE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
