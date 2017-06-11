Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C07A6B0292
	for <linux-mm@kvack.org>; Sun, 11 Jun 2017 03:58:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u101so16528645wrc.2
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 00:58:04 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id b8si6321911wra.249.2017.06.11.00.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Jun 2017 00:58:02 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id u101so15394579wrc.1
        for <linux-mm@kvack.org>; Sun, 11 Jun 2017 00:58:02 -0700 (PDT)
Date: Sun, 11 Jun 2017 09:57:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86, mm: disable 1GB direct mapping when disabling 2MB
 mapping
Message-ID: <20170611075759.aiesval452dbgfpr@gmail.com>
References: <20170609135743.9920-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170609135743.9920-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Christian Borntraeger <borntraeger@de.ibm.com>


* Vlastimil Babka <vbabka@suse.cz> wrote:

> The kmemleak and debug_pagealloc features both disable using huge pages for
> direct mapping so they can do cpa() on page level granularity in any context.
> However they only do that for 2MB pages, which means 1GB pages can still be
> used if the CPU supports it, unless disabled by a boot param, which is
> non-obvious. Disable also 1GB pages when disabling 2MB pages.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  arch/x86/mm/init.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index cbc87ea98751..20282dfce0fa 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -170,6 +170,10 @@ static void __init probe_page_size_mask(void)
>  	 */
>  	if (boot_cpu_has(X86_FEATURE_PSE) && !debug_pagealloc_enabled())
>  		page_size_mask |= 1 << PG_LEVEL_2M;
> +	else
> +		direct_gbpages = 0;
> +#else
> +	direct_gbpages = 0;
>  #endif
>  
>  	/* Enable PSE if available */

So I agree with the fix, but I think it would be much cleaner to eliminate the 
outer #ifdef:

	#if !defined(CONFIG_KMEMCHECK)

and put it into the condition, like this:

	if (boot_cpu_has(X86_FEATURE_PSE) && !debug_pagealloc_enabled() && !IS_ENABLED(CONFIG_KMEMCHECK))
		page_size_mask |= 1 << PG_LEVEL_2M;
	else
		direct_gbpages = 0;

without any #ifdeffery. This makes it much more readable all around, and also 
makes it obvious that when the 2MB size bit is not set then gbpages are disabled 
as well.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
