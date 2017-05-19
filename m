Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84BFD2806EA
	for <linux-mm@kvack.org>; Fri, 19 May 2017 11:55:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q125so61945325pgq.8
        for <linux-mm@kvack.org>; Fri, 19 May 2017 08:55:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f1si8420487pgc.109.2017.05.19.08.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 08:55:12 -0700 (PDT)
Subject: Re: [PATCH v5 01/11] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to
 bit 1
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-2-zi.yan@sent.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <76a36bee-0f1c-a2f4-6f5c-78394ac46ee4@intel.com>
Date: Fri, 19 May 2017 08:55:11 -0700
MIME-Version: 1.0
In-Reply-To: <20170420204752.79703-2-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On 04/20/2017 01:47 PM, Zi Yan wrote:
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

This description lacks a problem statement.  What's the problem?

	_PAGE_PSE is used to distinguish between a truly non-present
	(_PAGE_PRESENT=0) PMD, and a PMD which is undergoing a THP
	split and should be treated as present.

	But _PAGE_SWP_SOFT_DIRTY currently uses the _PAGE_PSE bit,
	which would cause confusion between one of those PMDs
	undergoing a THP split, and a soft-dirty PMD.

	Thus, we need to move the bit.

Does that capture it?

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  arch/x86/include/asm/pgtable_64.h    | 12 +++++++++---
>  arch/x86/include/asm/pgtable_types.h | 10 +++++-----
>  2 files changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> index 73c7ccc38912..770b5ae271ed 100644
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -157,15 +157,21 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
>  /*
>   * Encode and de-code a swap entry
>   *
> - * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0| <- bit number
> - * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit names
> - * | OFFSET (14->63) | TYPE (9-13)  |0|X|X|X| X| X|X|X|0| <- swp entry
> + * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2| 1|0| <- bit number
> + * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U| W|P| <- bit names
> + * | OFFSET (14->63) | TYPE (9-13)  |0|0|X|X| X| X|X|SD|0| <- swp entry

So, this diagram was incomplete before?  It should have had "SD" under
bit 7 for swap entries?

>   * G (8) is aliased and used as a PROT_NONE indicator for
>   * !present ptes.  We need to start storing swap entries above
>   * there.  We also need to avoid using A and D because of an
>   * erratum where they can be incorrectly set by hardware on
>   * non-present PTEs.
> + *
> + * SD (1) in swp entry is used to store soft dirty bit, which helps us
> + * remember soft dirty over page migration
> + *
> + * Bit 7 in swp entry should be 0 because pmd_present checks not only P,
> + * but also L and G.
>   */
>  #define SWP_TYPE_FIRST_BIT (_PAGE_BIT_PROTNONE + 1)
>  #define SWP_TYPE_BITS 5
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index df08535f774a..9a4ac934659e 100644
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
