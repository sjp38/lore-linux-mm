Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD1E6B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 14:06:44 -0400 (EDT)
Received: by ykfw194 with SMTP id w194so102629199ykf.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 11:06:43 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id n83si16109342ykn.36.2015.07.28.11.06.42
        for <linux-mm@kvack.org>;
        Tue, 28 Jul 2015 11:06:43 -0700 (PDT)
Date: Tue, 28 Jul 2015 14:06:42 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V5 0/7] Allow user to request memory to be locked on page
 fault
Message-ID: <20150728180642.GE2407@akamai.com>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <55B5F4FF.9070604@suse.cz>
 <20150727133555.GA17133@akamai.com>
 <55B63D37.20303@suse.cz>
 <20150727145409.GB21664@akamai.com>
 <20150728111725.GG24972@dhcp22.suse.cz>
 <20150728134942.GB2407@akamai.com>
 <55B79B7F.9010604@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gDGSpKKIBgtShtf+"
Content-Disposition: inline
In-Reply-To: <55B79B7F.9010604@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--gDGSpKKIBgtShtf+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 28 Jul 2015, Vlastimil Babka wrote:

> On 07/28/2015 03:49 PM, Eric B Munson wrote:
> >On Tue, 28 Jul 2015, Michal Hocko wrote:
> >
>=20
> [...]
>=20
> >The only
> >remaining question I have is should we have 2 new mlockall flags so that
> >the caller can explicitly set VM_LOCKONFAULT in the mm->def_flags vs
> >locking all current VMAs on fault.  I ask because if the user wants to
> >lock all current VMAs the old way, but all future VMAs on fault they
> >have to call mlockall() twice:
> >
> >	mlockall(MCL_CURRENT);
> >	mlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);
> >
> >This has the side effect of converting all the current VMAs to
> >VM_LOCKONFAULT, but because they were all made present and locked in the
> >first call, this should not matter in most cases.
>=20
> Shouldn't the user be able to do this?
>=20
> mlockall(MCL_CURRENT)
> mlockall(MCL_FUTURE | MCL_ONFAULT);
>=20
> Note that the second call shouldn't change (i.e. munlock) existing
> vma's just because MCL_CURRENT is not present. The current
> implementation doesn't do that thanks to the following in
> do_mlockall():
>=20
>         if (flags =3D=3D MCL_FUTURE)
>                 goto out;
>=20
> before current vma's are processed and MCL_CURRENT is checked. This
> is probably so that do_mlockall() can also handle the munlockall()
> syscall.
> So we should be careful not to break this, but otherwise there are
> no limitations by not having two MCL_ONFAULT flags. Having to do
> invoke syscalls instead of one is not an issue as this shouldn't be
> frequent syscall.

Good catch, my current implementation did break this and is now fixed.

>=20
> >The catch is that,
> >like mmap(MAP_LOCKED), mlockall() does not communicate if mm_populate()
> >fails.  This has been true of mlockall() from the beginning so I don't
> >know if it needs more than an entry in the man page to clarify (which I
> >will add when I add documentation for MCL_ONFAULT).
>=20
> Good point.
>=20
> >In a much less
> >likely corner case, it is not possible in the current setup to request
> >all current VMAs be VM_LOCKONFAULT and all future be VM_LOCKED.
>=20
> So again this should work:
>=20
> mlockall(MCL_CURRENT | MCL_ONFAULT)
> mlockall(MCL_FUTURE);
>=20
> But the order matters here, as current implementation of
> do_mlockall() will clear VM_LOCKED from def_flags if MCL_FUTURE is
> not passed. So *it's different* from how it handles MCL_CURRENT (as
> explained above). And not documented in manpage. Oh crap, this API
> is a closet full of skeletons. Maybe it was an unnoticed regression
> and we can restore some sanity?

I will add a note about the ordering problem to the manpage as well.
Unfortunately, the basic idea of clearing VM_LOCKED from mm->def_flags
if MCL_FUTURE is not specified but not doing the same for MCL_CURRENT
predates the move to git, so I am not sure if it was ever different.


--gDGSpKKIBgtShtf+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVt8SyAAoJELbVsDOpoOa9ZesP/1N/oMkXQdcSEZVI2hPN/lg2
9mWtmYEND1iC1vy7m8SDPnbAhVEDe7QS1LnkybW7h+ZPDdEcYndvaWGlwVZfAcFF
ibAYaG7hkQ5mOwpRrAqIf0Fmgya0W1tJjIxg59FyHxsFZBGe+NiCZ7CmZGpTp8sY
5QcFKUSFRGoIfAp2A4akeitUr3Eq62QEDOGrGq7TJboHJeNklRqRwDjYgMSe6NHq
lR7KOBP/iPu3W2yWpOcfqxQiv4V0d7C4cZTi4NcQeaOy4tkolspMZaUuA4n0u+ZI
1uyUaVo24RhGucRALQ5oM5l6pQLL+cGeWGmJtrB9lwydD0H5aVxYqVKAXylYDhBN
VeVocCkLkpQZX8NnMpWcqMDpq0gSuM0YbtMHpaU04suBNBCHb4nnc9uql5GHm5TX
WyrTKCj9tG5vmM94RKhreI4SpN2v1K0BwmRWDV0hgSl1/WIizxSOgnrs5VBEzrXo
78HoY24TPsDTs6bhsfuQ6uaKmy1Q8fQpkGCenVaveOW4igVJvvZEVKKvZwDu0VzD
HrAKkRfYO427d8Xk46ZJzav0RcwR7LWeBfm68QkswXhMWEMVcxXf3hAJxl+rWsCa
WJenAR2HADZCQrfLWp5bLYcdWww8LHoWRiT8M2jBjn/BNTblo0yLd3o+kdFxJ2V9
f6X8bsOxQAhqSGzrGcnK
=OZR5
-----END PGP SIGNATURE-----

--gDGSpKKIBgtShtf+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
