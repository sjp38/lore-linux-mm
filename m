Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 0A3036B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:52:10 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id d49so2021794eek.9
        for <linux-mm@kvack.org>; Mon, 01 Jul 2013 04:52:09 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH -V2 1/4] mm/cma: Move dma contiguous changes into a seperate config
In-Reply-To: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Mon, 01 Jul 2013 13:52:02 +0200
Message-ID: <xa1tzju6sdjx.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, m.szyprowski@samsung.com
Cc: linuxppc-dev@lists.ozlabs.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 28 2013, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> We want to use CMA for allocating hash page table and real mode area for
> PPC64. Hence move DMA contiguous related changes into a seperate config
> so that ppc64 can enable CMA without requiring DMA contiguous.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index 07abd9d..74b7c98 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -202,11 +202,10 @@ config DMA_SHARED_BUFFER
>  	  APIs extension; the file's descriptor can then be passed on to other
>  	  driver.
>=20=20
> -config CMA
> -	bool "Contiguous Memory Allocator"
> -	depends on HAVE_DMA_CONTIGUOUS && HAVE_MEMBLOCK
> -	select MIGRATION
> -	select MEMORY_ISOLATION
> +config DMA_CMA
> +	bool "DMA Contiguous Memory Allocator"
> +	depends on HAVE_DMA_CONTIGUOUS
> +	select CMA

Just to be on the safe side, I'd add

	depends on HAVE_MEMBLOCK

or change this so that it does not select CMA but depends on CMA.

>  	help
>  	  This enables the Contiguous Memory Allocator which allows drivers
>  	  to allocate big physically-contiguous blocks of memory for use with
> @@ -215,17 +214,7 @@ config CMA
>  	  For more information see <include/linux/dma-contiguous.h>.
>  	  If unsure, say "n".
>=20=20
> -if CMA
> -
> -config CMA_DEBUG
> -	bool "CMA debug messages (DEVELOPMENT)"
> -	depends on DEBUG_KERNEL
> -	help
> -	  Turns on debug messages in CMA.  This produces KERN_DEBUG
> -	  messages for every CMA call as well as various messages while
> -	  processing calls such as dma_alloc_from_contiguous().
> -	  This option does not affect warning and error messages.
> -
> +if  DMA_CMA
>  comment "Default contiguous memory area size:"
>=20=20
>  config CMA_SIZE_MBYTES

> diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguou=
s.h
> index 01b5c84..00141d3 100644
> --- a/include/linux/dma-contiguous.h
> +++ b/include/linux/dma-contiguous.h
> @@ -57,7 +57,7 @@ struct cma;
>  struct page;
>  struct device;
>=20=20
> -#ifdef CONFIG_CMA
> +#ifdef CONFIG_DMA_CMA
>=20=20
>  /*
>   * There is always at least global CMA area and a few optional device
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e742d06..26a5f81 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -477,3 +477,27 @@ config FRONTSWAP
>  	  and swap data is stored as normal on the matching swap device.
>=20=20
>  	  If unsure, say Y to enable frontswap.
> +
> +config CMA
> +	bool "Contiguous Memory Allocator"
> +	depends on HAVE_MEMBLOCK
> +	select MIGRATION
> +	select MEMORY_ISOLATION
> +	help
> +	  This enables the Contiguous Memory Allocator which allows other
> +	  subsystems to allocate big physically-contiguous blocks of memory.
> +	  CMA reserves a region of memory and allows only movable pages to
> +	  be allocated from it. This way, the kernel can use the memory for
> +	  pagecache and when a subsystem requests for contiguous area, the
> +	  allocated pages are migrated away to serve the contiguous request.
> +
> +	  If unsure, say "n".
> +
> +config CMA_DEBUG
> +	bool "CMA debug messages (DEVELOPMENT)"
> +	depends on DEBUG_KERNEL && CMA
> +	help
> +	  Turns on debug messages in CMA.  This produces KERN_DEBUG
> +	  messages for every CMA call as well as various messages while
> +	  processing calls such as dma_alloc_from_contiguous().
> +	  This option does not affect warning and error messages.
> --=20
> 1.8.1.2
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJR0W1iAAoJECBgQBJQdR/0GKsQAImkobDydf8Cz/SR7nE8B2Q6
LTA0n87AwwtMgLeZLIDQncksISI7bdduIsjaLD1zk3pcIu3z3RdPHEsoVZCgBaaN
vz+BMnLe6TEgP6HKI98QcrVyeZViJwMIKSNTPUmdByum7YxOWAKQH6rSNogTsZGE
nwPMU9ZklN9DaZtOpuOCP+6yxmuN5ENYnaIeKD9R+UOYbM6XfdlqX0Plmho5XZGd
KCaH8dmfa7DobiHVREl7+n6YVQpZPeavOywSPPNw76XiGT7KZaaTxMdNC+nQJH6C
SrUL8CDtcDei0OsIByE1BAYkhKXFsQRfWZkYG3YxpLmBVzuPaLjiMw0jasFlozSD
26C5Gqkfv80tD61jdfrWVnDta912CCPjfQ5L7gpJV+XN134otdnXB5Fw3JKTG9iW
2hl9KEufbmMgYqb+rkeAmkN4DHNdRuN5qPO5i2HfHXCGVW2++QBW1dW6rthV16VG
q0kWC+H8Q2wWQuSUW7/h3+o2jOSOlT6mN90/UoO2QU1SPIhgkBR+7ismHVJWFPRw
i+wF4WeBaGvzq2Lb7LqB9r3+P/VG1eGuinJYx3lV9TrMJRE0dmMYmXIFEE95aS1h
cWskahY1GMgVpjsdPWucjkXlu1BXR9/OjjO8REJ07PkM2ny+OcQ49qLgn7dFHs4+
9P3LkSEZPWNMGUpon1H8
=7mX6
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
