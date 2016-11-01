Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8347F6B02A6
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 05:11:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p16so96335215qta.5
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 02:11:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d21si20881059qtd.2.2016.11.01.02.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 02:11:03 -0700 (PDT)
Subject: Re: [PATCH] swapfile: fix memory corruption via malformed swapfile
References: <1477949533-2509-1-git-send-email-jann@thejh.net>
From: Jerome Marchand <jmarchan@redhat.com>
Message-ID: <11480a7c-294a-acdd-0963-727c8d61d5a6@redhat.com>
Date: Tue, 1 Nov 2016 10:10:58 +0100
MIME-Version: 1.0
In-Reply-To: <1477949533-2509-1-git-send-email-jann@thejh.net>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="QDumFIe2PgPIWbQlm4gMdlcOdPRltopGd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QDumFIe2PgPIWbQlm4gMdlcOdPRltopGd
Content-Type: multipart/mixed; boundary="Asq5vdATKDnKImkos8KrHS4OTPcrW0CrV";
 protected-headers="v1"
From: Jerome Marchand <jmarchan@redhat.com>
To: Jann Horn <jann@thejh.net>, Andrew Morton <akpm@linux-foundation.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Message-ID: <11480a7c-294a-acdd-0963-727c8d61d5a6@redhat.com>
Subject: Re: [PATCH] swapfile: fix memory corruption via malformed swapfile
References: <1477949533-2509-1-git-send-email-jann@thejh.net>
In-Reply-To: <1477949533-2509-1-git-send-email-jann@thejh.net>

--Asq5vdATKDnKImkos8KrHS4OTPcrW0CrV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/31/2016 10:32 PM, Jann Horn wrote:
> When root activates a swap partition whose header has the wrong endiann=
ess,
> nr_badpages elements of badpages are swabbed before nr_badpages has bee=
n
> checked, leading to a buffer overrun of up to 8GB.
>=20
> This normally is not a security issue because it can only be exploited =
by
> root (more specifically, a process with CAP_SYS_ADMIN or the ability to=

> modify a swap file/partition), and such a process can already e.g. modi=
fy
> swapped-out memory of any other userspace process on the system.
>=20
> Testcase for reproducing the bug (must be run as root, should crash you=
r
> kernel):
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/swap.h>
> #include <limits.h>
> #include <err.h>
> #include <string.h>
> #include <stdio.h>
>=20
> #define PAGE_SIZE 4096
> #define __u32 unsigned int
>=20
>=20
> // from include/linux/swap.h
> union swap_header {
>   struct {
>     char reserved[PAGE_SIZE - 10];
>     char magic[10];     /* SWAP-SPACE or SWAPSPACE2 */
>   } magic;
>   struct {
>     char    bootbits[1024]; /* Space for disklabel etc. */
>     __u32   version;
>     __u32   last_page;
>     __u32   nr_badpages;
>     unsigned char sws_uuid[16];
>     unsigned char sws_volume[16];
>     __u32   padding[117];
>     __u32   badpages[1];
>   } info;
> };
>=20
> int main(void) {
>   char file[] =3D "/tmp/swapfile.XXXXXX";
>   int file_fd =3D mkstemp(file);
>   if (file_fd =3D=3D -1)
>     err(1, "mkstemp");
>   if (ftruncate(file_fd, PAGE_SIZE))
>     err(1, "ftruncate");
>   union swap_header swap_header =3D {
>     .info =3D {
>       .version =3D __builtin_bswap32(1),
>       .nr_badpages =3D __builtin_bswap32(INT_MAX)
>     }
>   };
>   memcpy(swap_header.magic.magic, "SWAPSPACE2", 10);
>   if (write(file_fd, &swap_header, sizeof(swap_header)) !=3D
>       sizeof(swap_header))
>     err(1, "write");
>=20
>   // not because the attack needs it, just in case you forgot to
>   // sync yourself before crashing your machine
>   sync();
>=20
>   // now die
>   if (swapon(file, 0))
>     err(1, "swapon");
>   puts("huh, we survived");
>   if (swapoff(file))
>     err(1, "swapoff");
>   unlink(file);
> }
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jann@thejh.net>
> ---
>  mm/swapfile.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 2210de290b54..f30438970cd1 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2224,6 +2224,8 @@ static unsigned long read_swap_header(struct swap=
_info_struct *p,
>  		swab32s(&swap_header->info.version);
>  		swab32s(&swap_header->info.last_page);
>  		swab32s(&swap_header->info.nr_badpages);
> +		if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
> +			return 0;
>  		for (i =3D 0; i < swap_header->info.nr_badpages; i++)
>  			swab32s(&swap_header->info.badpages[i]);
>  	}
>=20

Nice catch!

Acked-by: Jerome Marchand <jmarchan@redhat.com>




--Asq5vdATKDnKImkos8KrHS4OTPcrW0CrV--

--QDumFIe2PgPIWbQlm4gMdlcOdPRltopGd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJYGFwiAAoJEHTzHJCtsuoCmfoH/As6Y0VkEsnjltCet41mS0yl
EcnuasLecAGtJM5nBkiCcdBuyD74n78B+CpDFtaRZsk5de8VPu6J40G2l0v4RC2P
Ao4NgZyo/d4gOi5AxwzlPa6WudhmiSS69dMdXOVOo1oP27KfhWESmwvbCgVbILHU
oisjFX2FHGbb6M0odLj7xWWh0N8be6eJYKxxSTVdKFX+4TaXTr2L0175pDRggRG7
G1WnGkXdnruYFkHMNdPlh48Vt2NxouVzwC6duTy+xPQGA3DoTJkwwStzJjxOhbym
pTCkcm4WKO2Gjh17CN18cbcfw2m+fvAJYOHHmtzdOFtk5ZOlZFhmW/nJp5ORxss=
=m1kU
-----END PGP SIGNATURE-----

--QDumFIe2PgPIWbQlm4gMdlcOdPRltopGd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
