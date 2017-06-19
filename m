Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3932C6B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 14:02:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h64so12658827wmg.0
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 11:02:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p34si300737wrc.158.2017.06.19.11.02.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Jun 2017 11:02:02 -0700 (PDT)
Date: Mon, 19 Jun 2017 20:01:47 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings
 of poison pages
Message-ID: <20170619180147.qolal6mz2wlrjbxk@pd.tnic>
References: <20170616190200.6210-1-tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170616190200.6210-1-tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yazen Ghannam <yazen.ghannam@amd.com>

(drop stable from CC)

You could use git's --suppress-cc= option when sending.

On Fri, Jun 16, 2017 at 12:02:00PM -0700, Luck, Tony wrote:
> From: Tony Luck <tony.luck@intel.com>
> 
> Speculative processor accesses may reference any memory that has a
> valid page table entry.  While a speculative access won't generate
> a machine check, it will log the error in a machine check bank. That
> could cause escalation of a subsequent error since the overflow bit
> will be then set in the machine check bank status register.

...

> @@ -1056,6 +1057,40 @@ static int do_memory_failure(struct mce *m)
>  	return ret;
>  }
>  
> +#ifdef CONFIG_X86_64
> +
> +void arch_unmap_kpfn(unsigned long pfn)
> +{

I guess you can move the ifdeffery inside the function.

> +	unsigned long decoy_addr;
> +
> +	/*
> +	 * Unmap this page from the kernel 1:1 mappings to make sure
> +	 * we don't log more errors because of speculative access to
> +	 * the page.
> +	 * We would like to just call:
> +	 *	set_memory_np((unsigned long)pfn_to_kaddr(pfn), 1);
> +	 * but doing that would radically increase the odds of a
> +	 * speculative access to the posion page because we'd have
> +	 * the virtual address of the kernel 1:1 mapping sitting
> +	 * around in registers.
> +	 * Instead we get tricky.  We create a non-canonical address
> +	 * that looks just like the one we want, but has bit 63 flipped.
> +	 * This relies on set_memory_np() not checking whether we passed
> +	 * a legal address.
> +	 */
> +
> +#if PGDIR_SHIFT + 9 < 63 /* 9 because cpp doesn't grok ilog2(PTRS_PER_PGD) */

Please no side comments.

Also, explain why the build-time check. (Sign-extension going away for VA
space yadda yadda..., 5 2/3 level paging :-))

Also, I'm assuming this whole "workaround" of sorts should be Intel-only?

> +	decoy_addr = (pfn << PAGE_SHIFT) + (PAGE_OFFSET ^ BIT(63));
> +#else
> +#error "no unused virtual bit available"
> +#endif
> +
> +	if (set_memory_np(decoy_addr, 1))
> +		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map \n", pfn);

WARNING: unnecessary whitespace before a quoted newline
#107: FILE: arch/x86/kernel/cpu/mcheck/mce.c:1089:
+               pr_warn("Could not invalidate pfn=0x%lx from 1:1 map \n", pfn);


-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
