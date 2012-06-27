Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 363F36B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:53:26 -0400 (EDT)
Message-ID: <4FEA9FDD.6030102@kernel.org>
Date: Wed, 27 Jun 2012 14:53:33 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Alex Shi <alex.shi@intel.com>

On 06/26/2012 01:14 AM, Seth Jennings wrote:

> This patch adds support for a local_tlb_flush_kernel_range()
> function for the x86 arch.  This function allows for CPU-local
> TLB flushing, potentially using invlpg for single entry flushing,
> using an arch independent function name.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>


Anyway, we don't matter INVLPG_BREAK_EVEN_PAGES's optimization point is 8 or something.
We do care only it works without big problem.
I believe after Alex's patch is settle down, we can fix it if it's wrong.
But it shouldn't prevent merging this patch.

Acked-by: Minchan Kim <minchan@kernel.org>

Nitpick: I expect you change __HAVE_LOCAL_XXX to __HAVE_ARCH_LOCAL_XXX in next spin. :)


> ---
>  arch/x86/include/asm/tlbflush.h |   21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 36a1a2a..92a280b 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -168,4 +168,25 @@ static inline void flush_tlb_kernel_range(unsigned long start,
>  	flush_tlb_all();
>  }
>  
> +#define __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE
> +/*
> + * INVLPG_BREAK_EVEN_PAGES is the number of pages after which single tlb
> + * flushing becomes more costly than just doing a complete tlb flush.
> + * While this break even point varies among x86 hardware, tests have shown
> + * that 8 is a good generic value.
> +*/
> +#define INVLPG_BREAK_EVEN_PAGES 8
> +static inline void local_flush_tlb_kernel_range(unsigned long start,
> +		unsigned long end)
> +{
> +	if (cpu_has_invlpg &&
> +		(end - start)/PAGE_SIZE <= INVLPG_BREAK_EVEN_PAGES) {
> +		while (start < end) {
> +			__flush_tlb_single(start);
> +			start += PAGE_SIZE;
> +		}
> +	} else
> +		local_flush_tlb();
> +}
> +
>  #endif /* _ASM_X86_TLBFLUSH_H */



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
