Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 2D6596B0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 15:50:30 -0500 (EST)
Message-ID: <51156507.50900@zytor.com>
Date: Fri, 08 Feb 2013 12:50:15 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] add helper for highmem checks
References: <20130208202813.62965F25@kernel.stglabs.ibm.com>
In-Reply-To: <20130208202813.62965F25@kernel.stglabs.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@alien8.de, mingo@kernel.org, tglx@linutronix.de

On 02/08/2013 12:28 PM, Dave Hansen wrote:
>   #endif
> diff -puN include/linux/mm.h~clean-up-highmem-checks include/linux/mm.h
> --- linux-2.6.git/include/linux/mm.h~clean-up-highmem-checks	2013-02-08 08:42:37.295222148 -0800
> +++ linux-2.6.git-dave/include/linux/mm.h	2013-02-08 09:01:49.758254468 -0800
> @@ -1771,5 +1771,18 @@ static inline unsigned int debug_guardpa
>   static inline bool page_is_guard(struct page *page) { return false; }
>   #endif /* CONFIG_DEBUG_PAGEALLOC */
>
> +static inline phys_addr_t last_lowmem_phys_addr(void)
> +{
> +	/*
> +	 * 'high_memory' is not a pointer that can be dereferenced, so
> +	 * avoid calling __pa() on it directly.
> +	 */
> +	return __pa(high_memory - 1);
> +}
> +static inline bool phys_addr_is_highmem(phys_addr_t addr)
> +{
> +	return addr > last_lowmem_paddr();
> +}
> +

Are we sure that high_memory - 1 is always a valid reference?  Consider 
especially the case where there is MMIO beyond end of memory on a system 
which has less RAM than the HIGHMEM boundary...

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
