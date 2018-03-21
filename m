Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1546B000D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 19:19:53 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m15so4117545qke.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 16:19:53 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z44si5059535qtz.273.2018.03.21.16.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 16:19:52 -0700 (PDT)
Subject: Re: [PATCH 15/15] mm/hmm: use device driver encoding for HMM pfn v2
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-16-jglisse@redhat.com>
 <0a46cec4-3c39-bc2c-90f5-da33981cb8f2@nvidia.com>
 <20180321155228.GD3214@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <98aaf798-12e4-ac52-3913-4fced8a28ce3@nvidia.com>
Date: Wed, 21 Mar 2018 16:19:50 -0700
MIME-Version: 1.0
In-Reply-To: <20180321155228.GD3214@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/21/2018 08:52 AM, Jerome Glisse wrote:
> On Tue, Mar 20, 2018 at 09:39:27PM -0700, John Hubbard wrote:
>> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> [...]
>=20

<snip>

>>
>> Let's just keep it simple, and go back to the bitmap flags!
>=20
> This simplify nouveau code and it is the reason why i did that patch.
> I am sure it can simplify NVidia uvm code, i can look into it if you
> want to give pointers. Idea here is that HMM can fill array with some-
> thing that match device driver internal format and avoid the conversion
> step from HMM format to driver format (saving CPU cycles and memory
> doing so). I am open to alternative that give the same end result.
>=20
> [Just because code is worth 2^32 words :)
>=20
> Without this patch:
>     int nouveau_do_fault(..., ulong addr, unsigned npages, ...)
>     {
>         uint64_t *hmm_pfns, *nouveau_pfns;
>=20
>         hmm_pfns =3D kmalloc(sizeof(uint64_t) * npages, GFP_KERNEL);
>         nouveau_pfns =3D kmalloc(sizeof(uint64_t) * npages, GFP_KERNEL);
>         hmm_vma_fault(..., hmm_pfns, ...);
>=20
>         for (i =3D 0; i < npages; ++i) {
>             nouveau_pfns[i] =3D nouveau_pfn_from_hmm_pfn(hmm_pfns[i]);
>         }
>         ...
>     }
>=20
> With this patch:
>     int nouveau_do_fault(..., ulong addr, unsigned npages, ...)
>     {
>         uint64_t *nouveau_pfns;
>=20
>         nouveau_pfns =3D kmalloc(sizeof(uint64_t) * npages, GFP_KERNEL);
>         hmm_vma_fault(..., nouveau_pfns, ...);
>=20
>         ...
>     }
>=20
> Benefit from this patch is quite obvious to me. Down the road with bit
> more integration between HMM and IOMMU/DMA this can turn into something
> directly ready for hardware consumptions.
>=20
> Note that you could argue that i can convert nouveau to use HMM format
> but this would not work, first because it requires a lot of changes in
> nouuveau, second because HMM do not have all the flags needed by the
> drivers (nor does HMM need them). HMM being the helper here, i feel it
> is up to HMM to adapt to drivers than the other way around.]
>=20

OK, if this simplifies Nouveau and potentially other drivers, then I'll=20
drop my earlier objections! Thanks for explaining what's going on, in detai=
l.

thanks,
--=20
John Hubbard
NVIDIA
