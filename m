Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A050E6B045C
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:54:11 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j128so137197677pfg.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:54:11 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r1si9120723pfd.81.2016.11.18.09.54.10
        for <linux-mm@kvack.org>;
        Fri, 18 Nov 2016 09:54:10 -0800 (PST)
Date: Fri, 18 Nov 2016 17:53:28 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv3 6/6] arm64: Add support for CONFIG_DEBUG_VIRTUAL
Message-ID: <20161118175327.GE1197@leverpostej>
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
 <1479431816-5028-7-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479431816-5028-7-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

Hi,

On Thu, Nov 17, 2016 at 05:16:56PM -0800, Laura Abbott wrote:
> 
> x86 has an option CONFIG_DEBUG_VIRTUAL to do additional checks
> on virt_to_phys calls. The goal is to catch users who are calling
> virt_to_phys on non-linear addresses immediately. This inclues callers
> using virt_to_phys on image addresses instead of __pa_symbol. As features
> such as CONFIG_VMAP_STACK get enabled for arm64, this becomes increasingly
> important. Add checks to catch bad virt_to_phys usage.
> 
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> v3: Make use of __pa_symbol required via debug checks. It's a WARN for now but
> it can become a BUG after wider testing. __virt_to_phys is
> now for linear addresses only. Dropped the VM_BUG_ON from Catalin's suggested
> version from the nodebug version since having that in the nodebug version
> essentially made them the debug version. Changed to KERNEL_START/KERNEL_END
> for bounds checking. More comments.

I gave this a go with DEBUG_VIRTUAL && KASAN_INLINE selected, and the
kernel dies somewhere before bringing up earlycon. :(

I mentioned some possible reasons in a reply to pastch 5, and I have
some more comments below.

[...]

> -#define __virt_to_phys(x) ({						\
> +
> +
> +/*
> + * This is for translation from the standard linear map to physical addresses.
> + * It is not to be used for kernel symbols.
> + */
> +#define __virt_to_phys_nodebug(x) ({					\
>  	phys_addr_t __x = (phys_addr_t)(x);				\
> -	__x & BIT(VA_BITS - 1) ? (__x & ~PAGE_OFFSET) + PHYS_OFFSET :	\
> -				 (__x - kimage_voffset); })
> +	((__x & ~PAGE_OFFSET) + PHYS_OFFSET);				\
> +})

Given the KASAN failure, and the strong possibility that there's even
more stuff lurking in common code, I think we should retain the logic to
handle kernel image addresses for the timebeing (as x86 does). Once
we've merged DEBUG_VIRTUAL, it will be easier to track those down.

Catalin, I think you suggested removing that logic; are you happy for it
to be restored?

See below for a refactoring that retains this logic.

[...]

> +/*
> + * This is for translation from a kernel image/symbol address to a
> + * physical address.
> + */
> +#define __pa_symbol_nodebug(x) ({					\
> +	phys_addr_t __x = (phys_addr_t)(x);				\
> +	(__x - kimage_voffset);						\
> +})

We can avoid duplication here (and in physaddr.c) if we factor the logic
into helpers, e.g.

/*
 * The linear kernel range starts in the middle of the virtual adddress
 * space. Testing the top bit for the start of the region is a
 * sufficient check.
 */
#define __is_lm_address(addr)	(!!((addr) & BIT(VA_BITS - 1)))

#define __lm_to_phys(addr)	(((addr) & ~PAGE_OFFSET) + PHYS_OFFSET)
#define __kimg_to_phys(addr)	((addr) - kimage_voffset)

#define __virt_to_phys_nodebug(x) ({					\
	phys_addr_t __x = (phys_addr_t)(x);				\
	__is_lm_address(__x) ? __lm_to_phys(__x) :			\
			       __kimg_to_phys(__x);			\
})

#define __pa_symbol_nodebug(x)	__kimg_to_phys((phys_addr_t)(x))

> +#ifdef CONFIG_DEBUG_VIRTUAL
> +extern unsigned long __virt_to_phys(unsigned long x);
> +extern unsigned long __phys_addr_symbol(unsigned long x);

It would be better for both of these to return phys_addr_t.

[...]

> diff --git a/arch/arm64/mm/physaddr.c b/arch/arm64/mm/physaddr.c
> new file mode 100644
> index 0000000..f8eb781
> --- /dev/null
> +++ b/arch/arm64/mm/physaddr.c
> @@ -0,0 +1,39 @@
> +#include <linux/mm.h>
> +
> +#include <asm/memory.h>

We also need:

#include <linux/bug.h>
#include <linux/export.h>
#include <linux/types.h>
#include <linux/mmdebug.h>

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
> +		/*
> +		 * __virt_to_phys should not be used on symbol addresses.
> +		 * This should be changed to a BUG once all basic bad uses have
> +		 * been cleaned up.
> +		 */
> +		WARN(1, "Do not use virt_to_phys on symbol addresses");
> +		return __phys_addr_symbol(x);
> +	}
> +}
> +EXPORT_SYMBOL(__virt_to_phys);

I think this would be better something like:

phys_addr_t __virt_to_phys(unsigned long x)
{
	WARN(!__is_lm_address(x),
	     "virt_to_phys() used for non-linear address: %pK\n",
	     (void*)x);
	
	return __virt_to_phys_nodebug(x);
}
EXPORT_SYMBOL(__virt_to_phys);

> +
> +unsigned long __phys_addr_symbol(unsigned long x)
> +{
> +	phys_addr_t __x = (phys_addr_t)x;
> +
> +	/*
> +	 * This is bounds checking against the kernel image only.
> +	 * __pa_symbol should only be used on kernel symbol addresses.
> +	 */
> +	VIRTUAL_BUG_ON(x < (unsigned long) KERNEL_START || x > (unsigned long) KERNEL_END);
> +	return (__x - kimage_voffset);
> +}
> +EXPORT_SYMBOL(__phys_addr_symbol);

Similarly:

phys_addr_t __phys_addr_symbol(unsigned long x)
{
	/*
	 * This is bounds checking against the kernel image only.
	 * __pa_symbol should only be used on kernel symbol addresses.
	 */
	VIRTUAL_BUG_ON(x < (unsigned long) KERNEL_START ||
		       x > (unsigned long) KERNEL_END);

	return __pa_symbol_nodebug(x);
}
EXPORT_SYMBOL(__phys_addr_symbol);

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
