Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D74A280282
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 20:49:16 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id y205so30409526qkb.4
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 17:49:16 -0800 (PST)
Received: from mail-qt0-x234.google.com (mail-qt0-x234.google.com. [2607:f8b0:400d:c0d::234])
        by mx.google.com with ESMTPS id c14si7851414qtc.42.2016.11.11.17.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 17:49:15 -0800 (PST)
Received: by mail-qt0-x234.google.com with SMTP id p16so19841290qta.0
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 17:49:15 -0800 (PST)
Date: Fri, 11 Nov 2016 20:49:13 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH RFC] mm: Add debug_virt_to_phys()
In-Reply-To: <20161112004449.30566-1-f.fainelli@gmail.com>
Message-ID: <alpine.LFD.2.20.1611112034520.1618@knanqh.ubzr>
References: <20161112004449.30566-1-f.fainelli@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: linux-kernel@vger.kernel.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, Chris Brandt <chris.brandt@renesas.com>, Pratyush Anand <panand@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Neeraj Upadhyay <neeraju@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Marchand <jmarchan@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>, "open list:GENERIC INCLUDE/ASM HEADER FILES" <linux-arch@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, 11 Nov 2016, Florian Fainelli wrote:

> When CONFIG_DEBUG_VM is turned on, virt_to_phys() maps to
> debug_virt_to_phys() which helps catch vmalloc space addresses being
> passed. This is helpful in debugging bogus drivers that just assume
> linear mappings all over the place.
> 
> For ARM, ARM64, Unicore32 and Microblaze, the architectures define
> __virt_to_phys() as being the functional implementation of the address
> translation, so we special case the debug stub to call into
> __virt_to_phys directly.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  arch/arm/include/asm/memory.h      |  4 ++++
>  arch/arm64/include/asm/memory.h    |  4 ++++
>  include/asm-generic/memory_model.h |  4 ++++
>  mm/debug.c                         | 15 +++++++++++++++
>  4 files changed, 27 insertions(+)
> 
> diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
> index 76cbd9c674df..448dec9b8b00 100644
> --- a/arch/arm/include/asm/memory.h
> +++ b/arch/arm/include/asm/memory.h
> @@ -260,11 +260,15 @@ static inline unsigned long __phys_to_virt(phys_addr_t x)
>   * translation for translating DMA addresses.  Use the driver
>   * DMA support - see dma-mapping.h.
>   */
> +#ifndef CONFIG_DEBUG_VM
>  #define virt_to_phys virt_to_phys
>  static inline phys_addr_t virt_to_phys(const volatile void *x)
>  {
>  	return __virt_to_phys((unsigned long)(x));
>  }
> +#else
> +#define virt_to_phys debug_virt_to_phys
> +#endif
[...]

Why don't you do something more like:

 static inline phys_addr_t virt_to_phys(const volatile void *x)
 {
+        debug_virt_to_phys(x);
         return __virt_to_phys((unsigned long)(x));
 }

[...]

static inline void debug_virt_to_phys(const void *address)
{
#ifdef CONFIG_DEBUG_VM
        BUG_ON(is_vmalloc_addr(address));
#endif
}

?


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
