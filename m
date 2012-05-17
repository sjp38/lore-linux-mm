Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 258EB6B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 04:10:26 -0400 (EDT)
Message-ID: <4FB4B29C.4010908@kernel.org>
Date: Thu, 17 May 2012 17:11:08 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
References: <1337133919-4182-1-git-send-email-minchan@kernel.org> <1337133919-4182-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1337133919-4182-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, a.p.zijlstra@chello.nl, Nick Piggin <npiggin@gmail.com>

Isn't there anyone for taking a time to review this patch? :)

On 05/16/2012 11:05 AM, Minchan Kim wrote:

> The zsmalloc [un]maps non-physical contiguos pages to contiguous
> virual address frequently so it needs frequent tlb-flush.
> Now x86 doesn't support common utility function for flushing just
> a few tlb entries so zsmalloc have been used set_pte and __flush_tlb_one
> which are x86 specific functions. It means zsmalloc have a dependency
> with x86.
> 
> This patch adds new function, local_flush_tlb_kernel_range which
> are good candidate for being common utility function because other
> architecture(ex, MIPS, sh, unicore32, arm, score) already have
> supportd it.
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: David Howells <dhowells@redhat.com>
> Cc: x86@kernel.org
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  arch/x86/include/asm/tlbflush.h  |   12 ++++++++++++
>  drivers/staging/zsmalloc/Kconfig |    2 +-
>  2 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 4ece077..6e1253a 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -172,4 +172,16 @@ static inline void flush_tlb_kernel_range(unsigned long start,
>  	flush_tlb_all();
>  }
>  
> +static inline void local_flush_tlb_kernel_range(unsigned long start,
> +		unsigned long end)
> +{
> +	if (cpu_has_invlpg) {
> +		while (start < end) {
> +			__flush_tlb_single(start);
> +			start += PAGE_SIZE;
> +		}
> +	} else
> +		local_flush_tlb();
> +}
> +
>  #endif /* _ASM_X86_TLBFLUSH_H */
> diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
> index def2483..29819b8 100644
> --- a/drivers/staging/zsmalloc/Kconfig
> +++ b/drivers/staging/zsmalloc/Kconfig
> @@ -3,7 +3,7 @@ config ZSMALLOC
>  	# arch dependency is because of the use of local_unmap_kernel_range
>  	# in zsmalloc-main.c.
>  	# TODO: implement local_unmap_kernel_range in all architecture.
> -	depends on (ARM || MIPS || SUPERH)
> +	depends on (ARM || MIPS || SUPERH || X86)
>  	default n
>  	help
>  	  zsmalloc is a slab-based memory allocator designed to store



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
