Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 461B26B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 14:23:51 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m1so5270583pgd.13
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 11:23:51 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o9si3729291pgi.274.2017.03.24.11.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 11:23:50 -0700 (PDT)
Message-ID: <1490379805.2733.133.camel@linux.intel.com>
Subject: Re: [PATCH v4 01/11] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7
 to bit 1
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Fri, 24 Mar 2017 11:23:25 -0700
In-Reply-To: <20170313154507.3647-2-zi.yan@sent.com>
References: <20170313154507.3647-1-zi.yan@sent.com>
	 <20170313154507.3647-2-zi.yan@sent.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On Mon, 2017-03-13 at 11:44 -0400, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
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
> A arch/x86/include/asm/pgtable_64.hA A A A | 12 +++++++++---
> A arch/x86/include/asm/pgtable_types.h | 10 +++++-----
> A 2 files changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> index 73c7ccc38912..a5c4fc62e078 100644
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -157,15 +157,21 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
> A /*
> A  * Encode and de-code a swap entry
> A  *
> - * |A A A A A ...A A A A A A A A A A A A | 11| 10|A A 9|8|7|6|5| 4| 3|2|1|0| <- bit number
> - * |A A A A A ...A A A A A A A A A A A A |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit names
> - * | OFFSET (14->63) | TYPE (9-13)A A |0|X|X|X| X| X|X|X|0| <- swp entry
> + * |A A A A A ...A A A A A A A A A A A A | 11| 10|A A 9|8|7|6|5| 4| 3|2| 1|0| <- bit number
> + * |A A A A A ...A A A A A A A A A A A A |SW3|SW2|SW1|G|L|D|A|CD|WT|U| W|P| <- bit names
> + * | OFFSET (14->63) | TYPE (9-13)A A |0|0|X|X| X| X|X|SD|0| <- swp entry
> A  *
> A  * G (8) is aliased and used as a PROT_NONE indicator for
> A  * !present ptes.A A We need to start storing swap entries above
> A  * there.A A We also need to avoid using A and D because of an
> A  * erratum where they can be incorrectly set by hardware on
> A  * non-present PTEs.
> + *
> + * SD (1) in swp entry is used to store soft dirty bit, which helps us
> + * remember soft dirty over page migration
> + *
> + * Bit 7 in swp entry should be 0 because pmd_present checks not only P,
> + * but also G.

but also L and G.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
