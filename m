Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF87E6B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 03:24:11 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j128so22778337oif.3
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 00:24:11 -0700 (PDT)
Received: from g4t3428.houston.hpe.com (g4t3428.houston.hpe.com. [15.241.140.76])
        by mx.google.com with ESMTPS id x12si17382827otd.30.2016.09.14.00.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 00:24:02 -0700 (PDT)
Subject: Re: [RFC PATCH v2 0/3] Add support for eXclusive Page Frame Ownership
 (XPFO)
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Message-ID: <afe6dc8e-7e53-e4e4-8959-0098d3d0c92a@hpe.com>
Date: Wed, 14 Sep 2016 09:23:58 +0200
MIME-Version: 1.0
In-Reply-To: <20160914071901.8127-1-juerg.haefliger@hpe.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="X1S6k1OXnDBv9lOh0eaK4rxduXi2rQ5fA"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--X1S6k1OXnDBv9lOh0eaK4rxduXi2rQ5fA
Content-Type: multipart/mixed; boundary="rOu3TDjgvxEHAGHDHwIoR03apojltv8SM";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@hpe.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu
Message-ID: <afe6dc8e-7e53-e4e4-8959-0098d3d0c92a@hpe.com>
Subject: Re: [RFC PATCH v2 0/3] Add support for eXclusive Page Frame Ownership
 (XPFO)
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
In-Reply-To: <20160914071901.8127-1-juerg.haefliger@hpe.com>

--rOu3TDjgvxEHAGHDHwIoR03apojltv8SM
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Resending to include the kernel-hardening list. Sorry, I wasn't subscribe=
d with the correct email
address when I sent this the first time.

=2E..Juerg

On 09/14/2016 09:18 AM, Juerg Haefliger wrote:
> Changes from:
>   v1 -> v2:
>     - Moved the code from arch/x86/mm/ to mm/ since it's (mostly)
>       arch-agnostic.
>     - Moved the config to the generic layer and added ARCH_SUPPORTS_XPF=
O
>       for x86.
>     - Use page_ext for the additional per-page data.
>     - Removed the clearing of pages. This can be accomplished by using
>       PAGE_POISONING.
>     - Split up the patch into multiple patches.
>     - Fixed additional issues identified by reviewers.
>=20
> This patch series adds support for XPFO which protects against 'ret2dir=
'
> kernel attacks. The basic idea is to enforce exclusive ownership of pag=
e
> frames by either the kernel or userspace, unless explicitly requested b=
y
> the kernel. Whenever a page destined for userspace is allocated, it is
> unmapped from physmap (the kernel's page table). When such a page is
> reclaimed from userspace, it is mapped back to physmap.
>=20
> Additional fields in the page_ext struct are used for XPFO housekeeping=
=2E
> Specifically two flags to distinguish user vs. kernel pages and to tag
> unmapped pages and a reference counter to balance kmap/kunmap operation=
s
> and a lock to serialize access to the XPFO fields.
>=20
> Known issues/limitations:
>   - Only supports x86-64 (for now)
>   - Only supports 4k pages (for now)
>   - There are most likely some legitimate uses cases where the kernel n=
eeds
>     to access userspace which need to be made XPFO-aware
>   - Performance penalty
>=20
> Reference paper by the original patch authors:
>   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf
>=20
> Juerg Haefliger (3):
>   Add support for eXclusive Page Frame Ownership (XPFO)
>   xpfo: Only put previous userspace pages into the hot cache
>   block: Always use a bounce buffer when XPFO is enabled
>=20
>  arch/x86/Kconfig         |   3 +-
>  arch/x86/mm/init.c       |   2 +-
>  block/blk-map.c          |   2 +-
>  include/linux/highmem.h  |  15 +++-
>  include/linux/page_ext.h |   7 ++
>  include/linux/xpfo.h     |  41 +++++++++
>  lib/swiotlb.c            |   3 +-
>  mm/Makefile              |   1 +
>  mm/page_alloc.c          |  10 ++-
>  mm/page_ext.c            |   4 +
>  mm/xpfo.c                | 213 +++++++++++++++++++++++++++++++++++++++=
++++++++
>  security/Kconfig         |  20 +++++
>  12 files changed, 314 insertions(+), 7 deletions(-)
>  create mode 100644 include/linux/xpfo.h
>  create mode 100644 mm/xpfo.c
>=20


--=20
Juerg Haefliger
Hewlett Packard Enterprise


--rOu3TDjgvxEHAGHDHwIoR03apojltv8SM--

--X1S6k1OXnDBv9lOh0eaK4rxduXi2rQ5fA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJX2PsOAAoJEHVMOpb5+LSMsA0QAIHMfTGCGDrTmqVL6Bi7/947
CYxgUUi235iAvh9DX+c50Oci+IrhRGKOiXOw7D4lj6MFYnhoBFKFlT/hioJoB+KU
iv+Kb9HfN8Ab0BITVhmFKOJ8vsELLI/gbOTBceDimVoEndlkYXeP1AnVL56Y1Dmr
17k5Yhy4pdKLvOt4NYTprKEnc+td1XtbZ/biRZhrCRrhLFgaQDB2gOYZmu0kny7X
Plp04Ts/fhsh8nh86ej1BeU4yg0XPexi9I+O8TSrzsG8LUSj3Ev1g/56rETzYeze
+QOzUhuMOEZLju+5Cix9tjPG7RPPQJ+k1SqNhE4q+YHwwOhx+Qa5RJRL92/hyoDk
cMBhDb5Mk/G2Y0CzvGYurfJxFny6h324NTjvUhNquTV5hXwy61e2qAkd0bOh2W3o
8RfwVp/xYoYeqbkcNcq+tyPSx6rC4MUC07jm28pn9McAyaLIBN63tuyAX9Hm8lAh
euxdnSG0EcFMA2PpFVAvIoTY+a7l3gEViQPYdjmDgVY3Sbq7cBZJv4mBcgsnI7oY
S2Jbd0y9oE7zv2lJL2xbt1Ylu3wR5+BHUWcg6nUrEHrNNJ/C3QRtoMEKA7MqP+l7
DgSIbUQZ5IFDZ5nNHUmGI6pz49PG+4k8aef2hoH3tzFJ1Az1u/qCSB5H0obSez9Q
2WwUHG3aQkkJwO5Rd0DS
=Wq/n
-----END PGP SIGNATURE-----

--X1S6k1OXnDBv9lOh0eaK4rxduXi2rQ5fA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
