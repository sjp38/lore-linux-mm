Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 653666B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 16:28:41 -0400 (EDT)
Received: by qkda128 with SMTP id a128so37145998qkd.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:28:41 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id r23si2243387qkl.19.2015.08.24.13.28.40
        for <linux-mm@kvack.org>;
        Mon, 24 Aug 2015 13:28:40 -0700 (PDT)
Date: Mon, 24 Aug 2015 16:26:08 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150824202608.GD17005@akamai.com>
References: <CALYGNiPcruTM+2KKNZr7ebCVCPsqytSrW8rSzSmj+1Qp4OqXEw@mail.gmail.com>
 <55DB1C77.8070705@suse.cz>
 <CALYGNiNuZgQFzZ+_dQsPOvSJAX7QfZ38zbabn4wRc=oC5Lb9wA@mail.gmail.com>
 <55DB29EB.1000308@suse.cz>
 <20150824150912.GA17005@akamai.com>
 <CALYGNiMO+bHCJxqC_f__iS_OgjxTWDUXF4XWVKdS4jGLenWX=g@mail.gmail.com>
 <20150824155503.GB17005@akamai.com>
 <CALYGNiPiZgac_TQVuU0907uA6G69wCmV6pBzgpa6sQ-wHLGvGQ@mail.gmail.com>
 <20150824170028.GC17005@akamai.com>
 <CALYGNiO3r9Yx7xeS-rZ_nVCR+BRP4d0-Fnd0omkBDdh1ftnExg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ylS2wUBXLOxYXZFQ"
Content-Disposition: inline
In-Reply-To: <CALYGNiO3r9Yx7xeS-rZ_nVCR+BRP4d0-Fnd0omkBDdh1ftnExg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>


--ylS2wUBXLOxYXZFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 24 Aug 2015, Konstantin Khlebnikov wrote:

> On Mon, Aug 24, 2015 at 8:00 PM, Eric B Munson <emunson@akamai.com> wrote:
> > On Mon, 24 Aug 2015, Konstantin Khlebnikov wrote:
> >
> >> On Mon, Aug 24, 2015 at 6:55 PM, Eric B Munson <emunson@akamai.com> wr=
ote:
> >> > On Mon, 24 Aug 2015, Konstantin Khlebnikov wrote:
> >> >
> >> >> On Mon, Aug 24, 2015 at 6:09 PM, Eric B Munson <emunson@akamai.com>=
 wrote:
> >> >> > On Mon, 24 Aug 2015, Vlastimil Babka wrote:
> >> >> >
> >> >> >> On 08/24/2015 03:50 PM, Konstantin Khlebnikov wrote:
> >> >> >> >On Mon, Aug 24, 2015 at 4:30 PM, Vlastimil Babka <vbabka@suse.c=
z> wrote:
> >> >> >> >>On 08/24/2015 12:17 PM, Konstantin Khlebnikov wrote:
> >> >> >> >>>>
> >> >> >> >>>>
> >> >> >> >>>>I am in the middle of implementing lock on fault this way, b=
ut I cannot
> >> >> >> >>>>see how we will hanlde mremap of a lock on fault region.  Sa=
y we have
> >> >> >> >>>>the following:
> >> >> >> >>>>
> >> >> >> >>>>      addr =3D mmap(len, MAP_ANONYMOUS, ...);
> >> >> >> >>>>      mlock(addr, len, MLOCK_ONFAULT);
> >> >> >> >>>>      ...
> >> >> >> >>>>      mremap(addr, len, 2 * len, ...)
> >> >> >> >>>>
> >> >> >> >>>>There is no way for mremap to know that the area being remap=
ped was lock
> >> >> >> >>>>on fault so it will be locked and prefaulted by remap.  How =
can we avoid
> >> >> >> >>>>this without tracking per vma if it was locked with lock or =
lock on
> >> >> >> >>>>fault?
> >> >> >> >>>
> >> >> >> >>>
> >> >> >> >>>remap can count filled ptes and prefault only completely popu=
lated areas.
> >> >> >> >>
> >> >> >> >>
> >> >> >> >>Does (and should) mremap really prefault non-present pages? Sh=
ouldn't it
> >> >> >> >>just prepare the page tables and that's it?
> >> >> >> >
> >> >> >> >As I see mremap prefaults pages when it extends mlocked area.
> >> >> >> >
> >> >> >> >Also quote from manpage
> >> >> >> >: If  the memory segment specified by old_address and old_size =
is locked
> >> >> >> >: (using mlock(2) or similar), then this lock is maintained whe=
n the segment is
> >> >> >> >: resized and/or relocated.  As a  consequence, the amount of m=
emory locked
> >> >> >> >: by the process may change.
> >> >> >>
> >> >> >> Oh, right... Well that looks like a convincing argument for havi=
ng a
> >> >> >> sticky VM_LOCKONFAULT after all. Having mremap guess by scanning
> >> >> >> existing pte's would slow it down, and be unreliable (was the ar=
ea
> >> >> >> completely populated because MLOCK_ONFAULT was not used or becau=
se
> >> >> >> the process aulted it already? Was it not populated because
> >> >> >> MLOCK_ONFAULT was used, or because mmap(MAP_LOCKED) failed to
> >> >> >> populate it all?).
> >> >> >
> >> >> > Given this, I am going to stop working in v8 and leave the vma fl=
ag in
> >> >> > place.
> >> >> >
> >> >> >>
> >> >> >> The only sane alternative is to populate always for mremap() of
> >> >> >> VM_LOCKED areas, and document this loss of MLOCK_ONFAULT informa=
tion
> >> >> >> as a limitation of mlock2(MLOCK_ONFAULT). Which might or might n=
ot
> >> >> >> be enough for Eric's usecase, but it's somewhat ugly.
> >> >> >>
> >> >> >
> >> >> > I don't think that this is the right solution, I would be really
> >> >> > surprised as a user if an area I locked with MLOCK_ONFAULT was th=
en
> >> >> > fully locked and prepopulated after mremap().
> >> >>
> >> >> If mremap is the only problem then we can add opposite flag for it:
> >> >>
> >> >> "MREMAP_NOPOPULATE"
> >> >> - do not populate new segment of locked areas
> >> >> - do not copy normal areas if possible (anonymous/special must be c=
opied)
> >> >>
> >> >> addr =3D mmap(len, MAP_ANONYMOUS, ...);
> >> >> mlock(addr, len, MLOCK_ONFAULT);
> >> >> ...
> >> >> addr2 =3D mremap(addr, len, 2 * len, MREMAP_NOPOPULATE);
> >> >> ...
> >> >>
> >> >
> >> > But with this, the user must remember what areas are locked with
> >> > MLOCK_LOCKONFAULT and which are locked the with prepopulate so the
> >> > correct mremap flags can be used.
> >> >
> >>
> >> Yep. Shouldn't be hard. You anyway have to do some changes in user-spa=
ce.
> >>
> >
> > Sorry if I wasn't clear enough in my last reply, I think forcing
> > userspace to track this is the wrong choice.  The VM system is
> > responsible for tracking these attributes and should continue to be.
>=20
> Userspace tracks addresses and sizes of these areas. Plus mremap obviously
> works only with page granularity so memory allocator in userspace have to=
 know
> a lot about these structures. So keeping one more bit isn't a rocket scie=
nce.
>=20

Fair enough, however, my current implementation does not require that
userspace keep track of any extra information.  With the VM_LOCKONFAULT
flag mremap() keeps the properties that were set with mlock() or
equivalent across remaps.

> >
> >>
> >> Much simpler for users-pace solution is a mm-wide flag which turns all=
 further
> >> mlocks and MAP_LOCKED into lock-on-fault. Something like
> >> mlockall(MCL_NOPOPULATE_LOCKED).
> >
> > This set certainly adds the foundation for such a change if you think it
> > would be useful.  That particular behavior was not part of my inital use
> > case though.
> >
>=20
> This looks like much easier solution: you don't need new syscall and after
> enabling that lock-on-fault mode userspace still can get old behaviour si=
mply
> by touching newly locked area.

Again, this suggestion requires that userspace know more about VM than
with my implementation and will require it to walk an entire mapping
before use to fault it in if required.  With the current implementation,
mlock continues to function as it has, with the additional flexibility
of being able to request that areas not be prepopulated.

--ylS2wUBXLOxYXZFQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV233gAAoJELbVsDOpoOa9Ue0P/2to/kSUnUJK4LAuvUwvKEio
/2wRZ65G1xdyz1Eqq3Zt2ldvxKW0JbSV7T/cvqo42iV0nUdjMFqWiux1DwJj/vX0
nqqE2LtnTBYbxpbfNgrtSHmWmH27nco1JpNAIW+adLBankNlpgVL0PhGXRvVHZ70
rkfYrOdVzT/dh+ENhrBOQfx/otQYF03/u3YH3b6ZK5IxibLgKt3azB3eCdDev7yK
GJqqo/5FRYIVjKropJaDWWWdPXK8UmY2gCTLPJ7eCucyIZV6rEFddHhpnN5nJGjr
I7cadVOA+wqiLTTS7hHv1FQRy0vekU82z6HWSD6O6fLgdSvv+72mH6QuoeY1LGK7
+Xz5irWJDxk404MifDv9nI9dEC2wLN7vTv6lqUcTh/0g0zszomONM9XEEl/JfZK7
dUJQvPvIjegFM13YY1jt6+rTx9SRNW0Vq4oL+qY5SOwi1Xs9+khC8Yj76Dx5feCA
eE5Whm+0pz56/1RnAwWgkaxJ3LAbCjVJ9QAMvYSFp4uAna4O6zLR1kmg6D9goMf+
bxDk0uvZAOeLuAkDlS32O/43IC3BDv7l+hi+IpbWb+u2JtVUIO1/ueRW7zgud8uV
0hHn3swsQobVdNo9pvPGEvAsRmGjWyr3pLXpQwzOscoZce8aoiUNG8vJ98nEl6QH
BtWL4A8MUsoU37DIhOR6
=nKz/
-----END PGP SIGNATURE-----

--ylS2wUBXLOxYXZFQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
