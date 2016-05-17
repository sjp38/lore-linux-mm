Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id F10F56B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 10:14:37 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j8so10120176lfd.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 07:14:37 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id n81si26765561wma.66.2016.05.17.07.14.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 May 2016 07:14:36 -0700 (PDT)
Subject: Re: mm: Use phys_addr_t for reserve_bootmem_region arguments
References: <1463491221-10573-1-git-send-email-stefan.bader@canonical.com>
From: Stefan Bader <stefan.bader@canonical.com>
Message-ID: <573B273D.9040201@canonical.com>
Date: Tue, 17 May 2016 16:14:21 +0200
MIME-Version: 1.0
In-Reply-To: <1463491221-10573-1-git-send-email-stefan.bader@canonical.com>
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="dgDojonMO9BV1skAcx5KXpIMpB2kbtPXW"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kernel-team@lists.ubuntu.com, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dgDojonMO9BV1skAcx5KXpIMpB2kbtPXW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 17.05.2016 15:20, Stefan Bader wrote:
> Re-posting to a hopefully better suited audience. I hit this problem
> when trying to boot a i386 dom0 (PAE enabled) on a 64bit Xen host using=

> a config which would result in a reserved memory range starting at 4MB.=


Of course that ^ should be "starting at 4GB" not MB...

> Due to the usage of unsigned long as arguments for start address and
> length, this would wrap and actually mark the lower memory range starin=
g
> from 0 as reserved. Between kernel version 4.2 and 4.4 this somehow boo=
ts
> but starting with 4.4 the result is a panic and reboot.
>=20
> Not sure this special Xen case is the only one affected, but in general=

> it seems more correct to use phys_addr_t as the type for start and end
> as that is the type used in the memblock region definitions and those
> are 64bit (at least with PAE enabled).
>=20
> -Stefan
>=20
>=20
>=20
> From 1588a8b3983f63f8e690b91e99fe631902e38805 Mon Sep 17 00:00:00 2001
> From: Stefan Bader <stefan.bader@canonical.com>
> Date: Tue, 10 May 2016 19:05:16 +0200
> Subject: [PATCH] mm: Use phys_addr_t for reserve_bootmem_region argumen=
ts
>=20
> Since 92923ca the reserved bit is set on reserved memblock regions.
> However start and end address are passed as unsigned long. This is
> only 32bit on i386, so it can end up marking the wrong pages reserved
> for ranges at 4GB and above.
>=20
> This was observed on a 32bit Xen dom0 which was booted with initial
> memory set to a value below 4G but allowing to balloon in memory
> (dom0_mem=3D1024M for example). This would define a reserved bootmem
> region for the additional memory (for example on a 8GB system there was=

> a reverved region covering the 4GB-8GB range). But since the addresses
> were passed on as unsigned long, this was actually marking all pages
> from 0 to 4GB as reserved.
>=20
> Fixes: 92923ca "mm: meminit: only set page reserved in the memblock reg=
ion"
> Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
> Cc: <stable@kernel.org> # 4.2+
> ---
>  include/linux/mm.h | 2 +-
>  mm/page_alloc.c    | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b56ff72..4c1ff62 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1715,7 +1715,7 @@ extern void free_highmem_page(struct page *page);=

>  extern void adjust_managed_page_count(struct page *page, long count);
>  extern void mem_init_print_info(const char *str);
> =20
> -extern void reserve_bootmem_region(unsigned long start, unsigned long =
end);
> +extern void reserve_bootmem_region(phys_addr_t start, phys_addr_t end)=
;
> =20
>  /* Free the reserved page into the buddy system, so it gets managed. *=
/
>  static inline void __free_reserved_page(struct page *page)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c69531a..eb66f89 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -951,7 +951,7 @@ static inline void init_reserved_page(unsigned long=
 pfn)
>   * marks the pages PageReserved. The remaining valid pages are later
>   * sent to the buddy page allocator.
>   */
> -void __meminit reserve_bootmem_region(unsigned long start, unsigned lo=
ng end)
> +void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t e=
nd)
>  {
>  	unsigned long start_pfn =3D PFN_DOWN(start);
>  	unsigned long end_pfn =3D PFN_UP(end);
>=20



--dgDojonMO9BV1skAcx5KXpIMpB2kbtPXW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCgAGBQJXOydGAAoJEOhnXe7L7s6jeWMQAIhY/3WuKLX/aeEZaZClVpEV
0Ey8rGPWpm0Iq5DGSH8babctJlnl3XVYJMo2nrcJsFEVzLEnx8e2DtfOQE1i7d51
OnrZ5ql5OdRwUHSXg/Y2jJi1ZrDxhJug9FbnNj716r1bEJkhJ4VB4mCFgLJQ7079
h2xuLyla81DeWYJqlql6hgj+d6JerwpotcdbpcsJNiPWgtWe/YtKFnhnPL9qwmUK
2Jg+DWmWmQVVarsIwGqkAvIf9+EE+U7d5FLTUg3nbA6bUdA0/pvFz/amMNycMYVw
g2gG1FBNz4tJM8et4CE4Iwf04aygbKbOQ3zcIJBrKHqguxxmqgCe1GBqV4hGVVHi
1ZWQLC5weowp8TxKWDT59KQyE0hIdIkR5T/i7xawJiOJBxaPsYwsz8M6LE+9+P92
ONbvpWlRe9sGt+pxeTwemUeQxzvRJeTl5DoZozrrYHE78qmre1j7VNyZNO6KBoJX
IPkl+dO2QF/fxZWCFF4ye4yFAgifPTnExIHLWh28ybFxAsHiDRkGUjQy0pOX6ih/
sblsIaWwZlzDHyQkhylRrRv+IDsEdSi5k2yLva3muhY/d+3OF/bfrpUTRcPburBP
WqWOSSWr3o0XsFwjPVwvvE/3X+X1034vhGqR3u6qE++y2zhhzc7tko8Q9Y7pIq5F
LCLDQbZAASpz6KqhoVJ7
=GP0f
-----END PGP SIGNATURE-----

--dgDojonMO9BV1skAcx5KXpIMpB2kbtPXW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
