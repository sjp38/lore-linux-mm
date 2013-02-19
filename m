Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 6B5C96B0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 13:21:32 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id hz10so3498648pad.35
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 10:21:31 -0800 (PST)
Date: Tue, 19 Feb 2013 10:20:50 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] arm: Set the page table freeing ceiling to
 TASK_SIZE
In-Reply-To: <1361204311-14127-3-git-send-email-catalin.marinas@arm.com>
Message-ID: <alpine.LNX.2.00.1302191008290.2139@eggly.anvils>
References: <1361204311-14127-1-git-send-email-catalin.marinas@arm.com> <1361204311-14127-3-git-send-email-catalin.marinas@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Mon, 18 Feb 2013, Catalin Marinas wrote:

> ARM processors with LPAE enabled use 3 levels of page tables, with an
> entry in the top level (pgd) covering 1GB of virtual space. Because of
> the branch relocation limitations on ARM, the loadable modules are
> mapped 16MB below PAGE_OFFSET, making the corresponding 1GB pgd shared
> between kernel modules and user space.
> 
> If free_pgtables() is called with the default ceiling 0,
> free_pgd_range() (and subsequently called functions) also frees the page
> table shared between user space and kernel modules (which is normally
> handled by the ARM-specific pgd_free() function). This patch changes
> defines the ARM USER_PGTABLES_CEILING to TASK_SIZE.

I don't have an ARM to test on, so I won't ack or nack this,
but I am a little worried or puzzled.

I thought CONFIG_ARM_LPAE came in v3.3: so I would expect these
patches to need "Cc: stable@vger.kernel.org" for porting back there.

But then, did v3.3..v3.8 have the appropriate arch/arm code to handle
the freeing of the user+kernel pgd?  I'm not asserting that it could
not, but when doing the similar arch/x86 thing, I had to make changes
down there, so it's not necessarily something that works automatically.

And does the ARM !LPAE case work correctly (not leaking page tables
at any level) with this change from 0 to TASK_SIZE?  Again, I'm not
asserting that it does not, but your commit description doesn't give
enough confidence that you've tried that.

Perhaps you have some other patches to arch/arm, that of course I
wouldn't have noticed, which make this all work together; and it's
accepted that CONFIG_ARM_LPAE is broken on v3.3..v3.8, and too
much risk to backport it all for -stable.

Maybe all I'm asking for is a more reassuring commit description.

Hugh

> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  arch/arm/include/asm/pgtable.h | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
> index c094749..8f06ee5 100644
> --- a/arch/arm/include/asm/pgtable.h
> +++ b/arch/arm/include/asm/pgtable.h
> @@ -61,6 +61,13 @@ extern void __pgd_error(const char *file, int line, pgd_t);
>  #define FIRST_USER_ADDRESS	PAGE_SIZE
>  
>  /*
> + * Use TASK_SIZE as the ceiling argument for free_pgtables() and
> + * free_pgd_range() to avoid freeing the modules pmd when LPAE is enabled (pmd
> + * page shared between user and kernel).
> + */
> +#define USER_PGTABLES_CEILING	TASK_SIZE
> +
> +/*
>   * The pgprot_* and protection_map entries will be fixed up in runtime
>   * to include the cachable and bufferable bits based on memory policy,
>   * as well as any architecture dependent bits like global/ASID and SMP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
