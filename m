Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id BD84C6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 16:34:58 -0400 (EDT)
Received: by qgef3 with SMTP id f3so56166677qge.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 13:34:58 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id b129si4101097qhc.109.2015.07.08.13.34.57
        for <linux-mm@kvack.org>;
        Wed, 08 Jul 2015 13:34:57 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:34:56 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V3 3/5] mm: mlock: Introduce VM_LOCKONFAULT and add mlock
 flags to enable it
Message-ID: <20150708203456.GC4669@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
 <1436288623-13007-4-git-send-email-emunson@akamai.com>
 <20150708132351.61c13db6@lwn.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PuGuTyElPB9bOcsM"
Content-Disposition: inline
In-Reply-To: <20150708132351.61c13db6@lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--PuGuTyElPB9bOcsM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 08 Jul 2015, Jonathan Corbet wrote:

> On Tue,  7 Jul 2015 13:03:41 -0400
> Eric B Munson <emunson@akamai.com> wrote:
>=20
> > This patch introduces the ability to request that pages are not
> > pre-faulted, but are placed on the unevictable LRU when they are finally
> > faulted in.  This can be done area at a time via the
> > mlock2(MLOCK_ONFAULT) or the mlockall(MCL_ONFAULT) system calls.  These
> > calls can be undone via munlock2(MLOCK_ONFAULT) or
> > munlockall2(MCL_ONFAULT).
>=20
> Quick, possibly dumb question: I've been beating my head against these for
> a little bit, and I can't figure out what's supposed to happen in this
> case:
>=20
> 	mlock2(addr, len, MLOCK_ONFAULT);
> 	munlock2(addr, len, MLOCK_LOCKED);
>=20
> It looks to me like it will clear VM_LOCKED without actually unlocking any
> pages.  Is that the intended result?

This is not quite right, what happens when you call munlock2(addr, len,
MLOCK_LOCKED); is we call apply_vma_flags(addr, len, VM_LOCKED, false).
The false argument means that we intend to clear the specified flags.
Here is the relevant snippet:
=2E..
                newflags =3D vma->vm_flags;
                if (add_flags) {
                        newflags &=3D ~(VM_LOCKED | VM_LOCKONFAULT);
                        newflags |=3D flags;
                } else {
                        newflags &=3D ~flags;
                }
=2E..

Note that when we are adding flags, we first clear both VM_LOCKED and
VM_LOCKONFAULT.  This was done to match the behavior found in
mlockall().  When we are remove flags, we simply clear the specified
flag(s).

So in your example the state of the VMAs covered by addr and len would
remain unchanged.

It sounds like apply_vma_flags() needs a comment covering this topic, I
will include that in the set I am working on now.

Eric

--PuGuTyElPB9bOcsM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVnYlwAAoJELbVsDOpoOa96jQQAMzj+srECYanjQL4rB5HSwhS
jfU2GPE5w8xLHqHEdoPmu/98FKAK7kNvhb4Ytdmssq+sHIS3sHbx2b4SFkMLDnM8
4hTQtkUaD9ti+HnmBvxbDYNfn2MGHlxtfhML88/tA3LPproe9aWWZGtn4xZ+TE96
Qbnb0X4WCKuT2blVmoQ2Uf1zT2eaGJmpWk+QEKrWqlLDtijNcHEXiNn+1odo8WJd
7rr/7tjO+4N6AhC+0NypU9JhFB0L5pxm1Au+U3L3N8Szq8palqGYZ76k7X2cdNrN
7bc3ghWSLnA6p6sw1T4PDcuLhDNnS4zdtodtBJK6aVVR6NmJSzB8xU//HqFb27RA
s+0Z/6U8Z1P58q/IvMay2hsqmNY2hobvpNlm59JJynX+ajMC0IrzYrB0CDAIoO5s
tx5O4LDrMMsU/av92mU0y8yqGZdiGBQsIWfKTklWvq9q6HbDGae/WoSsnV5zX/b8
zHpvJxCmRG92vEwb46mqSbnWbkzK10SVyZRohrTd35hmSkXHpEk2AWwLHriLMtD8
nF/mQYL88FSsXwDKoz2Iw3C6HPVR6lDS8kae5iY4C0umP8FFX7VuBYBXOn29E1U4
mKbYb/wKn9x4iI4IeyHLBN4m+4zY+pqhXNlNKQ3hOR3jgMXPQ2fx7mzoEiRwB40g
4dkKMXOml6uRVob09Ixx
=lbgU
-----END PGP SIGNATURE-----

--PuGuTyElPB9bOcsM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
