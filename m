Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFBD6B025E
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 14:38:51 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id a132so13528005oih.22
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 11:38:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t6si8301517ott.234.2017.11.14.11.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 11:38:50 -0800 (PST)
Message-ID: <1510688325.1080.1.camel@redhat.com>
Subject: Re: [PATCH 04/30] x86, kaiser: disable global pages by default with
 KAISER
From: Rik van Riel <riel@redhat.com>
Date: Tue, 14 Nov 2017 14:38:45 -0500
In-Reply-To: <20171110193105.02A90543@viggo.jf.intel.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
	 <20171110193105.02A90543@viggo.jf.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-5Ku5CO9A2Ypi3TwbeLpD"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, bp@suse.de, tglx@linutronix.de, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


--=-5Ku5CO9A2Ypi3TwbeLpD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-11-10 at 11:31 -0800, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>=20
> Global pages stay in the TLB across context switches.=C2=A0=C2=A0Since al=
l
> contexts
> share the same kernel mapping, these mappings are marked as global
> pages
> so kernel entries in the TLB are not flushed out on a context switch.
>=20
> But, even having these entries in the TLB opens up something that an
> attacker can use [1].
>=20
> That means that even when KAISER switches page tables on return to
> user
> space the global pages would stay in the TLB cache.
>=20
> Disable global pages so that kernel TLB entries can be flushed before
> returning to user space. This way, all accesses to kernel addresses
> from
> userspace result in a TLB miss independent of the existence of a
> kernel
> mapping.
>=20
> Replace _PAGE_GLOBAL by __PAGE_KERNEL_GLOBAL and keep _PAGE_GLOBAL
> available so that it can still be used for a few selected kernel
> mappings
> which must be visible to userspace, when KAISER is enabled, like the
> entry/exit code and data.

Nice changelog.

Why am I pointing this out?

> +++ b/arch/x86/include/asm/pgtable_types.h	2017-11-10
> 11:22:06.626244956 -0800
> @@ -179,8 +179,20 @@ enum page_cache_mode {
> =C2=A0#define PAGE_READONLY_EXEC	__pgprot(_PAGE_PRESENT |
> _PAGE_USER |	\
> =C2=A0					=C2=A0_PAGE_ACCESSED)
> =C2=A0
> +/*
> + * Disable global pages for anything using the default
> + * __PAGE_KERNEL* macros.=C2=A0=C2=A0PGE will still be enabled
> + * and _PAGE_GLOBAL may still be used carefully.
> + */
> +#ifdef CONFIG_KAISER
> +#define __PAGE_KERNEL_GLOBAL	0
> +#else
> +#define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
> +#endif
> +				=09

The comment above could use a little more info
on why things are done that way, though :)

--=20
All rights reversed
--=-5Ku5CO9A2Ypi3TwbeLpD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJaC0ZFAAoJEM553pKExN6D2d8H/1Njx1gfgFj9TB8cjwfMGYMA
ZRSexbV1V+UqQT5bJ3MS/Qkceusj8iCI6uvswYOMvdHkUw4j5SWVoYrisSb2L6eI
DfdTjxD7oU2nGj7rGyCE04u0VpLoZMpPULDNiLahGye2yPsrRo1dduzwL0Qqtxmn
5OOy7v3FCIwewoV6ApKulTEmueZISdpm62oOpylJ753+vXCn9rozwPOXWsuSR/tC
VaU+5bD6+8KUi8LCEt+ZlJlUf9hkjt3mdp2dYKCVq1BZFDEGmUO50SvvvZ5lYws/
faIF5bgGi+LOdVsy+9ZBBv+HEGHt6tXmrsoEGvtm4GOlSbjoU/0WYaXifx9pz04=
=/HyD
-----END PGP SIGNATURE-----

--=-5Ku5CO9A2Ypi3TwbeLpD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
