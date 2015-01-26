Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 24DB06B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:58:14 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so14629531pad.1
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:58:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ht9si13955527pad.207.2015.01.26.15.58.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 15:58:13 -0800 (PST)
Date: Mon, 26 Jan 2015 15:58:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 3/7] mm: Change ioremap to set up huge I/O mappings
Message-Id: <20150126155811.0ade183f5f3f89277d11fde6@linux-foundation.org>
In-Reply-To: <1422314009-31667-4-git-send-email-toshi.kani@hp.com>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
	<1422314009-31667-4-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015 16:13:25 -0700 Toshi Kani <toshi.kani@hp.com> wrote:

> Change ioremap_pud_range() and ioremap_pmd_range() to set up
> huge I/O mappings when their capability is enabled and their
> conditions are met in a given request -- both virtual & physical
> addresses are aligned and its range fufills the mapping size.
> 
> These changes are only enabled when both CONFIG_HUGE_IOMAP
> and CONFIG_HAVE_ARCH_HUGE_VMAP are defined.
> 
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -81,6 +81,14 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
>  		return -ENOMEM;
>  	do {
>  		next = pmd_addr_end(addr, end);
> +
> +		if (ioremap_pmd_enabled() &&
> +		    ((next - addr) == PMD_SIZE) &&
> +		    !((phys_addr + addr) & (PMD_SIZE-1))) {

IS_ALIGNED might be a little neater here.

> +			pmd_set_huge(pmd, phys_addr + addr, prot);
> +			continue;
> +		}
> +
>  		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
>  			return -ENOMEM;
>  	} while (pmd++, addr = next, addr != end);
> @@ -99,6 +107,14 @@ static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
>  		return -ENOMEM;
>  	do {
>  		next = pud_addr_end(addr, end);
> +
> +		if (ioremap_pud_enabled() &&
> +		    ((next - addr) == PUD_SIZE) &&
> +		    !((phys_addr + addr) & (PUD_SIZE-1))) {

And here.

> +			pud_set_huge(pud, phys_addr + addr, prot);
> +			continue;
> +		}
> +
>  		if (ioremap_pmd_range(pud, addr, next, phys_addr + addr, prot))
>  			return -ENOMEM;
>  	} while (pud++, addr = next, addr != end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
