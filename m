Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBCD6B0070
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 11:08:02 -0400 (EDT)
Received: by labko7 with SMTP id ko7so35333464lab.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:08:01 -0700 (PDT)
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com. [209.85.215.52])
        by mx.google.com with ESMTPS id a4si3817089lak.156.2015.06.17.08.07.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 08:08:00 -0700 (PDT)
Received: by labbc20 with SMTP id bc20so35228997lab.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:07:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150611211947.10271.80768.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150611211354.10271.57950.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20150611211947.10271.80768.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 17 Jun 2015 08:07:38 -0700
Message-ID: <CALCETrXXYyjKHi1ajR6aescmjSo5eds=5g_byWpzBRbBNdsgRQ@mail.gmail.com>
Subject: Re: [PATCH v4 6/6] arch, x86: pmem api for ensuring durability of
 persistent memory updates
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, X86 ML <x86@kernel.org>, Toshi Kani <toshi.kani@hp.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Luis Rodriguez <mcgrof@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Michael Ellerman <mpe@ellerman.id.au>, Tejun Heo <tj@kernel.org>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>

On Thu, Jun 11, 2015 at 2:19 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> From: Ross Zwisler <ross.zwisler@linux.intel.com>
>
> Based on an original patch by Ross Zwisler [1].
>
> Writes to persistent memory have the potential to be posted to cpu
> cache, cpu write buffers, and platform write buffers (memory controller)
> before being committed to persistent media.  Provide apis,
> memcpy_to_pmem(), sync_pmem(), and memremap_pmem(), to write data to
> pmem and assert that it is durable in PMEM (a persistent linear address
> range).  A '__pmem' attribute is added so sparse can track proper usage
> of pointers to pmem.
>
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2015-May/000932.html
>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> [djbw: various reworks]
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/x86/Kconfig                  |    1
>  arch/x86/include/asm/cacheflush.h |   36 +++++++++++++
>  arch/x86/include/asm/io.h         |    6 ++
>  drivers/block/pmem.c              |   75 +++++++++++++++++++++++++--
>  include/linux/compiler.h          |    2 +
>  include/linux/pmem.h              |  102 +++++++++++++++++++++++++++++++++++++
>  lib/Kconfig                       |    3 +
>  7 files changed, 218 insertions(+), 7 deletions(-)
>  create mode 100644 include/linux/pmem.h
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index f16caf7eac27..5dfb8f31ac48 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -28,6 +28,7 @@ config X86
>         select ARCH_HAS_FAST_MULTIPLIER
>         select ARCH_HAS_GCOV_PROFILE_ALL
>         select ARCH_HAS_MEMREMAP
> +       select ARCH_HAS_PMEM_API
>         select ARCH_HAS_SG_CHAIN
>         select ARCH_HAVE_NMI_SAFE_CMPXCHG
>         select ARCH_MIGHT_HAVE_ACPI_PDC         if ACPI
> diff --git a/arch/x86/include/asm/cacheflush.h b/arch/x86/include/asm/cacheflush.h
> index b6f7457d12e4..4d896487382c 100644
> --- a/arch/x86/include/asm/cacheflush.h
> +++ b/arch/x86/include/asm/cacheflush.h
> @@ -4,6 +4,7 @@
>  /* Caches aren't brain-dead on the intel. */
>  #include <asm-generic/cacheflush.h>
>  #include <asm/special_insns.h>
> +#include <asm/uaccess.h>
>
>  /*
>   * The set_memory_* API can be used to change various attributes of a virtual
> @@ -108,4 +109,39 @@ static inline int rodata_test(void)
>  }
>  #endif
>
> +#ifdef ARCH_HAS_NOCACHE_UACCESS
> +static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src, size_t n)
> +{
> +       /*
> +        * We are copying between two kernel buffers, if
> +        * __copy_from_user_inatomic_nocache() returns an error (page
> +        * fault) we would have already taken an unhandled fault before
> +        * the BUG_ON.  The BUG_ON is simply here to satisfy
> +        * __must_check and allow reuse of the common non-temporal store
> +        * implementation for memcpy_to_pmem().
> +        */
> +       BUG_ON(__copy_from_user_inatomic_nocache((void __force *) dst,
> +                               (void __user *) src, n));

Ick.  If we take a fault, we will lose the debugging information we
would otherwise have gotten unless we get lucky and get a usable CR2
value in the oops.

> +}
> +
> +static inline void arch_sync_pmem(void)
> +{
> +       wmb();
> +       pcommit_sfence();
> +}

This function is non-intuitive to me.  It's really "arch-specific sync
pmem after one or more copies using arch_memcpy_to_pmem".  If normal
stores or memcpy to non-WC memory is used instead, then it's
insufficient if the memory is WB and it's unnecessarily slow if the
memory is WT or UC (the first sfence isn't needed).

I would change the name and add documentation.  I'd also add a comment
about the wmb() being an SFENCE to flush pending non-temporal writes.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
