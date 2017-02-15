Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB16C6B0408
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 16:46:29 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so199145900pfx.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:46:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p80si4911325pfk.56.2017.02.15.13.46.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 13:46:28 -0800 (PST)
Date: Wed, 15 Feb 2017 13:46:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] powerpc/mm/autonuma: Switch ppc64 to its own
 implementeation of saved write
Message-Id: <20170215134627.315dd734bd0000393a680cc9@linux-foundation.org>
In-Reply-To: <1486609259-6796-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1486609259-6796-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu,  9 Feb 2017 08:30:59 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> With this our protnone becomes a present pte with READ/WRITE/EXEC bit cleared.
> By default we also set _PAGE_PRIVILEGED on such pte. This is now used to help
> us identify a protnone pte that as saved write bit. For such pte, we will clear
> the _PAGE_PRIVILEGED bit. The pte still remain non-accessible from both user
> and kernel.

I don't see how these patches differ from the ones which are presently
in -mm.

It helps to have a [0/n] email for a patch series and to put a version
number in there as well.

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
> +#define pte_savedwrite pte_savedwrite
> +static inline bool pte_savedwrite(pte_t pte)
> +{
> +	/*
> +	 * Saved write ptes are prot none ptes that doesn't have
> +	 * privileged bit sit. We mark prot none as one which has
> +	 * present and pviliged bit set and RWX cleared. To mark
> +	 * protnone which used to have _PAGE_WRITE set we clear
> +	 * the privileged bit.
> +	 */
> +	return !(pte_raw(pte) & cpu_to_be64(_PAGE_RWX | _PAGE_PRIVILEGED));
> +}
> +
>  static inline pte_t pte_mkdevmap(pte_t pte)
>  {
>  	return __pte(pte_val(pte) | _PAGE_SPECIAL|_PAGE_DEVMAP);

arch/powerpc/include/asm/book3s/64/pgtable.h doesn't have
pte_mkdevmap().  What tree are you patching here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
