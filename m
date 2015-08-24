Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id CE7196B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:09:13 -0400 (EDT)
Received: by qkfh127 with SMTP id h127so70656700qkf.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:09:13 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id h69si28578107qkh.122.2015.08.24.08.09.12
        for <linux-mm@kvack.org>;
        Mon, 24 Aug 2015 08:09:13 -0700 (PDT)
Date: Mon, 24 Aug 2015 11:09:12 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150824150912.GA17005@akamai.com>
References: <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz>
 <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz>
 <20150821183132.GA12835@akamai.com>
 <CALYGNiPcruTM+2KKNZr7ebCVCPsqytSrW8rSzSmj+1Qp4OqXEw@mail.gmail.com>
 <55DB1C77.8070705@suse.cz>
 <CALYGNiNuZgQFzZ+_dQsPOvSJAX7QfZ38zbabn4wRc=oC5Lb9wA@mail.gmail.com>
 <55DB29EB.1000308@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
Content-Disposition: inline
In-Reply-To: <55DB29EB.1000308@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 24 Aug 2015, Vlastimil Babka wrote:

> On 08/24/2015 03:50 PM, Konstantin Khlebnikov wrote:
> >On Mon, Aug 24, 2015 at 4:30 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> >>On 08/24/2015 12:17 PM, Konstantin Khlebnikov wrote:
> >>>>
> >>>>
> >>>>I am in the middle of implementing lock on fault this way, but I cann=
ot
> >>>>see how we will hanlde mremap of a lock on fault region.  Say we have
> >>>>the following:
> >>>>
> >>>>      addr =3D mmap(len, MAP_ANONYMOUS, ...);
> >>>>      mlock(addr, len, MLOCK_ONFAULT);
> >>>>      ...
> >>>>      mremap(addr, len, 2 * len, ...)
> >>>>
> >>>>There is no way for mremap to know that the area being remapped was l=
ock
> >>>>on fault so it will be locked and prefaulted by remap.  How can we av=
oid
> >>>>this without tracking per vma if it was locked with lock or lock on
> >>>>fault?
> >>>
> >>>
> >>>remap can count filled ptes and prefault only completely populated are=
as.
> >>
> >>
> >>Does (and should) mremap really prefault non-present pages? Shouldn't it
> >>just prepare the page tables and that's it?
> >
> >As I see mremap prefaults pages when it extends mlocked area.
> >
> >Also quote from manpage
> >: If  the memory segment specified by old_address and old_size is locked
> >: (using mlock(2) or similar), then this lock is maintained when the seg=
ment is
> >: resized and/or relocated.  As a  consequence, the amount of memory loc=
ked
> >: by the process may change.
>=20
> Oh, right... Well that looks like a convincing argument for having a
> sticky VM_LOCKONFAULT after all. Having mremap guess by scanning
> existing pte's would slow it down, and be unreliable (was the area
> completely populated because MLOCK_ONFAULT was not used or because
> the process aulted it already? Was it not populated because
> MLOCK_ONFAULT was used, or because mmap(MAP_LOCKED) failed to
> populate it all?).

Given this, I am going to stop working in v8 and leave the vma flag in
place.

>=20
> The only sane alternative is to populate always for mremap() of
> VM_LOCKED areas, and document this loss of MLOCK_ONFAULT information
> as a limitation of mlock2(MLOCK_ONFAULT). Which might or might not
> be enough for Eric's usecase, but it's somewhat ugly.
>=20

I don't think that this is the right solution, I would be really
surprised as a user if an area I locked with MLOCK_ONFAULT was then
fully locked and prepopulated after mremap().

> >>
> >>>There might be a problem after failed populate: remap will handle them
> >>>as lock on fault. In this case we can fill ptes with swap-like non-pre=
sent
> >>>entries to remember that fact and count them as should-be-locked pages.
> >>
> >>
> >>I don't think we should strive to have mremap try to fix the inherent
> >>unreliability of mmap (MAP_POPULATE)?
> >
> >I don't think so. MAP_POPULATE works only when mmap happens.
> >Flag MREMAP_POPULATE might be a good idea. Just for symmetry.
>=20
> Maybe, but please do it as a separate series.
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV2zOYAAoJELbVsDOpoOa914QP/1WLYpDWRu7QcEFQsZ9/EphN
U65FGIqpVmkV7VQrHdpYjotjrr4PpNP+Z8u1pv/QDarupqrbINuFaBF3ip9IN1bB
kgDpUyFSK04nSRDMVF5jww7ONXjhr7d5NgT8wn+HXW5l34FZkFlHCDEldA/WI6yz
IjPFlIfQRBxUgmiDcOFBNWLiacDLpJICQjshwdMTmZl7RedJM184lXS8mIL2CINs
4og3PWz6xDSAoJ3PfaOcVtfKPYAdQDct8/18fr5o2/7bVa+DXr4xQ/vJUsmqXpXc
ZEz1ZDCAbiq4qS+ybPdWonhnl4nNxeid1HZGrxNEDA6kHlmZ8Vw5uh7vh8HtlEWJ
RxMTGONvrVC8s2ijDOzqqfAD7+8zupBouomgYIoKLSyPsXMOvfqFJqO4JJoj+pmP
i8Gz6OedSsXI28VoctkTyfVkCB4f1eYRARgXbxMhpC+eCL35trfIqA/a6kfxKu7c
JrhJqND3cM2UdTmT6G/KVwnTzpoTxV7lfmgnM0/K61CIJ0/s2xGClwxiLu6lLdM/
bwxQuh6yVXCVccqN7eDBcrkRuabzcIUfbHu6YL1roahLb+gLKYyRgYrKdBmi6u2v
PoEwOMvUqgiiZFfp3qBgRolssOgdW6G8SRWk2z9Rky9c2nMsCe01RP34YZUrlvWc
GM8koujIdjNTzrk505ic
=iivI
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
