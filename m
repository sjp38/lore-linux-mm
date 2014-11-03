Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3E50F6B0071
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 14:01:39 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id a1so11854450wgh.34
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 11:01:38 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id i2si9424433wiy.55.2014.11.03.11.01.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 11:01:38 -0800 (PST)
Date: Mon, 3 Nov 2014 20:01:26 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 5/7] x86, mm, pat: Refactor !pat_enabled handling
In-Reply-To: <1414450545-14028-6-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1411031957330.5308@nanos>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com> <1414450545-14028-6-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com

On Mon, 27 Oct 2014, Toshi Kani wrote:
> diff --git a/arch/x86/mm/iomap_32.c b/arch/x86/mm/iomap_32.c
> index ee58a0b..96aa8bf 100644
> --- a/arch/x86/mm/iomap_32.c
> +++ b/arch/x86/mm/iomap_32.c
> @@ -70,29 +70,23 @@ void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
>  	return (void *)vaddr;
>  }
>  
> -/*
> - * Map 'pfn' using protections 'prot'
> - */
> -#define __PAGE_KERNEL_WC	(__PAGE_KERNEL | \
> -				 cachemode2protval(_PAGE_CACHE_MODE_WC))
> -
>  void __iomem *
>  iomap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
>  {
>  	/*
> -	 * For non-PAT systems, promote PAGE_KERNEL_WC to PAGE_KERNEL_UC_MINUS.
> -	 * PAGE_KERNEL_WC maps to PWT, which translates to uncached if the
> -	 * MTRR is UC or WC.  UC_MINUS gets the real intention, of the
> -	 * user, which is "WC if the MTRR is WC, UC if you can't do that."
> +	 * For non-PAT systems, translate non-WB request to UC- just in
> +	 * case the caller set the PWT bit to prot directly without using
> +	 * pgprot_writecombine(). UC- translates to uncached if the MTRR
> +	 * is UC or WC. UC- gets the real intention, of the user, which is
> +	 * "WC if the MTRR is WC, UC if you can't do that."
>  	 */
> -	if (!pat_enabled && pgprot_val(prot) == __PAGE_KERNEL_WC)
> +	if (!pat_enabled && pgprot2cachemode(prot) != _PAGE_CACHE_MODE_WB)
>  		prot = __pgprot(__PAGE_KERNEL |
>  				cachemode2protval(_PAGE_CACHE_MODE_UC_MINUS));
>  
>  	return (void __force __iomem *) kmap_atomic_prot_pfn(pfn, prot);
>  }
>  EXPORT_SYMBOL_GPL(iomap_atomic_prot_pfn);
> -#undef __PAGE_KERNEL_WC

Rejects. Please update against Juergens latest.
  
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
