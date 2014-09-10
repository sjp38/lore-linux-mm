Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 65FEC6B003A
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 14:29:33 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id s18so10460459lam.28
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:29:32 -0700 (PDT)
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
        by mx.google.com with ESMTPS id v2si22405315lal.134.2014.09.10.11.29.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 11:29:31 -0700 (PDT)
Received: by mail-la0-f54.google.com with SMTP id ge10so917476lab.13
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:29:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410367910-6026-4-git-send-email-toshi.kani@hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com> <1410367910-6026-4-git-send-email-toshi.kani@hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 10 Sep 2014 11:29:10 -0700
Message-ID: <CALCETrWoCYWRSDXy0W8vEhdiEKmuETMRpDMWRgYvVx71MeeTkg@mail.gmail.com>
Subject: Re: [PATCH v2 3/6] x86, mm, asm-gen: Add ioremap_wt() for WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> This patch adds ioremap_wt() for creating WT mapping on x86.
> It follows the same model as ioremap_wc() for multi-architecture
> support.  ARCH_HAS_IOREMAP_WT is defined in the x86 version of
> io.h to indicate that ioremap_wt() is implemented on x86.
>
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/x86/include/asm/io.h   |    2 ++
>  arch/x86/mm/ioremap.c       |   24 ++++++++++++++++++++++++
>  include/asm-generic/io.h    |    4 ++++
>  include/asm-generic/iomap.h |    4 ++++
>  4 files changed, 34 insertions(+)
>
> diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
> index 71b9e65..c813c86 100644
> --- a/arch/x86/include/asm/io.h
> +++ b/arch/x86/include/asm/io.h
> @@ -35,6 +35,7 @@
>    */
>
>  #define ARCH_HAS_IOREMAP_WC
> +#define ARCH_HAS_IOREMAP_WT
>
>  #include <linux/string.h>
>  #include <linux/compiler.h>
> @@ -316,6 +317,7 @@ extern void unxlate_dev_mem_ptr(unsigned long phys, void *addr);
>  extern int ioremap_change_attr(unsigned long vaddr, unsigned long size,
>                                 enum page_cache_mode pcm);
>  extern void __iomem *ioremap_wc(resource_size_t offset, unsigned long size);
> +extern void __iomem *ioremap_wt(resource_size_t offset, unsigned long size);
>
>  extern bool is_early_ioremap_ptep(pte_t *ptep);
>
> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
> index 885fe44..952f4b4 100644
> --- a/arch/x86/mm/ioremap.c
> +++ b/arch/x86/mm/ioremap.c
> @@ -155,6 +155,10 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
>                 prot = __pgprot(pgprot_val(prot) |
>                                 cachemode2protval(_PAGE_CACHE_MODE_WC));
>                 break;
> +       case _PAGE_CACHE_MODE_WT:
> +               prot = __pgprot(pgprot_val(prot) |
> +                               cachemode2protval(_PAGE_CACHE_MODE_WT));
> +               break;
>         case _PAGE_CACHE_MODE_WB:
>                 break;
>         }
> @@ -249,6 +253,26 @@ void __iomem *ioremap_wc(resource_size_t phys_addr, unsigned long size)
>  }
>  EXPORT_SYMBOL(ioremap_wc);
>
> +/**
> + * ioremap_wt  -       map memory into CPU space write through
> + * @phys_addr: bus address of the memory
> + * @size:      size of the resource to map
> + *
> + * This version of ioremap ensures that the memory is marked write through.
> + * Write through writes data into memory while keeping the cache up-to-date.
> + *
> + * Must be freed with iounmap.
> + */
> +void __iomem *ioremap_wt(resource_size_t phys_addr, unsigned long size)
> +{
> +       if (pat_enabled)
> +               return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WT,
> +                                       __builtin_return_address(0));
> +       else
> +               return ioremap_nocache(phys_addr, size);
> +}
> +EXPORT_SYMBOL(ioremap_wt);
> +
>  void __iomem *ioremap_cache(resource_size_t phys_addr, unsigned long size)
>  {
>         return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WB,
> diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
> index 975e1cc..405d418 100644
> --- a/include/asm-generic/io.h
> +++ b/include/asm-generic/io.h
> @@ -322,6 +322,10 @@ static inline void __iomem *ioremap(phys_addr_t offset, unsigned long size)
>  #define ioremap_wc ioremap_nocache
>  #endif
>
> +#ifndef ioremap_wt
> +#define ioremap_wt ioremap_nocache
> +#endif
> +
>  static inline void iounmap(void __iomem *addr)
>  {
>  }
> diff --git a/include/asm-generic/iomap.h b/include/asm-generic/iomap.h
> index 1b41011..d8f8622 100644
> --- a/include/asm-generic/iomap.h
> +++ b/include/asm-generic/iomap.h
> @@ -66,6 +66,10 @@ extern void ioport_unmap(void __iomem *);
>  #define ioremap_wc ioremap_nocache
>  #endif
>
> +#ifndef ARCH_HAS_IOREMAP_WT
> +#define ioremap_wt ioremap_nocache
> +#endif
> +

This is a little bit sad.  I wouldn't be too surprised if there are
eventually users who prefer WC or WB over UC if WT isn't available
(and they'll want a corresponding way to figure out what kind of fence
to use).

Hey Intel and AMD: want to add another memtype that has cacheable
reads but acts like WC for writes?  Being able to use sfence to flush
to NV-DIMMs would be neat!  (Presumably nontemporal stores to WT
memory work like that, but this stuff is barely documented.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
