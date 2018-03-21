Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFFE56B0006
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 01:24:36 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g203so2455337qkb.3
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 22:24:36 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d129si2402566qkb.161.2018.03.20.22.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 22:24:35 -0700 (PDT)
Subject: Re: [PATCH 10/15] mm/hmm: do not differentiate between empty entry or
 missing directory v2
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-11-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <4b0da5bb-4e44-798c-f4dd-cabc93cfeb99@nvidia.com>
Date: Tue, 20 Mar 2018 22:24:34 -0700
MIME-Version: 1.0
In-Reply-To: <20180320020038.3360-11-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> There is no point in differentiating between a range for which there
> is not even a directory (and thus entries) and empty entry (pte_none()
> or pmd_none() returns true).
>=20
> Simply drop the distinction ie remove HMM_PFN_EMPTY flag and merge now
> duplicate hmm_vma_walk_hole() and hmm_vma_walk_clear() functions.
>=20
> Changed since v1:
>   - Improved comments
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h |  8 +++-----
>  mm/hmm.c            | 45 +++++++++++++++------------------------------
>  2 files changed, 18 insertions(+), 35 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 54d684fe3b90..cf283db22106 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -84,7 +84,6 @@ struct hmm;
>   * HMM_PFN_VALID: pfn is valid. It has, at least, read permission.
>   * HMM_PFN_WRITE: CPU page table has write permission set
>   * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned =
memory
> - * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
>   * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e.,=
 the
>   *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it sho=
uld not
>   *      be mirrored by a device, because the entry will never have HMM_P=
FN_VALID
> @@ -94,10 +93,9 @@ struct hmm;
>  #define HMM_PFN_VALID (1 << 0)
>  #define HMM_PFN_WRITE (1 << 1)
>  #define HMM_PFN_ERROR (1 << 2)
> -#define HMM_PFN_EMPTY (1 << 3)

Hi Jerome,

Nearly done with this one...see below for a bit more detail, but I think if=
 we did this:

    #define HMM_PFN_EMPTY (0)

...it would work out nicely.

> -#define HMM_PFN_SPECIAL (1 << 4)
> -#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 5)
> -#define HMM_PFN_SHIFT 6
> +#define HMM_PFN_SPECIAL (1 << 3)
> +#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 4)
> +#define HMM_PFN_SHIFT 5
> =20

<snip>

> @@ -438,7 +423,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  		pfns[i] =3D 0;
> =20
>  		if (pte_none(pte)) {
> -			pfns[i] =3D HMM_PFN_EMPTY;
> +			pfns[i] =3D 0;

This works, but why not keep HMM_PFN_EMPTY, and just define it as zero?
Symbols are better than raw numbers here.


>  			if (hmm_vma_walk->fault)
>  				goto fault;
>  			continue;
> @@ -489,8 +474,8 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> =20
>  fault:
>  		pte_unmap(ptep);
> -		/* Fault all pages in range */
> -		return hmm_vma_walk_clear(start, end, walk);
> +		/* Fault any virtual address we were ask to fault */

                                                     asked to fault

thanks,
--=20
John Hubbard
NVIDIA
