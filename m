Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA0A6B05D9
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:36:33 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id q26-v6so22368812ioi.21
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:36:33 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20056.outbound.protection.outlook.com. [40.107.2.56])
        by mx.google.com with ESMTPS id 190-v6si3011050itl.0.2018.11.08.02.36.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Nov 2018 02:36:31 -0800 (PST)
From: Steve Capper <Steve.Capper@arm.com>
Subject: Re: [PATCH V3 5/5] arm64/mm: Enable HugeTLB migration for contiguous
 bit HugeTLB pages
Date: Thu, 8 Nov 2018 10:36:27 +0000
Message-ID: <20181108103616.22z3imossjb5ffkw@capper-debian.cambridge.arm.com>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
 <1540299721-26484-6-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1540299721-26484-6-git-send-email-anshuman.khandual@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A03D333A85F0754B8AA6BA2F0663AD20@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <Anshuman.Khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Suzuki Poulose <Suzuki.Poulose@arm.com>, Punit Agrawal <Punit.Agrawal@arm.com>, Will Deacon <Will.Deacon@arm.com>, Steven Price <Steven.Price@arm.com>, Catalin Marinas <Catalin.Marinas@arm.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, nd <nd@arm.com>

On Tue, Oct 23, 2018 at 06:32:01PM +0530, Anshuman Khandual wrote:
> Let arm64 subscribe to the previously added framework in which architectu=
re
> can inform whether a given huge page size is supported for migration. Thi=
s
> just overrides the default function arch_hugetlb_migration_supported() an=
d
> enables migration for all possible HugeTLB page sizes on arm64. With this=
,
> HugeTLB migration support on arm64 now covers all possible HugeTLB option=
s.
>=20
>         CONT PTE    PMD    CONT PMD    PUD
>         --------    ---    --------    ---
> 4K:        64K      2M        32M      1G
> 16K:        2M     32M         1G
> 64K:        2M    512M        16G
>=20
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Reviewed-by: Steve Capper <steve.capper@arm.com>

> ---
>  arch/arm64/include/asm/hugetlb.h |  5 +++++
>  arch/arm64/mm/hugetlbpage.c      | 20 ++++++++++++++++++++
>  2 files changed, 25 insertions(+)
>=20
> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hu=
getlb.h
> index e73f685..656f70e 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -20,6 +20,11 @@
> =20
>  #include <asm/page.h>
> =20
> +#ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> +#define arch_hugetlb_migration_supported arch_hugetlb_migration_supporte=
d
> +extern bool arch_hugetlb_migration_supported(struct hstate *h);
> +#endif
> +
>  static inline pte_t huge_ptep_get(pte_t *ptep)
>  {
>  	return READ_ONCE(*ptep);
> diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
> index 21512ca..f3afdcf 100644
> --- a/arch/arm64/mm/hugetlbpage.c
> +++ b/arch/arm64/mm/hugetlbpage.c
> @@ -27,6 +27,26 @@
>  #include <asm/tlbflush.h>
>  #include <asm/pgalloc.h>
> =20
> +#ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
> +bool arch_hugetlb_migration_supported(struct hstate *h)
> +{
> +	size_t pagesize =3D huge_page_size(h);
> +
> +	switch (pagesize) {
> +#ifdef CONFIG_ARM64_4K_PAGES
> +	case PUD_SIZE:
> +#endif
> +	case PMD_SIZE:
> +	case CONT_PMD_SIZE:
> +	case CONT_PTE_SIZE:
> +		return true;
> +	}
> +	pr_warn("%s: unrecognized huge page size 0x%lx\n",
> +			__func__, pagesize);
> +	return false;
> +}
> +#endif
> +
>  int pmd_huge(pmd_t pmd)
>  {
>  	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
> --=20
> 2.7.4
>=20
