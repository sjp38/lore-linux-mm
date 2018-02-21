Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E221F6B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:51:28 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j3so1230966wrb.18
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 05:51:28 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id a53si9104593wra.252.2018.02.21.05.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 05:51:27 -0800 (PST)
Date: Wed, 21 Feb 2018 14:51:19 +0100
From: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: Re: [PATCH 1/6] powerpc/mm/32: Use pfn_valid to check if pointer is
 in RAM
Message-ID: <20180221135119.d3qgvdck5yruomi7@latitude>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
 <20180220161424.5421-2-j.neuschaefer@gmx.net>
 <0d14cb2c-dd00-d258-cb15-302b2a9d684f@c-s.fr>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jgd5mu54dmgravdc"
Content-Disposition: inline
In-Reply-To: <0d14cb2c-dd00-d258-cb15-302b2a9d684f@c-s.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christophe leroy <christophe.leroy@c-s.fr>
Cc: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Balbir Singh <bsingharora@gmail.com>, Guenter Roeck <linux@roeck-us.net>


--jgd5mu54dmgravdc
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Christophe,

On Tue, Feb 20, 2018 at 06:45:09PM +0100, christophe leroy wrote:
[...]
> > -	if (slab_is_available() && (p < virt_to_phys(high_memory)) &&
> > +	if (slab_is_available() && pfn_valid(__phys_to_pfn(p)) &&
>=20
> I'm not sure this is equivalent:
>=20
> high_memory =3D (void *) __va(max_low_pfn * PAGE_SIZE);
> #define ARCH_PFN_OFFSET		((unsigned long)(MEMORY_START >> PAGE_SHIFT))
> #define pfn_valid(pfn)		((pfn) >=3D ARCH_PFN_OFFSET && (pfn) < max_mapnr)
> set_max_mapnr(max_pfn);
>=20
> So in the current implementation it checks against max_low_pfn while your
> patch checks against max_pfn
>=20
> 	max_low_pfn =3D max_pfn =3D memblock_end_of_DRAM() >> PAGE_SHIFT;
> #ifdef CONFIG_HIGHMEM
> 	max_low_pfn =3D lowmem_end_addr >> PAGE_SHIFT;
> #endif

Good point, I haven't considered CONFIG_HIGHMEM before.

As far as I understand it, in the non-CONFIG_HIGHMEM case:

  - max_low_pfn is set to the same value as max_pfn, so the ioremap
    check should detect the same PFNs as RAM.

and with CONFIG_HIGHMEM:

  - max_low_pfn is set to lowmem_end_addr >> PAGE_SHIFT
  - but max_pfn isn't

So, I think you're right.


While looking through arch/powerpc/mm, I noticed that there's a
page_is_ram function, which simply uses the memblocks directly, on
PPC32. It seems like a good candidate for the RAM check in
__ioremap_caller, except that there's this code, which apparently
trashes memblock 0 completely on non-CONFIG_NEED_MULTIPLE_NODES:

  https://elixir.bootlin.com/linux/v4.16-rc2/source/arch/powerpc/mm/mem.c#L=
223


Thanks,
Jonathan Neusch=C3=A4fer

--jgd5mu54dmgravdc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJajXlOAAoJEAgwRJqO81/bA04P/A5eYOetCVfwe5i8CzVCzswi
syAI04l5dw0ka8DJ6Vn3mGtDFbw+uDpOmZ4bwyebvvmr4nMnbJP6DLrYgOfs6Jz1
aczZBbk1Jf/bO28zSvfZtrq1cfw5YI1RF54d6mJsjzC+oDpdCvTAwB03Feq1MbAu
QYO6tilAaCnJyQ8vvxRL309oh1/jiYSfXga0pyH3KkjxWlPYAK7BrSW4IuWsp8Yw
7mDJFnWuhiVxRMBgnvlXt4ykz6GLACM/mKaT/mWGtsvh/mTt2r+jk07QnnqX+Tvb
V9iiXMof5TAM+nLlI8oLgxsXTFbu//QJMiNa6s6NWv6WMA3/Dq2HlWf8X4lj6TXx
dmNNrcGWkVdCGdZKliwS+jAU0kMZ3cz2VCcLQH+rWJgCutQpbpF1I+J9Lv3vg7cH
0lcRcsmfnBF5JGKScvjaHjCqH2M98JDSER5xU9B2ff9dZn5db6zeN/804OD7htX3
nS//MoDImnbeur7ryfthSLgrVv5te78mv1aA/PLclGnveo5C/lrxWU1DjmBEmxW/
h6o5JU6hV1To0teV47Cu9QLPPebpmM0iVR45TK4Y9u5DjdmvpYLYgnTsxtgXJGkW
LX5tE060VtbeKZIA0N2VxKpwp+t+osCRPch+bPLlVjlS6Bo/gTtAHO5w9ldqDqf/
UGnCm3zfS2X0jWMdxvRc
=afR/
-----END PGP SIGNATURE-----

--jgd5mu54dmgravdc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
