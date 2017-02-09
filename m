Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B40C6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 10:08:05 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id y140so6180174oie.2
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 07:08:05 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0106.outbound.protection.outlook.com. [104.47.32.106])
        by mx.google.com with ESMTPS id n187si4742265oih.239.2017.02.09.07.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 07:08:04 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v3 04/14] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to
 bit 1
Date: Thu, 9 Feb 2017 09:07:56 -0600
Message-ID: <A8EB8880-24C8-4134-96B7-BB6D5027AC60@cs.rutgers.edu>
In-Reply-To: <20170209091458.GA15649@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-5-zi.yan@sent.com>
 <20170209091458.GA15649@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_A5B4B13E-8536-4F97-B856-4812B7FBFA18_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>

--=_MailMate_A5B4B13E-8536-4F97-B856-4812B7FBFA18_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 9 Feb 2017, at 3:14, Naoya Horiguchi wrote:

> On Sun, Feb 05, 2017 at 11:12:42AM -0500, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid
>> false negative return when it races with thp spilt
>> (during which _PAGE_PRESENT is temporary cleared.) I don't think that
>> dropping _PAGE_PSE check in pmd_present() works well because it can
>> hurt optimization of tlb handling in thp split.
>> In the current kernel, bits 1-4 are not used in non-present format
>> since commit 00839ee3b299 ("x86/mm: Move swap offset/type up in PTE to=

>> work around erratum"). So let's move _PAGE_SWP_SOFT_DIRTY to bit 1.
>> Bit 7 is used as reserved (always clear), so please don't use it for
>> other purpose.
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> ChangeLog v3:
>> - Move _PAGE_SWP_SOFT_DIRTY to bit 1, it was placed at bit 6. Because
>> some CPUs might accidentally set bit 5 or 6.
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>
> More documenting will be helpful, could you do like follows?

Sure. Thanks for helping.

>
> Thanks,
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Sun, 5 Feb 2017 11:12:42 -0500
> Subject: [PATCH] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1=

>
> pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid
> false negative return when it races with thp spilt
> (during which _PAGE_PRESENT is temporary cleared.) I don't think that
> dropping _PAGE_PSE check in pmd_present() works well because it can
> hurt optimization of tlb handling in thp split.
> In the current kernel, bits 1-4 are not used in non-present format
> since commit 00839ee3b299 ("x86/mm: Move swap offset/type up in PTE to
> work around erratum"). So let's move _PAGE_SWP_SOFT_DIRTY to bit 1.
> Bit 7 is used as reserved (always clear), so please don't use it for
> other purpose.
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  arch/x86/include/asm/pgtable_64.h    | 12 +++++++++---
>  arch/x86/include/asm/pgtable_types.h | 10 +++++-----
>  2 files changed, 14 insertions(+), 8 deletions(-)
>
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/p=
gtable_64.h
> index 73c7ccc38912..07c98c85cc96 100644
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -157,15 +157,21 @@ static inline int pgd_large(pgd_t pgd) { return 0=
; }
>  /*
>   * Encode and de-code a swap entry
>   *
> - * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0| <- bit numbe=
r
> - * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit names=

> - * | OFFSET (14->63) | TYPE (9-13)  |0|X|X|X| X| X|X|X|0| <- swp entry=

> + * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2| 1|0| <- bit numb=
er
> + * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U| W|P| <- bit name=
s
> + * | OFFSET (14->63) | TYPE (9-13)  |0|0|X|X| X| X|X|SD|0| <- swp entr=
y
>   *
>   * G (8) is aliased and used as a PROT_NONE indicator for
>   * !present ptes.  We need to start storing swap entries above
>   * there.  We also need to avoid using A and D because of an
>   * erratum where they can be incorrectly set by hardware on
>   * non-present PTEs.
> + *
> + * SD (1) in swp entry is used to store soft dirty bit, which helps us=

> + * remember soft dirty over page migration.
> + *
> + * Bit 7 in swp entry should be 0 because pmd_present checks not only =
P,
> + * but G.
>   */
>  #define SWP_TYPE_FIRST_BIT (_PAGE_BIT_PROTNONE + 1)
>  #define SWP_TYPE_BITS 5
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/as=
m/pgtable_types.h
> index 8b4de22d6429..3695abd58ef6 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -97,15 +97,15 @@
>  /*
>   * Tracking soft dirty bit when a page goes to a swap is tricky.
>   * We need a bit which can be stored in pte _and_ not conflict
> - * with swap entry format. On x86 bits 6 and 7 are *not* involved
> - * into swap entry computation, but bit 6 is used for nonlinear
> - * file mapping, so we borrow bit 7 for soft dirty tracking.
> + * with swap entry format. On x86 bits 1-4 are *not* involved
> + * into swap entry computation, but bit 7 is used for thp migration,
> + * so we borrow bit 1 for soft dirty tracking.
>   *
>   * Please note that this bit must be treated as swap dirty page
> - * mark if and only if the PTE has present bit clear!
> + * mark if and only if the PTE/PMD has present bit clear!
>   */
>  #ifdef CONFIG_MEM_SOFT_DIRTY
> -#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
> +#define _PAGE_SWP_SOFT_DIRTY	_PAGE_RW
>  #else
>  #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
>  #endif
> -- =

> 2.7.4


--
Best Regards
Yan Zi

--=_MailMate_A5B4B13E-8536-4F97-B856-4812B7FBFA18_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYnIXMAAoJEEGLLxGcTqbMCvoH/3Q4pBypQF0iKmapJ0dHlavV
euz08mB8HaBtSkRIrYl7zlaDBDesM1nm07gYXZHOFwBBRSljWf+Osy557y0f29Pu
NyLHMgDahTT95U2SOfSyD+LArdP9rTLl9djsBUKDrzGaM+ljIGFia3WLN563KqRq
PczDNB49VhPRc/bsQaA39an8OK9hd0k7uXS2O7b61N5omXqGgaJ43lzxaynhpaZ8
IANA22IRSF21tltJlj3iqL2Wa9UwMrbxF0uM8l/heS0QzC/Psc5UnHidm5w7gXLY
rMiPeNe+9VQJBy4lNBq3GoPjDELm8crCLi1B8N2G4o4JpkkhGN0dIiwrJYEnqSY=
=HqSG
-----END PGP SIGNATURE-----

--=_MailMate_A5B4B13E-8536-4F97-B856-4812B7FBFA18_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
