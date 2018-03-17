Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4086B0003
	for <linux-mm@kvack.org>; Sat, 17 Mar 2018 00:35:32 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h89so2266631qtd.18
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 21:35:32 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id q84si1220059qke.105.2018.03.16.21.35.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 21:35:31 -0700 (PDT)
Subject: Re: [PATCH 08/14] mm/hmm: cleanup special vma handling (VM_SPECIAL)
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-9-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <44d08350-7035-a26c-d6c8-29b3dc3f99eb@nvidia.com>
Date: Fri, 16 Mar 2018 21:35:29 -0700
MIME-Version: 1.0
In-Reply-To: <20180316191414.3223-9-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 12:14 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Special vma (one with any of the VM_SPECIAL flags) can not be access by
> device because there is no consistent model accross device drivers on
> those vma and their backing memory.
>=20
> This patch directly use hmm_range struct for hmm_pfns_special() argument
> as it is always affecting the whole vma and thus the whole range.
>=20
> It also make behavior consistent after this patch both hmm_vma_fault()
> and hmm_vma_get_pfns() returns -EINVAL when facing such vma. Previously
> hmm_vma_fault() returned 0 and hmm_vma_get_pfns() return -EINVAL but
> both were filling the HMM pfn array with special entry.
>=20

Hi Jerome,

This seems correct.=20

<snip>

> @@ -486,6 +478,14 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  	return 0;
>  }
> =20
> +static void hmm_pfns_special(struct hmm_range *range)
> +{
> +	unsigned long addr =3D range->start, i =3D 0;
> +
> +	for (; addr < range->end; addr +=3D PAGE_SIZE, i++)
> +		range->pfns[i] =3D HMM_PFN_SPECIAL;
> +}

Silly nit: the above would read more naturally, like this:

	unsigned long addr, i =3D 0;

	for (addr =3D range->start; addr < range->end; addr +=3D PAGE_SIZE, i++)
		range->pfns[i] =3D HMM_PFN_SPECIAL;

Either way,

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA
