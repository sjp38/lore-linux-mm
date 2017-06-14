Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4AA83292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:09:13 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o21so2395467qtb.13
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:09:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f8si331284qkb.268.2017.06.14.09.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 09:09:12 -0700 (PDT)
Date: Wed, 14 Jun 2017 18:09:09 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] x86/mm: Provide pmdp_mknotpresent() helper
Message-ID: <20170614160909.GE5847@redhat.com>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
 <20170614135143.25068-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614135143.25068-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 14, 2017 at 04:51:41PM +0300, Kirill A. Shutemov wrote:
> We need an atomic way to make pmd page table entry not-present.
> This is required to implement pmdp_invalidate() that doesn't loose dirty
> or access bits.

What does the cmpxchg() loop achieves compared to xchg() and then
return the old value (potentially with the dirty bit set when it was
not before we called xchg)?

> index f5af95a0c6b8..576420df12b8 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1092,6 +1092,19 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
>  	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
>  }
>  
> +#ifndef pmdp_mknotpresent
> +#define pmdp_mknotpresent pmdp_mknotpresent
> +static inline void pmdp_mknotpresent(pmd_t *pmdp)
> +{
> +	pmd_t old, new;
> +
> +	{
> +		old = *pmdp;
> +		new = pmd_mknotpresent(old);
> +	} while (pmd_val(cmpxchg(pmdp, old, new)) != pmd_val(old));
> +}
> +#endif

Isn't it faster to do xchg(&xp->pmd, pmd_mknotpresent(pmd)) and have
the pmdp_invalidate caller can set the dirty bit in the page if it was
found set in the returned old pmd value (and skip the loop and cmpxchg)?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
