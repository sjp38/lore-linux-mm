Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E66E96B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:54:58 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id g10so15068940pdj.12
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:54:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kt3si14163519pdb.33.2015.01.26.15.54.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 15:54:58 -0800 (PST)
Date: Mon, 26 Jan 2015 15:54:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] lib: Add huge I/O map capability interfaces
Message-Id: <20150126155456.a40df49e42b1b7f8077421f4@linux-foundation.org>
In-Reply-To: <1422314009-31667-3-git-send-email-toshi.kani@hp.com>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
	<1422314009-31667-3-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015 16:13:24 -0700 Toshi Kani <toshi.kani@hp.com> wrote:

> Add ioremap_pud_enabled() and ioremap_pmd_enabled(), which
> return 1 when I/O mappings of pud/pmd are enabled on the kernel.
> 
> ioremap_huge_init() calls arch_ioremap_pud_supported() and
> arch_ioremap_pmd_supported() to initialize the capabilities.
> 
> A new kernel option "nohgiomap" is also added, so that user can
> disable the huge I/O map capabilities if necessary.

Why?  What's the problem with leaving it enabled?

> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2304,6 +2304,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			register save and restore. The kernel will only save
>  			legacy floating-point registers on task switch.
>  
> +	nohgiomap	[KNL,x86] Disable huge I/O mappings.

That reads like "no high iomap" to me.  "nohugeiomap" would be better.

> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -13,6 +13,44 @@
>  #include <asm/cacheflush.h>
>  #include <asm/pgtable.h>
>  
> +#ifdef CONFIG_HUGE_IOMAP
> +int __read_mostly ioremap_pud_capable;
> +int __read_mostly ioremap_pmd_capable;
> +int __read_mostly ioremap_huge_disabled;
> +
> +static int __init set_nohgiomap(char *str)
> +{
> +	ioremap_huge_disabled = 1;
> +	return 0;
> +}
> +early_param("nohgiomap", set_nohgiomap);

Why early?

> +static inline void ioremap_huge_init(void)
> +{
> +	if (!ioremap_huge_disabled) {
> +		if (arch_ioremap_pud_supported())
> +			ioremap_pud_capable = 1;
> +		if (arch_ioremap_pmd_supported())
> +			ioremap_pmd_capable = 1;
> +	}
> +}
> +
> +static inline int ioremap_pud_enabled(void)
> +{
> +	return ioremap_pud_capable;
> +}
> +
> +static inline int ioremap_pmd_enabled(void)
> +{
> +	return ioremap_pmd_capable;
> +}
> +
> +#else	/* !CONFIG_HUGE_IOMAP */
> +static inline void ioremap_huge_init(void) { }
> +static inline int ioremap_pud_enabled(void) { return 0; }
> +static inline int ioremap_pmd_enabled(void) { return 0; }
> +#endif	/* CONFIG_HUGE_IOMAP */
> +
>  static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
>  		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
>  {
> @@ -74,6 +112,12 @@ int ioremap_page_range(unsigned long addr,
>  	unsigned long start;
>  	unsigned long next;
>  	int err;
> +	static int ioremap_huge_init_done;
> +
> +	if (!ioremap_huge_init_done) {
> +		ioremap_huge_init_done = 1;
> +		ioremap_huge_init();
> +	}

Looks hacky.  Why can't we just get the startup ordering correct?  It
at least needs a comment which fully explains the situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
