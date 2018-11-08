Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 55E856B05D5
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:35:32 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id h13-v6so18185322wrq.3
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:35:32 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0081.outbound.protection.outlook.com. [104.47.0.81])
        by mx.google.com with ESMTPS id t129-v6si2893447wmf.86.2018.11.08.02.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Nov 2018 02:35:30 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 3/5] mm/hugetlb: Enable arch specific huge page size
 support for migration
Date: Thu, 8 Nov 2018 10:35:28 +0000
Message-ID: <20181108103517.7uy3rktr4gyrsh6q@capper-debian.cambridge.arm.com>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-4-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1540299721-26484-4-git-send-email-anshuman.khandual@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8D92419021B13244BD11F631F95A7F24@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <Anshuman.Khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Suzuki Poulose <Suzuki.Poulose@arm.com>, Punit Agrawal <Punit.Agrawal@arm.com>, Will Deacon <Will.Deacon@arm.com>, Steven Price <Steven.Price@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, nd <nd@arm.com>

On Tue, Oct 23, 2018 at 06:31:59PM +0530, Anshuman Khandual wrote:
> Architectures like arm64 have HugeTLB page sizes which are different than
> generic sizes at PMD, PUD, PGD level and implemented via contiguous bits.
> At present these special size HugeTLB pages cannot be identified through
> macros like (PMD|PUD|PGDIR)_SHIFT and hence chosen not be migrated.
>=20
> Enabling migration support for these special HugeTLB page sizes along wit=
h
> the generic ones (PMD|PUD|PGD) would require identifying all of them on a
> given platform. A platform specific hook can precisely enumerate all huge
> page sizes supported for migration. Instead of comparing against standard
> huge page orders let hugetlb_migration_support() function call a platform
> hook arch_hugetlb_migration_support(). Default definition for the platfor=
m
> hook maintains existing semantics which checks standard huge page order.
> But an architecture can choose to override the default and provide suppor=
t
> for a comprehensive set of huge page sizes.
>=20
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Reviewed-by: Steve Capper <steve.capper@arm.com>

> ---
>  include/linux/hugetlb.h | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 70bcd89..4cc3871 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -493,18 +493,29 @@ static inline pgoff_t basepage_index(struct page *p=
age)
>  extern int dissolve_free_huge_page(struct page *page);
>  extern int dissolve_free_huge_pages(unsigned long start_pfn,
>  				    unsigned long end_pfn);
> -static inline bool hugepage_migration_supported(struct hstate *h)
> -{
> +
>  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> +#ifndef arch_hugetlb_migration_supported
> +static inline bool arch_hugetlb_migration_supported(struct hstate *h)
> +{
>  	if ((huge_page_shift(h) =3D=3D PMD_SHIFT) ||
>  		(huge_page_shift(h) =3D=3D PUD_SHIFT) ||
>  			(huge_page_shift(h) =3D=3D PGDIR_SHIFT))
>  		return true;
>  	else
>  		return false;
> +}
> +#endif
>  #else
> +static inline bool arch_hugetlb_migration_supported(struct hstate *h)
> +{
>  	return false;
> +}
>  #endif
> +
> +static inline bool hugepage_migration_supported(struct hstate *h)
> +{
> +	return arch_hugetlb_migration_supported(h);
>  }
> =20
>  /*
> --=20
> 2.7.4
>=20
