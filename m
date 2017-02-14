Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA116B038F
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:04:36 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id h56so135698321qtc.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 03:04:36 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id j8si164039pli.311.2017.02.14.03.04.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 Feb 2017 03:04:35 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH V2 2/2] powerpc/mm/autonuma: Switch ppc64 to its own implementeation of saved write
In-Reply-To: <1487050314-3892-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1487050314-3892-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1487050314-3892-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2017 22:04:33 +1100
Message-ID: <87y3x9kp8e.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
> diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> index 0735d5a8049f..8720a406bbbe 100644
> --- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> +++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> @@ -16,6 +16,9 @@
>  #include <asm/page.h>
>  #include <asm/bug.h>
>  
> +#ifndef __ASSEMBLY__
> +#include <linux/mmdebug.h>
> +#endif

I assume that's for the VM_BUG_ON() you add below. But if so wouldn't
the #include be better placed in book3s/64/pgtable.h also?

> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index fef738229a68..c684ef6cbd10 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -512,6 +512,32 @@ static inline pte_t pte_mkhuge(pte_t pte)
>  	return pte;
>  }
>  
> +#define pte_mk_savedwrite pte_mk_savedwrite
> +static inline pte_t pte_mk_savedwrite(pte_t pte)
> +{
> +	/*
> +	 * Used by Autonuma subsystem to preserve the write bit
> +	 * while marking the pte PROT_NONE. Only allow this
> +	 * on PROT_NONE pte
> +	 */
> +	VM_BUG_ON((pte_raw(pte) & cpu_to_be64(_PAGE_PRESENT | _PAGE_RWX | _PAGE_PRIVILEGED)) !=
> +		  cpu_to_be64(_PAGE_PRESENT | _PAGE_PRIVILEGED));
> +	return __pte(pte_val(pte) & ~_PAGE_PRIVILEGED);
> +}
> +


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
