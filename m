Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3A46B0270
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 19:10:37 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u144so8704424pgb.0
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 16:10:37 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n65si2054439pfi.201.2017.10.06.16.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 16:10:36 -0700 (PDT)
Subject: Re: [PATCHv2 1/2] mm: Introduce wrappers to access mm->nr_ptes
References: <20171005101442.49555-1-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7e476fd2-5818-c395-cdf2-00b5229c1a73@intel.com>
Date: Fri, 6 Oct 2017 16:10:31 -0700
MIME-Version: 1.0
In-Reply-To: <20171005101442.49555-1-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On 10/05/2017 03:14 AM, Kirill A. Shutemov wrote:
> +++ b/arch/sparc/mm/hugetlbpage.c
> @@ -396,7 +396,7 @@ static void hugetlb_free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
>  
>  	pmd_clear(pmd);
>  	pte_free_tlb(tlb, token, addr);
> -	atomic_long_dec(&tlb->mm->nr_ptes);
> +	mm_dec_nr_ptes(tlb->mm);
>  }

If we're going to go replace all of these, I wonder if we should start
doing it more generically.

	mm_dec_nr_pgtable(PGTABLE_PTE, tlb->mm)

or even:

	mm_dec_nr_pgtable(PGTABLE_LEVEL1, tlb->mm)

Instead of having a separate batch of functions for each level.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
