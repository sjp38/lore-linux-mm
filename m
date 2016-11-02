Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35A196B0278
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 19:06:48 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hr10so14205681pac.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 16:06:48 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i6si4677086pao.147.2016.11.02.16.06.47
        for <linux-mm@kvack.org>;
        Wed, 02 Nov 2016 16:06:47 -0700 (PDT)
Date: Wed, 2 Nov 2016 23:06:43 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv2 6/6] arm64: Add support for CONFIG_DEBUG_VIRTUAL
Message-ID: <20161102230642.GB19591@remoulade>
References: <20161102210054.16621-1-labbott@redhat.com>
 <20161102210054.16621-7-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161102210054.16621-7-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Wed, Nov 02, 2016 at 03:00:54PM -0600, Laura Abbott wrote:
> +CFLAGS_physaddr.o		:= -DTEXT_OFFSET=$(TEXT_OFFSET)
> +obj-$(CONFIG_DEBUG_VIRTUAL)	+= physaddr.o

> diff --git a/arch/arm64/mm/physaddr.c b/arch/arm64/mm/physaddr.c
> new file mode 100644
> index 0000000..874c782
> --- /dev/null
> +++ b/arch/arm64/mm/physaddr.c
> @@ -0,0 +1,34 @@
> +#include <linux/mm.h>
> +
> +#include <asm/memory.h>
> +
> +unsigned long __virt_to_phys(unsigned long x)
> +{
> +	phys_addr_t __x = (phys_addr_t)x;
> +
> +	if (__x & BIT(VA_BITS - 1)) {
> +		/*
> +		 * The linear kernel range starts in the middle of the virtual
> +		 * adddress space. Testing the top bit for the start of the
> +		 * region is a sufficient check.
> +		 */
> +		return (__x & ~PAGE_OFFSET) + PHYS_OFFSET;
> +	} else {
> +		VIRTUAL_BUG_ON(x < kimage_vaddr || x >= (unsigned long)_end);
> +		return (__x - kimage_voffset);
> +	}
> +}
> +EXPORT_SYMBOL(__virt_to_phys);
> +
> +unsigned long __phys_addr_symbol(unsigned long x)
> +{
> +	phys_addr_t __x = (phys_addr_t)x;
> +
> +	/*
> +	 * This is intentionally different than above to be a tighter check
> +	 * for symbols.
> +	 */
> +	VIRTUAL_BUG_ON(x < kimage_vaddr + TEXT_OFFSET || x > (unsigned long) _end);

Can't we use _text instead of kimage_vaddr + TEXT_OFFSET? That way we don't
need CFLAGS_physaddr.o.

Or KERNEL_START / KERNEL_END from <asm/memory.h>?

Otherwise, this looks good to me (though I haven't grokked the need for
__pa_symbol() yet).

Thanks,
Mark.

> +	return (__x - kimage_voffset);
> +}
> +EXPORT_SYMBOL(__phys_addr_symbol);
> -- 
> 2.10.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
