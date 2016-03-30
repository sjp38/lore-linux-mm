Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CF0C46B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 10:05:51 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id 4so44299791pfd.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:05:51 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f63si6734418pfj.137.2016.03.30.07.05.50
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 07:05:50 -0700 (PDT)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [PATCH v4 3/8] mm: Add support for PUD-sized transparent
 hugepages
Date: Wed, 30 Mar 2016 14:05:29 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE04220B3FF@FMSMSX114.amr.corp.intel.com>
References: <1454242175-16870-1-git-send-email-matthew.r.wilcox@intel.com>
	<1454242175-16870-4-git-send-email-matthew.r.wilcox@intel.com>
 <20160329151710.6a256611fd28637d5c40ac3c@linux-foundation.org>
In-Reply-To: <20160329151710.6a256611fd28637d5c40ac3c@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

It's awful.  I have a v6 in the works which fixes a number of problems in v=
5, but there are about ten Kconfig options which the x86 code depends on.  =
And then ... yes, there's this bad definition of pud_t on ARM.  Arnd has a =
patch to fix that problem, Subject: [PATCH v2] [RFC] ARM: modify pgd_t defi=
nition for TRANSPARENT_HUGEPAGE_PUD.

But 0day is still pointing out other problems with the current patchset, so=
 I'd hold off on it until I get v6 posted if I were you.  Thanks for pickin=
g up x86-unify-native__get_and_clear-smp-case.patch

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Tuesday, March 29, 2016 3:17 PM
To: Wilcox, Matthew R
Cc: Matthew Wilcox; linux-mm@kvack.org; linux-nvdimm@ml01.01.org; linux-fsd=
evel@vger.kernel.org; linux-kernel@vger.kernel.org; x86@kernel.org
Subject: Re: [PATCH v4 3/8] mm: Add support for PUD-sized transparent hugep=
ages

On Sun, 31 Jan 2016 23:09:30 +1100 Matthew Wilcox <matthew.r.wilcox@intel.c=
om> wrote:

> From: Matthew Wilcox <willy@linux.intel.com>
>=20
> The current transparent hugepage code only supports PMDs.  This patch
> adds support for transparent use of PUDs with DAX.  It does not include
> support for anonymous pages.
>=20
> Most of this patch simply parallels the work that was done for huge PMDs.
> The only major difference is how the new ->pud_entry method in mm_walk
> works.  The ->pmd_entry method replaces the ->pte_entry method, whereas
> the ->pud_entry method works along with either ->pmd_entry or ->pte_entry=
.
> The pagewalk code takes care of locking the PUD before calling ->pud_walk=
,
> so handlers do not need to worry whether the PUD is stable.

Why is this patchset always so hard to compile :(

> ...
>
> --- a/include/linux/pfn_t.h
> +++ b/include/linux/pfn_t.h
> @@ -82,6 +82,13 @@ static inline pmd_t pfn_t_pmd(pfn_t pfn, pgprot_t pgpr=
ot)
>  {
>  	return pfn_pmd(pfn_t_to_pfn(pfn), pgprot);
>  }
> +
> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> +static inline pud_t pfn_t_pud(pfn_t pfn, pgprot_t pgprot)
> +{
> +	return pfn_pud(pfn_t_to_pfn(pfn), pgprot);
> +}
> +#endif
>  #endif
> =20
>  #ifdef __HAVE_ARCH_PTE_DEVMAP
> @@ -98,5 +105,6 @@ static inline bool pfn_t_devmap(pfn_t pfn)
>  }
>  pte_t pte_mkdevmap(pte_t pte);
>  pmd_t pmd_mkdevmap(pmd_t pmd);
> +pud_t pud_mkdevmap(pud_t pud);

arm allnoconfig:

In file included from kernel/memremap.c:17:
include/linux/pfn_t.h:107: error: 'pud_mkdevmap' declared as function retur=
ning an array
because it expands to

pgd_t pud_mkdevmap(pgd_t pud);

and

typedef unsigned long pgd_t[2];                                            =
    =20


Also the patch provides no implementation of pud_mkdevmap() so it's
obviously going to break bisection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
