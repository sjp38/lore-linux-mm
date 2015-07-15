Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CFE0C6B02D0
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 11:24:04 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so1154471wib.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 08:24:04 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id ei6si490516wib.96.2015.07.15.08.24.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 Jul 2015 08:24:03 -0700 (PDT)
Message-ID: <55A67B0D.9030804@arm.com>
Date: Wed, 15 Jul 2015 16:23:57 +0100
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 17/36] arm64, thp: remove infrastructure for handling
 splitting PMDs
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com> <1436550130-112636-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-18-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/07/15 18:41, Kirill A. Shutemov wrote:
> With new refcounting we don't need to mark PMDs splitting. Let's drop
> code to handle this.
>
> pmdp_splitting_flush() is not needed too: on splitting PMD we will do
> pmdp_clear_flush() + set_pte_at(). pmdp_clear_flush() will do IPI as
> needed for fast_gup.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   arch/arm64/include/asm/pgtable.h |  9 ---------
>   arch/arm64/mm/flush.c            | 16 ----------------
>   2 files changed, 25 deletions(-)
>
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pg=
table.h
> index bd5db28324ba..37cdbf37934c 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -274,20 +274,11 @@ static inline pgprot_t mk_sect_prot(pgprot_t prot)
>
>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>   #define pmd_trans_huge(pmd)=09(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TAB=
LE_BIT))
> -#define pmd_trans_splitting(pmd)=09pte_special(pmd_pte(pmd))
> -#ifdef CONFIG_HAVE_RCU_TABLE_FREE
> -#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
> -struct vm_area_struct;
> -void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long addr=
ess,
> -=09=09=09  pmd_t *pmdp);
> -#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
> -#endif /* CONFIG_TRANSPARENT_HUGEPAGE */

Wouldn't this cause a build failure(Untested) ? We need to retain the last =
line,

#endif /* CONFIG_TRANSPARENT_HUGEPAGE */

isn't it ?


Thanks
Suzuki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
