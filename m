Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 027766B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 17:29:24 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so5120048pdj.21
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 14:29:24 -0700 (PDT)
Date: Tue, 24 Sep 2013 22:28:53 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mm: insure topdown mmap chooses addresses above security
	minimum
Message-ID: <20130924212853.GK12758@n2100.arm.linux.org.uk>
References: <1380057811-5352-1-git-send-email-timothy.c.pepper@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380057811-5352-1-git-send-email-timothy.c.pepper@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timothy Pepper <timothy.c.pepper@linux.intel.com>
Cc: linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org

On Tue, Sep 24, 2013 at 02:23:31PM -0700, Timothy Pepper wrote:
> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
> index 0c63562..0e7355d 100644
> --- a/arch/arm/mm/mmap.c
> +++ b/arch/arm/mm/mmap.c
> @@ -9,6 +9,7 @@
>  #include <linux/io.h>
>  #include <linux/personality.h>
>  #include <linux/random.h>
> +#include <linux/security.h>
>  #include <asm/cachetype.h>
>  
>  #define COLOUR_ALIGN(addr,pgoff)		\
> @@ -146,7 +147,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  
>  	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
>  	info.length = len;
> -	info.low_limit = PAGE_SIZE;
> +	info.low_limit = max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));
>  	info.high_limit = mm->mmap_base;
>  	info.align_mask = do_align ? (PAGE_MASK & (SHMLBA - 1)) : 0;
>  	info.align_offset = pgoff << PAGE_SHIFT;

This looks sane for ARM.

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
