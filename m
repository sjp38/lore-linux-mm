Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0536B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 04:25:04 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n127so51935578qkf.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 01:25:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i29si3813505qtf.101.2017.03.01.01.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 01:25:03 -0800 (PST)
Subject: Re: [PATCH v6 2/4] mm: Add functions to support extra actions on swap
 in/out
References: <cover.1488232591.git.khalid.aziz@oracle.com>
 <4c4da87ff45b98e236cdfef66055b876074dabfb.1488232597.git.khalid.aziz@oracle.com>
From: Jerome Marchand <jmarchan@redhat.com>
Message-ID: <b8aae071-12ad-52ee-d97f-b273ae7c8838@redhat.com>
Date: Wed, 1 Mar 2017 10:24:50 +0100
MIME-Version: 1.0
In-Reply-To: <4c4da87ff45b98e236cdfef66055b876074dabfb.1488232597.git.khalid.aziz@oracle.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="3fdK7FiognWmN71ecarFblO7MOkPHav81"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org, davem@davemloft.net, arnd@arndb.de
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, lstoakes@gmail.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, mgorman@suse.de, hughd@google.com, vdavydov.dev@gmail.com, minchan@kernel.org, namit@vmware.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3fdK7FiognWmN71ecarFblO7MOkPHav81
Content-Type: multipart/mixed; boundary="wQcfFPeJenbmiIFrbJVXaBVSD47eJjtBm";
 protected-headers="v1"
From: Jerome Marchand <jmarchan@redhat.com>
To: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org,
 davem@davemloft.net, arnd@arndb.de
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, vbabka@suse.cz,
 dan.j.williams@intel.com, lstoakes@gmail.com, dave.hansen@linux.intel.com,
 hannes@cmpxchg.org, mgorman@suse.de, hughd@google.com,
 vdavydov.dev@gmail.com, minchan@kernel.org, namit@vmware.com,
 linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, sparclinux@vger.kernel.org,
 Khalid Aziz <khalid@gonehiking.org>
Message-ID: <b8aae071-12ad-52ee-d97f-b273ae7c8838@redhat.com>
Subject: Re: [PATCH v6 2/4] mm: Add functions to support extra actions on swap
 in/out
References: <cover.1488232591.git.khalid.aziz@oracle.com>
 <4c4da87ff45b98e236cdfef66055b876074dabfb.1488232597.git.khalid.aziz@oracle.com>
In-Reply-To: <4c4da87ff45b98e236cdfef66055b876074dabfb.1488232597.git.khalid.aziz@oracle.com>

--wQcfFPeJenbmiIFrbJVXaBVSD47eJjtBm
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/28/2017 07:35 PM, Khalid Aziz wrote:
> If a processor supports special metadata for a page, for example ADI
> version tags on SPARC M7, this metadata must be saved when the page is
> swapped out. The same metadata must be restored when the page is swappe=
d
> back in. This patch adds two new architecture specific functions -
> arch_do_swap_page() to be called when a page is swapped in,
> arch_unmap_one() to be called when a page is being unmapped for swap
> out.
>=20
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Khalid Aziz <khalid@gonehiking.org>

This looks much better than your original version.

Acked-by: Jerome Marchand <jmarchan@redhat.com>

Thanks,
Jerome

> ---
> v5:
> 	- Replaced set_swp_pte() function with new architecture
> 	  functions arch_do_swap_page() and arch_unmap_one()
>=20
>  include/asm-generic/pgtable.h | 16 ++++++++++++++++
>  mm/memory.c                   |  1 +
>  mm/rmap.c                     |  2 ++
>  3 files changed, 19 insertions(+)
>=20
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtabl=
e.h
> index 18af2bc..5764d8f 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -282,6 +282,22 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_=
b)
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif
> =20
> +#ifndef __HAVE_ARCH_DO_SWAP_PAGE
> +static inline void arch_do_swap_page(struct mm_struct *mm, unsigned lo=
ng addr,
> +				     pte_t pte, pte_t orig_pte)
> +{
> +
> +}
> +#endif
> +
> +#ifndef __HAVE_ARCH_UNMAP_ONE
> +static inline void arch_unmap_one(struct mm_struct *mm, unsigned long =
addr,
> +				  pte_t pte, pte_t orig_pte)
> +{
> +
> +}
> +#endif
> +
>  #ifndef __HAVE_ARCH_PGD_OFFSET_GATE
>  #define pgd_offset_gate(mm, addr)	pgd_offset(mm, addr)
>  #endif
> diff --git a/mm/memory.c b/mm/memory.c
> index 6bf2b47..b086c76 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2658,6 +2658,7 @@ int do_swap_page(struct vm_fault *vmf)
>  	if (pte_swp_soft_dirty(vmf->orig_pte))
>  		pte =3D pte_mksoft_dirty(pte);
>  	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
> +	arch_do_swap_page(vma->vm_mm, vmf->address, pte, vmf->orig_pte);
>  	vmf->orig_pte =3D pte;
>  	if (page =3D=3D swapcache) {
>  		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 91619fd..192c41a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1538,6 +1538,7 @@ static int try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  		swp_pte =3D swp_entry_to_pte(entry);
>  		if (pte_soft_dirty(pteval))
>  			swp_pte =3D pte_swp_mksoft_dirty(swp_pte);
> +		arch_unmap_one(mm, address, swp_pte, pteval);
>  		set_pte_at(mm, address, pte, swp_pte);
>  	} else if (PageAnon(page)) {
>  		swp_entry_t entry =3D { .val =3D page_private(page) };
> @@ -1571,6 +1572,7 @@ static int try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  		swp_pte =3D swp_entry_to_pte(entry);
>  		if (pte_soft_dirty(pteval))
>  			swp_pte =3D pte_swp_mksoft_dirty(swp_pte);
> +		arch_unmap_one(mm, address, swp_pte, pteval);
>  		set_pte_at(mm, address, pte, swp_pte);
>  	} else
>  		dec_mm_counter(mm, mm_counter_file(page));
>=20



--wQcfFPeJenbmiIFrbJVXaBVSD47eJjtBm--

--3fdK7FiognWmN71ecarFblO7MOkPHav81
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJYtpNiAAoJEHTzHJCtsuoCKRQH/jKRGrEsuxwR1cB6lW3R6o0g
TTprDDeNtwawyJFR9fO51Rcv1Y/3JXV3As8pG+jzeSOU+S8EISnRgTE3BDRYDexG
eA7V/B0pQn0Kkrt7QwdA6bTzZ+MWPpvvWE2x9JcIFGDIGpexwVRlJL4FRy97q7Q2
NgK2V+pSaUayRdWsLHY9yfeoE7ngemRO+O6Z6VGU8ipZAGnqQQCccQKfhf3BaP70
cade6iFSLOUOAseE/Czn3Us69QU4g5pFczHFJb1bpQdcEFT9EiRgNJqZQvnJT6ml
2EPXHwNzQhn+P5lgQjBGu0l+MHI42/YPUB1bAKAeBtUzK7UkotzHYOLnsk35TnU=
=ec1Z
-----END PGP SIGNATURE-----

--3fdK7FiognWmN71ecarFblO7MOkPHav81--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
