Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA4A6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:00:32 -0400 (EDT)
Received: by qgj62 with SMTP id 62so90340394qgj.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 10:00:32 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id t29si933259qki.36.2015.08.24.10.00.28
        for <linux-mm@kvack.org>;
        Mon, 24 Aug 2015 10:00:28 -0700 (PDT)
Date: Mon, 24 Aug 2015 13:00:28 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150824170028.GC17005@akamai.com>
References: <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
 <CALYGNiPcruTM+2KKNZr7ebCVCPsqytSrW8rSzSmj+1Qp4OqXEw@mail.gmail.com>
 <55DB1C77.8070705@suse.cz>
 <CALYGNiNuZgQFzZ+_dQsPOvSJAX7QfZ38zbabn4wRc=oC5Lb9wA@mail.gmail.com>
 <55DB29EB.1000308@suse.cz>
 <20150824150912.GA17005@akamai.com>
 <CALYGNiMO+bHCJxqC_f__iS_OgjxTWDUXF4XWVKdS4jGLenWX=g@mail.gmail.com>
 <20150824155503.GB17005@akamai.com>
 <CALYGNiPiZgac_TQVuU0907uA6G69wCmV6pBzgpa6sQ-wHLGvGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zCKi3GIZzVBPywwA"
Content-Disposition: inline
In-Reply-To: <CALYGNiPiZgac_TQVuU0907uA6G69wCmV6pBzgpa6sQ-wHLGvGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>


--zCKi3GIZzVBPywwA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 24 Aug 2015, Konstantin Khlebnikov wrote:

> On Mon, Aug 24, 2015 at 6:55 PM, Eric B Munson <emunson@akamai.com> wrote:
> > On Mon, 24 Aug 2015, Konstantin Khlebnikov wrote:
> >
> >> On Mon, Aug 24, 2015 at 6:09 PM, Eric B Munson <emunson@akamai.com> wr=
ote:
> >> > On Mon, 24 Aug 2015, Vlastimil Babka wrote:
> >> >
> >> >> On 08/24/2015 03:50 PM, Konstantin Khlebnikov wrote:
> >> >> >On Mon, Aug 24, 2015 at 4:30 PM, Vlastimil Babka <vbabka@suse.cz> =
wrote:
> >> >> >>On 08/24/2015 12:17 PM, Konstantin Khlebnikov wrote:
> >> >> >>>>
> >> >> >>>>
> >> >> >>>>I am in the middle of implementing lock on fault this way, but =
I cannot
> >> >> >>>>see how we will hanlde mremap of a lock on fault region.  Say w=
e have
> >> >> >>>>the following:
> >> >> >>>>
> >> >> >>>>      addr =3D mmap(len, MAP_ANONYMOUS, ...);
> >> >> >>>>      mlock(addr, len, MLOCK_ONFAULT);
> >> >> >>>>      ...
> >> >> >>>>      mremap(addr, len, 2 * len, ...)
> >> >> >>>>
> >> >> >>>>There is no way for mremap to know that the area being remapped=
 was lock
> >> >> >>>>on fault so it will be locked and prefaulted by remap.  How can=
 we avoid
> >> >> >>>>this without tracking per vma if it was locked with lock or loc=
k on
> >> >> >>>>fault?
> >> >> >>>
> >> >> >>>
> >> >> >>>remap can count filled ptes and prefault only completely populat=
ed areas.
> >> >> >>
> >> >> >>
> >> >> >>Does (and should) mremap really prefault non-present pages? Shoul=
dn't it
> >> >> >>just prepare the page tables and that's it?
> >> >> >
> >> >> >As I see mremap prefaults pages when it extends mlocked area.
> >> >> >
> >> >> >Also quote from manpage
> >> >> >: If  the memory segment specified by old_address and old_size is =
locked
> >> >> >: (using mlock(2) or similar), then this lock is maintained when t=
he segment is
> >> >> >: resized and/or relocated.  As a  consequence, the amount of memo=
ry locked
> >> >> >: by the process may change.
> >> >>
> >> >> Oh, right... Well that looks like a convincing argument for having a
> >> >> sticky VM_LOCKONFAULT after all. Having mremap guess by scanning
> >> >> existing pte's would slow it down, and be unreliable (was the area
> >> >> completely populated because MLOCK_ONFAULT was not used or because
> >> >> the process aulted it already? Was it not populated because
> >> >> MLOCK_ONFAULT was used, or because mmap(MAP_LOCKED) failed to
> >> >> populate it all?).
> >> >
> >> > Given this, I am going to stop working in v8 and leave the vma flag =
in
> >> > place.
> >> >
> >> >>
> >> >> The only sane alternative is to populate always for mremap() of
> >> >> VM_LOCKED areas, and document this loss of MLOCK_ONFAULT information
> >> >> as a limitation of mlock2(MLOCK_ONFAULT). Which might or might not
> >> >> be enough for Eric's usecase, but it's somewhat ugly.
> >> >>
> >> >
> >> > I don't think that this is the right solution, I would be really
> >> > surprised as a user if an area I locked with MLOCK_ONFAULT was then
> >> > fully locked and prepopulated after mremap().
> >>
> >> If mremap is the only problem then we can add opposite flag for it:
> >>
> >> "MREMAP_NOPOPULATE"
> >> - do not populate new segment of locked areas
> >> - do not copy normal areas if possible (anonymous/special must be copi=
ed)
> >>
> >> addr =3D mmap(len, MAP_ANONYMOUS, ...);
> >> mlock(addr, len, MLOCK_ONFAULT);
> >> ...
> >> addr2 =3D mremap(addr, len, 2 * len, MREMAP_NOPOPULATE);
> >> ...
> >>
> >
> > But with this, the user must remember what areas are locked with
> > MLOCK_LOCKONFAULT and which are locked the with prepopulate so the
> > correct mremap flags can be used.
> >
>=20
> Yep. Shouldn't be hard. You anyway have to do some changes in user-space.
>=20

Sorry if I wasn't clear enough in my last reply, I think forcing
userspace to track this is the wrong choice.  The VM system is
responsible for tracking these attributes and should continue to be.

>=20
> Much simpler for users-pace solution is a mm-wide flag which turns all fu=
rther
> mlocks and MAP_LOCKED into lock-on-fault. Something like
> mlockall(MCL_NOPOPULATE_LOCKED).

This set certainly adds the foundation for such a change if you think it
would be useful.  That particular behavior was not part of my inital use
case though.


--zCKi3GIZzVBPywwA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV202sAAoJELbVsDOpoOa9Oi8P/jYlOtUrXtvvqK5Oiozpis6Z
zb7mLmaiWxr61uIe/ljCdtWpWK8XHLSsM7xx5IKGQAkhgjmiQSdeDVIh5iWU/9mY
6Vz/XYBmLDuC7cq8N+ZAJbv7LDhQOFma1Kp86YA1nVHyZhayEFOxZqUbwAkhMJKE
Qx1+qKNs/7W1cA21iYDYV2Zn/Uopjxx2bhdR6uOAnEFC/FdnXy33J9M4ArJHVpLO
YLsg9ufYtM3vpJObGTHRASyQ0NLMADzmLB6w5U+F8g2dWHzJjIP+kHPTDLda1HC0
x5edQgqjAV/TQ6DBsVcms+GYXLkYsEM8wCunvHqOSCrNjyk8yiF4rnZm55CG/WcR
d9aP0KH5iwgSTqWvl9WLclf2MWX84AetDHWfnA0KF6Q7eYRPbQXccTqUNLFdwQBg
6eYKEKaqbuK0bBts4kJlLRZGN5paAjgFLCB3njxPYzMqBhHaU3skQsYY/v6Xa/9D
9tsrpTNQqhaY2j2eZQeek5oJYTpGPdGagGd5AoLZTtIfzFhFTyFl62mwsXMVOKZF
n20DxV41TFrRMUe+RkFhzyvApjyZpgeQBNlCJArYLUrNZvUN67H72GXcHNtYJUAx
DfJteZBYCyq6tOV4DaEYBiWOn3P2KrIHZpBDLCIQMwWTwiKPDZWA1Rtv+vPfP51q
AGupr2+rybcpunEOKHx/
=Y0HY
-----END PGP SIGNATURE-----

--zCKi3GIZzVBPywwA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
