Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E48F6B000E
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 00:39:30 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q185so2409776qke.0
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 21:39:30 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id x14si625024qtj.69.2018.03.20.21.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 21:39:29 -0700 (PDT)
Subject: Re: [PATCH 15/15] mm/hmm: use device driver encoding for HMM pfn v2
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-16-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0a46cec4-3c39-bc2c-90f5-da33981cb8f2@nvidia.com>
Date: Tue, 20 Mar 2018 21:39:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180320020038.3360-16-jglisse@redhat.com>
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
> User of hmm_vma_fault() and hmm_vma_get_pfns() provide a flags array
> and pfn shift value allowing them to define their own encoding for HMM
> pfn that are fill inside the pfns array of the hmm_range struct. With
> this device driver can get pfn that match their own private encoding
> out of HMM without having to do any conversion.
>=20
> Changed since v1:
>   - Split flags and special values for clarification
>   - Improved comments and provide examples
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h | 130 +++++++++++++++++++++++++++++++++++++---------=
------
>  mm/hmm.c            |  85 +++++++++++++++++++---------------
>  2 files changed, 142 insertions(+), 73 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 0f7ea3074175..5d26e0a223d9 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -80,68 +80,145 @@
>  struct hmm;
> =20
>  /*
> + * hmm_pfn_flag_e - HMM flag enums
> + *
>   * Flags:
>   * HMM_PFN_VALID: pfn is valid. It has, at least, read permission.
>   * HMM_PFN_WRITE: CPU page table has write permission set
> + * HMM_PFN_DEVICE_PRIVATE: private device memory (ZONE_DEVICE)
> + *
> + * The driver provide a flags array, if driver valid bit for an entry is=
 bit
> + * 3 ie (entry & (1 << 3)) is true if entry is valid then driver must pr=
ovide
> + * an array in hmm_range.flags with hmm_range.flags[HMM_PFN_VALID] =3D=
=3D 1 << 3.
> + * Same logic apply to all flags. This is same idea as vm_page_prot in v=
ma
> + * except that this is per device driver rather than per architecture.

Hi Jerome,

If we go with this approach--and I hope not, I'll try to talk you down from=
 the
ledge, in a moment--then maybe we should add the following to the comments:=
=20

"There is only one bit ever set in each hmm_range.flags[entry]."=20

Or maybe we'll get pushback, that the code shows that already, but IMHO thi=
s is=20
strange way to do things (especially when there is a much easier way), and =
deserves=20
that extra bit of helpful documentation.

More below...

> + */
> +enum hmm_pfn_flag_e {
> +	HMM_PFN_VALID =3D 0,
> +	HMM_PFN_WRITE,
> +	HMM_PFN_DEVICE_PRIVATE,
> +	HMM_PFN_FLAG_MAX
> +};
> +
> +/*
> + * hmm_pfn_value_e - HMM pfn special value
> + *
> + * Flags:
>   * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned =
memory
> + * HMM_PFN_NONE: corresponding CPU page table entry is pte_none()
>   * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e.,=
 the
>   *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it sho=
uld not
>   *      be mirrored by a device, because the entry will never have HMM_P=
FN_VALID
>   *      set and the pfn value is undefined.
> - * HMM_PFN_DEVICE_PRIVATE: unaddressable device memory (ZONE_DEVICE)
> + *
> + * Driver provide entry value for none entry, error entry and special en=
try,
> + * driver can alias (ie use same value for error and special for instanc=
e). It
> + * should not alias none and error or special.
> + *
> + * HMM pfn value returned by hmm_vma_get_pfns() or hmm_vma_fault() will =
be:
> + * hmm_range.values[HMM_PFN_ERROR] if CPU page table entry is poisonous,
> + * hmm_range.values[HMM_PFN_NONE] if there is no CPU page table
> + * hmm_range.values[HMM_PFN_SPECIAL] if CPU page table entry is a specia=
l one
>   */
> -#define HMM_PFN_VALID (1 << 0)
> -#define HMM_PFN_WRITE (1 << 1)
> -#define HMM_PFN_ERROR (1 << 2)
> -#define HMM_PFN_SPECIAL (1 << 3)
> -#define HMM_PFN_DEVICE_PRIVATE (1 << 4)
> -#define HMM_PFN_SHIFT 5
> +enum hmm_pfn_value_e {
> +	HMM_PFN_ERROR,
> +	HMM_PFN_NONE,
> +	HMM_PFN_SPECIAL,
> +	HMM_PFN_VALUE_MAX
> +};

I can think of perhaps two good solid ways to get what you want, without
moving to what I consider an unnecessary excursion into arrays of flags.=20
If I understand correctly, you want to let each architecture
specify which bit to use for each of the above HMM_PFN_* flags.=20

The way you have it now, the code does things like this:

        cpu_flags & range->flags[HMM_PFN_WRITE]

but that array entry is mostly empty space, and it's confusing. It would
be nicer to see:

        cpu_flags & HMM_PFN_WRITE

...which you can easily do, by defining HMM_PFN_WRITE and friends in an
arch-specific header file.

The other way to make this more readable would be to use helper routines
similar to what the vm_pgprot* routines do:

static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
{
	return pgprot_modify(oldprot, vm_get_page_prot(vm_flags));
}

...but that's also unnecessary.

Let's just keep it simple, and go back to the bitmap flags!

thanks,
--=20
John Hubbard
NVIDIA
