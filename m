Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D92B96B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 09:27:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id t92so6095203wrc.13
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 06:27:16 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id z9si5219115wra.515.2017.12.08.06.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 06:27:15 -0800 (PST)
Date: Fri, 8 Dec 2017 15:27:14 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171208142714.GB7793@amd>
References: <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz>
 <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au>
 <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org>
 <87bmjbks4c.fsf@concordia.ellerman.id.au>
 <CAGXu5jLWRQn6EaXEEvdvXr+4gbiJawwp1EaLMfYisHVfMiqgSA@mail.gmail.com>
 <20171207195727.GA26792@bombadil.infradead.org>
 <87shclh3zc.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7ZAtKRhVyVSsbBD2"
Content-Disposition: inline
In-Reply-To: <87shclh3zc.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>


--7ZAtKRhVyVSsbBD2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2017-12-08 22:08:07, Michael Ellerman wrote:
> Matthew Wilcox <willy@infradead.org> writes:
>=20
> > On Thu, Dec 07, 2017 at 11:14:27AM -0800, Kees Cook wrote:
> >> On Wed, Dec 6, 2017 at 9:46 PM, Michael Ellerman <mpe@ellerman.id.au> =
wrote:
> >> > Matthew Wilcox <willy@infradead.org> writes:
> >> >> So, just like we currently say "exactly one of MAP_SHARED or MAP_PR=
IVATE",
> >> >> we could add a new paragraph saying "at most one of MAP_FIXED or
> >> >> MAP_REQUIRED" and "any of the following values".
> >> >
> >> > MAP_REQUIRED doesn't immediately grab me, but I don't actively disli=
ke
> >> > it either :)
> >> >
> >> > What about MAP_AT_ADDR ?
> >> >
> >> > It's short, and says what it does on the tin. The first argument to =
mmap
> >> > is actually called "addr" too.
> >>=20
> >> "FIXED" is supposed to do this too.
> >>=20
> >> Pavel suggested:
> >>=20
> >> MAP_ADD_FIXED
> >>=20
> >> (which is different from "use fixed", and describes why it would fail:
> >> can't add since it already exists.)
> >>=20
> >> Perhaps "MAP_FIXED_NEW"?
> >>=20
> >> There has been a request to drop "FIXED" from the name, so these:
> >>=20
> >> MAP_FIXED_NOCLOBBER
> >> MAP_FIXED_NOREPLACE
> >> MAP_FIXED_ADD
> >> MAP_FIXED_NEW
> >>=20
> >> Could be:
> >>=20
> >> MAP_NOCLOBBER
> >> MAP_NOREPLACE
> >> MAP_ADD
> >> MAP_NEW
> >>=20
> >> and we still have the unloved, but acceptable:
> >>=20
> >> MAP_REQUIRED
> >>=20
> >> My vote is still for "NOREPLACE" or "NOCLOBBER" since it's very
> >> specific, though "NEW" is pretty clear too.
> >
> > How about MAP_NOFORCE?
>=20
> It doesn't tell me that addr is not a hint. That's a crucial detail.
>=20
> Without MAP_FIXED mmap never "forces/replaces/clobbers", so why would I
> need MAP_NOFORCE if I don't have MAP_FIXED?
>=20
> So it needs something in there to indicate that the addr is not a hint,
> that's the only thing that flag actually *does*.
>=20
>=20
> If we had a time machine, the right set of flags would be:
>=20
>   - MAP_FIXED:   don't treat addr as a hint, fail if addr is not free
>   - MAP_REPLACE: replace an existing mapping (or force or clobber)

Actually, if we had a time machine... would we even provide
MAP_REPLACE functionality?

> But the two were conflated for some reason in the current MAP_FIXED.
>=20
> Given we can't go back and fix it, the closest we can get is to add a
> variant of MAP_FIXED which subtracts the "REPLACE" semantic.
>=20
> ie: MAP_FIXED_NOREPLACE

I like MAP_FIXED_NOREPLACE.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--7ZAtKRhVyVSsbBD2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAloqoUIACgkQMOfwapXb+vLwvwCfQ8H/fsW8/ip7dUMGYhdRy0Nr
qY4AoJeTvd1sbDY8RcKSr6Kr7WV8/Ip8
=HsUI
-----END PGP SIGNATURE-----

--7ZAtKRhVyVSsbBD2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
